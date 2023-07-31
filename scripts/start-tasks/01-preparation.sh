#!/bin/bash

echo -n -e ${C_CYAN}

# Creating required files to avoid errors
touch ./container/home/builder/.zsh_history
touch ./container/home/builder/.custom_aliases
touch .makerc-custom
touch .makerc-personal

echo -n -e ${C_RST}