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
-- Table structure for table `project`
--

DROP TABLE IF EXISTS `project`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `project` (
  `project_key` int(15) NOT NULL auto_increment,
  `project_title` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `project_crdate` int(15) default NULL,
  `project_submitted` int(15) default NULL,
  `project_person` int(15) default NULL COMMENT 'Project lead, foreign key',
  `project_description` text collate utf8_unicode_ci,
  `project_rationale` text collate utf8_unicode_ci,
  `project_contribution` text collate utf8_unicode_ci,
  `project_previous` text collate utf8_unicode_ci,
  `project_workplan` text collate utf8_unicode_ci,
  `project_alignment` text collate utf8_unicode_ci,
  `project_research` text collate utf8_unicode_ci,
  `project_budget` text collate utf8_unicode_ci,
  `project_partners` text collate utf8_unicode_ci,
  `project_outputs` text collate utf8_unicode_ci,
  `project_measure` text collate utf8_unicode_ci,
  `project_risks` text collate utf8_unicode_ci,
  `project_approved` int(15) default NULL,
  `project_completion` int(15) default NULL,
  `project_creator` int(15) default NULL,
  PRIMARY KEY  (`project_key`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `project`
--
-- WHERE:  TRUE ORDER BY project_id

