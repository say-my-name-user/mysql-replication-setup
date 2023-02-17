-- Create replication user
CREATE USER 'replicauser'@'%' IDENTIFIED BY 'replicapass';
GRANT SELECT, REPLICATION SLAVE ON *.* TO 'replicauser'@'%';

-- Create dummy data
DROP DATABASE IF EXISTS sourcedb;

CREATE DATABASE sourcedb;

USE sourcedb;

CREATE TABLE `replication_data` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Identifier',
    `text` text DEFAULT NULL COMMENT 'Text',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Replication data';

INSERT INTO `replication_data` VALUES
(1,'Row 1'),
(2,'Row 2'),
(3,'Row 3'),
(4,'Row 4'),
(5,'Row 5');