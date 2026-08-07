# dotfiles

这是我的个人 Mac 配置，由 nix-darwin 和 Home Manager 管理。新 Mac 克隆仓库后，运行一个命令即可复现同一套环境。

## 来源与参考

本项目搭建时参考了 Kun 的 [kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles)。
当前仓库不是 Fork，后续配置按我的设备和工作流独立维护。

## 使用与贡献

这个仓库公开供阅读、参考和自由派生，但不接受功能请求或 Pull Request，PR 会被自动关闭。
如果发现问题，请使用 Bug 报告模板提交 GitHub Issue。

## 包含内容

应用配置后会管理：

- 系统设置：深色模式、按键重复、Dock、Finder、触控板
- Homebrew 应用：cask 和命令行工具
- Nix 用户软件：Git、GitHub CLI、Delta、Neovim、eza、zoxide、tmux、ripgrep、fd、fzf、jq、Hack Nerd Font
- Shell：Zsh、别名、Starship 提示符
- 编辑器：使用 Nord 主题的 Neovim 配置
- 可选的 Pi 主题、本地扩展、通用界面设置、模型覆盖，以及已跟踪或固定版本的第三方 Pi 包

## 前置条件

- 默认面向 Apple Silicon Mac。
- Intel Mac 需要在 `configuration.nix` 中设置：

  ```nix
  nixpkgs.hostPlatform = "x86_64-darwin";
  ```

## 新 Mac 安装

在新 Mac 上克隆仓库：

```sh
git clone https://github.com/JokerQianwei/dotfiles.git
cd dotfiles
```

运行前先阅读下方的“改成你自己的配置”，按需修改用户名、主机标识和 CPU 架构，并确认 Homebrew 清理警告。

```sh
./bootstrap.sh
```

`bootstrap.sh` 依次执行：

1. 尚未安装时，安装 Determinate Nix。
2. 将当前仓库链接到 `~/.dotfiles`。首次构建前必须完成这一步，因为 `home.nix` 通过该路径引用配置文件。
3. 检查 `flake.nix` 中的 `user` 是否与当前 macOS 用户名一致；不一致时询问是否修改。
4. 首次运行 `darwin-rebuild switch`。脚本会从 nix-darwin 26.05 发布分支获取 `darwin-rebuild`，再应用仓库锁定的 flake 配置。

完成后即可使用下面的日常工作流。

### 只验证，不应用

安装 Nix 后，可以在不修改系统的情况下检查配置：

```sh
nix flake check --no-build
nix build .#darwinConfigurations.mac.system --dry-run
```

如果修改了主机标识，请将命令中的 `mac` 替换为对应名称。

## 日常使用

直接编辑配置，然后运行：

```sh
./rebuild.sh
```

不需要额外执行构建和复制。

## 改成你自己的配置

首次运行 `bootstrap.sh` 前检查：

- **用户名**：运行 `./bootstrap.sh` 让脚本检测并修改，或者直接修改 `flake.nix` 中唯一的 `user = "qianwei"`。`configuration.nix`、`home.nix` 和用户目录都由该变量生成。
- **主机标识**：默认是 `"mac"`，分别出现在 `flake.nix` 的 `darwinConfigurations."mac"`、`rebuild.sh:5` 的 `#mac`，以及 `bootstrap.sh` 的首次切换命令中。三处必须一致。
- **CPU 架构**：修改 `configuration.nix` 中的 `hostPlatform`。

### Git 身份

`home.nix` 包含我的公开 GitHub 用户名和 noreply 邮箱。提交代码前请替换成你自己的信息：

```nix
programs.git = {
  enable = true;
  settings.user = {
    name = "Your Name";
    email = "you@example.com";
  };
};
```

### Homebrew 清理警告

`configuration.nix` 设置了：

```nix
homebrew.onActivation.cleanup = "zap";
```

每次应用配置时，Homebrew 都会删除 `brews` 和 `casks` 中未声明的软件，并清理 cask 声明的关联文件。首次运行 `bootstrap.sh` 或 `rebuild.sh` 前，务必检查这两个清单并加入需要保留的软件。

### Herdr

`herdr` 已列在 `brews` 中。它是 Homebrew Core 的公开 formula，可用 `brew info herdr` 查询。无需使用时可从清单删除。

## 仓库结构

- `flake.nix`：入口文件，连接 nixpkgs、nix-darwin、Home Manager 和 nix-homebrew，并声明 `mac` 主机。
- `configuration.nix`：系统级配置，包括 macOS 默认设置和 Homebrew。
- `home.nix`：用户级配置，包括 Shell、软件、提示符和文件链接。
- `rebuild.sh`：首次安装后重新应用配置。
- `home/`：由 Home Manager 链接到用户目录的实际配置文件。

## 文件链接方式

`home/` 中保存的是配置源文件。`home.nix` 使用 `mkOutOfStoreSymlink`，将 `~/.config/nvim` 等路径直接链接到仓库，因此编辑仓库文件就是编辑实时配置。

修改链接文件通常无需重建；修改软件清单或系统默认设置后，需要运行 `./rebuild.sh`。

### 恢复 VS Code 扩展

VS Code 设置由 Home Manager 链接，扩展及固定版本记录在 `home/.config/vscode/extensions.txt`。安装清单中的扩展：

```sh
install-vscode-extensions
```

### 恢复应用偏好

Herdr 和 Snipaste 的配置由 Home Manager 分别链接到 `config.toml` 和 `config.ini`，日志、会话及截图历史仍留在本机。

HapiGo 与 Bob 的完整偏好中混有账号、API Key、历史和插件数据，因此仓库只保存快捷键及普通界面行为。恢复这些安全设置：

```sh
restore-app-preferences
```

## 可选的 Pi 配置

Pi 是可选 CLI，本仓库不内置它。请按 [Pi 官方说明](https://pi.dev)安装，例如：

```sh
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
```

Home Manager 管理仓库编写的 `~/.pi/agent/extensions` 和 `~/.pi/agent/skills`，并分别链接已跟踪的 `packages/pi-herdr-btw`、`models.json`、`settings.json` 和 `pi-herdr-btw.json`。

扩展目录包括：

- edit 路由器
- tcodex 快速模式适配器
- 从 `safe2` 同步的空上游错误重试补丁
- 终端标题扩展

重试补丁使用 `settings.json` 中有上限的重试策略。Skills 目录保存 Agent-Native Hardening 和 Anti-AI Copy 的标准 Agent Skills 副本及其参考资料和 MIT 许可证，不再从 npm 加载。修改 Pi 资源后运行 `/reload`。Pi 只配置了固定版本的 Nord 主题包。

### Pi 第三方包

全局 `settings.json` 声明了以下本地或固定版本来源：

- `npm:pi-web-access@0.14.0`：Pi 网络访问工具。
- `./packages/pi-herdr-btw`：基于 `pi-herdr-btw@0.3.0` 的 `safe2` 适配版，增加 `--down` 分屏覆盖和 Herdr Shell 就绪重试；非敏感默认值保存在 `pi-herdr-btw.json`。
- `npm:@maddeye/pi-nord@1.0.0`：唯一配置的 Pi 主题。
- `npm:@ryan_nookpi/pi-extension-codex-fast-mode@0.2.6`：`ryan_nookpi` 发布的固定 npm 版本。
- `git:github.com/algal/pi-openai-server-compaction@c6d593087709e9481223dc6c6c2269b371b5e055`：实验性 OpenAI 服务端压缩扩展的固定公开提交。

npm 版本和 Git 提交均为不可变固定值，不会随 Pi 包更新自动移动。本地 BTW 包直接由仓库管理；更新它或第三方固定版本前，需要先审查来源，再显式修改仓库或版本。

在 Pi 0.82.0 上，全局设置会在启动时自动安装缺失的固定包，无需额外执行一次性安装命令。Pi 下载的 npm 和 Git 包保存在未受管理的 `~/.pi/agent/npm` 和 `~/.pi/agent/git` 中，不进入 Home Manager 或 Git。

这些包拥有当前用户的完整权限，必须像其他可执行代码一样审查和信任。压缩扩展是实验性的，会将相关 OpenAI 压缩和连续性数据发送给 OpenAI。上游声明的旧 peer 范围是 `>=0.80.9 <0.81.0`；当前固定提交只在本地验证过可加载并能在 Pi 0.82.0 上执行远程压缩，这不保证其他 Pi 版本或提交也可用。

Home Manager 不管理整个 `~/.pi/agent`，也不管理 Pi 认证、会话、信任决定、缓存、npm/Git 包目录或其他运行时状态。模型覆盖文件不包含凭据或端点，不选择默认模型，只在自行完成 Pi 认证后生效。

## 其他说明

首次启动 `nvim` 时，配置会从 GitHub 克隆 [lazy.nvim](https://github.com/folke/lazy.nvim) 及插件，需要联网一次，之后可离线使用。Neovim 使用 Nord 主题和透明背景。

### 剪贴板图片快捷键

本机快捷键 App 会调用仓库中的 `home/bin/pi-paste-image-safe2`，将剪贴板图片粘贴到远程 Pi 会话：

1. `pngpaste` 将剪贴板图片写入临时 PNG。
2. SSH 将图片上传到私有远程目录。
3. 返回的远程路径写回本机剪贴板。
4. Ghostty 获得焦点，并将路径粘贴到当前会话。

脚本中只保存 SSH 别名 `safe2`，不包含真实主机名、IP、用户名、凭据或 SSH 配置；别名的实际连接信息仍只保存在本机。仓库同时声明公开依赖 `pngpaste`。负责全局快捷键的 App Bundle、运行日志和辅助功能权限不进入仓库。

## 许可证

本仓库采用 MIT No Attribution 许可证，详见 `LICENSE`。
