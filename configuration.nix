{ config, pkgs, lib, ... }: {

  # --- Flakes & Nix Settings ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # --- Bootloader & Kernel ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # --- Networking ---
  networking.hostName = "lain";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ]; # SSH

  # --- Time & Localization ---
  time.timeZone = "Asia/Bangkok";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "th_TH.UTF-8";
    LC_IDENTIFICATION = "th_TH.UTF-8";
    LC_MEASUREMENT = "th_TH.UTF-8";
    LC_MONETARY = "th_TH.UTF-8";
    LC_NAME = "th_TH.UTF-8";
    LC_NUMERIC = "th_TH.UTF-8";
    LC_PAPER = "th_TH.UTF-8";
    LC_TELEPHONE = "th_TH.UTF-8";
    LC_TIME = "th_TH.UTF-8";
  };

  # --- User Account ---
  users.users.lain = {
    isNormalUser = true;
    description = "Lain";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  # --- Desktop Environment: Gnome ---
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us,th";
    options = "grp:alt_shift_toggle";
  };

  # --- Audio: Pipewire ---
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- System Services ---
  virtualisation.docker.enable = true;
  services.openssh.enable = true;
  services.asusd.enable = true; # For ASUS laptops

  # --- Gaming ---
  programs.steam.enable = true;
  programs.gamemode.enable = true;

  # --- System Packages ---
  environment.systemPackages = with pkgs; [
    vim git curl wget tree htop btop # Basic tools
    asusctl supergfxctl # ASUS tools
    starship # Shell
    brave firefox # Browsers
    vscode github-cli # Development
    python3 nodejs_20 rustc go gcc clang # Programming languages & build tools
    (python3.withPackages (ps: with ps; [
      torch torchvision numpy pandas scikit-learn matplotlib jupyter # ML/AI Python libraries
    ]))
    discord # Communication
    steam lutris # Gaming
    inkscape gimp krita blender # Graphics
    vlc obs-studio # Media
    unzip p7zip cudatoolkit nvidia-docker # Utilities
    
    # Gnome Extensions
    gnomeExtensions.blur-my-shell
    gnomeExtensions.user-themes
    gnomeExtensions.dash-to-dock
    gnomeExtensions.vitals
  ];

  # --- Fonts ---
  fonts.packages = with pkgs; [
    noto-fonts noto-fonts-cjk-sans noto-fonts-emoji noto-fonts-extra
    liberation_ttf fira-code fira-code-symbols jetbrains-mono
    hack-font source-code-pro iosevka victor-mono
  ];

  # --- System State ---
  system.stateVersion = "25.05";
}
