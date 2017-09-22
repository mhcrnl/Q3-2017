<%@ include file="../include/header.jsp" %>
<%
Trackback tb = (Trackback) request.getAttribute("requestedTrackback");
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="TRACKBACK_DELETED_TITLE"/></div>
	<div class="description">
		<b:i18n key="TRACKBACK_DELETED_DESC"/>
	</div>

	<b:i18n key="TRACKBACK_DELETED_TEXT"/><br/>
	<ul>
		<li><a href="<%=ctx%>/listTrackbacks.secureaction?id=<%=tb.getEntry().getId()%>" class="navLink"><b:i18n key="TRACKBACK_DELETED_LINK1"/></a><br/></li>
	</ul>

</div>
<%@ include file="../include/footer.jsp" %>
	