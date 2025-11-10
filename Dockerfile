FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies: SSH server, curl, Python (for simple HTTP keep-alive)
RUN apt-get update &&     apt-get install -y --no-install-recommends         openssh-server         curl         ca-certificates         python3         sudo &&     rm -rf /var/lib/apt/lists/*

# Create SSH directory
RUN mkdir -p /var/run/sshd

# Create non-root user with sudo
RUN useradd -m -s /bin/bash ubuntu &&     echo "ubuntu:ubuntu" | chpasswd &&     usermod -aG sudo ubuntu &&     echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Ngrok (single binary)
RUN curl -sSL https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.tgz -o /tmp/ngrok.tgz &&     tar -xzf /tmp/ngrok.tgz -C /usr/local/bin &&     rm /tmp/ngrok.tgz &&     chmod +x /usr/local/bin/ngrok

# SSH configuration: allow password login for demo usage
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config &&     sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config &&     sed -i 's/#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

# Copy start scripts
COPY start-ngrok.sh /start-ngrok.sh
COPY start-ngrok-ssh.sh /start-ngrok-ssh.sh
RUN chmod +x /start-ngrok.sh /start-ngrok-ssh.sh

EXPOSE 22 8080

# Default entrypoint: minimal SSH + Ngrok
CMD ["/start-ngrok-ssh.sh"]
