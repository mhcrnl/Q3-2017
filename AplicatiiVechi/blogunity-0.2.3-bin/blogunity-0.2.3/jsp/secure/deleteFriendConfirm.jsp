<%@ include file="../include/header.jsp" %>
<% User u = (User) request.getAttribute("requestedFriend"); %>

<div id="contentLayer">
	<div class="title"><b:i18n key="DELETE_FRIEND_TITLE"/></div>
	<div class="description">
		<b:i18n key="DELETE_FRIEND_DESC"/>
	</div>
	<% 
	String[] params = new String[]{ utils.renderUser(u, request)}; 
	request.setAttribute("params", params);
	%>
	<b:i18n key="DELETE_FRIEND_TEXT" params="params" /><br>
	<a href="<%=ctx%>/deleteFriendExec.secureaction?id=<%=u.getId()%>" class="naviLink"><b:i18n key="YES"/></a>
	&nbsp;&nbsp;
	<a href="<%=utils.peekNextToLastActionFromStack(request)%>" class="naviLink"><b:i18n key="NO"/></a>	

</div>
<%@ include file="../include/footer.jsp" %>