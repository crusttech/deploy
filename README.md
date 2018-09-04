# Deploy scripts for Crust services


## Usage:

### Deploy proxy (one time thing)
```
./bash-ssh-docker/deploy.sh proxy
```


### Deploy Crust services
```
./bash-ssh-docker/deploy.sh <service> [tag:latest]
```

Service can be one of: sam, crm, spa

This will create service, accessible on `https://api.<service>.<tag>.rustbucket.io`