{
  description = "Vertex development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        formatter.default = pkgs.nixpkgs-fmt;
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