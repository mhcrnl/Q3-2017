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
-- Table structure for table `view`
--

DROP TABLE IF EXISTS `view`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `view` (
  `view_id` int(15) NOT NULL auto_increment,
  `view_title` varchar(36) default 'untitled',
  `view_text` text,
  `view_creator` int(15) default NULL,
  `view_crdate` int(15) default NULL,
  PRIMARY KEY  (`view_id`)
) ENGINE=MyISAM AUTO_INCREMENT=330 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `view`
--
-- WHERE:  TRUE ORDER BY view_id

LOCK TABLES `view` WRITE;
/*!40000 ALTER TABLE `view` DISABLE KEYS */;
INSERT INTO `view` VALUES (234,'template_list','<admin template,[*template_id*]> <a href=\"?template=[*template_id*]\">[*template_title*]</a><br/>',1,1292786928),(235,'view_list','<admin view,[*view_id*]> <a href=\"?view=[*view_id*]\">[*view_title*]</a><br/>',1,1292786984),(236,'page_list','[*page_type*] <admin page,[*page_id*]>\r\n[<a href=\"?page=[*page_id*]&action=publish&mode=report\">Publish</a>] [<a href=\"<st_url>page/[*page_id*]\">Preview</a>] [<a href=\"<st_url>[*page_location*]\">Current</a>]  [*page_title*]</a><br/>',1,1292787073),(237,'optlist_list','<admin optlist,[*optlist_id*]> <a href=\"?optlist=[*optlist_id*]\">[*optlist_title*]</a><br/>',1,1292791938),(238,'author_list','<admin author,[*author_id*]> <a href=\"page.cgi?author=[*author_id*]\">[*author_name*]</a><br/>',1,1292794337),(239,'box_list','<admin box,[*box_id*]>  <a href=\"?box=[*box_id*]\">[*box_title*]</a><br/>',1,1292794361),(240,'event_list','<admin event,[*event_id*]>  <a href=\"?event=[*event_id*]\">[*event_title*]</a><br/>',1,1292794443),(241,'feed_list','[*feed_command*] <admin feed,[*feed_id*]> [*feed_links*] Links: <a href=\"?feed=[*feed_id*]\">[*feed_title*]</a> ([*feed_category*])<br/>',1,1292794486),(242,'file_list','<admin file,[*file_id*]> <a href=\"?file=[*file_id*]\">[*file_title*]</a><br/>',1,1292794516),(243,'journal_list','<admin journal,[*journal_id*]>  <a href=\"?journal=[*journal_id*]\">[*journal_title*]</a><br/>',1,1292794569),(244,'link_list','<admin link,[*link_id*]> [*link_type*] <a href=\"?link=[*link_id*]\">[*link_title*]</a> ([*link_hits*] hits)<br>\r\n',1,1292794649),(245,'mapping_list','<admin mapping,[*mapping_id*]> <a href=\"?mapping=[*mapping_id*]&action=edit\">[*mapping_title*]</a><br/>',1,1292794681),(246,'post_list','<admin post,[*post_id*]> <a href=\"<st_url>post/[*post_id*]\">[*post_title*]</a> <NICE_DATE>[*post_crdate*]<END_NICE_DATE><br/>',1,1292794729),(247,'presentation_list','<admin presentation,[*presentation_id*]> \r\n<a href=\"?presentation=[*presentation_id*]\">[*presentation_title*]</a>, \r\n<NICE_DATE>[*presentation_crdate*]<END_NICE_DATE><br/>',1,1292794759),(248,'project_list','<admin project,[*project_id*]>  <a href=\"?project=[*project_id*]\">[*project_title*]</a><br/>',1,1292794815),(249,'publication_list','<admin publication,[*publication_id*]>  <a href=\"?publication=[*publication_id*]\">[*publication_title*]</a>, <NICE_DATE>[*publication_crdate*]<END_NICE_DATE><br/>\r\n',1,1292794880),(250,'topic_list','<admin topic,[*topic_id*]>  <a href=\"?topic=[*topic_id*]\">[*topic_title*]</a><br/>',1,1292794981),(251,'person_list','<admin person,[*person_id*]> <a href=\"?person=[*person_id*]\">[*person_title*]</a> ([*person_name*] - [*person_email*])<br />\r\n',1,1292797139),(252,'author_html','<h1>[*author_name*]</h1>\r\n\r\n<p>link: <a href=\"[*author_link*]\">[*author_link*]</a></p>\r\n<p>[*author_description*]  <admin author,[*author_id*]></p>\r\n\r\n<h3>Posts referring to articles by [*author_name*]</h3>\r\n<keyword db=post;author=[*author_name*];format=link_summary;sort=crdate DESC>',1,1293381670),(253,'post_link_summary','<keyword db=file;type=Illustration;align=top;post=[*post_id*];format=top;number=1>\r\n<strong><a href=\"[*post_link*]\">[*post_title*]</a></strong><br />\r\n<a href=\"?author=[*post_author*]\">[*post_author*]</a>, \r\n<a href=\"?journal=[*post_journal*]\">[*post_journal*]</a>, <NICE_DATE>[*post_crdate*]<END_NICE_DATE>.\r\n<keyword db=file;type=Illustration;align=left;post=[*post_id*];format=left;number=1><keyword db=file;type=Illustration;align=right;post=[*post_id*];format=right;number=1>[*post_description*] \r\n<keyword db=file;type=Enclosure;post=[*post_id*];format=hencl>\r\n<keyword db=file;type=Illustration;align=bottom;post=[*post_id*];format=bottom;number=1><br /><br />',1,1293381731),(254,'box_html','[*box_content*] <admin box,[*box_id*]>',1,1293381814),(255,'event_html','<h1>[*event_title*]</h1>\r\n<p><b><a href=\" [*event_link*]\">Click Here to Attend Event</a></b><br />\r\nSpeakers: [*event_star*]<br/>\r\nStart:  [*event_start*] EDT (<a href=\"http://www.timeanddate.com/worldclock/fixedtime.html?iso=20111125T12&p1=250\">Check Time Zones</a>)<br/>\r\nFinish: [*event_finish*] EDT<br/>\r\n[*event_description*]</p>',1,1293384415),(256,'thread_list','[<a href=\"?thread=[*thread_id*]&action=edit\">Edit</a>]\r\n<a href=\"?thread=[*thread_id*]\">[*thread_title*]</a> <NICE_DATE>[*thread_crdate*]<END_NICE_DATE><br/>',1,1293387760),(257,'thread_html','<p><b>[*thread_title*]</b><br />\r\n[*thread_description*] <a href=\"http://www.downes.ca/cgi-bin/cchat.cgi?chat_thread=[*thread_id*]\">Join thread</a>.</p>',1,1293387795),(258,'event_summary','<DATERANGE>[*event_start*],[*event_end*]<END_DATERANGE>: <a href=\"<st_cgi>page.cgi?event=[*event_id*]\">[*event_title*]</a> - [*event_location*]\r\n[*event_description*]<br/><br/>',1,1293411524),(259,'feed_html','<h1>[*feed_title*]</h1>\r\n<p></i>[*feed_authorname*]</i><br/>\r\n<img src=\"[*feed_imgURL*]\" height=\"[*feed_imgheight*]\" width=\"[*feed_width*]\"  alt=\"[*feed_title*] [*feed_imgTitle*] [*feed_imgCreator*]\" border=\"0\"></a><br/>[*feed_description*]\r\n[<a href=\"[*feed_html*]\">HTML</a>]\r\n[<a href=\"[*feed_link*]\">XML</a>]\r\nLast Updated: [*feed_lastBuildDate*]<br/>\r\n</p>\r\n\r\n\r\n\r\n<h2>Recent Posts kk</h2>\r\n<keyword db=link;feedid=[*feed_id*];format=html;truncate=500;title,description,category~change11;sort=crdate DESC>\r\n\r\n\r\n<hr>\r\n\r\n<p>Information about this feed is obtained from the <a href=\"[*feed_link*]\">feed XML file</a>. Feed owners may supply additional information by updating their XML file or by sending email to <a href=\"mailto:stephen@downes.ca\">stephen@downes.ca</a>\r\n <admin feed,[*feed_id*]></p>',1,1293411634),(260,'file_bottom','<br/><a href=\"[*file_link*]\"><img class=\"bottom\" src=\"<st_url>[*file_dirname*]\" alt=\"[*file_dirname*], size: [*file_size*] bytes, type:  [*file_mime*] \" border=\"1\" width=\"[*file_width*]\"></a><br/>',1,1293412920),(261,'file_eleft','<a href=\"<st_url>[*file_dirname*]\"><img style=\"float:left;margin:5px 15px 15px 0px;\" src=\"<st_url>[*file_dirname*]\" alt=\"[*file_dirname*], size: [*file_size*] bytes, type:  [*file_mime*] \" border=\"1\" width=\"[*file_width*]\" valign=\"top\" align=\"left\"></a>',1,1293412999),(262,'file_hencl','<br/>Enclosure: <a href=\"<st_url>[*file_dirname*]\">[*file_dirname*]</a>\r\nSize: [*file_size*] bytes, type:  [*file_mime*] ',1,1293413044),(263,'file_html','<p><img src=\"<st_url>[*file_dirname*]\" alt=\"[*file_type*]\" border=\"1\" width=\"200\"><br/>\r\n<a href=\"<st_url>[*file_dirname*]\">[*file_title*]</a><br>\r\nSize: [*file_size*] bytes<br/>\r\nType:  [*file_mime*] \r\n[*file_description*]</p>',1,1293413114),(264,'file_left','<a href=\"[*file_link*]\"><img style=\"float:left; margin:5px 15px 5px 15px;\" src=\"<st_url>[*file_dirname*]\" alt=\"[*file_dirname*], size: [*file_size*] bytes, type:  [*file_mime*] \" border=\"1\" width=\"[*file_width*]\"></a>',1,1293413189),(265,'file_post','<br/>File: <a href=\"<st_url>[*file_file*]\">[*file_title*]</a> ([*file_type*], [*file_size*] bytes)',1,1293413283),(266,'file_post_edit','[<a href=\"<st_url>cgi-bin/page.cgi?q=id=[*file_id*]&db=file&format=edit\">Edit</a>] <a href=\"<st_url>[*file_file*]\">[*file_title*]</a><br/>',1,1293413381),(267,'file_post_summary','<div class=\"post_credits\">\r\n<strong><a href=\"<st_url>[*file_file*]\">[*file_title*]</a></strong> ([*file_size*] bytes)</div>\r\n<div class=\"post_description\">\r\n<keyword db=post_file;format=post;file=[*file_id*]>\r\n</div> ',1,1293413484),(268,'file_right','<a href=\"[*file_link*]\"><img style=\"float:right; margin:5px 15px 5px 15px;\"  src=\"<st_url>[*file_dirname*]\" alt=\"[*file_dirname*], size: [*file_size*] bytes, type:  [*file_mime*] \" border=\"1\" width=\"[*file_width*]\"  valign=\"top\" align=\"right\"></a>',1,1293413544),(269,'file_rss02','<enclosure url=\"<st_url>[*file_dirname*]\" length=\"[*file_size*]\" type=\"[*file_mime*]\" />',1,1293413611),(270,'file_summary','<img src=\"http://<st_url>images/[*file_type*].gif\"/ align=\"top\" alt=\"[*file_type*]\"> <a href=\"<st_url>[*file_file*]\">[*file_title*]</a> ([*file_size*] bytes)<br/>\r\n[*file_description*]',1,1293413707),(271,'file_top','<br />\r\n<a href=\"[*file_link*]\"><img class=\"top\" src=\"<st_url>[*file_dirname*]\" alt=\"[*file_dirname*], size: [*file_size*] bytes, type:  [*file_mime*] \" border=\"1\" width=\"[*file_width*]\"></a><br/>',1,1293413774),(272,'journal_html','<h1>[*journal_title*]</h1>\r\n\r\n<div class=\"post_description\">\r\nLink: <a href=\"[*journal_link*]\">[*journal_link*]</a><br/><br/>\r\n\r\n[*journal_description*]  <admin journal,[*journal_id*]>\r\n\r\n<h2>Posts</h2>\r\n\r\n<keyword db=post;format=link_summary;journal=[*journal_id*];sort=crdate DESC>\r\n\r\n\r\n<h2>Links</h2>\r\n\r\n\r\n<p>(Still working on this)</p>\r\n\r\n<keyword db=link;journal=[*journal_id*];sort=crdate DESC>',1,1293414335),(273,'post_link_html','<!-- Begin Post -->\r\n<p><a href=\"<st_url>threads.htm\">All Discussion Threads</a>]<keyword db=file;type=Illustration;align=top;post=[*post_id*];format=top;number=1></p>\r\n\r\n<h2 style=\"margin-bottom: 0px;\"><a href=\"[*post_link*]\">[*post_title*]</a></h2>\r\n<p style=\"padding-top:0pt;\">\r\nCommentary by <keyword db=person;id=[*post_creator*];format=byline;number=1> on <keyword db=link;link=[*post_link*];format=byline;number=1>, <NICE_DATE>[*post_crdate*]<END_NICE_DATE>.\r\n \r\n<br/><div class=\"tweetmeme_button\" style=\"float: right; margin-right: 20px;margin-left: 10px;margin-bottom: 10px;\">\r\n<script type=\"text/javascript\">tweetmeme_url = &#39;<st_url>post/[*post_id*]&#39;; tweetmeme_source = &#39;oldaily&#39;;</script><script type=\"text/javascript\" src=\"http://tweetmeme.com/i/scripts/button.js\"></script></div><p><keyword db=file;type=Illustration;align=left;post=[*post_id*];format=left;number=1><keyword db=file;type=Illustration;align=right;post=[*post_id*];format=right;number=1>[*post_description*] (Hits Today: [*post_hits*] Total: [*post_total*])\r\n<keyword db=file;type=Enclosure;post=[*post_id*];format=hencl>\r\n<keyword db=file;type=Illustration;align=bottom;post=[*post_id*];format=bottom;number=1>\r\n</p>\r\n<p>[<a href=\"[*post_link*]\">Link</a>] <TOPIC>[*post_id*]<END_TOPIC> \r\n <next post,[*post_id*]><admin post,[*post_id*]></p> \r\n<hr size=\"1\">\r\n\r\n<p><strong>Comments</strong></p>\r\n<p><keyword db=post;type=comment;thread=[*post_id*];format=comment_summary;sort=crdate;number=500></p>\r\n<p><CFORM>[*post_id*],[*post_title*],[*post_comment_checked*]<END_CFORM></p>',1,1293414797),(274,'post_link_email','<!-- Begin Post -->\r\n\r\n<p style=\"margin-bottom:4px;\">\r\n<keyword db=file;type=Illustration;align=top;post=[*post_id*];format=top;number=1>\r\n<strong><a href=\"<st_url>post/[*post_id*]\">[*post_title*]</a></strong><br />\r\n<a href=\"<st_url>cgi-bin/admin.cgi?author=[*post_author*]\">[*post_author*]</a>, \r\n<a href=\"<st_url>cgi-bin/page.cgi?journal=[*post_journal*]\">[*post_journal*]</a>, <NICE_DATE>[*post_crdate*]<END_NICE_DATE>.</p>\r\n<hr size=\"1\" color=\"#cccccc\" style=\"margin:0px;padding:0px;\"/>\r\n<p  style=\"margin-top:3px;\">\r\n<keyword db=file;type=Illustration;align=left;post=[*post_id*];format=eleft;number=1>\r\n<keyword db=file;type=Illustration;align=right;post=[*post_id*];format=right;number=1>\r\n[*post_description*] \r\n<keyword db=file;type=Enclosure;post=[*post_id*];format=hencl>\r\n<keyword db=file;type=Illustration;align=bottom;post=[*post_id*];format=bottom;number=1>\r\n[<a href=\"<st_url>post/[*post_id*]\">Comment</a>]\r\n<hr size=\"1\">\r\n\r\n',1,1293414928),(275,'link_html','<p><b><a href=\"<st_url>link/[*link_id*]/rd\">[*link_title*]</a> </b><br />\r\n<i>[*link_authorname*], [*link_feedname*], <NICE_DATE>[*link_crdate*]<END_NICE_DATE></i><br/>\r\n[*link_description*] [*link_issued*]  [<a href=\"<st_cgi>page.cgi?db=post&action=edit&autoblog=[*link_id*]\">Comment</a>]</p>',1,1293471614),(276,'link_rss','<item>\r\n\r\n   <title>[*link_title*]</title>\r\n   <link><st_url>cgi-bin/edurss02.cgi?rd=[*link_id*]</link>\r\n   <description><![CDATA[[*link_description*] [From: <keyword db=feed;id=[*link_feedid*];format=brief>, <NICE_DATE>[*link_crdate*]<END_NICE_DATE>] [<a href=\"<st_cgi>page.cgi?db=post&action=edit&autoblog=[*link_id*]\">Comment</a>] \r\n   ]]></description>\r\n\r\n</item>\r\n',1,1293471779),(277,'person_html','<h1>[*person_name*]</h1>\r\n\r\n\r\n<h2>Posts</h2>\r\n\r\n<keyword db=post;creator=[*person_id*];format=link_email>',1,1293471864),(278,'link_email','<!-- Begin Post -->\r\n\r\n<p><b><a href=\"<st_url>link/[*link_id*]/rd\">[*link_title*]</a></b><br/>\r\n<i>[*link_authorname*], [*link_feedname*]</i><br/>[*link_description*] [<a href=\"[*link_link*]\">Link</a>]\r\n[*link_issued*]  \r\n<keyword db=feed;number=1;type=brief;id=[*link_feedid*]> [<a href=\"<st_cgi>page.cgi?db=post&action=edit&autoblog=[*link_id*]\">Comment</a>]</p>\r\n',1,1293471923),(279,'post_announcement_email','<!-- Begin Announcement -->\r\n\r\n<h2>[*post_title*]</h2>\r\n<p style=\"margin-bottom:4px;\">\r\n<keyword db=file;type=Illustration;align=top;post=[*post_id*];format=top;number=1>\r\n<keyword db=file;type=Illustration;align=left;post=[*post_id*];format=eleft;number=1>\r\n<keyword db=file;type=Illustration;align=right;post=[*post_id*];format=right;number=1>\r\n[*post_description*] \r\n<keyword db=file;type=Enclosure;post=[*post_id*];format=hencl>\r\n<keyword db=file;type=Illustration;align=bottom;post=[*post_id*];format=bottom;number=1>\r\n[<a href=\"<st_url>post/[*post_id*]\">Comment</a>]\r\n<hr size=\"1\">\r\n\r\n',1,1293472089),(280,'post_announcement_html','<!-- Begin Post -->\r\n\r\n<h2>[*post_title*]</h2>\r\n<p>[*post_description*]</p>',1,1293472132),(281,'post_announcement_rss','<item>\r\n   <title>Announcement: [*post_title*]</title>\r\n   <link><site_url>newsletter.htm</link>\r\n   <description>[*post_description*]</description>\r\n</item>',1,1293472188),(282,'post_article_email','<!-- Begin Post -->\r\n\r\n<p><b><a href=\"<st_url>post/[*post_id*]\">[*post_title*]</a></b><br/>\r\nArticle by [*post_author*]. \r\n[*post_description*] <NICE_DATE>[*post_crdate*]<END_NICE_DATE> [<a href=\"<st_url>post/[*post_id*]\">Link</a>] \r\n[<a href=\"<st_url>post/[*post_id*]\">Comment</a>]</p>',1,1293472334),(283,'post_article_html','<h2>[*post_title*]</h2><p>\r\n<p class=\"byline\">By [*post_author*]<br/><NICE_DATE>[*post_crdate*]<END_NICE_DATE></p>\r\n<keyword db=publication;post=[*post_id*];format=inpost;all>\r\n\r\n[*post_content*]\r\n<h3>Comments</h3>\r\n<keyword db=post;type=comment;thread=[*post_id*];format=comment_html;sort=crdate DESC>\r\n<CFORM>[*post_id*],[*post_title*]<END_CFORM>',1,1293472393),(284,'post_article_rss','      <item>\r\n          <title>[*post_title*]</title>\r\n	  <link><st_url>cgi-bin/page.cgi?post=[*post_id*]</link>\r\n          <description><![CDATA[[*post_description*] \r\n[*post_author*]</a>, [*post_journal*], <NICE_DATE>[*post_crdate*]<END_NICE_DATE> [<a href=\"[*post_link*]\">Link</a>] [<a href=\"<st_url>cgi-bin/page.cgi?post=[*post_id*]\">Comment</a>]]]></description>\r\n         <pubDate><822_DATE>[*post_crdate*]<END_822_DATE></pubDate>\r\n         <guid><st_url>cgi-bin/page.cgi?post=[*post_id*]</guid>\r\n      </item>',1,1293472450),(285,'post_comment_email','[*post_author*], <a href=\"<st_url>cgi-bin/page.cgi?post=[*post_thread*]#[*post_id*]\">[*post_title*]</a>, [*post_description*] <br/>',1,1293472537),(286,'post_comment_html','<!-- Begin Post -->\r\n<a name=\"[*post_id*]\" />\r\n<h4><a href=\"<st_url>cgi-bin/page.cgi?post=[*post_thread*]\">[*post_title*]</a></h4>\r\n<p class=\"byline\"><span class=\"bylinespan\">\r\n[*post_author*], \r\n<NICE_DATE>[*post_crdate*]<END_NICE_DATE>\r\n</span></p>\r\n\r\n<p class=\"comment\">[*post_description*]</a> [<a href=\"<st_url>cgi-bin/page.cgi?post=[*post_thread*]\">Comment</a>]\r\n[<a href=\"<st_url>cgi-bin/page.cgi?post=[*post_id*]\">Permalink</a>]\r\n <next post,[*post_id*]> <admin post,[*post_id*]>\r\n</p>\r\n<!-- End Post -->',1,1293472603),(287,'post_comment_rss','      <item>\r\n          <title>[*post_title*]</title>\r\n	  <link><st_url>cgi-bin/page.cgi?post=[*post_thread*]&format=full</link>\r\n          <description>[*post_description*] <a href=\"<st_url>cgi-bin/page.cgi?person=[*person_id*]\" class=\"stealth\">[*person_name*]</a>, <NICE_DATE>[*post_crdate*]<END_NICE_DATE> [<a href=\"<st_url>cgi-bin/page.cgi?post=[*post_id*]&format=full\">Comment</a>]\r\n          </description>\r\n      </item>\r\n',1,1293472660),(288,'post_announcement_summary','<!-- Begin Announcement -->\r\n\r\n<p><b>[*post_title*]</b><br/>\r\n\r\n[*post_description*]</p>',1,1293477492),(289,'post_article_summary','<a href=\"<st_url>post/[*post_id*]\">[*post_title*]</a>\r\nArticle by [*post_author*] <NICE_DATE>[*post_crdate*]<END_NICE_DATE><br/>\r\n[*post_description*]<br/><br/>',1,1293477693),(290,'post_link_rss','      <item>\r\n          <title>[*post_title*]</title>\r\n	  <link>http://connect.downes.ca/cgi-bin/page.cgi?post=[*post_id*]</link>\r\n          <description><![CDATA[[*post_description*] \r\n[*post_author*]</a>, [*post_journal*], <NICE_DATE>[*post_crdate*]<END_NICE_DATE> <TOPIC>[*post_id*]<END_TOPIC> [<a href=\"[*post_link*]\">Link</a>] [<a href=\"http://connect.downes.ca/cgi-bin/page.cgi?post=[*post_id*]\">Comment</a>]]]></description>\r\n         <pubDate><822_DATE>[*post_crdate*]<END_822_DATE></pubDate>\r\n         <guid>http://connect.downes.ca/cgi-bin/page.cgi?post=[*post_id*]</guid>\r\n          <XMLTOPIC>[*post_id*]<END_XMLTOPIC>\r\n      </item>\r\n',1,1293478790),(291,'post_link_txt','[*post_title*]\r\n[*post_author*], [*post_journal*]\r\n-------------------------------------------------------------\r\n<st_url>post/[*post_id*]\r\n[*post_description*]\r\nComment: <st_url>/post/[*post_id*]\r\nDirect Link: [*post_link*]',1,1293478987),(292,'post_link_list','<admin post,[*post_id*]> <a href=\"<st_url>post/[*post_id*]\">[*post_title*]</a><br/>',1,1293479195),(293,'post_article_list','<admin post,[*post_id*]> <a href=\"<st_url>post/[*post_id*]\">[*post_title*]</a><br/>',1,1293479485),(294,'post_announcement_list','<admin post,[*post_id*]> <a href=\"<st_url>post/[*post_id*]\">[*post_title*]</a><br/>',1,1293479500),(295,'post_comment_list','<admin post,[*post_id*]> <a href=\"<st_url>post/[*post_id*]\">[*post_title*]</a><br/>',1,1293479518),(296,'post_announcement_text','\r\n[*post_title*]\r\n-----------------------------------------------------------------------------------\r\n[*post_description*]',1,1293479580),(297,'post_article_txt','[*post_title*]\r\n<st_url>post/[*post_id*]\r\n\r\n<NICE_DATE>[*post_crdate*]<END_NICE_DATE>\r\n[*post_description*]\r\n\r\nComment:<st_url>post/[*post_id*]',1,1293479668),(298,'post_comment_summary','<!-- Begin Post -->\r\n<a name=\"[*post_id*]\" />\r\n<h4><a href=\"<st_url>cgi-bin/page.cgi?post=[*post_thread*]\">[*post_title*]</a></h4>\r\n<p class=\"byline\"><span class=\"bylinespan\">\r\n[*post_author*], \r\n<NICE_DATE>[*post_crdate*]<END_NICE_DATE>\r\n</span><br />[*post_description*]</a> \r\n<admin post,[*post_id*]>\r\n</p>\r\n<!-- End Post -->',1,1293479771),(299,'post_comment_txt','\r\n[*post_title*]\r\n-----------------------------------------------------------------------------------\r\n[*post_description*]\r\n',1,1293479819),(300,'presentation_html','<!-- Begin Presentation -->\r\n<p>[<a href=\"<st_url>presentations.htm\">All Presentations</a>]</p>\r\n<h3>[*presentation_title*]</h3>\r\n<p><a href=\"[*presentation_link*]\">[*presentation_author*]</a>, <NICE_DATE>[*presentation_crdate*]<END_NICE_DATE><br/>\r\n[*presentation_catdetails*] presentation delivered to [*presentation_conference*], [*presentation_location*]. </p>\r\n\r\n<p>[*presentation_description*] \r\n[<a href=\"[*presentation_slides*]\">Slides</a>]\r\n[<a href=\"[*presentation_audio*]\">Audio</a>]\r\n[<a href=\"[*presentation_video*]\">Video</a>] </p>\r\n\r\n<p><ul>[*presentation_video_player*]<br/>\r\n[*presentation_slide_player*]<br/>\r\n\r\n<embed type=\"application/x-shockwave-flash\" flashvars=\"audioUrl=[*presentation_audio*]\" src=\"http://www.google.com/reader/ui/3523697345-audio-player.swf\" width=\"400\" height=\"27\" quality=\"best\"></embed>\r\n\r\n</ul></p>',1,1293480511),(301,'presentation_email','<!-- Begin Post -->\r\n\r\n<p><a href=\"http://www.downes.ca/cgi-bin/page.cgi?presentation=[*presentation_id*]\">[*presentation_title*]</a><br/>\r\n[*presentation_description*] Presentation by [*presentation_author*], [*presentation_conference*], [*presentation_location*], <NICE_DATE>[*post_crdate*]<END_NICE_DATE> [<a style=\"color: #0fad0f; text-decoration: none;\" href=\"[*presentation_link*]\">Link</a>] </p>',1,1293480574),(302,'presentation_rss','     <item>\r\n          <title>[*presentation_title*]</title>\r\n	  <link><st_url>presentation[*presentation_id*]</link>\r\n          <description><![CDATA[ [<a href=\"[*presentation_slides*]\">Slides</a>][<a href=\"[*presentation_audio*]\">Audio</a>] [*presentation_description*] \r\n[*presentation_conference*], [*presentation_location*] ([*presentation_catdetails*]) <NICE_DATE>[*presentation_crdate*]<END_NICE_DATE> [<a href=\"<st_url>presentation[*presentation_id*]\">Comment</a>] ]]></description>\r\n         <pubDate><822_DATE>[*presentation_crdate*]<END_822_DATE></pubDate>\r\n         <enclosure url=\"[*presentation_audio*]\" length=\"123456789\" type=\"audio/mpeg\" />\r\n         <guid><st_url>presentation[*presentation_id*]</guid>\r\n      </item>',1,1293480675),(303,'presentation_text','[*presentation_title*]\r\n<st_url>presentation/[*presentation_id*]\r\n----------------------------------------------------------------------\r\n[*presentation_description*] Presentation by Stephen Downes, [*presentation_conference*], [*presentation_location*], <NICE_DATE>[*post_crdate*]<END_NICE_DATE> \r\n[*presentation_link*]',1,1293480793),(304,'project_html','<h2>Task: [*project_title*]</h2>\r\n\r\n[*project_description*]\r\n',1,1293489674),(305,'publication_summary','<p>\r\n<a href=\"[*publication_link*]\">[*publication_title*]</a><br/>\r\n<NICE_DATE>[*publication_crdate*]<END_NICE_DATE>. \r\n<em>[*publication_journal_name*]</em> [*publication_volume*] [*publication_pages*] [*publication_publisher*] [<a href=\"[*publication_link*]\">Link</a>][*publication_description*]\r\n</p>',1,1293489745),(306,'publication_html','<p>\r\n<a href=\"[*publication_link*]\">[*publication_title*]</a><br/>\r\n<NICE_DATE>[*publication_crdate*]<END_NICE_DATE>. \r\n<em>[*publication_journal_name*]</em> [*publication_volume*] [*publication_pages*] [*publication_publisher_name*] [<a href=\"[*publication_link*]\">Link</a>] [<a href=\"<st_url>post/[*publication_post*]\">Post</a>]\r\n</p>',1,1293489801),(307,'task_html','<h2>Task: [*task_title*]</h2>\r\nCreated: <NICE_DATE>[*task_crdate*]<END_NICE_DATE>\r\nDue: <NICE_DATE>[*task_due*]<END_NICE_DATE><br/>\r\nPriority: [*task_priority*]  Status: [*task_status*]\r\n<br/><br/>\r\n[*task_description*]\r\n',1,1293489932),(308,'task_list','<admin task,[*task_id*]> <a href=\"page.cgi?task=[*task_id*]\">[*task_title*]</a><br/>',1,1293490072),(309,'topic_html','<h2>Topic: [*topic_title*]</h2>\r\n<WIKIPEDIA [*topic_title*]>\r\n<p>[*topic_description*]</p>\r\n<p>Category: [*topic_type*]<br/>\r\nDefinition: [*topic_where*]<br/>\r\n<EDIT><DELETE><br/>\r\n\r\n\r\n\r\n<a href=\"<st_url>cgi-bin/page.cgi?page=65&pagedata=topic,[*topic_id*],[*topic_title*]\"><img src=\"<st_url>images/jsm.gif\" border=\"0\"> Javascript Feed for this topic</a><br/>\r\n\r\n<a href=\"<st_url>cgi-bin/page.cgi?topic=[*topic_id*]&format=rss\"><img src=\"<st_url>images/xml.gif\" border=\"0\"> RSS Feed for this topic</a>\r\n\r\n\r\n<h4>Recent Posts in this Topic</h4>\r\n<keyword db=post;lookup=topic in topic_list as item;topic=[*topic_id*];sort=crdate DESC;type=link;number=10;format=link_email>\r\n\r\n<h4>Recent Links in this Topic</h4>\r\n(pending - I&#39;m going to build cache versions of these pages first)',1,1293490208),(310,'feed_course','<hr/><p><b><a href=\"<st_url>feed/[*feed_id*]\">[*feed_title*]</a></b> <br/>By [*feed_authorname*].  [*feed_description*] [*feed_type*]. [<a href=\"[*feed_html*]\">HTML</a>][<a href=\"[*feed_link*]\">XML</a>]  last Updated: [*feed_lastBuildDate*]<br/>\r\n\r\n</p>\r\n',52529,1295291480),(311,'post_link_threadlist','<!-- Begin Post -->\r\n<h2 style=\"margin-top:20pt;margin-bottom:0pt\"><a href=\"<st_url>post/[*post_id*]\">[*post_title*]</a></h2>\r\n<p style=\"margin-top:2pt\">\r\n<em><a href=\"<st_cgi>page.cgi?author=[*post_author*]\">[*post_author*]</a>, \r\n<a href=\"<st_cgi>page.cgi?journal=[*post_journal*]\">[*post_journal*]</a>, <NICE_DATE>[*post_crdate*]<END_NICE_DATE>.</em><br />\r\n[*post_description*] \r\n</p>\r\n',52529,1295294783),(312,'person_byline','<a href=\"<st_url>person/[*person_id*]\">[*person_title*]</a> ([*person_name*])\r\n',1,1295307975),(313,'link_viewer','<!-- Begin Item -->\r\n<h2>[*link_title*]</h2>\r\n<p>\r\nSource: <keyword db=feed;id=[*link_feedid*];format=viewer;number=1>\r\n<br />\r\nDate: <NICE_DATE>[*link_crdate*]<END_NICE_DATE>\r\n<br /><br />\r\n\r\n[*link_description*] \r\n\r\n\r\nDirect Link:  <a href=\"[*link_link*]\" target=\"_new\">[*link_link*]</a><br/>\r\n\r\n</p>\r\n',52529,1295361314),(314,'feed_viewer','<a href=\"<st_url>feed/[*feed_id*]\">[*feed_title*]</a>, by [*feed_authorname*].\r\n[*feed_managingEditor*] \r\n[*feed_webMaster*]\r\n[*feed_publisher*] \r\n[*feed_description*]',52529,1295361350),(315,'link_byline','link by [*link_authorname*],  <a href=\"<st_url>link/[*link_id*]/rd\">[*link_title*]</a>',1,1295526586),(316,'post_comment_notify','<p><b><a href=\"<st_url>cgi-bin/page.cgi?post=[*post_thread*]\">[*post_title*]</a></b><br/>\r\n[*post_author*],  <NICE_DATE>[*post_crdate*]<END_NICE_DATE></p>\r\n\r\n\r\n<p>[*post_description*]</a> [<a href=\"<st_url>cgi-bin/page.cgi?post=[*post_thread*]#comment\">Reply</a>]</p>\r\n\r\n',52529,1295547193),(317,'link_twitter','<a href=\"[*link_link*]\">@[*link_authorname*]</a> tweeted: [*link_description*] [*link_issued*]<br/><br/>',52529,1295610516),(318,'feed_opml','<outline title=\"[*feed_title*]\" text=\"[*feed_title*]\" htmlUrl=\"[*feed_html*]\" type=\"[*feed_type*]\" xmlUrl=\"[*feed_link*]\"/>',52529,1295611846),(319,'post_rss','     <item>\r\n          <title>[*post_title*]</title>\r\n	  <link><st_url>post/[*post_id*]</link>\r\n          <description><![CDATA[[*post_description*] \r\n[*post_author*]</a>, [*post_journal*], <NICE_DATE>[*post_crdate*]<END_NICE_DATE> <TOPIC>[*post_id*]<END_TOPIC> [<a href=\"[*post_link*]\">Link</a>] [<a href=\"<st_url>/cgi-bin/page.cgi?post=[*post_id*]$comment\">Comment</a>]]]></description>\r\n         <pubDate><822_DATE>[*post_crdate*]<END_822_DATE></pubDate>\r\n         <guid><st_url>/cgi-bin/page.cgi?post=[*post_id*]</guid>\r\n          <XMLTOPIC>[*post_id*]<END_XMLTOPIC>\r\n      </item>',52529,1295612936),(320,'feed_brief','<a href=\"<st_cgi>page.cgi?feed=[*feed_id*]\">[*feed_title*]</a>',52529,1295613317),(321,'publication_email','<p>\r\n<b><a href=\"[*publication_link*]\">[*publication_title*]</a></b><br/>\r\n<NICE_DATE>[*publication_crdate*]<END_NICE_DATE>. \r\n<em>[*publication_author_name*] [*publication_journal_name*]</em> [*publication_volume*] [*publication_pages*] [*publication_publisher_name*] [*publication_description*] [<a href=\"[*publication_link*]\">Link</a>] \r\n</p>',10081,1316446599),(322,'media_list','<admin media,[*media_id*]>  ([*media_type*]) <a href=\"<st_cgi>page.cgi?media=[*media_id*]\">[*media_title*]</a> ([*media_hits*] hits)<br>',10081,1316450319),(323,'media_html','<h2>[*media_title*]</h2>\r\n<p><img src=\"[*media_url*]\" height=\"[*media_height*]\" width=\"[*media_width*]\">\r\n<img src=\"[*media_thurl*]\" height=\"[*media_thheight*]\" width=\"[*media_thwidth*]\">\r\n<br />\r\nURL: <a href=\"[*media_url*]\">[*media_url*]</a> <br /><br />\r\n\r\nType: [*media_type*]<br/>\r\nMime: Type: [*media_mimetype*]<br/>\r\n\r\nDimensions: Size: [*media_size*]; \r\nHeight: [*media_height*];\r\nWidth: [*media_width*]<br />\r\nDuration: [*media_duration*]<br />\r\n\r\nExplicit:  [*media_explicit*]<br />\r\n\r\nSubtitle: [*media_subtitle*]<br />\r\nDescription: [*media_description*] [*media_block*] <br />\r\n\r\nFrom feed <a href=\"<st_url>feed/[*media_feed*]\">[*media_feed*]</a><br />\r\nFrom post <a href=\"<st_url>post/[*media_post*]\">[*media_post*]</a><br />\r\nIdentifier: [*media_identifier*]</a> <br />\r\nKeywords: [*media_keywords*]</a>; \r\nLangauge: [*media_language*]</a> <br />\r\n<NICE_DATE>[*media_crdate*]<END_NICE_DATE> \r\n<admin media,[*media_id*]>  </p>',10081,1316450348),(324,'event_email','<p><b>[*event_title*]</b><br />\r\n<b><a href=\"http://change.mooc.ca/meetings.htm\">Click Here to Attend Event</a></b><br />\r\nSpeakers: [*event_star*]<br/>\r\nStart:  [*event_start*] EDT (<a href=\"http://www.timeanddate.com/worldclock/fixedtime.html?iso=20111125T12&p1=250\">Check Time Zones</a>)<br/>\r\nFinish: [*event_finish*] EDT<br/>\r\n[*event_description*]</p>\r\n',10081,1316544762),(325,'presentation_summary','<p><b><a href=\"<st_url>/presentation/[*presentation_id*]\">[*presentation_title*]</a></b><br/>\r\n[*presentation_author*], <NICE_DATE>[*presentation_crdate*]<END_NICE_DATE>. [*presentation_conference*], [*presentation_location*] ([*presentation_catdetails*]).</p>',10081,1316628783),(326,'media_brief','<count> <a href=\"[*media_url*]\">[*media_title*]</a>, <NICE_DATE>[*media_crdate*]<END_NICE_DATE> <br/>',10081,1320337915),(327,'media_pls','File=[*media_url*]\r\nTitle=[*media_title*]\r\nLength=[*media_size*]\r\n\r\n',10081,1320348976),(328,'graph_list','[*graph_id*] <a href=\"[*graph_urlone*]\">[*graph_tableone*] [*graph_idone*]</a> --> <a href=\"[*graph_urltwo*]\">[*graph_tabletwo*] [*graph_idtwo*]</a> ([*graph_type*] : [*graph_typeval*]) <br/>',10081,1327429697),(329,'link_twlist','<li><a href=\"[*link_link*]\">@[*link_authorname*]</a> tweeted: [*link_description*] [*link_issued*]</li>',10081,1335263685);
/*!40000 ALTER TABLE `view` ENABLE KEYS */;
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