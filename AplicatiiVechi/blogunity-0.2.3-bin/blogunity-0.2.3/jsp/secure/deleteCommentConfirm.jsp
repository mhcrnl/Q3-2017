<%@ include file="../include/header.jsp" %>
<% 
Comment comment = (Comment) request.getAttribute("requestedComment"); 
Entry e = comment.getCommentedEntry();
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="DELETE_COMMENT_TITLE"/></div>
	<div class="description">
		<b:i18n key="DELETE_COMMENT_DESC"/>
	</div>

	<%
	String[] params = new String[]{ comment.getTitle() };
	request.setAttribute("params", params);
	%>
	<b:i18n key="DELETE_COMMENT_TEXT" params="params" /><br>
	<a href="<%=ctx%>/deleteCommentExec.secureaction?id=<%=comment.getId()%>" class="naviLink"><b:i18n key="YES"/></a>
	&nbsp;&nbsp;
	<a href="<%= utils.peekNextToLastActionFromStack(request)%>" class="naviLink"><b:i18n key="NO"/></a>

</div>
<%@ include file="../include/footer.jsp" %>