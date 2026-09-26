##################################################
#### Tool functions for dev container commands ###
##################################################

# checks if a project directory exists
_project_directory_exists() {
    local project_path="${DEV_CONTAINER_BASE_PATH}/projects/$1"
    if [[ ! -d "${project_path}" ]]; then
        echo "Path doesn't exist: ${project_path}"
        return 1
    fi
}

# checks if a docker image exists
_image_exists() {
    if [[ -z $(docker images -q "${DEV_CONTAINER_NAME}:$1") ]]; then
        echo "Image doesn't exist: ${DEV_CONTAINER_NAME}:$1"
        return 1
    fi
}

# useful for pre-commit hooks that require dependencies on the dev container
# pushing isn't supported
# extract the [user] part of .gitconfig and sends it to the container
_setup_gitconfig_user() {
    grep -Pzo "\[user\]\n[^\[]+" ~/.gitconfig | xargs --null -i docker exec "${DEV_CONTAINER_NAME}" bash -c 'echo "{}" > ${HOME}/.gitconfig'
}