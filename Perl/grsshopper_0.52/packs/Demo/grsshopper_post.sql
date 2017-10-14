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
-- Table structure for table `post`
--

DROP TABLE IF EXISTS `post`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `post` (
  `post_id` int(15) NOT NULL auto_increment,
  `post_type` varchar(32) character set latin1 default 'link',
  `post_pretext` text character set latin1,
  `post_title` varchar(255) default NULL,
  `post_link` varchar(255) character set latin1 default NULL,
  `post_linkid` int(15) default NULL,
  `post_author` varchar(255) character set latin1 default NULL,
  `post_authorids` varchar(255) default NULL,
  `post_authorstr` text,
  `post_journal` varchar(255) character set latin1 default NULL,
  `post_journalids` varchar(255) default NULL,
  `post_journalstr` text,
  `post_authorid` int(15) default NULL,
  `post_journalid` int(15) default NULL,
  `post_description` text,
  `post_quote` text character set latin1,
  `post_content` longtext,
  `post_topics` varchar(255) character set utf8 collate utf8_unicode_ci default NULL,
  `post_replies` int(15) default '0',
  `post_key` int(15) default NULL,
  `post_hits` int(12) default NULL,
  `post_thread` int(15) default NULL,
  `post_dir` varchar(32) character set latin1 default NULL,
  `post_crdate` varchar(36) character set latin1 default NULL,
  `post_creator` varchar(36) character set latin1 default NULL,
  `post_crip` varchar(24) character set latin1 default NULL,
  `post_pub` varchar(10) character set latin1 default NULL,
  `post_updated` int(15) default NULL,
  `post_email_checked` varchar(10) default NULL,
  `post_emails` text,
  `post_cache` longtext,
  `post_offset` int(6) default NULL,
  `post_pub_date` varchar(250) default NULL,
  `image_file` varchar(250) default NULL,
  `post_image_url` varchar(250) default NULL,
  `post_image_file` varchar(250) default NULL,
  `post_total` int(11) default NULL,
  `post_source` varchar(250) default NULL,
  `post_autocats` varchar(250) default NULL,
  PRIMARY KEY  (`post_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `post`
--
-- WHERE:  TRUE ORDER BY post_id

LOCK TABLES `post` WRITE;
/*!40000 ALTER TABLE `post` DISABLE KEYS */;
/*!40000 ALTER TABLE `post` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-08-13 17:02:50
