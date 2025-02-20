#!/bin/bash

# Fixing file permissions when ${CONTAINER_USER_ID} is not 1000

if [[ "${CONTAINER_USER_ID}" != 1000 && "${MAKEVAR_HOST_OS}" == "Linux" ]]; then

    echo -ne "${C_YELLOW}"
    echo -e "Fixing file and folder permissions for non 1000 user..."

    # Vault
    sudo -E chmod -R u=rwX,g=rwX,o= ~/.vault
    sudo -E chown -R builder:"${CONTAINER_GROUP_ID}" ~/.vault

    # Ansible Collections
    sudo -E mkdir -p /srv/ansible
    sudo -E chown -R builder:"${CONTAINER_GROUP_ID}" /srv/ansible
    sudo -E chmod -R u=rwX,g=rwX,o= /srv/ansible

    # SSH
    sudo -E chown builder:"${CONTAINER_GROUP_ID}" ~/.ssh
    if [[ -f ~/.ssh/known_hosts ]]; then
        sudo -E chown builder:"${CONTAINER_GROUP_ID}" ~/.ssh/known_hosts*
    fi

    # Shell History
    sudo -E chmod -R u=rwX,g=rwX,o= ~/.history
    sudo -E chown -R builder:"${CONTAINER_GROUP_ID}" ~/.history

    # Projects
    sudo -E chmod -R u=rwX,g=rwX,o= /srv/inventories
    sudo -E chown -R "${CONTAINER_USER_ID}":builder /srv/inventories

    # Personal certificates
    sudo -E mkdir -p /srv/personal/certificates
    sudo -E chown builder:"${CONTAINER_GROUP_ID}" /srv/personal/certificates

    echo -ne "${C_RST}"

fi
