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
