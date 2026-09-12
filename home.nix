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

  xdg.configFile."klassy/klassyrc".source =
  ./dotfiles/klassy/klassyrc;

  programs.plasma = {
    enable = true;

    workspace = {
      #lookAndFeel = "org.kde.breezedark.desktop";
      # org.kde.klassykitedarkbottompanel.desktop

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
/*
      "klassy/klassyrc" = {
        Global = {
          #LookAndFeelSet = "org.kde.breezedark.desktop";
          LookAndFeelSet = "org.kde.klassykitedarkbottompanel.desktop";
          #RefreshedConfig = "6.5.3";
        };

        TitleBarOpacity = {
          ActiveTitleBarOpacity = 80;
          InactiveTitleBarOpacity = 64;
        };

        Windeco = {
          ButtonIconStyle = "StyleFluent";
          ColorizeWindowOutlineWithButton = false;
          DrawTitleBarSeparator = false;
          WindowCornerRadius = 12;
        };

        WindowOutlineStyle = {
          WindowOutlineAccentColorOpacityActive = 30;
          WindowOutlineStyleActive = "WindowOutlineAccentColor";
        };
      };
*/
    };
  };
}
