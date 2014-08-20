FROM 		progrium/busybox 
MAINTAINER 	Jeff Lindsay <progrium@gmail.com>

ADD https://dl.bintray.com/mitchellh/consul/0.3.1_linux_amd64.zip /tmp/consul.zip
RUN cd /bin && unzip /tmp/consul.zip && chmod +x /bin/consul && rm /tmp/consul.zip

ADD https://dl.bintray.com/mitchellh/consul/0.3.1_web_ui.zip /tmp/webui.zip
RUN cd /tmp && unzip /tmp/webui.zip && mv dist /ui && rm /tmp/webui.zip

RUN opkg-install curl bash

ADD ./config /config/
ONBUILD ADD ./config /config/

ADD ./start /bin/start

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 53/udp
VOLUME ["/data"]

ENV SHELL /bin/bash

ENTRYPOINT ["/bin/start"]
CMD []
