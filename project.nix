let
  pins = {
    # merge of https://github.com/NixOS/nixpkgs/pull/401526
    nixpkgs = builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/a9245b8f22bb81675d374aed93736930f5109503.tar.gz";
      sha256 = "sha256:0jcnmb0smaqz7fiyzc51n2cyn9s81h3j285wv47bxifk0rvavca2";
    };
  };
  defaultNixpkgs = import pins.nixpkgs {};
  cachedPackageSet = "ghc" + builtins.replaceStrings ["."] [""] defaultNixpkgs.haskellPackages.ghc.version;

in { version ? cachedPackageSet }:

  let
    config = {
      packageOverrides = nixpkgs: {
        haskell = nixpkgs.haskell // {
          packages = nixpkgs.haskell.packages // {
            "${version}" = nixpkgs.haskell.packages.${version}.override(old: {
              overrides = self: super: {
                skeleton = self.callCabal2nix "skeleton" ./skeleton {};
              };
            });
          };
        };
      };
    };

  in rec {
    nixpkgs = import pins.nixpkgs {
      inherit config;
    };

    buildWith = pkgSet: with pkgSet.haskell.packages.${version}; {
      inherit skeleton;
    };

    shell = nixpkgs.haskell.packages.${version}.shellFor {
      packages = p: with p; [ skeleton ];
      strictDeps = true;
      withHoogle = true;
      nativeBuildInputs = with nixpkgs; [
        cabal-install
        ghcid
        haskell-language-server
        hlint
        haskellPackages.weeder
      ];
    };
  }
