# nix-additional

This repository contains Nix packages and NixOS modules.

## Packages and Modules

### `mssql-server`

Microsoft SQL Server 2025 for Linux.

See [docs/mssql-server.md](docs/mssql-server.md) for setup and options.

### `blur-my-shell`

GNOME extension that adds a blur look different parts of the GNOME Shell.

See [docs/blur-my-shell.md](docs/blur-my-shell.md) for setup.

## Flake Outputs

- `packages.x86_64-linux.blur-my-shell`
- `packages.x86_64-linux.mssql-server`
- `nixosModules.default`
- `nixosModules.mssql-server`
- `overlays.blur-my-shell`
- `overlays.mssql-server`
