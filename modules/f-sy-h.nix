{ custom, pname, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.m3l6h.${pname}.f-sy-h = {
    enable = mkOption {
      default = true;
      description = "f-sy-h syntax highlighting plugin";
      type = types.bool;
    };
  };

  config =
    let
      parent = config.m3l6h.${pname};
      enable = parent.enable;
      cfg = parent.f-sy-h;
    in
    mkIf (enable && cfg.enable) {
      home.packages = with pkgs; [
        zsh-f-sy-h
      ];

      home.file."${custom}/plugins/F-Sy-H" = {
        recursive = true;
        source = "${pkgs.zsh-f-sy-h}/share/zsh/site-functions";
      };

      programs.zsh.oh-my-zsh.plugins = [ "F-Sy-H" ];
    };
}
