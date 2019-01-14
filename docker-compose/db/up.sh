#!/bin/bash
cd $(dirname $(readlink -f $0))
if [ ! -d "data/db" ]; then
	mkdir -p data/db
	chown 1001.1001 data/db
fi
if [ ! -f "wait-for-it.sh" ]; then
	wget https://github.com/vishnubob/wait-for-it/raw/master/wait-for-it.sh
	chmod a+x wait-for-it.sh
fi
docker-compose up -d
docker run -it --rm --net=party -v $PWD:$PWD -w $PWD yikaus/alpine-bash ./wait-for-it.sh -t 60 --strict crust-db1:3306 -- echo "Crust DB1 is up"