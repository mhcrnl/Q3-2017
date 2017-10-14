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
-- Table structure for table `author`
--

DROP TABLE IF EXISTS `author`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `author` (
  `author_id` int(11) NOT NULL auto_increment,
  `author_link` varchar(255) default NULL,
  `author_name` varchar(123) default NULL,
  `author_description` text,
  `author_crdate` int(15) default NULL,
  `box_test` varchar(250) default NULL,
  `author_nickname` varchar(250) default NULL,
  `author_twitter` varchar(250) default NULL,
  `author_linkedin` varchar(250) default NULL,
  `author_delicious` varchar(250) default NULL,
  `author_flickr` varchar(250) default NULL,
  `author_email` varchar(250) default NULL,
  `author_creator` varchar(250) default NULL,
  `author_opensocialuserid` varchar(250) default NULL,
  `author_person` varchar(250) default NULL,
  `author_facebook` varchar(250) default NULL,
  `author_socialnet` varchar(250) default NULL,
  PRIMARY KEY  (`author_id`)
) ENGINE=MyISAM AUTO_INCREMENT=44 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `author`
--
-- WHERE:  TRUE ORDER BY author_id

LOCK TABLES `author` WRITE;
/*!40000 ALTER TABLE `author` DISABLE KEYS */;
INSERT INTO `author` VALUES (1,'http://filosofiadebolsillo.wordpress.com','FilodeBolsillo',NULL,1347449172,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'3',NULL,NULL,NULL,NULL),(2,'http://annehole.wordpress.com','annehole',NULL,1347890643,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(3,'http://brainysmurf1234.wordpress.com','brainysmurf1234',NULL,1347890763,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(4,'http://suifaijohnmak.wordpress.com','suifaijohnmak',NULL,1347890884,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(5,'http://claudiaguerreros.wordpress.com','claudiaguerreros',NULL,1347891004,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(6,'http://cathygermano.wordpress.com','CathyGermano',NULL,1347891243,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(7,'http://openeduodyssey.wordpress.com','navarre',NULL,1347891363,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(8,'http://opendistanceteachingandlearning.wordpress.com','opendistanceteachingandlearning',NULL,1347891483,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(9,'http://dougpete.wordpress.com','dougpete',NULL,1347891603,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(10,'http://thecastel.wordpress.com','thecastel',NULL,1347891722,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(11,'http://moocworld.blogspot.com/','Mark',NULL,1347892082,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(12,'http://hakanwester.se','Hocke',NULL,1347892204,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(13,'http://www.blogger.com/profile/14427008736132127215','yukondude',NULL,1347892443,NULL,NULL,NULL,NULL,NULL,NULL,'noreply@blogger.com','2',NULL,NULL,NULL,NULL),(14,'http://www.dimitristzouris.org/','Dimitris Tzouris',NULL,1347892683,NULL,NULL,NULL,NULL,NULL,NULL,'noreply@blogger.com','2',NULL,NULL,NULL,NULL),(15,'http://www.blogger.com/profile/03187869027295073212','Lee Anne Morris',NULL,1347892804,NULL,NULL,NULL,NULL,NULL,NULL,'noreply@blogger.com','2',NULL,NULL,NULL,NULL),(16,'http://www.blogger.com/profile/02534886308864289544','Osvaldo',NULL,1347892923,NULL,NULL,NULL,NULL,NULL,NULL,'noreply@blogger.com','2',NULL,NULL,NULL,NULL),(17,'http://apointofcontact.wordpress.com','Glenyan',NULL,1347893163,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(18,'http://zmldidaktik.wordpress.com','jupidu',NULL,1347893284,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(19,'http://tecnodoc.uc3m.es','gbueno',NULL,1347893523,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(20,'http://serenaturri.wordpress.com','serenaturri',NULL,1347893762,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(21,'http://www.blogger.com/profile/16895029067006588081','markwashere',NULL,1347893883,NULL,NULL,NULL,NULL,NULL,NULL,'noreply@blogger.com','2',NULL,NULL,NULL,NULL),(22,'http://maryakem.wordpress.com','maryakem',NULL,1347894003,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(23,'https://landing.athabascau.ca/blog/owner/rory','Rory McGreal',NULL,1347894124,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(24,'http://theelearner.com','elearning_explorer',NULL,1347894242,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(25,'http://feefihohum.wordpress.com','feefihohum',NULL,1347894604,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(26,'http://aswonderfulassunsets.blogspot.com/','Bill Miller',NULL,1347894963,NULL,NULL,NULL,NULL,NULL,NULL,'noreply@blogger.com','2',NULL,NULL,NULL,NULL),(27,NULL,'George Siemens',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(28,'http://theelearner.com','Ya-Yin Ko',NULL,1348104005,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(29,'http://www.blogger.com/profile/10237169838657305465','Brenda Herchmer',NULL,1348571883,NULL,NULL,NULL,NULL,NULL,NULL,'noreply@blogger.com','2',NULL,NULL,NULL,NULL),(30,'http://elearnchristiana.wordpress.com','elearnchristiana',NULL,1348572004,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(31,'http://markmcguire.net','Mark McGuire',NULL,1348572243,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(32,'http://bustlingbazaars.wordpress.com','lrenshaw11',NULL,1348572482,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(33,'http://openforlearning.wordpress.com','openforlearning',NULL,1348572722,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(34,'http://mundosvirtuales3dyeducacion.blogspot.com/','Silvia Brugnoni',NULL,1348572843,NULL,NULL,NULL,NULL,NULL,NULL,'noreply@blogger.com','2',NULL,NULL,NULL,NULL),(35,'http://moocmadness.wordpress.com','VanessaVaile',NULL,1348572963,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(36,'http://taiarnold.wordpress.com','taiarnold',NULL,1348573084,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(37,'http://tjbliss.org','tjbliss',NULL,1348573206,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(38,'http://connectiv.wordpress.com','jaapsoft2',NULL,1348573322,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(39,'http://www.blogger.com/profile/05603560361267577707','Petra',NULL,1348573443,NULL,NULL,NULL,NULL,NULL,NULL,'noreply@blogger.com','2',NULL,NULL,NULL,NULL),(40,'https://onlinelearninginsights.wordpress.com','onlinelearninginsights',NULL,1348573563,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(41,'http://www.cheshirepuss.co.uk','ian',NULL,1348715765,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(42,'http://foadblog.wordpress.com/2012/09/06/foad_connectiviste/','CDATA(0)',NULL,1348715884,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL),(43,'http://blogasaurus.posterous.com','Jan Herder',NULL,1349099284,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `author` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-10-01 16:43:36
