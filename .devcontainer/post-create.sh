#!/usr/bin/env bash
set -euo pipefail

echo "=== Setting up HoloViz Dev Environment ==="

# --- Git configuration ---
git config --global user.name "Marc Skov Madsen"
git config --global user.email "marc.skov.madsen@gmail.com"

# --- Install pixi ---
echo "Installing pixi..."
curl -fsSL https://pixi.sh/install.sh | bash
export PATH="$HOME/.pixi/bin:$PATH"
echo 'export PATH="$HOME/.pixi/bin:$PATH"' >> "$HOME/.bashrc"

# --- Install uv ---
echo "Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

# --- Install Claude Code CLI ---
echo "Installing Claude Code CLI..."
npm install -g @anthropic-ai/claude-code

# --- Install Quarto ---
echo "Installing Quarto..."
QUARTO_VERSION="1.6.43"
wget -q "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" -O /tmp/quarto.deb
sudo dpkg -i /tmp/quarto.deb
rm /tmp/quarto.deb

# --- Install JupyterLab ---
echo "Installing JupyterLab..."
pip install jupyterlab jupyter_bokeh ipykernel

# --- Clone repositories ---
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"
DEV_ENV_DIR="$(dirname "$SCRIPT_DIR")"
DEFAULT_REPOS_DIR="$(cd "$DEV_ENV_DIR/.." && pwd)/repos"
REPOS_DIR="${REPOS_DIR:-$DEFAULT_REPOS_DIR}"
mkdir -p "$REPOS_DIR"

# HoloViz repos (pixi-based)
HOLOVIZ_REPOS=(
  "holoviz/panel"
  "holoviz/panel-material-ui"
  "holoviz/holoviews"
  "holoviz/param"
  "holoviz/lumen"
  "MarcSkovMadsen/panel-live"
  "MarcSkovMadsen/panel-reactflow"
  "MarcSkovMadsen/panel-splitjs"
  "MarcSkovMadsen/holoviz-mcp"
  "MarcSkovMadsen/holoviz-agents"
)

# Personal repos (uv-based)
PERSONAL_REPOS=(
  "MarcSkovMadsen/blog"
  "MarcSkovMadsen/my_panel_app"
  "MarcSkovMadsen/holoviz-mcp-ui"
)

clone_repo_if_available() {
  local repo="$1"
  local name target_dir
  name="$(basename "$repo")"
  target_dir="$REPOS_DIR/$name"

  if [ -d "$target_dir" ]; then
    echo "  Skipping $repo (already exists at $target_dir)"
    return
  fi

  if ! gh repo view "$repo" >/dev/null 2>&1; then
    echo "  Warning: Skipping $repo (not found or no access)"
    return
  fi

  echo "  Cloning $repo..."
  gh repo clone "$repo" "$target_dir" -- --depth 1 || echo "  Warning: Failed to clone $repo"
}

echo "Cloning HoloViz repos..."
for repo in "${HOLOVIZ_REPOS[@]}"; do
  clone_repo_if_available "$repo"
done

echo "Cloning personal repos..."
for repo in "${PERSONAL_REPOS[@]}"; do
  clone_repo_if_available "$repo"
done

# --- Set up fork remotes for HoloViz repos ---
echo "Setting up fork remotes..."
for repo in "panel" "holoviews" "param" "lumen" "panel-material-ui"; do
  if [ -d "$REPOS_DIR/$repo" ]; then
    (
      cd "$REPOS_DIR/$repo"
      gh repo fork --remote-only 2>/dev/null || true
    )
  fi
done

echo "=== Setup complete! ==="
echo "Open the workspace file: dev-environment.code-workspace"
