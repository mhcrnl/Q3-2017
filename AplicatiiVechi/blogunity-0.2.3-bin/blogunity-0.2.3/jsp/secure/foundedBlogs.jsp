<%@ include file="../include/header.jsp" %>
<%Set blogs = (Set) request.getAttribute("blogs"); %>

<div id="contentLayer">
	<div class="title"><b:i18n key="FOUNDED_BLOGS_TITLE" /></div>
	<div class="description">
		<b:i18n key="FOUNDED_BLOGS_DESC" />
	</div>

	<%if (user.getUserSettings().getTotalNumberOfBlogsPerUser() == -1 || 
				user.getUserSettings().getTotalNumberOfBlogsPerUser() > user.getFoundedBlogs().size()){%>
		<a class="naviLink" href="<%=ctx%>/createBlogForm.secureaction"><b:i18n key="CREATE_NEW_BLOG" /></a><br/>
	<%}%>
	<display:table name="blogs" decorator="com.j2biz.blogunity.web.decorator.BlogsTableDecorator" 
			requestURI="foundedBlogsList.secureaction" pagesize="20" defaultsort="3" defaultorder="descending" sort="list">
		<display:column property="blog" titleKey="BLOG" sortable="true" headerClass="sortable"/>
		<display:column property="founder" titleKey="BLOG_FOUNDER" sortable="true" headerClass="sortable"/>
		<display:column property="decoratedCreateTime" titleKey="BLOG_CREATE_TIME" 
							sortable="true" headerClass="sortable" sortProperty="createTime"/>
		<display:column property="decoratedLastModifiedTime" titleKey="BLOG_LAST_MODIFIED" 
							sortable="true" headerClass="sortable" sortProperty="lastModifiedTime"/>
		<display:column property="foundedBlogsActions" titleKey="ACTIONS" />
	</display:table>

</div>

<%@ include file="../include/footer.jsp" %>
	