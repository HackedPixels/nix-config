{ pkgs, config, ... }: {
  programs.obsidian.enable = true;

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = {
      vimwiki.enable = true;
    };

    opts = {
      background = if config.catppuccin.flavor == "latte" then "light" else "dark";
    };

    extraConfigLua = ''
      vim.cmd.colorscheme("catppuccin")
    '';
  };
}
