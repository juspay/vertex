# vertex

One-click AI agent setup through Google Vertex AI Platform

## Usage

[Install Nix](https://nixos.asia/en/install), and then:

```sh
nix run github:juspay/vertex
```

## NixOS

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
