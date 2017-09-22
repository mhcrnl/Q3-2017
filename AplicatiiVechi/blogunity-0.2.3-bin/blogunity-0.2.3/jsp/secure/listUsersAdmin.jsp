<%@ include file="../include/header.jsp" %>
<%
FormErrorList errors = (FormErrorList) request.getAttribute("errors");
List users = (List) request.getAttribute("users");
String searchUser = (String) request.getAttribute("searchUser");
%>
<div id="contentLayer">
	<div class="title"><b:i18n key="SYSTEM_USERS_TITLE" /></div>
	<div class="description">
		<b:i18n key="SYSTEM_USERS_DESC" />
	</div>

	<div id="formLayer">
		<form method="post" action="<%=ctx%>/listUsersAdmin.secureaction">
			<!-- ############# NICKNAME ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("nickname")){ %>
			<div class="textError" onclick="toggle('errorLayerNickname')"><b:i18n key="SEARCH.USER" />:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SEARCH.USER" />:</div> 
			<%}%>
			<input type="text" name="nickname" size="25" maxlength="10" value="<%= (searchUser != null)? searchUser : "" %>"/>
			<input type="submit" name="search" value="<b:i18n key="SEARCH" />" />
			<%=utils.showErrorsLayer(errors, "nickname")%>
		</form>
	</div>

	<display:table name="users" decorator="com.j2biz.blogunity.web.decorator.UsersTableDecorator" 
			requestURI="listUsersAdmin.secureaction" pagesize="20" defaultsort="4" defaultorder="descending" sort="list">
		<display:column property="nickname" titleKey="USER_NICKNAME" sortable="true" headerClass="sortable"/>
		<display:column property="firstname" titleKey="USER_FIRSTNAME" sortable="true" headerClass="sortable"/>
		<display:column property="lastname" titleKey="USER_LASTNAME" sortable="true" headerClass="sortable"/>
		<display:column property="decoratedRegisterTime" titleKey="USER_REGISTER_TIME" 
						sortable="true" headerClass="sortable"  sortProperty="registerTime"/>
		<display:column property="adminActions" titleKey="ACTIONS" />
	</display:table>

</div>

<%@ include file="../include/footer.jsp" %>
	
