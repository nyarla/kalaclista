{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/master"; };
  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShell.${system} = with pkgs;
        (buildFHSUserEnv rec {
          name = "the.kalaclista.com-v5";
          targetPkgs = p:
            with p; [
              cmark
              coreutils
              curl
              esbuild
              gnumake
              imagemagick
              jhead
              libwebp
              libxcrypt
              libxml2.dev
              nodePackages.prettier
              openssl.dev
              optipng
              perl
              perlPackages.Appcpanminus
              perlPackages.Appcpm
              perlPackages.Carton
              perlPackages.XMLLibXML
              perlPackages.locallib
              pkgconfig
              stdenv.cc.cc
              stdenv.cc.libc
            ];

          runScript = writeShellScript "start.sh" ''
            export PATH=$(pwd)/extlib/bin:$PATH
            export PERL5LIB=$(pwd)/extlib/lib/perl5:$(pwd)/app/lib:$(pwd)/lib

            unset IN_NIX_SHELL
            export IN_PERL_SHELL=1

            exec zsh "''${@}"
          '';
        }).env;
    };
}
