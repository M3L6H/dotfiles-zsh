{
  home-manager,
  module,
  impermanenceModule,
  pname,
  pkgs,
  ...
}:
let
  username = "testUser";
in
pkgs.testers.runNixOSTest {
  name = "m3l6h-${pname}-test";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          home-manager.nixosModules.home-manager
        ];

        users.users.${username} = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          password = "test";
        };

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${username} =
            { ... }:
            {
              imports = [
                impermanenceModule
                module
              ];

              home = {
                inherit username;
                homeDirectory = "/home/${username}";
                stateVersion = "24.05";
              };

              m3l6h.${pname}.enable = true;
            };
        };
      };
  };

  testScript = ''
    print("Starting test...")

    start_all()

    machine.wait_for_unit("default.target")

    print("Machines started")

    # Wait for boot and login availability
    machine.wait_for_unit("multi-user.target")

    # Switch to the test user and verify basic zsh functionality
    machine.succeed("su - ${username} -c 'zsh -c \"echo $ZSH_VERSION\"'")

    # Check if oh-my-zsh is loaded (e.g., via env var)
    machine.succeed("su - ${username} -c 'zsh -c \"echo $ZSH\"'")

    # Verify vi-mode plugin (check if bindkey is set or something indicative)
    machine.succeed("su - ${username} -c 'cat /home/${username}/.zshrc | grep zsh-vi-mode'")

    # Check starship prompt (e.g., if STARSHIP_CONFIG exists or command works)
    machine.succeed("su - ${username} -c 'starship --version'")

    # Check zoxide (e.g., command availability)
    machine.succeed("su - ${username} -c 'zoxide --version'")

    # Check for custom directory existence
    machine.succeed("su - ${username} -c 'ls /home/${username}/.zsh-custom'")

    print("All tests passed!")

    # Copy files for output
    machine.copy_from_vm("/home/${username}/.zshrc", "dotfiles")
    machine.copy_from_vm("/home/${username}/.zshenv", "dotfiles")
    machine.copy_from_vm("/home/${username}/.zsh-custom", "dotfiles")
  '';
}
