{ custom, pname, ... }:
{
  config,
  lib,
  ...
}:
with lib;
{
  options.m3l6h.${pname}.aliases = {
    enable = mkOption {
      default = true;
      description = "default aliases";
      type = types.bool;
    };
  };

  config =
    let
      parent = config.m3l6h.${pname};
      enable = parent.enable;
      cfg = parent.aliases;
    in
    mkIf (enable && cfg.enable) {
      home.file."${custom}/my-custom/aliases.zsh".source = ./aliases.zsh;
    };
}
