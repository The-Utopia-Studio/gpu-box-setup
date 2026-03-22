#!/bin/bash
set -e

echo "========================================="
echo "  GPU Box Setup — AI Development Stack"
echo "========================================="

# --- System essentials ---
echo "[1/8] System essentials..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
  build-essential git curl wget unzip htop tmux tree jq \
  software-properties-common ca-certificates gnupg lsof

# --- Node.js 22 (for Claude Code, web apps) ---
echo "[2/8] Node.js 22..."
if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt-get install -y -qq nodejs
fi
echo "Node $(node --version)"

# --- Claude Code ---
echo "[3/8] Claude Code..."
if ! command -v claude &>/dev/null; then
  sudo npm install -g @anthropic-ai/claude-code
fi

# --- Python ML stack ---
echo "[4/8] Python ML environment..."
sudo apt-get install -y -qq python3-pip python3-venv
python3 -m pip install --upgrade pip --break-system-packages

# Use nightly for Blackwell (sm_120) support; cu128 required for driver 580+
python3 -m pip install --break-system-packages --pre \
  torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128

python3 -m pip install --break-system-packages \
  transformers \
  accelerate \
  datasets \
  tokenizers \
  safetensors \
  huggingface-hub \
  bitsandbytes \
  peft \
  trl \
  vllm \
  langchain \
  langchain-community \
  openai \
  anthropic \
  numpy \
  pandas \
  scipy \
  scikit-learn \
  matplotlib \
  seaborn \
  tqdm \
  wandb \
  tensorboard \
  jupyterlab \
  ipywidgets \
  gradio \
  fastapi \
  uvicorn \
  httpx \
  python-dotenv \
  pydantic

# --- Ollama ---
echo "[5/8] Ollama..."
if ! command -v ollama &>/dev/null; then
  curl -fsSL https://ollama.com/install.sh | sh
fi

# --- Docker ---
echo "[6/8] Docker..."
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker $USER
fi

# --- NVIDIA Container Toolkit (GPU in Docker) ---
echo "[7/8] NVIDIA Container Toolkit..."
if ! command -v nvidia-ctk &>/dev/null; then
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
    sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
  curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
  sudo apt-get update -qq
  sudo apt-get install -y -qq nvidia-container-toolkit
  sudo nvidia-ctk runtime configure --runtime=docker
  sudo systemctl restart docker 2>/dev/null || true
fi

# --- Haishare GPU scheduler fix (for cloud GPU pods) ---
echo "[8/9] GPU environment fix..."
if [ -d /var/run/haishare ]; then
  echo "  Detected haishare GPU scheduler — applying env fixes"
  grep -q 'HAISHARE_SCHEDULER_DIR' ~/.bashrc 2>/dev/null || cat >> ~/.bashrc << 'HAISHARE'

# --- GPU Environment Fix (haishare/cloud GPU pods) ---
export HAISHARE_SCHEDULER_DIR=/var/run/haishare/gpu0
export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
HAISHARE
fi

# --- Convenience aliases ---
echo "[9/9] Shell config..."
cat >> ~/.bashrc << 'ALIASES'

# --- AI Dev Aliases ---
alias gpu="nvidia-smi"
alias gpuw="watch -n1 nvidia-smi"
alias jl="jupyter lab --ip=0.0.0.0 --no-browser --port=8888"
alias serve="python3 -m http.server"
alias tb="tensorboard --logdir=./runs --bind_all"
ALIASES

echo ""
echo "========================================="
echo "  Setup complete!"
echo "========================================="
echo ""
echo "Installed:"
echo "  - Node.js $(node --version) + Claude Code"
echo "  - Python $(python3 --version 2>&1 | awk '{print $2}') + PyTorch + HuggingFace + vLLM"
echo "  - Ollama (run: ollama serve & ollama pull llama3)"
echo "  - Docker + NVIDIA Container Toolkit"
echo "  - JupyterLab (run: jl)"
echo "  - Gradio, FastAPI, LangChain, W&B"
echo ""
echo "Aliases: gpu, gpuw, jl, serve, tb"
echo "Restart shell or run: source ~/.bashrc"
