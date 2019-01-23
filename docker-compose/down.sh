#!/bin/bash
action=$(basename $0)
services="db system sam crm webapp"
services=$(echo -n "$services" | awk '{ for (i=NF; i>1; i--) printf("%s ",$i); print $1; }') #'
for service in $services; do
	if [ -f "$service/$action" ]; then
		./$service/$action
	else
		cd $service
		docker-compose down
		cd ..
	fi
done