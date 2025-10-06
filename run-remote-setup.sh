#!/bin/bash

# Prompt for the local setup script if not provided as an argument
if [ -z "$1" ]; then
  read -p "Enter the path to the local setup script: " LOCAL_SCRIPT
else
  LOCAL_SCRIPT="$1"
fi

# Check if the file exists
if [ ! -f "$LOCAL_SCRIPT" ]; then
  echo "❌ Error: File '$LOCAL_SCRIPT' not found."
  exit 1
fi

# Prompt for the remote host (e.g., user@hostname)
read -p "Enter the remote host (e.g., user@hostname): " HOST

# Define a unique remote path
REMOTE_SCRIPT="/tmp/remote_setup_$$.sh"

echo "📤 Uploading '$LOCAL_SCRIPT' to '$HOST:$REMOTE_SCRIPT'..."
scp "$LOCAL_SCRIPT" "$HOST:$REMOTE_SCRIPT" || { echo "❌ SCP upload failed."; exit 1; }

# Run it remotely inside tmux and keep tmux open after execution
echo "🚀 Running setup script on remote host..."
ssh "$HOST" "chmod +x $REMOTE_SCRIPT && tmux new-session -d -s setup '$REMOTE_SCRIPT; echo; echo \"✅ Script finished. Press any key to exit.\"; read'"

# Automatically attach to the tmux session
ssh -t "$HOST" "tmux attach -t setup"

# Optional message
# echo "🚀 Remote setup script launched in tmux session 'setup' on $HOST."
# echo "To reattach later: ssh -t $HOST 'tmux attach -t setup'"
