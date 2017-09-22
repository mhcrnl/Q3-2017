<%@ include file="../include/header.jsp" %>
<% 
Blog blog = (Blog) request.getAttribute("requestedBlog"); 
String themeDir = (String) request.getAttribute("themeDir");
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="OVERWRITE_THEME_TITLE" /></div>
	<div class="description">
		<b:i18n key="OVERWRITE_THEME_DESC" />
	</div>

	<%
	String[] params = new String[]{ utils.renderBlog(blog, request)};
	request.setAttribute("params", params);
	%>
	<b:i18n key="OVERWRITE_THEME_TEXT" params="params" /><br/>
	<a href="<%=ctx%>/overwriteBlogThemeExec.secureaction?id=<%=blog.getId()%>&theme=<%=themeDir%>" class="naviLink"><b:i18n key="YES" /></a>
	&nbsp;&nbsp;
	<a href="<%=utils.peekNextToLastActionFromStack(request)%>" class="naviLink"><b:i18n key="NO" /></a>

</div>
<%@ include file="../include/footer.jsp" %>