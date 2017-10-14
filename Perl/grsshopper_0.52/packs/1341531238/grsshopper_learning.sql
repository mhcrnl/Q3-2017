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
-- Table structure for table `learning`
--

DROP TABLE IF EXISTS `learning`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `learning` (
  `learning_id` int(15) NOT NULL auto_increment,
  `learning_item` varchar(255) default NULL,
  `learning_feedid` varchar(255) default NULL,
  `learning_inttype` varchar(255) default NULL,
  `learning_lrtype` varchar(255) default NULL,
  `learning_intlevel` varchar(255) default NULL,
  `learning_semdens` varchar(255) default NULL,
  `learning_eurole` varchar(255) default NULL,
  `learning_context` varchar(255) default NULL,
  `learning_age` varchar(255) default NULL,
  `learning_difficulty` varchar(255) default NULL,
  `learning_ltime` varchar(255) default NULL,
  `learning_description` text,
  `learning_language` varchar(64) default NULL,
  `learning_langs` varchar(255) default NULL,
  `learning_extra` varchar(255) default NULL,
  `learning_crdate` int(15) default NULL,
  PRIMARY KEY  (`learning_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `learning`
--
-- WHERE:  TRUE ORDER BY learning_id

LOCK TABLES `learning` WRITE;
/*!40000 ALTER TABLE `learning` DISABLE KEYS */;
/*!40000 ALTER TABLE `learning` ENABLE KEYS */;
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
