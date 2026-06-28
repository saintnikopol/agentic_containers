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

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV BUN_INSTALL=/root/.bun
ENV PATH="${BUN_INSTALL}/bin:${PATH}"
ENV GIT_CONFIG_GLOBAL=/workspace/.gitconfig

# Enable pnpm and yarn via Corepack
RUN corepack enable

# 👇 Install Pi Coding Agent (corrected package)
RUN npm install -g @earendil-works/pi-coding-agent


# Install GitHub CLI (optional, but very useful for PRs)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Default command (overridden by docker-compose)
CMD ["bash"]