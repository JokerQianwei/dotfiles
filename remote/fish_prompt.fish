# 使用经典 Unix 风格的单行提示符。
set -g fish_greeting

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
