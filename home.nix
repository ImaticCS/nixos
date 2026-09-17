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
    fastfetch
  ];

  programs.plasma = {
    enable = true;

    workspace = {

      # Plasma Style
      theme = "breeze-dark";

      # Colour scheme and icons
      colorScheme = "KlassyDark";
      iconTheme = "klassy-dark";
    };

    kwin.effects.translucency.enable = true;

    configFile = {
      kdeglobals = {
        KDE.widgetStyle = "Klassy";

        General.AccentColor = {
          value = "56,163,165";
        };
      };

      kwinrc = {
        "org.kde.kdecoration2" = {
          library = "org.kde.klassy";
          theme = "Klassy";

          BorderSize = "Normal";
          BorderSizeAuto = false;
          ButtonsOnLeft = "MFS";
          ButtonsOnRight = "HIAX";
        };

        "Effect-translucency" = {
          IndividualMenuConfig = true;
          PopupMenus = 94;
        };
      };
    };
  };
}
