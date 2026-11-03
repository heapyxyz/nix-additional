{ pkgs }:

{
  blur-my-shell = pkgs.callPackage ./blur-my-shell.nix { };
  mssql-server = pkgs.callPackage ./mssql-server.nix { };
}
