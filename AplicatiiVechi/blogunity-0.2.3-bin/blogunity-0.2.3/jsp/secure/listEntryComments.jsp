<%@ include file="../include/header.jsp" %>

<%
Entry e = (Entry) request.getAttribute("entry");
List comments = (List) request.getAttribute("comments");
%>
<div id="contentLayer">
	<div class="title"><b:i18n key="ENTRY_COMMENTS_TITLE"/></div>
	<div class="description">
		<b:i18n key="ENTRY_COMMENTS_DESC"/>
	</div>
	<display:table name="comments" decorator="com.j2biz.blogunity.web.decorator.CommentsTableDecorator" 
			requestURI="foundedBlogsList.secureaction" pagesize="20" defaultsort="3" defaultorder="descending" sort="list">
		<display:column property="comment" titleKey="COMMENT" sortable="true" headerClass="sortable"/>
		<display:column property="author" titleKey="COMMENT_AUTHOR" sortable="true" headerClass="sortable"/>
		<display:column property="decoratedCreateTime" titleKey="COMMENT_CREATE_TIME" 
						sortable="true" headerClass="sortable" sortProperty="createTime"/>
		<display:column property="actions" titleKey="ACTIONS" />
	</display:table>

</div>


<%@ include file="../include/footer.jsp" %>
	
