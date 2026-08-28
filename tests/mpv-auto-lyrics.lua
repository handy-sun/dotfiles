local source = debug.getinfo(1, "S").source:sub(2)
local root = source:match("^(.*)/tests/") or "."

_G.MPV_AUTO_LYRICS_TEST = true
local lyrics = dofile(root .. "/.config/mpv/scripts/auto-lyrics.lua")
_G.MPV_AUTO_LYRICS_TEST = nil

local function equal(actual, expected, message)
  if actual ~= expected then
    error(string.format("%s: expected %q, got %q", message, expected, actual), 2)
  end
end

local function truthy(actual, message)
  if not actual then
    error(message, 2)
  end
end

local function falsy(actual, message)
  if actual then
    error(message, 2)
  end
end

local embedded, synced = lyrics.find_embedded_lyrics({
  UNSYNCEDLYRICS = "plain lyrics",
  ["lyrics-LYRICS-XXX"] = "[00:01.20]同步歌词\n[00:04.00]第二行",
})
equal(embedded, "[00:01.20]同步歌词\n[00:04.00]第二行", "synchronized embedded lyrics take priority")
truthy(synced, "embedded LRC timestamps should be recognized")
truthy(lyrics.is_synchronized("[00:01]无小数时间戳"), "LRC timestamps may omit fractions")

local plain, plain_synced = lyrics.find_embedded_lyrics({ lyrics = "第一行\r\n第二行" })
equal(plain, "第一行\n第二行", "embedded lyrics should normalize newlines")
falsy(plain_synced, "plain embedded lyrics should not be treated as synchronized")

local metadata = lyrics.normalize_metadata({
  TITLE = "  夜曲  ",
  Album_Artist = "周杰伦",
  album = "十一月的萧邦",
})
equal(metadata.title, "夜曲", "title metadata should be normalized")
equal(metadata.artist, "周杰伦", "album artist should be used as fallback")
equal(metadata.album, "十一月的萧邦", "album metadata should be preserved")

truthy(lyrics.is_audio_only({
  { type = "audio" },
  { type = "video", albumart = true },
}), "album art should still count as audio-only playback")
falsy(lyrics.is_audio_only({
  { type = "audio" },
  { type = "video", albumart = false },
}), "ordinary video playback should not trigger lyric downloads")

truthy(lyrics.has_subtitle_track({ { type = "sub" } }), "an existing subtitle should suppress lyric lookup")
falsy(lyrics.has_subtitle_track({ { type = "audio" } }), "audio-only tracks should allow lyric lookup")

local cache_name = lyrics.cache_filename({
  artist = "陈奕迅/DUO",
  title = "富士山下: Live?",
}, 259.6)
equal(cache_name, "陈奕迅_DUO - 富士山下_ Live_ [260].lrc", "cache filenames should be safe and stable")

local network = lyrics.select_network_lyrics({
  syncedLyrics = "[00:01.00]网络同步歌词",
  plainLyrics = "网络普通歌词",
})
equal(network, "[00:01.00]网络同步歌词", "network synchronized lyrics should be preferred")
equal(lyrics.select_network_lyrics({ plainLyrics = "网络普通歌词" }), nil, "plain network lyrics cannot be timed")
equal(lyrics.select_network_lyrics(42), nil, "invalid network responses should be ignored")

local searched = lyrics.select_search_result({
  {
    trackName = "夜曲 (Live)",
    artistName = "周杰伦",
    duration = 260,
    syncedLyrics = "[00:01.00]错误候选",
  },
  {
    trackName = "夜曲",
    artistName = "周杰伦",
    duration = 259,
    syncedLyrics = "[00:01.00]精确候选",
  },
}, metadata, 259.6)
equal(searched, "[00:01.00]精确候选", "search fallback should prefer matching synchronized lyrics")
equal(lyrics.select_search_result({
  {
    trackName = "完全不同的歌曲",
    artistName = "其他歌手",
    duration = 259,
    syncedLyrics = "[00:01.00]错误歌词",
  },
}, metadata, 259.6), nil, "search fallback should reject unrelated lyrics")
equal(lyrics.select_search_result(42, metadata, 259.6), nil, "invalid search responses should be ignored")

print("mpv auto-lyrics tests passed")
