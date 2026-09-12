{
  config,
  pkgs,
  pkgs-unstable,
  mpv-src,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/audio
    ../../modules/desktop/plasma.nix
    ../../modules/vm/vmware.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # The VM does not need 32-bit graphics support.
  hardware.graphics.enable32Bit = false;

  networking.hostName = "nixos"; # Define your hostname.

  services.printing.enable = false;

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (import ../../overlays/mpv-git.nix pkgs-unstable mpv-src)
    (import ../../overlays/faugus-launcher.nix pkgs-unstable)
    (import ../../overlays/pipx.nix)
  ];

  environment.systemPackages = with pkgs; [
    pciutils
    git
    gnumake
    micro
    mpv-git
    sublime4
    nh
    nix-tree
    nix-diff
    nix-du
    nvd
    nixfmt
    statix
    nix-init
    nurl
    nix-prefetch-github
    jq
    pipx
    #faugus-launcher
  ];

  # Necessary exception for Sublime Text
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.imatic = import ../../home.nix;
  };

  networking.firewall.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  system.stateVersion = "26.05"; # Did you read the comment?

}
