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
      
      perSystem = { pkgs, system, ... }: 
        let
          # Configuration - Update these values for your setup
          googleCloudProject = "dev-ai-delta";
          vertexRegion = "us-east5";
          modelName = "claude-sonnet-4";
          smallModelName = "claude-3-5-haiku";
          
          vertex-setup = pkgs.writeShellApplication {
            name = "vertex-setup";
            runtimeInputs = with pkgs; [ google-cloud-sdk claude-code ];
            text = ''
              set -euo pipefail
              
              # Check if already authenticated
              if ! gcloud auth application-default print-access-token &>/dev/null; then
                echo "Authentication required. Opening browser..."
                # gcloud auth application-default login
                gcloud auth login
                gcloud config set project ${googleCloudProject}
                gcloud services enable aiplatform.googleapis.com
              else
                echo "Already authenticated with Google Cloud."
              fi

              # https://docs.anthropic.com/en/docs/claude-code/google-vertex-ai#4-configure-claude-code

              # Enable Vertex AI integration
              export CLAUDE_CODE_USE_VERTEX=1
              export CLOUD_ML_REGION=${vertexRegion}
              export ANTHROPIC_VERTEX_PROJECT_ID=${googleCloudProject}

              # Optional: Disable prompt caching if needed
              export DISABLE_PROMPT_CACHING=1

              # Optional: Override regions for specific models
              export VERTEX_REGION_CLAUDE_3_5_HAIKU=us-central1
              export VERTEX_REGION_CLAUDE_3_5_SONNET=us-east5
              export VERTEX_REGION_CLAUDE_3_7_SONNET=us-east5
              export VERTEX_REGION_CLAUDE_4_0_OPUS=europe-west4
              export VERTEX_REGION_CLAUDE_4_0_SONNET=us-east5

              export ANTHROPIC_MODEL='${modelName}'
              export ANTHROPIC_SMALL_FAST_MODEL='${smallModelName}'

              echo "Launching Claude Code..."
              exec claude
            '';
          };
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfreePredicate = pkg: builtins.elem (pkg.pname or pkg.name or "") [ "claude-code" ];
          };
          
          formatter = pkgs.nixpkgs-fmt;
          
          packages.default = vertex-setup;
          
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