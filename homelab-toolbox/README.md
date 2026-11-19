# homelab-toolbox

A container image with OpenTofu, Ansible (`ansible-core`), kubectl and Helm, plus `homelab-box`, a wrapper that runs it against the current directory. The only host requirement is Docker. Downloads pick the binary for `TARGETARCH`, so the same Dockerfile targets amd64 and arm64. The image contains no keys, kubeconfigs or secrets; the wrapper mounts those at run time.

## Build

```bash
./build.sh                          # native arch; the image's ops user gets your UID
./build.sh --platform linux/arm64   # extra args go straight to docker build
```

`build.sh` reads `versions.env`, passes each pin as a `--build-arg`, and tags `homelab-toolbox:latest` (override with `HOMELAB_BOX_IMAGE`). The OpenTofu, kubectl and Helm downloads are checked against each project's published SHA-256 checksums; `ansible-core` comes from PyPI at the pinned version. Set `HOMELAB_BOX_UID` to build for a UID other than yours.

## Setup (once per machine)

```bash
install -D -m 600 secrets.env.example ~/.config/homelab/secrets.env   # then fill in values
ln -s "$PWD/homelab-box" ~/.local/bin/homelab-box                      # optional, puts it on PATH
ssh-add -l                                                             # agent running with your key loaded
```

## Run

```bash
cd ../terraform/proxmox/k3s-lab
homelab-box                    # interactive bash in /work
homelab-box tofu plan          # or any single command
```

| Host | Container | Notes |
|------|-----------|-------|
| current directory | `/work` | read-write; OpenTofu state and `.terraform/` stay here |
| `$SSH_AUTH_SOCK` | `/ssh-agent` | agent forwarding only, no key files; fails if no agent |
| `~/.ssh/known_hosts` | `/home/ops/.ssh/known_hosts` | read-write; created empty if missing |
| `~/.kube` | `/home/ops/.kube` | read-only; skipped if missing |
| `~/.config/homelab/secrets.env` | environment | `--env-file`; required |

Each host path can be overridden with `HOMELAB_BOX_KNOWN_HOSTS`, `HOMELAB_BOX_KUBE_DIR` and `HOMELAB_BOX_SECRETS_ENV`. The container uses default bridge networking, so it follows the host's routes, including NetBird/WireGuard. `-t` is added only when stdin is a terminal, so scripts and CI can call it too.

## Update versions

1. Look up the current stable releases:
   - OpenTofu: <https://github.com/opentofu/opentofu/releases>
   - kubectl: <https://dl.k8s.io/release/stable.txt>
   - Helm: <https://github.com/helm/helm/releases>
   - ansible-core: <https://pypi.org/project/ansible-core/>
2. Edit `versions.env` (plain numbers, no leading `v`).
3. Run `./build.sh`, then `homelab-box tofu version` (and the other tools' version commands).

## Troubleshooting

- **`Permission denied` on the agent socket:** the image UID doesn't match yours. Rebuild with `./build.sh`.
- **`hostfile_replace_entries failed … Device or resource busy`:** OpenSSH can't swap a single bind-mounted file when it rewrites `known_hosts` (e.g. `ssh-keygen -R`). Do that on the host instead. Adding new hosts still works.
