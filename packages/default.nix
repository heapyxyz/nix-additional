{ pkgs }:

{
  apple-cursor = pkgs.callPackage ./apple-cursor.nix { };
  blur-my-shell = pkgs.callPackage ./blur-my-shell.nix { };
  mssql-server = pkgs.callPackage ./mssql-server.nix { };
}
