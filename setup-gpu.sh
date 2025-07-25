#!/bin/bash

set -e

# Get absolute path of this script
SCRIPT_PATH="$(realpath "$0")"

# Launch inside a tmux session if not already
if [ -z "$TMUX" ]; then
  SESSION_NAME="setup"
  tmux new-session -s "$SESSION_NAME" "bash '$SCRIPT_PATH'; bash"
  exit 0
fi

echo "🛠️ Running setup inside tmux session '$TMUX'..."

# --- Functions ---
install_packages() {
  echo "========== INSTALLING PACKAGES =========="
  export NEEDRESTART_MODE=a
  export DEBIAN_FRONTEND=noninteractive

    sudo tee /etc/needrestart/conf.d/99-no-prompt.conf > /dev/null <<EOF
\$nrconf{restart} = 'a';
EOF

  sudo apt update
  sudo apt --fix-broken install -y
  sudo apt autoremove -y
  sudo apt install -y tmux curl xclip xvfb btop pipx ffmpeg nvtop libsndfile1 sox nvidia-cuda-toolkit git-lfs pv
}

configure_tmux() {
  echo "========== CONFIGURING TMUX =========="
  curl -fsSL -o ~/.tmux.conf https://raw.githubusercontent.com/hossein-khalilian/server-setup/main/.tmux.conf
  tmux source-file ~/.tmux.conf
}

setup_neovim() {
  echo "========== SETTING UP NEOVIM =========="
  mkdir -p ~/.config
  cd ~/.config
  if [ ! -d "nvim" ]; then
    git clone https://github.com/hossein-khalilian/nvim-config.git nvim
  fi
  cd nvim
  ./pre-installation.sh || true
  source ~/.bashrc
}

setup_jupyterlab() {
  echo "========== SETTING UP JUPYTERLAB =========="
  mkdir -p ~/projects/hse/git
  cd ~/projects/hse/git
  if [ ! -d "jupyterlab-compose" ]; then
    git clone https://github.com/hossein-khalilian/jupyterlab-compose.git
  fi
  cd jupyterlab-compose
  docker compose -f docker-compose-gpu.yml up -d
}

setup_python_env() {
  echo "========== SETTING UP PYTHON ENV =========="
  pipx install virtualenv || true
  pipx ensurepath
  source ~/.bashrc
  VENV_DIR="$HOME/projects/hse/venv2"
  grep -qxF "source $VENV_DIR/bin/activate" ~/.bashrc || echo "source $VENV_DIR/bin/activate" >> ~/.bashrc
  if [ ! -d "$VENV_DIR" ]; then
    $HOME/.local/bin/virtualenv "$VENV_DIR"
  fi
}

configure_xvfb() {
  echo "========== CONFIGURING XVFB =========="
  grep -qxF 'if [ -z "$DISPLAY" ]; then' ~/.bashrc || cat << 'EOF' >> ~/.bashrc

# Start Xvfb if no display is available
if [ -z "$DISPLAY" ]; then
  Xvfb :0 -screen 0 1024x768x24 &
  export DISPLAY=:0
fi
EOF
}

configure_git() {
  echo "========== CONFIGURING GIT =========="
  grep -qxF '# Set Git user config if inside a repo' ~/.bashrc || cat << 'EOF' >> ~/.bashrc

# Set Git user config if inside a repo
if git rev-parse --is-inside-work-tree &>/dev/null; then
  git config --local user.name "hossein khalilian"
  git config --local user.email "hse.khalilian08@gmail.com"
fi
EOF
}

# --- Execution ---
install_packages
configure_tmux
configure_git
setup_neovim
setup_python_env
configure_xvfb
setup_jupyterlab

# Final package cleanup
echo "========== FINAL CLEANUP =========="
sudo apt --fix-broken install -y
sudo apt autoremove -y

echo "========== ✅ SETUP COMPLETE ✅ =========="
