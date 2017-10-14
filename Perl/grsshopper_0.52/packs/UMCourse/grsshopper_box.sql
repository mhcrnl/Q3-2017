-- MySQL dump 10.11
--
-- Host: localhost    Database: changes
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
-- Table structure for table `box`
--

DROP TABLE IF EXISTS `box`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `box` (
  `box_id` int(15) NOT NULL auto_increment,
  `box_title` varchar(255) default NULL,
  `box_description` varchar(255) default NULL,
  `box_content` text,
  `box_sub` varchar(5) default NULL,
  `box_format` varchar(10) default NULL,
  `box_day` varchar(12) default NULL,
  `box_creator` varchar(255) default NULL,
  `box_crdate` varchar(255) default NULL,
  `box_txt_version` int(5) default NULL,
  `box_rss_version` int(15) default NULL,
  `box_order` int(3) default NULL,
  PRIMARY KEY  (`box_id`)
) ENGINE=MyISAM AUTO_INCREMENT=22 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `box`
--
-- WHERE:  TRUE ORDER BY box_id

LOCK TABLES `box` WRITE;
/*!40000 ALTER TABLE `box` DISABLE KEYS */;
INSERT INTO `box` VALUES (19,'Sidebar',NULL,'<h2 style=\"margin-left:10px;\">Contents</h2>\r\n\r\n<p style=\"margin-left:10px;\">\r\n\r\n<b>Calendar</b><br />\r\n\r\n\r\n<a href=\"<st_url>calendar.htm\" title=\"Course Calendar\" alt=\"Course Calendar\">\r\n<img src=\"http://change.mooc.ca/files/images/mooc_calendar_icon.PNG\" border=\"1\" width=\"175\"></a>\r\n<br /><br />\r\n\r\n<b>This Course</b><br />\r\n<a href=\"<st_url>index.html\">Home Page</a><br />\r\n<a href=\"<st_url>about.htm\">About This Course</a><br />\r\n<a href=\"<st_url>outline.htm\">Course Outline</a><br />\r\n<a href=\"<st_url>how.htm\">How It Works</a><br />\r\n<a href=\"<st_url>facilitators.htm\">Course Facilitators</a><br />\r\n<a href=\"<st_url>privacy.htm\">Your Privacy</a><br />\r\n<a href=\"<st_url>contact.htm\">Contact Us</a><br /><br />\r\n\r\n\r\n\r\n<b>Your Account</b><br />\r\n\r\n<a href=\"<st_url>cgi-bin/login.cgi?action=Register\">Register</a><br />\r\n<a href=\"<st_url>cgi-bin/login.cgi\">Login</a><br />\r\n<a href=\"<st_url>options.htm\">Manage Account</a><br />\r\n<a href=\"<st_url>openid.htm\">About OpenID</a><br /><br />\r\n\r\n<b>Participating</b><br />\r\n<a href=\"<st_url>change_audio.htm\">Listen to Audio</a><br />\r\n<a href=\"<st_cgi>cchat.cgi\">Join a Backchannel Chat</a><br />\r\n<a href=\"<st_url>threads.htm\">Read Discussion Threads</a><br />\r\n<a href=\"<st_url>newsletter.htm\">Read Daily Newsletter</a><br />\r\n<a href=\"<st_url>archives.htm\">Newsletter Archives</a><br />\r\n<a href=\"<st_cgi>page.cgi?action=viewer\">Browse Blog Posts</a><br />\r\n<a href=\"<st_url>new_feed.htm\">Add a New Blog Feed</a><br />\r\n<a href=\"<st_url>feeds.htm\">View List of Blogs</a><br />\r\n<a href=\"<st_url>meetings.htm\">Live Meetings</a><br />\r\n<a href=\"<st_url>recordings.htm\">Listen to Recordings</a><br />\r\n<a href=\"<st_url>webbased.htm\">Web-based Activities</a><br /><br />\r\n\r\n<b>Feeds</b><br />\r\n<a href=\"<st_url>dailyposts.xml\">Announcements RSS</a><br />\r\n<a href=\"<st_url>dailyblogs.xml\">Blog Posts RSS</a><br />\r\n<a href=\"<st_url>opml.xml\">OPML List of Feeds</a><br /><br />\r\n\r\n<b>Contents</b><br />\r\n<a href=\"<st_url>week01.htm\">Week 01 : Orientation</a><br />\r\n<a href=\"<st_url>week02.htm\">Week 02: Zoraini Wati Abas</a><br />\r\n<a href=\"<st_url>week03.htm\">Week 03: Martin Weller</a><br />\r\n<a href=\"<st_url>week04.htm\">Week 04: Allison Littlejohn</a><br />\r\n<a href=\"<st_url>week05.htm\">Week 05: David Wiley</a><br />\r\n<a href=\"<st_url>week06.htm\">Week 06: Tony Bates</a><br />\r\n<a href=\"<st_url>week07.htm\">Week 07: Rory McGreal</a><br />\r\n<a href=\"<st_url>week08.htm\">Week 08: Nancy White</a><br />\r\n<a href=\"<st_url>week09.htm\">Week 09: Dave Cormier</a><br />\r\n<a href=\"<st_url>week10.htm\">Week 10: Eric Duval</a><br />\r\n<a href=\"<st_url>week11.htm\">Week 11: Jon Dron</a><br />\r\n<a href=\"<st_url>week12.htm\">Week 12: Clark Aldrich</a><br />\r\n<a href=\"<st_url>week13.htm\">Week 13: Clark Quinn</a><br />\r\n<a href=\"<st_url>week14.htm\">Week 14: Jan Herrington</a><br />\r\n<a href=\"<st_url>week15.htm\">Week 15: Break</a><br />\r\n<a href=\"<st_url>week16.htm\">Week 16: Break</a><br />\r\n<a href=\"<st_url>week15.htm\">Week 17: Howard Rheingold</a><br />\r\n<a href=\"<st_url>week16.htm\">Week 18: Valerie Irvine and Jillianne Code</a><br />\r\n<a href=\"<st_url>week17.htm\">Week 19: Dave Snowden</a><br />\r\n<a href=\"<st_url>week18.htm\">Week 20: Richard DeMillo, Ashwim Ram, Preetha Ram, and Hua Ali</a><br />\r\n<a href=\"<st_url>week21.htm\">Week 21: Break</a><br />\r\n<a href=\"<st_url>week22.htm\">Week 22: Pierre Levy</a><br />\r\n<a href=\"<st_url>week23.htm\">Week 23: Tom Reeves</a><br />\r\n<a href=\"<st_url>week24.htm\">Week 24: Geetha Narayanan</a></br/>\r\n<a href=\"<st_url>week25.htm\">Week 25: Stephen Downes</a></br/>\r\n<a href=\"<st_url>week27.htm\">Week 27: Antonio Vantaggiato</a></br/>\r\n<a href=\"<st_url>week28.htm\">Week 28: Tony Hirst</a></br/>\r\n<a href=\"<st_url>week29.htm\">Week 29: Alec Couros</a></br/>\r\n<a href=\"<st_url>week30.htm\">Week 30: Marti Cleveland-Innes</a></br/>\r\n<a href=\"<st_url>week31.htm\">Week 31: Diana Laurillard</a></br/>\r\n<a href=\"<st_url>week32.htm\">Week 32: George Siemens</a></br/>\r\n<a href=\"<st_url>week33.htm\">Week 33: George Veletsianos</a></br/>\r\n<a href=\"<st_url>week34.htm\">Week 34: Bonnie Stewart</a></br/>\r\n<a href=\"<st_url>week35.htm\">Week 35: Terry Anderson</a></br/>\r\n</p>',NULL,NULL,NULL,'1','1293381989',NULL,NULL,NULL),(20,'Navbar',NULL,'  <!-- MAIN MENU: Top horizontal menu of the site.  Use class=\"here\" to turn the current page tab on -->\r\n  <div id=\"mainMenu\">\r\n    <ul class=\"floatRight\">\r\n      <li><a href=\"<st_url>index.html\" title=\"Introduction\">Home</a></li>\r\n      <li><a href=\"<st_url>about.htm\" title=\"About\">About</a></li>\r\n      <li><a href=\"<st_url>contact.htm\" title=\"Get in touch\" class=\"last\">Contact</a></li>\r\n    </ul>\r\n  </div>',NULL,NULL,NULL,'1','1293382165',NULL,NULL,NULL),(21,'Calside',NULL,'<h2 style=\"margin-left:10px;\">Contents</h2>\r\n\r\n<p style=\"margin-left:10px;\">\r\n\r\n\r\n<b>This Course</b><br />\r\n<a href=\"<st_url>index.html\">Home Page</a><br />\r\n<a href=\"<st_url>about.htm\">About This Course</a><br />\r\n<a href=\"<st_url>outline.htm\">Course Outline</a><br />\r\n<a href=\"<st_url>how.htm\">How It Works</a><br />\r\n<a href=\"<st_url>facilitators.htm\">Course Facilitators</a><br />\r\n<a href=\"<st_url>privacy.htm\">Your Privacy</a><br />\r\n<a href=\"<st_url>contact.htm\">Contact Us</a><br /><br />\r\n\r\n\r\n\r\n<b>Your Account</b><br />\r\n\r\n<a href=\"<st_url>cgi-bin/login.cgi?action=Register\">Register</a><br />\r\n<a href=\"<st_url>cgi-bin/login.cgi\">Login</a><br />\r\n<a href=\"<st_url>options.htm\">Manage Account</a><br />\r\n<a href=\"<st_url>openid.htm\">About OpenID</a><br /><br />\r\n\r\n<b>Participating</b><br />\r\n<a href=\"<st_url>change_audio.htm\">Listen to Audio</a><br />\r\n<a href=\"<st_cgi>cchat.cgi\">Join a Backchannel Chat</a><br />\r\n<a href=\"<st_url>threads.htm\">Read Discussion Threads</a><br />\r\n<a href=\"<st_url>newsletter.htm\">Read Daily Newsletter</a><br />\r\n<a href=\"<st_url>archives.htm\">Newsletter Archives</a><br />\r\n<a href=\"<st_cgi>page.cgi?action=viewer\">Browse Blog Posts</a><br />\r\n<a href=\"<st_url>new_feed.htm\">Add a New Blog Feed</a><br />\r\n<a href=\"<st_url>feeds.htm\">View List of Blogs</a><br />\r\n<a href=\"<st_url>meetings.htm\">Live Meetings</a><br />\r\n<a href=\"<st_url>recordings.htm\">Listen to Recordings</a><br />\r\n<a href=\"<st_url>webbased.htm\">Web-based Activities</a><br /><br />\r\n\r\n<b>Feeds</b><br />\r\n<a href=\"<st_url>dailyposts.xml\">Announcements RSS</a><br />\r\n<a href=\"<st_url>dailyblogs.xml\">Blog Posts RSS</a><br />\r\n<a href=\"<st_url>opml.xml\">OPML List of Feeds</a><br /><br />\r\n\r\n<b>Contents</b><br />\r\n<a href=\"<st_url>week01.htm\">Week 01 : Orientation</a><br />\r\n<a href=\"<st_url>week02.htm\">Week 02: Zoraini Wati Abas</a><br />\r\n<a href=\"<st_url>week03.htm\">Week 03: Martin Weller</a><br />\r\n<a href=\"<st_url>week04.htm\">Week 04: Allison Littlejohn</a><br />\r\n<a href=\"<st_url>week05.htm\">Week 05: David Wiley</a><br />\r\n<a href=\"<st_url>week06.htm\">Week 06: Tony Bates</a><br />\r\n<a href=\"<st_url>week07.htm\">Week 07: Rory McGreal</a><br />\r\n<a href=\"<st_url>week08.htm\">Week 08: Nancy White</a><br />\r\n<a href=\"<st_url>week09.htm\">Week 09: Dave Cormier</a><br />\r\n<a href=\"<st_url>week10.htm\">Week 10: Eric Duval</a><br />\r\n<a href=\"<st_url>week11.htm\">Week 11: Jon Dron</a><br />\r\n<a href=\"<st_url>week12.htm\">Week 12: Clark Aldrich</a><br />\r\n<a href=\"<st_url>week13.htm\">Week 13: Clark Quinn</a><br />\r\n<a href=\"<st_url>week14.htm\">Week 14: Jan Herrington</a><br />\r\n<a href=\"<st_url>week15.htm\">Week 15: Break</a><br />\r\n<a href=\"<st_url>week16.htm\">Week 16: Break</a><br />\r\n<a href=\"<st_url>week15.htm\">Week 17: Howard Rheingold</a><br />\r\n<a href=\"<st_url>week16.htm\">Week 18: Valerie Irvine and Jillianne Code</a><br />\r\n<a href=\"<st_url>week17.htm\">Week 19: Dave Snowden</a><br />\r\n<a href=\"<st_url>week18.htm\">Week 20: Richard DeMillo, Ashwim Ram, Preetha Ram, and Hua Ali</a><br />\r\n<a href=\"<st_url>week21.htm\">Week 21: Break</a><br />\r\n<a href=\"<st_url>week22.htm\">Week 22: Pierre Levy</a><br />\r\n<a href=\"<st_url>week23.htm\">Week 23: Tom Reeves</a><br />\r\n<a href=\"<st_url>week24.htm\">Week 24: Geetha Narayanan</a></br/>\r\n<a href=\"<st_url>week25.htm\">Week 25: Stephen Downes</a></br/>\r\n<a href=\"<st_url>week27.htm\">Week 27: Antonio Vantaggiato</a></br/>\r\n<a href=\"<st_url>week28.htm\">Week 28: Tony Hirst</a></br/>\r\n<a href=\"<st_url>week29.htm\">Week 29: Alec Couros</a></br/>\r\n<a href=\"<st_url>week30.htm\">Week 30: Marti Cleveland-Innes</a></br/>\r\n<a href=\"<st_url>week31.htm\">Week 31: Diana Laurillard</a></br/>\r\n<a href=\"<st_url>week32.htm\">Week 32: George Siemens</a></br/>\r\n<a href=\"<st_url>week33.htm\">Week 33: George Veletsianos</a></br/>\r\n<a href=\"<st_url>week34.htm\">Week 34: Bonnie Stewart</a></br/>\r\n<a href=\"<st_url>week35.htm\">Week 35: Terry Anderson</a></br/>\r\n</p>\r\n',NULL,NULL,NULL,'10081','1320326207',NULL,NULL,NULL);
/*!40000 ALTER TABLE `box` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-09-05 18:40:26
