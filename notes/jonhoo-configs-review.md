# jonhoo/configs 配置审阅

审阅对象：[jonhoo/configs](https://github.com/jonhoo/configs)。重点关注其 Neovim、终端工作流和 Nix 配置。

## 配置模型

仓库按用途分为 `editor`、`shell`、`server`、`gui`、`mail`、`bins` 和 `agentic` 等 GNU Stow group。README 明确承认 Stow 存在不足，但目录仍可供其他部署工具使用。

同时，仓库正在使用 NixOS 和 Home Manager：Nix 模块通过 `builtins.readFile` 复用原来的 Fish、tmux 和 Neovim 配置。因此当前实际模型是：

- Stow 目录保存原始配置；
- Nix 管理机器、软件包与系统服务；
- Home Manager 把原始配置接入用户环境。

来源：[README](https://github.com/jonhoo/configs/blob/master/README.md)、[Nix flake](https://github.com/jonhoo/configs/blob/master/nix/flake.nix)、[Home Manager base](https://github.com/jonhoo/configs/blob/master/nix/modules/home/base.nix)

## Neovim 是主编辑器

Nix 配置将 Neovim 同时设为默认编辑器，并为 `vi`、`vim` 提供别名。`editor/.config/nvim/init.lua` 是约 700 行的主配置；`server/.config/nvim/init.vim` 则是远端环境使用的精简版本。

主配置的特点：

- 单文件、按 preferences、hotkeys、autocommands、plugins 等章节顺序组织；
- 相对行号、持久 undo、默认不折叠、不换行；
- 使用 8 字符硬 tab，Rust 单独采用 100 字符行宽；
- `Ctrl-J` 和 `Ctrl-K` 在几乎所有 mode 中充当 Escape；
- 禁用方向键，`H`/`L` 跳到行首和行尾；
- 搜索结果自动居中；
- 使用 `wl-copy` 和 `wl-paste` 接入 Wayland 剪贴板。

这是一套高度个人化的操作模型，不追求 Vim 默认习惯，也不追求面向他人的可配置性。

来源：[init.lua](https://github.com/jonhoo/configs/blob/master/editor/.config/nvim/init.lua)、[server init.vim](https://github.com/jonhoo/configs/blob/master/server/.config/nvim/init.vim)、[Nix base](https://github.com/jonhoo/configs/blob/master/nix/modules/base.nix)

## 插件与语言支持

插件数量相对克制，主要用于：

- `lazy.nvim`：插件管理；
- `fzf-lua`：文件与 buffer 查找；
- `nvim-lspconfig`：LSP；
- `nvim-cmp`：补全；
- `lsp_signature.nvim`：函数签名；
- `leap.nvim`：快速跳转；
- `vim-matchup`：改进 `%`；
- `lightline.vim`：状态栏；
- VimTeX 和少量语言语法插件。

Rust Analyzer 会启用全部 Cargo features，并在保存检查时使用 Clippy。其他按可执行文件是否存在启用的 server 包括 Bash、TexLab、Ruff 和 nil。

补全没有引入专门的 snippet engine，而是直接调用 Neovim 内置的 `vim.snippet.expand`。这符合“已有能力足够时不再增加依赖”的原则。

来源：[init.lua](https://github.com/jonhoo/configs/blob/master/editor/.config/nvim/init.lua)

## 最有价值的编辑器设计

### 邻近文件排序

`Ctrl-P` 使用 `fd` 生成文件列表，再通过 Jon 自己的
[`proximity-sort`](https://github.com/jonhoo/proximity-sort) 根据文件与当前文件的目录距离排序，最后交给 `fzf-lua`。相较于只按名称匹配，这更贴近大型仓库中“相关文件通常位于附近”的实际情况。

这是最值得我们观察的功能。是否采用应先验证当前 `fff.nvim` 在大型项目中的排序是否构成真实问题。

### 主动关闭干扰信息

配置关闭折叠、semantic tokens 和 inlay hints，也隐藏 fzf 的文件图标和预览。它表达了清晰偏好：保持文本位置稳定，只显示作者主动需要的信息。

值得学习的是为 UI 信息设定明确标准，而不是复制具体开关。

来源：[init.lua](https://github.com/jonhoo/configs/blob/master/editor/.config/nvim/init.lua)

## Nix 配置的可借鉴之处

Nix 配置按两个维度拆分：

- `hosts/xos`、`hosts/xfw`：磁盘、硬件、内核和键盘等机器差异；
- `modules/base`、`dev`、`personal`、`laptop`：机器角色和能力。

`base` 只提供所有机器都需要的 shell、Neovim、tmux 和基础命令；`dev` 增加编译器、性能分析及 Rust 工具；`personal` 再增加 GUI、邮件和个人应用。

这比按软件逐个拆分模块更贴近实际部署决策。我们的仓库目前只有一台 Mac，不需要立即采用；出现第二台机器或远端开发主机后，可以参考这种“主机差异 + 角色能力”的结构。

来源：[flake.nix](https://github.com/jonhoo/configs/blob/master/nix/flake.nix)、[base.nix](https://github.com/jonhoo/configs/blob/master/nix/modules/base.nix)、[dev.nix](https://github.com/jonhoo/configs/blob/master/nix/modules/dev.nix)、[xos](https://github.com/jonhoo/configs/blob/master/nix/hosts/xos/default.nix)、[xfw](https://github.com/jonhoo/configs/blob/master/nix/hosts/xfw/default.nix)

## Shell 与 tmux

Fish 在交互式终端中自动进入 tmux。tmux 使用：

- `Ctrl-A` 前缀；
- vi copy mode 和 `hjkl` pane 导航；
- 100,000 行历史；
- X11 `xclip` 剪贴板；
- 极简状态栏；
- 作者自己的 `tmux-jump`。

Fish 配置还把简短输入主要实现为 abbreviation，而不是 alias；这样展开后的真实命令仍能显示并进入历史记录。其大量函数直接封装 AWS、OpenStack、reMarkable 和服务器状态等个人工作流。

我们的 tmux 已有相近的 vi 导航和深历史，不需要改键位。Fish abbreviation 的思路值得在新增交互式缩写时参考，但现有 Zsh alias 没有构成需要迁移的问题。

来源：[tmux.conf](https://github.com/jonhoo/configs/blob/master/shell/.tmux.conf)、[Fish config](https://github.com/jonhoo/configs/blob/master/shell/.config/fish/config.fish)

## 不宜照搬

- Neovim 单文件已超过 700 行，并保留大量注释代码；我们的分文件结构更易遍历。
- Stow 与 Nix 并存造成两种部署入口；我们的 Home Manager 单一入口更清晰。
- Fish 配置包含旧基础设施地址、公开身份和大量机器特有逻辑，不适合作为共享 shell 基础配置。
- tmux 直接引用 `~/dev/others/tmux-jump`，依赖没有在同一配置中声明。
- 两台 NixOS 主机均关闭防火墙，不应复制。
- `agentic/` 为 AGENTS、Claude 和 Gemini 分别维护大段相似规则，存在漂移风险；我们共用 `home/AGENTS.md` 的方式更简单。
- LSP attach 回调声明“只为 Rust 保存时格式化”，实际条件是任意 LSP client 支持 formatting；相关代码还引用了未在局部定义的 `bufnr`。借鉴配置前应先验证其行为，不应原样复制。

来源：[init.lua](https://github.com/jonhoo/configs/blob/master/editor/.config/nvim/init.lua)、[tmux.conf](https://github.com/jonhoo/configs/blob/master/shell/.tmux.conf)、[agentic](https://github.com/jonhoo/configs/tree/master/agentic)

## 对我们的建议

1. 观察 `proximity-sort` 是否能改善大型仓库中的文件查找；没有实际问题就不改。
2. 保留当前 Neovim 分文件结构和 Home Manager 单一部署路径。
3. 有第二类主机后，再采用 `base`、`dev`、`personal` 角色模块。
4. 新增 shell 自动化时，继续围绕真实个人任务编写小函数或脚本。
5. 不复制他的按键、8 字符 tab 或关闭语义高亮等个人偏好。

总体而言，Jon 的配置体现了资深工程师常见的特点：工具不追求流行默认值，而是围绕多年形成的具体工作习惯调整。最值得学习的是邻近文件排序和按机器角色组织 Nix，而不是复制整套 Neovim 配置。
