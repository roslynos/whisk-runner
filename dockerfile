# base image
FROM ubuntu:20.04

# input GitHub runner version argument
ARG RUNNER_VERSION

ENV DEBIAN_FRONTEND noninteractive

LABEL Author="Bytewizer"
LABEL GitHub="https://github.com/roslynos"
LABEL BaseImage="ubuntu:20.04"
LABEL RunnerVersion=${RUNNER_VERSION}

# add a non-sudo user
RUN useradd -m docker

# install the packages and dependencies
RUN apt-get update -y && \
  apt-get install -y apt-utils 2>&1 | grep -v "debconf: delaying package configuration, since apt-utils is not installed" && \
  apt-get install -y --no-install-recommends \
    curl gawk wget git diffstat unzip texinfo gcc build-essential \
    chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils \
    iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
    xterm python3-subunit mesa-common-dev zstd liblz4-tool file liblttng-ust0

# install english language pack
RUN apt-get install -yq  language-pack-en

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
# RUN /home/docker/actions-runner/bin/installdependencies.sh

# add over the start.sh script
ADD scripts/start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]

ENV DEBIAN_FRONTEND teletype