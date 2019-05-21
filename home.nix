{ config, pkgs, ... }:

let home_directory = builtins.getEnv "HOME";
    log_directory = "${home_directory}/logs";
    tmp_directory = "/tmp";
    localconfig = import <localconfig>;
    mkPersistentLink = path: pkgs.runCommand "persistent-link" {} ''
      ln -s /nix/persistent/nicola/${path} $out
    '';

in rec {
  ##import ./config/emacs.nix;

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

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 86400;
  };

  home.packages = [
    pkgs.ripgrep
    pkgs.htop
    pkgs.lsof
  ];

  home.file.".emacs.d/init.el".source = ./dotfiles/emacs/init.el;
  home.file.".emacs.d/custom.el".source = ./dotfiles/emacs/custom.el;
  home.file.".config/sakura/sakura.conf".source = ./dotfiles/sakura.conf;

  ## This should really be in ${zsh.dotDir}...

  home.file.".zsh/prompts/prompt_nikki_setup".source = ./dotfiles/zsh/prompt_nikki_setup;

  programs = {
    direnv.enable = true;

    lesspipe.enable = true;

    zsh = rec {
      enable = true;
      dotDir = ".config/zsh";
      enableCompletion = false;
      enableAutosuggestions = true;
      history.share = false;
      defaultKeymap = "emacs";
      ## enableSyntaxHighlighting = true;

      initExtra = ''
        [[ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]] && \
            . $HOME/.nix-profile/etc/profile.d/nix.sh
        fpath+=$HOME/.zsh/prompts
        autoload -U promptinit && promptinit
        prompt nikki
        export PATH=$PATH:$HOME/.sbcl/bin
      '';

      shellAliases = {
        ls = "ls --color=tty";
      };

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
