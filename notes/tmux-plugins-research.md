# tmux 插件建议

## 针对当前配置的结论

当前配置已经直接实现了 `tmux-sensible`、`tmux-yank`、`tmux-pain-control` 和常见 session picker 的主要能力。为了保持配置小巧，不建议仅为这些功能引入 TPM。

值得考虑的插件按优先级排列如下：

1. [`tmux-resurrect`](https://github.com/tmux-plugins/tmux-resurrect)：保存并恢复 session、window、pane 布局、工作目录和部分运行程序。适合 Mac 或 safe2 重启后的恢复。
2. [`tmux-fingers`](https://github.com/Morantron/tmux-fingers)：为屏幕中的路径、散列、URL 等文本显示 Vimium 风格提示，减少进入 copy mode 后的移动和选择。
3. [`tmux-open`](https://github.com/tmux-plugins/tmux-open)：从 copy mode 打开 URL、文件或搜索选中文本。
4. [`tmux-continuum`](https://github.com/tmux-plugins/tmux-continuum)：在 `tmux-resurrect` 之上定期自动保存并可自动恢复。只在确实需要无人值守恢复时采用；它会接触状态栏配置，需确认不影响现有 Nord 状态栏。

不建议当前安装：

- [`tmux-sensible`](https://github.com/tmux-plugins/tmux-sensible)：现有配置已经设置 `escape-time`、`history-limit`、索引、鼠标和窗口行为。
- [`tmux-yank`](https://github.com/tmux-plugins/tmux-yank)：macOS 已使用 `pbcopy`，safe2 已使用 OSC 52 辅助脚本。
- [`tmux-pain-control`](https://github.com/tmux-plugins/tmux-pain-control)：现有 `h/j/k/l` 和 `H/J/K/L` pane 键位已覆盖。
- [`tmux-sessionx`](https://github.com/omerxx/tmux-sessionx)、[`sesh`](https://github.com/joshmedeski/sesh)：现有 `prefix+f` 与 `tmux-sessionizer` 已覆盖当前项目发现和 session 切换需求。
- 状态栏、电量和 CPU 插件：现有 Nord 状态栏刻意保持简洁。

## 最小采用方案

如果只需要重启恢复，安装 TPM 与 `tmux-resurrect` 两项即可；不要预先加入 Continuum。若从未遇到 session 因主机重启丢失的问题，则维持零插件是更简单的选择。

## 来源

- [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [tmux-plugins 官方列表](https://github.com/tmux-plugins/list)
- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
- [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum)
- [tmux-fingers](https://github.com/Morantron/tmux-fingers)
- [tmux-open](https://github.com/tmux-plugins/tmux-open)
