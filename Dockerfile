FROM python:3.12.12-slim-trixie

LABEL org.opencontainers.image.source=https://github.com/ClarifiedSecurity/catapult
LABEL org.opencontainers.image.description="Pre-built Docker image for Catapult"
LABEL org.opencontainers.image.licenses="AGPL-3.0 license"

ARG TZ
ENV TZ=$TZ
RUN ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone

ARG CONTAINER_USER_ID
ARG CONTAINER_GROUP_ID

ENV CONTAINER_USER_ID=${CONTAINER_USER_ID:-1000}
ENV CONTAINER_GROUP_ID=${CONTAINER_GROUP_ID:-1000}
ENV ANSIBLE_CONFIG=/srv/ansible.cfg
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

# Increasing UID_MAX & GID_MAX for cases when external identity provider is used for host accounts
RUN sed -i 's/^UID_MAX[[:space:]]*[0-9]\+/UID_MAX        4294967295/' /etc/login.defs
RUN sed -i 's/^GID_MAX[[:space:]]*[0-9]\+/GID_MAX        4294967295/' /etc/login.defs

# Setting UMASK 002 for non-1000 host users
RUN sed -i 's/^UMASK[[:space:]]*[0-9]\+/UMASK        002/' /etc/login.defs

RUN mkdir -p /etc/sudoers.d
RUN echo "builder     ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/builder
RUN groupadd builder -g ${CONTAINER_GROUP_ID} && useradd -u ${CONTAINER_USER_ID} -g builder -m -d /home/builder -s /bin/bash -c "Builder user" builder
RUN chown -R builder:builder /srv

ADD --chown=builder:builder /container/home/builder/.default_aliases /srv/container/home/builder/.default_aliases
ADD --chown=builder:builder /scripts /srv/scripts
ADD --chown=builder:builder ansible.cfg /srv/ansible.cfg
ADD --chown=builder:builder defaults /srv/defaults

# Files that need to be present when using the image in CI pipelines
ADD --chown=builder:builder inventories/_operating_systems /srv/inventories/_operating_systems
ADD --chown=builder:builder container/home/builder/.vault/unlock-vault.sh /home/builder/.vault/unlock-vault.sh

# Installing everything in separate scripts to and multiple layers thus reducing the image size
# Having separate layers also keeps them small and easier to download and extract on low bandwidth connections

ADD --chown=builder:builder scripts/general/install-docker-image-tools.sh /tmp/install-docker-image-tools.sh
RUN bash /tmp/install-docker-image-tools.sh

USER builder

ADD --chown=builder:builder scripts/general/install-docker-image-python.sh /tmp/install-docker-image-python.sh
ADD --chown=builder:builder defaults/pyproject.toml /home/builder/catapult-venv/pyproject.toml
ADD --chown=builder:builder defaults/uv.lock /home/builder/catapult-venv/uv.lock
RUN bash /tmp/install-docker-image-python.sh
ADD --chown=builder:builder container/home/builder/.zshrc /home/builder/.zshrc

ADD --chown=builder:builder scripts/general/install-docker-image-collections.sh /tmp/install-docker-image-collections.sh
RUN bash /tmp/install-docker-image-collections.sh

# Setting the default editor to nano since it's easier to use for beginners
ENV EDITOR=nano

WORKDIR /srv