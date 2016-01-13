FROM wehkamp/alpine:3.2
LABEL container.name="wehkamp/consul:0.6.1"

ENV CONSUL_VERSION 0.6.1

RUN wget -q -O /tmp/consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip \
    && cd /tmp \
    && unzip consul.zip \
    && mv consul /bin/consul \
    && rm /tmp/consul.zip

RUN wget -q -O /tmp/webui.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip \
    && mkdir /ui \
    && cd /ui \
    && unzip /tmp/webui.zip \
    && rm /tmp/webui.zip

RUN apk update && apk add bash ca-certificates curl
RUN cat /etc/ssl/certs/*.crt > /etc/ssl/certs/ca-certificates.crt && \
    sed -i -r '/^#.+/d' /etc/ssl/certs/ca-certificates.crt

RUN wget -q -O /bin/docker https://get.docker.io/builds/Linux/x86_64/docker-1.8.0 \
    && chmod +x /bin/docker \
    && cat /etc/ssl/certs/*.crt > /etc/ssl/certs/ca-certificates.crt \
    && sed -i -r '/^#.+/d' /etc/ssl/certs/ca-certificates.crt

VOLUME ["/config.d"]

RUN mkdir /config

ADD ./config/consul.json /config/consul.json
ONBUILD ADD ./config /config/

ADD ./start /bin/start

ADD check-http /bin/check-http
ADD check-cmd /bin/check-cmd

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

ENTRYPOINT ["/bin/start"]
CMD []
