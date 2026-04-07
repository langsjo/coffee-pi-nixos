{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
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

      devShell = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.mkShellNoCC {
          packages = with pkgs; [
            gst_all_1.gstreamer
            gst_all_1.gst-plugins-base
            gst_all_1.gst-plugins-good
            gst_all_1.gst-plugins-bad
            gst_all_1.gst-libav
          ];
        }
      );
    };
}
