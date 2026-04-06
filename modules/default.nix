{
  pkgs,
  lib,
  ...
}:
let
  gstPackages = with pkgs.gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-libav
  ];
  gstPluginPath = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstPackages;
  coffeeViewer = pkgs.writeShellApplication {
    name = "stream-viewer";
    runtimeInputs = gstPackages;
    runtimeEnv = {
      GST_PLUGIN_PATH = gstPluginPath;
    };
    text = builtins.readFile ./coffee-stream-viewer.sh;
  };
in
{
  nix.enable = false;
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  hardware.enableAllHardware = true;
  hardware.graphics.enable = true;

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
    extraGroups = [
      "wheel"
      "video"
      "render"
      "i2c"
    ];
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  services.cage = {
    enable = true;
    user = "pi";
    program = lib.getExe coffeeViewer;
    # environment.WLR_LIBINPUT_NO_DEVICES = "1";
  };
  systemd.services."cage-tty1" = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };

  system.stateVersion = "26.05";
}
