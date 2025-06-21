FROM node:22-bookworm-slim

RUN apt update && apt install --yes --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    unzip \
    dumb-init \
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
         docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g tsx


WORKDIR /app

COPY . /app

RUN npm install && \
    npm run build:frontend

RUN mkdir ./data


# It is just for safe, as by default, it is disabled in the latest Node.js now.
# Read more:
# - https://github.com/sagemathinc/cocalc/issues/6963
# - https://github.com/microsoft/node-pty/issues/630#issuecomment-1987212447
ENV UV_USE_IO_URING=0

VOLUME /app/data
EXPOSE 5001
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["tsx", "./backend/index.ts"]
