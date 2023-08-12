{ mkDerivation, base, dlist, hspec, lib, text, vector }:
mkDerivation {
  pname = "fast-myers-diff";
  version = "0.0.0";
  src = ./.;
  libraryHaskellDepends = [ base dlist text vector ];
  testHaskellDepends = [ base hspec text vector ];
  homepage = "https://github.com/NorfairKing/sydtest#readme";
  description = "A fast implementation of the Myers diff algorithm";
  license = lib.licenses.mit;
}
