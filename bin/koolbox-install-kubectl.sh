#!/usr/bin/bash

# install latest stable
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# install specific version
curl -LO "https://dl.k8s.io/release/v1.30.4/bin/linux/amd64/kubectl"

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
chmod a+r /etc/bash_completion.d/kubectl
rm kubectl

# Old Ubuntu way
#export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
#curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
#echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
#apt-get update
#apt-get -y install --no-install-recommends kubectl
#rm -rf /var/lib/apt/lists/*
