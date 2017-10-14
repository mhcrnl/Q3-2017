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
  PRIMARY KEY  (`feed_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `feed`
--
-- WHERE:  TRUE ORDER BY feed_id

LOCK TABLES `feed` WRITE;
/*!40000 ALTER TABLE `feed` DISABLE KEYS */;
INSERT INTO `feed` VALUES (1,NULL,'RSS 2.0','UUsflQMSvYSfyncnse','GssZy8  rebmbpyogxir, [url=http://dmmezsdibitm.com/]dmmezsdibitm[/url], [link=http://uneaswqhhcnb.com/]uneaswqhhcnb[/link], http://uqdueoxhwadn.com/','TcyQkCixUfgtntCJvT','http://yuscfwujbfhl.com/',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'category',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'O',1339864152,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'nbcpxw',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'2'),(2,NULL,'RSS 2.0','IFKDtkJRhLhyTjEjGMb','4NoJYc  qyixbqnfbmpq, [url=http://aqqkpfjxapga.com/]aqqkpfjxapga[/url], [link=http://eczvrsnczozq.com/]eczvrsnczozq[/link], http://xstdizaotvei.com/','VceCgLHwI','http://tuyilmgofztw.com/',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'category',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'O',1339878170,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'odrvwf',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'2'),(3,NULL,'RSS 2.0','pkkUacKIYioVbteR','nuKBFn  euooiimmazfx, [url=http://wxmjdtradtiy.com/]wxmjdtradtiy[/url], [link=http://zbtkottreomw.com/]zbtkottreomw[/link], http://yhdxcttidnad.com/','MgDChoXogYeVUCe','http://mwwtvjtjblsj.com/',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'category',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'O',1339888220,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tgfhemt',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'2');
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

-- Dump completed on 2012-08-13 17:02:49
