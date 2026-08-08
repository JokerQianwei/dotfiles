{ config, pkgs, user, ... }:

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
  home.sessionVariables.EDITOR = "nvim";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
    '';
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

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
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
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
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
  home.file.".pi/agent/REALTIME-SYSTEM-PROMPT.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/REALTIME-SYSTEM-PROMPT.md";
  home.file.".pi/agent/openai-fast.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/openai-fast.json";
  home.file.".pi/agent/pi-explore-subagents.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/pi-explore-subagents.json";
  home.file.".pi/agent/pi-smart-btw.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/pi-smart-btw.json";
  home.file.".pi/agent/pi-subagent-review.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/pi-subagent-review.json";
  home.file.".pi/agent/semantic-grep.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/semantic-grep.json";
  home.file.".pi/agent/pi-herdr-btw.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/pi-herdr-btw.json";
  home.file.".pi/agent/packages/pi-herdr-btw".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/packages/pi-herdr-btw";

}
