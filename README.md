# Postfix Docker Image with Postgres Support

A Postfix Docker image with PostgreSQL support. This image allows you to...

1. Use Postgres-based alias lookups
2. Configure Postfix via environment variables (as an alternative to config files)
2. Forward Postfix logs to Postgres


## Example Usage
```
docker run --rm -ti -p 25:25 -p 587:587 \
  -e CONF_MYDOMAIN=example.com \
  -e CONF_RELAYHOST=[smtp.mailgun.org]:587
  -e SASL_AUTH=username:password \
  -e POSTGRES_HOSTS=pg_host \
  -e POSTGRES_USER=postfix_user \
  -e POSTGRES_PASSWORD=postfix_user_password \
  -e POSTGRES_ALIAS_DB=aliases \
  -e POSTGRES_ALIAS_QUERY="SELECT forw_addr FROM mxaliases WHERE alias='%s'" \
  -e POSTGRES_LOG_HOST=pg_host \
  -e POSTGRES_LOG_DB=postfix_logs \
  -e POSTGRES_LOG_USER=log_user \
  -e POSTGRES_LOG_PASSWORD=log_user_password \
  -e POSTGRES_LOG_TABLE=postfix_logs
  dhet/postfix-pg:latest
```

## Configuration
This image aims to make Postfix configurable primarily through environment variables so that you don't have to bake config files into your sub-image.

### General
All environment variables that start with a `CONF_` prefix are translated into equivalent postfix settings. The remainder of the environment variable name will be lowercased and piped into Postfix's main configuration file (`/etc/postfix/main.cf`).

#### Examples:
|Environment variable|Equivalent Postfix setting|
|---|---|
|`CONF_MYDOMAIN=example.com`|`mydomain = example.com`|
|`CONF_MYDESTINATION="$myhostname localhost.$mydomain localhost"`|`mydestination = $myhostname localhost.$mydomain localhost`|
|`CONF_RELAYHOST=[smtp.mailgun.org]:587`|`relayhost = [smtp.mailgun.org]:587`|
|etc...||

### Relay SASL
To enable SASL auth for a relay server specify the `SASL_AUTH` environment variable. The value of this variable needs to have the format `username:password`. This setting automatically sets the `smtp_sasl_auth_enable`, `smtp_sasl_password_maps` and `smtp_sasl_security_options` options for you **but you have to set the `relayhost` variable yourself.**

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

### Logging
You can configure this image to push Postfix logs to a Postgres database through rsyslog. This feature works independently of the Postfix alias lookups so the database credentials need to be specified separately, even if alias DB and log DB are the same. To enable logging specify these environment variables (all variables are required):
* `POSTGRES_LOG_HOST`: The hostname of the database host
* `POSTGRES_LOG_TABLE`: The database table to write logs into
* `POSTGRES_LOG_DB`: The database which holds the log table
* `POSTGRES_LOG_USER`: The database user for logging
* `POSTGRES_LOG_PASSWORD`: The log database user's password

> ⚠️ The table as specified in `POSTGRES_LOG_TABLE` needs to be created by you prior to starting the container. The table needs to contain at least the following two columns: `raw_log` (type `text` or `varchar`) and `created_at` (type `timestamp`). Optional fields can be added as desired.

## Acknowledgements
*This image is a slightly modified version of the postfix image found in [Jessie Frazelle's dockerfile collection](https://github.com/jessfraz/dockerfiles).*