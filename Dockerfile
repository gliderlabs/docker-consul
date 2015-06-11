FROM progrium/busybox
ENV VERSION 0.5.2 

ADD https://dl.bintray.com/mitchellh/consul/${VERSION}_linux_amd64.zip /tmp/consul.zip
RUN cd /bin && unzip /tmp/consul.zip && chmod +x /bin/consul && rm /tmp/consul.zip

ADD https://dl.bintray.com/mitchellh/consul/${VERSION}_web_ui.zip /tmp/webui.zip
RUN mkdir /ui && cd /ui && unzip /tmp/webui.zip && rm /tmp/webui.zip && mv dist/* . && rm -rf dist

ADD https://get.docker.io/builds/Linux/x86_64/docker-1.6.1 /bin/docker
RUN chmod +x /bin/docker

ADD ./config/opkg.conf /etc/opkg.conf
RUN opkg-install bash ca-certificates curl

RUN cat /etc/ssl/certs/*.crt > /etc/ssl/certs/ca-certificates.crt && \
    sed -i -r '/^#.+/d' /etc/ssl/certs/ca-certificates.crt

ADD ./config /config/
ONBUILD ADD ./config /config/

ADD ./start /bin/start
ADD ./check-http /bin/check-http
ADD ./check-cmd /bin/check-cmd

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

ENV SHELL /bin/bash

ENTRYPOINT ["/bin/start"]
CMD []
