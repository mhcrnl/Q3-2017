# this is the file, that creates a table called
# mp3table in the databes mp3 on your sql server.

# first you have to create the database called mp3.
# (1) mysql 
# (2) CREATE DATABASE mp3;
# (3) source mp3table.sql; 
# (4) quit

# if you have several databases on your sql server,
# then switch to mp3.
USE mp3;
# attention! here the table mp3table in the database
# mp3 is going to be deleted, if it exists.
DROP TABLE IF EXISTS mp3table;
# here we define our nice table, that we want to fill 
# with our nice information about the mp3 files.
CREATE TABLE mp3table(
        un          CHAR(255) NOT NULL,
        name        CHAR(255) NOT NULL,
        title       CHAR(30) NULL,
        artist      CHAR(30) NULL,
        album       CHAR(30) NULL,
        year        SMALLINT UNSIGNED NULL,
        comment     CHAR(30) NULL,
        genre       TINYINT UNSIGNED NULL,
	tracknum    TINYINT UNSIGNED NULL,
        directory   CHAR(255) NOT NULL,
        size        INT UNSIGNED NOT NULL,
        moditime    INT UNSIGNED NOT NULL,
        vbr         CHAR(1) NOT NULL,
        bitrate     SMALLINT UNSIGNED NOT NULL,
        frequency   TINYINT UNSIGNED NOT NULL,
        min         TINYINT UNSIGNED NOT NULL,
        sec         TINYINT UNSIGNED NOT NULL
);
