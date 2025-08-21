{ pname, ... }:
{
  config,
  lib,
  ...
}:
with lib;
{
  options.m3l6h.${pname}.starship = {
    enable = mkOption {
      default = true;
      description = "starship prompt";
      type = types.bool;
    };
  };

  config =
    let
      parent = config.m3l6h.${pname};
      enable = parent.enable;
      cfg = parent.starship;
    in
    mkIf (enable && cfg.enable) {
      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          character = {
            success_symbol = "[󰚩 ](bold green)";
            error_symbol = "[󱚝 ](bold red)";
          };
          continuation_prompt = "[󱚟 ](bold yellow)";
          format = "$all$character";
        };
      };
    };
}
