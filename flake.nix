{
  description = "heapy's NixOS packages and modules";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }
          )
        );
    in
    {
      packages = forAllSystems (pkgs: import ./packages { inherit pkgs; });

      nixosModules = {
        default = import ./modules;
        mssql-server = import ./modules/mssql-server.nix;
      };

      overlays = {
        default = final: prev: import ./packages { pkgs = final; };
        mssql-server = final: prev: {
          mssql-server = final.callPackage ./packages/mssql-server.nix { };
        };
      };
    };
}
