<%@ include file="../include/header.jsp" %>
<%
FormErrorList errors = (FormErrorList) request.getAttribute("errors");
String likeBlogname = (String) request.getAttribute("likeBlogname");
List foundedBlogs = (List)request.getAttribute("foundedBlogs");
%>
	<div id="contentLayer">
		<div class="title"><b:i18n key="SEARCH_FOR_BLOG_TITLE"/></div>
		<div class="description">
			<b:i18n key="SEARCH_FOR_BLOG_DESC"/>
		</div>
		<div id="formLayer">
			<form method="post" action="<%=ctx%>/searchBlogExec.action">
				<!-- ############# BLOGNAME ###############  -->
				<%if (errors!=null && errors.containsErrorsForKey("blogname")){ %>
				<div class="textError" onclick="toggle('errorLayerBlogname')"><b:i18n key="BLOGNAME"/>:</div> 
				<%}else{ %>
				<div class="textRequired"><b:i18n key="BLOGNAME"/>:</div> 
				<%}%>
				<input type="text" name="blogname" size="25" maxlength="10" value="<%= (likeBlogname != null)? likeBlogname : "" %>"/>
				<input type="submit" name="search" value="<b:i18n key="SEARCH_BUTTON"/>" />
				<%=utils.showErrorsLayer(errors, "blogname")%>
			</form>
		</div>

		<div class="text">

			<display:table name="foundedBlogs" decorator="com.j2biz.blogunity.web.decorator.BlogsTableDecorator" 
					requestURI="searchBlogExec.action" pagesize="20" defaultsort="1" defaultorder="descending" sort="list">
				<display:column property="blog" titleKey="BLOG" sortable="true" headerClass="sortable"/>
				<display:column property="founder" titleKey="BLOG_FOUNDER" sortable="true" headerClass="sortable"/>
				<display:column property="decoratedCreateTime" titleKey="BLOG_CREATE_TIME" 
								sortable="true" headerClass="sortable" sortProperty="createTime"/>
			</display:table>

		</div>
	</div>	
<%@ include file="../include/footer.jsp" %>