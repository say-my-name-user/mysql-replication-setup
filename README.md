## MySQL Replication Setup example using Docker

#### Installation

- Clone the project: `git clone https://github.com/say-my-name-user/mysql-replication-setup.git`


- Run: `cd mysql-replication-setup && source ./run.sh`

#### Testing

- If everything is installed okay then now you have two containers up: source-db and replica-db.


- Both of them have `replication_data` table with 5 rows, to check them run the following:

  - for source-db: `docker exec -i $(docker-compose ps -q source-db) mysql -u root -prootpass -e "USE sourcedb; SELECT * FROM replication_data;"`
  - for replica-db: `docker exec -i $(docker-compose ps -q replica-db) mysql -u root -prootpass -e "USE sourcedb; SELECT * FROM replication_data;"`


- Try to insert a new row into the main source-db: `docker exec -i $(docker-compose ps -q source-db) mysql -u root -prootpass -e "USE sourcedb; INSERT INTO replication_data VALUES (6,'New row');"`


- Check the replica-db, it must have the same new row in its database copy: `docker exec -i $(docker-compose ps -q replica-db) mysql -u root -prootpass -e "USE sourcedb; SELECT * FROM replication_data;"`


- Try to delete some data in the main source-db: `docker exec -i $(docker-compose ps -q source-db) mysql -u root -prootpass -e "USE sourcedb; DELETE FROM replication_data WHERE id < 4;"`


- Check the replica-db: `docker exec -i $(docker-compose ps -q replica-db) mysql -u root -prootpass -e "USE sourcedb; SELECT * FROM replication_data;"`