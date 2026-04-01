{
  custom,
  pname,
  ...
}@flake-args:
{
  config,
  lib,
  ...
}:
with lib;
{
  options.m3l6h.${pname} = {
    enable = mkEnableOption "m3l6h's custom zsh configuration";
    impermanence.enable = mkEnableOption "persistence for key directories";
    envExtra = mkOption {
      default = "";
      description = "Environment variables to be added to .zshenv";
      example = literalExpression ''
        EDITOR='nvim'
      '';
      type = types.lines;
    };
    initContent = mkOption {
      default = "";
      description = "Content to be added to .zshrc";
      example = literalExpression ''
        echo "Hello zsh initContent!"
      '';
      type = types.lines;
    };
    keychainUnlock = mkOption {
      default = true;
      description = "Try unlock keychain on SSH";
      type = types.bool;
    };
    ohMyZsh.enable = mkOption {
      default = true;
      description = "oh-my-zsh integration";
      type = types.bool;
    };
    overrideNixDevelop = mkOption {
      default = true;
      description = "Override nix develop to use this shell";
      type = types.bool;
    };
  };

  imports = [
    (import ./aliases.nix flake-args)
    (import ./f-sy-h.nix flake-args)
    (import ./functions.nix flake-args)
    (import ./starship.nix flake-args)
    (import ./vi-mode.nix flake-args)
    (import ./zoxide.nix flake-args)
  ];

  config =
    let
      cfg = config.m3l6h.${pname};

      # integration with my custom neovim
      neovim =
        config.m3l6h.neovim or {
          enable = false;
        };

      # integration with my custom tmux
      tmux =
        config.m3l6h.tmux or {
          enable = false;
        };
    in
    mkIf cfg.enable {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;

        envExtra = concatLines (
          [
            # Ensure proper font display
            "export LC_ALL=en_US.UTF-8"
            "export LANG=en_US.UTF-8"
          ]
          ++ optionals neovim.enable [
            "export EDITOR='nvim'"
          ]
          ++ optionals tmux.enable [
            "export ZSH_TMUX_AUTOSTART=true"
            # Autoquit can get us locked out of our terminal if our tmux config gets jacked up
            "export ZSH_TMUX_AUTOQUIT=false"
          ]
          ++ optionals cfg.vi-mode.enable [
            "export ZVM_VI_SURROUND_BINDKEY='s-prefix'"
          ]
          ++ optionals cfg.zoxide.enable [
            "export ZOXIDE_CMD_OVERRIDE='cd'"
          ]
          ++ [ cfg.envExtra ]
        );

        history.expireDuplicatesFirst = true;

        initContent = concatLines (
          optionals cfg.vi-mode.enable [
            "source $HOME/${custom}/my-custom/zsh-vi-mode.sh"
          ]
          ++ optionals cfg.overrideNixDevelop [
            ''
              nix() {
                if [ "$1" = 'develop' ]; then
                  shift
                  command nix develop -c "$SHELL" "$@"
                else
                  command nix "$@"
                fi
              }
            ''
          ]
          ++ optionals cfg.keychainUnlock [
            ''
              if [ -n "$SSH_CLIENT" ]; then
                LOCKED="$(busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/collection/login org.freedesktop.Secret.Collection Locked 2>/dev/null | awk '{printf "%s", $2}')"

                if "$LOCKED"; then
                  printf 'Unlock keyring (enter password for %s): ' "$USER"
                  read -s PASS
                  echo ""
                  printf '%s' "$PASS" | gnome-keyring-daemon --unlock --replace >/dev/null 2>&1
                  unset PASS
                fi
              fi
            ''
          ]
          ++ [ cfg.initContent ]
        );

        oh-my-zsh = {
          enable = true;
          custom = "$HOME/${custom}";
          extraConfig = ''
            path=($HOME/.local/bin $path)
            export PATH
          '';
          plugins = [
            "git"
            "git-auto-fetch"
          ]
          ++ optionals tmux.enable [
            "tmux"
          ]
          ++ optionals cfg.zoxide.enable [
            "zoxide"
          ]
          ++ optionals cfg.vi-mode.enable [
            "zsh-vi-mode"
          ];
        };
      };
    };
}
