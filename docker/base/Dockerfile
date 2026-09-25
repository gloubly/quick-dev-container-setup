####################################
############ Base Image ############
####################################

FROM ubuntu:26.04

ARG UID
ARG GID

WORKDIR /workspace

RUN apt-get update && apt-get upgrade -y && apt-get install -y software-properties-common

# timezone
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

# use non-root user with sudo permission (no password)
RUN apt-get -y install sudo adduser
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN usermod -aG sudo ubuntu
RUN chown ubuntu /workspace
USER ubuntu

# register apt repositories
RUN sudo add-apt-repository -y ppa:deadsnakes/ppa && \
    sudo apt-get update

# base dependencies
RUN sudo apt-get install -y \
    build-essential \
    cmake \
    git \
    nano \
    wget \
    curl \
    python3.15 \
    python3.15-dev \
    python3.15-venv \
    libffi-dev