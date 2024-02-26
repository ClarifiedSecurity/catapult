# Must match the Python version in pyproject.toml
FROM python:3.11.7-slim-bookworm

# Timezone configuration from .makerc-vars
ARG TZ
ENV TZ=${MAKEVAR_TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG CONTAINER_USER_ID
ARG CONTAINER_GROUP_ID

ENV CONTAINER_USER_ID=${CONTAINER_USER_ID:-1000}
ENV CONTAINER_GROUP_ID=${CONTAINER_GROUP_ID:-1000}
ENV ANSIBLE_CONFIG=/srv/ansible.cfg

RUN mkdir -p /etc/sudoers.d
RUN echo "builder     ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/builder
RUN groupadd builder -g ${CONTAINER_GROUP_ID} && useradd -u ${CONTAINER_USER_ID} -g builder -m -d /home/builder -s /bin/bash -c "Builder user" builder

ADD --chown=builder:builder /container/home/builder/.default_aliases /home/builder/.default_aliases
ADD --chown=builder:builder /container/home/builder/.ssh /home/builder/.ssh
ADD --chown=builder:builder /container/home/builder/kpsock.py /home/builder/kpsock.py
ADD --chown=builder:builder /container/home/builder/keepass-decrypt-check.py /home/builder/keepass-decrypt-check.py
ADD --chown=builder:builder /container/home/builder/keepass-unlocker.sh /home/builder/keepass-unlocker.sh
ADD --chown=builder:builder plugins /srv/plugins
ADD --chown=builder:builder ansible.cfg /srv/ansible.cfg
ADD --chown=builder:builder /requirements /srv/requirements
ADD --chown=builder:builder /scripts /srv/scripts
ADD --chown=builder:builder /container/docker-entrypoint.sh /
ADD --chown=builder:builder defaults/requirements.txt /srv/defaults/requirements.txt
ADD --chown=builder:builder package.json /srv/package.json

# Installing everything in two script to avoid creating multiple layers thus reducing the image size
# Having 2 layers also keeps them small and easy to download and extract on low bandwidth connections

ADD --chown=builder:builder scripts/general/install-docker-image-tools.sh /tmp/install-docker-image-tools.sh
RUN bash /tmp/install-docker-image-tools.sh

ADD --chown=builder:builder scripts/general/install-docker-image-python.sh /tmp/install-docker-image-python.sh
RUN bash /tmp/install-docker-image-python.sh

USER builder
WORKDIR /srv
ENTRYPOINT ["/docker-entrypoint.sh"]
