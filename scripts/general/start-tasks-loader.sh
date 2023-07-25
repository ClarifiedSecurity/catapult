#!/bin/bash

# This script is used to load all the start tasks in the container
# It looks for all the files in the custom/start-tasks folder and sources them

set -e # exit when any command fails

echo -n -e ${C_CYAN}

# Checking if docker is installed
if ! [ -x "$(command -v docker)" ]; then
  echo -n -e ${C_RED}
  echo -e "Docker not found did you run 'make prepare' first!"
  exit 1
  echo -n -e ${C_RST}
fi

START_TASKS_FILES="scripts/start-tasks/*.sh"
CUSTOM_START_TASKS_FILES="custom/start-tasks/*.sh"

for custom_startfile in $CUSTOM_START_TASKS_FILES; do
  if [ -f $custom_startfile ]; then
    # Comment in the echo line below for better debugging
    # echo -e "\n Processing custom $custom_startfile...\n"
    $custom_startfile
  fi
done

for startfile in $START_TASKS_FILES; do
  if [ -f $startfile ]; then
    # Comment in the echo line below for better debugging
    # echo -e "\n Processing $startfile...\n"
    $startfile
  fi
done

