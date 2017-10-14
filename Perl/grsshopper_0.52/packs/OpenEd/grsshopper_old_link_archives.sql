-- MySQL dump 10.11
--
-- Host: localhost    Database: open
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
-- Table structure for table `old_link_archives`
--

DROP TABLE IF EXISTS `old_link_archives`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `old_link_archives` (
  `link_id` int(15) NOT NULL auto_increment,
  `link_identifier` varchar(255) default NULL,
  `link_crdate` int(15) NOT NULL default '0',
  `link_pubdate` varchar(64) NOT NULL default '',
  `link_feedid` int(15) NOT NULL default '0',
  `link_title` varchar(255) NOT NULL default '',
  `link_language` varchar(10) default NULL,
  `link_description` text,
  `link_link` varchar(255) default NULL,
  `link_edit` varchar(255) default NULL,
  `link_guid` varchar(255) default NULL,
  `link_category` varchar(128) default NULL,
  `link_created` varchar(25) default NULL,
  `link_modified` varchar(25) default NULL,
  `link_issued` varchar(25) default NULL,
  `link_creatorname` text,
  `link_creatorurl` text,
  `link_creatoremail` varchar(255) default NULL,
  `link_contributor` text,
  `link_subject` varchar(255) default NULL,
  `link_coverage` text,
  `link_aggregationLevel` varchar(5) default NULL,
  `link_journal` varchar(255) default NULL,
  `link_format` varchar(255) default NULL,
  `link_version` varchar(255) default NULL,
  `link_size` int(15) default NULL,
  `link_status` varchar(255) default NULL,
  `link_type` varchar(255) default NULL,
  `link_platform` text,
  `link_duration` varchar(64) default NULL,
  `link_source` varchar(255) default NULL,
  `link_cost` varchar(8) default NULL,
  `link_restrictions` varchar(8) default NULL,
  `link_rights` varchar(255) default NULL,
  `link_lcflag` char(1) NOT NULL default 'C',
  `link_rating_v` float default '0',
  `link_rating_n` int(15) default '0',
  `link_hits` int(15) default '0',
  `link_cites` int(15) default '0',
  `pub` int(15) default '0',
  PRIMARY KEY  (`link_id`),
  KEY `link_link` (`link_link`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `old_link_archives`
--
-- WHERE:  TRUE ORDER BY old_link_archives_id

