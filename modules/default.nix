{
  pkgs,
  lib,
  ...
}:
let
  coffeeViewer = pkgs.writeShellApplication {
    name = "stream-viewer";
    runtimeInputs = [
      (pkgs.mpv.override { youtubeSupport = false; })
    ];
    text = builtins.readFile ./coffee-stream-viewer.sh;
  };

  cage' = pkgs.cage.override (old: {
    wlroots_0_19 = old.wlroots_0_19.override {
      enableXWayland = false;
    };
  });
in
{
  nix.enable = false;
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  hardware.enableAllHardware = true;
  hardware.graphics.enable = true;

  networking.networkmanager.enable = lib.mkForce false;
  networking.wireless = {
    enable = true;
    networks."aalto open" = { };
  };

  # services.journald.storage = "none";
  time.timeZone = "Europe/Helsinki";
  console.keyMap = "fi";

  users.users.pi = {
    isNormalUser = true;
    initialPassword = "coffee-pi";
    extraGroups = [ "wheel" ];
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  services.cage = {
    enable = true;
    package = cage';
    user = "pi";
    program = lib.getExe coffeeViewer;
    # environment.WLR_LIBINPUT_NO_DEVICES = "1";
  };
  # systemd.services."cage-tty1" = {
  #   wants = [ "network-online.target" ];
  #   after = [ "network-online.target" ];
  # };

  system.stateVersion = "26.05";
}
