FROM 234348545939.dkr.ecr.eu-west-1.amazonaws.com/wehkamp/alpine:3.13.2
LABEL container.name="wehkamp/consul:1.8.9"

ENV CONSUL_VERSION 1.8.9

RUN wget -q -O /tmp/consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip \
    && cd /tmp \
    && unzip consul.zip \
    && mv consul /bin/consul \
    && rm /tmp/consul.zip

RUN apk update && apk add bash curl tini

VOLUME ["/config.d"]

RUN mkdir /config

ADD ./config/consul.json /config/consul.json
ONBUILD ADD ./config /config/

ADD ./start /bin/start

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

ENTRYPOINT ["tini", "--", "/bin/start"]
CMD []
