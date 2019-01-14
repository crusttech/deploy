# fixes issues with 'show databases' and 'show tables'

CREATE USER 'mysql.infoschema'@'localhost';
GRANT ALL ON *.* TO 'mysql.infoschema'@'localhost';