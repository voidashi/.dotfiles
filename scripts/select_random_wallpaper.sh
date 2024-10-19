#!/bin/bash

# USE EXAMPLE:
#
# Inside Hyprland config
# exec-once = swaybg -m fill -i "$(bash $HOME/scripts/select_random_wallpaper.sh $HOME/Pictures/Current_wallpapers)"
#
# Or inside Sway config
# exec swaybg -m fill -i "$(bash $HOME/scripts/select_random_wallpaper.sh $HOME/Pictures/Current_wallpapers)"


# Directory to select a random file from
DIRECTORY=$1

# Check if the directory exists
if [ ! -d "$DIRECTORY" ]; then
  echo "Directory does not exist."
  exit 1
fi

# Get a random file from the directory
RANDOM_FILE=$(ls "$DIRECTORY" | shuf -n 1)

# Full path of the random file
RANDOM_FILE_PATH="$DIRECTORY/$RANDOM_FILE"

# Check if a file was found and print the path
if [ -z "$RANDOM_FILE" ]; then
  echo "No files found in the directory."
else
  echo "$RANDOM_FILE_PATH"
fi

