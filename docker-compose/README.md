# Docker Compose deployment

This is an example docker-compose deployment.

Requirements:

- Docker (18.09 or better)
- Docker Compose (1.23 or better)

## Main services (crust-* and didmos-*)

### Configuration

All the services have a common deployment environment file (`.env`) which is in the service
parent directory. Each service also has their own environment file (`config.[service].env`, 
`config.[service].js`) and variables under `service/environment` in `docker-compose.yml`.



### Starting & stopping

Generally for a test deployment, all you need to do is to rename the `DOMAIN` variable in the
`.env` file. Starting or stopping the services is as easy as running `docker-compose up -d` and
`docker-compose down`. 

### Data

Some of the services need data storage. By default, a `data` subfolder is created. If you need 
to back up your services, your best bet is to shut down the service, and copy the files to your 
backup storage space.



The services are as follows:

- `nginx-proxy` - a reverse proxy that can run our services (optional),
- `db` - a database instance for CRUST,
- `system` - the system service for CRUST,
- `crm` - the CRM service for CRUST,
- `sam` - the Messaging service for CRUST,
- `webapp` - the complete webapp for CRUST

All the containers asume the existance of a `party` network. If you haven't created one, you
can do that by issuing the following command:

~~~
docker network create -d bridge --subnet 172.25.0.0/24 party
~~~

The private network allows us to expose only ports to `nginx-proxy`, and leave all system
services on a private network behind it. This way, we don't rely on firewall configuration
for security.

## Reverse proxy

The project relies on a running [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy)
container for routing, and an example service for it is also provided here. To run
the service, issue the following commands (as root or a user in the docker group):

~~~
cd nginx-proxy && docker-compose up -d
~~~

The setup comes with [jrcs/letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion),
which will use LetsEncrypt API service to provision SSL certificates for your deployment automatically.

To configure the virtual hosts, individual exposed containers have `VIRTUAL_HOST` env variables.
