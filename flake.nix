{
  description = "imatic's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
      ...
    }:
    let
      system = "x86_64-linux";

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit pkgs-unstable;
        };

        modules = [
          ./configuration.nix

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

#{
#  description = "imatic's NixOS configuration";
#
#  inputs = {
#    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
#    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
#  };
#
#  outputs = { self, nixpkgs, ... }: {
#    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
#      system = "x86_64-linux";
#      modules = [
#        ./configuration.nix
#      ];
#    };
#  };
#}
