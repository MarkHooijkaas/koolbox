
#########################################################
FROM ubuntu:24.04 AS koolbox-base

ARG DEBIAN_FRONTEND=noninteractive

COPY --chown=1000:1000 bin/koolbox-install-apt-packages.sh /home/koolbox/bin/koolbox-install-apt-packages.sh
RUN /home/koolbox/bin/koolbox-install-apt-packages.sh

#########################################################
FROM koolbox-base

COPY --chown=1000:1000 bin /home/koolbox/bin

RUN ls -la /home/koolbox/bin/
RUN /home/koolbox/bin/koolbox-install-aws-cli.sh
RUN /home/koolbox/bin/koolbox-install-ansible.sh

RUN /home/koolbox/bin/koolbox-install-helm.sh
RUN /home/koolbox/bin/koolbox-install-kubectl.sh
RUN /home/koolbox/bin/koolbox-install-rancher-cli.sh
RUN /home/koolbox/bin/koolbox-install-yq.sh


# Add a toolbox user, to not run as root
#RUN \
#  groupadd --gid 1000 toolbox && \
#  useradd --system --create-home --home-dir /home/toolbox --shell /bin/bash --uid 1000 --gid 1000 toolbox

#USER 1000
#WORKDIR /home/toolbox

ENTRYPOINT ["/bin/bash"]
