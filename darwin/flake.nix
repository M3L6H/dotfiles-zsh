{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:nix-darwin/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      darwin,
      nixpkgs,
    }:
    let
      inherit (darwin.lib) darwinSystem;
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages."${system}";
      linuxSystem = builtins.replaceStrings [ "darwin" ] [ "linux" ] system;

      darwin-builder = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        modules = [
          "${nixpkgs}/nixos/modules/profiles/nix-builder-vm.nix"
          {
            virtualisation = {
              host.pkgs = pkgs;
              darwin-builder.workingDirectory = "/var/lib/darwin-builder";
              darwin-builder.hostPort = 22;
            };
          }
        ];
      };

      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.vim
          ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = system;
        };
    in
    {
      darwinConfigurations."simple" = darwinSystem {
        inherit system;
        modules = [
          (
            configuration
            // {
              nix.distributedBuilds = true;
              nix.buildMachines = [
                {
                  hostName = "localhost";
                  sshUser = "builder";
                  sshKey = "/etc/nix/builder_ed25519";
                  system = linuxSystem;
                  maxJobs = 4;
                  supportedFeatures = [
                    "kvm"
                    "benchmark"
                    "big-parallel"
                  ];
                }
              ];

              launchd.daemons.darwin-builder = {
                command = "${darwin-builder.config.system.build.macos-builder-installer}/bin/create-builder";
                serviceConfig = {
                  KeepAlive = true;
                  RunAtLoad = true;
                  StandardOutPath = "/var/log/darwin-builder.log";
                  StandardErrorPath = "/var/log/darwin-builder.log";
                };
              };
            }
          )
        ];
      };
    };
}
