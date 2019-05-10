{ config, pkgs, ... }:

let home_directory = builtins.getEnv "HOME";
    log_directory = "${home_directory}/logs";
    tmp_directory = "/tmp";
    localconfig = import <localconfig>;
    mkPersistentLink = path: pkgs.runCommand "persistent-link" {} ''
      ln -s /nix/persistent/nicola/${path} $out
    '';

in rec {
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = false;
      allowUnsupportedSystem = false;
    };

    overlays =
      let path = ./overlays; in with builtins;
      map (n: import (path + ("/" + n)))
          (filter (n: match ".*\\.nix" n != null ||
                      pathExists (path + ("/" + n + "/default.nix")))
                  (attrNames (readDir path)));
   };

  home.packages = [
    pkgs.htop
  ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 600;
  };

  programs = {
    direnv.enable = true;

    lesspipe.enable = true;

    zsh = rec {
      enable = true;
      dotDir = ".config/zsh";
      enableCompletion = false;
      enableAutosuggestions = true;
      ## enableSyntaxHighlighting = true;

      initExtra = ''
         fpath+=$HOME/.zsh/prompts
         autoload -U promptinit && promptinit
         prompt nikki
      '';
      plugins = [
      ];

      sessionVariables = {
        EDITOR = "${pkgs.vim}/bin/vim";
        LESS   = "-FRSXM";
      };
    };

    home-manager = {
      enable = true;
      path = "https://github.com/avatarwin/home-manager/archive/master.tar.gz";
    };

    git = {
      enable = true;
      userName = "Nicola Archibald";
      userEmail = "133696+avatarwin@users.noreply.github.com";
      extraConfig = {
        log.abbrevCommit = true;
        format.pretty = "oneline";
      };

     ignores = [
       "#*#"
       "*.a"
       "*.o"
       "*~"
       "*.elc"
       "*.so"
       "result"  ## Sure about this one?
     ];
    };
  };
}
