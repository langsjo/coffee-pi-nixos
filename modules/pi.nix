{
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];
  boot.initrd.allowMissingModules = true;
  hardware.raspberry-pi."4" = {
    fkms-3d.enable = true;
    fkms-3d.cma = 320;

    gpio.enable = true;
    i2c0.enable = true;
    i2c1.enable = true;
  };

  nixpkgs.hostPlatform = "aarch64-linux";
}
