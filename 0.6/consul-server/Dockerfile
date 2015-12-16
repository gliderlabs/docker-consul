FROM gliderlabs/consul-agent:0.6
ADD ./config /config/
ADD https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip /tmp/webui.zip
RUN cd /tmp && mkdir /ui && unzip webui.zip -d /ui && rm webui.zip
ENTRYPOINT ["/bin/consul", "agent", "-server", "-config-dir=/config"]
