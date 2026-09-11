{ pkgs, pkgs-unstable, ... }:

{
  services.xserver.enable = true;

  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; [
    #klassy
    #pkgs-unstable.plasma-panel-colorizer
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    kate
    ktexteditor
    khelpcenter
    discover
    gwenview
    okular
    qrca
    plasma-keyboard
    qtvirtualkeyboard
    krdp
    ffmpegthumbs
    dolphin-plugins
    baloo-widgets
  ];
}
