FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-l", "-c"]

RUN useradd -ms /bin/bash docker
RUN chmod 777 /home/docker


RUN apt-get update && apt-get upgrade -y && apt-get -y install \
    autoconf \
    git \
    wget \
    curl \
    cmake \
    build-essential \
    python2.7 python-dev \
    libopenmpi-dev openmpi-bin \
    libpthread-stubs0-dev \
    unzip \
    dos2unix \
    nano \ 
    environment-modules \
    nginx

ENV PANTHEON_BASE_PATH=/home/docker
ENV COMPUTE_ALLOCATION=Clover
# copy the required folders before each step
RUN mkdir /home/docker/clover
COPY clover/sbang.sh /home/docker/clover
COPY clover/setup/ /home/docker/clover/setup/
COPY clover/pantheon/ /home/docker/clover/pantheon/
COPY clover/inputs/ /home/docker/clover/inputs/
WORKDIR /home/docker/clover/

RUN ./sbang.sh setup/install-deps.sh

COPY clover/run/ /home/docker/clover/run/
RUN ./sbang.sh run/run.sh

COPY clover/postprocess/ /home/docker/clover/postprocess/
RUN ./sbang.sh postprocess/postprocess.sh
RUN ./sbang.sh postprocess/timestamp.sh


COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
ENTRYPOINT ["nginx","-g","daemon off;"]
