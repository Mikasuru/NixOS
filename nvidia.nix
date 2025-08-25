{ config, pkgs, ... }: {
  # --- Nvidia GPU for RTX 4070 Laptop ---
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Prime settings for hybrid graphics
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      offload.enable = true;
      offload.enableOffloadCmd = true;
    };
  };

  # --- Nvidia Docker/Container Support ---
  hardware.nvidia-container-toolkit.enable = true;

  # --- General Graphics Support ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
