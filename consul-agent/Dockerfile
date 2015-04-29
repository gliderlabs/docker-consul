FROM gliderlabs/consul:latest
ADD ./config /config/
EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp
ENTRYPOINT ["/bin/consul", "agent", "-config-dir=/config"]
