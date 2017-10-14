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
-- Table structure for table `feed`
--

DROP TABLE IF EXISTS `feed`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `feed` (
  `feed_id` int(15) NOT NULL auto_increment,
  `feed_identifier` text,
  `feed_type` varchar(8) default NULL,
  `feed_title` varchar(255) NOT NULL default '',
  `feed_description` text,
  `feed_html` varchar(255) default NULL,
  `feed_link` varchar(255) default NULL,
  `feed_journal` int(15) default NULL,
  `feed_author` int(15) default NULL,
  `feed_post` varchar(255) default NULL,
  `feed_guid` varchar(255) default NULL,
  `feed_lastBuildDate` varchar(25) default NULL,
  `feed_pubDate` varchar(25) default NULL,
  `feed_genname` varchar(24) default NULL,
  `feed_genver` varchar(10) default NULL,
  `feed_genurl` varchar(255) default NULL,
  `feed_creatorname` text,
  `feed_creatorurl` text,
  `feed_creatoremail` text,
  `feed_managingEditor` varchar(255) default NULL,
  `feed_webMaster` varchar(255) default NULL,
  `feed_publisher` text,
  `feed_category` varchar(127) character set utf8 collate utf8_unicode_ci default 'category',
  `feed_docs` varchar(255) default NULL,
  `feed_version` varchar(10) default NULL,
  `feed_rights` varchar(255) default NULL,
  `feed_language` varchar(10) default NULL,
  `feed_updatePeriod` varchar(20) default NULL,
  `feed_updateFrequency` varchar(20) default NULL,
  `feed_updateBase` varchar(20) default NULL,
  `feed_granularity` varchar(20) default NULL,
  `feed_compression` varchar(10) default NULL,
  `feed_imgTitle` varchar(255) default NULL,
  `feed_imgLink` varchar(255) default NULL,
  `feed_imgURL` varchar(255) default NULL,
  `feed_imgCreator` varchar(255) default NULL,
  `feed_imgheight` int(4) default NULL,
  `feed_imgwidth` int(4) default NULL,
  `feed_lastharvest` varchar(15) default NULL,
  `feed_status` varchar(15) default 'O',
  `feed_crdate` int(15) default NULL,
  `feed_tagline` varchar(255) default NULL,
  `feed_modified` varchar(255) default NULL,
  `feed_etag` varchar(255) default NULL,
  `feed_updated` varchar(15) default NULL,
  `feed_cache` longtext,
  `feed_links` int(15) default NULL,
  `feed_country` varchar(5) default NULL,
  `feed_add_entry` varchar(255) default NULL,
  `feed_as_xml` text,
  `feed_timezone` varchar(250) default NULL,
  `feed_feedburnerid` varchar(250) default NULL,
  `feed_feedburnerurl` varchar(250) default NULL,
  `feed_feedburnerhost` varchar(250) default NULL,
  `feed_hub` varchar(250) default NULL,
  `feed_OSstartIndex` varchar(250) default NULL,
  `feed_OStotalResults` varchar(250) default NULL,
  `feed_OSitemsPerPage` varchar(250) default NULL,
  `feed_authorname` varchar(250) default NULL,
  `feed_explicit` varchar(250) default NULL,
  `feed_topic` varchar(250) default NULL,
  `feed_rating` varchar(250) default NULL,
  `feed_authorurl` varchar(250) default NULL,
  `feed_authoremail` varchar(250) default NULL,
  `geo_lat` varchar(250) default NULL,
  `geo_long` varchar(250) default NULL,
  `feed_copyright` varchar(250) default NULL,
  `feed_baseurl` varchar(250) default NULL,
  `feed_autocats` varchar(250) default NULL,
  `feed_blogroll` varchar(250) default NULL,
  `feed_keywords` varchar(250) default NULL,
  `feed_creator` varchar(250) default NULL,
  `feed_class` varchar(250) default NULL,
  `feed_genre` varchar(250) default NULL,
  `feed_autopost_rule` varchar(250) default NULL,
  `feed_rules` text,
  PRIMARY KEY  (`feed_id`)
) ENGINE=MyISAM AUTO_INCREMENT=20 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `feed`
--
-- WHERE:  TRUE ORDER BY feed_id

LOCK TABLES `feed` WRITE;
/*!40000 ALTER TABLE `feed` DISABLE KEYS */;
INSERT INTO `feed` VALUES (4,NULL,'RSS 0.91','Moncton Wildcats',NULL,'http://www.moncton-wildcats.com/','http://www.moncton-wildcats.com/feed/news',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Sports',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1349095143','A',1348441315,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Moncton Wildcats Press Release',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'1','News','Press Release','all','=> autopost;'),(5,NULL,'RSS 0.91','CBC New Brunswick',NULL,NULL,'http://rss.cbc.ca/lineup/canada-newbrunswick.xml',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Province',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1349095204','A',1348682237,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'CBC News',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'1','News','News','title~Moncton;description~Moncton','title|description~Moncton => category=City,autopost;'),(6,NULL,'RSS 0.91','308',NULL,'http://www.threehundredeight.com/','http://www.threehundredeight.com/feeds/posts/default',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Canada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1349092204','A',1348688970,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'1','News','News',NULL,'title|description~Brunswick => category=Province,autopost;\r\nelse => autopost;'),(7,NULL,'RSS 0.91','CUPE News',NULL,NULL,'http://cupe.ca/rss/topics/news/',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Canada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1349095263','A',1348764320,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Canadian Union of Public Employees',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'1','News','News',NULL,'title|description~Moncton => category=City,autopost;\r\nelse title|description~NB|Brunswick => category=Province,autopost;'),(8,NULL,'RSS 0.91','CARP',NULL,'http://www.carp.ca/','http://www.carp.ca/feed/',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Canada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1349094303','A',1348772857,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'1','News','News',NULL,'title|description~Moncton => category=City,autopost;\r\nelse title|description~NB|Brunswick => category=Province,autopost;'),(9,NULL,'RSS 0.91','Canadian Conference of the Arts',NULL,'http://ccarts.ca/','http://ccarts.ca/feed/',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Entertainment',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1349094423','A',1348773022,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'1','News','News',NULL,'title|description~Moncton => category=City,autopost;\r\nelse title|description~NB|Brunswick => category=Province,autopost;'),(10,NULL,'RSS 0.91','CBC Canadian News',NULL,NULL,'http://rss.cbc.ca/lineup/canada.xml',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Canada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1349095503','A',1348773518,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'1','News','News',NULL,'title|description~Saint John|Fredericton|NB| => category=Province;autopost;'),(11,NULL,'RSS 0.91','CBC World News',NULL,NULL,'http://rss.cbc.ca/lineup/world.xml',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'World',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1349094663','A',1348774280,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'1','News','News',NULL,NULL),(12,NULL,'RSS 0.91','Canadian University Press',NULL,NULL,'http://cupwire.ca/feed.xml',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Canada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1349092089','A',1348774451,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'1','News','News',NULL,'title|description~Moncton => category=City,autopost;\r\nelse title|description~Fredericton|Sackville|Brunswick => category=Province,autopost;\r\n'),(13,NULL,'RSS 0.91','RCMP',NULL,'http://www.rcmp-grc.gc.ca/nb/news-nouvelles/','http://www.rcmp-grc.gc.ca/nb/news-nouvelles/releases-communiques/news-nouvelles-eng.xml',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'City',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1349092143','A',1348775049,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'1','News','News',NULL,'title|description~Moncton|Dieppe|Riverview|Hillsbourough|Salisbury|Shediac|Irishtown => category=City,class=Police,autopost\r\n'),(14,NULL,'RSS 0.91','The Sixth Estate',NULL,'http://sixthestate.net/','http://sixthestate.net/?feed=rss2',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Canada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1349092502','A',1348790082,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Sixth Estate',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'1','Opinion','Opinion',NULL,'=> autopost;'),(15,NULL,'RSS 0.91','Gwynne Dyer',NULL,'http://gwynnedyer.com/','http://gwynnedyer.com/feed/',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'World',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1349092263','A',1348791528,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Gwynne Dyer',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'1','Opinion','Opinion',NULL,'=> autopost;'),(16,NULL,'RSS 0.91','Canadian Labour Congress',NULL,'http://www.canadianlabour.ca/','http://www.canadianlabour.ca/rss-news',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Canada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1349094843','A',1348792061,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Canadian Labour Congress',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'1','News','News',NULL,'=> autopost;\r\n'),(17,NULL,'RSS 0.91','The Moncton Times@Transcript - Good and Bad',NULL,'http://themonctongrimes-dripdrain.blogspot.com/','http://themonctongrimes-dripdrain.blogspot.com/feeds/posts/default?alt=rss',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'City',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1349092323','A',1348828754,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Graeme Decarie',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'1','Opinion','Opinion',NULL,'=> autopost;'),(18,NULL,'RSS 0.91','Columbia Journalism Review',NULL,'http://www.cjr.org','http://www.cjr.org/index.xml',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'World',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1349095023','A',1348829046,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'1','Opinion','Opinion',NULL,NULL),(19,NULL,'RSS 0.91','The Real News Network',NULL,'http://therealnews.com/','http://therealnews.com/rss/therealnews.rss',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'World',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1349095563','A',1349013173,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'1','News','News',NULL,'=> autopost;');
/*!40000 ALTER TABLE `feed` ENABLE KEYS */;
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
