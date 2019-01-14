if [ ! -d "data/db" ]; then
	mkdir -p data/db
	chown 1001.1001 data/db
fi
docker-compose up