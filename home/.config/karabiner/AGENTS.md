# Karabiner 配置

- 修改 `karabiner.json` 后运行 `karabiner_cli --lint-complex-modifications home/.config/karabiner/karabiner.json`。
- Karabiner 不会感知符号链接目标的修改；用 `launchctl kickstart -k "gui/$(id -u)/org.pqrs.service.agent.Karabiner-Core-Service-rev2"` 重新加载。
- 不要用 `karabiner_cli --select-profile` 重新加载，它会将 `~/.config/karabiner/karabiner.json` 改写为普通文件。
- Caps 同时承担单按切换和按住组合层；在 Caps 松开前发生其他输入事件时，Karabiner 会取消 `to_if_alone`。
