##################################################
######### Help messages for dev commands #########
##################################################

_dev_build_help() {
    cat << EOF

Build a dev image

Usage:  dev build TAG [OPTIONS] [docker build options ...]

Tag:    image tag, either "base" or a directory in projects/ for a final image

Options:
    --debug     shortcut for "--progress plain --no-cache"

EOF
}

_dev_run_help() {
    cat << EOF

Create a new dev container

Usage:  dev run TAG

Tag:    image tag, directory projects/{tag} must exist

EOF
}

_dev_start_help() {
    cat << EOF

Start the dev container or do nothing if it is running

Usage:  dev start

EOF
}

_dev_enter_help() {
    cat << EOF

Enter in the dev container, starts it if needed

Usage:  dev enter

EOF
}

_dev_reset_help() {
    cat << EOF

Recreate the dev container with the same image tag and configuration

Usage:  dev reset

EOF
}

_dev_clean_help() {
    cat << EOF

Remove the dev container

Usage:  dev clean

EOF
}

_dev_imgclean_help() {
    cat << EOF

Delete dangling and ${DEV_CONTAINER_NAME} related images

Usage:  dev imgclean

EOF
}

_dev_help() {
    cat << EOF

Dev container commands

Usage:  dev COMMAND

Commands:
    build       Build a dev image
    run         Create a new dev container
    start       Start the dev container
    enter       Enter in the dev container, starts it if needed
    reset       Recreate the dev container with the same configuration
    clean       Remove the dev container
    imgclean    Delete dangling and ${DEV_CONTAINER_NAME} related images

Run dev COMMAND --help for more information on a command.

EOF
}