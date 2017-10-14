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
-- Table structure for table `config`
--

DROP TABLE IF EXISTS `config`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `config` (
  `config_id` int(5) NOT NULL auto_increment,
  `config_type` varchar(255) default NULL,
  `config_noun` varchar(255) default NULL,
  `config_verb` varchar(255) default NULL,
  `config_value` varchar(255) default NULL,
  KEY `config_id` (`config_id`)
) ENGINE=MyISAM AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `config`
--
-- WHERE:  TRUE ORDER BY config_id

LOCK TABLES `config` WRITE;
/*!40000 ALTER TABLE `config` DISABLE KEYS */;
INSERT INTO `config` VALUES (1,NULL,'reset_key',NULL,'1341531238'),(2,NULL,'st_url',NULL,'http://course.downes.ca/'),(3,NULL,'st_cgi',NULL,'http://course.downes.ca/cgi-bin/'),(4,NULL,'co_host',NULL,'downes.ca'),(5,NULL,'st_urlf',NULL,'/var/www/course/'),(6,NULL,'st_cgif',NULL,'/var/www/cgi-bin/'),(7,NULL,'st_data',NULL,'/var/www/cgi-bin/data/'),(8,NULL,'st_name',NULL,'Course'),(9,NULL,'st_tag',NULL,'#Course'),(10,NULL,'st_pub',NULL,'Course Publisher'),(11,NULL,'st_cre',NULL,'Course Author'),(12,NULL,'st_archive',NULL,'/var/www/course/archive/'),(13,NULL,'st_css',NULL,'/var/www/course/css/'),(14,NULL,'st_files',NULL,'/var/www/course/files/'),(15,NULL,'st_images',NULL,'/var/www/course/images/'),(16,NULL,'st_js',NULL,'/var/www/course/js/'),(17,NULL,'st_logs',NULL,'/var/www/course/logs/'),(18,NULL,'st_stats',NULL,'/var/www/course/stats/'),(19,NULL,'st_uploads',NULL,'/var/www/course/uploads/'),(20,NULL,'up_audio',NULL,'/var/www/course/audio/'),(21,NULL,'up_images',NULL,'/var/www/course/images/'),(22,NULL,'up_video',NULL,'/var/www/course/video/'),(23,NULL,'up_documents',NULL,'/var/www/course/documents/'),(24,NULL,'up_slides',NULL,'/var/www/course/slides/');
/*!40000 ALTER TABLE `config` ENABLE KEYS */;
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
