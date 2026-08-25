# Tinted8 Nord 的 Fish 语法与补全配色。
# SSH 不会传递 COLORTERM；两端都由支持真彩色的 Kitty 渲染。
set -gx COLORTERM truecolor

set -g fish_color_normal e5e9f0
set -g fish_color_command 88c0d0
set -g fish_color_keyword 81a1c1
set -g fish_color_quote a3be8c
set -g fish_color_redirection b48ead --bold
set -g fish_color_end 81a1c1
set -g fish_color_error bf616a
set -g fish_color_param d8dee9
set -g fish_color_comment 616e88 --italics
set -g fish_color_selection d8dee9 --background=434c5e --bold
set -g fish_color_operator 81a1c1
set -g fish_color_escape ebcb8b
set -g fish_color_autosuggestion 616e88
set -g fish_color_cwd 5e81ac
set -g fish_color_cwd_root bf616a
set -g fish_color_user a3be8c
set -g fish_color_host a3be8c
set -g fish_color_host_remote ebcb8b
set -g fish_color_status bf616a
set -g fish_color_valid_path --underline

set -g fish_pager_color_completion e5e9f0
set -g fish_pager_color_description ebcb8b --italics
set -g fish_pager_color_prefix --bold --underline
set -g fish_pager_color_progress 2e3440 --background=d08770 --bold
set -g fish_pager_color_selected_background --background=434c5e
