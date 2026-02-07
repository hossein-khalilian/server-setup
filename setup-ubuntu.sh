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
  sudo apt update
  sudo apt --fix-broken install -y
  sudo apt autoremove -y
  sudo apt install -y tmux git curl xclip btop pipx
  mkdir -p ~/projects/hse/git
}

install_docker() {
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
  sudo apt-get update
  sudo apt-get install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update

  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

  # Post installation
    if ! getent group docker > /dev/null 2>&1; then
    sudo groupadd docker
  fi
  sudo usermod -aG docker $USER
}

configure_tmux() {
  curl -fsSL -o ~/.tmux.conf https://raw.githubusercontent.com/hossein-khalilian/server-setup/main/.tmux.conf
  tmux source-file ~/.tmux.conf
}

setup_neovim() {
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
  mkdir -p ~/projects/hse/git
  cd ~/projects/hse/git
  if [ ! -d "jupyterlab-compose" ]; then
    git clone https://github.com/hossein-khalilian/jupyterlab-compose.git
  fi
  cd jupyterlab-compose
  docker compose -f docker-compose.yml up -d
}

setup_python_env() {
    echo "========== SETTING UP PYTHON ENV =========="

    # Install uv if missing
    if ! command -v uv &>/dev/null; then
        echo "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        # Add uv to PATH if not already there
        if ! grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        fi
        export PATH="$HOME/.local/bin:$PATH"
    fi

    VENV_DIR="$HOME/projects/hse/venv2"

    # Ensure python3-venv is installed
    if ! dpkg -s python3-venv &>/dev/null; then
        echo "Installing python3-venv and python3-pip..."
        sudo apt update && sudo apt install -y python3-venv python3-pip
    fi

    # Create virtual environment using python -m venv
    if [ ! -d "$VENV_DIR" ]; then
        echo "Creating virtual environment at $VENV_DIR..."
        python3 -m venv "$VENV_DIR"
    fi

    # Activate venv and ensure pip is available
    source "$VENV_DIR/bin/activate"
    python -m ensurepip --upgrade
    pip install --upgrade pip

    # Add venv activation to .bashrc if not already there
    if ! grep -qxF "source $VENV_DIR/bin/activate" ~/.bashrc; then
        echo "source $VENV_DIR/bin/activate" >> ~/.bashrc
    fi

    echo "Python environment setup complete."
}


configure_xvfb() {
  grep -qxF 'if [ -z "$DISPLAY" ]; then' ~/.bashrc || cat << 'EOF' >> ~/.bashrc

# Start Xvfb if no display is available
if [ -z "$DISPLAY" ]; then
  Xvfb :0 -screen 0 1024x768x24 &
  export DISPLAY=:0
fi
EOF
}

configure_git() {
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
install_docker
configure_xvfb
# setup_jupyterlab
setup_python_env

# Final package cleanup
sudo apt --fix-broken install -y
sudo apt autoremove -y

# 🟢 End message
echo "✅ Setup complete."
