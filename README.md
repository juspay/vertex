# vertex

One-click AI agent setup through Google Vertex AI Platform. Currently, this launches **Claude Code** using your Google login[^cc] configured to use the **Claude Sonnet 4** model.

[^cc]: See [Claude Code on Google Vertex AI](https://docs.anthropic.com/en/docs/claude-code/google-vertex-ai)

## Usage

[Install Nix](https://nixos.asia/en/install), and then:

```sh
nix run github:juspay/vertex
```

This will launch Claude Code after authenticating using your Google account. You can pass custom arguments after `--`; for [example](https://www.anthropic.com/engineering/claude-code-best-practices#d-safe-yolo-mode):

```sh
nix run github:juspay/vertex -- --dangerously-skip-permissions
```

> [!NOTE]
> When you run `vertex`, it will automatically:
> - Use your only project if you have exactly one
> - Let you choose interactively if you have multiple projects

> [!TIP]
> Google authentication / permission issues? Reset your gcloud config (`rm -rf ~/.config/gcloud`) and try again.

### NixOS

To use this on NixOS, add the following to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    vertex = {
      url = "github:juspay/vertex";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, vertex, ... }: {
    # Your NixOS configuration
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # or your system
      modules = [
        # Your existing modules
        {
          environment.systemPackages = [
            vertex.packages.x86_64-linux.default # or your system
          ];
        }
      ];
    };
  };
}
```

Then run `sudo nixos-rebuild switch` and use `vertex-claude` command.

## Goals

Combine `google-cloud-sdk`, `gemini-cli`, `claude-code` (from nixpkgs) to provide a seamless entrypoint to getting AI agents working using Claude 4 Sonnet through Google Vertex AI platform (provided by your organization).
