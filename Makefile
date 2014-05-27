
build:
	docker build --no-cache -t consul .

tag:
	docker tag consul progrium/consul