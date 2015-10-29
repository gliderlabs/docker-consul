# Consul Docker images

These are Zendesk's customized Docker images for HashiCorp's Consul.
They're based on [Glider Labs'](https://github.com/gliderlabs/docker-consul)
original sources.

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
