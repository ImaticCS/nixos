{
  description = "imatic's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

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
      home-manager,
      plasma-manager,
      mpv-src,
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
          inherit pkgs-unstable mpv-src;
        };

        modules = [
          ./hosts/vm
          
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
