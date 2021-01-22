# Postfix (with Postgres) Docker Image

A Postfix Docker image with PostgreSQL support. This allows for alias lookups via database and other use cases.



## Example Usage
```
docker run --rm -ti -p 25:25 -p 587:587 \
  -e CONF_MYDOMAIN=example.com \
  -e CONF_RELAYHOST=[smtp.mailgun.org]:587
  -e SASL_AUTH=username:password \
  -e POSTGRES_HOSTS=pg_host \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres_password \
  -e POSTGRES_ALIAS_DB=aliases \
  -e POSTGRES_ALIAS_QUERY="SELECT forw_addr FROM mxaliases WHERE alias='%s'" \
  dhet/postfix-pg:latest
```

## Configuration
This image aims to make Postfix configurable primarily through environment variables. 

### General
All environment variables that start with a `CONF_` prefix are translated into equivalent postfix settings. The remainder of the environment variable name will be lowercased and piped into Postfix's main configuration file (`/etc/postfix/main.cf`).

#### Examples:
|Environment variable|Equivalent Postfix setting|
|---|---|
|`CONF_MYDOMAIN=example.com`|`mydomain = example.com`|
|`CONF_MYDESTINATION="$myhostname localhost.$mydomain localhost"`|`mydestination = $myhostname localhost.$mydomain localhost`|
|`CONF_RELAYHOST=[smtp.mailgun.org]:587`|`relayhost = [smtp.mailgun.org]:587`|
|etc...||

### SASL
To enable SASL auth for a relay server specify the `SASL_AUTH` environment variable. The value of this variable needs to have the format `username:password`. This setting automatically sets the `smtp_sasl_auth_enable`, `smtp_sasl_password_maps` and `smtp_sasl_security_options` options for you **but you have to set the `CONF_RELAYHOST` variable yourself.**

### Postgres Alias Maps
This image supports both, local and virtual alias map lookups via Postgres. Please check the [Postfix PostgreSQL Howto](http://www.postfix.org/PGSQL_README.html) for more detailed explanations.

The following environment variables are required for this:
* `POSTGRES_HOSTS`: A list of one or more database hosts separated by spaces
* `POSTGRES_USER`: The database user
* `POSTGRES_PASSWORD`: The database user's password
* `POSTGRES_ALIAS_DB`: The database in which the (virtual) alias table is stored

#### Local Aliases
* `POSTGRES_ALIAS_QUERY`: The query to find an alias, e.g. `SELECT forw_addr FROM mxaliases WHERE alias='%s'`.

#### Virtual Aliases
* `POSTGRES_VALIAS_QUERY`: The query to find a virtual alias, e.g. `SELECT forw_addr FROM virtualaliases WHERE alias='%s'`.


## Acknowledgements
*This image is a slightly modified version of the postfix image found in [Jessie Frazelle's dockerfile collection](https://github.com/jessfraz/dockerfiles).*