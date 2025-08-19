# `koolbox`: Kubernetes Toolbox for cloud automation
This repo provides a set of tools to:
- create a variety of container images with cloud tools
- make it possible to make your own images with specific tools/versions
- make images that are as lean as possible for use in scripting (like CI/CD scripts)
- make images that can be used interactively (and are usually larger)
- have scripts that can be used to install such tools, even outside of a container

The script images are kept as small as possible.
They can be based on debian-slim, which does not contain things as documentation.

The interactive images contain all kind of extra tools and packages such as:
- documentation and other stuff not in slim
- less
- vim
- k9s
- ...
The interactive images can be recognized are tagged `full` while

Several images are planned/available:
- `kubebox`: kubectl, helm, several plugins and probably python3
- `kaazbox`: Kubernetes And AZ: adds azure-cli and terraform
- `kawsbox`: Kubernetes AWS: adds aws-cli and terraform
Planned images might be
- `kloudbox`: adds all cloud tools, aws, az, gcp, ...
- `kansbox` : kubernetes and ansible
- `kallbox` : kloudbox and ansible

koolbox itself is not a container image, but the overall tools to build and run these tools.


There is a huge variation on image sizes as can be seen:
```
$ podman images --sort repository | grep -v none
REPOSITORY                  TAG          IMAGE ID      CREATED      SIZE
docker.io/library/debian    trixie       047bd8d81940  8 days ago   124 MB
docker.io/library/debian    trixie-slim  c4f2d356126a  8 days ago   81 MB
localhost/orgkisst/kaazbox  full         1c72b7dd9745  5 hours ago  1.19 GB
localhost/orgkisst/kaazbox  slim         6bc4b5710492  5 hours ago  1.06 GB
localhost/orgkisst/kawsbox  full         d25d50616ffa  5 hours ago  754 MB
localhost/orgkisst/kawsbox  slim         507f8e63eb8b  5 hours ago  637 MB
localhost/orgkisst/kubebox  full         9169edef4802  5 hours ago  528 MB
localhost/orgkisst/kubebox  slim         30ddf25040d3  4 hours ago  373 MB
localhost/orgkisst/kubebox  superslim    c002eb552318  4 hours ago  239 MB
```

# TODO
Many packages, still can be added, like: k9s, plugins helm-diff, kubent, krew, kubectl-clean, ...
