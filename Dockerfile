FROM wehkamp/alpine:3.6
LABEL container.name="wehkamp/consul:1.0.2"

ENV CONSUL_VERSION 1.0.2

RUN wget -q -O /tmp/consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip \
    && cd /tmp \
    && unzip consul.zip \
    && mv consul /bin/consul \
    && rm /tmp/consul.zip

#RUN wget -q -O /tmp/webui.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip \
#    && mkdir /ui \
#    && cd /ui \
#    && unzip /tmp/webui.zip \
#    && rm /tmp/webui.zip

RUN apk update && apk add bash curl tini

VOLUME ["/config.d"]

RUN mkdir /config

ADD ./config/consul.json /config/consul.json
ONBUILD ADD ./config /config/

ADD ./start /bin/start

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

ENTRYPOINT ["tini", "--", "/bin/start"]
CMD []
