FROM ubuntu:20.04
ARG PIP=pip3
ARG PYTHON=python3
# nginx + njs
RUN apt-get update \
 # TODO: Remove systemd upgrade once it is updated in base image
 && apt-get -y upgrade --only-upgrade systemd \
 && apt-get -y install --no-install-recommends \
    curl \
    gnupg2 \
    wget \
    ca-certificates \
    python3 \
    python3-pip \
 && rm -rf /var/lib/apt/lists/*

RUN ln -s $(which ${PYTHON}) /usr/local/bin/python

RUN apt-get update
RUN apt-get update \
 && apt-get -y install --no-install-recommends \
    jq \
    awscli \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN echo "deb https://apt.repos.neuron.amazonaws.com focal main" > /etc/apt/sources.list.d/neuron.list
RUN wget -qO - https://apt.repos.neuron.amazonaws.com/GPG-PUB-KEY-AMAZON-AWS-NEURON.PUB | apt-key add -
RUN apt-get update -y 
RUN apt-get install linux-headers-$(uname -r) -y \
    git -y \
    aws-neuronx-dkms=2.* -y \
    aws-neuronx-tools=2.* -y \
    aws-neuronx-tools \
    aws-neuronx-runtime-lib \
    aws-neuronx-collectives
ENV PATH="$PATH:/opt/aws/neuron/bin"
RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN ${PIP} --no-cache-dir install --upgrade \
    pip \
    setuptools
# pip install statements have been separated out into multiple sequentially executed statements to
# resolve package dependencies during installation.
RUN ${PIP} install transformers
RUN ${PIP} install joblib
COPY FSscripts2.tar.gz /.
RUN ${PIP} install --extra-index-url https://pip.repos.neuron.amazonaws.com neuronx-cc==2.*
RUN ${PIP} install --extra-index-url https://pip.repos.neuron.amazonaws.com tensorflow-neuronx
RUN ${PIP} install --no-deps tensorflow-serving-api
RUN apt-get update
RUN apt-get install -y \
    tensorflow-model-server-neuronx \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN tar xvzf FSscripts2.tar.gz
RUN chmod +x ./benchmark-roberta.py \
 && chmod +x ./benchmark-roberta.sh \
 && chmod +x ./tfs-driver.sh
CMD ["/bin/bash",  "tfs-driver.sh"]
