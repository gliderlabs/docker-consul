FROM 		progrium/busybox
MAINTAINER 	Jeff Lindsay <progrium@gmail.com>

ADD https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip /tmp/consul.zip
RUN cd /bin && unzip /tmp/consul.zip && chmod +x /bin/consul && rm /tmp/consul.zip

ADD https://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip /tmp/webui.zip
RUN mkdir /ui && cd /ui && unzip /tmp/webui.zip && rm /tmp/webui.zip && mv dist/* . && rm -rf dist

ADD https://get.docker.io/builds/Linux/x86_64/docker-1.6.1 /bin/docker
RUN chmod +x /bin/docker

RUN opkg-install curl bash ca-certificates

RUN cat /etc/ssl/certs/*.crt > /etc/ssl/certs/ca-certificates.crt && \
    sed -i -r '/^#.+/d' /etc/ssl/certs/ca-certificates.crt

ADD ./config /config/
ONBUILD ADD ./config /config/

ADD ./start /bin/start
ADD ./check-http /bin/check-http
ADD ./check-cmd /bin/check-cmd

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 53 53/udp
VOLUME ["/data"]

ENV SHELL /bin/bash

ENTRYPOINT ["/bin/start"]
CMD []
