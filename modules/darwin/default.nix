# Shared darwin config. Profile specific parts live in ./<profile>.nix.
{ pkgs, inputs, system, email, fullName, username, profile, ... }: {
  imports = [
    ./${profile}.nix
    inputs.determinate.darwinModules.default
    inputs.nixvim.nixDarwinModules.nixvim
    inputs.home-manager.darwinModules.home-manager
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.vim
    pkgs.lmstudio
    pkgs.git

    #pkgs.alcove # dont include since it cant be licensed when installed via nix
    pkgs.fzf

    pkgs.serie

    pkgs.orbstack
  ];
  environment.variables = {
    PATH = "$PATH:$HOME/.docker/bin";
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  system.primaryUser = username;
  system.defaults.dock.autohide = true;
  system.defaults.dock.largesize = 64;

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;
  programs.zsh = {
    enable = true;
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  #services.tailscale.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs = {
    hostPlatform = system;
    config.allowUnfree = true;
  };

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  determinateNix.enable = true;
  determinateNix.determinateNixd = {
    builder = {
      state = "enabled";
      cpuCount = 6;
      memoryBytes = 17179869184; # 16 GiB
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs profile username email fullName; };
    users.${username} = import ../home;
  };
}
