# Docker Compose deployment

This is an example docker-compose deployment.

Requirements:

- Docker (18.09 or better)
- Docker Compose (1.23 or better)


## Main services

### Configuration

All the services have a common deployment environment file `.env`. Each service also has a fiew variables under 
`service/environment` in `docker-compose.yml`.


#### Changing domain name
If you want to give Crust a test run on your localhost you can leave all settings as they are.
We've configured our DNS to point `*.local.crust.tech` to `127.0.0.1`. There is also a subscription
key inside `.env` that allows you to use Crust on that domain without 
limitations.

##### Full list of domains Crust uses:

 - `$DOMAIN`
 - `system.api.${DOMAIN}`
 - `crm.api.${DOMAIN}`
 - `messaging.api.${DOMAIN}`

Make sure all domains point to where you host your files. If your domain registrar/dns service provider supports
wildcard entries, we suggest you use that.


Generally for a test deployment, all you need to do is to rename the `DOMAIN` variable in the
`.env` file.

#### JWT Secret
Make sure you generate your JWT secret (`AUTH_JWT_SECRET`). 

Quick bash oneliner:
```bash
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
```

#### SMTP / Email sending capabilities
There are a few functionalities in Crust and Didmos that have email sending capabilities. To 
enable them, please configure `SMTP_*` variables to enable sending through a working SMTP service.

For local testing, you can use MailHog. Follow setup instructions at [MailHog's GitHub page](https://github.com/mailhog/MailHog)
and point `SMTP_HOST to the mailhog instance.


### Networking

All the containers assume the existence of a `proxy` network. If you haven't created one, you
can do that by issuing the following command:

```sh
docker network create -d bridge --subnet 172.25.0.0/24 proxy
```

### Data

Some of the services need data storage. By default, a `data` subfolder is created. If you need 
to back up your services, your best bet is to shut down the service, and copy the files to your 
backup storage space.

### Services:

#### Crust
- `db` - a database instance for CRUST,
- `system` - the system service for CRUST,
- `crm` - the CRM service for CRUST,
- `messaging` - the Messaging service for CRUST,
- `webapp` - the complete webapp for CRUST


## Exposing Crust to the outside world with reverse proxy

The project relies on a running [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy)
container for routing, and an example service for it is also provided here. To run
the service, issue the following commands (as root or a user in the docker group):

```sh
cd nginx-proxy && docker-compose up -d
```

The setup comes with [jrcs/letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion),
which will use LetsEncrypt API service to provision SSL certificates for your deployment automatically.

To configure the virtual hosts, individual exposed containers have `VIRTUAL_HOST` env variables.


### Starting & stopping Crust services

Starting or stopping is as easy as running `docker-compose up -d` for starting and `docker-compose down`
for stopping all services. 

### Updating images

```sh
docker-compose pull
docker-compose up -d
```

### Initial configuration

```bash
docker-compose exec api-system cli settings auto-configure --auth-from-address info@domain.tld --auth-from-name Admin --auth-frontend-url https://domain.tld
```
This command only sets missing values. You can remove/set values manually with `cli settings remove` or `cli settings set`
and run auto-configure again.

Any change to changes to settings will be picked-up on restart `docker-compose restart api-system`.

#### Permissions & role membership

Crust comes with a small CLI toolbox. You can access it inside `api-system` container like this:
```bash
docker-compose exec api-system cli
```

Among other helper tools, you can reset system roles and their privileges, assign roles to users etc.

Role resetting:
```bash
docker-compose exec api-system cli roles reset
```

List users:
```bash
docker-compose exec api-system cli users list
```

Assign "Administrators" (ID=2) role to a specific user:
```bash
docker-compose exec api-system cli roles useradd 2 83986549888253955
```

#### External authentication provider auto-discovery
```bash
docker-compose exec api-system cli external-auth auto-discovery my-didmos https://didmos-url
```

#### Explore, view and change settings
Majority of internal setting values will be auto-detected/configured

```bash
docker-compose exec api-system cli settings help
docker-compose exec api-system cli settings auto-configure --help
docker-compose exec api-system cli settings list --prefix=auth
```

### Troubleshooting

#### MySQL refuses to start due to write access to `data/db`. 
You'll have to adjust ownership or reconfigure docker-compose.yml 
to use a different kind of volume.

To adjust permissions, see UID (numeric value) of the user running mysql insider percona image. Should be `1001`.
Change directory ownership: 
```sh
chown -R 1001:1001 data/db && docker-compose restart db
```

#### Backend returning 500 HTTP error
Make sure you check logs in your system/messaging/crm service.

Possible reasons:
 - Most likely you've changed domain and should also change subscription key.
