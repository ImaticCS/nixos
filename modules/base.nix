{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # System
  # ---------------------------------------------------------------------------

  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  time.timeZone = "Australia/Sydney";

  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  users.users.imatic = {
    isNormalUser = true;
    description = "imatic";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # ---------------------------------------------------------------------------
  # Desktop
  # ---------------------------------------------------------------------------

  programs.firefox.enable = true;

  fonts.packages = with pkgs; [
    inter
  ];

  hardware.graphics.enable = true;

  # ---------------------------------------------------------------------------
  # Compatibility
  # ---------------------------------------------------------------------------

  programs.nix-ld.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  zramSwap.enable = true;

  # ---------------------------------------------------------------------------
  # Nix
  # ---------------------------------------------------------------------------

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # ---------------------------------------------------------------------------
  # Boot
  # ---------------------------------------------------------------------------

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ---------------------------------------------------------------------------
  # Home Manager
  # ---------------------------------------------------------------------------

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.imatic = import ../home.nix;
  };

  # ---------------------------------------------------------------------------
  # System packages
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    git
    jq
    micro
    mpv-git
    nh
    nix-tree
    nixfmt
    nix-init
    nurl
    nix-prefetch-github
    sublime4
    tmux
    yt-dlp-nightly
  ];

  # Temporary workaround for Sublime Text's bundled Package Control,
  # which currently appears to depend on the legacy OpenSSL 1.1.1 package.
  # Remove this once upstream no longer requires OpenSSL 1.1.1.
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];
}
