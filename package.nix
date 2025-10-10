{
  writeShellApplication,
  google-cloud-sdk,
  claude-code,
  gum,
  jq,
}:

let
  vertexRegion = "us-east5";
  modelName = "claude-sonnet-4-5";
  smallModelName = "claude-3-5-haiku";

  select-gcloud-project = writeShellApplication {
    name = "select-gcloud-project";
    runtimeInputs = [ google-cloud-sdk gum jq ];
    text = ''
      set -euo pipefail

      echo "Fetching available Google Cloud projects..." >&2
      if ! PROJECTS_JSON=$(gcloud projects list --format=json); then
        echo "Error: Failed to fetch projects. Please check your gcloud authentication and permissions." >&2
        exit 1
      fi

      PROJECT_LIST=$(echo "$PROJECTS_JSON" | jq -r '.[] | "\(.projectId) - \(.name)"')
      PROJECT_COUNT=$(echo "$PROJECT_LIST" | wc -l | tr -d ' ')

      if [ -z "$PROJECT_LIST" ] || [ "$PROJECT_COUNT" -eq 0 ]; then
        echo "Error: No Google Cloud projects found. Please create a project first." >&2
        exit 1
      elif [ "$PROJECT_COUNT" -eq 1 ]; then
        PROJECT_ID=$(echo "$PROJECT_LIST" | cut -d' ' -f1)
        echo "Using only available project: $PROJECT_ID" >&2
        echo "$PROJECT_ID"
      else
        echo "Select a Google Cloud project:" >&2
        SELECTED_PROJECT=$(echo "$PROJECT_LIST" | gum choose --height=10)
        PROJECT_ID=$(echo "$SELECTED_PROJECT" | cut -d' ' -f1)
        echo "Selected project: $PROJECT_ID" >&2
        echo "$PROJECT_ID"
      fi
    '';
  };
in
writeShellApplication {
  name = "claude";
  runtimeInputs = [ google-cloud-sdk claude-code select-gcloud-project ];
  text = ''
    set -euo pipefail

    # Check if already authenticated
    if ! AUTH_OUTPUT=$(gcloud auth application-default print-access-token 2>&1); then
      echo "$AUTH_OUTPUT" >&2
      echo "Authentication required. Opening browser..."
      gcloud auth login
      # For some reason, we must re-auth
      # cf. https://stackoverflow.com/a/42059661/55246
      gcloud auth application-default login

      # Project selection
      GOOGLE_CLOUD_PROJECT=$(select-gcloud-project)

      gcloud config set project "$GOOGLE_CLOUD_PROJECT"
      gcloud services enable aiplatform.googleapis.com
    else
      echo "Already authenticated with Google Cloud."
      # Get current project
      GOOGLE_CLOUD_PROJECT=$(gcloud config get-value project)
      if [ -z "$GOOGLE_CLOUD_PROJECT" ] || [ "$GOOGLE_CLOUD_PROJECT" = "(unset)" ]; then
        echo "Error: No project configured. Please reset your gcloud config and try again." >&2
        exit 1
      else
        echo "Using configured project: $GOOGLE_CLOUD_PROJECT"
      fi
    fi

    # https://docs.anthropic.com/en/docs/claude-code/google-vertex-ai

    # Enable Vertex AI integration
    export CLAUDE_CODE_USE_VERTEX=1
    export CLOUD_ML_REGION=${vertexRegion}
    export ANTHROPIC_VERTEX_PROJECT_ID="$GOOGLE_CLOUD_PROJECT"

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
    exec claude "$@"
  '';
}
