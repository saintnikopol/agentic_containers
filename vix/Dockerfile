FROM debian:bookworm-slim

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
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI (optional, but very useful for PRs)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# debian:bookworm-slim has no non-root user built in (unlike the node
# image), so create one explicitly.
RUN useradd -m -u 1000 -s /bin/bash vix

# /workspace is bind-mounted from the host, so it's owned by the host
# user's uid, not the container's non-root uid below. Git's dubious-
# ownership check would otherwise refuse to operate on it.
RUN git config --system --add safe.directory /workspace

# Drop root: everything below runs as the non-root 'vix' user, so a
# compromised dependency or injected shell command can't touch system
# files.
USER vix
WORKDIR /home/vix

# Install Vix (Go binary, no npm/Node involved)
RUN curl -fsSL https://getvix.dev/install.sh | bash
ENV PATH="/home/vix/.local/bin:${PATH}"

WORKDIR /workspace

COPY --chown=vix:vix entrypoint.sh /home/vix/entrypoint.sh
ENTRYPOINT ["/home/vix/entrypoint.sh"]

# Default command (overridden by docker-compose)
CMD ["bash"]
