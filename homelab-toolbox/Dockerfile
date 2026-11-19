# syntax=docker/dockerfile:1
# homelab-toolbox: OpenTofu, Ansible, kubectl and Helm on Debian 13.
# Build with ./build.sh, which passes the pinned versions from versions.env.
# No keys, kubeconfigs or secrets belong in this image; homelab-box mounts them at run time.
FROM debian:13-slim

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Set by BuildKit from the target platform (amd64 or arm64).
ARG TARGETARCH

# KUBECACHEDIR keeps kubectl's cache out of ~/.kube, which homelab-box mounts read-only.
ENV LANG=C.UTF-8 \
    PATH=/opt/venv/bin:$PATH \
    KUBECACHEDIR=/home/ops/.cache/kube

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git jq openssh-client python3 python3-venv \
 && rm -rf /var/lib/apt/lists/*

# Non-root user. OpenSSH fails when the running UID has no passwd entry.
ARG UID=1000
RUN groupadd --gid "$UID" ops \
 && useradd --uid "$UID" --gid ops --create-home --shell /bin/bash ops \
 && install -d -m 0700 -o ops -g ops /home/ops/.ssh \
 && install -d -m 0755 -o ops -g ops /work

ARG ANSIBLE_CORE_VERSION
RUN : "${ANSIBLE_CORE_VERSION:?build with ./build.sh}" \
 && python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --no-cache-dir --disable-pip-version-check \
      "ansible-core==${ANSIBLE_CORE_VERSION}"

# OpenTofu, checked against the release's SHA256SUMS.
ARG TOFU_VERSION
RUN : "${TOFU_VERSION:?build with ./build.sh}" "${TARGETARCH:?needs BuildKit}" \
 && tmp="$(mktemp -d)" && cd "$tmp" \
 && base="https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}" \
 && tarball="tofu_${TOFU_VERSION}_linux_${TARGETARCH}.tar.gz" \
 && curl -fsSLO "$base/$tarball" \
 && curl -fsSLO "$base/tofu_${TOFU_VERSION}_SHA256SUMS" \
 && awk -v f="$tarball" '$2 == f' "tofu_${TOFU_VERSION}_SHA256SUMS" | sha256sum -c - \
 && tar -xzf "$tarball" tofu \
 && install -m 0755 tofu /usr/local/bin/tofu \
 && cd / && rm -rf "$tmp"

# kubectl, checked against the published .sha256.
ARG KUBECTL_VERSION
RUN : "${KUBECTL_VERSION:?build with ./build.sh}" "${TARGETARCH:?needs BuildKit}" \
 && tmp="$(mktemp -d)" && cd "$tmp" \
 && base="https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}" \
 && curl -fsSLO "$base/kubectl" \
 && curl -fsSLO "$base/kubectl.sha256" \
 && echo "$(cat kubectl.sha256)  kubectl" | sha256sum -c - \
 && install -m 0755 kubectl /usr/local/bin/kubectl \
 && cd / && rm -rf "$tmp"

# Helm, checked against the published .sha256sum.
ARG HELM_VERSION
RUN : "${HELM_VERSION:?build with ./build.sh}" "${TARGETARCH:?needs BuildKit}" \
 && tmp="$(mktemp -d)" && cd "$tmp" \
 && tarball="helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" \
 && curl -fsSLO "https://get.helm.sh/$tarball" \
 && curl -fsSLO "https://get.helm.sh/$tarball.sha256sum" \
 && sha256sum -c "$tarball.sha256sum" \
 && tar -xzf "$tarball" "linux-${TARGETARCH}/helm" \
 && install -m 0755 "linux-${TARGETARCH}/helm" /usr/local/bin/helm \
 && cd / && rm -rf "$tmp"

USER ops
WORKDIR /work
CMD ["bash"]
