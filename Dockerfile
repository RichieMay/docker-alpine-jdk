# AlpineLinux 3.15.0 with a glibc-2.32-r0 and Oracle JDK8u301
FROM alpine:3.15.0
MAINTAINER RichieMay mayboe@gmail.com

# Set useful environment variables
ENV LANG                en_US.UTF-8
ENV LC_ALL              en_US.UTF-8
ENV ALPINE_OS_VERSION   3.15.0
ENV JDK_VERSION_MAJOR   8
ENV JDK_VERSION_MINOR   301

# Arguments
ARG JDK_PACKAGE_NAME=jdk
ARG JDK_DOWNLOAD_URL=https://d6.injdk.cn/oraclejdk
ARG ALPINE_GLIBC_VERSION=2.32-r0
ARG ALPINE_GLIBC_PACKAGE=glibc-${ALPINE_GLIBC_VERSION}.apk
ARG ALPINE_GLIBC_DOWNLOAD_URL=https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${ALPINE_GLIBC_VERSION}

# Change repositories in china
RUN echo "http://mirrors.ustc.edu.cn/alpine/v3.15/main" > "/etc/apk/repositories" && \
    echo "http://mirrors.ustc.edu.cn/alpine/v3.15/community" >> "/etc/apk/repositories"

# Install glibc and hotfix /etc/nsswitch.conf
RUN apk add --no-cache --virtual=build-dependencies wget ca-certificates tar && \
    wget "$ALPINE_GLIBC_DOWNLOAD_URL/${ALPINE_GLIBC_PACKAGE}" && \
    apk add --no-cache --allow-untrusted "${ALPINE_GLIBC_PACKAGE}" && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    apk del build-dependencies && \
    rm -rf "${ALPINE_GLIBC_PACKAGE}"

# Install helper tools and oracle jdk
RUN mkdir -p /opt && apk add --no-cache bash curl tar unzip busybox-extras && \
    curl -jksSL "${JDK_DOWNLOAD_URL}/${JDK_VERSION_MAJOR}/${JDK_PACKAGE_NAME}-${JDK_VERSION_MAJOR}u${JDK_VERSION_MINOR}-linux-x64.tar.gz" | \
    tar -zxf - -C /opt

# Set java environment
ENV JAVA_HOME /opt/${JDK_PACKAGE_NAME}1.${JDK_VERSION_MAJOR}.0_${JDK_VERSION_MINOR}
ENV PATH      ${PATH}:${JAVA_HOME}/bin
