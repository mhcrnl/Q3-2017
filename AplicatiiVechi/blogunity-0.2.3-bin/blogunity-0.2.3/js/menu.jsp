<%@ taglib uri="/WEB-INF/tld/blogunity.tld" prefix="b" %>
<%@ page import="com.j2biz.blogunity.pojo.*"%>
<%@ page import="com.j2biz.blogunity.util.*"%>
<%@ page import="com.j2biz.blogunity.i18n.*"%>
<%@ page import="com.j2biz.blogunity.web.*"%>
<%@ page import="java.util.*"%>
<%@ page contentType="text/html; charset=UTF-8"%>
<% 
String ctx = request.getContextPath(); 
User user = null;
Object o = request.getSession().getAttribute("user");
if (o != null) {
	user = (User) o;
}

BlogUtils utils = BlogUtils.getInstance();
%>
/***********************************************
* AnyLink Drop Down Menu- � Dynamic Drive (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit http://www.dynamicdrive.com/ for full source code
***********************************************/

<%if (user != null){%>
//Profile
var menu1=new Array()
menu1[0]='<a href="<%=ctx%>/editProfileForm.secureaction" class="naviLink"><b:i18n key="MY_PROFILE.PROFILE" /></a><br>'
menu1[1]='<a href="<%=ctx%>/editUserpicsForm.secureaction" class="naviLink"><b:i18n key="MY_PROFILE.USERPICS" /></a><br>'
menu1[2]='<a href="<%=ctx%>/friendsList.secureaction" class="naviLink"><b:i18n key="MY_PROFILE.FRIENDS"/></a><br>'
menu1[3]='<a href="<%=ctx%>/previewProfile.secureaction" class="naviLink"><b:i18n key="MY_PROFILE.PREVIEW"/></a><br>'

//Blogs
var menu2=new Array()
menu2[0]='<a href="<%=ctx%>/foundedBlogsList.secureaction" class="naviLink"><b:i18n key="BLOGS.FOUNDED_BLOGS"/></a><br>'
menu2[1]='<a href="<%=ctx%>/communityBlogs.secureaction" class="naviLink"><b:i18n key="BLOGS.JOINED_BLOGS"/></a><br>'
menu2[2]='<a href="<%=ctx%>/manageFavoriteBlogs.secureaction" class="naviLink"><b:i18n key="BLOGS.FAVORITE_BLOGS"/></a><br>'
		
//Tapes
var menu3=new Array()
menu3[0]='<a href="<%=ctx%>/foundedBlogsTape.secureaction" class="naviLink"><b:i18n key="MESSAGE_TAPES.FOUNDED_BLOGS"/></a><br>'
menu3[1]='<a href="<%=ctx%>/communityBlogsTape.secureaction" class="naviLink"><b:i18n key="MESSAGE_TAPES.JOINED_BLOGS"/></a><br>'
menu3[2]='<a href="<%=ctx%>/favoriteBlogsTape.secureaction" class="naviLink"><b:i18n key="MESSAGE_TAPES.FAVORITE_BLOGS"/></a><br>'
menu3[3]='<a href="<%=ctx%>/friendsTape.secureaction" class="naviLink"><b:i18n key="MESSAGE_TAPES.FRIENDS_BLOGS"/></a><br>'
<%}%>


//Search
var menu4=new Array()
menu4[0]='<a href="<%=ctx%>/searchBlogForm.action" class="naviLink"><b:i18n key="SEARCH.BLOG"/></a><br>'
menu4[1]='<a href="<%=ctx%>/searchUserForm.action" class="naviLink"><b:i18n key="SEARCH.USER"/></a><br>'

//Statistics
var menu5=new Array()
menu5[0]='<a href="<%=ctx%>/globalStatistics.action" class="naviLink"><b:i18n key="STATISTICS.GLOBAL"/></a><br>'


<%if (user != null && user.isAdministrator()){%>
//System
var menu6=new Array()
menu6[0]='<a href="<%=ctx%>/editSystemConfigurationForm.secureaction" class="naviLink"><b:i18n key="ADMINISTRATION.SYSTEM_SETTINGS"/></a><br>'
menu6[1]='<a href="<%=ctx%>/listGlobalCategories.secureaction" class="naviLink"><b:i18n key="ADMINISTRATION.GLOBAL_CATEGORIES"/></a><br>'
menu6[2]='<a href="<%=ctx%>/listUsersAdmin.secureaction" class="naviLink"><b:i18n key="ADMINISTRATION.USERS"/></a><br>'
menu6[3]='<a href="<%=ctx%>/listBlogsAdmin.secureaction" class="naviLink"><b:i18n key="ADMINISTRATION.BLOGS"/></a><br>'
menu6[3]='<a href="<%=ctx%>/listSysinfo.secureaction" class="naviLink"><b:i18n key="ADMINISTRATION.SYSTEM_INFO"/></a><br>'
<%}%>


var menuwidth='165px' //default menu width
var menubgcolor='#F0F0F0'  //menu bgcolor
var disappeardelay=250  //menu disappear speed onMouseout (in miliseconds)
var hidemenu_onclick="yes" //hide menu when user clicks within menu?

/////No further editting needed

var ie4=document.all
var ns6=document.getElementById&&!document.all

if (ie4||ns6)
document.write('<div id="dropmenudiv" style="visibility:hidden;width:'+menuwidth+';background-color:'+menubgcolor+'" onMouseover="clearhidemenu()" onMouseout="dynamichide(event)"></div>')


function getposOffset(what, offsettype){
var totaloffset=(offsettype=="left")? what.offsetLeft : what.offsetTop;
var parentEl=what.offsetParent;
while (parentEl!=null){
totaloffset=(offsettype=="left")? totaloffset+parentEl.offsetLeft : totaloffset+parentEl.offsetTop;
parentEl=parentEl.offsetParent;
}
return totaloffset;
}


function showhide(obj, e, visible, hidden, menuwidth){
if (ie4||ns6)
dropmenuobj.style.left=dropmenuobj.style.top=-500
if (menuwidth!=""){
dropmenuobj.widthobj=dropmenuobj.style
dropmenuobj.widthobj.width=menuwidth
}
if (e.type=="click" && obj.visibility==hidden || e.type=="mouseover")
obj.visibility=visible
else if (e.type=="click")
obj.visibility=hidden
}

function iecompattest(){
return (document.compatMode && document.compatMode!="BackCompat")? document.documentElement : document.body
}

function clearbrowseredge(obj, whichedge){
var edgeoffset=0
if (whichedge=="rightedge"){
var windowedge=ie4 && !window.opera? iecompattest().scrollLeft+iecompattest().clientWidth-15 : window.pageXOffset+window.innerWidth-15
dropmenuobj.contentmeasure=dropmenuobj.offsetWidth
if (windowedge-dropmenuobj.x < dropmenuobj.contentmeasure)
edgeoffset=dropmenuobj.contentmeasure-obj.offsetWidth
}
else{
var windowedge=ie4 && !window.opera? iecompattest().scrollTop+iecompattest().clientHeight-15 : window.pageYOffset+window.innerHeight-18
dropmenuobj.contentmeasure=dropmenuobj.offsetHeight
if (windowedge-dropmenuobj.y < dropmenuobj.contentmeasure)
edgeoffset=dropmenuobj.contentmeasure+obj.offsetHeight
}
return edgeoffset
}

function populatemenu(what){
if (ie4||ns6)
dropmenuobj.innerHTML=what.join("")
}


function dropdownmenu(obj, e, menucontents, menuwidth){
if (window.event) event.cancelBubble=true
else if (e.stopPropagation) e.stopPropagation()
clearhidemenu()
dropmenuobj=document.getElementById? document.getElementById("dropmenudiv") : dropmenudiv
populatemenu(menucontents)

if (ie4||ns6){
showhide(dropmenuobj.style, e, "visible", "hidden", menuwidth)
dropmenuobj.x=getposOffset(obj, "left")
dropmenuobj.y=getposOffset(obj, "top")
dropmenuobj.style.left=dropmenuobj.x-clearbrowseredge(obj, "rightedge")+"px"
dropmenuobj.style.top=dropmenuobj.y-clearbrowseredge(obj, "bottomedge")+obj.offsetHeight+"px"
}

return clickreturnvalue()
}

function clickreturnvalue(){
if (ie4||ns6) return false
else return true
}

function contains_ns6(a, b) {
while (b.parentNode)
if ((b = b.parentNode) == a)
return true;
return false;
}

function dynamichide(e){
if (ie4&&!dropmenuobj.contains(e.toElement))
delayhidemenu()
else if (ns6&&e.currentTarget!= e.relatedTarget&& !contains_ns6(e.currentTarget, e.relatedTarget))
delayhidemenu()
}

function hidemenu(e){
if (typeof dropmenuobj!="undefined"){
if (ie4||ns6)
dropmenuobj.style.visibility="hidden"
}
}

function delayhidemenu(){
if (ie4||ns6)
delayhide=setTimeout("hidemenu()",disappeardelay)
}

function clearhidemenu(){
if (typeof delayhide!="undefined")
clearTimeout(delayhide)
}


if (hidemenu_onclick=="yes")
document.onclick=hidemenu