FROM gliderlabs/consul-agent:1.2
ADD ./config /config/
ENTRYPOINT ["/bin/consul", "agent", "-server", "-config-dir=/config"]
