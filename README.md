# vertex

One-click AI agent setup through Google Vertex AI Platform. Currently, this launches **Claude Code** using your Google login[^cc] configured to use the **Claude Sonnet 4.5** model.

[^cc]: See [Claude Code on Google Vertex AI](https://docs.anthropic.com/en/docs/claude-code/google-vertex-ai)

## Usage

### macOS

1. Install Nix [using these instructions](https://nixos.asia/en/install)
1. Run vertex:
  ```sh
  nix run github:juspay/vertex
  ```

> [!TIP]
> If you are a Nix veteran, [nixos-unified-template](https://github.com/juspay/nixos-unified-template) is the best way to install `vertex`. The template already includes `vertex` (be sure to enable the "work" profile) and is configured to use the latest versions of tools. Once you setup your Nix config, run `vertex-claude` to launch it.

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

## Editor support

### Zed

Zed [supports](https://zed.dev/blog/claude-code-via-acp) Claude Code. To have it use our `vertex-claude`:

- First, sucessfully run `vertex-claude` using the instructions above
- Export these environment variables in a terminal:
  ```
  export ANTHROPIC_VERTEX_PROJECT_ID=dev-ai-gamma  # Or, your project.
  export CLAUDE_CODE_USE_VERTEX=1
  ```
- Open Zed from the same terminal (important!). On macOS, you can run `open -a Zed`.


## What `vertex-claude` does

Running `vertex-claude` (or the `nix run ...` command above) launches Claude Code after authenticating using your Google account. You can pass custom arguments to it; for [example](https://www.anthropic.com/engineering/claude-code-best-practices#d-safe-yolo-mode):

```sh
vertex-claude --dangerously-skip-permissions

# Or
nix run github:juspay/vertex -- --dangerously-skip-permissions
```

### Sandboxed mode (Linux only)

For enhanced security, you can run `vertex-claude` in a sandboxed environment using [landrun](https://github.com/srid/landrun-nix):

```sh
nix run github:juspay/vertex#vertex-claude-sandboxed

# You can pass additional arguments:
nix run github:juspay/vertex#vertex-claude-sandboxed -- --verbose
```

This restricts filesystem and network access to only what's necessary for Claude Code to function. The sandbox:
- Automatically runs with `--dangerously-skip-permissions` (safe since filesystem access is already restricted)
- Allows read-write access to your Claude config (`~/.claude`, `~/.claude.json`, `~/.config/gcloud`)
- Allows read-write-execute access to the current directory only
- Enables network access for API calls
- Provides Nix functionality for package management

> [!NOTE]
> When you run `vertex-claude`, it will automatically:
> - Use your only project if you have exactly one
> - Let you choose interactively if you have multiple projects

> [!TIP]
> Google authentication / permission issues? Reset your gcloud config (`rm -rf ~/.config/gcloud`) and try again.


## Goals

Combine `google-cloud-sdk`, `gemini-cli`, `claude-code` (from nixpkgs) to provide a seamless entrypoint to getting AI agents working using Claude Sonnet 4.5 through Google Vertex AI platform (provided by your organization).
