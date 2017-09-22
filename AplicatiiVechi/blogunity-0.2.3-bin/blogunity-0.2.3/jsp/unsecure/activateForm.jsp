<%@ include file="../include/header.jsp" %>
	
<div id="contentLayer">
	<div class="title"><b:i18n key="ACTIVATE"/></div>

	<br/><br/>
	
	<% if (user == null){ %>
	<div id="formLayer">
	<form method="post" action="<%=ctx%>/activate.action">
		<div class="textRequired"><b:i18n key="USER_NICKNAME"/></div>
		<input type="text" name="name" size="20" maxlength="30" />
		
		<br/>
		<div class="textRequired"><b:i18n key="USER_ACTIVATION_CODE"/></div>	
		<input type="text" name="activationCode" size="20" maxlength="50" />	
		<br/>
		<input type="submit" name="activate" value="<b:i18n key="ACTIVATE_BUTTON"/>" />
	</form>
	</div>
	<%}else{ %>
	<div style="float: right; position: relative; margin: 0px 0px 0px 0px; width: 100px; padding: 0px 0px 0px 0px; text-align: right;">
		<a href="<%=ctx%>/logout.action" class="naviLink" style="color: #FFFFFF;"><b:i18n key="LOGOUT"/></a>
	</div>
	<%}%>

</div>		

<%@ include file="../include/footer.jsp" %>

