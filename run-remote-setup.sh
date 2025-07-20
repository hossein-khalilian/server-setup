#!/bin/bash

# Prompt for the remote host (e.g., user@hostname)
read -p "Enter the remote host (e.g., user@hostname): " HOST

# Define the setup script and remote path
LOCAL_SCRIPT="setup-gpu.sh"
REMOTE_SCRIPT="/tmp/remote_setup_$$.sh"

# Upload the script to the remote server
scp "$LOCAL_SCRIPT" "$HOST:$REMOTE_SCRIPT"

# Run it remotely inside tmux and keep tmux open after execution
ssh "$HOST" "chmod +x $REMOTE_SCRIPT && tmux new-session -d -s setup '$REMOTE_SCRIPT; echo; echo \"✅ Script finished. Press any key to exit.\"; read'"

# Let the user know
echo "🚀 Remote setup script launched in tmux session 'setup' on $HOST."
echo "To attach: ssh $HOST -t 'tmux attach -t setup'"
