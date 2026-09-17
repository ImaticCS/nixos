{
  pkgs-unstable, mpv-src, ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/audio
    ../../modules/desktop/plasma.nix
    ../../modules/vm/vmware.nix
  ];

  nixpkgs.overlays = [
    (import ../../overlays/mpv-git.nix pkgs-unstable mpv-src)
    (import ../../overlays/yt-dlp-nightly.nix)
  ];

  networking.hostName = "vm";

  # The VM does not need 32-bit graphics support.
  hardware.graphics.enable32Bit = false;
  # The VM does not need printing support.
  services.printing.enable = false;

  system.stateVersion = "26.05";

}
