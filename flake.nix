{
  description = "m3l6h's custom zsh configuration packaged as a flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
  };

  outputs =
    {
      flake-parts,
      home-manager,
      impermanence,
      ...
    }@inputs:
    let
      systems = [ "x86_64-linux" ];

      custom = ".zsh-custom";
      pname = "zsh";
      version = "0.1.0";

      homeModule = import ./modules {
        inherit custom pname;
      };

      impermanenceModule = impermanence.homeManagerModules.impermanence;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      inherit systems;

      perSystem =
        { pkgs, ... }:
        {
          checks."m3l6h-${pname}-test" =
            let
              module = homeModule;
              test = import ./tests/default.test.nix {
                inherit
                  pname
                  pkgs
                  home-manager
                  module
                  impermanenceModule
                  ;
              };
            in
            pkgs.runCommand "m3l6h-${pname}-test-run"
              {
                nativeBuildInputs = [ test.driver ];
              }
              ''
                touch $out  # Create an empty output file to satisfy Nix
                ${test.driver}/bin/nixos-test-driver
              '';
        };

      flake = {
        inherit homeModule version;
        homeModules.default = homeModule;
      };
    };
}
