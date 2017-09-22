<%@ include file="../include/header.jsp" %>
<% 
Blog b = (Blog) request.getAttribute("requestedBlog"); 
User u = (User) request.getAttribute("requestedUser"); 
%>
<div id="contentLayer">
	<div class="title"><b:i18n key="DISMISS_MEMBER_FROM_BLOG_TITLE" /></div>
	<div class="description">
		<b:i18n key="DISMISS_MEMBER_FROM_BLOG_DESC" />
	</div>

	<% 
	String[] params = new String[]{ utils.renderUser(u, request), utils.renderBlog(b, request) };
	request.setAttribute("params", params);
	%>
	<b:i18n key="DISMISS_MEMBER_FROM_BLOG_TEXT" params="params" /><br>
	<a href="<%=ctx%>/dismissMemberFromCommunityBlogExec.secureaction?userid=<%=u.getId()%>&blogid=<%=b.getId()%>" class="naviLink"><b:i18n key="YES" /></a>
	&nbsp;&nbsp;
	<a href="<%=utils.peekNextToLastActionFromStack(request)%>" class="naviLink"><b:i18n key="NO" /></a>

</div>
<%@ include file="../include/footer.jsp" %>
