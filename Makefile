VERSION=0.6

build:
	VERSION=$(VERSION) make -C $(VERSION)/consul
	VERSION=$(VERSION) make -C $(VERSION)/consul-agent
	VERSION=$(VERSION) make -C $(VERSION)/consul-server
