<%@ include file="../include/header.jsp" %>
<% Blog b = (Blog) request.getAttribute("requestedBlog"); %>

<div id="contentLayer">
	<div class="title"><b:i18n key="DELETE_BLOG_TITLE" /></div>
	<div class="description">
		<b:i18n key="DELETE_BLOG_DESC" />
	</div>
	<%
	String[] params = new String[]{utils.renderBlog(b, request)};
	request.setAttribute("params", params);
	%>
	<b:i18n key="DELETE_BLOG_TEXT" params="params"/><br>
	<a href="<%=ctx%>/deleteBlogExec.secureaction?id=<%=b.getId()%>" class="naviLink"><b:i18n key="YES" /></a>
	&nbsp;&nbsp;
	<a href="<%=utils.peekNextToLastActionFromStack(request)%>" class="naviLink"><b:i18n key="NO" /></a>

</div>
<%@ include file="../include/footer.jsp" %>