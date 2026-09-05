{ pkgs, plasma-manager, ... }:

{
  imports = [
    plasma-manager.homeModules.plasma-manager
  ];

  home.username = "imatic";
  home.homeDirectory = "/home/imatic";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    htop
  ];

  programs.plasma = {
    enable = true;

    #workspace = {
    #  lookAndFeel = "org.kde.breeze.desktop";
    #};
  };
}