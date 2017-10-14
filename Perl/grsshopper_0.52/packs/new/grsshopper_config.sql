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
) ENGINE=MyISAM AUTO_INCREMENT=175 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `config`
--
-- WHERE:  TRUE ORDER BY config_id

LOCK TABLES `config` WRITE;
/*!40000 ALTER TABLE `config` DISABLE KEYS */;
INSERT INTO `config` VALUES (1,NULL,'reset_key',NULL,'1339764271'),(2,NULL,'st_url',NULL,'http://course.downes.ca/'),(3,NULL,'st_cgi',NULL,'http://course.downes.ca/cgi-bin/'),(4,NULL,'co_host',NULL,'downes.ca'),(5,NULL,'st_urlf',NULL,'/var/www/course/'),(6,NULL,'st_cgif',NULL,'/var/www/cgi-bin/'),(7,NULL,'st_data',NULL,'/var/www/cgi-bin/data/'),(8,NULL,'st_name',NULL,'Course'),(9,NULL,'st_tag',NULL,'#Course'),(10,NULL,'st_pub',NULL,'Course Publisher'),(11,NULL,'st_cre',NULL,'Course Author'),(12,NULL,'st_archive',NULL,'/var/www/course/archive/'),(13,NULL,'st_css',NULL,'/var/www/course/css/'),(14,NULL,'st_files',NULL,'/var/www/course/files/'),(15,NULL,'st_images',NULL,'/var/www/course/images/'),(16,NULL,'st_js',NULL,'/var/www/course/js/'),(17,NULL,'st_logs',NULL,'/var/www/course/logs/'),(18,NULL,'st_stats',NULL,'/var/www/course/stats/'),(19,NULL,'st_uploads',NULL,'/var/www/course/uploads/'),(20,NULL,'up_audio',NULL,'/var/www/course/audio/'),(21,NULL,'up_images',NULL,'/var/www/course/images/'),(22,NULL,'up_video',NULL,'/var/www/course/video/'),(23,NULL,'up_documents',NULL,'/var/www/course/documents/'),(24,NULL,'up_slides',NULL,'/var/www/course/slides/'),(25,NULL,'st_url',NULL,'http://course.downes.ca/'),(26,NULL,'st_cgi',NULL,'http://course.downes.ca/cgi-bin/'),(27,NULL,'co_host',NULL,'downes.ca'),(28,NULL,'st_urlf',NULL,'/var/www/course/'),(29,NULL,'st_cgif',NULL,'/var/www/cgi-bin/'),(30,NULL,'st_data',NULL,'/var/www/cgi-bin/data/'),(31,NULL,'st_name',NULL,'Course'),(32,NULL,'st_tag',NULL,'#Course'),(33,NULL,'st_pub',NULL,'Course Publisher'),(34,NULL,'st_cre',NULL,'Course Author'),(35,NULL,'st_archive',NULL,'/var/www/course/archive/'),(36,NULL,'st_css',NULL,'/var/www/course/css/'),(37,NULL,'st_files',NULL,'/var/www/course/files/'),(38,NULL,'st_images',NULL,'/var/www/course/images/'),(39,NULL,'st_js',NULL,'/var/www/course/js/'),(40,NULL,'st_logs',NULL,'/var/www/course/logs/'),(41,NULL,'st_stats',NULL,'/var/www/course/stats/'),(42,NULL,'st_uploads',NULL,'/var/www/course/uploads/'),(43,NULL,'up_audio',NULL,'/var/www/course/audio/'),(44,NULL,'up_images',NULL,'/var/www/course/images/'),(45,NULL,'up_video',NULL,'/var/www/course/video/'),(46,NULL,'up_documents',NULL,'/var/www/course/documents/'),(47,NULL,'up_slides',NULL,'/var/www/course/slides/'),(48,NULL,'st_url',NULL,'http://course.downes.ca/'),(49,NULL,'st_cgi',NULL,'http://course.downes.ca/cgi-bin/'),(50,NULL,'co_host',NULL,'downes.ca'),(51,NULL,'st_urlf',NULL,'/var/www/course/'),(52,NULL,'st_cgif',NULL,'/var/www/cgi-bin/'),(53,NULL,'st_data',NULL,'/var/www/cgi-bin/data/'),(54,NULL,'st_name',NULL,'Course'),(55,NULL,'st_tag',NULL,'#Course'),(56,NULL,'st_pub',NULL,'Course Publisher'),(57,NULL,'st_cre',NULL,'Course Author'),(58,NULL,'st_archive',NULL,'/var/www/course/archive/'),(59,NULL,'st_css',NULL,'/var/www/course/css/'),(60,NULL,'st_files',NULL,'/var/www/course/files/'),(61,NULL,'st_images',NULL,'/var/www/course/images/'),(62,NULL,'st_js',NULL,'/var/www/course/js/'),(63,NULL,'st_logs',NULL,'/var/www/course/logs/'),(64,NULL,'st_stats',NULL,'/var/www/course/stats/'),(65,NULL,'st_uploads',NULL,'/var/www/course/uploads/'),(66,NULL,'up_audio',NULL,'/var/www/course/audio/'),(67,NULL,'up_images',NULL,'/var/www/course/images/'),(68,NULL,'up_video',NULL,'/var/www/course/video/'),(69,NULL,'up_documents',NULL,'/var/www/course/documents/'),(70,NULL,'up_slides',NULL,'/var/www/course/slides/'),(71,NULL,'st_crea',NULL,'ss'),(72,NULL,'st_license',NULL,'CC By-NC-SA'),(73,NULL,'st_timezone',NULL,''),(74,NULL,'person_status',NULL,''),(75,NULL,'st_crea',NULL,'ss'),(76,NULL,'st_timezone',NULL,''),(77,NULL,'person_status',NULL,''),(78,NULL,'st_crea',NULL,'ss'),(79,NULL,'st_timezone',NULL,''),(80,NULL,'person_status',NULL,''),(81,NULL,'st_timezone',NULL,''),(82,NULL,'person_status',NULL,''),(83,NULL,'st_timezone',NULL,''),(84,NULL,'person_status',NULL,''),(85,NULL,'st_timezone',NULL,'ADT'),(86,NULL,'person_status',NULL,''),(87,NULL,'st_reg_on',NULL,'yes'),(88,NULL,'person_status',NULL,''),(89,NULL,'create_author',NULL,'admin'),(90,NULL,'edit_author',NULL,'admin'),(91,NULL,'delete_author',NULL,'admin'),(92,NULL,'view_author',NULL,'anyone'),(93,NULL,'create_box',NULL,'admin'),(94,NULL,'edit_box',NULL,'admin'),(95,NULL,'delete_box',NULL,'admin'),(96,NULL,'view_box',NULL,'anyone'),(97,NULL,'create_event',NULL,'admin'),(98,NULL,'edit_event',NULL,'admin'),(99,NULL,'delete_event',NULL,'admin'),(100,NULL,'view_event',NULL,'anyone'),(101,NULL,'create_feed',NULL,'registered'),(102,NULL,'edit_feed',NULL,'owner'),(103,NULL,'delete_feed',NULL,'admin'),(104,NULL,'view_feed',NULL,'anyone'),(105,NULL,'create_file',NULL,'registered'),(106,NULL,'edit_file',NULL,'admin'),(107,NULL,'delete_file',NULL,'admin'),(108,NULL,'view_file',NULL,'anyone'),(109,NULL,'create_journal',NULL,'admin'),(110,NULL,'edit_journal',NULL,'admin'),(111,NULL,'delete_journal',NULL,'admin'),(112,NULL,'view_journal',NULL,'anyone'),(113,NULL,'create_link',NULL,'admin'),(114,NULL,'edit_link',NULL,'admin'),(115,NULL,'delete_link',NULL,'admin'),(116,NULL,'view_link',NULL,'anyone'),(117,NULL,'create_mapping',NULL,'admin'),(118,NULL,'edit_mapping',NULL,'admin'),(119,NULL,'delete_mapping',NULL,'admin'),(120,NULL,'view_mapping',NULL,'admin'),(121,NULL,'create_optlist',NULL,'admin'),(122,NULL,'edit_optlist',NULL,'admin'),(123,NULL,'delete_optlist',NULL,'admin'),(124,NULL,'view_optlist',NULL,'admin'),(125,NULL,'create_page',NULL,'admin'),(126,NULL,'edit_page',NULL,'admin'),(127,NULL,'delete_page',NULL,'admin'),(128,NULL,'view_page',NULL,'anyone'),(129,NULL,'create_person',NULL,'admin'),(130,NULL,'edit_person',NULL,'owner'),(131,NULL,'delete_person',NULL,'admin'),(132,NULL,'view_person',NULL,'owner'),(133,NULL,'create_post',NULL,'registered'),(134,NULL,'edit_post',NULL,'owner'),(135,NULL,'delete_post',NULL,'admin'),(136,NULL,'view_post',NULL,'anyone'),(137,NULL,'create_presentation',NULL,'owner'),(138,NULL,'edit_presentation',NULL,'admin'),(139,NULL,'delete_presentation',NULL,'admin'),(140,NULL,'view_presentation',NULL,'anyone'),(141,NULL,'create_project',NULL,'admin'),(142,NULL,'edit_project',NULL,'admin'),(143,NULL,'delete_project',NULL,'admin'),(144,NULL,'view_project',NULL,'anyone'),(145,NULL,'create_publication',NULL,'admin'),(146,NULL,'edit_publication',NULL,'admin'),(147,NULL,'delete_publication',NULL,'admin'),(148,NULL,'view_publication',NULL,'anyone'),(149,NULL,'create_publisher',NULL,'admin'),(150,NULL,'edit_publisher',NULL,'admin'),(151,NULL,'delete_publisher',NULL,'admin'),(152,NULL,'view_publisher',NULL,'anyone'),(153,NULL,'create_task',NULL,'admin'),(154,NULL,'edit_task',NULL,'admin'),(155,NULL,'delete_task',NULL,'admin'),(156,NULL,'view_task',NULL,'anyone'),(157,NULL,'create_template',NULL,'admin'),(158,NULL,'edit_template',NULL,'admin'),(159,NULL,'delete_template',NULL,'admin'),(160,NULL,'view_template',NULL,'anyone'),(161,NULL,'create_thread',NULL,'admin'),(162,NULL,'edit_thread',NULL,'admin'),(163,NULL,'delete_thread',NULL,'admin'),(164,NULL,'view_thread',NULL,'anyone'),(165,NULL,'create_topic',NULL,'admin'),(166,NULL,'edit_topic',NULL,'admin'),(167,NULL,'delete_topic',NULL,'admin'),(168,NULL,'view_topic',NULL,'anyone'),(169,NULL,'create_view',NULL,'admin'),(170,NULL,'edit_view',NULL,'admin'),(171,NULL,'delete_view',NULL,'admin'),(172,NULL,'view_view',NULL,'anyone'),(173,NULL,'person_status',NULL,''),(174,NULL,'person_status',NULL,'');
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

-- Dump completed on 2012-07-05 13:50:30
