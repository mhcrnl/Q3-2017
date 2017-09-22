<%@ include file="../include/header.jsp" %>
<% 
Set blogs = (Set) request.getAttribute("blogs");
Set waitingBlogs = (Set) request.getAttribute("waitingBlogs");
FormErrorList errors = (FormErrorList) request.getAttribute("errors"); 
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="JOINED_BLOGS_TITLE" /></div>
	<div class="description">
		<b:i18n key="JOINED_BLOGS_DESC" />
	</div>

	<div id="formLayer">
		<form method="post" action="<%=ctx%>/communityBlogAddExec.secureaction">
			<!-- ############# CONTRIBUTE TO BLOG ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("blogname")){ %>
			<div class="textError" onclick="toggle('errorLayerBlogname')"><b:i18n key="BLOG" />:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="BLOG" />:</div> 
			<%}%>
			<input type="text" name="blogname" size="25" maxlength="50"/><input type="submit" name="contribute" value="<b:i18n key="CONTRIBUTE_BLOG_BUTTON" />"><br />
			<%=utils.showErrorsLayer(errors, "blogname")%>			
		</form>
	</div>

	<%
	String successMsg = (String) request.getAttribute("successMsg");
	if (org.apache.commons.lang.StringUtils.isNotEmpty(successMsg)){
		%><div class="text"><i><%= successMsg%></i></div><%
	}
	%>

	
	<br>
	<div class="smalltitle"><b:i18n key="CONTRIBUTED_BLOGS_TITLE" /></div>
	<display:table name="blogs" decorator="com.j2biz.blogunity.web.decorator.BlogsTableDecorator" 
			requestURI="communityBlogs.secureaction" pagesize="20" id="joinedTable" defaultsort="3" defaultorder="descending" sort="list">
		<display:column property="blog" titleKey="BLOG" sortable="true" headerClass="sortable"/>
		<display:column property="founder" titleKey="BLOG_FOUNDER" sortable="true" headerClass="sortable"/>
		<display:column property="decoratedCreateTime" titleKey="BLOG_CREATE_TIME" 
						sortable="true" headerClass="sortable" sortProperty="createTime"/>
		<display:column property="decoratedLastModifiedTime" titleKey="BLOG_LAST_MODIFIED" 
						sortable="true" headerClass="sortable" sortProperty="lastModifiedTime"/>
		<display:column property="joinedBlogsActions" titleKey="ACTIONS" />
	</display:table>


	<br>
	<div class="smalltitle"><b:i18n key="WAITING_BLOGS_TITLE" /></div>
	<display:table name="waitingBlogs" decorator="com.j2biz.blogunity.web.decorator.BlogsTableDecorator" 
			requestURI="communityBlogs.secureaction" pagesize="20" id="waitingTable" defaultsort="3" defaultorder="descending" sort="list">
		<display:column property="blog" titleKey="BLOG" sortable="true" headerClass="sortable"/>
		<display:column property="founder" titleKey="BLOG_FOUNDER" sortable="true" headerClass="sortable"/>
		<display:column property="decoratedCreateTime" titleKey="BLOG_CREATE_TIME" 
						sortable="true" headerClass="sortable" sortProperty="createTime"/>
		<display:column property="decoratedLastModifiedTime" titleKey="BLOG_LAST_MODIFIED" 
						sortable="true" headerClass="sortable" sortProperty="lastModifiedTime"/>
		<display:column property="waitingBlogsActions" titleKey="ACTIONS" />
	</display:table>




</div>

<%@ include file="../include/footer.jsp" %>
	