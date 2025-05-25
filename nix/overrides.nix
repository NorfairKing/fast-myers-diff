{ lib
, haskell
, ...
}:
self: super:
with lib;
with haskell.lib;

{
  fast-myers-diff =
    buildFromSdist (
      overrideCabal (self.callPackage (../fast-myers-diff) { })
        (old: {
          doBenchmark = true;
          configureFlags = (old.configureFlags or [ ]) ++ [
            # Optimisations
            "--ghc-options=-O2"
            # Extra warnings
            "--ghc-options=-Wall"
            "--ghc-options=-Wincomplete-uni-patterns"
            "--ghc-options=-Wincomplete-record-updates"
            "--ghc-options=-Wpartial-fields"
            "--ghc-options=-Widentities"
            "--ghc-options=-Wredundant-constraints"
            "--ghc-options=-Wcpp-undef"
            "--ghc-options=-Wunused-packages"
            "--ghc-options=-Werror"
            "--ghc-options=-Wno-deprecations"
          ];
        })
    );
}
