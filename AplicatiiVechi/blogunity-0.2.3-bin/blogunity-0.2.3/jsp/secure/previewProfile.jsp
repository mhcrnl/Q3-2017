<%@ include file="../include/header.jsp" %>
<div id="contentLayer">
	<div class="title"><b:i18n key="PREVIEW_PROFILE_TITLE"/></div>
	<div class="description">
		<b:i18n key="PREVIEW_PROFILE_DESC"/>
	</div>
	<iframe src="<%=ctx%>/users/<%=user.getNickname() %>" 
				width="90%" height="600" name="profileFrame" frameborder="0" marginheight="0" marginwidth="0">
		<p>You browser can not show IFrames!</p>
	</iframe>

</div>
<%@ include file="../include/footer.jsp" %>
	
