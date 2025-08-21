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

      home.persistence."/persist/home/${config.home.username}" = mkIf parent.impermanence.enable {
        directories = [
          ".local/share/zoxide"
        ];

        allowOther = false;
      };
    };
}
