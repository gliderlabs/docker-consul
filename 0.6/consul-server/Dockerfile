FROM masakazuwatanabe/consul-agent:0.6
ADD ./config /config/
ADD https://dl.bintray.com/mitchellh/consul/0.6.0_web_ui.zip /tmp/webui.zip
RUN cd /tmp && unzip webui.zip && mv dist /ui && rm webui.zip
ENTRYPOINT ["/bin/consul", "agent", "-server", "-config-dir=/config"]
