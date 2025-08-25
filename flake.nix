{
  description = "NixOS configuration for RTX 4070 laptop with dev tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.lain = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import
        ./hardware-configuration.nix
        ./configuration.nix
        ./nvidia.nix

        # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.lain = import ./home.nix;
          };
        }

        # --- Auto-Upgrade ---
        ({ ... }: {
          system.autoUpgrade = {
            enable = true;
            flake = inputs.self.outPath;
            flags = [ "--update-input" "nixpkgs" "-L" ];
            dates = "02:00";
            randomizedDelaySec = "45min";
          };
        })
      ];
    };
  };
}
