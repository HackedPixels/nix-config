{ pkgs, inputs, profile, ... }: {
  imports = [
    ./${profile}.nix
    inputs.pi.homeModules.default
    inputs.nixvim.homeModules.nixvim
    ./editor.nix
    ./shell.nix
    ./theme.nix
  ];

  home.stateVersion = "26.05";
  programs.bat.enable = true;

  home.packages = with pkgs; [
    ripgrep
    fd
    git
    lazygit
    unzip
    gcc
    nodejs_22
    crush
  ];

  programs.zed-editor.enable = true;
  programs.claude-code.enable = true;

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    keyMode = "vi";
    prefix = "C-a";
    plugins = with pkgs.tmuxPlugins; [
      cpu
      tilish
      online-status
      battery
    ];
    extraConfig = ''
    set -g @tilish-default 'main-vertical'
    '';
  };

  programs.btop.enable = true;

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
      config.font = wezterm.font 'JetBrainsMono NF'
      config.font_size = 14.0

      return config
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

   programs.pi.coding-agent = {
    enable = true;
   };
}
