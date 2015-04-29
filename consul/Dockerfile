FROM progrium/busybox

ADD https://dl.bintray.com/mitchellh/consul/0.5.0_linux_amd64.zip /tmp/consul.zip
RUN cd /bin && unzip /tmp/consul.zip && chmod +x /bin/consul && rm /tmp/consul.zip

RUN opkg-install ca-certificates && \
    cat /etc/ssl/certs/*.crt > /etc/ssl/certs/ca-certificates.crt && \
    sed -i -r '/^#.+/d' /etc/ssl/certs/ca-certificates.crt

ENTRYPOINT ["/bin/consul"]
