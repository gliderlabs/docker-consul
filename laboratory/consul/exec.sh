#!/bin/bash -x

consul='consul'

### CONSUL SERVER MODE
docker run -d -p 8500:8500 --name $consul -h $consul progrium/consul -server -bootstrap

### GET IP CONSUL SERVER
JOIN_IP="$(docker inspect -f '{{.NetworkSettings.IPAddress}}' $consul)"

### SIMULATE ONE CONSUL AGENT MODE

for i in $(seq 1 3); do
  docker run -d --name node${i} -h node${i} -v $PWD/node${i}.json:/config/consul.json  progrium/consul -join $JOIN_IP
  docker run -d --name apache${i} nimmis/alpine-apache
done
