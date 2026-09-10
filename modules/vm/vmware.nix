{
  virtualisation.vmware.guest.enable = true;

  # VMX settings:
  # pciSound.playBuffer = "20"
  # sound.bufferTime = "20"
  # sound.smallBlockSize = "512"
  # sound.maxLength = "2048"
  # sound.highPriority = "TRUE"

  services.pipewire = {
    extraConfig.pipewire."90-vm-buffer" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 128;
        "default.clock.min-quantum" = 128;
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
              "api.alsa.headroom" = 512;
              "api.alsa.disable-tsched" = true;
            };
          };
        }
      ];
    };
  };
}
