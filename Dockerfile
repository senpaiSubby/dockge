FROM node:22-bookworm-slim

# Docker Compose is pinned to v2: v5 leaves its progress output mid-way on some commands
# (e.g. restart never prints the final "Started" frame), so the terminal in Dockge looks frozen
RUN apt update && apt install --yes --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    unzip \
    dumb-init \
    git \
    openssh-client \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo \
         "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
         "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
         tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt update \
    && apt --yes --no-install-recommends install \
         docker-ce-cli \
         "docker-compose-plugin=2.40.3-*" \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g tsx


WORKDIR /app

COPY . /app

# Git commit this image is built from, shown next to the version in Settings > About
ARG DOCKGE_COMMIT=""
ENV DOCKGE_COMMIT=$DOCKGE_COMMIT

RUN npm install && \
    npm run build:frontend

RUN mkdir ./data


# It is just for safe, as by default, it is disabled in the latest Node.js now.
# Read more:
# - https://github.com/sagemathinc/cocalc/issues/6963
# - https://github.com/microsoft/node-pty/issues/630#issuecomment-1987212447
ENV UV_USE_IO_URING=0

# git pull (Update button) runs in a terminal nobody can type into:
# fail instead of hanging on a password prompt, and trust a git host's SSH key on first use
ENV GIT_TERMINAL_PROMPT=0
RUN printf 'Host *\n    BatchMode yes\n    StrictHostKeyChecking accept-new\n' > /etc/ssh/ssh_config.d/dockge.conf

VOLUME /app/data
EXPOSE 5001
ENTRYPOINT ["/usr/bin/dumb-init", "--", "sh", "/app/extra/docker-entrypoint.sh"]
CMD ["tsx", "./backend/index.ts"]
