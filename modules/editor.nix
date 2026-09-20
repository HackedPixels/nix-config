{ pkgs, ... }: {
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
}
