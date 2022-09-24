# The MIT License
#
#  Copyright (c) 2015-2017, CloudBees, Inc.
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

ARG version=4.10-2-jdk11
ARG terraform_version=1.1.4
ARG packer_version=1.7.9
ARG helm_version=3.8.0

FROM quay.io/centos/centos:stream8

ARG version
ARG terraform_version
ARG packer_version
ARG helm_version

LABEL Description="This is a base image, which allows connecting Jenkins agents via JNLP protocols" Vendor="Jenkins project" Version="$version"

ARG user=jenkins

RUN groupadd -g 1000 ${user} &&\
    useradd ${user} -u 1000 -g 1000 -c "Jenkins user" -d /var/lib/jenkins &&\
    groupadd -g 982 docker &&\
    usermod -aG docker ${user} &&\
    dnf -y clean all &&\
    dnf -y install epel-release &&\
    dnf -y update &&\
    dnf group install -y "Development Tools" &&\
    dnf install -y --enablerepo=epel --enablerepo=powertools \
                    sudo \
                    gcc \
                    make \
                    autoconf \
                    automake \
                    libtool \
                    rpm-build \
                    libtirpc-devel \
                    libblkid-devel \
                    libuuid-devel \
                    libudev-devel \
                    openssl-devel \
                    zlib-devel \
                    libaio-devel \
                    libattr-devel \
                    elfutils-libelf-devel \
                    kernel-devel \
                    python3 \
                    python3-devel \
                    python3-setuptools \
                    python3-cffi \
                    libffi-devel \
                    git \
                    ncompress \
                    libcurl-devel \
                    python3-packaging \
                    dkms \
                    gem \
                    ruby \
                    ruby-devel \
                    gcc-c++ \
                    wget \
                    curl \
                    unzip \
                    gnupg \
                    jq \
                    java-11-openjdk.x86_64 \
                    yum-utils &&\
                    yum remove docker \
                    docker-client \
                    docker-client-latest \
                    docker-common \
                    docker-latest \
                    docker-latest-logrotate \
                    docker-logrotate \
                    docker-engine &&\
    gem install package_cloud &&\
    curl -sL https://rpm.nodesource.com/setup_16.x | bash - &&\
    dnf install -y nodejs &&\
    npm install -g --update npm &&\
    npm update -g &&\
    curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo &&\
    dnf install -y yarn &&\
    wget https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip &&\
    unzip terraform_${terraform_version}_linux_amd64.zip &&\
    mv terraform /usr/local/bin/terraform &&\
    rm terraform_${terraform_version}_linux_amd64.zip &&\
    wget https://releases.hashicorp.com/packer/${packer_version}/packer_${packer_version}_linux_amd64.zip &&\
    unzip packer_${packer_version}_linux_amd64.zip &&\
    mv packer /usr/local/bin/packer &&\
    rm packer_${packer_version}_linux_amd64.zip &&\
    wget https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz &&\
    tar -xf helm-v${helm_version}-linux-amd64.tar.gz &&\
    mv linux-amd64/helm /usr/local/bin/helm &&\
    rm -rf linux-amd64 helm-v${helm_version}-linux-amd64.tar.gz &&\
    wget https://raw.githubusercontent.com/jenkinsci/docker-inbound-agent/master/jenkins-agent &&\
    mv jenkins-agent /usr/local/bin/jenkins-agent &&\
    chmod +x /usr/local/bin/jenkins-agent &&\
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave &&\
    dnf -y update &&\
    dnf -y clean all &&\
    gem install package_cloud

USER ${user}

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
