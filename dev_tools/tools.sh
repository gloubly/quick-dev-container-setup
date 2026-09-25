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