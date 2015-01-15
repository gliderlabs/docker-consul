# Consul Agent in Docker

This project is a Docker container for [Consul](http://www.consul.io/). It's a slightly opinionated, pre-configured Consul Agent made specifically to work in the Docker ecosystem.

## Getting the container

The container is very small (50MB virtual, based on [Busybox](https://github.com/progrium/busybox)) and available on the Docker Index:

	$ docker pull progrium/consul

## Using the container

#### Just trying out Consul

If you just want to run a single instance of Consul Agent to try out its functionality:

	$ docker run -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h node1 progrium/consul -server -bootstrap

The [Web UI](http://www.consul.io/intro/getting-started/ui.html) can be enabled by adding the `-ui-dir` flag:

	$ docker run -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h node1 progrium/consul -server -bootstrap -ui-dir /ui

We publish 8400 (RPC), 8500 (HTTP), and 8600 (DNS) so you can try all three interfaces. We also give it a hostname of `node1`. Setting the container hostname is the intended way to name the Consul Agent node. 

Our recommended interface is HTTP using curl:

	$ curl localhost:8500/v1/catalog/nodes

We can also use dig to interact with the DNS interface:

	$ dig @0.0.0.0 -p 8600 node1.node.consul

However, if you install Consul on your host, you can use the CLI interact with the containerized Consul Agent:

	$ consul members

#### Testing a Consul cluster on a single host

If you want to start a Consul cluster on a single host to experiment with clustering dynamics (replication, leader election), here is the recommended way to start a 3 node cluster. 

Here we start the first node not with `-bootstrap`, but with `-bootstrap-expect 3`, which will wait until there are 3 peers connected before self-bootstrapping and becoming a working cluster.

	$ docker run -d --name node1 -h node1 progrium/consul -server -bootstrap-expect 3

We can get the container's internal IP by inspecting the container. We'll put it in the env var `JOIN_IP`.

	$ JOIN_IP="$(docker inspect -f '{{.NetworkSettings.IPAddress}}' node1)"

Then we'll start `node2` and tell it to join `node1` using `$JOIN_IP`:

	$ docker run -d --name node2 -h node2 progrium/consul -server -join $JOIN_IP

Now we can start `node3` the same way:

	$ docker run -d --name node3 -h node3 progrium/consul -server -join $JOIN_IP

We now have a real three node cluster running on a single host. Notice we've also named the containers after their internal hostnames / node names.

We haven't published any ports to access the cluster, but we can use that as an excuse to run a fourth agent node in "client" mode (dropping the `-server`). This means it doesn't participate in the consensus quorum, but can still be used to interact with the cluster. It also means it doesn't need disk persistence.

	$ docker run -d -p 8400:8400 -p 8500:8500 -p 8600:53/udp --name node4 -h node4 progrium/consul -join $JOIN_IP

Now we can interact with the cluster on those published ports and, if you want, play with killing, adding, and restarting nodes to see how the cluster handles it.

#### Running a real Consul cluster in a production environment

Setting up a real cluster on separate hosts is very similar to our single host cluster setup process, but with a few differences:

 * We assume there is a private network between hosts. Each host should have an IP on this private network
 * We're going to pass this private IP to Consul via the `-advertise` flag
 * We're going to publish all ports, including internal Consul ports (8300, 8301, 8302), on this IP
 * We set up a volume at `/data` for persistence. As an example, we'll bind mount `/mnt` from the host

Assuming we're on a host with a private IP of 10.0.1.1 and the IP of docker bridge docker0 is 172.17.42.1 we can start the first host agent:

	$ docker run -d -h node1 -v /mnt:/data \
		-p 10.0.1.1:8300:8300 \
		-p 10.0.1.1:8301:8301 \
		-p 10.0.1.1:8301:8301/udp \
		-p 10.0.1.1:8302:8302 \
		-p 10.0.1.1:8302:8302/udp \
		-p 10.0.1.1:8400:8400 \
		-p 10.0.1.1:8500:8500 \
		-p 172.17.42.1:53:53/udp \
		progrium/consul -server -advertise 10.0.1.1 -bootstrap-expect 3

On the second host, we'd run the same thing, but passing a `-join` to the first node's IP. Let's say the private IP for this host is 10.0.1.2:

	$ docker run -d -h node2 -v /mnt:/data  \
		-p 10.0.1.2:8300:8300 \
		-p 10.0.1.2:8301:8301 \
		-p 10.0.1.2:8301:8301/udp \
		-p 10.0.1.2:8302:8302 \
		-p 10.0.1.2:8302:8302/udp \
		-p 10.0.1.2:8400:8400 \
		-p 10.0.1.2:8500:8500 \
		-p 172.17.42.1:53:53/udp \
		progrium/consul -server -advertise 10.0.1.2 -join 10.0.1.1

And the third host with an IP of 10.0.1.3:

	$ docker run -d -h node3 -v /mnt:/data  \
		-p 10.0.1.3:8300:8300 \
		-p 10.0.1.3:8301:8301 \
		-p 10.0.1.3:8301:8301/udp \
		-p 10.0.1.3:8302:8302 \
		-p 10.0.1.3:8302:8302/udp \
		-p 10.0.1.3:8400:8400 \
		-p 10.0.1.3:8500:8500 \
		-p 172.17.42.1:53:53/udp \
		progrium/consul -server -advertise 10.0.1.3 -join 10.0.1.1

That's it! Once this last node connects, it will bootstrap into a cluster. You now have a working cluster running in production on a private network.

## Special Features

#### Runner command

Since the `docker run` command to start in production is so long, a command is available to generate this for you. Running with `cmd:run <advertise-ip>[::<join-ip>[::client]] [docker-run-args...]` will output an opinionated, but customizable `docker run` command you can run in a subshell. For example:

	$ docker run --rm progrium/consul cmd:run 10.0.1.1 -d

Outputs:

	eval docker run --name consul -h $HOSTNAME 	\
		-p 10.0.1.1:8300:8300 \
		-p 10.0.1.1:8301:8301 \
		-p 10.0.1.1:8301:8301/udp \
		-p 10.0.1.1:8302:8302 \
		-p 10.0.1.1:8302:8302/udp \
		-p 10.0.1.1:8400:8400 \
		-p 10.0.1.1:8500:8500 \
		-p 172.17.42.1:53:53/udp \
		-d 	\
		progrium/consul -server -advertise 10.0.1.1 -bootstrap-expect 3

By design, it will set the hostname of the container to your host hostname, it will name the container `consul` (though this can be overridden), it will bind port 53 to the Docker bridge, and the rest of the ports on the advertise IP. If no join IP is provided, it runs in `-bootstrap-expect` mode with a default of 3 expected peers. Here is another example, specifying a join IP and setting more docker run arguments:

	$ docker run --rm progrium/consul cmd:run 10.0.1.1::10.0.1.2 -d -v /mnt:/data

Outputs:

	eval docker run --name consul -h $HOSTNAME 	\
		-p 10.0.1.1:8300:8300 \
		-p 10.0.1.1:8301:8301 \
		-p 10.0.1.1:8301:8301/udp \
		-p 10.0.1.1:8302:8302 \
		-p 10.0.1.1:8302:8302/udp \
		-p 10.0.1.1:8400:8400 \
		-p 10.0.1.1:8500:8500 \
		-p 172.17.42.1:53:53/udp \
		-d -v /mnt:/data \
		progrium/consul -server -advertise 10.0.1.1 -join 10.0.1.2

You may notice it lets you only run with bootstrap-expect or join, not both. Using `cmd:run` assumes you will be bootstrapping with the first node and expecting 3 nodes. You can change the expected peers before bootstrap by setting the `EXPECT` environment variable.

To use this convenience, you simply wrap the `cmd:run` output in a subshell. Run this to see it work:

	$ $(docker run --rm progrium/consul cmd:run 127.0.0.1 -it)

##### Client flag

Client nodes allow you to keep growing your cluster without impacting the performance of the underlying gossip protocol (they proxy requests to one of the server nodes and so are stateless).

To boot a client node using the runner command, append the string `::client` onto the `<advertise-ip>::<join-ip>` argument.  For example:

	$ docker run --rm progrium/consul cmd:run 10.0.1.4::10.0.1.2::client -d

Would create the same output as above but without the `-server` consul argument.

#### Health checking with Docker

Consul lets you specify a shell script to run for health checks, similar to Nagios. As a container, those scripts run inside this container environment which is a minimal Busybox environment with bash and curl. For some, this is fairly limiting, so I've added some built-in convenience scripts to properly do health checking in a Docker system. 

These all require you to mount the host's Docker socket to `/var/run/docker.sock` when you run the Consul container.

##### Using check-http

	check-http <container-id> <port> <path> [curl-args...]

This utility performs `curl` based HTTP health checking given a container ID or name, an internal port (what the service is actually listening on inside the container) and a path. You can optionally provide extra arguments to `curl`. 

The HTTP request is done in a separate ephemeral container that is attached to the target container's network namespace. The utility automatically determines the internal Docker IP to run the request against. A successful request will output the response headers into Consul. An unsuccessful request will output the reason the request failed and set the check to critical. By default, `curl` runs with `--retry 2` to cover local transient errors. 

##### Using check-cmd

	check-cmd <container-id> <port> <command...>

This utility performs the specified command in a separate ephemeral container based on the target container's image that is attached to that container's network namespace. Very often, this is expected to be a health check script, but can be anything that can be run as a command on this container image. For convenience, an environment variable `SERVICE_ADDR` is set with the internal Docker IP and port specified here. 

##### Using docker

The above health check utilities require the Docker binary, so it's already built-in to the container. If neither of the above fit your needs, and the container environment is too limiting, you can perform Docker operations directly to perform any containerized health check.

#### DNS

This container was designed assuming you'll be using it for DNS on your other containers. So it listens on port 53 inside the container to be more compatible and accessible via linking. It also has DNS recursive queries enabled, using the Google 8.8.8.8 nameserver.

When running with `cmd:run`, it publishes the DNS port on the Docker bridge. You can use this with the `--dns` flag in `docker run`, or better yet, use it with the Docker daemon options. Here is a command you can run on Ubuntu systems that will tell Docker to use the bridge IP for DNS, otherwise use Google DNS, and use `service.consul` as the search domain. 

	$ echo "DOCKER_OPTS='--dns 172.17.42.1 --dns 8.8.8.8 --dns-search service.consul'" >> /etc/default/docker

If you're using [boot2docker](http://boot2docker.io/) on OS/X, rather than an Ubuntu host, it has a Tiny Core Linux VM running the docker containers. Use this command to set the extra Docker daemon options (as of boot2docker v1.3.1), which also uses the first DNS name server that your OS/X machine uses for name resolution outside of the boot2docker world.

	$ boot2docker ssh sudo "ash -c \"echo EXTRA_ARGS=\'--dns 172.17.42.1 --dns $(scutil --dns | awk -F ': ' '/nameserver/{print $2}' | head -1) --dns-search service.consul\' > /var/lib/boot2docker/profile\""

With those extra options in place, within a Docker container, you have the appropriate entries automatically set in the `/etc/resolv.conf` file. To test it out, start a Docker container that has the `dig` utility installed (this example uses [aanand/docker-dnsutils](https://registry.hub.docker.com/u/aanand/docker-dnsutils/) which is the Ubuntu image with dnsutils installed).

	$ docker run --rm aanand/docker-dnsutils dig -t SRV consul +search

#### Runtime Configuration

Although you can extend this image to add configuration files to define services and checks, this container was designed for environments where services and checks can be configured at runtime via the HTTP API. 

It's recommended you keep your check logic simple, such as using inline `curl` or `ping` commands. Otherwise, keep in mind the default shell is Bash, but you're running in Busybox.

If you absolutely need to customize startup configuration, you can extend this image by making a new Dockerfile based on this one and having a `config` directory containing config JSON files. They will be added to the image you build via ONBUILD hooks. You can also add packages with `opkg`. See [docs on the Busybox image](https://github.com/progrium/busybox) for more info.

## Quickly restarting a node using the same IP issue

When testing a cluster scenario, you may kill a container and restart it again on the same host and see that it has trouble re-joining the cluster.

There is an issue when you restart a node as a new container with the same published ports that will cause heartbeats to fail and the node will flap. This is an ARP table caching problem. If you wait about 3 minutes before starting again, it should work fine. You can also manually reset the cache.

## Sponsor

This project was made possible thanks to [DigitalOcean](http://digitalocean.com).

## License

BSD
