#!/bin/bash
set -e
action=$(basename $0)
services="db system sam crm webapp"
for service in $services; do
	if [ -f "$service/$action" ]; then
		./$service/$action
	else
		cd $service
		docker-compose up -d
		sleep 1
		cd ..
	fi
done