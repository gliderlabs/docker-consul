#!/bin/bash 

consul='consul'

### CONSUL SERVER MODE
docker run -d -p 8500:8500 --name $consul -h $consul progrium/consul -server -bootstrap

### GET IP CONSUL SERVER
JOIN_IP="$(docker inspect -f '{{.NetworkSettings.IPAddress}}' $consul)"

### SIMULATE ONE CONSUL AGENT MODE
docker run -d --name node1 -h node1 -v $PWD/node1.json:/config/consul.json  progrium/consul -join $JOIN_IP
docker run -d --name node2 -h node1 -v $PWD/node2.json:/config/consul.json  progrium/consul -join $JOIN_IP
docker run -d --name node3 -h node1 -v $PWD/node3.json:/config/consul.json  progrium/consul -join $JOIN_IP

### SIMULATE ONE SERVICE
docker run -d --name apache1 nimmis/alpine-apache
docker run -d --name apache2 nimmis/alpine-apache
docker run -d --name apache3 nimmis/alpine-apache

