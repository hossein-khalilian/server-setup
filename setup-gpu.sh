sudo apt update
sudo apt --fix-broken install -y
sudo apt autoremove -y
sudo apt install -y tmux curl

tmux new -As setup

curl -o ~/.tmux.conf https://raw.githubusercontent.com/hossein-khalilian/server-setup/main/.tmux.conf
tmux source-file ~/.tmux.conf

mkdir -p ~/.config
cd ~/.config
[ ! -d "nvim" ] && git clone https://github.com/hossein-khalilian/nvim-config.git nvim
cd nvim
./pre-installation.sh || true
source ~/.bashrc

mkdir -p ~/projects/hse/git
cd ~/projects/hse/git
[ ! -d "jupyterlab-compose" ] && git clone https://github.com/hossein-khalilian/jupyterlab-compose.git
cd jupyterlab-compose/
docker compose -f docker-compose-gpu.yml up -d

[ ! -d "$HOME/projects/hse/venv2" ] && virtualenv "$HOME/projects/hse/venv2"
source "$HOME/projects/hse/venv2/bin/activate"
