# Blur my Shell

This repo provides the Blur my Shell GNOME Shell extension, newer than the version currently in nixpkgs.

## Add the Overlay

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
  nixpkgs.overlays = [ inputs.nix-additional.overlays.blur-my-shell ];
  # you can also use pkgs.blur-my-shell
  environment.systemPackages = [ pkgs.gnomeExtensions.blur-my-shell ];
}
```

The overlay replaces `pkgs.gnomeExtensions.blur-my-shell`, so existing references keep working.

## Package

Build the package directly:

```bash
nix build .#blur-my-shell
```

To use the package from the overlay:

```nix
nixpkgs.overlays = [ inputs.nix-additional.overlays.blur-my-shell ];
# pkgs.blur-my-shell
# pkgs.gnomeExtensions.blur-my-shell
```

## Notes

- The extension is built from extensions.gnome.org, with its metadata pinned so the hash stays stable.
- If the extension shows an error after updating, restart the GNOME session. The extension author notes this is a GNOME Shell bug.
