# Docker Compose deployment

This is an example docker-compose deployment.

Requirements:

- Docker (18.09 or better)
- Docker Compose (1.23 or better)


## Main services (crust-* and didmos-*)

### Configuration

All the services have a common deployment environment file `.env`. Each service also has their 
own environment file (`config.[service].env`,  `config.[service].js`) and variables under 
`service/environment` in `docker-compose.yml`.

Generally for a test deployment, all you need to do is to rename the `DOMAIN` variable in the
`.env` file.

### Networking

All the containers assume the existence of a `party` network. If you haven't created one, you
can do that by issuing the following command:

```
docker network create -d bridge --subnet 172.25.0.0/24 party
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

#### Didmos2
- `backend` - Didmos backend
- `frontend` - Self service portal
- `ldap` - LDAP
- `mongo` - Storage
- `satosa` - Athentication


## Exposing Crust to the outside world with reverse proxy

The project relies on a running [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy)
container for routing, and an example service for it is also provided here. To run
the service, issue the following commands (as root or a user in the docker group):

```
cd nginx-proxy && docker-compose up -d
```

The setup comes with [jrcs/letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion),
which will use LetsEncrypt API service to provision SSL certificates for your deployment automatically.

To configure the virtual hosts, individual exposed containers have `VIRTUAL_HOST` env variables.


### Starting & stopping Crust services

 Starting or stopping the services is as easy as running `docker-compose up -d` and
`docker-compose down`. 
