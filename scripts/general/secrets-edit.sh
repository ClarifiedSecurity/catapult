#!/usr/bin/env bash

if [ ! -f /var/tmp/vlt_pf ]; then

    # shellcheck disable=SC1091
    source /srv/scripts/general/secrets-unlock.sh

else

    ansible-vault edit ~/.vault/vlt
    /srv/scripts/general/secrets-validate.sh

fi