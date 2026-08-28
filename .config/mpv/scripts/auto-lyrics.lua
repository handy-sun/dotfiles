local M = {}

local function trim(value)
  if type(value) ~= "string" then
    return nil
  end
  value = value:gsub("^\239\187\191", ""):gsub("\r\n", "\n"):gsub("\r", "\n")
  value = value:match("^%s*(.-)%s*$")
  return value ~= "" and value or nil
end

function M.is_synchronized(lyrics)
  return type(lyrics) == "string"
    and (lyrics:find("%[%d+:%d%d%]") ~= nil or lyrics:find("%[%d+:%d%d[%.:,]%d+%]") ~= nil)
end

function M.find_embedded_lyrics(tags)
  local plain
  for key, value in pairs(tags or {}) do
    local normalized_key = tostring(key):lower():gsub("[%s_-]", "")
    if normalized_key:find("lyrics", 1, true) or normalized_key == "uslt" or normalized_key == "sylt" then
      local candidate = trim(value)
      if candidate then
        if M.is_synchronized(candidate) then
          return candidate, true
        end
        plain = plain or candidate
      end
    end
  end
  return plain, false
end

function M.normalize_metadata(tags)
  local normalized = {}
  for key, value in pairs(tags or {}) do
    normalized[tostring(key):lower():gsub("[%s-]", "_")] = trim(value)
  end
  return {
    title = normalized.title,
    artist = normalized.artist or normalized.album_artist or normalized.albumartist,
    album = normalized.album,
  }
end

function M.is_audio_only(tracks)
  local has_audio = false
  for _, track in ipairs(tracks or {}) do
    if track.type == "audio" then
      has_audio = true
    elseif track.type == "video" and not track.albumart then
      return false
    end
  end
  return has_audio
end

function M.has_subtitle_track(tracks)
  for _, track in ipairs(tracks or {}) do
    if track.type == "sub" then
      return true
    end
  end
  return false
end

local function safe_prefix(value, max_bytes)
  if #value <= max_bytes then
    return value
  end
  local cut = max_bytes
  while cut > 0 do
    local next_byte = value:byte(cut + 1)
    if not next_byte or next_byte < 128 or next_byte >= 192 then
      break
    end
    cut = cut - 1
  end
  return value:sub(1, cut)
end

function M.cache_filename(metadata, duration)
  local artist = trim(metadata.artist) or "未知歌手"
  local title = trim(metadata.title) or "未知歌曲"
  local base = (artist .. " - " .. title):gsub("[\\/:*?\"<>|%c]", "_"):gsub("%s+", " ")
  base = safe_prefix(base, 200)
  return string.format("%s [%d].lrc", base, math.floor((duration or 0) + 0.5))
end

function M.select_network_lyrics(response)
  if type(response) ~= "table" then
    return nil
  end
  local lyrics = trim(response.syncedLyrics)
  return M.is_synchronized(lyrics) and lyrics or nil
end

local function comparable(value)
  value = trim(value)
  return value and value:lower():gsub("[%s%p]", "") or ""
end

function M.select_search_result(results, metadata, duration)
  if type(results) ~= "table" then
    return nil
  end
  local best_lyrics, best_score
  for _, result in ipairs(results) do
    local lyrics = M.select_network_lyrics(result)
    if lyrics then
      local score = 0
      if comparable(result.trackName) == comparable(metadata.title) then
        score = score + 100
      end
      if comparable(result.artistName) == comparable(metadata.artist) then
        score = score + 50
      end
      if metadata.album and comparable(result.albumName) == comparable(metadata.album) then
        score = score + 20
      end
      if duration and result.duration then
        score = score + math.max(0, 30 - math.abs(duration - result.duration))
      end
      if not best_score or score > best_score then
        best_lyrics, best_score = lyrics, score
      end
    end
  end
  return best_score and best_score >= 120 and best_lyrics or nil
end

if rawget(_G, "MPV_AUTO_LYRICS_TEST") then
  return M
end

local utils = require("mp.utils")
local options = {
  cache_dir = "@cacheDir@",
  curl_path = "@curlPath@",
  ffprobe_path = "@ffprobePath@",
  mkdir_path = "@mkdirPath@",
  endpoint = "https://lrclib.net/api",
  timeout = 10,
}

require("mp.options").read_options(options)

local lookup_id = 0

local function is_current(id, path)
  return id == lookup_id and mp.get_property("path") == path
end

local function notify(message)
  mp.msg.info(message)
  if mp.get_property_native("vo-configured") then
    mp.osd_message(message, 3)
  end
end

local function read_file(path)
  local file = io.open(path, "rb")
  if not file then
    return nil
  end
  local content = file:read("*a")
  file:close()
  return content
end

local function write_cache(path, content)
  utils.subprocess({ args = { options.mkdir_path, "-p", options.cache_dir } })
  local temporary = path .. ".tmp"
  local file, error_message = io.open(temporary, "wb")
  if not file then
    mp.msg.error("无法写入歌词缓存: " .. tostring(error_message))
    return false
  end
  file:write(content)
  file:close()
  if not os.rename(temporary, path) then
    os.remove(temporary)
    mp.msg.error("无法更新歌词缓存: " .. path)
    return false
  end
  return true
end

local function cache_path(metadata, duration)
  return utils.join_path(options.cache_dir, M.cache_filename(metadata, duration))
end

local function load_lyrics(lyrics, metadata, duration, source)
  local path = cache_path(metadata, duration)
  if read_file(path) ~= lyrics and not write_cache(path, lyrics) then
    return false
  end
  mp.commandv("sub-add", path, "select", "歌词 · " .. source)
  notify("已加载" .. source .. "歌词")
  return true
end

local function subprocess_async(args, callback)
  mp.command_native_async({
    name = "subprocess",
    args = args,
    capture_stdout = true,
    capture_stderr = true,
    playback_only = false,
  }, function(success, result, error_message)
    if not success or not result or result.status ~= 0 then
      callback(nil, error_message or (result and result.stderr))
      return
    end
    callback(result.stdout)
  end)
end

local function parse_json(content)
  if not content then
    return nil
  end
  local value, error_message = utils.parse_json(content)
  if error_message then
    mp.msg.warn("歌词服务返回了无效 JSON: " .. error_message)
    return nil
  end
  return value
end

local function curl_request(path, parameters, callback)
  local args = {
    options.curl_path,
    "--silent",
    "--show-error",
    "--get",
    "--max-time",
    tostring(options.timeout),
    "--max-filesize",
    "1048576",
    "--user-agent",
    "expnix-mpv-auto-lyrics/1.0",
    options.endpoint .. path,
  }
  for _, parameter in ipairs(parameters) do
    args[#args + 1] = "--data-urlencode"
    args[#args + 1] = parameter
  end
  subprocess_async(args, function(stdout, error_message)
    callback(parse_json(stdout), error_message)
  end)
end

local function search_lrclib(id, path, metadata, duration)
  curl_request("/search", {
    "track_name=" .. metadata.title,
    "artist_name=" .. metadata.artist,
  }, function(response, error_message)
    if not is_current(id, path) then
      return
    end
    local lyrics = M.select_search_result(response, metadata, duration)
    if lyrics then
      load_lyrics(lyrics, metadata, duration, "LRCLIB")
    else
      mp.msg.info("未找到同步歌词" .. (error_message and (": " .. error_message) or ""))
    end
  end)
end

local function fetch_lrclib(id, path, metadata, duration)
  if not metadata.title or not metadata.artist then
    mp.msg.info("缺少歌曲标题或歌手标签，跳过在线歌词")
    return
  end

  local parameters = {
    "track_name=" .. metadata.title,
    "artist_name=" .. metadata.artist,
    "duration=" .. tostring(math.floor(duration + 0.5)),
  }
  if metadata.album then
    parameters[#parameters + 1] = "album_name=" .. metadata.album
  end

  curl_request("/get", parameters, function(response)
    if not is_current(id, path) then
      return
    end
    local lyrics = M.select_network_lyrics(response)
    if lyrics then
      load_lyrics(lyrics, metadata, duration, "LRCLIB")
    else
      search_lrclib(id, path, metadata, duration)
    end
  end)
end

local function load_cached_or_fetch(id, path, metadata, duration)
  local cached = read_file(cache_path(metadata, duration))
  if M.is_synchronized(cached) then
    mp.commandv("sub-add", cache_path(metadata, duration), "select", "歌词 · 本地缓存")
    notify("已加载本地缓存歌词")
    return
  end
  fetch_lrclib(id, path, metadata, duration)
end

local function probe_embedded(id, path, metadata, duration)
  subprocess_async({
    options.ffprobe_path,
    "-v",
    "error",
    "-show_entries",
    "format_tags",
    "-of",
    "json",
    path,
  }, function(stdout)
    if not is_current(id, path) then
      return
    end
    local response = parse_json(stdout) or {}
    local tags = response.format and response.format.tags or {}
    local probed_metadata = M.normalize_metadata(tags)
    metadata.title = metadata.title or probed_metadata.title
    metadata.artist = metadata.artist or probed_metadata.artist
    metadata.album = metadata.album or probed_metadata.album

    local embedded, synchronized = M.find_embedded_lyrics(tags)
    if embedded and synchronized then
      load_lyrics(embedded, metadata, duration, "内嵌")
      return
    end
    if embedded then
      mp.msg.info("找到无时间戳的内嵌歌词，继续查找同步歌词")
    end
    load_cached_or_fetch(id, path, metadata, duration)
  end)
end

local function start_lookup()
  lookup_id = lookup_id + 1
  local id = lookup_id
  local path = mp.get_property("path")
  local tracks = mp.get_property_native("track-list", {})
  if not path or path:find("^[%a][%w+.-]*://") or not M.is_audio_only(tracks) or M.has_subtitle_track(tracks) then
    return
  end

  local duration = mp.get_property_number("duration", 0)
  local metadata = M.normalize_metadata(mp.get_property_native("metadata", {}))
  probe_embedded(id, path, metadata, duration)
end

mp.register_event("file-loaded", start_lookup)
mp.register_event("end-file", function()
  lookup_id = lookup_id + 1
end)
