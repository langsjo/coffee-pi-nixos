{
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-2
  ];
  boot.initrd.allowMissingModules = true;
  nixpkgs.hostPlatform = "armv7l-linux";
}
