<%@ include file="../include/header.jsp" %>


	<div id="contentLayer">
		<% request.setAttribute("params", new String[]{user.getNickname()}); %>
		<div class="title"><b:i18n key="MY_PROFILE_TITLE" params="params" /></div>
		<div class="description">
			<b:i18n key="MY_PROFILE_DESC"/>
		</div>
	</div>

<%@ include file="../include/footer.jsp" %>
	