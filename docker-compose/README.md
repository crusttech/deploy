# Docker Compose deployment

This is an example docker-compose deployment.

Requirements:

- Docker (18.09 or better)
- Docker Compose (1.23 or better)

## Structure

All the services have a common deployment environment file (`crust.env`) which is in the service
parent directory. Each service also has their local environment file (`[service].env`) in their
individual service folders.

Generally for a test deployment, all you need to do is to rename the `VIRTUAL_HOST` variable for
each individual service. Starting or stopping the services is as easy as running `./up.sh` and
`./down.sh` in this folder.

Individual services might need data storage. By default, a `data` folder may be created in the
service folder. If you need to back up your services, your best bet is to shut down the service,
and copy the files to your backup storage space.

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