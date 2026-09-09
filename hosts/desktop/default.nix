{
  pkgs,
  pkgs-unstable,
  mpv-src,
  nix-cachyos-kernel,
  ...
}:

{
  imports = [
    ../../modules/base.nix
    ../../modules/audio
    ../../modules/desktop/plasma.nix
  ];

  networking.hostName = "desktop";

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-zen4;

  hardware.graphics.enable32Bit = true;

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "openssl-1.1.1w"
    ];
  };

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

  system.stateVersion = "26.05";
}
