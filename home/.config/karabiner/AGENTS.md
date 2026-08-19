# Karabiner 配置

- 修改 `karabiner.json` 后运行 `karabiner_cli --lint-complex-modifications home/.config/karabiner/karabiner.json`。
- Karabiner 不会感知符号链接目标的修改；先 `touch -h ~/.config/karabiner/karabiner.json`，再依次重启 `org.pqrs.service.agent.karabiner_console_user_server` 和 `org.pqrs.service.agent.Karabiner-Core-Service-rev2`。
- 不要用 `karabiner_cli --select-profile` 重新加载，它会将 `~/.config/karabiner/karabiner.json` 改写为普通文件。
- Caps 只用于按住组合层，单按不执行操作。
- 右 Command 直接发送系统的 Control-Space 输入源快捷键，不再作为 Command 修饰键。
