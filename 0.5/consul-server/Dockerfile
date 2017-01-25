FROM zendesk/consul-agent:0.5.2
ENV CONSUL_SERVER 1
ENV CONSUL_DNS_ALLOW_STALE 0
ENV CONSUL_DNS_MAX_STALE ""
ENV CONSUL_UI_DIR /ui
ADD https://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip /tmp/webui.zip
RUN cd /tmp && unzip webui.zip && mv dist /ui && rm webui.zip
ENTRYPOINT ["/bin/consul_launcher"]
