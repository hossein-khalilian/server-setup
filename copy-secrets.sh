#!/bin/bash

# Prompt for the host
read -p "Enter the hostname (e.g., gpu, user@host): " HOST

# Copy SSH keys
scp ~/.ssh/temp_keys/* "$HOST:~/.ssh/"

# Copy Hugging Face tokens
scp ~/.cache/huggingface/token ~/.cache/huggingface/stored_tokens "$HOST:~/.cache/huggingface"
