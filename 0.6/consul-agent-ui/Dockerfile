FROM gliderlabs/consul:0.6

RUN apk --update add unzip
ADD ./config /config/
ADD https://releases.hashicorp.com/consul/0.6.0/consul_0.6.0_web_ui.zip /tmp/webui.zip
RUN mkdir /ui 
RUN cd /ui && unzip /tmp/webui.zip
RUN rm /tmp/webui.zip 
EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp
ENV DNS_RESOLVES consul
ENV DNS_PORT 8600
ENTRYPOINT ["/bin/consul", "agent", "-config-dir=/config"]
