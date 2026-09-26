##################################################
###### Dev commands for dev container usage ######
##################################################

# absolute path of the project root directory
DEV_CONTAINER_BASE_PATH=$(realpath "$(dirname "$0")/..")
DEV_CONTAINER_NAME="dev-container"

source ${DEV_CONTAINER_BASE_PATH}/dev_tools/tools.sh
source ${DEV_CONTAINER_BASE_PATH}/dev_tools/help.sh

# build the base image or a final dev image
_dev_build() {
    # check that an image tag is provided and that it isn't an option
    if [[ $# == 0 ]]; then
        echo "Need an image tag"
        return 1
    fi
    if [[ $1 == -* ]]; then {
        _dev_build_help
        return 0
    }
    fi

    local project="$1"
    shift

    local additional_args=()
    while [[ $# > 0 ]]; do
        case $1 in
            --debug)
                additional_args+=(--progress plain --no-cache)
                shift
                ;;
            --help)
                echo "TODO help"
                return 0
                ;;
            *)
                additional_args+=($1)
                shift
                ;;
        esac
    done

    if [[ "${project}" == "base" ]]; then
        docker build \
            -t ${DEV_CONTAINER_NAME}:base \
            --build-arg UID=$(id -u) \
            --build-arg GID=$(id -g) \
            -f ${DEV_CONTAINER_BASE_PATH}/docker/base/Dockerfile \
            ${additional_args[@]} \
            ${DEV_CONTAINER_BASE_PATH}
        return 0
    fi

    _project_directory_exists "${project}" || return 1
    _image_exists "base" || return 1

    # add env vars
    . "${DEV_CONTAINER_BASE_PATH}/projects/${project}/config"
    docker build \
        -t ${DEV_CONTAINER_NAME}:${project} \
        --build-arg PROJECT_DIR=${project} \
        -f ${DEV_CONTAINER_BASE_PATH}/docker/final/Dockerfile \
        ${additional_args[@]} \
        ${DEV_CONTAINER_BASE_PATH}
}

# run a dev container, need an image tag
_dev_run() {
    if [[ $# == 0 ]]; then
        echo "Please provide an image tag"
        return 1
    fi
    if [[ $1 == -* ]]; then {
        _dev_run_help
        return 0
    }
    fi
    local tag="$1"
    if [[ "${tag}" == "base" ]]; then
        echo "Can't use base image, need a final image tag"
        return 1
    fi
    if $(docker ps -a --format {{.Names}} | grep -q "${DEV_CONTAINER_NAME}"); then
        echo "A dev container is already running"
        return 1
    fi
    _project_directory_exists "${tag}" || return 1
    _image_exists "${tag}" || return 1

    shift
    local additional_args="$@"

    # add env vars
    . ${DEV_CONTAINER_BASE_PATH}/projects/${tag}/config
    docker run \
        -v ${PROJECT_PATH}:/workspace/$(basename "${PROJECT_PATH}") \
        --name ${DEV_CONTAINER_NAME} \
        ${additional_args} \
        -it ${DEV_CONTAINER_NAME}:${tag}
}

# start the container or do nothing if if doesn't exist or is already running
_dev_start() {
    if [[ ! -z $1 ]]; then {
        _dev_start_help
        return 0
    }
    fi
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
_dev_enter() {
    if [[ ! -z $1 ]]; then {
        _dev_enter_help
        return 0
    }
    fi
    _dev_start > /dev/null
    docker exec -it ${DEV_CONTAINER_NAME} bash
}

# recreate the same container
_dev_reset() {
    _dev_start > /dev/null
    local project_dir=$(docker exec ${DEV_CONTAINER_NAME} env | grep DEV_CONTAINER_PROJECT_DIR | cut -d '=' -f 2)
    _dev_clean
    _dev_run "${project_dir}"
}

# stop and remove the container
_dev_clean() {
    echo "Stopping the dev container"
    docker stop "${DEV_CONTAINER_NAME}" > /dev/null || return 1
    echo "Removing the dev container"
    docker rm "${DEV_CONTAINER_NAME}" > /dev/null
}

# delete dangling and dev container related images
_dev_imgclean() {
    echo "Cleaning dangling images"
    docker rmi $(docker images --filter "dangling=true" --format {{.ID}}) 2> /dev/null || echo "No dangling images found"
    echo "Cleaning ${DEV_CONTAINER_NAME} images"
    docker rmi $(docker images dev-container --format '{{.ID}}') 2> /dev/null || echo "No images unused found"
}

dev() {
    case $1 in
        build)
            shift
            _dev_build "$@"
            ;;
        run)
            shift
            _dev_run "$@"
            ;;
        start)
            shift
            _dev_start "$@"
            ;;
        enter)
            shift
            _dev_enter "$@"
            ;;
        reset)
            shift
            _dev_reset "$@"
            ;;
        clean)
            shift
            _dev_clean "$@"
            ;;
        imclean)
            shift
            _dev_imgclean "$@"
            ;;
        --help|"")
            shift
            _dev_help
            ;;
        *)
            echo "Unknown command $1"
            echo "See 'dev --help'"
            return 1
            ;;
    esac
}