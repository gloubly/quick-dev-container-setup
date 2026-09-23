####################################
############ Base Image ############
####################################

FROM ubuntu:26.04

ARG UID
ARG GID

WORKDIR /workspace

RUN apt-get update && apt-get upgrade -y

# timezone
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

# use non-root user with sudo permission (no password)
RUN apt-get -y install sudo adduser
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN usermod -aG sudo ubuntu
RUN chown ubuntu /workspace
USER ubuntu

# base dependencies
RUN sudo apt-get install -y \
    build-essential \
    cmake \
    git \
    software-properties-common \
    nano \
    wget