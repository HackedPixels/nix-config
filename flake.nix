{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
  };

  outputs = inputs@{ self, home-manager, nix-darwin, nixpkgs, determinate }:
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
      nixpkgs.hostPlatform = "aarch64-darwin";

      users.users.jan = {
        name = "jan";
        home = "/Users/jan";
      };

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Jans-MacBook-Pro
    darwinConfigurations."Jans-MacBook-Pro" = nix-darwin.lib.darwinSystem {
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
          home-manager.users.jan = { pkgs, ... }: {
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

            programs.zsh = {
              enable = true;
              antidote = {
                enable = true;
                plugins = [
"getantidote/use-omz"
"ohmyzsh/ohmyzsh path:lib"
"ohmyzsh/ohmyzsh path:plugins/colored-man-pages"
"ohmyzsh/ohmyzsh path:plugins/magic-enter"

"jeffreytse/zsh-vi-mode"
"zdharma-continuum/fast-syntax-highlighting kind:defer"
"zsh-users/zsh-autosuggestions"
                ];
              };
            };

            programs.starship = {
              enable = true;
              enableZshIntegration = true;
              presets = [];
            };

            programs.neovim = {
              enable = true;
              defaultEditor = true;
              viAlias = true;
              vimAlias = true;

              plugins = with pkgs.vimPlugins; [
                lazy-nvim
                LazyVim
              ];

              initLua = ''
                require("lazy").setup({
                  spec = {
                    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
                  },
                  defaults = { lazy = false },
                  install = { colorscheme = { "tokyonight", "habamax" } },
                  checker = { enabled = true },
                })
              '';

            };
          };

        }
      ];
    };
  };
}
