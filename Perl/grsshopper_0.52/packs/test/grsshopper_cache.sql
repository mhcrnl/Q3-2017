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
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `cache` (
  `cache_id` int(15) NOT NULL auto_increment,
  `cache_title` varchar(127) default NULL,
  `cache_update` int(15) default '0',
  `cache_text` longtext character set utf8 collate utf8_unicode_ci,
  PRIMARY KEY  (`cache_id`),
  KEY `cache_title` (`cache_title`)
) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `cache`
--
-- WHERE:  TRUE ORDER BY cache_id

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES (1,'RECORD_page_168_PAGE_OUTLINE',1341531472,'<p>[<a href=\"http://course.downes.ca/week1.htm\"> Week 1 - What Is Connectivism?</a>]<br/>\r\n</p>'),(2,'RECORD_page_177_PAGE_OUTLINE',1341531472,'<p>[<a href=\"http://course.downes.ca/week10.htm\"> Week 10 - Net Pedagogy: The Role of the Educator</a>]<br/>\r\n</p>'),(3,'RECORD_page_178_PAGE_OUTLINE',1341531472,'<p>[<a href=\"http://course.downes.ca/week11.htm\"> Week 11 - Research &amp; Analytics</a>]<br/>\r\n</p>'),(4,'RECORD_page_179_PAGE_OUTLINE',1341531472,'<p>[<a href=\"http://course.downes.ca/week12.htm\"> Week 12 - Changing Views, Changing Systems</a>]<br/>\r\n</p>'),(5,'RECORD_page_169_PAGE_OUTLINE',1341531472,'<p>[<a href=\"http://course.downes.ca/week2.htm\"> Week 2 - Patterns of Connectivity</a>]<br/>\r\n</p>'),(6,'RECORD_page_170_PAGE_OUTLINE',1341531472,'<p>[<a href=\"http://course.downes.ca/week3.htm\"> Week 3 - Connective Knowledge</a>]<br/>\r\n</p>'),(7,'RECORD_page_171_PAGE_OUTLINE',1341531472,'<p>[<a href=\"http://course.downes.ca/week4.htm\"> Week 4 - What Makes Connectivism Unique?</a>]<br/>\r\n</p>'),(8,'RECORD_page_172_PAGE_OUTLINE',1341531472,'<p>[<a href=\"http://course.downes.ca/week5.htm\"> Week 5 - Groups, Networks and Collectives</a>]<br/>\r\n</p>'),(9,'RECORD_page_173_PAGE_OUTLINE',1341531472,'<p>[<a href=\"http://course.downes.ca/week6.htm\"> Week 6 - Personal Learning Environments &amp; Networks </a>]<br/>\r\n</p>'),(10,'RECORD_page_174_PAGE_OUTLINE',1341531472,'<p>[<a href=\"http://course.downes.ca/week7.htm\"> Week 7 - Complex Adaptive Systems</a>]<br/>\r\n</p>'),(11,'RECORD_page_175_PAGE_OUTLINE',1341531472,'<p>[<a href=\"http://course.downes.ca/week8.htm\"> Week 8 -  Power &amp; Authority</a>]<br/>\r\n</p>'),(12,'RECORD_page_176_PAGE_OUTLINE',1341531472,'<p>[<a href=\"http://course.downes.ca/week9.htm\"> Week 9 - Openness &amp; Transparency</a>]<br/>\r\n</p>'),(13,'RECORD_post_1_POST_LINK_SUMMARY',1341531516,'\r\n<strong><a href=\"http://www.downes.ca\">Tedst</a></strong><br />\r\n<a href=\"?author=\"></a>, \r\n<a href=\"?journal=\"></a>, July 5, 2012.\r\n<p>This is a test post</p> \r\n\r\n<br /><br />');
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-07-05 23:39:02
