FROM python:3.11.9-slim-bookworm

ARG TZ
ENV TZ=$TZ
RUN ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone

ARG CONTAINER_USER_ID
ARG CONTAINER_GROUP_ID

ENV CONTAINER_USER_ID=${CONTAINER_USER_ID:-1000}
ENV CONTAINER_GROUP_ID=${CONTAINER_GROUP_ID:-1000}
ENV ANSIBLE_CONFIG=/srv/ansible.cfg
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

RUN mkdir -p /etc/sudoers.d
RUN echo "builder     ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/builder
RUN groupadd builder -g ${CONTAINER_GROUP_ID} && useradd -u ${CONTAINER_USER_ID} -g builder -m -d /home/builder -s /bin/bash -c "Builder user" builder
RUN chown -R builder:builder /srv

ADD --chown=builder:builder .yarnrc.yml /srv/.yarnrc.yml
ADD --chown=builder:builder /container/docker-entrypoint.sh /
ADD --chown=builder:builder /container/home/builder/.default_aliases /srv/container/home/builder/.default_aliases
ADD --chown=builder:builder /scripts /srv/scripts
ADD --chown=builder:builder ansible.cfg /srv/ansible.cfg
ADD --chown=builder:builder defaults/requirements.txt /srv/defaults/requirements.txt
ADD --chown=builder:builder defaults/requirements.yml /srv/defaults/requirements.yml
ADD --chown=builder:builder package.json /srv/package.json
ADD --chown=builder:builder yarn.lock /srv/yarn.lock

# Files that need to be present when using the image in CI pipelines
ADD --chown=builder:builder /inventories /srv/inventories
ADD --chown=builder:builder defaults/autocomplete.yml /srv/defaults/autocomplete.yml
ADD --chown=builder:builder defaults/start.yml /srv/inventories/start.yml

# Installing everything in separate scripts to avoid creating multiple layers thus reducing the image size
# Having separate layers also keeps them small and easier to download and extract on low bandwidth connections

ADD --chown=builder:builder scripts/general/install-docker-image-tools.sh /tmp/install-docker-image-tools.sh
RUN bash /tmp/install-docker-image-tools.sh

USER builder

ADD --chown=builder:builder scripts/general/install-docker-image-python.sh /tmp/install-docker-image-python.sh
RUN bash /tmp/install-docker-image-python.sh
ADD --chown=builder:builder container/home/builder/.zshrc /home/builder/.zshrc

ADD --chown=builder:builder scripts/general/install-docker-image-collections.sh /tmp/install-docker-image-collections.sh
RUN bash /tmp/install-docker-image-collections.sh

WORKDIR /srv
ENTRYPOINT ["/docker-entrypoint.sh"]
