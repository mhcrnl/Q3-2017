<%@ include file="../include/header.jsp" %>
<%
Blog b = (Blog) request.getAttribute("blog");
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="ENTRY_DELETED_TITLE"/></div>
	<div class="description">
		<b:i18n key="ENTRY_DELETED_DESC"/>
	</div>

	<b:i18n key="ENTRY_DELETED_TEXT"/><br/>
	<ul>
		<li><a href="<%=ctx%>/blogs/<%=b.getUrlName()%>" class="navLink"><b:i18n key="ENTRY_DELETED_LINK1"/></a><br/></li>
		<li><a href="<%=ctx%>/listPrivateBlogEntries.secureaction?id=<%=b.getId()%>" class="navLink"><b:i18n key="ENTRY_DELETED_LINK2"/></a><br/></li>
	</ul>

</div>
<%@ include file="../include/footer.jsp" %>
	