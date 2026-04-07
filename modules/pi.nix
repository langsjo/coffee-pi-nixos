{
  pkgs,
  modulesPath,
  config,
  inputs,
  ...
}:
let
  empty = pkgs.writeTextDir "my-empty-file" "";
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-2
    "${inputs.nixos-hardware}/raspberry-pi/common/config-txt.nix"
    (modulesPath + "/installer/sd-card/sd-image-armv7l-multiplatform-installer.nix")
  ];

  nixpkgs.overlays = [
    (final: prev: {
      efivar = empty;
      efibootmgr = empty;
    })
  ];

  boot.initrd.allowMissingModules = true;
  nixpkgs.hostPlatform = "armv7l-linux";
  sdImage.populateFirmwareCommands = ''
    cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/*.dtb firmware/
    cp -r ${pkgs.raspberrypifw}/share/raspberrypi/boot/overlays firmware/
    cp ${pkgs.ubootRaspberryPi4_32bit}/u-boot.bin firmware/u-boot-rpi4.bin
    cp -f ${config.hardware.raspberry-pi.configtxt.file} firmware/config.txt
  '';

  hardware.raspberry-pi.configtxt.settings = {
    avoid_warnings = 1;
    enable_uart = 1;
    pi2.kernel = "u-boot-rpi2.bin";
    pi3.kernel = "u-boot-rpi3.bin";
    pi4 = {
      kernel = "u-boot-rpi4.bin";
      arm_64bit = 0;
      device_tree_address = "0x03000000";
      total_mem = 3072;
      otg_mode = 1;
    };
  };
}
