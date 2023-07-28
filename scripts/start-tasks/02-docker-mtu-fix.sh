#!/bin/bash

echo -n -e ${C_CYAN}

if ! [ -x "$(command -v iptables)" ]; then

  exit 0

fi

docker_rule="FORWARD -p tcp -m tcp --tcp-flags SYN SYN -j TCPMSS --clamp-mss-to-pmtu" # https://stfc-cloud-docs.readthedocs.io/en/latest/faultfixes/HTTPConnectivityInContainerOnVM.html

if ${MAKEVAR_SUDO_COMMAND} iptables -S | grep -q "$docker_rule"; then
  echo -n -e
else
  echo -e "Fixing docker MTU..."
  ${MAKEVAR_SUDO_COMMAND} iptables -I $docker_rule
fi

### some info about it
# https://stfc-cloud-docs.readthedocs.io/en/latest/faultfixes/HTTPConnectivityInContainerOnVM.html

### to remove the rule
#iptables -D FORWARD -p tcp --tcp-flags SYN SYN -j TCPMSS --clamp-mss-to-pmtu

