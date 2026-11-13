{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Boot: systemd-boot on the Windows ESP, kernels on the 1 GiB XBOOTLDR
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.xbootldrMountPoint = "/boot";
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.loader.efi.canTouchEfiVariables = true;

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
  ];

  # laptop basics
  security.pam.services.swaylock = {};
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  hardware.bluetooth.enable = true;

  system.stateVersion = "26.05";
}
