<%@ include file="../include/header.jsp" %>
<% Trackback tb = (Trackback) request.getAttribute("requestedTrackback"); %>

<div id="contentLayer">
	<div class="title"><b:i18n key="DELETE_TRACKBACK_TITLE" /></div>
	<div class="description">
		<b:i18n key="DELETE_TRACKBACK_DESC" />
	</div>
	<%
	String[] params = new String[]{utils.renderTrackback(tb, request)};
	request.setAttribute("params", params);
	%>
	<b:i18n key="DELETE_TRACKBACK_TEXT" params="params"/><br>
	<a href="<%=ctx%>/deleteTrackbackExec.secureaction?id=<%=tb.getId()%>" class="naviLink"><b:i18n key="YES" /></a>
	&nbsp;&nbsp;
	<a href="<%=utils.peekNextToLastActionFromStack(request)%>" class="naviLink"><b:i18n key="NO" /></a>

</div>
<%@ include file="../include/footer.jsp" %>