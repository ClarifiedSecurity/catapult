# Matches the Python version in pyproject.toml
FROM python:3.11.6-slim-bullseye

# Timezone configuration from .makerc-vars
ARG TZ
ENV TZ=${MAKEVAR_TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG CONTAINER_USER_ID
ARG CONTAINER_GROUP_ID

ENV CONTAINER_USER_ID=${CONTAINER_USER_ID:-1000}
ENV CONTAINER_GROUP_ID=${CONTAINER_GROUP_ID:-1000}

RUN apt update \
 && apt install -y ca-certificates curl gnupg \
 # Adding nodejs & yarn repo
 && mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
 && NODE_MAJOR=18 \
 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
 && apt update \
 # Required tools
 && apt install -y gcc rsync iputils-ping jq sshpass git git-lfs sudo zsh software-properties-common nodejs unzip \
 # Dev tools
 # && apt install -y iproute2 traceroute dnsutils wget netcat-openbsd vim nano htop procps \
 # Node and Yarn
 && corepack enable \
 && cd /srv \
 && yarn set version stable \
 # Apt cleanup
 && apt clean \
 && rm -rf /var/lib/apt/lists/*

RUN echo "builder     ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/builder
RUN groupadd -r builder -g ${CONTAINER_GROUP_ID} && useradd -u ${CONTAINER_USER_ID} -r -g builder -m -d /home/builder -s /bin/bash -c "Builder user" builder

USER builder
WORKDIR /home/builder

# Poetry
ADD --chown=builder:builder poetry/pyproject.toml /srv/poetry/pyproject.toml
ADD --chown=builder:builder poetry/poetry.lock /srv/poetry/poetry.lock

RUN cd /srv \
 && curl -sSL https://install.python-poetry.org | python3 - \
 && $HOME/.local/bin/poetry config installer.max-workers 10 \
 && $HOME/.local/bin/poetry install --directory=/srv/poetry \
 && cd $HOME \
# Oh My Zsh
 && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
 && zsh \
 && git clone https://github.com/denysdovhan/spaceship-prompt.git "/home/builder/.oh-my-zsh/custom/themes/spaceship-prompt" --depth=1 \
 && ln -s "/home/builder/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "/home/builder/.oh-my-zsh/custom/themes/spaceship.zsh-theme" \
# Oh My Zsh Poetry autocomplete
 && mkdir /home/builder/.oh-my-zsh/custom/plugins/poetry \
 && $HOME/.local/bin/poetry completions zsh > /home/builder/.oh-my-zsh/custom/plugins/poetry/_poetry \
# fzf
 && git clone https://github.com/junegunn/fzf.git /home/builder/.fzf --depth 1 \
 && /home/builder/.fzf/install --key-bindings --completion --update-rc \
# Aliases
 && echo "source $HOME/.default_aliases" | sudo tee -a /etc/zsh/zshrc \
 && echo "source $HOME/.custom_aliases" | sudo tee -a /etc/zsh/zshrc \
 && echo "source $HOME/.personal_aliases" | sudo tee -a /etc/zsh/zshrc

ADD --chown=builder:builder /container/home/builder/.default_aliases /home/builder/.default_aliases
ADD --chown=builder:builder /container/home/builder/.ssh /home/builder/.ssh
ADD --chown=builder:builder /container/home/builder/kpsock.py /home/builder/kpsock.py
ADD --chown=builder:builder /container/home/builder/keepass-decrypt-check.py /home/builder/keepass-decrypt-check.py
ADD --chown=builder:builder plugins /srv/plugins
ADD --chown=builder:builder ansible.cfg /srv/ansible.cfg
ADD --chown=builder:builder /requirements /srv/requirements
ADD --chown=builder:builder /scripts /srv/scripts
ADD --chown=builder:builder /container/docker-entrypoint.sh /

WORKDIR /srv

# NOTCUSTOM because custom requirements will be installed on first run and updating them needs to be available without rebuilding the image
ENV ANSIBLE_CONFIG=/srv/ansible.cfg
RUN /srv/scripts/general/install-all-requirements.sh NOTCUSTOM

ENTRYPOINT ["/docker-entrypoint.sh"]
