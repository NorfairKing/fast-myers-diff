{
  description = "fast-myers-diff";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-26.05";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    nixpkgs-25_11.url = "github:NixOS/nixpkgs?ref=nixos-25.11";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-25_11
    , pre-commit-hooks
    }:
    let
      system = "x86_64-linux";
      nixpkgsFor = nixpkgs: import nixpkgs { inherit system; config.allowUnfree = true; };
      pkgs = nixpkgsFor nixpkgs;
      haskellPackagesFor = nixpkgs: (nixpkgsFor nixpkgs).haskellPackages.extend (
        pkgs.lib.composeManyExtensions [
          self.overrides.${system}
        ]
      );
      haskellPackages = haskellPackagesFor nixpkgs;
    in
    {
      overrides.${system} = pkgs.callPackage ./nix/overrides.nix { };
      overlays.${system} = import ./nix/overlay.nix;
      packages.${system}.default = haskellPackages.fast-myers-diff;
      checks.${system} =
        let
          backwardCompatibilityCheckFor = nixpkgs: (haskellPackagesFor nixpkgs).fast-myers-diff;
          allNixpkgs = {
            inherit
              nixpkgs-25_11;
          };
          backwardCompatibilityChecks = pkgs.lib.mapAttrs (_: nixpkgs: backwardCompatibilityCheckFor nixpkgs) allNixpkgs;
        in
        backwardCompatibilityChecks // {
          release = self.packages.${system}.default;
          shell = self.devShells.${system}.default;
          pre-commit = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              hlint.enable = true;
              hpack.enable = true;
              ormolu.enable = true;
              nixpkgs-fmt.enable = true;
              nixpkgs-fmt.excludes = [ ".*/default.nix" ];
              cabal2nix.enable = true;
            };
          };
        };
      devShells.${system}.default = haskellPackages.shellFor {
        name = "fast-myers-diff-shell";
        packages = p: [ p.fast-myers-diff ];
        withHoogle = true;
        doBenchmark = true;
        buildInputs = with pkgs; [
          cabal-install
          zlib
        ] ++ self.checks.${system}.pre-commit.enabledPackages;
        shellHook = self.checks.${system}.pre-commit.shellHook;
      };
    };
}
