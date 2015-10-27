FROM wehkamp/alpine:3.2
LABEL container.name="wehkamp/consul:0.5.2"

ENV VERSION 0.5.2
ENV CONSUL_VERSION v0.5.2-deadlock-patches
ENV GOPATH /go
ENV APPPATH $GOPATH/src/github.com/hashicorp

WORKDIR $APPPATH

RUN apk add --update -t build-deps go git libc-dev gcc libgcc build-base bash curl \
    && git clone https://github.com/hashicorp/consul.git

WORKDIR $APPPATH/consul
RUN git checkout ${CONSUL_VERSION} \
    && make \
    && mv bin/consul /bin/consul \
    && wget -q -O /tmp/webui.zip https://dl.bintray.com/mitchellh/consul/${VERSION}_web_ui.zip \
    && mkdir /ui \
    && cd /ui \
    && unzip /tmp/webui.zip \
    && rm /tmp/webui.zip \
    && mv dist/* . \
    && rm -rf dist \
    && wget -q -O /bin/docker https://get.docker.io/builds/Linux/x86_64/docker-1.8.0 \
    && chmod +x /bin/docker \
    && cat /etc/ssl/certs/*.crt > /etc/ssl/certs/ca-certificates.crt \
    && sed -i -r '/^#.+/d' /etc/ssl/certs/ca-certificates.crt

RUN apk del --purge build-deps git go libc-dev gcc libgcc \
    && rm -rf $GOPATH

ADD ./config /config/
ONBUILD ADD ./config /config/

ADD ./start /bin/start
ADD ./check-http /bin/check-http
ADD ./check-cmd /bin/check-cmd

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

ENV SHELL /bin/bash

ENTRYPOINT ["/bin/start"]
CMD []
