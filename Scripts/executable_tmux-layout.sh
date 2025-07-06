#!/bin/bash

# Method: Create the exact layout we want step by step
# Step 1: Split horizontally to create left side (25%) and right side (75%)
tmux split-window -t 1 -h -l 25%

# Step 2: Go to the right side and split it to create middle (50%) and right (25%)
tmux split-window -t 1 -h -l 66%  # 50% of 75% = 67%

# Step 3: Split the right side vertically to create top (50%) and bottom (50%)
tmux split-window -v -t 3
# Step 4: Split the left side vertically to create top (50%) and bottom (50%)
tmux split-window -v -t 1

# Step 5: Select the middle pane (pane 3)
tmux select-pane -t 3
