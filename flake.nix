{
  description = "Example nix-darwin system flake";

  inputs = {
    catppuccin.url = "github:catppuccin/nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
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
          home-manager.users.${username}= { pkgs, ... }: {
            imports = [
              catppuccin.homeModules.catppuccin
              ./modules/editor.nix
              ./modules/shell.nix
            ];

            home.stateVersion = "26.05";
            programs.bat.enable = true;

            home.packages = with pkgs; [
              ripgrep
              fd
              lazygit
              unzip
              gcc
              nodejs_22
            ];

            programs.tmux = {
              enable = true;
              baseIndex = 1;
              clock24 = true;
              keyMode = "vi";
              prefix = "C-a";
              plugins = with pkgs.tmuxPlugins; [
                cpu
                tilish
              ];
              extraConfig = ''
              set -g @tilish-default 'main-vertical'
              '';
            };

            programs.btop.enable = true;

            catppuccin.enable = true;
            catppuccin.tmux = {
              enable = true;
              extraConfig = ''
                set -g status-right-length 100
                set -g status-left-length 100
                set -g status-left ""
                set -g status-right "#{E:@catppuccin_status_application}"
                set -agF status-right "#{E:@catppuccin_status_cpu}"
                set -agF status-right "#{E:@catppuccin_status_ram}"
                set -ag status-right "#{E:@catppuccin_status_session}"
                set -ag status-right "#{E:@catppuccin_status_uptime}"
                set -agF status-right "#{E:@catppuccin_status_battery}"
              '';
            };

            programs.direnv = {
              enable = true;
              enableZshIntegration = true;
              nix-direnv.enable = true;
            };

            programs.eza = {
              enable = true;
              enableZshIntegration = true;
            };

            programs.starship = {
              enable = true;
              enableZshIntegration = true;
              presets = [];
            };
          };
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
  };
}
