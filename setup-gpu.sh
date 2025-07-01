sudo apt update
sudo apt --fix-broken install -y
sudo apt autoremove
sudo apt install tmux curl

tmux new -s setup

curl -o ~/.tmux.conf https://raw.githubusercontent.com/hossein-khalilian/server-setup/main/.tmux.conf
tmux source-file ~/.tmux.conf

mkdir -p ~/.config
cd ~/.config
git clone https://github.com/hossein-khalilian/nvim-config.git nvim
cd nvim
./pre-installation.sh
source ~/.bashrc

mkdir -p ~/projects/hse/git
cd ~/projects/hse/git
git clone https://github.com/hossein-khalilian/jupyterlab-compose.git
cd jupyterlab-compose/
docker compose -f docker-compose-gpu.yml up -d

virtualenv ~/projects/hse/venv2
source ~/projects/hse/venv2/bin/activate

