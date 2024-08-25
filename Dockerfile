
#########################################################
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y apt-utils && \
  apt-get update && apt-get -y install --no-install-recommends \
    apt-transport-https \
    bash-completion \
    ca-certificates \
    curl \
    git \
    gnupg \
    iputils-ping \
    jed \
    jq \
    less \
    nano \
    openssh-client \
    python3 \
    python3-pip \
    rsync \
    telnet \
    tcptraceroute \
    traceroute \
    unzip \
    vim \
    wget \
    zip \
    && apt-get clean
    #&& rm -rf /var/lib/apt/lists/*

# The next command gets things like manpages, but this add 200M to the image, and usually --help is just fine
# RUN yes | unminimize

# Install kubectl
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && apt-get -y install --no-install-recommends kubectl \
    && rm -rf /var/lib/apt/lists/*

# Install aws cli
RUN pip3 install awscli --upgrade

# Install rancher cli
RUN wget -qO- https://github.com/rancher/cli/releases/download/v2.4.10/rancher-linux-amd64-v2.4.10.tar.gz \
  | tar xvz -C /tmp && \
  mv /tmp/rancher-*/rancher /usr/local/bin/ && \
  rmdir /tmp/rancher-*

# Install kustomize
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash && \
  mv kustomize /usr/local/bin

# Install helm3
RUN \
  mkdir /tmp/helm && \
  wget -qO- "https://get.helm.sh/helm-v3.5.3-linux-amd64.tar.gz" \
  | tar xvz -C /tmp/helm/ && \
  mv /tmp/helm/linux-amd64/helm /usr/local/bin/

# Install yq
RUN curl -sLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && \
  chmod 755 /usr/local/bin/yq

# Add a toolbox user, to not run as root
RUN \
  groupadd --gid 1000 toolbox && \
  useradd --system --create-home --home-dir /home/toolbox --shell /bin/bash --uid 1000 --gid 1000 toolbox

USER 1000
WORKDIR /home/toolbox

ENTRYPOINT ["/bin/bash"]
