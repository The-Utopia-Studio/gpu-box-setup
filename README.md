# GPU Box Setup

One-command setup for AI development on Ubuntu + NVIDIA GPU machines.

## What's included

- **Node.js 22** + **Claude Code**
- **Python 3.12** + **PyTorch** (CUDA 12.6) + HuggingFace + vLLM
- **Ollama** — run local LLMs
- **Docker** + NVIDIA Container Toolkit
- **JupyterLab, Gradio, FastAPI** — experiments & serving
- **LangChain, W&B, TensorBoard** — building & tracking

## Quick start

```bash
curl -fsSL https://raw.githubusercontent.com/The-Utopia-Studio/gpu-box-setup/main/gpu-box-setup.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/The-Utopia-Studio/gpu-box-setup.git
cd gpu-box-setup
bash gpu-box-setup.sh
```

## Aliases added

| Alias | Command |
|-------|---------|
| `gpu` | `nvidia-smi` |
| `gpuw` | `watch -n1 nvidia-smi` |
| `jl` | Launch JupyterLab on port 8888 |
| `tb` | Launch TensorBoard |
| `serve` | Python HTTP server |
