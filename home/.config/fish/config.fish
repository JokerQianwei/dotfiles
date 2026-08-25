# 用户命令与 Homebrew 命令
fish_add_path $HOME/.local/bin /opt/homebrew/bin /opt/homebrew/sbin

# 保留中文地区格式，只将命令行诊断信息切换为英文。
set -gx LC_MESSAGES en_US.UTF-8

# 关闭交互式 Shell 的欢迎语
set -g fish_greeting

alias vi nvim

# 使用经典 Unix 风格的单行提示符。
function fish_prompt
    set_color --bold '#a3be8c'
    printf '%s@%s' $USER (prompt_hostname)
    set_color normal
    printf ':'
    set_color --bold '#81a1c1'
    printf '%s' (prompt_pwd --dir-length=0)
    set_color normal
    if fish_is_root_user
        printf '# '
    else
        printf '$ '
    end
end

function fish_right_prompt
end

if status is-interactive
    # 使用 fd 提供候选，并为文件和目录选择器显示预览。
    set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
    set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
    set -gx FZF_CTRL_T_OPTS "--preview 'head -200 {} 2>/dev/null'"
    set -gx FZF_ALT_C_COMMAND "fd --type d --hidden --follow --exclude .git"
    set -gx FZF_ALT_C_OPTS "--preview 'fd --max-depth 2 --hidden . {} 2>/dev/null | head -200'"
    if fzf --help | string match -q '*--fish*'
        fzf --fish | source
    else
        source /usr/share/doc/fzf/examples/key-bindings.fish
        fzf_key_bindings
    end
    bind --erase alt-c
    bind --erase -M insert alt-c
    bind alt-f fzf-cd-widget
    bind -M insert alt-f fzf-cd-widget
end
