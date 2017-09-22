<%@ include file="../include/header.jsp" %>
<%
FormErrorList errors = (FormErrorList) request.getAttribute("errors");
List blogs = (List) request.getAttribute("blogs");
String searchBlog = (String) request.getAttribute("searchBlog");
%>
<div id="contentLayer">
	<div class="title"><b:i18n key="SYSTEM_BLOGS_TITLE" /></div>
	<div class="description">
		<b:i18n key="SYSTEM_BLOGS_DESC" />
	</div>

	<div id="formLayer">
		<form method="post" action="<%=ctx%>/listBlogsAdmin.secureaction">
			<!-- ############# BLOGNAME ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("blogname")){ %>
			<div class="textError" onclick="toggle('errorLayerBlogname')"><b:i18n key="SEARCH.BLOG" />:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SEARCH.BLOG" />:</div> 
			<%}%>
			<input type="text" name="blogname" size="25" maxlength="10" value="<%= (searchBlog != null)? searchBlog : "" %>"/>
			<input type="submit" name="search" value="<b:i18n key="SEARCH" />" />
			<%=utils.showErrorsLayer(errors, "blogname")%>
		</form>
	</div>

	<display:table name="blogs" decorator="com.j2biz.blogunity.web.decorator.BlogsTableDecorator" 
			requestURI="listBlogsAdmin.secureaction" pagesize="20" defaultsort="3" defaultorder="descending" sort="list">
		<display:column property="blog" titleKey="BLOG" sortable="true" headerClass="sortable"/>
		<display:column property="founder" titleKey="BLOG_FOUNDER" sortable="true" headerClass="sortable"/>
		<display:column property="decoratedCreateTime" titleKey="BLOG_CREATE_TIME" 
						sortable="true" headerClass="sortable" sortProperty="createTime" />
		<display:column property="decoratedlastModifiedTime" titleKey="BLOG_LAST_MODIFIED" 
						sortable="true" headerClass="sortable" sortProperty="lastModifiedTime"/>
		<display:column property="adminBlogsActions" titleKey="ACTIONS" />
	</display:table>

</div>

<%@ include file="../include/footer.jsp" %>
	
