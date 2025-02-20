#!/bin/bash

# Fixing file permissions when ${CONTAINER_USER_ID} is not 1000

if [[ "${CONTAINER_USER_ID}" != 1000 && "${MAKEVAR_HOST_OS}" == "Linux" ]]; then

    umask 0002

    echo -ne "${C_YELLOW}"
    echo -e "Fixing file and folder permissions for non 1000 user..."

    # Vault
    sudo -E chmod 775 ~/.vault
    sudo -E chown builder:"${CONTAINER_GROUP_ID}" ~/.vault

    # Ansible Collections
    sudo -E mkdir -p /srv/ansible
    sudo -E chown builder:"${CONTAINER_GROUP_ID}" /srv/ansible

    # SSH
    sudo -E chmod 600 /home/builder/.ssh/config
    sudo -E chown builder:"${CONTAINER_GROUP_ID}" ~/.ssh

    # Shell History
    sudo -E chown builder:"${CONTAINER_GROUP_ID}" ~/.history

    # Projects
    sudo -E chown -R builder:"${CONTAINER_GROUP_ID}" /srv/inventories

    # Personal certificates
    sudo -E mkdir -p /srv/personal/certificates
    sudo -E chown builder:"${CONTAINER_GROUP_ID}" /srv/personal/certificates

    echo -ne "${C_RST}"

fi
