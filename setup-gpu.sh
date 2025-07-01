#!/bin/bash

# Check if already inside tmux
if [ -z "$TMUX" ]; then
  # Not in tmux, start a new session and run this script inside it
  SESSION_NAME="setup"
  SCRIPT_PATH="$(realpath "$0")"
  tmux new-session -s "$SESSION_NAME" "$SCRIPT_PATH"
  exit 0
fi

# --- From here on, you are inside tmux ---
echo "Running setup inside tmux session."

# Update and install packages
sudo apt update
sudo apt --fix-broken install -y
sudo apt autoremove -y
sudo apt install -y tmux curl

# Load tmux config
curl -o ~/.tmux.conf https://raw.githubusercontent.com/hossein-khalilian/server-setup/main/.tmux.conf
tmux source-file ~/.tmux.conf

# Set up nvim config
mkdir -p ~/.config
cd ~/.config
[ ! -d "nvim" ] && git clone https://github.com/hossein-khalilian/nvim-config.git nvim
cd nvim
./pre-installation.sh || true
source ~/.bashrc

# Clone and run JupyterLab Compose
mkdir -p ~/projects/hse/git
cd ~/projects/hse/git
[ ! -d "jupyterlab-compose" ] && git clone https://github.com/hossein-khalilian/jupyterlab-compose.git
cd jupyterlab-compose/
docker compose -f docker-compose-gpu.yml up -d

# Create and activate virtual environment
[ ! -d "$HOME/projects/hse/venv2" ] && virtualenv "$HOME/projects/hse/venv2"
source "$HOME/projects/hse/venv2/bin/activate"
