# AlpineLinux 3.15 with a glibc-2.34 and Oracle JDK8u311
FROM alpine:3.15
MAINTAINER RichieMay mayboe@gmail.com

# https://github.com/gliderlabs/docker-alpine/issues/11:
# install glibc
# hotfix /etc/nsswitch.conf

ENV ALPINE_OS_VERSION        3.15
ENV ALPINE_GLIBC_VERSION     2.34-r0
ENV ALPINE_GLIBC_PACKAGE     glibc-${ALPINE_GLIBC_VERSION}.apk
ENV ALPINE_GLIBC_BASE_URL    https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${ALPINE_GLIBC_VERSION}

RUN echo "http://mirrors.ustc.edu.cn/alpine/v3.15/main" > "/etc/apk/repositories" && \
    echo "http://mirrors.ustc.edu.cn/alpine/v3.15/community" >> "/etc/apk/repositories"

RUN apk add --no-cache --virtual=build-dependencies curl ca-certificates tar && \
    curl -o "${ALPINE_GLIBC_PACKAGE}" -L "$ALPINE_GLIBC_BASE_URL/${ALPINE_GLIBC_PACKAGE}" && \
    apk add --no-cache --allow-untrusted "${ALPINE_GLIBC_PACKAGE}" && \
    /sbin/ldconfig "/lib" && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    apk del build-dependencies && \
    rm -rf "${ALPINE_GLIBC_PACKAGE}"

# install oracle jdk
ENV JDK_VERSION_MAJOR 8
ENV JDK_VERSION_MINOR 311
ENV JDK_VERSION_BUILD 11
ENV JDK_PACKAGE_NAME  jdk
ENV JDK_VERSION_HASH  4d5417147a92418ea8b615e228bb6935 
ENV JDK_DOWN_BASE_URL https://download.oracle.com/otn/java/jdk/${JDK_VERSION_MAJOR}u${JDK_VERSION_MINOR}-b${JDK_VERSION_BUILD}

# Download and unarchive Java
RUN mkdir -p /opt && \
    curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie" "${JDK_DOWN_BASE_URL}/${JDK_VERSION_HASH}/${JDK_PACKAGE_NAME}-${JDK_VERSION_MAJOR}u${JDK_VERSION_MINOR}-linux-x64.tar.gz?AuthParam=1638864167_ad0684fd0bbbe2f598fe0678df747d13" | \
    tar -zxf - -C /opt

# Set environment
ENV JAVA_HOME /opt/${JAVA_PACKAGE}1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}
ENV CLASSPATH $JAVA_HOME/bin
ENV PATH      ${PATH}:${JAVA_HOME}/bin
