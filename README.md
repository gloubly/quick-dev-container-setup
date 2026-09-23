# Quick dev container setup

Quick multi-containers dev setup to easily switch between them. Only one is active at once

## Base image
All dev containers inherit from a "base" image:
* timezone setup (prevent tzdata from blocking packages installation)
* Non-root user with sudo permissions (no password needed)
* Essential dependencies

## Final images
Final images build files needed to be located in a directory *projects/*. The directory name will be the image tag.
Files needed:
* config: build environment variables
    - PROJECT_PATH: absolute path of the project to be mounted on the container
* install.sh
