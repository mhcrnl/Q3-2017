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
-- Table structure for table `mapping`
--

DROP TABLE IF EXISTS `mapping`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `mapping` (
  `mapping_id` int(15) NOT NULL auto_increment,
  `mapping_title` varchar(255) default NULL,
  `mapping_stype` varchar(64) default NULL,
  `mapping_specific_feed` int(15) default NULL,
  `mapping_feed_type` varchar(32) default NULL,
  `mapping_feed_fields` varchar(127) default NULL,
  `mapping_field_value_pair` varchar(255) default NULL,
  `mapping_dtable` varchar(32) default NULL,
  `mapping_crdate` int(15) default NULL,
  `mapping_creator` int(15) default NULL,
  `mapping_update` int(15) default NULL,
  `mappung_upby` int(15) default NULL,
  `mapping_mappings` text,
  `mapping_values` text,
  `mapping_prefix` varchar(32) default NULL,
  `mapping_priority` varchar(250) default NULL,
  PRIMARY KEY  (`mapping_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `mapping`
--
-- WHERE:  TRUE ORDER BY mapping_id

LOCK TABLES `mapping` WRITE;
/*!40000 ALTER TABLE `mapping` DISABLE KEYS */;
INSERT INTO `mapping` VALUES (1,'Twitter #oped12 feed -> link','mapping_specific_feed',29,NULL,NULL,NULL,'link',1347449481,1,NULL,NULL,'mapping_stype,mapping_specific_feed;mapping_specific_feed,29;mapping_dtable,link;mapping_priority,1;mapping_tval_field,link_type;mapping_tval_value,twitter;link_title,link_title;link_description,link_description;link_type,link_type;link_link,link_link;link_category,link_category;link_guid,link_guid;link_created,link_created;link_issued,link_issued;link_author,link_author;link_authorname,link_authorname;link_authorurl,link_authorurl;link_modified,link_modified;link_localcat,link_localcat;link_feedid,link_feedid;link_feedname,link_feedname;mapping_title,Twitter #oped12 feed -> link','link_type,twitter',NULL,'1'),(2,'Diigo Open Ed 2012 Feed -> link','mapping_specific_feed',30,NULL,NULL,NULL,'link',1347450016,1,NULL,NULL,'mapping_stype,mapping_specific_feed;mapping_specific_feed,30;mapping_dtable,link;mapping_priority,1;mapping_tval_field,link_type;mapping_tval_value,Diigo;link_title,link_title;link_description,link_description;link_type,link_type;link_link,link_link;link_category,link_category;link_guid,link_guid;link_created,link_created;link_issued,link_issued;link_author,link_author;link_authorname,link_authorname;link_authorurl,link_authorurl;link_modified,link_modified;link_localcat,link_localcat;link_feedid,link_feedid;link_feedname,link_feedname;mapping_title,Diigo Open Ed 2012 Feed -> link','link_type,Diigo',NULL,'1');
/*!40000 ALTER TABLE `mapping` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-10-01 16:43:37
