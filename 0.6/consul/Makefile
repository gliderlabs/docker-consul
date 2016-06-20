
build:
	docker build -t gliderlabs/consul:$(VERSION) \
							 --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
							 --build-arg VCS_REF=`git rev-parse --short HEAD` .