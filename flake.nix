{
  description = "Example nix-darwin system flake";

  inputs = {
    catppuccin.url = "github:catppuccin/nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixvim.url = "github:nix-community/nixvim";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    pi.url = "github:lukasl-dev/pi.nix";
  };

  outputs = inputs@{ self, home-manager, nix-darwin, nixpkgs, determinate, catppuccin, nixvim, ...}:
  let
    mkDarwinSystem = { system, username, profile }:
      nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs system username profile; };
        modules = [ ./modules/darwin ];
      };

    # Standalone home-manager for a non-NixOS Linux host that already has nix installed.
    mkLinuxSystem = { system, username, profile }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit inputs profile; };
        modules = [
          { nixpkgs.config.allowUnfree = true; }
          ./modules/home
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
        profile = "work";
      };
      "Jans-MacBook-Pro" = mkDarwinSystem {
        system = "aarch64-darwin";
        username = "jan";
        profile = "private";
      };
    };

    homeConfigurations = {
      "jankoeppen@SDGDEU-G60216JQ" = mkLinuxSystem {
        system = "x86_64-linux";
        username = "jan";
        profile = "work";
      };
      "jan@cairo" = mkLinuxSystem {
        system = "x86_64-linux";
        username = "jan";
        profile = "private";
      };
    };
  };
}
