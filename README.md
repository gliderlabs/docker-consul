# Consul Docker images

These are Zendesk's customized Docker images for HashiCorp's Consul.  They're
based on [Glider Labs' original
sources](https://github.com/gliderlabs/docker-consul).

## Lock race fixes

This build contains an [important
fix](https://github.com/hashicorp/consul/compare/master...zendesk:zendesk_0.5.2)
to some race conditions in `consul lock` in the 0.5.2 upstream release.  Our
fix has been accepted by Hashicorp, but no new release has been published yet
that contains it.

## Data persistence

The `/data` directory is now marked as a volume, so that Consul's Raft data can
be preserved across container restarts.  (Of course, you may always start
with a clean slate by removing and recreating the container.)

## Environment variables

The following environment variables can be set to control the way Consul
operates.  Check the [Consul
documentation](https://www.consul.io/docs/agent/options.html) for further
details on how they operate.

For boolean variables, the values `"0"`, `"false"`, and `"n"` all translate to
`false`; and `"1"`, `"true"`, and `"y"` all translate to `true`.

* `CONSUL_ACL_DATACENTER`
* `CONSUL_ACL_DEFAULT_POLICY`
* `CONSUL_ACL_DOWN_POLICY`
* `CONSUL_ACL_MASTER_TOKEN`
* `CONSUL_ACL_TOKEN`
* `CONSUL_ACL_TTL`
* `CONSUL_ADVERTISE_ADDR`
* `CONSUL_ADVERTISE_ADDR_WAN`
* `CONSUL_BOOTSTRAP_EXPECT`
* `CONSUL_CHECK_UPDATE_INTERVAL`
* `CONSUL_DATA_DIR`
* `CONSUL_CLIENT_ADDR`
* `CONSUL_DATACENTER`
* `CONSUL_DISABLE_REMOTE_EXEC`
* `CONSUL_DISABLE_UPDATE_CHECK`
* `CONSUL_DNS_ALLOW_STALE`
* `CONSUL_DNS_ENABLE_TRUNCATE`
* `CONSUL_DNS_MAX_STALE`
* `CONSUL_DNS_NODE_TTL`
* `CONSUL_DNS_ONLY_PASSING`
* `CONSUL_DNS_SERVICE_TTL`
* `CONSUL_DOMAIN`
* `CONSUL_ENCRYPT`
* `CONSUL_LEAVE_ON_TERMINATE`
* `CONSUL_REJOIN_AFTER_LEAVE`
* `CONSUL_RETRY_JOIN`
* `CONSUL_RETRY_INTERVAL`
* `CONSUL_RETRY_INTERVAL_WAN`
* `CONSUL_SERVER`
* `CONSUL_SERVER_NAME`
* `CONSUL_SESSION_TTL_MIN`
* `CONSUL_SKIP_LEAVE_ON_INTERRUPT`
* `CONSUL_START_JOIN`
* `CONSUL_START_JOIN_WAN`
* `CONSUL_STATSD_ADDR`
* `CONSUL_STATSITE_ADDR`
* `CONSUL_STATSITE_PREFIX`
* `CONSUL_TLS_CA_FILE`
* `CONSUL_TLS_CERT_FILE`
* `CONSUL_TLS_VERIFY_INCOMING`
* `CONSUL_TLS_VERIFY_OUTGOING`
* `CONSUL_TLS_VERIFY_SERVER_HOSTNAME`
* `CONSUL_UI_DIR`

## License

MIT
