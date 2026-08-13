{ config, lib, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    gh
    neovim
    eza
    tmux
    ripgrep
    fd
    jq
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
  ];
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "code --wait";
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/.1password/agent.sock";
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    history = {
      append = true;
      size = 100000;
      save = 100000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
    setOptions = [
      "HIST_REDUCE_BLANKS"
      "INTERACTIVE_COMMENTS"
    ];
    profileExtra = ''
      if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
      typeset -U path PATH
      path=("$HOME/.local/bin" "$HOME/go/bin" $path)
    '';
    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        if command -v brew >/dev/null 2>&1; then
          fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
        fi
      '')
      (lib.mkOrder 1000 ''
        bindkey '^f' autosuggest-accept
      '')
    ];
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      ls = "eza --icons=auto --group-directories-first";
      ll = "eza -la --git --icons=auto --group-directories-first";
      la = "eza -la --icons=auto --group-directories-first";
      lt = "eza --tree --level=2 --icons=auto --group-directories-first";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    globalConfig.tools = {
      go = "1.26.3";
      node = "24.16.0";
      "npm:mcp-call-cli" = "0.2.1";
      python = "3.13.13";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetOptions = [
      "--preview 'head -200 {} 2>/dev/null'"
    ];
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions = [
      "--preview 'eza --tree --level=2 --icons=auto --color=always {} 2>/dev/null | head -200'"
    ];
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    ignores = [
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "*.swp"
      "*.swo"
      "*~"
      ".env"
      ".env.*"
      "!.env.example"
      "!.env.sample"
      "!.env.1password.example"
    ];
    settings = {
      user = {
        name = "JokerQianwei";
        email = "72345663+JokerQianwei@users.noreply.github.com";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      fetch.prune = true;
      merge.conflictStyle = "zdiff3";
      diff.colorMoved = "zebra";
      alias.df = "!git -c delta.side-by-side=true diff";
      core.excludesFile = "~/.config/git/ignore";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      syntax-theme = "Nord";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      palette = "nord";
      palettes.nord = {
        nord0 = "#2E3440";
        nord1 = "#3B4252";
        nord2 = "#434C5E";
        nord3 = "#4C566A";
        nord4 = "#D8DEE9";
        nord5 = "#E5E9F0";
        nord6 = "#ECEFF4";
        nord7 = "#8FBCBB";
        nord8 = "#88C0D0";
        nord9 = "#81A1C1";
        nord10 = "#5E81AC";
        nord11 = "#BF616A";
        nord12 = "#D08770";
        nord13 = "#EBCB8B";
        nord14 = "#A3BE8C";
        nord15 = "#B48EAD";
      };
      directory = {
        truncate_to_repo = false;
        truncation_length = 0;
        style = "bold nord8";
      };
      git_branch.style = "bold nord9";
      git_status.style = "nord13";
      character = {
        success_symbol = "[❯](nord14)";
        error_symbol = "[❯](nord11)";
      };
      cmd_duration = {
        format = "[$duration]($style) ";
        style = "nord3";
      };
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr/config.toml";
  home.file.".config/ghostty/config".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/ghostty/config";
  home.file.".config/karabiner/karabiner.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/karabiner/karabiner.json";
  home.file."Library/Application Support/Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/vscode/settings.json";
  home.file."Library/Application Support/Sublime Text/Packages/User/Preferences.sublime-settings".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/Library/Application Support/Sublime Text/Packages/User/Preferences.sublime-settings";
  home.file."Library/Application Support/Sublime Text/Packages/User/Package Control.sublime-settings".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/Library/Application Support/Sublime Text/Packages/User/Package Control.sublime-settings";
  home.file.".config/gh/config.yml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/gh/config.yml";
  home.file.".snipaste/config.ini".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.snipaste/config.ini";
  home.file.".tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.tmux.conf";
  home.file."bin/pi-paste-image-safe2".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/bin/pi-paste-image-safe2";
  home.file."bin/install-vscode-extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/bin/install-vscode-extensions";
  home.file."bin/restore-app-preferences".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/bin/restore-app-preferences";
  home.file."bin/export-logi-options-plus".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/bin/export-logi-options-plus";
  # Pi、Codex 和 Claude 共用同一份全局 Agent 说明。
  home.file.".pi/agent/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".agents/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills";
  # Pi 的凭据和运行状态留在本机，只链接编写或审查过的资源。
  home.file.".pi/agent/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions";
  home.file.".pi/agent/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/skills";
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/settings.json";
  home.file.".pi/agent/openai-fast.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/openai-fast.json";
  home.file.".pi/agent/pi-herdr-btw.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/pi-herdr-btw.json";
  home.file.".pi/agent/packages/pi-herdr-btw".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/packages/pi-herdr-btw";

}
