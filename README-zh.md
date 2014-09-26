# Consul Agent in Docker

这个项目是一个为[Consul](http://www.consul.io/)做的Docker的容器。他是一个预配置的包含针对Docker生态圈的Consul Agent.

# 得到container
（译注：其实是images， 这篇readme里的container在我来说指代的都是image）

这个container很小（大约50MB， 是基于 [Busybox](https://github.com/progrium/busybox)）可以从docker 目录中直接得到：

	$ docker pull progrium/consul

## 使用container

#### 如何尝鲜

如果你只是想试试看一个单独的consul agent的功能可以使用下面的命令：

	$ docker run -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h node1 progrium/consul -server -bootstrap

我们暴露出了 8400(RPC), 8500(HTTP) 和 8600(DNS)， 这样你就可以试验这三种接口了。我们为container还起了node1的名字。给container起名字是为了给Consul Agent节点命名。

我们推荐的方式是通过curl访问 HTTP 接口 

	$ curl localhost:8500/v1/catalog/nodes

我们也可以用dig来和DNS接口进行交互

	$ dig @0.0.0.0 -p 8600 node1.node.consul

但是， 如果你在你的宿主机上已经安装了Consul， 你可以用命令行来和容器里的Consul Agent进行交互

	$ consul members

#### 在一个主机上测试Consul集群
如果你希望在一台主机上测试Consul集群， 体验一下集群的动态特性（例如数据在多点同步，leader的选举），这里以我们推荐的启动一个三个节点的集群的方式

这里我们启动第一个节点的时候没有使用了 `-bootstrap` 参数， 而是使用了 `-bootstrap-expect 3`, 使用这个参数节点会等到所有三个端都连接到一起了才会启动并且成为一个可用的cluster。

	$ docker run -d --name node1 -h node1 progrium/consul -server -bootstrap-expect 3

我们需要知道这个container的内部IP， 使用下面的命令我们吧这个IP放到了环境变量 `JOIN_IP` 里。（译注：把配置信息放到环境变量是 12factor app的实际指导）（译注：下面奇怪的语法可以查阅docker的文档， 基本上是用了golang template的语法 ）

	$ JOIN_IP="$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' node1)"

紧接着我们启动 `node2`并且告诉他通过 `$JOIN_IP` 加入到 `node1`

	$ docker run -d --name node2 -h node2 progrium/consul -server -join $JOIN_IP

以同样的方法我们启动 `node3`

	$ docker run -d --name node3 -h node3 progrium/consul -server -join $JOIN_IP

现在我们就有了一个拥有3个节点的运行在一台机器上的集群。注意， 我们根据Consul Agent的名字给container起了名字。（译注： docker 的--name 参数和 给entrypoint的 -h 参数的值是一样的）

我们没有暴露出任何一个端口用以访问这个集群， 但是我们可以使用第四个agent节点以client的模式（不是用 -server参数）。这意味着他不参与选举但是可以和集群交互。（译注: 参与选举说的应该是选举leader的时候， 他没有话语权）而且这个client模式的agent也不需要磁盘做持久化。（译注：就是一个交互的通道）

	$ docker run -d -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h node4 progrium/consul -join $JOIN_IP

现在我们可以就可以通过这几个暴露的端口和集群交互了， 如果你愿意， 也可以试着杀死、添加或者重启集群中的几个节点看看集群是如何管理这些节点的。

####  在生产环境运行Consul集群

部署Consul集群到多个单独的主机和在一台主机上部署是很类似的， 不同之处在于：

 * 我们假设主机是在一个私有网络里的， 每一个主机都要有一个自己的这个私有网络的IP
 * 我们通过 `-advertise` 参数吧这个IP告知给容器中的Consul Agent
 * 我们会把Consul的所有端口都暴露到这个IP上， 包括一些内部端口（8300， 8301， 8302）
 * 我们设置了一个Volume到 `/data` 用以持久化。在下面的例子里我们把本地的 `/mnt` 挂载到了这个 Volume上

假设我们在一个私有IP地址为 10.0.0.1的主机上， 我们可以用下面的命令启动我们第一个主机 agent：


	$ docker run -d -h node1 -v /mnt:/data \
		-p 10.0.1.1:8300:8300 \
		-p 10.0.1.1:8301:8301 \
		-p 10.0.1.1:8301:8301/udp \
		-p 10.0.1.1:8302:8302 \
		-p 10.0.1.1:8302:8302/udp \
		-p 10.0.1.1:8400:8400 \
		-p 10.0.1.1:8500:8500 \
		-p 10.0.1.1:8600:53/udp \
		progrium/consul -server -advertise 10.0.1.1 -bootstrap-expect 3

在第二个主机上我们类似的运行另外一个agent， 不同的是使用  `-join` 参数让他加入到第一个节点. 假设第二个主机的IP为10.0.0.2:

	$ docker run -d -h node2 -v /mnt:/data  \
		-p 10.0.1.2:8300:8300 \
		-p 10.0.1.2:8301:8301 \
		-p 10.0.1.2:8301:8301/udp \
		-p 10.0.1.2:8302:8302 \
		-p 10.0.1.2:8302:8302/udp \
		-p 10.0.1.2:8400:8400 \
		-p 10.0.1.2:8500:8500 \
		-p 10.0.1.2:8600:53/udp \
		progrium/consul -server -advertise 10.0.1.2 -join 10.0.1.1

同理， 第三个主机的IP是 10.0.1.3:

	$ docker run -d -h node3 -v /mnt:/data  \
		-p 10.0.1.3:8300:8300 \
		-p 10.0.1.3:8301:8301 \
		-p 10.0.1.3:8301:8301/udp \
		-p 10.0.1.3:8302:8302 \
		-p 10.0.1.3:8302:8302/udp \
		-p 10.0.1.3:8400:8400 \
		-p 10.0.1.3:8500:8500 \
		-p 10.0.1.3:8600:53/udp \
		progrium/consul -server -advertise 10.0.1.3 -join 10.0.1.1

搞定！当第三个个节点加入到集群之后， 整个集群就会启动。现在我们有了一个工作的， 部署在不同主机上的Consule的集群了。

## 特别功能

#### 运行命令

因为启动生产环境的 `docker run` 命令太长，可以使用一个命令来生成这个命令。运行  `cmd:run <advertise-ip>[::<join-ip>[::client]] [docker-run-args...]` 会生成一个启动docker的命令

	$docker run --rm progrium/consul cmd:run 10.0.1.1 -d

生成:

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


这个命令有意的把container的host名字和宿主机的hostname设置为一致的， 同时container的名字被命名为 `consul`（这个名字是可以修改的）, 还把端口53帮到了Docker bridge。 (译注： docker bridge 是docker和宿主机网络通讯的渠道 [docker 网络](https://docs.docker.com/articles/networking/)， 运行ifconfig docker0可以看到)。 其他的端口都绑定到了 advertise IP上。（译注：就是宿主机的IP ifconfig eth0）。如果没有指定 join IP 就会以 `-bootstrap-expect`运行， 默认值为3。 下面是另外一个例子指定了Join IP 还加入了更多的dockr run的参数:

	$ docker run --rm progrium/consul cmd:run 10.0.1.1::10.0.1.2 -d -v /mnt:/data

输出:

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

你可以注意到你只能使用 bootstrap-expect 或者 join， 不能同时使用两者。 使用 `cmd:run` 假设你打算通过第一个节点启动，并且期望一共3个节点。你可以通过设置 `EXPECT` 修改期望的节点数.

你可以通过把 `cmd:run` 包在一个子shell中来使用这个便利的方法。运行下面的命令看效果:

	$ $(docker run --rm progrium/consul cmd:run 127.0.0.1 -it)

（译注：我是用 `echo  $(docker run --rm progrium/consul cmd:run 127.0.0.1 -it)看效果的）

##### Client 标记

Client节点允许你在不影响底层gossip protocol的情况下扩张你的cluster（他们代理请求到某一台服务节点并且是无状态的）
启动一个client节点的方法是在运行启动命令的时候加入 `::client` 到 `<advertise-ip>::<join-ip>` 参数上。 例如:

	$ docker run --rm progrium/consul cmd:run 10.0.1.4::10.0.1.2::client -d

这个命令会生成和上面一样的输出， 只是没有了 `-server` 的参数.

#### 使用Consul做健康检查

Consul允许你通过指定一个shell脚本来检测服务的健康状态， 类似于 nagios。作为一个container， 这些脚本运行在container内部， 也就是一个最简的linux环境 Busybox 通过bash或者curl。对于一些用例来说这有很大的局限性，为此我们加入了内建的方便脚本来做Docker系统内部的监控检查。

这些都需要你在启动Consul container的时候把宿主的Docker socket挂载到 `/var/run/docker.sock`

##### 使用 check-http

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
