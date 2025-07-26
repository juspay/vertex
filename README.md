# vertex

WIP: One-click AI agent setup through Google Vertex AI Platform

## Goals

Combine `google-cloud-sdk`, `gemini-cli`, `claude-code` (from nixpkgs) to provide a seamless entrypoint to getting AI agents working using Claude 4 Sonnet through Google Vertex AI platform (provided by your organization).

## Technical Details

- [ ] Do we use bash to script it up, or something else (e.g., Nushell)? Whatever it is, it should provide a pleasant way to write scripts, and integrate well with Nix (`nix run ...`).
- [ ] A single `nix run` should take care of everything.

## Manual workflow

Currenty, we have to do this, but it should be automated:

- To authentication, first run: `gcloud auth application-default login` and check all boxes. Ref: https://stackoverflow.com/a/42059661/55246
- Configure Claude Code to use Vertex AI (use sonnet over opus) https://docs.anthropic.com/en/docs/claude-code/google-vertex-ai
- Test with `claude -p 'What model are you?'` - which should print something like `I'm Claude Sonnet 4 (claude-sonnet-4).` and exit immediately.