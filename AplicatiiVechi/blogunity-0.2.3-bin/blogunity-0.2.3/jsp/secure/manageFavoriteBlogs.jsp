<%@ include file="../include/header.jsp" %>
<% 
Set blogs = (Set) request.getAttribute("blogs");
FormErrorList errors = (FormErrorList) request.getAttribute("errors"); 
%>
<div id="contentLayer">
	<div class="title"><b:i18n key="FAVORITE_BLOGS_TITLE" /></div>
	<div class="description">
		<b:i18n key="FAVORITE_BLOGS_DESC" />
	</div>


	<div id="formLayer">
		<form method="post" action="<%=ctx%>/favoriteBlogAddExec.secureaction">
			<!-- ############# ADD FAVORITES ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("blogname")){ %>
			<div class="textError" onclick="toggle('errorLayerBlogname')"><b:i18n key="ADD_BLOG_TO_FAVORITES" />:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="ADD_BLOG_TO_FAVORITES" />:</div> 
			<%}%>
			<input type="text" name="blogname" size="25" maxlength="50"/><input type="submit" name="add" value="<b:i18n key="ADD"/>"><br />
			<%=utils.showErrorsLayer(errors, "blogname")%>			
		</form>
	</div>
	<br>

	<display:table name="blogs" decorator="com.j2biz.blogunity.web.decorator.BlogsTableDecorator" 
			requestURI="manageFavoriteBlogs.secureaction" pagesize="20" defaultsort="3" defaultorder="descending" sort="list">
		<display:column property="blog" titleKey="BLOG" sortable="true" headerClass="sortable"/>
		<display:column property="founder" titleKey="BLOG_FOUNDER" sortable="true" headerClass="sortable"/>
		<display:column property="decoratedCreateTime" titleKey="BLOG_CREATE_TIME" 
						sortable="true" headerClass="sortable" sortProperty="createTime"/>
		<display:column property="decoratedLastModifiedTime" titleKey="BLOG_LAST_MODIFIED" 
						sortable="true" headerClass="sortable" sortProperty="lastModifiedTime"/>
		<display:column property="favoriteBlogsActions" titleKey="ACTIONS" />
	</display:table>

</div>	


<%@ include file="../include/footer.jsp" %>
	
