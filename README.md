# Nix flake for binary distributions of various Go applications

[![built with nix](https://img.shields.io/badge/builtwith-nix-7d81f7?style=flat-square)](https://builtwithnix.org)

Unfortunately, some applications cannot be built with Go 1.18 on darwin ([NixOS/nixpkgs#168984](https://github.com/NixOS/nixpkgs/issues/168984), [NixOS/nixpkgs#169478](https://github.com/NixOS/nixpkgs/issues/169478))
until the [macOS SDK is updated](https://github.com/NixOS/nixpkgs/issues/101229).

This flake relies on official binary distributions for these packages.


## Usage

```nix
{
  description = "Your go package";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gobin.url = "github:sagikazarmark/go-bin-flake";
    gobin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, gobin, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShell = pkgs.mkShell {
          buildInputs = [ pkgs.go gobin.hugo-bin ];
        };
      });
}
```

Or using overlay:

```nix
{
  description = "Your go package";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gobin.url = "github:sagikazarmark/go-bin-flake";
    gobin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, gobin, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;

          overlays = [ gobin.overlay ];
        };
      in {
        devShell = pkgs.mkShell {
          buildInputs = [ pkgs.go pkgs.hugo-bin ];
        };
      });
}
```

## License

The project is licensed under the [MIT License](LICENSE).
