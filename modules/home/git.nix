{ pkgs, email, fullName, ...}: {
  programs.git = {
    enable = true;
    settings = {
      user = {
	inherit email;
        name = fullName;
      };

      init.defaultBranch = "main";
    };

    ignores = [
      ".DS_Store"
      "*.swp"
    ];
  };
}
