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
- k9s
- ...
The interactive images can be recognized with an `i` in their name, just before `box`

Several images are planned/available:
- `kubebox`: kubectl, helm, several plugins and probably python3
- `kubibox`: interactive version
- `kaazbox`: Kubernetes And AZ: adds azure-cli and terraform
- `kaazibox`: interactive version
- `kawsbox`: Kubernetes AWS: adds aws-cli and terraform
- `kawsibox`: interactive version
- `kloudbox`: adds all cloud tools, aws, az, gcp, ...
- `kloudibox`: interactive version
- koolbox is not a container image, but the overall tools to build and run these tools


There is a huge variation on image sizes as can be seen:
```
mark@clevo-fedo:~/work/koolbox$ podman images| grep -v none
REPOSITORY                   TAG            IMAGE ID      CREATED         SIZE
localhost/orgkisst/kupibox   latest         e4e21add4dd3  21 seconds ago  1.32 GB
localhost/orgkisst/kubebox   latest         cd76205964f2  8 minutes ago   364 MB
localhost/orgkisst/kubibox   latest         beab2371bcfb  10 minutes ago  431 MB
localhost/orgkisst/kloudbox  latest         98dfeab9080a  18 hours ago    649 MB
docker.io/library/debian     12             3d2058890b96  6 days ago      121 MB
docker.io/library/debian     12-slim        f813b63f015b  6 days ago      77.9 MB
docker.io/library/python     3.12-slim      bad5eac7befe  8 days ago      123 MB
docker.io/library/python     3.12           537013425929  8 days ago      1.13 GB
docker.io/library/ubuntu     24.04          e0f16e6366fe  2 weeks ago     80.6 MB
mcr.microsoft.com/azure-cli  azurelinux3.0  77058ec760b7  2 weeks ago     688 MB
mcr.microsoft.com/azure-cli  latest         77058ec760b7  2 weeks ago     688 MB
```
