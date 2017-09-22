<%@ include file="../include/header.jsp" %>
<%
Blog b = (Blog) request.getAttribute("blog");
Set entries = (Set) request.getAttribute("entries");
%>
<div id="contentLayer">
	<div class="title"><b:i18n key="LIST_ENTRIES_TITLE"/></div>
	<div class="description">
		<b:i18n key="LIST_ENTRIES_DESC"/>
	</div>

	<a class="naviLink" href="<%=ctx%>/createBlogEntryForm.secureaction?id=<%=b.getId()%>"><b:i18n key="POST_NEW_ENTRY"/></a><br/>
	<display:table name="entries" decorator="com.j2biz.blogunity.web.decorator.EntriesTableDecorator" 
			requestURI="listPrivateBlogEntries.secureaction" pagesize="20" defaultsort="3" defaultorder="descending" sort="list">
		<display:column property="entry" titleKey="ENTRY"/>
		<display:column property="author" titleKey="ENTRY_AUTHOR" sortable="true" headerClass="sortable"/>
		<display:column property="decoratedTime" titleKey="ENTRY_CREATE_TIME" sortable="true" headerClass="sortable" sortProperty="createTime"/>
		<display:column property="type" titleKey="ENTRY_TYPE" sortable="true" headerClass="sortable"/>
		<display:column property="actions" titleKey="ACTIONS" />
	</display:table>

</div>

<%@ include file="../include/footer.jsp" %>
	
