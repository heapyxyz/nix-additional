# Microsoft SQL Server

This repo provides Microsoft SQL Server 2025 as a Nix package and a NixOS module.

It only works on `x86_64-linux`. The package is unfree, so you need to allow unfree packages.

## Add the Module

Add this repo as a flake input:

```nix
{
  inputs.nix-additional.url = "github:heapyxyz/nix-additional";
}
```

Then enable the module in your NixOS configuration:

```nix
{ inputs, ... }:

{
  imports = [ inputs.nix-additional.nixosModules.mssql-server ];

  nixpkgs.config.allowUnfree = true;

  services.mssql-server = {
    enable = true;
    saPasswordFile = "/var/lib/secrets/mssql-sa";
  };
}
```

## First Start

The module creates the `mssql` user and the data directories. On the first boot, it also sets up the database automatically.

Create the SA password file before the first boot:

```bash
sudo install -d -m 700 /var/lib/secrets
sudo sh -c 'umask 077; printf "%s\n" "ChangeMe!12345" > /var/lib/secrets/mssql-sa'
```

The file must be readable by root and must not be stored in the Nix store. Keep it out of Git.

The password must follow the SQL Server rules: at least 8 characters and at least three of these four groups: uppercase letters, lowercase letters, digits, and symbols.

After setup, the module starts `mssql-server.service`. You can check it with:

```bash
sudo systemctl status mssql-server
sudo journalctl -u mssql-server
```

The first start can take a few minutes.

## Options

| Option           | Default       | Meaning                                                   |
| ---------------- | ------------- | --------------------------------------------------------- |
| `enable`         | `false`       | Start SQL Server.                                         |
| `saPasswordFile` | `null`        | Path to the SA password file. Needed for the first start. |
| `edition`        | `"Developer"` | SQL Server edition or a 25-character product key.         |
| `port`           | `1433`        | TCP port for SQL Server.                                  |

If `saPasswordFile` is `null`, the automatic setup is skipped. You must then initialize SQL Server yourself.

## Package

Build the package directly:

```bash
nix build .#mssql-server
```

To use the package from the overlay:

```nix
nixpkgs.overlays = [ inputs.nix-additional.overlays.mssql-server ];
# pkgs.mssql-server
```

The module links the package to `/opt/mssql`, so tools such as `/opt/mssql/bin/mssql-conf` work.

## Notes

- Open the firewall yourself if you need remote access. For example: `networking.firewall.allowedTCPPorts = [ 1433 ];`
- The default `Developer` edition is for development and testing. Check the Microsoft license before using another edition in production.
- The package builds and the module evaluates, but the first-run setup has not been tested in a VM yet.
