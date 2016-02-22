FROM alpine:latest

ENV H2O_VERSION 1.7.0
ENV H2O_SHA256 b905cd4c99f150495d7252cc911cfd05285dc8aa1874ffc078e57185b7b3f613d5d0ab7950198d1431e1ed610371f3bee282f7dfef65f1575cf333267ebafa06

RUN apk --no-cache add entr --repository http://nl.alpinelinux.org/alpine/edge/testing

# Download, Build, and Install the H2O Web Server
RUN set -x \
    && apk --no-cache add perl openssl \
    && apk --no-cache add --virtual build-dependencies build-base linux-headers cmake zlib-dev wget ca-certificates \
    && mkdir -p /tmp/h2o/ \
    && mkdir -p /tmp/h2o/src \
    && mkdir -p /tmp/h2o/build \
    && wget -q https://github.com/h2o/h2o/archive/v${H2O_VERSION}.tar.gz \
        -O /tmp/h2o/h2o-${H2O_VERSION}.tar.gz \
    && echo "${H2O_SHA256}  /tmp/h2o/h2o-${H2O_VERSION}.tar.gz" | shasum -a 512 -c - \
    && tar zxf /tmp/h2o/h2o-${H2O_VERSION}.tar.gz -C /tmp/h2o/src/ \
    && cmake -DWITH_BUNDLED_SSL=on -DWITH_MRUBY=off -H/tmp/h2o/src/h2o-${H2O_VERSION}/ -B/tmp/h2o/build/ \
    && make -C /tmp/h2o/build/ install \
    && rm -rf /tmp/h2o \
    && apk del build-dependencies


# Add the configuration for H2O
ADD h2o.conf /etc/h2o.conf

# This is a web container that will expose Port 80 and Port 443 to handle HTTP
# and HTTPS Traffic.
EXPOSE 80 443

# When this container runs, it's going to run the h2o binary, defaulting to our
# standard configuration file.
CMD ls /srv/tls/certs/*.pem | entr -r h2o -c /etc/h2o.conf
