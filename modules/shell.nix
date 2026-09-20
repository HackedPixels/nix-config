{ pkgs, ...}: {
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
}
