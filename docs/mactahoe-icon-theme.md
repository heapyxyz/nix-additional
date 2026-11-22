# `mactahoe-icon-theme`

This repo provides the macOS Tahoe icon theme for Linux. It installs the `MacTahoe`, `MacTahoe-dark`, and `MacTahoe-light` themes.

## Add the overlay

Add this repo as a flake input:

```nix
{
  inputs.nix-additional.url = "github:heapyxyz/nix-additional";
}
```

Then apply the overlay in your NixOS configuration:

```nix
{ inputs, ... }:

{
  nixpkgs.overlays = [ inputs.nix-additional.overlays.mactahoe-icon-theme ];

  environment.systemPackages = [ pkgs.mactahoe-icon-theme ];
  # select one of the installed themes, for example:
  # org.gnome.desktop.interface icon-theme = "MacTahoe-dark";
}
```

## Package

Build the package directly:

```bash
nix build .#mactahoe-icon-theme
```

To use the package from the overlay:

```nix
nixpkgs.overlays = [ inputs.nix-additional.overlays.mactahoe-icon-theme ];
# pkgs.mactahoe-icon-theme
```

## Options

| Option     | Default | Meaning                           |
| ---------- | ------- | --------------------------------- |
| `withBold` | `false` | Install bold panel icons version. |

Enable it when calling the package:

```nix
(pkgs.mactahoe-icon-theme.override { withBold = true; })
```

## Notes

- Built from `vinceliuice/MacTahoe-icon-theme` with a pinned revision.
- Unwanted theme inheritance is removed and icon caches are generated during install.
