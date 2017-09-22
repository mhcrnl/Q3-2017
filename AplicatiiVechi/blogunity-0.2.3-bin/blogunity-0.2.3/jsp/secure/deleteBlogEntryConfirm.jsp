<%@ include file="../include/header.jsp" %>
<% Entry e = (Entry) request.getAttribute("requestedBlogEntry"); %>

<div id="contentLayer">
	<div class="title"><b:i18n key="DELETE_ENTRY_TITLE"/></div>
	<div class="description">
		<b:i18n key="DELETE_ENTRY_DESC"/>
	</div>
	
	<%
	String[] params = new String[]{ utils.renderEntry(e, request) };
	request.setAttribute("params", params);
	%>
	<b:i18n key="DELETE_ENTRY_TEXT" params="params" /><br/>
	<a href="<%=ctx%>/deleteBlogEntryExec.secureaction?id=<%=e.getId()%>" class="naviLink"><b:i18n key="YES"/></a>
	&nbsp;&nbsp;
	<a href="<%=utils.peekNextToLastActionFromStack(request)%>" class="naviLink"><b:i18n key="NO"/></a>

</div>

<%@ include file="../include/footer.jsp" %>