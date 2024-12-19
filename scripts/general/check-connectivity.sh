#!/usr/bin/env bash

# Running connectivity checks
if ping -c 1 1.1.1.1 &> /dev/null; then

    echo -n -e "${C_GREEN}"
    echo -e IPv4 connectivity OK
    echo -n -e "${C_RST}"

else

    echo -n -e "${C_RED}"
    echo -e IPv4 connectivity FAIL
    echo -n -e "${C_RST}"

fi

if ping -c 1 2606:4700:4700::1111 &> /dev/null; then

    echo -n -e "${C_GREEN}"
    echo -e IPv6 connectivity OK
    echo -n -e "${C_RST}"

else

    echo -n -e "${C_RED}"
    echo -e IPv6 connectivity FAIL
    echo -n -e "${C_RST}"

fi