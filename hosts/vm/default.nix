{
  config,
  pkgs,
  pkgs-unstable,
  mpv-src,
  nix-cachyos-kernel,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
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
  #boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-zen4;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # The VM does not need 32-bit graphics support.
  hardware.graphics.enable32Bit = false;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  services.printing.enable = false;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (import ../../overlays/mpv-git.nix pkgs-unstable mpv-src)
    (import ../../overlays/faugus-launcher.nix pkgs-unstable)
    nix-cachyos-kernel.overlays.pinned
  ];

  environment.systemPackages = with pkgs; [
    pciutils
    git
    gnumake
    micro
    mpv-git
    sublime4
    uv
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
  ];

  # Necessary exception for Sublime Text
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];

  # Certification fix for yt-dlp binary that is managed via UV.
  environment.sessionVariables = {
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  };

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://attic.xuyh0120.win/lantian"
    ];
    trusted-public-keys = [
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.imatic = import ../../home.nix;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  networking.firewall.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  system.stateVersion = "26.05"; # Did you read the comment?

}
