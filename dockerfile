# ----- Dockerfile -----
# Shadowroot LPE - CVE-2025-32463 Demonstration Environment

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install essential tools and libraries
RUN apt-get update && \
    apt-get install -y build-essential wget libpam0g-dev libselinux1-dev zlib1g-dev \
                       pkg-config libssl-dev git ca-certificates gcc sudo && \
    rm -rf /var/lib/apt/lists/*

# 2. Download and compile vulnerable sudo version (1.9.16p2)
WORKDIR /opt
RUN wget https://www.sudo.ws/dist/sudo-1.9.16p2.tar.gz && \
    tar -xzf sudo-1.9.16p2.tar.gz && \
    cd sudo-1.9.16p2 && \
    ./configure --disable-gcrypt --prefix=/usr && make && make install

# 3. Create a non-root user for exploitation
RUN useradd -m -s /bin/bash ghostuser

# 4. Copy the exploit script into the user's home
COPY shadow-escalate.sh /home/ghostuser/shadow-escalate.sh
RUN chown ghostuser:ghostuser /home/ghostuser/shadow-escalate.sh && chmod +x /home/ghostuser/shadow-escalate.sh

# 5. Switch to non-root user context
USER ghostuser
WORKDIR /home/ghostuser

# 6. Default to interactive shell
CMD ["/bin/bash"]
