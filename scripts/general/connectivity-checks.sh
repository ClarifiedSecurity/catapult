#!/usr/bin/env bash

if ping -c 1 1.1.1.1 &> /dev/null
then
  echo -e "\033[32mIPv4 connectivity OK\033[0m"
else
  echo -e "\033[31mIPv4 connectivity FAIL\033[0m"
fi

if ping -c 1 2606:4700:4700::1111 &> /dev/null
then
  echo -e "\033[32mIPv6 connectivity OK\033[0m"
else
  echo -e "\033[33mIPv6 connectivity FAIL\033[0m"
fi
