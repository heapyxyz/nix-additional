# `apple-cursor`

This repo provides a macOS cursor theme that works on GNOME 51. GNOME 51 draws cursors from `cursors_scalable/` which the nixpkgs package does not ship.

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
  nixpkgs.overlays = [ inputs.nix-additional.overlays.apple-cursor ];
  # you can also use pkgs.apple-cursor
}
```

## Package

Build the package directly:

```bash
nix build .#apple-cursor
```

To use the package from the overlay:

```nix
nixpkgs.overlays = [ inputs.nix-additional.overlays.apple-cursor ];
# pkgs.apple-cursor
```

## Notes

- Installs the theme as `macOS` under `share/icons`, matching the nixpkgs package name.
- Select it with GNOME Tweaks or `org.gnome.desktop.interface cursor-theme = "macOS";`.
- Built from `Neutrovertido/macOS-monterey-cursor` because the original package does not ship scalable cursors.
