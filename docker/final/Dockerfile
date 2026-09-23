####################################
########### Final image ############
####################################

FROM dev-container:base

ARG PROJECT_DIR

# to allow container reset
ENV DEV_CONTAINER_PROJECT_DIR=${PROJECT_DIR}

RUN echo ${PWD} && ls -lR

COPY --chmod=755 ../projects/${PROJECT_DIR}/install.sh /tmp/install.sh

RUN /tmp/install.sh

ENTRYPOINT ["/bin/bash"]

# CMD
