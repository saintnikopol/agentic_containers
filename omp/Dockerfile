FROM node:24-bookworm

# Install system tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    jq \
    ripgrep \
    grep \
    sed \
    gawk \
    less \
    vim \
    nano \
    tree \
    unzip \
    zip \
    openssh-client \
    python3 \
    python3-pip \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Enable pnpm and yarn via Corepack (must run as root)
RUN corepack enable

# Install GitHub CLI (optional, but very useful for PRs)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# /workspace is bind-mounted from the host, so it's owned by the host
# user's uid, not the container's non-root uid below. Git's dubious-
# ownership check would otherwise refuse to operate on it.
RUN git config --system --add safe.directory /workspace

# Drop root: everything below runs as the non-root 'node' user (uid 1000)
# already provided by the base image, so a compromised dependency or
# injected shell command can't touch system files.
USER node
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH="/home/node/.npm-global/bin:${PATH}"

# Install Bun (as node, installs into $HOME/.bun)
RUN curl -fsSL https://bun.sh/install | bash
ENV BUN_INSTALL=/home/node/.bun
ENV PATH="${BUN_INSTALL}/bin:${PATH}"

# 👇 Install Pi Coding Agent (corrected package)
RUN npm install -g @earendil-works/pi-coding-agent

# oh-my-pi is an extension on top of Pi (not a separate binary) - it's
# installed through Pi's own package manager, which Pi auto-discovers
# and loads on the next session.
RUN pi install npm:oh-my-pi

WORKDIR /workspace

# Default command (overridden by docker-compose)
CMD ["bash"]