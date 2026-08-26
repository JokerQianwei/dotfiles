# tmux 远程图片粘贴方案

## 结论

tmux 本身没有通用的“把本机图片剪贴板传到远端”能力。它的原生剪贴板集成以文本和 OSC 52 为中心；图片通常需要先上传为远端文件，再把文件路径粘贴进 pane。

当前配置已经实现了这一流程：

- `home/bin/pi-paste-image-safe2` 使用 `pngpaste` 读取 macOS 剪贴板。
- 脚本通过 SSH 把 PNG 写入 safe2 的 `~/.cp-images/`。
- 脚本把远端绝对路径粘贴回当前 Kitty 窗口。
- Karabiner 将 Kitty 中的 `Cmd+Option+V` 和 `Cmd+Shift+V` 绑定到该脚本。

本机日志显示该路径已多次成功上传。它不依赖 tmux，因此在 SSH 里的 tmux pane 中也能工作。

## 可选项目

### PasteHop

[PasteHop](https://github.com/shantanugoel/pastehop) 与当前需求最接近：从本机剪贴板读取图片，通过 SSH/SCP 上传，并将远端路径注入 Kitty 或 WezTerm。远端不需要 daemon，也支持显式指定 SSH host。

相比当前脚本，它增加了 host 信任、上传清理、多个终端和多个目标支持。对于固定的 `safe2` 单主机场景，当前约 50 行脚本更简单。

### pi-ssh-image-clipboard

[pi-ssh-image-clipboard](https://github.com/pasky/pi-ssh-image-clipboard) 是 Pi extension。它通过 SSH `RemoteForward` 从远端 Pi 读取当前客户端的 macOS 图片剪贴板，保存为远端临时文件并插入路径。它会根据 tmux `client_activity` 选择最近操作的客户端，适合多个客户端连接同一个远端 tmux session。

它只解决 Pi 中的 `Ctrl+V`，并需要 launchd socket、SSH reverse forward 和远端登录 hook。当前脚本适用于 Pi 以外的命令行程序，配置也更少。

### clipfan

[clipfan](https://github.com/prime-radiant-inc/clipfan) 在所有 Mac/Linux 主机上运行 daemon，通过认证 SSH 流同步剪贴板。图片会保存到远端状态目录，绝对路径会写入文本剪贴板和所有 tmux paste buffer，因此可用 `prefix-]` 粘贴。

它适合多主机、双向同步和剪贴板历史，但对单个 safe2 明显偏重。

### tmux-paste-image

[tmux-paste-image](https://github.com/jkhas8/tmux-paste-image) 是 TPM 插件，但只从 tmux 所在主机的 X11/Wayland 剪贴板读取图片，依赖 `xclip` 或 `wl-paste`。它不能直接读取 SSH 客户端 Mac 的剪贴板，因此不适合 headless safe2。

## Kitty 原生协议

Kitty 的 [`clipboard` kitten](https://sw.kovidgoyal.net/kitty/kittens/clipboard/) 支持通过终端协议读取任意 MIME 数据，包括将图片剪贴板写成 PNG：

```sh
kitten clipboard -g picture.png
```

该协议可以跨 SSH，但 safe2 当前没有 `kitten` 命令；在 tmux 中还依赖 passthrough、请求应答路由和剪贴板读取授权。当前 Kitty 已允许询问式读取，远端 tmux 也已开启 `allow-passthrough`，但引入远端 kitten 仍不如现有 SSH 上传脚本直接。

## 建议

保留现有实现。只有在需求扩展时再替换：

- 需要自动识别多个 SSH 目标或上传清理：采用 PasteHop。
- 只关心 Pi，并需要共享 tmux session 的多客户端识别：采用 pi-ssh-image-clipboard。
- 需要多主机双向剪贴板和历史：采用 clipfan。

## 来源

- [tmux Clipboard wiki](https://github.com/tmux/tmux/wiki/Clipboard)
- [Kitty clipboard kitten](https://sw.kovidgoyal.net/kitty/kittens/clipboard/)
- [PasteHop](https://github.com/shantanugoel/pastehop)
- [pi-ssh-image-clipboard](https://github.com/pasky/pi-ssh-image-clipboard)
- [clipfan](https://github.com/prime-radiant-inc/clipfan)
- [tmux-paste-image](https://github.com/jkhas8/tmux-paste-image)
