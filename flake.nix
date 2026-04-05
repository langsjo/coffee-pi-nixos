{
  inputs = {
    # nixpkgs.url = "git+file:///home/langsjo/git/nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    raspberry-pi-nix = {
      url = "github:nix-community/raspberry-pi-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system: {
        vm =
          (nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit inputs; };
            modules = [
              ./modules
              ./modules/pc.nix
            ];
          }).config.system.build.vm;
      });

      nixosConfigurations = {
        pi = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./modules
            ./modules/pi.nix
          ];
        };

        pi-cross = self.outputs.nixosConfigurations.pi.extendModules {
          modules = [
            {
              nixpkgs.buildPlatform = "x86_64-linux";
            }
          ];
        };
      };
    };
}
