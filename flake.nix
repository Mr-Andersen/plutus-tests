{
  inputs = {
    plutip.url = "path:/home/aka_dude/Work/mlabs/plutip";
    nixpkgs.follows = "plutip/nixpkgs";
    haskell-nix.follows = "plutip/haskell-nix";
    # bot-plutus-interface.follows = "plutip/bot-plutus-interface";
    # iohk-nix.follows = "plutip/iohk-nix";
    plutus.follows = "plutip/bot-plutus-interface/plutus";
    flake-utils.url = "github:numtide/flake-utils";
    # flake-compat = {
    #   url = "github:edolstra/flake-compat";
    #   flake = false;
    # };
  };

  outputs = { self, nixpkgs, haskell-nix, plutus, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
      let overlays =
            [ haskell-nix.overlay
              (final: prev: {
                plutus-tests =
                  final.haskell-nix.project' {
                    src = ./.;
                    compiler-nix-name = "ghc921";
                    shell.tools = {
                      cabal = {};
                      # hlint = {};
                      # haskell-language-server = {};
                    };

                    # Non-Haskell shell tools go here
                    # shell.buildInputs = with pkgs; [
                    #   nixpkgs-fmt
                    # ];

                    # This adds `js-unknown-ghcjs-cabal` to the shell.
                    # shell.crossPlatforms = p: [p.ghcjs];
                    modules = [{
                      reinstallableLibGhc = true;
                    }];
                  };
                })
            ];
	        pkgs = import nixpkgs { inherit system overlays; inherit (haskell-nix) config; };
          flake = pkgs.plutus-tests.flake {
            # This adds support for `nix build .#js-unknown-ghcjs-cabal:hello:exe:hello`
            # crossPlatforms = p: [p.ghcjs];
          };
     in
    flake // {
      packages.default = flake.packages."plutus-tests:test:plutus-tests";
    });
}
