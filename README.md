# nix-additional

This repository contains Nix packages and NixOS modules.

## Packages and modules

### `apple-cursor`

MacOS cursor theme that works on GNOME 51.

See [docs/apple-cursor.md](docs/apple-cursor.md) for setup.

### `blur-my-shell`

GNOME extension that adds a blur look different parts of the GNOME Shell.

See [docs/blur-my-shell.md](docs/blur-my-shell.md) for setup.

### `mactahoe-icon-theme`

MacOS Tahoe icon theme for Linux.

See [docs/mactahoe-icon-theme.md](docs/mactahoe-icon-theme.md) for setup.

### `mssql-server`

Microsoft SQL Server 2025 for Linux.

See [docs/mssql-server.md](docs/mssql-server.md) for setup and options.

## Flake outputs

- `packages.x86_64-linux.apple-cursor`
- `packages.x86_64-linux.blur-my-shell`
- `packages.x86_64-linux.mactahoe-icon-theme`
- `packages.x86_64-linux.mssql-server`
- `nixosModules.default`
- `nixosModules.mssql-server`
- `overlays.apple-cursor`
- `overlays.blur-my-shell`
- `overlays.mactahoe-icon-theme`
- `overlays.mssql-server`
