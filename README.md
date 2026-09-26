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

|   Commands        |   Usage
| ----------------- | ----------
|   dev build       |   Build a dev image
|   dev run         |   Create a new dev container
|   dev start       |   Start the dev container
|   dev enter       |   Enter in the dev container, starts it if needed
|   dev reset       |   Recreate the dev container with the same configuration
|   dev clean       |   Remove the dev container
|   dev imgclean    |   Delete dangling and dev-container related images
