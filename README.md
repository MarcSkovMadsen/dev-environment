# dev-environment

GitHub Codespaces configuration for HoloViz open-source development and personal projects.

## Quick Start

1. Go to [github.com/MarcSkovMadsen/dev-environment](https://github.com/MarcSkovMadsen/dev-environment)
2. Click **Code** > **Codespaces** > **Create codespace on main**
3. Select **8-core / 32GB** machine type
4. Wait for the environment to build (~10 min first time, seconds with prebuilds)
5. Open `dev-environment.code-workspace` for the multi-repo workspace

## What's Included

### Tools

- **pixi** — HoloViz repos (panel, holoviews, param, etc.)
- **uv** — personal projects
- **Node.js 22** — Claude Code CLI, JS-heavy repos
- **Quarto** — blog
- **JupyterLab** — testing
- **gh** — GitHub CLI

### AI

- **Claude Code** CLI (requires Claude Max subscription)
- **GitHub Copilot** (free for open-source contributors)

### Repos Cloned

| Repo | Tool | Org |
|------|------|-----|
| panel, panel-material-ui, holoviews, param, lumen | pixi | holoviz |
| panel-live, panel-reactflow, panel-splitjs, holoviz-mcp, holoviz-agents | pixi | MarcSkovMadsen |
| blog, my_panel_app, holoviz-mcp-ui | uv | MarcSkovMadsen |

## Usage Tips

- **Stop** the Codespace when not in use (retains all state, costs ~$0.07/GB/month for storage)
- **Restart** resumes in seconds with pixi environments intact
- Run `pixi install` in any HoloViz repo to set up its environment
- Run `uv sync` in personal projects to set up their environment
