<%@ taglib uri="/WEB-INF/tld/blogunity.tld" prefix="b" %>
<%@ taglib uri="/WEB-INF/tld/displaytag-12.tld" prefix="display" %>
<%@ page import="com.j2biz.blogunity.*"%>
<%@ page import="com.j2biz.blogunity.pojo.*"%>
<%@ page import="com.j2biz.blogunity.util.*"%>
<%@ page import="com.j2biz.blogunity.i18n.*"%>
<%@ page import="com.j2biz.blogunity.web.*"%>
<%@ page import="java.util.*"%>
<%@ page contentType="text/html; charset=UTF-8"%>
 
<% 
String ctx = request.getContextPath(); 
String base = BlogunityManager.getBase();
User user = null;
Object o = request.getSession().getAttribute("user");
if (o != null) {
	user = (User) o;
}

BlogUtils utils = BlogUtils.getInstance();
I18NMessageManager i18n = I18NMessageManager.getInstance();
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" >
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />	
	<link rel="stylesheet" type="text/css" href="<%=ctx%>/css/blogunity.css" />
	<link rel="stylesheet" href="<%=ctx%>/css/wiki.css" type="text/css" />	
	<script language="JavaScript" src="<%=ctx%>/js/blogunity.js"></script>
	<script language="JavaScript" src="<%=ctx%>/js/menu.jsp"></script>	
	<script language="JavaScript">
		window.history.forward(1);
	</script>
	<meta name="keywords" content="<%=utils.getSiteKeywords()%>" />
	<meta name="description" content="<%=utils.getSiteDescription()%>" />
	<title><%=utils.getSiteTitle()%></title>
</head>

<body >

<div id="mainLayer">

	<div id="headerLayer">
	<div id="logoLayer" style="float: left;">
			<a href="<%=ctx%>/"><img src="<%=ctx%>/images/blogunity_logo.gif" style="border: 0px;"/></a>
	</div>
	
	<% if (user == null){ %>
	<div id="loginformLayer">
		<form method="post" action="<%=ctx%>/login.action">
		<input type="text" name="name" size="20" maxlength="30" />
		<input type="password" name="password" size="20" maxlength="30" />
		<input type="submit" name="login" value="<b:i18n key="LOGIN"/>" />
		<%if (user == null && BlogunityManager.getSystemConfiguration().isAllowNewUsers()){%>
					<a href="<%=ctx%>/registerUserForm.action" class="naviLink"><b:i18n key="REGISTER"/></a>
			<%}%>
		</form>
	</div>
	<%}else{ %>
	<div style="float: right; position: relative; margin: 0px 0px 0px 0px; width: 100px; padding: 0px 0px 0px 0px; text-align: right;">
		<a href="<%=ctx%>/logout.action" class="naviLink" style="color: #FFFFFF;"><b:i18n key="LOGOUT"/></a>
	</div>
	<%}%>
	

	</div>

	<div id="centerLayer">
		<div id="menuLayer">
			<%if (user != null){%>
			<a href="#" onclick="return clickreturnvalue()" 
						onmouseover="dropdownmenu(this, event, menu1, '150px')" onmouseout="delayhidemenu()"><b:i18n key="MY_PROFILE"/></a> |
			<a href="#" onclick="return clickreturnvalue()" 
						onmouseover="dropdownmenu(this, event, menu2, '170px')" onmouseout="delayhidemenu()"><b:i18n key="BLOGS"/></a> |
			<a href="#" onclick="return clickreturnvalue()" 
						onmouseover="dropdownmenu(this, event, menu3, '170px')" onmouseout="delayhidemenu()"><b:i18n key="MESSAGE_TAPES"/></a> |
			<%}%>
			<a href="#" onclick="return clickreturnvalue()" 
						onmouseover="dropdownmenu(this, event, menu4, '150px')" onmouseout="delayhidemenu()"><b:i18n key="SEARCH"/></a> |
			<a href="#" onclick="return clickreturnvalue()" 
						onmouseover="dropdownmenu(this, event, menu5, '150px')" onmouseout="delayhidemenu()"><b:i18n key="STATISTICS"/></a>
			<%if (user != null && user.isAdministrator()){%>
			| <a href="#" onclick="return clickreturnvalue()" 
						onmouseover="dropdownmenu(this, event, menu6, '150px')" onmouseout="delayhidemenu()"><b:i18n key="ADMINISTRATION"/></a>
			<%}%>
		</div>
		<div id="naviLayer">
			<%
			NavigationStack stack = (NavigationStack) session.getAttribute(IConstants.Session.NAVIGATION_STACK);  
			if (stack != null && stack.size() > 0){
			%>
			<%=stack.toHTML(request)%>
			<%}%>
		</div>