# Quick dev container setup

Quick multi-containers dev setup to easily switch between projects with different dependencies. Only one is active at once.

## Base image
All **final** images inherit from a **base** image:
* timezone setup (prevent tzdata from blocking packages installation)
* Non-root user with sudo permissions (no password needed)
* Essential dependencies

## Setup
### Installation
Clone the repo
```bash
git clone https://github.com/gloubly/quick-dev-container-setup
```
Add this to your .bashrc or .zshrc
```bash
source YOUR_PATH/dev_container/dev_tools/commands.sh
```

#### :warning: This will create two variables, the commands won't work if they are altered
* DEV_CONTAINER_BASE_PATH
* DEV_CONTAINER_NAME

### Add a new project
Create a new directory in *projects/*. The directory name will be the image tag.
#### Files needed:
* config (to store build environment variables):
    - PROJECT_PATH: absolute path of the project to be mounted on the container
* install.sh

For an example, check my configuration for liburdf [here](projects/) - [GitHub repo](https://github.com/wissem01chiha/liburdf)

## Available commands

| Commands | Usage
| ----- | -----
| dev_build [tag] | Build a dev image, [tag] must be either a directory in projects/ or "base"
dev_run [tag] | Create a new dev container, [tag] must be either a directory in projects/
dev_start | Start the dev container
dev_enter | Enter in the dev container (starts it if needed)
dev_reset | Recreate the dev container with the same configuration
dev_clean | Remove the dev container
