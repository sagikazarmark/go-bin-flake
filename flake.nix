{
  description = "Flake for binary distributions of Go applications";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [
        # "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });
    in
      rec
      {
        overlay = final: prev: with final; {
          # golangci-lint-bin = callPackage ./pkgs/golangci-lint/default.nix {};
          hugo-bin = callPackage ./pkgs/hugo/default.nix {};
        };

        overlays.default = self.overlay;

        overlays.replace = final: prev: {
          hugo = self.overlay.hugo-bin;
        };

        packages = forAllSystems (
          system:
            {
              inherit (nixpkgsFor.${system}) hugo-bin;
            }
        );
      };
}
