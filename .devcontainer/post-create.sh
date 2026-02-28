#!/usr/bin/env bash
set -euo pipefail

echo "=== Setting up HoloViz Dev Environment ==="

# --- System dependencies ---
SYSTEM_PACKAGES=(
  libglib2.0-0
  libatk1.0-0
  libatk-bridge2.0-0
  libnss3
  libnspr4
  libcups2
  libdrm2
  libdbus-1-3
  libatspi2.0-0
  libxcomposite1
  libxdamage1
  libxfixes3
  libxrandr2
  libgbm1
  libxkbcommon0
  libpango-1.0-0
  libcairo2
  libasound2t64
)

missing_packages=()
for package in "${SYSTEM_PACKAGES[@]}"; do
  if ! dpkg -s "$package" >/dev/null 2>&1; then
    missing_packages+=("$package")
  fi
done

if [ "${#missing_packages[@]}" -gt 0 ]; then
  echo "Installing system dependencies: ${missing_packages[*]}..."
  sudo apt-get update
  sudo apt-get install -y "${missing_packages[@]}"
fi

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
# --- Clone repositories ---
REPOS_DIR="/workspaces/"
mkdir -p "$REPOS_DIR"

echo "Using REPOS_DIR: $REPOS_DIR"

# HoloViz repos (pixi-based)
REPOS=(
  "holoviz/panel"
  "holoviz/panel-material-ui"
  "holoviz/holoviews"
  "holoviz/param"
  "holoviz/lumen"
  "panel-extensions/panel-live"
  "panel-extensions/panel-reactflow"
  "panel-extensions/panel-splitjs"
  "MarcSkovMadsen/holoviz-mcp"  
  "MarcSkovMadsen/blog"
  "MarcSkovMadsen/holoviz-mcp"
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
for repo in "${REPOS[@]}"; do
  clone_repo_if_available "$repo"
done

echo "=== Setup complete! ==="
echo "Open the workspace file: dev-environment.code-workspace"
