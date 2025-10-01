# dotfiles-zsh

Nix-based repository containing my zsh configuration.

Provides both a home-manager module and dotfiles for easy consumption.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [features](#features)
- [development](#development)
  - [dotfiles](#dotfiles)
  - [testing](#testing)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## features

- [oh my zsh](https://ohmyz.sh)
- [starship prompt](https://starship.rs)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode)

## development

All modules have been defined in the `modules/` folder.

### dotfiles

Generate dotfiles with:

```sh
nix build .#packages.x86_64-linux.m3l6h-zsh-build-dotfiles
./result/bin/nixos-test-drive
./scripts/sanitize-dotfiles.sh
```

### testing

Run check tests with:

```sh
nix flake check
```

View test results with:

```sh
nix-store --read-log result
```

Perform interactive testing with:

```sh
nix build .#checks.x86_64-linux.m3l6h-zsh-test.driverInteractive

```
