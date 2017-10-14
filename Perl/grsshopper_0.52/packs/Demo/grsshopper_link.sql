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
-- Table structure for table `link`
--

DROP TABLE IF EXISTS `link`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `link` (
  `link_id` int(15) NOT NULL auto_increment,
  `link_hits` int(15) default '0',
  `link_cites` int(8) default '0',
  `link_title` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `link_type` varchar(32) collate utf8_unicode_ci default NULL,
  `link_link` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `link_category` varchar(255) collate utf8_unicode_ci default NULL,
  `link_topics` varchar(255) collate utf8_unicode_ci default NULL,
  `link_localcat` varchar(32) collate utf8_unicode_ci default NULL,
  `link_author` int(15) default NULL,
  `link_guid` varchar(255) collate utf8_unicode_ci default NULL,
  `link_created` datetime default NULL,
  `link_modified` datetime default NULL,
  `link_feedid` int(15) default NULL,
  `link_description` text collate utf8_unicode_ci,
  `link_crdate` int(15) default NULL,
  `link_orig` varchar(5) collate utf8_unicode_ci default NULL,
  `link_journal` varchar(250) collate utf8_unicode_ci default NULL,
  `link_authorname` varchar(250) collate utf8_unicode_ci default NULL,
  `link_authorurl` varchar(250) collate utf8_unicode_ci default NULL,
  `link_issued` varchar(250) collate utf8_unicode_ci default NULL,
  `feedname` varchar(250) collate utf8_unicode_ci default NULL,
  `link_feedname` varchar(250) collate utf8_unicode_ci default NULL,
  `link_total` varchar(250) collate utf8_unicode_ci default NULL,
  `link_content` text collate utf8_unicode_ci,
  `subtitle` varchar(250) collate utf8_unicode_ci default NULL,
  `link_explicit` varchar(250) collate utf8_unicode_ci default NULL,
  `item_keywords` varchar(250) collate utf8_unicode_ci default NULL,
  `link_autocats` varchar(250) collate utf8_unicode_ci default NULL,
  `link_geo` varchar(250) collate utf8_unicode_ci default NULL,
  `link_copyright` varchar(250) collate utf8_unicode_ci default NULL,
  `link_comment` varchar(250) collate utf8_unicode_ci default NULL,
  `link_commentsRSS` varchar(250) collate utf8_unicode_ci default NULL,
  `link_keywords` varchar(250) collate utf8_unicode_ci default NULL,
  `link_comments` varchar(250) collate utf8_unicode_ci default NULL,
  `link_publisher` varchar(250) collate utf8_unicode_ci default NULL,
  `link_pingserver` varchar(250) collate utf8_unicode_ci default NULL,
  `link_pingtarget` varchar(250) collate utf8_unicode_ci default NULL,
  `link_pingtrackback` varchar(250) collate utf8_unicode_ci default NULL,
  `link_gdetag` varchar(250) collate utf8_unicode_ci default NULL,
  `link_status` varchar(250) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`link_id`),
  UNIQUE KEY `link_link` (`link_link`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `link`
--
-- WHERE:  TRUE ORDER BY link_id

LOCK TABLES `link` WRITE;
/*!40000 ALTER TABLE `link` DISABLE KEYS */;
/*!40000 ALTER TABLE `link` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-08-13 17:02:49
