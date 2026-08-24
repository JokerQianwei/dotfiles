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
    tmux
    ripgrep
    fd
    jq
    # 终端使用的 Nerd Fonts。
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
      vi = "nvim";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
    };
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
      "--preview 'fd --max-depth 2 --hidden . {} 2>/dev/null | head -200'"
    ];
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
      core.excludesFile = "~/.config/git/ignore";
    };
  };

  home.activation.setDefaultTextEditor = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # 为常见文本格式显式设置关联，避免已有的编辑器关联继续优先。
    for type in \
      public.plain-text \
      net.daringfireball.markdown \
      public.json \
      public.xml \
      public.yaml \
      public.toml \
      public.comma-separated-values-text \
      public.tab-separated-values-text \
      com.apple.log \
      txt md markdown json xml yaml yml toml csv tsv log conf ini
    do
      for role in viewer editor all
      do
        /opt/homebrew/bin/duti -s com.coteditor.CotEditor "$type" "$role"
      done
    done
  '';

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr/config.toml";
  home.file.".config/fish/config.fish".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/fish/config.fish";
  home.file.".config/kitty/kitty.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/kitty/kitty.conf";
  home.file.".config/karabiner/karabiner.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/karabiner/karabiner.json";
  home.file.".hammerspoon/init.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.hammerspoon/init.lua";
  home.file."Library/Application Support/Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/vscode/settings.json";
  home.file.".config/gh/config.yml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/gh/config.yml";
  home.file.".snipaste/config.ini".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.snipaste/config.ini";
  home.file."Library/Rime/default.custom.yaml" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/Library/Rime/default.custom.yaml";
    force = true;
  };
  home.file."Library/Rime/double_pinyin.custom.yaml" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/Library/Rime/double_pinyin.custom.yaml";
    force = true;
  };
  home.file."Library/Rime/squirrel.custom.yaml" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/Library/Rime/squirrel.custom.yaml";
    force = true;
  };
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
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/settings.json";
  home.file.".pi/agent/openai-fast.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/openai-fast.json";
  home.file.".pi/agent/pi-herdr-btw.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/pi-herdr-btw.json";
  home.file.".pi/agent/packages/pi-herdr-btw".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/packages/pi-herdr-btw";

}
