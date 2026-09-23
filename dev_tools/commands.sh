#/bin/bash

# absolute path of the project root directory
DEV_CONTAINER_BASE_PATH=$(realpath "$(dirname "$0")/..")
DEV_CONTAINER_NAME="dev-container"

# enter the dev-container, no args needed
dev_enter() {
    dev_start > /dev/null
    docker exec -it ${DEV_CONTAINER_NAME} bash
}


# run a dev container, need an image tag
dev_run() {
    if [[ $# == 0 ]]; then
        echo "Please provide an image tag"
        return 1
    fi
    local tag="$1"
    if [[ $tag == "base" ]]; then
        echo "Can't use base image, need a final image tag"
        return 1
    fi
    # add env var
    . ${DEV_CONTAINER_BASE_PATH}/projects/${tag}/config
    docker run  -v ${PROJECT_PATH}:/workspace/$(basename "${PROJECT_PATH}") \
                --name ${DEV_CONTAINER_NAME} \
                -it ${DEV_CONTAINER_NAME}:${tag}
}

# build the base image or a final dev image
dev_build() {
    if [[ $# != 1 ]]; then
        echo "Need an image tag"
        return 1
    fi
    if [[ "$1" == "base" ]]; then
        docker build -t ${DEV_CONTAINER_NAME}:base \
                     --build-arg UID=$(id -u) \
                     --build-arg GID=$(id -g) \
                     -f ${DEV_CONTAINER_BASE_PATH}/docker/base/Dockerfile ${DEV_CONTAINER_BASE_PATH}
        return 0
    fi
    project="$1"
    . ${DEV_CONTAINER_BASE_PATH}/projects/${project}/config

    docker build -t ${DEV_CONTAINER_NAME}:${project} --no-cache \
                 --build-arg PROJECT_DIR=${project} \
                 -f ${DEV_CONTAINER_BASE_PATH}/docker/final/Dockerfile ${DEV_CONTAINER_BASE_PATH}
}

# recreate the same container
dev_reset() {
    dev_start > /dev/null
    project_dir=$(docker exec ${DEV_CONTAINER_NAME} env | grep DEV_CONTAINER_PROJECT_DIR | cut -d '=' -f 2)
    dev_clean
    dev_build "${project_dir}"
    dev_run "${project_dir}"
}

# start the container or do nothing if if doesn't exist or is already running
dev_start() {
    result=$(docker ps -a -f name=dev-container --format '{{.Status}}' | cut -d ' ' -f 1)
    case $result in
        Up)
            echo "Dev container already running"
            ;;
        Exited)
            echo "Starting dev container"
            docker start ${DEV_CONTAINER_NAME} > /dev/null
            ;;
        *)
            echo "Dev container doesn't exist"
    esac
}

# stop and remove the container
dev_clean() {
    echo "Stopping the dev container"
    docker stop ${DEV_CONTAINER_NAME} || return 1
    echo "Deleting the dev container"
    docker rm ${DEV_CONTAINER_NAME}
}