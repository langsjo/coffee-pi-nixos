{
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];
  boot.initrd.allowMissingModules = true;
  nixpkgs.hostPlatform = "aarch64-linux";
}
