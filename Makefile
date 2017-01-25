VERSION=0.7

build:
	VERSION=$(VERSION) make -C $(VERSION)/consul
	VERSION=$(VERSION) make -C $(VERSION)/consul-agent
	VERSION=$(VERSION) make -C $(VERSION)/consul-server

dockerhub:
	glu hubtag gliderlabs/consul $(VERSION) master $(VERSION)/consul
	glu hubtag gliderlabs/consul-server $(VERSION) master $(VERSION)/consul-server/
	glu hubtag gliderlabs/consul-agent $(VERSION) master $(VERSION)/consul-agent/
