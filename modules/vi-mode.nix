{ custom, pname, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.m3l6h.${pname}.vi-mode = {
    enable = mkOption {
      default = true;
      description = "zsh vi mode plugin";
      type = types.bool;
    };
  };

  config =
    let
      parent = config.m3l6h.${pname};
      enable = parent.enable;
      cfg = parent.vi-mode;
    in
    mkIf (enable && cfg.enable) {
      home.packages = with pkgs; [
        wl-clipboard # Used to yank to clipboard
        zsh-vi-mode
      ];

      home.file."${custom}/plugins/zsh-vi-mode" = {
        recursive = true;
        source = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
      };

      home.file."${custom}/my-custom/zsh-vi-mode.sh".source = ./vi-mode.sh;
    };
}
