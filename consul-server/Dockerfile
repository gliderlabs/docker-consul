FROM gliderlabs/consul-agent:latest
ADD ./config /config/
ADD https://dl.bintray.com/mitchellh/consul/0.5.0_web_ui.zip /tmp/webui.zip
RUN cd /tmp && unzip webui.zip && mv dist /ui && rm webui.zip
ENTRYPOINT ["/bin/consul", "agent", "-server", "-config-dir=/config"]
