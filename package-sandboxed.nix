{
  writeShellApplication,
  landrun,
  vertex-claude,
  lib,
}:

(writeShellApplication {
  name = "vertex-claude-sandboxed";
  runtimeInputs = [ landrun ];
  text = ''
    set -euo pipefail

    echo "Launching Claude Code in sandboxed environment..."

    # Run vertex-claude with landrun sandbox
    exec landrun \
      --rw "$HOME/.claude" \
      --rw "$HOME/.claude.json" \
      --rw "$HOME/.config/gcloud" \
      `# Claude Code config and state files` \
      --rw /dev/null \
      --rw /dev/tty \
      --rw /dev/pts \
      --rw /dev/ptmx \
      `# Terminal devices for interactive CLI` \
      --rox /dev/zero \
      --rox /dev/full \
      --rox /dev/random \
      --rox /dev/urandom \
      `# Standard devices needed by various tools` \
      --rox /usr \
      --rox /lib \
      --rox /lib64 \
      `# System binaries and libraries` \
      --rox /nix/store \
      `# Nix store for all Nix-installed packages` \
      --rox /etc/resolv.conf \
      `# DNS resolution` \
      --rox /etc/ssl \
      `# SSL certificates for HTTPS` \
      --rox /etc/terminfo \
      --rox /usr/share/terminfo \
      `# Terminal capability databases for proper rendering` \
      --rox "$(which gcloud)" \
      `# Google Cloud SDK binary` \
      --env PATH \
      --env HOME \
      --env TERM \
      --env SHELL \
      --env COLORTERM \
      --env LANG \
      --env LC_ALL \
      `# Environment variables for shell, terminal, and locale` \
      --unrestricted-network \
      `# Full network access for API calls and authentication` \
      --add-exec \
      `# Automatically add executable path to --rox` \
      --rwx . \
      `# Read-write-execute access to current directory` \
      --rw /tmp \
      `# Temporary file access` \
      ${vertex-claude}/bin/claude --dangerously-skip-permissions "$@"
  '';
}) // {
  meta = {
    description = "Claude Code for Google Vertex AI running in a sandboxed landrun environment";
  };
}
