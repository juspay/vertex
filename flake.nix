{
  description = "Vertex development environment";

  nixConfig = {
    extra-substituters = "https://cache.nixos.asia/oss";
    extra-trusted-public-keys = "oss:KO872wNJkCDgmGN3xy9dT89WAhvv13EiKncTtHDItVU=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      flake.overlays.default = final: prev: {
        vertex-claude = prev.callPackage ./package.nix { };
      };

      perSystem = { pkgs, system, ... }:
        let
          vertex-claude = pkgs.callPackage ./package.nix { };
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfreePredicate = pkg: builtins.elem (pkg.pname or pkg.name or "") [ "claude-code" ];
          };
          
          formatter = pkgs.nixpkgs-fmt;
          
          packages = {
            default = vertex-claude;
          };
          
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              # Add your development dependencies here
              nixd
            ];
            
            shellHook = ''
              echo "Welcome to the Vertex development environment!"
            '';
          };
        };
    };
}
