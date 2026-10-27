{ pkgs }:

{
  mssql-server = pkgs.callPackage ./mssql-server.nix { };
}
