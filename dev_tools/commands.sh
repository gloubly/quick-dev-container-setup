#/bin/bash

# absolute path of the project root directory
DEV_CONTAINER_BASE_PATH=$(realpath "$(dirname "$0")/..")
DEV_CONTAINER_NAME="dev-container"

# checks if a project directory exists
_project_directory_exists() {
    local project_path="${DEV_CONTAINER_BASE_PATH}/projects/$1"
    if [[ ! -d "${project_path}" ]]; then
        echo "Path: ${project_path} doesn't exist"
        return 1
    fi
}

# build the base image or a final dev image
dev_build() {
    if [[ $# != 1 ]]; then
        echo "Need an image tag"
        return 1
    fi
    if [[ "$1" == "base" ]]; then
        docker build \
            -t ${DEV_CONTAINER_NAME}:base \
            --build-arg UID=$(id -u) \
            --build-arg GID=$(id -g) \
            -f ${DEV_CONTAINER_BASE_PATH}/docker/base/Dockerfile \
            ${DEV_CONTAINER_BASE_PATH}
        return 0
    fi
    local project="$1"
    _project_directory_exists "${project}" || return 1
    # add env vars
    . "${DEV_CONTAINER_BASE_PATH}/projects/${project}/config"
    docker build \
        -t ${DEV_CONTAINER_NAME}:${project} \
        --build-arg PROJECT_DIR=${project} \
        -f ${DEV_CONTAINER_BASE_PATH}/docker/final/Dockerfile \
        ${DEV_CONTAINER_BASE_PATH}
}

# run a dev container, need an image tag
dev_run() {
    if [[ $# == 0 ]]; then
        echo "Please provide an image tag"
        return 1
    fi
    local tag="$1"
    if [[ "${tag}" == "base" ]]; then
        echo "Can't use base image, need a final image tag"
        return 1
    fi
    _project_directory_exists "${tag}" || return 1

    # add env vars
    . ${DEV_CONTAINER_BASE_PATH}/projects/${tag}/config
    docker run \
        -v ${PROJECT_PATH}:/workspace/$(basename "${PROJECT_PATH}") \
        --name ${DEV_CONTAINER_NAME} \
        -it ${DEV_CONTAINER_NAME}:${tag}
}

# start the container or do nothing if if doesn't exist or is already running
dev_start() {
    local result=$(docker ps -a -f name=dev-container --format '{{.Status}}' | cut -d ' ' -f 1)
    case ${result} in
        Up)
            echo "Dev container already running"
            ;;
        Exited)
            echo "Starting dev container"
            docker start "${DEV_CONTAINER_NAME}" > /dev/null
            ;;
        *)
            echo "Dev container doesn't exist"
    esac
}

# enter the dev-container, no args needed
dev_enter() {
    dev_start > /dev/null
    docker exec -it ${DEV_CONTAINER_NAME} bash
}

# recreate the same container
dev_reset() {
    dev_start > /dev/null
    local project_dir=$(docker exec ${DEV_CONTAINER_NAME} env | grep DEV_CONTAINER_PROJECT_DIR | cut -d '=' -f 2)
    dev_clean
    dev_build "${project_dir}"
    dev_run "${project_dir}"
}

# stop and remove the container
dev_clean() {
    echo "Stopping the dev container"
    docker stop "${DEV_CONTAINER_NAME}" > /dev/null || return 1
    echo "Removing the dev container"
    docker rm "${DEV_CONTAINER_NAME}" > /dev/null
}

dev_help() {
    cat << EOM
Dev container commands
* dev_build [tag]   Build a dev image, [tag] must be either a directory in projects/ or "base"
* dev_run   [tag]   Create a new dev container, [tag] must be either a directory in projects/
* dev_start         Start the dev container
* dev_enter         Enter in the dev container (starts it if needed)
* dev_reset         Recreate the dev container with the same configuration
* dev_clean         Remove the dev container
EOM
}