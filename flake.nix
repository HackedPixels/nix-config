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
    #pi.url = "github:lukasl-dev/pi.nix";
  };

  outputs = inputs@{ self, home-manager, nix-darwin, nixpkgs, determinate, catppuccin, nixvim, ...}:
  let
    mkDarwinSystem = { system, username, fullName, email, profile }:
      nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs system username fullName email profile; };
        modules = [ ./modules/darwin ];
      };
  in
  {
    darwinConfigurations = {
      "SDGDEU-YFD7130T" = mkDarwinSystem {
        system = "aarch64-darwin";
        username = "jan";
	fullName = "Jan Köppen";
	email = "jan.koeppen1@digits.schwarz";
        profile = "work";
      };
      "Jans-MacBook-Pro" = mkDarwinSystem {
        system = "aarch64-darwin";
        username = "jan";
        profile = "private";
      };
    };
  };
}
