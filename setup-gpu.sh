#!/bin/bash

# Get absolute path of this script
SCRIPT_PATH="$(realpath "$0")"

# If not inside tmux, launch the script inside a new tmux session
if [ -z "$TMUX" ]; then
  SESSION_NAME="setup"
  tmux new-session -s "$SESSION_NAME" "bash '$SCRIPT_PATH'; bash"
  exit 0
fi

# --- Inside tmux session from here on ---
echo "🛠️ Running setup inside tmux session '$TMUX'..."

# System setup
sudo apt update
sudo apt --fix-broken install -y
sudo apt autoremove -y
sudo apt install -y tmux curl

# Tmux config
curl -o ~/.tmux.conf https://raw.githubusercontent.com/hossein-khalilian/server-setup/main/.tmux.conf
tmux source-file ~/.tmux.conf

# Neovim config
mkdir -p ~/.config
cd ~/.config
[ ! -d "nvim" ] && git clone https://github.com/hossein-khalilian/nvim-config.git nvim
cd nvim
./pre-installation.sh || true
source ~/.bashrc

# JupyterLab Compose setup
mkdir -p ~/projects/hse/git
cd ~/projects/hse/git
[ ! -d "jupyterlab-compose" ] && git clone https://github.com/hossein-khalilian/jupyterlab-compose.git
cd jupyterlab-compose/
docker compose -f docker-compose-gpu.yml up -d

# Python virtualenv
sudo apt install python3-virtualenv -y
[ ! -d "$HOME/projects/hse/venv2" ] && virtualenv "$HOME/projects/hse/venv2"
source "$HOME/projects/hse/venv2/bin/activate"

# 🟢 End message
echo "✅ Setup complete.
