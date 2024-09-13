{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };
  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShell.${system} =
        with pkgs;
        (buildFHSUserEnv {
          name = "the.kalaclista.com-v5";
          targetPkgs =
            p: with p; [
              coreutils
              esbuild
              gnumake
              imagemagick
              libidn
              libidn.dev
              libwebp
              libxcrypt
              libxml2.dev
              minify
              nodePackages.prettier
              nodePackages.pnpm
              nodejs
              openssl.dev
              perl
              perlPackages.Appcpanminus
              perlPackages.Appcpm
              perlPackages.Carton
              perlPackages.XMLLibXML
              perlPackages.locallib
              pkg-config
              stdenv.cc.cc
              stdenv.cc.libc
            ];

          runScript = writeShellScript "start.sh" ''
            export PATH=$(pwd)/local/bin:$(pwd)/node_modules/.bin:$PATH
            export PERL5LIB=$(pwd)/local/lib/perl5:$(pwd)/app/lib:$(pwd)/lib:$PERL5LIB

            unset IN_NIX_SHELL
            export IN_PERL_SHELL=1

            exec zsh "''${@}"
          '';
        }).env;
    };
}
