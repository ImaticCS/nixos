{
  description = "imatic's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    mpv-src = {
      url = "github:mpv-player/mpv/master";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-index-database,
      home-manager,
      plasma-manager,
      mpv-src,
      nix-cachyos-kernel,
      ...
    }:
    let
      system = "x86_64-linux";

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;

        config = {
          allowUnfree = true;
        };
      };
    in
    {
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit pkgs-unstable mpv-src nix-cachyos-kernel;
        };

        modules = [
          ./hosts/vm

          nix-index-database.nixosModules.default
          home-manager.nixosModules.home-manager

          {
            home-manager.extraSpecialArgs = {
              inherit plasma-manager;
            };
          }
        ];
      };

      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit pkgs-unstable mpv-src nix-cachyos-kernel;
        };

        modules = [
          ./hosts/desktop

          nix-index-database.nixosModules.default
          home-manager.nixosModules.home-manager

          {
            home-manager.extraSpecialArgs = {
              inherit plasma-manager;
            };
          }
        ];
      };
    };
}
