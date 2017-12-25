<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=windows-1252">
<title>C:\aPerl\Presentations\lwpClockProper.pl.html</title>
<meta name="Generator" content="Vim/7.3">
<meta name="plugin-version" content="vim7.3_v6">
<meta name="syntax" content="perl">
<meta name="settings" content="use_css,number_lines">
<style type="text/css">
<!--
pre { font-family: monospace; color: #000000; background-color: #ffffff; }
body { font-family: monospace; color: #000000; background-color: #ffffff; }
.lnr { color: #804040; }
.Identifier { color: #008080; }
.Constant { color: #ff00ff; }
.Statement { color: #804040; font-weight: bold; }
.Comment { color: #0000ff; }
-->
</style>
</head>
<body>
<pre><span class="lnr"> 1 </span><span class="Comment"># lwpClockProper.pl - More proper example of web scraping</span>
<span class="lnr"> 2 </span><span class="Comment">#   Features HTML decoding, easy to use HTML interface.</span>
<span class="lnr"> 3 </span><span class="Statement">use strict</span>;
<span class="lnr"> 4 </span><span class="Statement">use warnings</span>;
<span class="lnr"> 5 </span><span class="Statement">use </span>Encode;                         <span class="Comment"># Use proper encode/decode translation</span>
<span class="lnr"> 6 </span><span class="Statement">use </span>HTTP::Response::Encoding;       <span class="Comment"># Gets encode charset from the HTML Content-Type: header</span>
<span class="lnr"> 7 </span><span class="Statement">use </span>LWP::UserAgent;
<span class="lnr"> 8 </span><span class="Statement">use </span>HTML::TreeBuilder::XPath;
<span class="lnr"> 9 </span><span class="Statement">use </span>HTML::Selector::XPath <span class="Constant">qw(</span><span class="Constant">selector_to_xpath</span><span class="Constant">)</span>;
<span class="lnr">10 </span>
<span class="lnr">11 </span><span class="Statement">my</span> <span class="Identifier">$ua</span> = LWP::UserAgent-&gt;new;
<span class="lnr">12 </span><span class="Statement">my</span> <span class="Identifier">$res</span> = <span class="Identifier">$ua</span><span class="Identifier">-&gt;get</span>(<span class="Constant">"</span><span class="Constant"><a href="http://timeanddate.com/worldclock/">http://timeanddate.com/worldclock/</a></span><span class="Constant">"</span>);
<span class="lnr">13 </span>
<span class="lnr">14 </span><span class="Statement">if</span>(<span class="Identifier">$res</span><span class="Identifier">-&gt;is_error</span>){
<span class="lnr">15 </span>        <span class="Statement">die</span> <span class="Constant">"</span><span class="Constant">HTTP Get error: </span><span class="Constant">"</span>, <span class="Identifier">$res</span><span class="Identifier">-&gt;status_line</span>;
<span class="lnr">16 </span>}
<span class="lnr">17 </span>
<span class="lnr">18 </span><span class="Statement">my</span> <span class="Identifier">$page</span> = decode <span class="Identifier">$res</span><span class="Identifier">-&gt;encoding</span>, <span class="Identifier">$res</span><span class="Identifier">-&gt;content</span>;
<span class="lnr">19 </span>
<span class="lnr">20 </span><span class="Statement">my</span> <span class="Identifier">$tree</span> = HTML::TreeBuilder::XPath-&gt;new_from_content(<span class="Identifier">$page</span>);
<span class="lnr">21 </span>
<span class="lnr">22 </span><span class="Statement">my</span> <span class="Identifier">$xpath</span> = selector_to_xpath(<span class="Constant">"</span><span class="Constant">strong#ctu</span><span class="Constant">"</span>);
<span class="lnr">23 </span><span class="Statement">my</span> <span class="Identifier">$node</span> = <span class="Identifier">$tree</span><span class="Identifier">-&gt;findnodes</span>(<span class="Identifier">$xpath</span>)-&gt;<span class="Statement">shift</span>;
<span class="lnr">24 </span><span class="Statement">print</span> <span class="Identifier">$node</span><span class="Identifier">-&gt;as_text</span>;
</pre>


</body></html>