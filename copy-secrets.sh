#!/bin/bash

scp ~/.ssh/temp_keys/* gpu:~/.ssh/
scp ~/.cache/huggingface/token ~/.cache/huggingface/stored_tokens gpu:~/.cache/huggingface
