<%@ include file="../include/header.jsp" %>
	
<div id="contentLayer">
	<div class="title"><b:i18n key="LOGIN"/></div>

	<br/><br/>
	
	<% if (user == null){ %>
	<div id="formLayer">
	<form method="post" action="<%=ctx%>/login.action">
		<div class="textRequired"><b:i18n key="USER_NICKNAME"/></div>
		<input type="text" name="name" size="20" maxlength="30" />
		
		<br/>
		<div class="textRequired"><b:i18n key="USER_PASSWORD"/></div>	
		<input type="password" name="password" size="20" maxlength="30" />	
		<br/>
		<input type="submit" name="login" value="<b:i18n key="LOGIN"/>" />
	</form>
	</div>
	<%}else{ %>
	<div style="float: right; position: relative; margin: 0px 0px 0px 0px; width: 100px; padding: 0px 0px 0px 0px; text-align: right;">
		<a href="<%=ctx%>/logout.action" class="naviLink" style="color: #FFFFFF;"><b:i18n key="LOGOUT"/></a>
	</div>
	<%}%>
	
	<br/><br/>
	
	<a href="<%=ctx%>/forgot.action"><b:i18n key="FORGOT_PASSWORD_LINK"/></a>

</div>		

<%@ include file="../include/footer.jsp" %>

