<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html><head>
<title>~/linkbot/linkbot.pl.html</title>
<meta name="Generator" content="Vim/7.2">
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
</head>
<body bgcolor="#ffffff" text="#000000"><font face="monospace">
<font color="#a52a2a">&nbsp;&nbsp;1 </font><font color="#a020f0">#!/usr/bin/perl</font><br>
<font color="#a52a2a">&nbsp;&nbsp;2 </font><br>
<font color="#a52a2a">&nbsp;&nbsp;3 </font><font color="#008b8b">$|</font>&nbsp;= <font color="#ff00ff">1</font>;<br>
<font color="#a52a2a">&nbsp;&nbsp;4 </font><br>
<font color="#a52a2a">&nbsp;&nbsp;5 </font><font color="#a52a2a"><b>use strict</b></font>;<br>
<font color="#a52a2a">&nbsp;&nbsp;6 </font><font color="#a52a2a"><b>use warnings</b></font>;<br>
<font color="#a52a2a">&nbsp;&nbsp;7 </font><br>
<font color="#a52a2a">&nbsp;&nbsp;8 </font><font color="#a52a2a"><b>use vars</b></font><br>
<font color="#a52a2a">&nbsp;&nbsp;9 </font>&nbsp;&nbsp;<font color="#ff00ff">qw(</font><br>
<font color="#a52a2a">&nbsp;10 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Host</font><br>
<font color="#a52a2a">&nbsp;11 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@URLs</font><br>
<font color="#a52a2a">&nbsp;12 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Output_Filename</font><br>
<font color="#a52a2a">&nbsp;13 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Delay</font><br>
<font color="#a52a2a">&nbsp;14 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Debugging</font><br>
<font color="#a52a2a">&nbsp;15 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$External_Links</font><br>
<font color="#a52a2a">&nbsp;16 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Errors_Only</font><br>
<font color="#a52a2a">&nbsp;17 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Suppress_Header</font><br>
<font color="#a52a2a">&nbsp;18 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Ignore_Robots_Txt</font><br>
<font color="#a52a2a">&nbsp;19 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Log_Filename</font><br>
<font color="#a52a2a">&nbsp;20 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Links_Only</font><br>
<font color="#a52a2a">&nbsp;21 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Proxy_URL</font><br>
<font color="#a52a2a">&nbsp;22 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Silent</font><br>
<font color="#a52a2a">&nbsp;23 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Email_Addresses</font><br>
<font color="#a52a2a">&nbsp;24 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Exclude_Regex</font><br>
<font color="#a52a2a">&nbsp;25 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Include_Regex</font><br>
<font color="#a52a2a">&nbsp;26 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Processed_GDBM_Filename</font><br>
<font color="#a52a2a">&nbsp;27 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$From_Email_Address</font><br>
<font color="#a52a2a">&nbsp;28 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$SMTP_Server</font><br>
<font color="#a52a2a">&nbsp;29 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$DSN</font><br>
<font color="#a52a2a">&nbsp;30 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Database_Name</font><br>
<font color="#a52a2a">&nbsp;31 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Database_User</font><br>
<font color="#a52a2a">&nbsp;32 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Database_Password</font><br>
<font color="#a52a2a">&nbsp;33 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Create_Error_Table</font><br>
<font color="#a52a2a">&nbsp;34 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Create_Linked_Table</font><br>
<font color="#a52a2a">&nbsp;35 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Error_Insert</font><br>
<font color="#a52a2a">&nbsp;36 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Linked_Insert</font><br>
<font color="#a52a2a">&nbsp;37 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Error_Select</font><br>
<font color="#a52a2a">&nbsp;38 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$Linked_Select</font><br>
<font color="#a52a2a">&nbsp;39 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;</font><font color="#ff00ff">)</font>;<br>
<font color="#a52a2a">&nbsp;40 </font><br>
<font color="#a52a2a">&nbsp;41 </font><font color="#a52a2a"><b>use </b></font>Getopt::Declare;<br>
<font color="#a52a2a">&nbsp;42 </font><font color="#a52a2a"><b>use </b></font>WWW::Mechanize;<br>
<font color="#a52a2a">&nbsp;43 </font><font color="#a52a2a"><b>use </b></font>WWW::RobotRules;<br>
<font color="#a52a2a">&nbsp;44 </font><font color="#a52a2a"><b>use </b></font>HTML::TokeParser;<br>
<font color="#a52a2a">&nbsp;45 </font><font color="#a52a2a"><b>use </b></font>GDBM_File;<br>
<font color="#a52a2a">&nbsp;46 </font><font color="#a52a2a"><b>use </b></font>DateTime;<br>
<font color="#a52a2a">&nbsp;47 </font><font color="#a52a2a"><b>use </b></font>DBI;<br>
<font color="#a52a2a">&nbsp;48 </font><font color="#a52a2a"><b>use </b></font>MIME::Lite;<br>
<font color="#a52a2a">&nbsp;49 </font><br>
<font color="#a52a2a">&nbsp;50 </font><font color="#a52a2a"><b>require</b></font>&nbsp;<font color="#ff00ff">'</font><font color="#ff00ff">linkbot.cfg</font><font color="#ff00ff">'</font>;<br>
<font color="#a52a2a">&nbsp;51 </font><br>
<font color="#a52a2a">&nbsp;52 </font><font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$specification_string</font>&nbsp;= <font color="#ff00ff">&lt;&lt;'EOD'</font><font color="#ff00ff">;</font><br>
<font color="#a52a2a">&nbsp;53 </font><font color="#ff00ff">&nbsp;&nbsp;(-E and -L are mutually exclusive) [mutex: -E -L]</font><br>
<font color="#a52a2a">&nbsp;54 </font><font color="#ff00ff">&nbsp;&nbsp;(-x and -X are mutually exclusive) [mutex: -x -X]</font><br>
<font color="#a52a2a">&nbsp;55 </font><font color="#ff00ff">&nbsp;&nbsp;-h &lt;host&gt; Defines the host name that the spider will be restricted to. [required]</font><br>
<font color="#a52a2a">&nbsp;56 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $Host = URI-&gt;new($host) }</font><br>
<font color="#a52a2a">&nbsp;57 </font><font color="#ff00ff">&nbsp;&nbsp;&lt;urls&gt;... Spidering start point URLs. [required]</font><br>
<font color="#a52a2a">&nbsp;58 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ @URLs = @urls }</font><br>
<font color="#a52a2a">&nbsp;59 </font><font color="#ff00ff">&nbsp;&nbsp;-d &lt;delay&gt;&nbsp;&nbsp;Set delay (in seconds) between requests.</font><br>
<font color="#a52a2a">&nbsp;60 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $Delay = $delay }</font><br>
<font color="#a52a2a">&nbsp;61 </font><font color="#ff00ff">&nbsp;&nbsp;-D&nbsp;&nbsp;Turn on debugging (doesn't delete data files).</font><br>
<font color="#a52a2a">&nbsp;62 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $Debugging = 1 }</font><br>
<font color="#a52a2a">&nbsp;63 </font><font color="#ff00ff">&nbsp;&nbsp;-e&nbsp;&nbsp;&nbsp;&nbsp;Check external links.&nbsp;&nbsp;Use with caution.</font><br>
<font color="#a52a2a">&nbsp;64 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $External_Links = 1 }</font><br>
<font color="#a52a2a">&nbsp;65 </font><font color="#ff00ff">&nbsp;&nbsp;-E&nbsp;&nbsp;&nbsp;&nbsp;Errors only on report.</font><br>
<font color="#a52a2a">&nbsp;66 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $Errors_Only = 1 }</font><br>
<font color="#a52a2a">&nbsp;67 </font><font color="#ff00ff">&nbsp;&nbsp;-f &lt;filename&gt; Output filename. Default output is to STDOUT.</font><br>
<font color="#a52a2a">&nbsp;68 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $Output_Filename = $filename }</font><br>
<font color="#a52a2a">&nbsp;69 </font><font color="#ff00ff">&nbsp;&nbsp;-F &lt;from_email_address&gt; Set the from email address.&nbsp;&nbsp;Overrides config setting.</font><br>
<font color="#a52a2a">&nbsp;70 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $From_Email_Address = $from_email_address }</font><br>
<font color="#a52a2a">&nbsp;71 </font><font color="#ff00ff">&nbsp;&nbsp;-H&nbsp;&nbsp;&nbsp;&nbsp;Suppress header in report.</font><br>
<font color="#a52a2a">&nbsp;72 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $Suppress_Header = 1 }</font><br>
<font color="#a52a2a">&nbsp;73 </font><font color="#ff00ff">&nbsp;&nbsp;-i&nbsp;&nbsp;&nbsp;&nbsp;Ignore robots.txt. Use with caution.</font><br>
<font color="#a52a2a">&nbsp;74 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $Ignore_Robots_Txt = 1 }</font><br>
<font color="#a52a2a">&nbsp;75 </font><font color="#ff00ff">&nbsp;&nbsp;-l &lt;filename&gt; Log status messages.</font><br>
<font color="#a52a2a">&nbsp;76 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $Log_Filename = $filename }</font><br>
<font color="#a52a2a">&nbsp;77 </font><font color="#ff00ff">&nbsp;&nbsp;-L&nbsp;&nbsp;&nbsp;&nbsp;Links only on report.</font><br>
<font color="#a52a2a">&nbsp;78 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $Links_Only = 1 }</font><br>
<font color="#a52a2a">&nbsp;79 </font><font color="#ff00ff">&nbsp;&nbsp;-p &lt;proxy_url&gt;&nbsp;&nbsp;HTTP/HTTPS proxy address. i.e. <a href="http://localhost:8001/">http://localhost:8001/</a></font><br>
<font color="#a52a2a">&nbsp;80 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $Proxy_URL = $proxy_url }</font><br>
<font color="#a52a2a">&nbsp;81 </font><font color="#ff00ff">&nbsp;&nbsp;-T &lt;time_zone&gt;&nbsp;&nbsp;Specify time zone under win32.&nbsp;&nbsp;i.e. America/Phoenix</font><br>
<font color="#a52a2a">&nbsp;82 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $ENV{TZ} = $time_zone }</font><br>
<font color="#a52a2a">&nbsp;83 </font><font color="#ff00ff">&nbsp;&nbsp;-s&nbsp;&nbsp;&nbsp;&nbsp;Silent mode. Suppresses status messages.</font><br>
<font color="#a52a2a">&nbsp;84 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $Silent = 1 }</font><br>
<font color="#a52a2a">&nbsp;85 </font><font color="#ff00ff">&nbsp;&nbsp;-S &lt;email_addresses&gt;&nbsp;&nbsp;Send report to comma delimited list of email addresses.</font><br>
<font color="#a52a2a">&nbsp;86 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $Email_Addresses = $email_addresses }</font><br>
<font color="#a52a2a">&nbsp;87 </font><font color="#ff00ff">&nbsp;&nbsp;-x &lt;regex&gt;&nbsp;&nbsp;&nbsp;&nbsp;Exclude URLs matching regex.</font><br>
<font color="#a52a2a">&nbsp;88 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $Exclude_Regex = $regex }</font><br>
<font color="#a52a2a">&nbsp;89 </font><font color="#ff00ff">&nbsp;&nbsp;-X &lt;regex&gt;&nbsp;&nbsp;&nbsp;&nbsp;Include URLs matching regex.</font><br>
<font color="#a52a2a">&nbsp;90 </font><font color="#ff00ff">&nbsp;&nbsp;&nbsp;&nbsp;{ $Include_Regex = $regex }</font><br>
<font color="#a52a2a">&nbsp;91 </font><font color="#ff00ff">EOD</font><br>
<font color="#a52a2a">&nbsp;92 </font><br>
<font color="#a52a2a">&nbsp;93 </font><font color="#0000ff"># If a config file is specified, parse it instead of @ARGV.</font><br>
<font color="#a52a2a">&nbsp;94 </font><font color="#a52a2a"><b>if</b></font>(<font color="#a52a2a"><b>-e</b></font>&nbsp;<font color="#008b8b">$ARGV</font>[<font color="#ff00ff">0</font>])<br>
<font color="#a52a2a">&nbsp;95 </font>{<br>
<font color="#a52a2a">&nbsp;96 </font><br>
<font color="#a52a2a">&nbsp;97 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>open</b></font>(<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$config_file</font>, <font color="#ff00ff">'</font><font color="#ff00ff">&lt;</font><font color="#ff00ff">'</font>, <font color="#008b8b">$ARGV</font>[<font color="#ff00ff">0</font>]) || <font color="#a52a2a"><b>die</b></font>&nbsp;<font color="#ff00ff">"</font><font color="#ff00ff">Can't open </font><font color="#008b8b">$ARGV</font><font color="#ff00ff">[0]: </font><font color="#008b8b">$!</font><font color="#ff00ff">"</font>;<br>
<font color="#a52a2a">&nbsp;98 </font><br>
<font color="#a52a2a">&nbsp;99 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$arguments</font>&nbsp;= Getopt::Declare-&gt;<font color="#a52a2a"><b>new</b></font>(<font color="#008b8b">$specification_string</font>, <font color="#008b8b">$config_file</font>);<br>
<font color="#a52a2a">100 </font><br>
<font color="#a52a2a">101 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>close</b></font>(<font color="#008b8b">$config_file</font>);<br>
<font color="#a52a2a">102 </font>}<br>
<font color="#a52a2a">103 </font><font color="#a52a2a"><b>else</b></font><br>
<font color="#a52a2a">104 </font>{<br>
<font color="#a52a2a">105 </font><br>
<font color="#a52a2a">106 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$arguments</font>&nbsp;= Getopt::Declare-&gt;<font color="#a52a2a"><b>new</b></font>(<font color="#008b8b">$specification_string</font>);<br>
<font color="#a52a2a">107 </font><br>
<font color="#a52a2a">108 </font>}<br>
<font color="#a52a2a">109 </font><br>
<font color="#a52a2a">110 </font>(<font color="#a52a2a"><b>open</b></font>(<font color="#008b8b">STDOUT</font>, <font color="#ff00ff">'</font><font color="#ff00ff">&gt;</font><font color="#ff00ff">'</font>, <font color="#008b8b">$Output_Filename</font>) || <font color="#a52a2a"><b>die</b></font>&nbsp;<font color="#ff00ff">"</font><font color="#ff00ff">Can't open </font><font color="#008b8b">$Output_Filename</font><font color="#ff00ff">: </font><font color="#008b8b">$!</font><font color="#ff00ff">"</font>)<br>
<font color="#a52a2a">111 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>if</b></font>&nbsp;<font color="#008b8b">$Output_Filename</font>;<br>
<font color="#a52a2a">112 </font><br>
<font color="#a52a2a">113 </font><font color="#0000ff"># Append to log file if $Processed_GDBM_Filename exists. Incomplete spidering.</font><br>
<font color="#a52a2a">114 </font><font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$write_mode</font>&nbsp;= <font color="#a52a2a"><b>-e</b></font>&nbsp;<font color="#008b8b">$Processed_GDBM_Filename</font>&nbsp;? <font color="#ff00ff">'</font><font color="#ff00ff">&gt;&gt;</font><font color="#ff00ff">'</font>&nbsp;: <font color="#ff00ff">'</font><font color="#ff00ff">&gt;</font><font color="#ff00ff">'</font>;<br>
<font color="#a52a2a">115 </font><br>
<font color="#a52a2a">116 </font>(<font color="#a52a2a"><b>open</b></font>(<font color="#008b8b">STDERR</font>, <font color="#008b8b">$write_mode</font>, <font color="#008b8b">$Log_Filename</font>) || <font color="#a52a2a"><b>die</b></font>&nbsp;<font color="#ff00ff">"</font><font color="#ff00ff">Can't open </font><font color="#008b8b">$Log_Filename</font><font color="#ff00ff">: </font><font color="#008b8b">$!</font><font color="#ff00ff">"</font>)<br>
<font color="#a52a2a">117 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>if</b></font>&nbsp;<font color="#008b8b">$Log_Filename</font>;<br>
<font color="#a52a2a">118 </font><br>
<font color="#a52a2a">119 </font><font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$start_time</font>&nbsp;= DateTime-&gt;now(<font color="#ff00ff">time_zone </font>=&gt; <font color="#ff00ff">'</font><font color="#ff00ff">local</font><font color="#ff00ff">'</font>);<br>
<font color="#a52a2a">120 </font><font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#008b8b">STDERR</font>&nbsp;<font color="#ff00ff">"</font><font color="#ff00ff">Start time: </font><font color="#008b8b">$start_time</font><font color="#6a5acd">\n\n</font><font color="#ff00ff">"</font>&nbsp;<font color="#a52a2a"><b>unless</b></font>&nbsp;<font color="#008b8b">$Silent</font>;<br>
<font color="#a52a2a">121 </font><br>
<font color="#a52a2a">122 </font><font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$user_agent_name</font>&nbsp;= <font color="#ff00ff">'</font><font color="#ff00ff">LinkBot/1.0</font><font color="#ff00ff">'</font>;<br>
<font color="#a52a2a">123 </font><br>
<font color="#a52a2a">124 </font><font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$mech</font>&nbsp;=<br>
<font color="#a52a2a">125 </font>&nbsp;&nbsp;WWW::Mechanize-&gt;<br>
<font color="#a52a2a">126 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>new</b></font><br>
<font color="#a52a2a">127 </font>&nbsp;&nbsp;&nbsp;&nbsp;(<br>
<font color="#a52a2a">128 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#ff00ff">agent&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </font>=&gt; <font color="#008b8b">$user_agent_name</font>,<br>
<font color="#a52a2a">129 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#ff00ff">autocheck&nbsp;&nbsp; </font>=&gt; <font color="#ff00ff">0</font>,<br>
<font color="#a52a2a">130 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#ff00ff">stack_depth </font>=&gt; <font color="#ff00ff">0</font>,<br>
<font color="#a52a2a">131 </font>&nbsp;&nbsp;&nbsp;&nbsp;);<br>
<font color="#a52a2a">132 </font><br>
<font color="#a52a2a">133 </font><font color="#008b8b">$mech</font>-&gt;proxy([<font color="#ff00ff">'</font><font color="#ff00ff">http</font><font color="#ff00ff">'</font>, <font color="#ff00ff">'</font><font color="#ff00ff">https</font><font color="#ff00ff">'</font>], <font color="#008b8b">$Proxy_URL</font>) <font color="#a52a2a"><b>if</b></font>&nbsp;<font color="#008b8b">$Proxy_URL</font>;<br>
<font color="#a52a2a">134 </font><br>
<font color="#a52a2a">135 </font><font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$robot_rules</font>;<br>
<font color="#a52a2a">136 </font><br>
<font color="#a52a2a">137 </font><font color="#0000ff"># Fetch and parse robots.txt unless ignoring.</font><br>
<font color="#a52a2a">138 </font><font color="#a52a2a"><b>if</b></font>(!<font color="#008b8b">$Ignore_Robots_Txt</font>)<br>
<font color="#a52a2a">139 </font>{<br>
<font color="#a52a2a">140 </font><br>
<font color="#a52a2a">141 </font>&nbsp;&nbsp;<font color="#008b8b">$robot_rules</font>&nbsp;= WWW::RobotRules-&gt;<font color="#a52a2a"><b>new</b></font>(<font color="#008b8b">$user_agent_name</font>);<br>
<font color="#a52a2a">142 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$robots_txt_url</font>&nbsp;= <font color="#008b8b">$Host</font>-&gt;canonical . <font color="#ff00ff">'</font><font color="#ff00ff">robots.txt</font><font color="#ff00ff">'</font>;<br>
<font color="#a52a2a">143 </font><br>
<font color="#a52a2a">144 </font>&nbsp;&nbsp;<font color="#008b8b">$mech</font>-&gt;get(<font color="#008b8b">$robots_txt_url</font>);<br>
<font color="#a52a2a">145 </font>&nbsp;&nbsp;<font color="#008b8b">$robot_rules</font>-&gt;parse(<font color="#008b8b">$robots_txt_url</font>, <font color="#008b8b">$mech</font>-&gt;content);<br>
<font color="#a52a2a">146 </font><br>
<font color="#a52a2a">147 </font>}<br>
<font color="#a52a2a">148 </font><br>
<font color="#a52a2a">149 </font><font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">@urls_to_visit</font>;<br>
<font color="#a52a2a">150 </font><br>
<font color="#a52a2a">151 </font><font color="#a52a2a"><b>push</b></font>(<font color="#008b8b">@urls_to_visit</font>, <font color="#008b8b">@URLs</font>);<br>
<font color="#a52a2a">152 </font><br>
<font color="#a52a2a">153 </font><font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">%processed</font>;<br>
<font color="#a52a2a">154 </font><br>
<font color="#a52a2a">155 </font><font color="#a52a2a"><b>tie</b></font>(<font color="#008b8b">%processed</font>, <font color="#ff00ff">'</font><font color="#ff00ff">GDBM_File</font><font color="#ff00ff">'</font>, <font color="#008b8b">$Processed_GDBM_Filename</font>, GDBM_WRCREAT, <font color="#ff00ff">0666</font>);<br>
<font color="#a52a2a">156 </font><br>
<font color="#a52a2a">157 </font><font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$dbh</font>&nbsp;=<br>
<font color="#a52a2a">158 </font>&nbsp;&nbsp;DBI-&gt;<br>
<font color="#a52a2a">159 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>connect</b></font><br>
<font color="#a52a2a">160 </font>&nbsp;&nbsp;&nbsp;&nbsp;(<br>
<font color="#a52a2a">161 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$DSN</font>&nbsp;. <font color="#008b8b">$Database_Name</font>,<br>
<font color="#a52a2a">162 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$Database_User</font>,<br>
<font color="#a52a2a">163 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$Database_Password</font>,<br>
<font color="#a52a2a">164 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<font color="#ff00ff">PrintError </font>=&gt; <font color="#ff00ff">0</font>, <font color="#ff00ff">RaiseError </font>=&gt; <font color="#ff00ff">1</font>}<br>
<font color="#a52a2a">165 </font>&nbsp;&nbsp;&nbsp;&nbsp;);<br>
<font color="#a52a2a">166 </font><br>
<font color="#a52a2a">167 </font><font color="#008b8b">$dbh</font>-&gt;<font color="#a52a2a"><b>do</b></font>(<font color="#008b8b">$Create_Error_Table</font>);<br>
<font color="#a52a2a">168 </font><font color="#008b8b">$dbh</font>-&gt;<font color="#a52a2a"><b>do</b></font>(<font color="#008b8b">$Create_Linked_Table</font>);<br>
<font color="#a52a2a">169 </font><br>
<font color="#a52a2a">170 </font><font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$error_insert_sth</font>&nbsp;&nbsp;= <font color="#008b8b">$dbh</font>-&gt;prepare(<font color="#008b8b">$Error_Insert</font>);<br>
<font color="#a52a2a">171 </font><font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$linked_insert_sth</font>&nbsp;= <font color="#008b8b">$dbh</font>-&gt;prepare(<font color="#008b8b">$Linked_Insert</font>);<br>
<font color="#a52a2a">172 </font><br>
<font color="#a52a2a">173 </font><font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$url</font>;<br>
<font color="#a52a2a">174 </font><font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$error_found</font>;<br>
<font color="#a52a2a">175 </font><br>
<font color="#a52a2a">176 </font><font color="#a52a2a"><b>while</b></font>(<font color="#008b8b">$url</font>&nbsp;= <font color="#a52a2a"><b>shift</b></font>(<font color="#008b8b">@urls_to_visit</font>))<br>
<font color="#a52a2a">177 </font>{<br>
<font color="#a52a2a">178 </font><br>
<font color="#a52a2a">179 </font>&nbsp;&nbsp;<font color="#0000ff"># Skip processed URLs.</font><br>
<font color="#a52a2a">180 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>next</b></font>&nbsp;<font color="#a52a2a"><b>if</b></font>&nbsp;<font color="#008b8b">$processed</font>{<font color="#008b8b">$url</font>};<br>
<font color="#a52a2a">181 </font><br>
<font color="#a52a2a">182 </font>&nbsp;&nbsp;<font color="#0000ff"># Skip non http links.</font><br>
<font color="#a52a2a">183 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>next</b></font>&nbsp;<font color="#a52a2a"><b>if</b></font>&nbsp;<font color="#008b8b">$url</font>&nbsp;!~<font color="#a52a2a"><b>&nbsp;/</b></font><font color="#ff00ff">^http</font><font color="#a52a2a"><b>/i</b></font>;<br>
<font color="#a52a2a">184 </font><br>
<font color="#a52a2a">185 </font>&nbsp;&nbsp;<font color="#0000ff"># Skip URLs in robots.txt.</font><br>
<font color="#a52a2a">186 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>next</b></font>&nbsp;<font color="#a52a2a"><b>if</b></font>&nbsp;!<font color="#008b8b">$Ignore_Robots_Txt</font>&nbsp;&amp;&amp; !<font color="#008b8b">$robot_rules</font>-&gt;allowed(<font color="#008b8b">$url</font>);<br>
<font color="#a52a2a">187 </font><br>
<font color="#a52a2a">188 </font>&nbsp;&nbsp;<font color="#0000ff"># Skip external URLs unless enabled.</font><br>
<font color="#a52a2a">189 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>if</b></font>(!<font color="#008b8b">$External_Links</font>)<br>
<font color="#a52a2a">190 </font>&nbsp;&nbsp;{<br>
<font color="#a52a2a">191 </font><br>
<font color="#a52a2a">192 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>next</b></font>&nbsp;<font color="#a52a2a"><b>if</b></font>&nbsp;URI-&gt;<font color="#a52a2a"><b>new</b></font>(<font color="#008b8b">$url</font>)-&gt;host <font color="#a52a2a"><b>ne</b></font>&nbsp;<font color="#008b8b">$Host</font>-&gt;host;<br>
<font color="#a52a2a">193 </font><br>
<font color="#a52a2a">194 </font>&nbsp;&nbsp;}<br>
<font color="#a52a2a">195 </font><br>
<font color="#a52a2a">196 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#008b8b">STDERR</font>&nbsp;<font color="#ff00ff">"</font><font color="#ff00ff">fetching </font><font color="#008b8b">$url</font><font color="#ff00ff">...</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>&nbsp;<font color="#a52a2a"><b>unless</b></font>&nbsp;<font color="#008b8b">$Silent</font>;<br>
<font color="#a52a2a">197 </font><br>
<font color="#a52a2a">198 </font>&nbsp;&nbsp;<font color="#008b8b">$mech</font>-&gt;get(<font color="#008b8b">$url</font>);<br>
<font color="#a52a2a">199 </font><br>
<font color="#a52a2a">200 </font>&nbsp;&nbsp;<font color="#008b8b">$processed</font>{<font color="#008b8b">$url</font>}++;<br>
<font color="#a52a2a">201 </font><br>
<font color="#a52a2a">202 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>if</b></font>(<font color="#008b8b">$mech</font>-&gt;success)<br>
<font color="#a52a2a">203 </font>&nbsp;&nbsp;{<br>
<font color="#a52a2a">204 </font><br>
<font color="#a52a2a">205 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">%duplicate_link</font>;<br>
<font color="#a52a2a">206 </font><br>
<font color="#a52a2a">207 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>foreach</b></font>&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$link</font>&nbsp;(<font color="#008b8b">$mech</font>-&gt;links)<br>
<font color="#a52a2a">208 </font>&nbsp;&nbsp;&nbsp;&nbsp;{<br>
<font color="#a52a2a">209 </font><br>
<font color="#a52a2a">210 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$url</font>&nbsp;= URI-&gt;<font color="#a52a2a"><b>new</b></font>(<font color="#008b8b">$url</font>);<br>
<font color="#a52a2a">211 </font><br>
<font color="#a52a2a">212 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$redirect_url</font>&nbsp;= <font color="#008b8b">$mech</font>-&gt;response-&gt;request-&gt;uri;<br>
<font color="#a52a2a">213 </font><br>
<font color="#a52a2a">214 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#0000ff"># Skip URLs that are not on the specified host.</font><br>
<font color="#a52a2a">215 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#0000ff"># This test is done here to catch bad external links.</font><br>
<font color="#a52a2a">216 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>next</b></font>&nbsp;<font color="#a52a2a"><b>if</b></font>&nbsp;<font color="#008b8b">$url</font>-&gt;host <font color="#a52a2a"><b>ne</b></font>&nbsp;<font color="#008b8b">$Host</font>-&gt;host;<br>
<font color="#a52a2a">217 </font><br>
<font color="#a52a2a">218 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#0000ff"># Skip links that refer to current page with no anchor.</font><br>
<font color="#a52a2a">219 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>next</b></font>&nbsp;<font color="#a52a2a"><b>if</b></font>&nbsp;<font color="#008b8b">$link</font>-&gt;url <font color="#a52a2a"><b>eq</b></font>&nbsp;<font color="#ff00ff">'</font><font color="#ff00ff">#</font><font color="#ff00ff">'</font>;<br>
<font color="#a52a2a">220 </font><br>
<font color="#a52a2a">221 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#0000ff"># Make URLs absolute.</font><br>
<font color="#a52a2a">222 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$link</font>&nbsp;= <font color="#008b8b">$link</font>-&gt;url_abs;<br>
<font color="#a52a2a">223 </font><br>
<font color="#a52a2a">224 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#0000ff"># Skip URLs that match the exclude regex.</font><br>
<font color="#a52a2a">225 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>if</b></font>(<font color="#008b8b">$Exclude_Regex</font>&nbsp;&amp;&amp; <font color="#008b8b">$link</font>&nbsp;=~<font color="#a52a2a"><b>&nbsp;/</b></font><font color="#008b8b">$Exclude_Regex</font><font color="#a52a2a"><b>/</b></font>)<br>
<font color="#a52a2a">226 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>
<font color="#a52a2a">227 </font><br>
<font color="#a52a2a">228 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#008b8b">STDERR</font>&nbsp;<font color="#ff00ff">"</font><font color="#ff00ff">skipping </font><font color="#008b8b">$link</font><font color="#ff00ff">...</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>&nbsp;<font color="#a52a2a"><b>unless</b></font>&nbsp;<font color="#008b8b">$Silent</font>;<br>
<font color="#a52a2a">229 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>next</b></font>;<br>
<font color="#a52a2a">230 </font><br>
<font color="#a52a2a">231 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>
<font color="#a52a2a">232 </font><br>
<font color="#a52a2a">233 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#0000ff"># Skip duplicate links for this page.</font><br>
<font color="#a52a2a">234 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>next</b></font>&nbsp;<font color="#a52a2a"><b>if</b></font>&nbsp;<font color="#008b8b">$duplicate_link</font>{<font color="#008b8b">$link</font>};<br>
<font color="#a52a2a">235 </font><br>
<font color="#a52a2a">236 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>push</b></font>(<font color="#008b8b">@urls_to_visit</font>, <font color="#008b8b">$link</font>);<br>
<font color="#a52a2a">237 </font><br>
<font color="#a52a2a">238 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#0000ff"># Indicate if a redirect has occured.</font><br>
<font color="#a52a2a">239 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$complete_url</font>&nbsp;= <font color="#008b8b">$redirect_url</font>&nbsp;<font color="#a52a2a"><b>eq</b></font>&nbsp;<font color="#008b8b">$url</font>&nbsp;? <font color="#008b8b">$url</font>&nbsp;: <font color="#ff00ff">"</font><font color="#008b8b">$url</font><font color="#ff00ff">&nbsp;=&gt; </font><font color="#008b8b">$redirect_url</font><font color="#ff00ff">"</font>;<br>
<font color="#a52a2a">240 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br>
<font color="#a52a2a">241 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$linked_insert_sth</font>-&gt;execute(<font color="#008b8b">$link</font>, <font color="#008b8b">$complete_url</font>);<br>
<font color="#a52a2a">242 </font><br>
<font color="#a52a2a">243 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$duplicate_link</font>{<font color="#008b8b">$link</font>} = <font color="#ff00ff">1</font>;<br>
<font color="#a52a2a">244 </font><br>
<font color="#a52a2a">245 </font>&nbsp;&nbsp;&nbsp;&nbsp;} <font color="#0000ff"># END: foreach my $link ($mech-&gt;links)</font><br>
<font color="#a52a2a">246 </font><br>
<font color="#a52a2a">247 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#0000ff"># Check if the fragment has a matching anchor.</font><br>
<font color="#a52a2a">248 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$fragment</font>&nbsp;= <font color="#008b8b">$url</font>-&gt;fragment;<br>
<font color="#a52a2a">249 </font><br>
<font color="#a52a2a">250 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>if</b></font>(<font color="#008b8b">$fragment</font>)<br>
<font color="#a52a2a">251 </font>&nbsp;&nbsp;&nbsp;&nbsp;{<br>
<font color="#a52a2a">252 </font><br>
<font color="#a52a2a">253 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$anchor_found</font>&nbsp;= <font color="#ff00ff">0</font>;<br>
<font color="#a52a2a">254 </font><br>
<font color="#a52a2a">255 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$content</font>&nbsp;= <font color="#008b8b">$mech</font>-&gt;content;<br>
<font color="#a52a2a">256 </font><br>
<font color="#a52a2a">257 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$toke_parser</font>&nbsp;= HTML::TokeParser-&gt;<font color="#a52a2a"><b>new</b></font>(<font color="#008b8b">\$content</font>);<br>
<font color="#a52a2a">258 </font><br>
<font color="#a52a2a">259 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>while</b></font>(<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$token</font>&nbsp;= <font color="#008b8b">$toke_parser</font>-&gt;get_tag)<br>
<font color="#a52a2a">260 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>
<font color="#a52a2a">261 </font><br>
<font color="#a52a2a">262 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#0000ff"># Skip end tags.</font><br>
<font color="#a52a2a">263 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>next</b></font>&nbsp;<font color="#a52a2a"><b>if</b></font>&nbsp;<font color="#008b8b">$token</font>-&gt;[<font color="#ff00ff">0</font>] =~<font color="#a52a2a"><b>&nbsp;/</b></font><font color="#ff00ff">^</font><font color="#6a5acd">\/</font><font color="#a52a2a"><b>/</b></font>;<br>
<font color="#a52a2a">264 </font><br>
<font color="#a52a2a">265 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>no warnings</b></font>;<br>
<font color="#a52a2a">266 </font><br>
<font color="#a52a2a">267 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#0000ff"># Check name in anchor tags.</font><br>
<font color="#a52a2a">268 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>if</b></font>(<font color="#008b8b">$token</font>-&gt;[<font color="#ff00ff">0</font>] =~<font color="#a52a2a"><b>&nbsp;/</b></font><font color="#ff00ff">^a$</font><font color="#a52a2a"><b>/i</b></font>&nbsp;&amp;&amp; <font color="#008b8b">$token</font>-&gt;[<font color="#ff00ff">1</font>]{name} <font color="#a52a2a"><b>eq</b></font>&nbsp;<font color="#008b8b">$fragment</font>)<br>
<font color="#a52a2a">269 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>
<font color="#a52a2a">270 </font><br>
<font color="#a52a2a">271 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$anchor_found</font>&nbsp;= <font color="#ff00ff">1</font>;<br>
<font color="#a52a2a">272 </font><br>
<font color="#a52a2a">273 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>
<font color="#a52a2a">274 </font><br>
<font color="#a52a2a">275 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#0000ff"># Check for id in any tag.</font><br>
<font color="#a52a2a">276 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$anchor_found</font>&nbsp;= <font color="#ff00ff">1</font>&nbsp;<font color="#a52a2a"><b>if</b></font>&nbsp;<font color="#008b8b">$token</font>-&gt;[<font color="#ff00ff">1</font>]{id} <font color="#a52a2a"><b>eq</b></font>&nbsp;<font color="#008b8b">$fragment</font>;<br>
<font color="#a52a2a">277 </font><br>
<font color="#a52a2a">278 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>use warnings</b></font>;<br>
<font color="#a52a2a">279 </font><br>
<font color="#a52a2a">280 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>
<font color="#a52a2a">281 </font><br>
<font color="#a52a2a">282 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>if</b></font>(!<font color="#008b8b">$anchor_found</font>)<br>
<font color="#a52a2a">283 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>
<font color="#a52a2a">284 </font><br>
<font color="#a52a2a">285 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$error</font>&nbsp;= <font color="#ff00ff">"</font><font color="#ff00ff">Missing anchor: </font><font color="#008b8b">$fragment</font><font color="#ff00ff">"</font>;<br>
<font color="#a52a2a">286 </font><br>
<font color="#a52a2a">287 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>warn</b></font>(<font color="#ff00ff">"</font><font color="#008b8b">$url</font><font color="#ff00ff">: </font><font color="#008b8b">$error</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>) <font color="#a52a2a"><b>unless</b></font>&nbsp;<font color="#008b8b">$Silent</font>;<br>
<font color="#a52a2a">288 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$error_insert_sth</font>-&gt;execute(<font color="#008b8b">$error</font>, <font color="#008b8b">$url</font>);<br>
<font color="#a52a2a">289 </font><br>
<font color="#a52a2a">290 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$error_found</font>&nbsp;= <font color="#ff00ff">1</font>;<br>
<font color="#a52a2a">291 </font><br>
<font color="#a52a2a">292 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>
<font color="#a52a2a">293 </font><br>
<font color="#a52a2a">294 </font>&nbsp;&nbsp;&nbsp;&nbsp;} <font color="#0000ff"># END: if($fragment)</font><br>
<font color="#a52a2a">295 </font><br>
<font color="#a52a2a">296 </font>&nbsp;&nbsp;}<br>
<font color="#a52a2a">297 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>else</b></font><br>
<font color="#a52a2a">298 </font>&nbsp;&nbsp;{<br>
<font color="#a52a2a">299 </font><br>
<font color="#a52a2a">300 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>warn</b></font>(<font color="#ff00ff">"</font><font color="#008b8b">$url</font><font color="#ff00ff">: </font><font color="#ff00ff">"</font>&nbsp;. <font color="#008b8b">$mech</font>-&gt;response-&gt;message . <font color="#ff00ff">"</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>) <font color="#a52a2a"><b>unless</b></font>&nbsp;<font color="#008b8b">$Silent</font>;<br>
<font color="#a52a2a">301 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$error_insert_sth</font>-&gt;execute(<font color="#008b8b">$mech</font>-&gt;response-&gt;message, <font color="#008b8b">$url</font>);<br>
<font color="#a52a2a">302 </font><br>
<font color="#a52a2a">303 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$error_found</font>&nbsp;= <font color="#ff00ff">1</font>;<br>
<font color="#a52a2a">304 </font><br>
<font color="#a52a2a">305 </font>&nbsp;&nbsp;}<br>
<font color="#a52a2a">306 </font><br>
<font color="#a52a2a">307 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>sleep</b></font>(<font color="#008b8b">$Delay</font>) <font color="#a52a2a"><b>if</b></font>&nbsp;<font color="#008b8b">$Delay</font>;<br>
<font color="#a52a2a">308 </font><br>
<font color="#a52a2a">309 </font>} <font color="#0000ff"># END: while($url = shift(@urls_to_visit)</font><br>
<font color="#a52a2a">310 </font><br>
<font color="#a52a2a">311 </font><font color="#0000ff"># Prevent "closing dbh with active statement handles" error. This occurs when no</font><br>
<font color="#a52a2a">312 </font><font color="#0000ff"># errors are found.</font><br>
<font color="#a52a2a">313 </font><font color="#a52a2a"><b>if</b></font>(!<font color="#008b8b">$error_found</font>)<br>
<font color="#a52a2a">314 </font>{<br>
<font color="#a52a2a">315 </font><br>
<font color="#a52a2a">316 </font>&nbsp;&nbsp;<font color="#008b8b">$error_insert_sth</font>-&gt;{Active} = <font color="#ff00ff">1</font>;<br>
<font color="#a52a2a">317 </font>&nbsp;&nbsp;<font color="#008b8b">$error_insert_sth</font>-&gt;finish;<br>
<font color="#a52a2a">318 </font><br>
<font color="#a52a2a">319 </font>}<br>
<font color="#a52a2a">320 </font><br>
<font color="#a52a2a">321 </font><font color="#a52a2a"><b>if</b></font>(!<font color="#008b8b">$Silent</font>)<br>
<font color="#a52a2a">322 </font>{<br>
<font color="#a52a2a">323 </font><br>
<font color="#a52a2a">324 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$spidering_end_time</font>&nbsp;= DateTime-&gt;now(<font color="#ff00ff">time_zone </font>=&gt; <font color="#ff00ff">'</font><font color="#ff00ff">local</font><font color="#ff00ff">'</font>);<br>
<font color="#a52a2a">325 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#008b8b">STDERR</font>&nbsp;<font color="#ff00ff">"</font><font color="#6a5acd">\n</font><font color="#ff00ff">Spidering End time: </font><font color="#008b8b">$spidering_end_time</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>;<br>
<font color="#a52a2a">326 </font><br>
<font color="#a52a2a">327 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$elapsed_time</font>&nbsp;= <font color="#008b8b">$start_time</font>&nbsp;- <font color="#008b8b">$spidering_end_time</font>;<br>
<font color="#a52a2a">328 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#008b8b">STDERR</font><br>
<font color="#a52a2a">329 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#ff00ff">'</font><font color="#ff00ff">Elapsed time: </font><font color="#ff00ff">'</font>&nbsp;.<br>
<font color="#a52a2a">330 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$elapsed_time</font>-&gt;hours&nbsp;&nbsp; . <font color="#ff00ff">'</font><font color="#ff00ff">&nbsp;hours </font><font color="#ff00ff">'</font>&nbsp;.<br>
<font color="#a52a2a">331 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$elapsed_time</font>-&gt;minutes . <font color="#ff00ff">'</font><font color="#ff00ff">&nbsp;minutes </font><font color="#ff00ff">'</font>&nbsp;.<br>
<font color="#a52a2a">332 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$elapsed_time</font>-&gt;seconds . <font color="#ff00ff">'</font><font color="#ff00ff">&nbsp;seconds</font><font color="#ff00ff">'</font>&nbsp;.<br>
<font color="#a52a2a">333 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#ff00ff">"</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>;<br>
<font color="#a52a2a">334 </font><br>
<font color="#a52a2a">335 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$gdbm_file_size</font>&nbsp;&nbsp; = <font color="#a52a2a"><b>-s</b></font>&nbsp;<font color="#008b8b">$Processed_GDBM_Filename</font>;&nbsp;&nbsp;<br>
<font color="#a52a2a">336 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$sqlite_file_size</font>&nbsp;= <font color="#a52a2a"><b>-s</b></font>&nbsp;<font color="#008b8b">$Database_Name</font>;&nbsp;&nbsp;<br>
<font color="#a52a2a">337 </font><br>
<font color="#a52a2a">338 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#008b8b">STDERR</font>&nbsp;<font color="#ff00ff">"</font><font color="#6a5acd">\n</font><font color="#ff00ff">GDBM file size: </font><font color="#008b8b">$gdbm_file_size</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>;<br>
<font color="#a52a2a">339 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#008b8b">STDERR</font>&nbsp;<font color="#ff00ff">"</font><font color="#ff00ff">SQLite file size: </font><font color="#008b8b">$sqlite_file_size</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>;<br>
<font color="#a52a2a">340 </font><br>
<font color="#a52a2a">341 </font>}<br>
<font color="#a52a2a">342 </font><br>
<font color="#a52a2a">343 </font><font color="#0000ff"># Remove GDBM file after completed spidering.</font><br>
<font color="#a52a2a">344 </font><font color="#a52a2a"><b>untie</b></font>(<font color="#008b8b">%processed</font>);<br>
<font color="#a52a2a">345 </font><br>
<font color="#a52a2a">346 </font><font color="#a52a2a"><b>if</b></font>(!<font color="#008b8b">$Debugging</font>)<br>
<font color="#a52a2a">347 </font>{<br>
<font color="#a52a2a">348 </font><br>
<font color="#a52a2a">349 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>unlink</b></font>(<font color="#008b8b">$Processed_GDBM_Filename</font>) ||<br>
<font color="#a52a2a">350 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>die</b></font>&nbsp;<font color="#ff00ff">"</font><font color="#ff00ff">Can't remove </font><font color="#008b8b">$Processed_GDBM_Filename</font><font color="#ff00ff">: </font><font color="#008b8b">$!</font><font color="#ff00ff">"</font>;<br>
<font color="#a52a2a">351 </font><br>
<font color="#a52a2a">352 </font>}<br>
<font color="#a52a2a">353 </font><br>
<font color="#a52a2a">354 </font><font color="#0000ff"># Errors.</font><br>
<font color="#a52a2a">355 </font><font color="#a52a2a"><b>if</b></font>(!<font color="#008b8b">$Links_Only</font>)<br>
<font color="#a52a2a">356 </font>{<br>
<font color="#a52a2a">357 </font><br>
<font color="#a52a2a">358 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$error_select_sth</font>&nbsp;= <font color="#008b8b">$dbh</font>-&gt;prepare(<font color="#008b8b">$Error_Select</font>);<br>
<font color="#a52a2a">359 </font>&nbsp;&nbsp;<font color="#008b8b">$error_select_sth</font>-&gt;execute;<br>
<font color="#a52a2a">360 </font><br>
<font color="#a52a2a">361 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#ff00ff">"</font><font color="#ff00ff">Error</font><font color="#6a5acd">\t</font><font color="#ff00ff">Bad Link</font><font color="#6a5acd">\t</font><font color="#ff00ff">Pages Containing Bad Link</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>&nbsp;<font color="#a52a2a"><b>unless</b></font>&nbsp;<font color="#008b8b">$Suppress_Header</font>;<br>
<font color="#a52a2a">362 </font><br>
<font color="#a52a2a">363 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$previous_error</font>&nbsp;&nbsp;&nbsp;&nbsp;= <font color="#ff00ff">''</font>;<br>
<font color="#a52a2a">364 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$previous_bad_link</font>&nbsp;= <font color="#ff00ff">''</font>;<br>
<font color="#a52a2a">365 </font><br>
<font color="#a52a2a">366 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>while</b></font>(<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$error_record</font>&nbsp;= <font color="#008b8b">$error_select_sth</font>-&gt;fetchrow_hashref)<br>
<font color="#a52a2a">367 </font>&nbsp;&nbsp;{<br>
<font color="#a52a2a">368 </font><br>
<font color="#a52a2a">369 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$current_error</font>&nbsp;&nbsp;&nbsp;&nbsp;= <font color="#008b8b">$error_record</font>-&gt;{error};<br>
<font color="#a52a2a">370 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$current_bad_link</font>&nbsp;= <font color="#008b8b">$error_record</font>-&gt;{bad_link};<br>
<font color="#a52a2a">371 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$page</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; = <font color="#008b8b">$error_record</font>-&gt;{page};<br>
<font color="#a52a2a">372 </font><br>
<font color="#a52a2a">373 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#ff00ff">"</font><font color="#008b8b">$current_error</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>&nbsp;<font color="#a52a2a"><b>if</b></font>&nbsp;<font color="#008b8b">$current_error</font>&nbsp;<font color="#a52a2a"><b>ne</b></font>&nbsp;<font color="#008b8b">$previous_error</font>;<br>
<font color="#a52a2a">374 </font><br>
<font color="#a52a2a">375 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#ff00ff">"</font><font color="#6a5acd">\t</font><font color="#008b8b">$current_bad_link</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>&nbsp;<font color="#a52a2a"><b>if</b></font>&nbsp;<font color="#008b8b">$current_bad_link</font>&nbsp;<font color="#a52a2a"><b>ne</b></font>&nbsp;<font color="#008b8b">$previous_bad_link</font>;<br>
<font color="#a52a2a">376 </font><br>
<font color="#a52a2a">377 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#ff00ff">"</font><font color="#6a5acd">\t\t</font><font color="#008b8b">$page</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>;<br>
<font color="#a52a2a">378 </font><br>
<font color="#a52a2a">379 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$previous_error</font>&nbsp;= <font color="#008b8b">$current_error</font>;<br>
<font color="#a52a2a">380 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$previous_bad_link</font>&nbsp;= <font color="#008b8b">$current_bad_link</font>;<br>
<font color="#a52a2a">381 </font><br>
<font color="#a52a2a">382 </font>&nbsp;&nbsp;}<br>
<font color="#a52a2a">383 </font><br>
<font color="#a52a2a">384 </font>} <font color="#0000ff"># END: if(!$Links_Only)</font><br>
<font color="#a52a2a">385 </font><br>
<font color="#a52a2a">386 </font><font color="#0000ff"># Links.</font><br>
<font color="#a52a2a">387 </font><font color="#a52a2a"><b>if</b></font>(!<font color="#008b8b">$Errors_Only</font>)<br>
<font color="#a52a2a">388 </font>{<br>
<font color="#a52a2a">389 </font><br>
<font color="#a52a2a">390 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$linked_select_sth</font>&nbsp;= <font color="#008b8b">$dbh</font>-&gt;prepare(<font color="#008b8b">$Linked_Select</font>);<br>
<font color="#a52a2a">391 </font>&nbsp;&nbsp;<font color="#008b8b">$linked_select_sth</font>-&gt;execute;<br>
<font color="#a52a2a">392 </font><br>
<font color="#a52a2a">393 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#ff00ff">"</font><font color="#6a5acd">\n</font><font color="#ff00ff">Link</font><font color="#6a5acd">\t</font><font color="#ff00ff">Pages Containing Link</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>&nbsp;<font color="#a52a2a"><b>unless</b></font>&nbsp;<font color="#008b8b">$Suppress_Header</font>;<br>
<font color="#a52a2a">394 </font><br>
<font color="#a52a2a">395 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$previous_link</font>&nbsp;= <font color="#ff00ff">''</font>;<br>
<font color="#a52a2a">396 </font><br>
<font color="#a52a2a">397 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>while</b></font>(<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$link_record</font>&nbsp;= <font color="#008b8b">$linked_select_sth</font>-&gt;fetchrow_hashref)<br>
<font color="#a52a2a">398 </font>&nbsp;&nbsp;{<br>
<font color="#a52a2a">399 </font><br>
<font color="#a52a2a">400 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$current_link</font>&nbsp;= <font color="#008b8b">$link_record</font>-&gt;{<font color="#a52a2a"><b>link</b></font>};<br>
<font color="#a52a2a">401 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$page</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; = <font color="#008b8b">$link_record</font>-&gt;{page};<br>
<font color="#a52a2a">402 </font><br>
<font color="#a52a2a">403 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>if</b></font>(<font color="#008b8b">$Include_Regex</font>&nbsp;&amp;&amp; <font color="#008b8b">$current_link</font>&nbsp;!~<font color="#a52a2a"><b>&nbsp;/</b></font><font color="#008b8b">$Include_Regex</font><font color="#a52a2a"><b>/</b></font>)<br>
<font color="#a52a2a">404 </font>&nbsp;&nbsp;&nbsp;&nbsp;{<br>
<font color="#a52a2a">405 </font><br>
<font color="#a52a2a">406 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#008b8b">STDERR</font>&nbsp;<font color="#ff00ff">"</font><font color="#ff00ff">skipping </font><font color="#008b8b">$current_link</font><font color="#ff00ff">...</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>&nbsp;<font color="#a52a2a"><b>unless</b></font>&nbsp;<font color="#008b8b">$Silent</font>;<br>
<font color="#a52a2a">407 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>next</b></font>;<br>
<font color="#a52a2a">408 </font><br>
<font color="#a52a2a">409 </font>&nbsp;&nbsp;&nbsp;&nbsp;}<br>
<font color="#a52a2a">410 </font><br>
<font color="#a52a2a">411 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#ff00ff">"</font><font color="#008b8b">$current_link</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>&nbsp;<font color="#a52a2a"><b>if</b></font>&nbsp;<font color="#008b8b">$current_link</font>&nbsp;<font color="#a52a2a"><b>ne</b></font>&nbsp;<font color="#008b8b">$previous_link</font>;<br>
<font color="#a52a2a">412 </font><br>
<font color="#a52a2a">413 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#ff00ff">"</font><font color="#6a5acd">\t</font><font color="#008b8b">$page</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>;<br>
<font color="#a52a2a">414 </font><br>
<font color="#a52a2a">415 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$previous_link</font>&nbsp;= <font color="#008b8b">$current_link</font>;<br>
<font color="#a52a2a">416 </font><br>
<font color="#a52a2a">417 </font>&nbsp;&nbsp;}<br>
<font color="#a52a2a">418 </font><br>
<font color="#a52a2a">419 </font>} <font color="#0000ff"># END: if(!$Errors_Only)</font><br>
<font color="#a52a2a">420 </font><br>
<font color="#a52a2a">421 </font><font color="#0000ff"># Remove database file after completed report.</font><br>
<font color="#a52a2a">422 </font><font color="#008b8b">$error_insert_sth</font>-&gt;finish;<br>
<font color="#a52a2a">423 </font><font color="#008b8b">$linked_insert_sth</font>-&gt;finish;<br>
<font color="#a52a2a">424 </font><br>
<font color="#a52a2a">425 </font><font color="#008b8b">$dbh</font>-&gt;disconnect;<br>
<font color="#a52a2a">426 </font><br>
<font color="#a52a2a">427 </font><font color="#a52a2a"><b>if</b></font>(!<font color="#008b8b">$Debugging</font>)<br>
<font color="#a52a2a">428 </font>{<br>
<font color="#a52a2a">429 </font><br>
<font color="#a52a2a">430 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>unlink</b></font>(<font color="#008b8b">$Database_Name</font>) || <font color="#a52a2a"><b>die</b></font>&nbsp;<font color="#ff00ff">"</font><font color="#ff00ff">Can't remove </font><font color="#008b8b">$Database_Name</font><font color="#ff00ff">: </font><font color="#008b8b">$!</font><font color="#ff00ff">"</font>;<br>
<font color="#a52a2a">431 </font><br>
<font color="#a52a2a">432 </font>}<br>
<font color="#a52a2a">433 </font><br>
<font color="#a52a2a">434 </font><font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$end_time</font>&nbsp;= DateTime-&gt;now(<font color="#ff00ff">time_zone </font>=&gt; <font color="#ff00ff">'</font><font color="#ff00ff">local</font><font color="#ff00ff">'</font>);<br>
<font color="#a52a2a">435 </font><br>
<font color="#a52a2a">436 </font><font color="#a52a2a"><b>if</b></font>(<font color="#008b8b">$Email_Addresses</font>)<br>
<font color="#a52a2a">437 </font>{<br>
<font color="#a52a2a">438 </font><br>
<font color="#a52a2a">439 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$message</font>&nbsp;=<br>
<font color="#a52a2a">440 </font>&nbsp;&nbsp;&nbsp;&nbsp;MIME::Lite-&gt;<font color="#a52a2a"><b>new</b></font><br>
<font color="#a52a2a">441 </font>&nbsp;&nbsp;&nbsp;&nbsp;(<br>
<font color="#a52a2a">442 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#ff00ff">From&nbsp;&nbsp;&nbsp;&nbsp; </font>=&gt; <font color="#008b8b">$From_Email_Address</font>,<br>
<font color="#a52a2a">443 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#ff00ff">To&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </font>=&gt; <font color="#008b8b">$Email_Addresses</font>,<br>
<font color="#a52a2a">444 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#ff00ff">Subject&nbsp;&nbsp;</font>=&gt; <font color="#ff00ff">'</font><font color="#ff00ff">Monthly Link Report for </font><font color="#ff00ff">'</font>&nbsp;. <font color="#008b8b">$end_time</font>-&gt;mdy,<br>
<font color="#a52a2a">445 </font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#ff00ff">Type&nbsp;&nbsp;&nbsp;&nbsp; </font>=&gt; <font color="#ff00ff">'</font><font color="#ff00ff">multipart/mixed</font><font color="#ff00ff">'</font>,<br>
<font color="#a52a2a">446 </font>&nbsp;&nbsp;&nbsp;&nbsp;);<br>
<font color="#a52a2a">447 </font><br>
<font color="#a52a2a">448 </font>&nbsp;&nbsp;<font color="#008b8b">$message</font>-&gt;attach<br>
<font color="#a52a2a">449 </font>&nbsp;&nbsp;(<br>
<font color="#a52a2a">450 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#ff00ff">Type&nbsp;&nbsp;&nbsp;&nbsp; </font>=&gt; <font color="#ff00ff">'</font><font color="#ff00ff">text/plain</font><font color="#ff00ff">'</font>,<br>
<font color="#a52a2a">451 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#ff00ff">Encoding </font>=&gt; <font color="#ff00ff">'</font><font color="#ff00ff">quoted-printable</font><font color="#ff00ff">'</font>,<br>
<font color="#a52a2a">452 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#ff00ff">Data&nbsp;&nbsp;&nbsp;&nbsp; </font>=&gt; <font color="#ff00ff">'</font><font color="#ff00ff">Attached is the Link Report completed </font><font color="#ff00ff">'</font>&nbsp;. <font color="#008b8b">$end_time</font>-&gt;mdy,<br>
<font color="#a52a2a">453 </font>&nbsp;&nbsp;);<br>
<font color="#a52a2a">454 </font><br>
<font color="#a52a2a">455 </font>&nbsp;&nbsp;<font color="#008b8b">$message</font>-&gt;attach<br>
<font color="#a52a2a">456 </font>&nbsp;&nbsp;(<br>
<font color="#a52a2a">457 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#ff00ff">Type </font>=&gt; <font color="#ff00ff">'</font><font color="#ff00ff">application/excel</font><font color="#ff00ff">'</font>,<br>
<font color="#a52a2a">458 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#ff00ff">Path </font>=&gt; <font color="#008b8b">$Output_Filename</font>,<br>
<font color="#a52a2a">459 </font>&nbsp;&nbsp;);<br>
<font color="#a52a2a">460 </font><br>
<font color="#a52a2a">461 </font>&nbsp;&nbsp;<font color="#008b8b">$message</font>-&gt;<font color="#a52a2a"><b>send</b></font>(<font color="#ff00ff">'</font><font color="#ff00ff">smtp</font><font color="#ff00ff">'</font>, <font color="#008b8b">$SMTP_Server</font>);<br>
<font color="#a52a2a">462 </font><br>
<font color="#a52a2a">463 </font>}<br>
<font color="#a52a2a">464 </font><br>
<font color="#a52a2a">465 </font><font color="#a52a2a"><b>if</b></font>(!<font color="#008b8b">$Silent</font>)<br>
<font color="#a52a2a">466 </font>{<br>
<font color="#a52a2a">467 </font><br>
<font color="#a52a2a">468 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#008b8b">STDERR</font>&nbsp;<font color="#ff00ff">"</font><font color="#6a5acd">\n</font><font color="#ff00ff">End time: </font><font color="#008b8b">$end_time</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>;<br>
<font color="#a52a2a">469 </font><br>
<font color="#a52a2a">470 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>my</b></font>&nbsp;<font color="#008b8b">$elapsed_time</font>&nbsp;= <font color="#008b8b">$start_time</font>&nbsp;- <font color="#008b8b">$end_time</font>;<br>
<font color="#a52a2a">471 </font>&nbsp;&nbsp;<font color="#a52a2a"><b>print</b></font>&nbsp;<font color="#008b8b">STDERR</font><br>
<font color="#a52a2a">472 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#ff00ff">'</font><font color="#ff00ff">Elapsed time: </font><font color="#ff00ff">'</font>&nbsp;.<br>
<font color="#a52a2a">473 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$elapsed_time</font>-&gt;hours&nbsp;&nbsp; . <font color="#ff00ff">'</font><font color="#ff00ff">&nbsp;hours </font><font color="#ff00ff">'</font>&nbsp;.<br>
<font color="#a52a2a">474 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$elapsed_time</font>-&gt;minutes . <font color="#ff00ff">'</font><font color="#ff00ff">&nbsp;minutes </font><font color="#ff00ff">'</font>&nbsp;.<br>
<font color="#a52a2a">475 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#008b8b">$elapsed_time</font>-&gt;seconds . <font color="#ff00ff">'</font><font color="#ff00ff">&nbsp;seconds</font><font color="#ff00ff">'</font>&nbsp;.<br>
<font color="#a52a2a">476 </font>&nbsp;&nbsp;&nbsp;&nbsp;<font color="#ff00ff">"</font><font color="#6a5acd">\n</font><font color="#ff00ff">"</font>;<br>
<font color="#a52a2a">477 </font><br>
<font color="#a52a2a">478 </font>}<br>
</font>

</body></html>