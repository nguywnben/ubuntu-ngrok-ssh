# ubuntu-ngrok-ssh

Run a full Ubuntu 22.04 SSH environment in the cloud using Ngrok tunnels — deployable on Railway, Render, or any Docker-compatible host.

> This project is intended for learning, testing, and temporary environments.  
> Do not use it for storing sensitive data or running abusive workloads.

---

## Features

- Ubuntu 22.04 base image
- OpenSSH server preinstalled
- Ngrok TCP tunnel for remote SSH access
- Works on any platform that can build and run this Dockerfile
- Connection info is printed directly to the container logs
- Non-root `ubuntu` user with `sudo` access

---

## Requirements

- A platform that can build and run Docker images (e.g. Railway, Render, Koyeb, Fly.io, VPS, local Docker, etc.)
- An Ngrok account
- `NGROK_AUTH_TOKEN` set as an environment variable in your deployment

---

## Quick Start (Local Docker)

```bash
git clone https://github.com/nguywnben/ubuntu-ngrok-ssh.git
cd ubuntu-ngrok-ssh

docker build -t ubuntu-ngrok-ssh .
docker run -it --rm   -e NGROK_AUTH_TOKEN=<your_ngrok_token>   ubuntu-ngrok-ssh
```

Wait a few seconds, then check the container logs. You should see a line like:

```text
Ngrok TCP: tcp://x.tcp.ngrok.io:12345
Connect using:
ssh ubuntu@x.tcp.ngrok.io -p 12345
```

Default credentials (you should change them if you use this for anything serious):

- **User:** `ubuntu`
- **Password:** `ubuntu`

---

## Deploying on Hosted Platforms

1. Create a new project from this repository.
2. Set the `NGROK_AUTH_TOKEN` environment variable in the dashboard.
3. Deploy.
4. Open the logs and look for the printed Ngrok TCP URL.
5. SSH into the box using the shown host and port:

```bash
ssh ubuntu@<host> -p <port>
```

This works on any Docker host as long as:
- Outbound internet access is allowed (Ngrok needs to reach its servers).
- Port 22 inside the container is accessible to the Ngrok client.

---

## Environment Variables

| Name               | Required | Description                                      |
|--------------------|----------|--------------------------------------------------|
| `NGROK_AUTH_TOKEN` | ✅       | Your Ngrok auth token used to create the tunnel. |

---

## Scripts

- `start-ngrok-ssh.sh`: Minimal entrypoint; starts SSH and exposes it via an Ngrok TCP tunnel.
- `start-ngrok.sh`: Extended version (example) that can also expose an additional HTTP service via Ngrok if needed.

---

## Security Notes

- This setup is for demos and experiments.
- Change the default password or use SSH keys for any real usage.
- Treat every deployed instance as temporary and disposable.

---

## License

This project is licensed under the **MIT License**. See [`LICENSE`](LICENSE) for details.
