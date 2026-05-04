# CLAUDE.md

本文件为 Claude Code（claude.ai/code）在此仓库中工作时提供指导。

## 仓库范围

这个仓库是个人 dotfiles 仓库，不是带有构建、测试或 lint 流水线的应用项目。这里的工作通常是编辑 `.config/` 下各个工具的配置文件，以及 `dotvim/` 下的 Vim 配置。

## 常用命令

| 任务 | 命令 |
| --- | --- |
| 查看仓库状态 | `git status --short` |
| 查看变更内容 | `git diff` |
| 在运行中的 tmux 会话里重新加载配置 | `tmux source-file ~/.config/tmux/tmux.conf` |
| 检查 tmux 配置是否可解析 | `tmux -f ~/.config/tmux/tmux.conf start-server \; show-options -g > /dev/null` |
| 检查 Alacritty 配置是否可解析 | `alacritty --config-file ~/.config/alacritty/alacritty.toml -e true` |
| 查看 Yazi 包和插件配置 | `yazi --debug` |
| 同步 package.toml 中声明的 Yazi 插件 | `ya pkg install` |
| 使用本地配置启动 PHP-FPM | `php-fpm --fpm-config ~/.config/php/php-fpm.conf --nodaemonize` |
| 校验 fontconfig XML | `xmllint --noout ~/.config/fontconfig/fonts.conf` |
| 检查 clangd YAML 配置 | `python -c "import yaml, pathlib; yaml.safe_load(pathlib.Path('~/.config/clangd/config.yaml').expanduser().read_text())"` |

## 架构

### 布局

- `.config/` 包含大多数正在使用的配置，按工具分组。
- `dotvim/` 包含 Vim/Neovim 相关配置，当前仍与 `.config` 分开存放。
- 这个仓库目前没有统一的引导脚本，也没有 Nix/Home Manager 入口；通常是直接编辑目标配置文件来应用修改。

### Yazi 是最接近代码工程的区域

Yazi 是这个仓库里内部结构最丰富的部分，也是最接近“组合式系统”的区域：

- `.config/yazi/yazi.toml` 定义管理器行为、打开规则以及插件/预览器的接线方式。
- `.config/yazi/keymap.toml` 添加自定义按键绑定，尤其是插件入口。
- `.config/yazi/init.lua` 配置运行时插件行为，以及状态栏/主题组合。
- `.config/yazi/package.toml` 固定外部插件和 flavor 依赖版本。
- `.config/yazi/plugins/*` 和 `.config/yazi/flavors/*` 保存 `init.lua` 与 `keymap.toml` 所依赖的插件/主题代码。

重要关联：

- `yazi.toml` 注册了插件钩子，例如 `git` fetcher，以及 `preview-git` / `ouch` 预览器。
- `init.lua` 调用了 `require('git'):setup(...)` 和 `require('yatline'):setup(...)`，因此修改插件名或依赖版本固定值时，必须与 `package.toml` 和已纳入仓库的插件目录保持一致。
- `keymap.toml` 与已安装插件紧密耦合，例如 `fast-enter`、`ouch` 和 `sudo`。

### 终端/编辑器栈的假设

多个配置默认采用以终端为中心的工作流，并假设各工具之间的键盘行为保持一致：

- `.config/alacritty/alacritty.toml` 定义终端外观以及大量自定义按键映射。
- `.config/tmux/tmux.conf` 使用类似 Vim 的导航模型，将 tmux 前缀键改为 `Ctrl-s`，并启用鼠标支持。
- `dotvim/coc-settings.json` 配置 C/C++、CMake 和 Vim script 的语言服务器与补全行为。
- `.config/clangd/config.yaml` 为 C++ 工具链提供后备编译参数。

修改按键绑定或转义序列时，要同时检查 Alacritty 和 tmux，确保两者保持兼容。

### 其他配置大多是独立的

`.config/` 下其余大多数目录都属于单工具配置，跨文件耦合较少：

- `fontconfig` 自定义合成斜体/粗体行为以及字体发现。
- `php/php-fpm.conf` 是一个本地 PHP-FPM socket/pool 小型配置。
- `ranger`、`joshuto`、`mpv`、`pip`、`ghostty`、`bat`、`eza` 和 `git` 都是常规的单工具配置目录。

## 本仓库的工作指导

- 优先做最小化、面向具体工具的修改，不要无故引入新的结构。
- 尽量使用该配置所属工具本身来验证修改，而不是编造通用验证步骤。
- 修改 Yazi 相关内容前，要一起检查 `yazi.toml`、`keymap.toml`、`init.lua` 和 `package.toml`，再调整插件相关行为。
- 遇到终端输入问题时，要沿着 Alacritty、tmux 和 Vim 配置一起排查，不要把单个文件孤立看待。
