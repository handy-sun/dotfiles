<!-- <details>
  <summary>Alacritty 终端配置说明</summary>
<p> -->

## Alacritty 终端配置说明

这是一个基于 Tango Dark 主题的 Alacritty 终端模拟器配置文件，提供了美观的配色方案、定制化的快捷键和实用的功能设置。

### 颜色主题

使用 Tango Dark 配色方案：

#### 基础颜色
- **背景色**: `#2e3436` (深灰色)
- **前景色**: `#d3d7cf` (浅灰白色)

#### 标准颜色
- **黑色**: `#2e3436`
- **红色**: `#cc0000`
- **绿色**: `#4e9a06`
- **黄色**: `#c4a000`
- **蓝色**: `#3465a4`
- **洋红色**: `#75507b`
- **青色**: `#06989a`
- **白色**: `#d3d7cf`

#### 亮色版本
- **亮黑色**: `#555753`
- **亮红色**: `#ef2929`
- **亮绿色**: `#8ae234`
- **亮黄色**: `#fce94f`
- **亮蓝色**: `#729fcf`
- **亮洋红色**: `#ad7fa8`
- **亮青色**: `#34e2e2`
- **亮白色**: `#eeeeec`

### 字体设置

- **大小**: 16pt (适用于1.5x放大的4k分辨率)
- **字体家族**: `NotoMono Nerd Font Mono` (`NotoMono NFM`也可)

### 窗口设置

- **装饰**: 完整窗口装饰 (`Full`)
- **动态内边距**: 启用 (`dynamic_padding = true`)
- **动态标题**: 启用 (`dynamic_title = true`)
- **透明度**: 0.96
- **启动模式**: 最大化 (`Maximized`)
- **窗口尺寸**: 自动适应屏幕 (`columns = 0`, `lines = 0`)
- **窗口内边距**: x=0, y=0

### 终端 Shell

- **程序**: 使用 fish shell (`/usr/local/bin/fish`)
- **参数**: `-l -i` (加载登录脚本和交互式模式)

### 快捷键绑定

#### 基础操作
- **新建实例**: `Ctrl+Shift+Return` - 打开新的终端实例
- **复制**: `Ctrl+Shift+C` - 复制选中的文本到剪贴板
- **粘贴**: `Ctrl+Shift+V` - 从剪贴板粘贴文本
- **粘贴选择**: `Shift+Insert` - 粘贴鼠标选中区域的文本
- **清除日志通知**: `Ctrl+L` - 清除终端日志和通知
- **发送清屏字符**: `Ctrl+L` - 发送换页符 `\f` 到终端

#### 导航键
- **Home 键**:
  - `Alt+Home`: 发送 `\u001B[1;3H` 序列
  - `Home` (应用光标模式): 发送 `\u001BOH`
  - `Home` (非应用光标模式): 发送 `\u001B[H`
- **End 键**:
  - `Alt+End`: 发送 `\u001B[1;3F` 序列
  - `End` (应用光标模式): 发送 `\u001BOF`
  - `End` (非应用光标模式): 发送 `\u001B[F`

#### 滚动操作
- **向上翻页**: 
  - `Shift+PageUp` (非 Alt 模式): 滚动页面向上
  - `Shift+Alt+PageUp`: 发送 `\u001B[5;2~`
  - `Ctrl+PageUp`: 发送 `\u001B[5;5~`
  - `Alt+PageUp`: 发送 `\u001B[5;3~`
  - `PageUp`: 发送 `\u001B[5~`
- **向下翻页**:
  - `Shift+PageDown` (非 Alt 模式): 滚动页面向下
  - `Shift+Alt+PageDown`: 发送 `\u001B[6;2~`
  - `Ctrl+PageDown`: 发送 `\u001B[6;5~`
  - `Alt+PageDown`: 发送 `\u001B[6;3~`
  - `PageDown`: 发送 `\u001B[6~`

#### 光标移动
- **左箭头**:
  - `Shift+Left`: 发送 `\u001B[1;2D`
  - `Ctrl+Left`: 发送 `\u001B[1;5D`
  - `Alt+Left`: 发送 `\u001B[1;3D`
  - `Left` (非应用光标模式): 发送 `\u001B[D`
  - `Left` (应用光标模式): 发送 `\u001BOD`
- **右箭头**:
  - `Shift+Right`: 发送 `\u001B[1;2C`
  - `Ctrl+Right`: 发送 `\u001B[1;5C`
  - `Alt+Right`: 发送 `\u001B[1;3C`
  - `Right` (非应用光标模式): 发送 `\u001B[C`
  - `Right` (应用光标模式): 发送 `\u001BOC`
- **上箭头**:
  - `Shift+Up`: 发送 `\u001B[1;2A`
  - `Ctrl+Up`: 发送 `\u001B[1;5A`
  - `Alt+Up`: 发送 `\u001B[1;3A`
  - `Up` (非应用光标模式): 发送 `\u001B[A`
  - `Up` (应用光标模式): 发送 `\u001BOA`
- **下箭头**:
  - `Shift+Down`: 发送 `\u001B[1;2B`
  - `Ctrl+Down`: 发送 `\u001B[1;5B`
  - `Alt+Down`: 发送 `\u001B[1;3B`
  - `Down` (非应用光标模式): 发送 `\u001B[B`
  - `Down` (应用光标模式): 发送 `\u001BOB`

#### 特殊键位
- **Tab 键**: `Shift+Tab` 发送 `\u001B[Z` (反向制表符)
- **退格键**: `Alt+Backspace` 发送 `\u001B\u007F`
- **插入键**: `Insert` 发送 `\u001B[2~`
- **删除键**: `Delete` 发送 `\u001B[3~`

#### 功能键 (F1-F12)
对每个功能键(F1-F12)都有对应的键盘序列映射，并支持修饰键组合：
- **无修饰键**: F1 发送 `\u001BOP`, F2 发送 `\u001BOQ`, 等等
- **Shift**: Shift+F1 发送 `\u001B[1;2P`, Shift+F2 发送 `\u001B[1;2Q`, 等等
- **Ctrl**: Ctrl+F1 发送 `\u001B[1;5P`, Ctrl+F2 发送 `\u001B[1;5Q`, 等等
- **Alt**: Alt+F1 发送 `\u001B[1;6P`, Alt+F2 发送 `\u001B[1;6Q`, 等等
- **Super**: Super+F1 发送 `\u001B[1;3P`, Super+F2 发送 `\u001B[1;3Q`, 等等

### 鼠标设置

- **打字时隐藏光标**: `false` (不隐藏)
- **鼠标绑定**:
  - 右键点击 (`Ctrl+右键`): 粘贴选中文本
  - 中键点击: 粘贴选中文本

### 滚动设置

- **历史行数**: 15000 行
- **滚动倍数**: 5

### 铃声效果

- **动画**: EaseOutExpo
- **颜色**: 白色 (`0xffffff`)
- **持续时间**: 0 (立即结束)

### 光标设置

- **vi 模式样式**: None (不显示特殊样式)

### 环境变量

- **TERM**: 设置为 `xterm-256color`，启用 256 色支持

### 通用设置

- **实时配置重载**: 启用 (`live_config_reload = true`) - 配置文件更改后无需重启即可生效

### 转义序列含义

配置文件中的 `\u001B[1` 这类转义序列的含义：

`\u001B` 是 Unicode 码点表示法，代表 ASCII 码 27，也就是 ESC（Escape）字符。在终端和计算机历史上，ESC 字符是一个特殊的控制字符，通常表示一个控制序列的开始。

ESC 字符（\u001B）的作用：

1. 控制序列引导符

ESC 字符是许多 ANSI 转义序列的开始标志。这些序列告诉终端执行特定操作，比如：
- 移动光标位置
- 改变文本颜色
- 清除屏幕或行
- 处理特殊按键输入

2. 在键盘绑定中的作用

在您的 alacritty 配置中，当按下某些组合键（如 Home、End、方向键等）时，终端需要向运行的应用程序发送特定的字符序列来表示这些键位动作。例如：
- `\u001B[C` 表示向右箭头键
- `\u001B[H` 表示 Home 键
- `\u001B[1;3H` 表示 Alt+Home 键

3. ANSI 标准兼容性

这些 ESC 开头的序列遵循 ANSI（美国国家标准协会）标准，确保了不同终端模拟器之间的兼容性。无论您使用哪种终端（Alacritty、iTerm2、GNOME Terminal 等），这些序列都应该被正确解释。

4. 在配置文件中的表示

在 TOML 配置文件中使用 \u001B（Unicode 转义序列）是为了确保正确编码，因为直接使用原始 ESC 字符可能难以编辑和阅读。
常见的 ESC 序列示例：

- `\u001B[A` - 上箭头键
- `\u001B[B` - 下箭头键
- `\u001B[C` - 右箭头键
- `\u001B[D` - 左箭头键
- `\u001B[2J` - 清除整个屏幕
- `\u001B[31m` - 设置文本为红色
- `\u001B[0m` - 重置所有格式

在您的配置文件中，ESC 字符主要用于键盘绑定部分，将按键操作转换为应用程序能够理解的特定字符序列，这对于确保在命令行应用（如 Vim、Emacs、Less、Man 等）中的正常导航至关重要。

<!-- </details> -->

## tmux 配置说明

这是一个偏向终端重度使用者的 tmux 配置，核心目标是：降低按键延迟、使用类 Vim 的操作方式、强化窗口/面板导航效率，并在状态栏中展示更实用的会话信息。

### 基础终端与输入行为

| 配置项 | 值 | 作用 |
| --- | --- | --- |
| XTerm 键支持 | `setw -g xterm-keys on` | 启用更完整的终端按键识别，便于识别带修饰键的组合键。 |
| ESC 延迟 | `set-option -g escape-time 50` | 将 ESC 等待时间缩短到 50ms，减少 Vim/Neovim 中按 ESC 时的迟滞感。 |
| 默认终端类型 | `set-option -g default-terminal "screen-256color"` | 使用 256 色终端能力，保证颜色显示兼容性。 |
| 更新环境变量 | `set -g update-environment "SSH_AUTH_SOCK"` | 每次创建/附加会话时更新 SSH agent socket，避免 tmux 内部拿到过期的 SSH_AUTH_SOCK。 |

### 前缀键与索引

| 配置项 | 值 | 作用 |
| --- | --- | --- |
| 取消默认前缀 | `unbind C-b` | 移除 tmux 默认的前缀键。 |
| 新前缀键 | `set-option -g prefix C-s` | 将前缀改为 `Ctrl+s`。 |
| 发送前缀 | `bind-key C-s send-prefix` | 允许在 tmux 内把前缀键继续发送给内部程序。 |
| 窗口编号起始值 | `set -g base-index 1` | 让窗口编号从 1 开始，更符合很多人的使用习惯。 |

### 类 Vim 导航与快速切换

| 配置项 | 值 | 作用 |
| --- | --- | --- |
| 复制/滚动模式按键风格 | `setw -g mode-keys vi` | 在 tmux 的复制模式中使用 Vim 风格按键。 |
| 前缀 + `h/j/k/l` | `select-pane -L/-D/-U/-R` | 使用 Vim 常见方向键在面板间切换。 |
| 无前缀 `Ctrl+Alt+h/j/k/l` | `bind -n ... select-pane ...` | 直接在面板间快速移动，无需先按前缀。 |
| 无前缀 `Ctrl+Alt+n/p` | `next-window` / `previous-window` | 直接切换到下一个/上一个窗口。 |

这部分说明该配置强调“尽量少按一次前缀”，把常见导航操作做成接近窗口管理器的即时切换体验。

### 鼠标与分屏

| 配置项 | 值 | 作用 |
| --- | --- | --- |
| 鼠标支持 | `set -g mouse on` | 启用鼠标选择、滚动、调整面板大小等能力。 |
| 切换鼠标关闭 | `bind m setw -g mouse off` | 通过前缀 + `m` 关闭鼠标支持。 |
| 切换鼠标开启 | `bind M setw -g mouse on` | 通过前缀 + `M` 重新开启鼠标支持。 |
| 快速横向分屏 | `bind-key / split-window -v -l 15` | 用前缀 + `/` 创建一个高度为 15 行的下方面板，适合临时日志、命令输出或辅助操作。 |

### 标题栏与状态栏

#### 终端标题栏

- `set -g set-titles on`：启用终端标题更新。
- `set -g set-titles-string '#(whoami)@#h :: [#S]'`：标题栏显示为“用户名@主机名 :: [会话名]”。

#### 状态栏行为

| 配置项 | 值 | 作用 |
| --- | --- | --- |
| 前景色 | `set -g status-fg black` | 设置状态栏前景色。 |
| 刷新间隔 | `set -g status-interval 5` | 每 5 秒刷新一次状态栏信息。 |
| 左侧最大长度 | `set -g status-left-length 90` | 允许左侧展示较长内容。 |
| 右侧最大长度 | `set -g status-right-length 60` | 控制右侧信息宽度。 |
| 对齐方式 | `set -g status-justify left` | 窗口列表左对齐。 |

#### 状态栏内容

| 区域 | 内容 | 说明 |
| --- | --- | --- |
| 左侧 | `[#S]`、pane 编号 `#D`、当前 pane TTY `#{pane_tty}` | 重点显示当前会话和 pane 信息。 |
| 右侧 | `#{user}@#H`、时间 `%R`、日期 `%b-%d`、星期 `%a` | 显示当前用户、主机、时间和日期。 |
| 窗口列表 | 普通窗口与当前窗口使用不同格式 | 当前窗口会加粗高亮，便于快速识别。 |

### 窗口命名

- `setw -g automatic-rename on`：启用自动窗口重命名。
- `set -g automatic-rename-format '#{pane_current_command}:#{b:pane_current_path}'`：将自动窗口名格式设置为“当前命令:当前路径的末级目录名”。例如可能显示为 `vim:dotfiles`、`ssh:project`、`fish:tmp`。
- `set-window-option -g window-status-format ...`：定义普通窗口在状态栏中的显示格式。
- `set-window-option -g window-status-current-format ...`：定义当前窗口在状态栏中的显示格式。

这意味着窗口名不再只是简单跟随当前程序名，而是会同时带上当前 pane 所在路径的最后一级目录，使状态栏里的窗口名更容易区分相同命令在不同目录下的会话；当前活动窗口也会在状态栏中更醒目。

### true color 支持说明

`set -ga terminal-overrides ",xterm-256color:Tc"` 的作用，是在 tmux 保持 `screen-256color` 作为默认终端类型的前提下，为匹配到 `xterm-256color` 的外层终端声明 true color 能力。

| 条件 | 是否需要 | 说明 |
| --- | --- | --- |
| 外层终端支持 24 位色 | 必需 | 例如 Alacritty、Ghostty、Kitty、WezTerm、iTerm2 通常都支持。 |
| 外层终端的 `TERM` 合理 | 必需 | 常见是 `xterm-256color`；这条 override 正是针对它生效。 |
| tmux 版本支持相关能力 | 必需 | 较新的 tmux 对 true color 支持更稳定。 |
| tmux 内部程序支持 true color | 必需 | 例如 Neovim、Vim（开启相关选项时）、bat、delta 等。 |
| SSH 远端环境配置正确 | 视情况 | 如果在远端 tmux 或多层 tmux 中使用，还要看远端 `TERM` 和 terminfo 是否匹配。 |

如果外层终端本身不支持 true color，或者内部程序只按 256 色输出，那么这项设置不会带来明显变化；如果终端、tmux 和应用三者都支持，就可以减少颜色渐变断层，让主题显示更准确。

### 值得注意的配置

| 配置项 | 当前状态 | 说明 |
| --- | --- | --- |
| `bind r source-file ~/.config/tmux/tmux.conf` | 已启用 | 原本用于快捷重载 tmux 配置。 |
| `default-shell` | 已注释 | 预留了设置默认 shell 的位置，但现在没有强制指定。 |
| `terminal-overrides` / true color | 已启用 | 通过 `set -ga terminal-overrides ",xterm-256color:Tc"` 告诉 tmux：当外层终端是 `xterm-256color` 时支持 true color（24 位色）。这通常适用于 Alacritty、Ghostty、iTerm2、Kitty、WezTerm 这类现代终端；同时终端本身、tmux 版本以及内部程序（如 Neovim、bat、less/支持颜色配置的工具）也要支持 true color，效果才会完整生效。 |
| 外网 IP 显示状态栏片段 | 已注释 | 曾考虑在状态栏显示公网 IP，但当前未启用。 |

### 整体风格总结

这个 tmux 配置主要做了几件事：

- 把 tmux 的操作方式调整得更接近 Vim 用户习惯。
- 强化面板/窗口切换效率，尽量减少前缀键带来的中断感。
- 启用鼠标支持，但保留快速开关。
- 让状态栏和标题栏更实用，优先显示当前会话、pane、TTY、用户、主机和时间信息。
- 兼顾 SSH 场景下的环境变量更新，减少 agent 转发失效问题。
