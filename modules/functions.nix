{ custom, pname, ... }:
{
  config,
  lib,
  ...
}:
with lib;
{
  options.m3l6h.${pname}.functions = {
    enable = mkOption {
      default = true;
      description = "default functions";
      type = types.bool;
    };
  };

  config =
    let
      parent = config.m3l6h.${pname};
      enable = parent.enable;
      cfg = parent.functions;
      file = "my-custom/functions.zsh";
    in
    mkIf (enable && cfg.enable) {
      home.file."${custom}/${file}".source = ./functions.zsh;

      programs.zsh.initContent = ''
        source $HOME/${custom}/${file}
      '';
    };
}
