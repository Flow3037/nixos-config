{ config, lib, pkgs, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Boot: systemd-boot on the Windows ESP, kernels on the 1 GiB XBOOTLDR
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.xbootldrMountPoint = "/boot";
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "saislaptop";
  networking.networkmanager.enable = true;

  time.timeZone = "Australia/Sydney";
  time.hardwareClockInLocalTime = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  users.users.sai = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "input" "docker" ];
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    config = {
      user.name = "Sai Prakhya";
      user.email = "prakhyasai37@gmail.com";
      init.defaultBranch = "main";
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta.navigate = true;
      merge.conflictStyle = "zdiff3";
    };
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  programs.niri.enable = true;
  systemd.user.services.niri.enableDefaultPath = false;

  programs.dms-shell = {
    enable = true;
    systemd.enable = true;
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${config.programs.niri.package}/bin/niri-session";
      user = "greeter";
    };
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    brave
    brightnessctl
    libnotify
    kitty
    stow
    xarchiver
    vesktop
    duf
    xwayland-satellite
    zed-editor
    vscode.fhs
    adw-gtk3
    papirus-icon-theme
    (inputs.fetch.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./fetch.patch ];
    }))
    whitesur-cursors
    loupe
    tree
    gnumake
    gh
    nixd
    nixfmt
    ripgrep
    fd
    eza
    jq
    ncdu
    tealdeer
    wl-clipboard
    delta
    _7zz
    unzip
    nix-tree
    showtime
    libreoffice
    hunspellDicts.en_AU
    papers

    (writeShellScriptBin "nrs" ''
      set -euo pipefail
      cd ~/nixos
      git add -A
      git --no-pager diff --cached --stat
      nh os switch ~/nixos
      if git diff --cached --quiet; then
        echo "Nothing to commit."
      else
        git commit -m "''${1:-update $(date '+%Y-%m-%d %H:%M')}"
        git push
      fi
    '')

    (writeShellScriptBin "nup" ''
      set -euo pipefail
      cd ~/nixos
      nix flake update
      git add flake.lock
      nh os switch ~/nixos
      git commit -m "flake update $(date '+%Y-%m-%d')" || true
      git push
    '')
  ];

  # laptop basics
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  hardware.bluetooth.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    inter
    carlito
    caladea
  ];
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Inter Variable" ];
    monospace = [ "JetBrainsMono Nerd Font" ];
  };
  programs.dconf = {
    enable = true;
    profiles.user.databases = [{
      settings."org/gnome/desktop/interface" = {
        gtk-theme = "adw-gtk3-dark";
        color-scheme = "prefer-dark";
        icon-theme = "Papirus-Dark";
        cursor-theme = "WhiteSur-cursors";
        cursor-size = lib.gvariant.mkInt32 34;
        font-name = "Inter Variable 11";
        monospace-font-name = "JetBrainsMono Nerd Font 11";
      };
    }];
  };

  programs.nix-ld.enable = true;

  programs.nh = {
    enable = true;
    flake = "/home/sai/nixos";
  };
  programs.direnv.enable = true;
  programs.fzf.keybindings = true;
  programs.zoxide.enable = true;
  programs.bat.enable = true;

  programs.nix-index-database.comma.enable = true;
  programs.localsend.enable = true;
  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.comfy;
      enabledExtensions = with spicePkgs.extensions; [
        shuffle         # true random shuffle (Spotify's own isn't)
        fullAppDisplay  # full-screen "now playing" view
        spicyLyrics     # word-by-word karaoke-style lyrics
      ];
    };
  programs.kdeconnect.enable = true;

  environment.shellAliases = {
    ll = "eza -l --git --icons";
    lt = "eza --tree --level=2 --icons";
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [ thunar-archive-plugin thunar-volman ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;

# default apps
  xdg.mime.defaultApplications = {
    "inode/directory" = "thunar.desktop";
    "x-scheme-handler/http" = "brave-browser.desktop";
    "x-scheme-handler/https" = "brave-browser.desktop";
    "text/html" = "brave-browser.desktop";
    "application/pdf" = "org.gnome.Papers.desktop";
    "image/png" = "org.gnome.Loupe.desktop";
    "image/jpeg" = "org.gnome.Loupe.desktop";
    "image/webp" = "org.gnome.Loupe.desktop";
    "image/gif" = "org.gnome.Loupe.desktop";
    "video/mp4" = "org.gnome.Showtime.desktop";
    "video/x-matroska" = "org.gnome.Showtime.desktop";
    "video/webm" = "org.gnome.Showtime.desktop";
    "video/quicktime" = "org.gnome.Showtime.desktop";
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.NH_SEARCH_CHANNEL = "nixos-26.05";
  environment.etc."ssl/unsw/unsw-root.pem".source = ./certs/unsw-root.pem;

  zramSwap.enable = true;

  # weekly generation cleanup
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };

  # aussie aussie oi oi oi
  i18n.defaultLocale = "en_AU.UTF-8";

  system.stateVersion = "26.05";
}
