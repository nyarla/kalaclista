{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/master"; };
  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      cpanfile = import ./cpanfile.nix { inherit pkgs; };
    in {
      devShell.${system} = with pkgs;
        mkShell rec {
          name = "the.kalaclista.com-v5";
          packages = [ perl gnumake curl coreutils imagemagick ] ++ cpanfile;
        };
    };
}
