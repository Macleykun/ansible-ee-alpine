Thanks to [justsomescripts](https://github.com/justsomescripts/ansible-ee-alpine) for the initial setup!

[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/macleykun/ansible-ee-alpine/docker-publish.yml)](https://github.com/Macleykun/ansible-ee-alpine/actions/workflows/docker-publish.yml)
[![Container Image Size](https://ghcr-badge.egpl.dev/Macleykun/ansible-ee-alpine/size?color=%2344cc11&tag=main&label=image+size&trim=)](https://github.com/Macleykun/ansible-ee-alpine/pkgs/container/ansible-ee-alpine)
[![Container Image Tag](https://ghcr-badge.egpl.dev/Macleykun/ansible-ee-alpine/tags?color=%2344cc11&ignore=sha256*%2Cnightly&n=2&label=image+tags&trim=)](https://github.com/Macleykun/ansible-ee-alpine/pkgs/container/ansible-ee-alpine)

# ℹ️ About The Project

This project provides container images for Ansible [Execution Environments](https://docs.ansible.com/automation-controller/latest/html/userguide/execution_environments.html) based on [Alpine Linux](https://www.alpinelinux.org/). 

**Advantages compared to the official EEs built using [ansible-builder](https://github.com/ansible/ansible-builder)**:

- Non-root user context
- Simpler Containerfile
- Small Container image
- Easy to use without ansible-runner
- Easy to tweak what pip packages and collections you want to include

## ✈️ Getting Started

If you still need to install ansible-navigator:

```bash
pip3 install 'ansible-navigator' --break-system-packages && pip3 uninstall 'ansible-core' --break-system-package -y
```

```bash
ansible-navigator collections -m interactive # Our ansible-navigator.yml uses stdout mode by default
```

Generally make a hosts file to a remote host you already have ssh'd into and also setup an example playbook where you use the ping module. Run it with: `ansible-navigator run test-playbook.yml` and enjoy the output!

## 📖 Usage

See the [ansible-navigator.yml file](https://github.com/Macleykun/ansible-ee-alpine/blob/main/ansible-navigator.yml)! It's configured that you can use your own private keys and accepted fingerprints from your host easily and not leave logging/artefacts behind.

## 📬 Contact

Through GitHub only please :)
