VERSION=0.5

build:
	make -C $(VERSION)/consul
	make -C $(VERSION)/consul-agent
	make -C $(VERSION)/consul-server
