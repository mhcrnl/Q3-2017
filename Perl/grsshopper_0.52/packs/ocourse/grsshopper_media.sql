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
-- Table structure for table `media`
--

DROP TABLE IF EXISTS `media`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `media` (
  `media_id` int(10) NOT NULL auto_increment,
  `media_type` varchar(40) default NULL,
  `media_mimetype` varchar(40) default NULL,
  `media_title` varchar(256) default NULL,
  `media_url` varchar(256) default NULL,
  `media_description` text,
  `media_size` varchar(32) default NULL,
  `media_link` varchar(256) default NULL,
  `media_post` varchar(256) default NULL,
  `media_feed` varchar(256) default NULL,
  `media_crdate` int(15) default NULL,
  `media_creator` int(15) default NULL,
  `media_thurl` varchar(250) default NULL,
  `media_thwidth` varchar(250) default NULL,
  `media_thheight` varchar(250) default NULL,
  `media_duration` varchar(250) default NULL,
  `media_block` varchar(250) default NULL,
  `media_explicit` varchar(250) default NULL,
  `media_keywords` varchar(250) default NULL,
  `media_subtitle` varchar(250) default NULL,
  `media_height` varchar(250) default NULL,
  `media_width` varchar(250) default NULL,
  `media_language` varchar(250) default NULL,
  `media_identifier` varchar(250) default NULL,
  KEY `media_id` (`media_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `media`
--
-- WHERE:  TRUE ORDER BY media_id

LOCK TABLES `media` WRITE;
/*!40000 ALTER TABLE `media` DISABLE KEYS */;
/*!40000 ALTER TABLE `media` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-07-22 13:42:13
