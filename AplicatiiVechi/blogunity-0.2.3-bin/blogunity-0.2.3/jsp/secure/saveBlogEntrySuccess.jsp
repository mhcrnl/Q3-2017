<%@ include file="../include/header.jsp" %>
<%
Entry e = (Entry) request.getAttribute("savedEntry");
%>
<div id="contentLayer">
	<div class="title"><b:i18n key="ENTRY_CREATED_TITLE"/></div>
	<div class="description">
		<b:i18n key="ENTRY_CREATED_DESC"/>
	</div>

	<b:i18n key="ENTRY_CREATED_TEXT"/><br/>
	<ul>
		<% if (e.getType() != Entry.DRAFT){ %>
		<li><a href="<%=base%>/blogs/<%=e.getBlog().getUrlName()%><%=e.getPermalink()%>" class="navLink"><b:i18n key="ENTRY_CREATED_LINK1"/></a><br/></li>
		<%} %>
		<li><a href="<%=ctx%>/createBlogEntryForm.secureaction?id=<%=e.getBlog().getId()%>" class="navLink"><b:i18n key="ENTRY_CREATED_LINK2"/></a><br/></li>
		<li><a href="<%=ctx%>/listPrivateBlogEntries.secureaction?id=<%=e.getBlog().getId()%>" class="navLink"><b:i18n key="ENTRY_CREATED_LINK3"/></a><br/></li>
	</ul>

	

</div>

<%@ include file="../include/footer.jsp" %>
	
