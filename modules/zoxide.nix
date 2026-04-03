{ pname, ... }:
{
  config,
  lib,
  ...
}:
with lib;
{
  options.m3l6h.${pname}.zoxide = {
    enable = mkOption {
      default = true;
      description = "zoxide";
      type = types.bool;
    };
  };

  config =
    let
      parent = config.m3l6h.${pname};
      enable = parent.enable;
      cfg = parent.zoxide;
    in
    mkIf (enable && cfg.enable) {
      programs.zoxide.enable = true;

      programs.zsh.envExtra = ''
        export ZOXIDE_CMD_OVERRIDE='cd'
      '';

      home = optionalAttrs parent.impermanence.enable {
        persistence."/persist".directories = [
          ".local/share/zoxide"
        ];
      };
    };
}
