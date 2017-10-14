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
-- Table structure for table `presentation`
--

DROP TABLE IF EXISTS `presentation`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `presentation` (
  `presentation_id` int(15) NOT NULL auto_increment,
  `presentation_category` varchar(59) default 'J - Presented Papers and Talks',
  `presentation_title` varchar(255) default NULL,
  `presentation_link` varchar(255) default NULL,
  `presentation_author` varchar(255) default 'Stephen Downes',
  `presentation_conference` varchar(255) default NULL,
  `presentation_location` varchar(255) default NULL,
  `presentation_crdate` int(15) default NULL,
  `presentation_attendees` int(6) default NULL,
  `presentation_cattendees` int(6) default NULL,
  `presentation_catdetails` varchar(24) default NULL,
  `presentation_slides` varchar(255) default NULL,
  `presentation_slideshare` varchar(255) default NULL,
  `presentation_audio` varchar(255) default NULL,
  `presentation_org` varchar(255) default NULL,
  `presentation_description` text,
  `presentation_video` varchar(255) default NULL,
  `presentation_audio_player` text,
  `presentation_slide_player` text,
  `presentation_video_player` text,
  `presentation_topics` varchar(255) default NULL,
  PRIMARY KEY  (`presentation_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `presentation`
--
-- WHERE:  TRUE ORDER BY presentation_id

LOCK TABLES `presentation` WRITE;
/*!40000 ALTER TABLE `presentation` DISABLE KEYS */;
/*!40000 ALTER TABLE `presentation` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-02-27 20:29:22
