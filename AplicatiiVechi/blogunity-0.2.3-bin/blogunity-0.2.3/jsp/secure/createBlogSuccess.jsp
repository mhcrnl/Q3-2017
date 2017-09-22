<%@ include file="../include/header.jsp" %>
<% 
Blog b = (Blog) request.getAttribute("newBlog");
%>
<div id="contentLayer">
	<div class="title"><b:i18n key="CREATED_BLOG_TITLE"/></div>
	<div class="description">
		<b:i18n key="CREATED_BLOG_DESC"/>
	</div>

	<b:i18n key="CREATED_BLOG_TEXT"/><br/>
	
	<ul>
		<li><a href="<%=ctx%>/foundedBlogsList.secureaction" class="navLink"><b:i18n key="CREATED_BLOG_LINK1"/></a><br/></li>
		<li><a href="<%=ctx%>/blogs/<%=b.getUrlName()%>" class="navLink"><b:i18n key="CREATED_BLOG_LINK2"/></a><br/></li>
	</ul>
	
</div>

<%@ include file="../include/footer.jsp" %>
	