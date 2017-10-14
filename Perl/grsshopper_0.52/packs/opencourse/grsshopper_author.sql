-- MySQL dump 10.11
--
-- Host: localhost    Database: course
-- ------------------------------------------------------
-- Server version	5.0.77

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `author`
--

DROP TABLE IF EXISTS `author`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `author` (
  `author_id` int(11) NOT NULL auto_increment,
  `author_link` varchar(255) default NULL,
  `author_name` varchar(123) default NULL,
  `author_description` text,
  `author_crdate` int(15) default NULL,
  `box_test` varchar(250) default NULL,
  `author_nickname` varchar(250) default NULL,
  `author_twitter` varchar(250) default NULL,
  `author_linkedin` varchar(250) default NULL,
  `author_delicious` varchar(250) default NULL,
  `author_flickr` varchar(250) default NULL,
  `author_email` varchar(250) default NULL,
  `author_creator` varchar(250) default NULL,
  `author_opensocialuserid` varchar(250) default NULL,
  `author_person` varchar(250) default NULL,
  `author_facebook` varchar(250) default NULL,
  `author_socialnet` varchar(250) default NULL,
  PRIMARY KEY  (`author_id`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `author`
--
-- WHERE:  TRUE ORDER BY author_id

LOCK TABLES `author` WRITE;
/*!40000 ALTER TABLE `author` DISABLE KEYS */;
INSERT INTO `author` VALUES (1,NULL,'Gerry Green',NULL,1348441326,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1',NULL,NULL,NULL,NULL),(2,'http://www.blogger.com/profile/06849352443716808247','Ã‰ric',NULL,1348689583,NULL,NULL,NULL,NULL,NULL,NULL,'noreply@blogger.com','1',NULL,NULL,NULL,NULL),(3,'http://sixthestate.net','Sixth Estate',NULL,1348790088,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1',NULL,NULL,NULL,NULL),(4,'http://gwynnedyer.com','Gwynne Dyer',NULL,1348791618,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1',NULL,NULL,NULL,NULL),(5,'http://www.carp.ca','Etobicoke',NULL,1348938664,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(6,'http://ccarts.ca','Kimberly Wilson',NULL,1348938728,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(7,'http://www.canadianlabour.ca/rss-news','francesfc',NULL,1348938849,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(8,NULL,'Neil Hodge',NULL,1349019003,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `author` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-10-01 12:48:55
