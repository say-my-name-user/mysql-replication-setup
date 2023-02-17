#!/usr/bin/bash

echo "Clear the environment..."
docker-compose stop
docker-compose rm -v
sudo rm -rf source/data/*
sudo rm -rf replica/data/*
rm -rf source/log/*
rm -rf replica/log/*

echo "Up containers..."
docker-compose down
docker-compose up --build --force-recreate -d

sleep 5
PING=$(docker exec -i $(docker-compose ps -q replica-db) mysql -u root -prootpass -e "select 'pong';" | grep -c 'pong')

while [ $PING -lt 1 ]
do
   echo "Containers are being up, wait..."
   sleep 2
   PING=$(docker exec -i $(docker-compose ps -q replica-db) mysql -u root -prootpass -e "select 'pong';" | grep -c 'pong')
done

echo "Make a dump from source-db..."
# Note: --source-data=2 generates CHANGE MASTER TO statement in the dump that is required for replica setup
docker exec -i $(docker-compose ps -q source-db) mysqldump -u root -prootpass --all-databases --source-data=2 > dump.sql

echo "Upload dump to replica-db..."
docker exec -i $(docker-compose ps -q replica-db) mysql -u root -prootpass < dump.sql

echo "Setup and run replica-db as a replica..."
docker exec -i $(docker-compose ps -q replica-db) mysql -u root -prootpass -e "
STOP SLAVE;
RESET SLAVE;
$(cat dump.sql | grep -oP "(CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.[\d]+', MASTER_LOG_POS=[\d]+)"), MASTER_HOST='source-db', MASTER_USER='$(docker exec -i $(docker-compose ps -q replica-db) printenv REPLICA_USER)', MASTER_PASSWORD='$(docker exec -i $(docker-compose ps -q replica-db) printenv REPLICA_PASSWORD)';
START SLAVE;
SHOW SLAVE STATUS \G;"

echo "Remove dump file..."
rm dump.sql