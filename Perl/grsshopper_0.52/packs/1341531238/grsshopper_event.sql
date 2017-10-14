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
-- Table structure for table `event`
--

DROP TABLE IF EXISTS `event`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `event` (
  `event_id` int(15) NOT NULL auto_increment,
  `event_type` varchar(32) default NULL,
  `event_title` varchar(255) default NULL,
  `event_group` varchar(15) default NULL,
  `event_description` text,
  `event_location` varchar(255) default NULL,
  `event_start` varchar(255) default NULL,
  `event_end` varchar(124) default NULL,
  `event_link` varchar(255) default NULL,
  `event_crdate` int(15) default NULL,
  `event_creator` smallint(15) default NULL,
  `test_date` datetime default NULL,
  `environment` varchar(250) default NULL,
  `event_environment` varchar(250) default NULL,
  `event_finish` varchar(255) default NULL,
  `event_star` varchar(250) default NULL,
  `event_host` varchar(250) default NULL,
  `owner_url` varchar(250) default NULL,
  `event_sponsor` varchar(250) default NULL,
  `event_sponsor_url` varchar(250) default NULL,
  `event_access` varchar(250) default NULL,
  `event_owner_url` varchar(250) default NULL,
  `event_identifier` varchar(250) default NULL,
  `event_localtz` varchar(250) default NULL,
  `event_icalstart` varchar(250) default NULL,
  `event_icalend` varchar(250) default NULL,
  `event_feedid` varchar(250) default NULL,
  `event_feedname` varchar(250) default NULL,
  `event_category` varchar(250) default NULL,
  PRIMARY KEY  (`event_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `event`
--
-- WHERE:  TRUE ORDER BY event_id

LOCK TABLES `event` WRITE;
/*!40000 ALTER TABLE `event` DISABLE KEYS */;
/*!40000 ALTER TABLE `event` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-07-09  0:44:30
