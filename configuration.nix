{ config, pkgs, ... }:

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
    extraGroups = [ "wheel" "networkmanager" "video" ];
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
    git
    alacritty
    fuzzel         # niri's default launcher (Super+D)
    brave
    brightnessctl
    swaylock
    swayidle
    mako           # notification
    libnotify
    wlsunset       # blue light filter

    (writeShellScriptBin "nrs" ''
      set -euo pipefail
      cd ~/nixos
      git add -A
      git --no-pager diff --cached --stat
      nixos-rebuild switch --flake ~/nixos --sudo
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
      nixos-rebuild switch --flake ~/nixos --sudo
      git commit -m "flake update $(date '+%Y-%m-%d')" || true
      git push
    '')
  ];

  # laptop basics
  security.pam.services.swaylock = {};
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  hardware.bluetooth.enable = true;

  system.stateVersion = "26.05";
}
