# nix-additional

This repository contains Nix packages and NixOS modules.

## Packages

### `mssql-server`

Microsoft SQL Server 2025 for `x86_64-linux`.

The package is unfree. Set `nixpkgs.config.allowUnfree = true` before you use it.

Build it with:

```bash
nix build .#mssql-server
```

## Modules

### `services.mssql-server`

Runs SQL Server and can set up the database on first boot.

See [docs/mssql-server.md](docs/mssql-server.md) for setup and options.

## Flake Outputs

- `packages.x86_64-linux.mssql-server`
- `nixosModules.default`
- `nixosModules.mssql-server`
- `overlays.default`
- `overlays.mssql-server`

There is no `packages.default` alias. Build the package by name.
