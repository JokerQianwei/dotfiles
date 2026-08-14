{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleInterfaceStyleSwitchesAutomatically = true;
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
      "com.apple.trackpad.scaling" = 3.0;
    };
    CustomUserPreferences."com.apple.HIToolbox".AppleGlobalTextInputProperties = {
      TextInputGlobalPropertyPerContextInput = true;
    };
    dock = {
      autohide = true;
      tilesize = 26;
      mru-spaces = false;
      wvous-br-corner = 14;  # Quick Note
    };
    finder = {
      FXPreferredViewStyle = "Nlsv";  # list view by default
      CreateDesktop = false;          # clean desktop
      ShowPathbar = true;
      _FXShowPosixPathInTitle = false;
    };
    trackpad = {
      Clicking = true;              # tap to click
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
    };
    WindowManager.EnableTiledWindowMargins = false;
  };
  nix-homebrew = {
    enable = true;
    inherit user;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    brews = [
      "duti"
      "herdr"
      "leetgo"
      "pi-coding-agent"
      "pngpaste"
    ];
    casks = [
      "1password"
      "1password-cli"
      "betterdisplay"
      "codexbar"
      "coteditor"
      "ghostty"
      "google-chrome"
      "hapigo"
      "keka"
      "karabiner-elements"
      "logi-options+"
      "mos"
      "notion"
      "pearcleaner"
      "snipaste"
      "sublime-text"
      "tencent-meeting"
      "updf"
      "uuremote"
      "visual-studio-code"
      "wechat"
      "wetype"
    ];
    masApps = {
      Bob = 1630034110;
      "Microsoft Excel" = 462058435;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft Word" = 462054704;
      Shadowrocket = 932747118;
    };
  };
}
