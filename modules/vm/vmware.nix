{
  virtualisation.vmware.guest.enable = true;

  services.pipewire = {
    extraConfig.pipewire."90-vm-buffer" = {
      "context.properties" = {
        "default.clock.quantum" = 256;
        "default.clock.min-quantum" = 256;
        "default.clock.max-quantum" = 512;
      };
    };

    wireplumber.extraConfig."90-vmware-audio" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "node.name" = "~alsa_output.*";
            }
          ];

          actions = {
            "update-props" = {
              "api.alsa.period-size" = 512;
              "api.alsa.headroom" = 1024;
              "api.alsa.disable-tsched" = true;
            };
          };
        }
      ];
    };
  };
}
