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
- Many packages, still can be added .
  * **script**:  plugins helm-diff, kubent, krew
  * **interactive**: k9s
- add krew and install some krew packages:
  * **script**: allctx, kubectx, kubens, foreach, kubectl-clean, popeye
  * **interactive**: kube-score, apidocs, rakkess, compare, cond, cost, df-pv, pug, explore, fuzzy, doctor, stern/kail, rolesum, capacity, reap, pv-mounter, pv-migrate, tree, kubecm?, kor, ktop, outdated, pods-on,
  * unknown: evict-pod?
- shell completions for bash (and zsh, fish, ...)


# root or non root?
The scripts can be run in different scenarios:
# script is run as root, should be installed to be used for all users
This seems to be the best default for in a podman rootless container.
It can also be invoked using `sudo` on the install scripts

- complete packages preferably installed in `/opt/<package>`
- binaries with symlinks from `/usr/local/bin`
- `kubectl-krew` in `/opt/krew` (`KREW_ROOT`) needs it's own `bin` directory appended to the `PATH`
- `helm` plugings in `/opt/helm-plugins` with `HELM_PLUGINS`

# script is run as a user and should be installed only for that user
- Single binary
  install in `/.local/bin` complete packages preferably installed in `~/local/share/<package>`
- binaries with symlinks from `~/.local/bin`
- `kubectl-krew` plugins in `~/.local/lib/krew` (`KREW_ROOT`).
   This needs it's own `bin` directory appended to the `PATH`
- `helm` plugings in `~/.local/lib//helm-plugins` with `HELM_PLUGINS`


- Option 2 seems to be desirable if you want to use the scripts on your on machine without container.
  It might also be desirable within a container, but not sure how yet.
- Option 3 seems to be too complex, better than to use `sudo <install-script>` and use option 1.
