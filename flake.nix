{
  description = "Interact with Railway via CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/22.11";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.follows = "rust-overlay/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.follows = "rust-overlay/nixpkgs";
  };

  outputs = inputs: with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        toolchain = pkgs.rust-bin.stable.latest.default;
        naersk' = pkgs.callPackage naersk {
          cargo = toolchain;
          rustc = toolchain;
        };
        code = naersk'.buildPackage {
          name = "railway";
          src = ./.;
        };
      in
      rec {
        packages = {
          cli = code;
          default = packages.cli;
        };
        devShells.default =
          import ./shell.nix { inherit pkgs; };
      }
    );
}
