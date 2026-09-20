{
  description = "Example nix-darwin system flake";

  inputs = {
    catppuccin.url = "github:catppuccin/nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
  };

  outputs = inputs@{ self, home-manager, nix-darwin, nixpkgs, determinate, catppuccin }:
  let
    mkDarwinSystem = { system, username }:
    let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;
      programs.zsh = {
        enable = true;
      };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = system;

      users.users.${username} = {
        name = username;
        home = "/Users/${username}";
      };
    };
    in nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        inputs.determinate.darwinModules.default
        {
            determinateNix.enable = true;
        }
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.${username} = import ./modules/home.nix;
        }
      ];
    };

    # Standalone home-manager for a non-NixOS Linux host that already has nix installed.
    mkLinuxSystem = { system, username }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./modules/home.nix
          {
            home.username = username;
            home.homeDirectory = "/home/${username}";
            targets.genericLinux.enable = true;
          }
        ];
      };
  in
  {
    darwinConfigurations = {
      "SDGDEU-YFD7130T" = mkDarwinSystem {
        system = "aarch64-darwin";
        username = "jan";
      };
      "Jans-MacBook-Pro" = mkDarwinSystem {
        system = "aarch64-darwin";
        username = "jan";
      };
    };

    homeConfigurations = {
      "jankoeppen@SDGDEU-G60216JQ" = mkLinuxSystem {
        system = "x86_64-linux";
        username = "jan";
      };
    };
  };
}
