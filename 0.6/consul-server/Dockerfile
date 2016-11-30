FROM gliderlabs/consul-agent:0.6
RUN apk --update add nagios-plugins
ADD ./config /config/
ENTRYPOINT ["/bin/consul", "agent", "-server", "-config-dir=/config"]
