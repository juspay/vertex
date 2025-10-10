{
  description = "Vertex development environment";

  nixConfig = {
    extra-substituters = "https://cache.nixos.asia/oss";
    extra-trusted-public-keys = "oss:KO872wNJkCDgmGN3xy9dT89WAhvv13EiKncTtHDItVU=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    landrun-nix.url = "github:srid/landrun-nix";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      imports = [ inputs.landrun-nix.flakeModule ];

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

          landrunApps.vertex-claude-sandboxed = {
            program = "${vertex-claude.overrideAttrs (old: {
              postBuild = (old.postBuild or "") + ''
                wrapProgram $out/bin/claude \
                  --add-flags "--dangerously-skip-permissions"
              '';
            })}/bin/claude";
            features = {
              tty = true;
              nix = true;
              network = true;
            };
            cli = {
              rw = [
                "$HOME/.claude"
                "$HOME/.claude.json"
                "$HOME/.config/gcloud"
              ];
              rwx = [ "." ];
              env = [
                "HOME"  # Needed for gcloud and claude to resolve ~/ paths for config/state files
              ];
            };
            meta.description = "Claude Code for Google Vertex AI running in a sandboxed landrun environment";
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
