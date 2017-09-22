<%@ include file="../include/header.jsp" %>
<%
FormErrorList errors = (FormErrorList) request.getAttribute("errors");
String newFriend = (String) request.getAttribute("newFriend");
Set friends = (Set) request.getAttribute("friends");
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="FRIENDS_TITLE"/></div>
	<div class="description">
		<b:i18n key="FRIENDS_DESC"/>
	</div>

	<div id="formLayer">
			<form method="post" action="<%=ctx%>/addFriend.secureaction">
				<!-- ############# NICKNAME ###############  -->
				<%if (errors!=null && errors.containsErrorsForKey("nickname")){ %>
				<div class="textError" onclick="toggle('errorLayerNickname')"><b:i18n key="USER_NICKNAME"/>:</div> 
				<%}else{ %>
				<div class="textRequired"><b:i18n key="USER_NICKNAME"/>:</div> 
				<%}%>
				<input type="text" name="nickname" size="25" maxlength="10" value="<%= (newFriend != null)? newFriend : "" %>"/>
				<input type="submit" name="add friend" value="<b:i18n key="ADD_FRIEND_BUTTON"/>" />
				<%=utils.showErrorsLayer(errors, "nickname")%>
			</form>
		</div>

		<display:table name="friends" decorator="com.j2biz.blogunity.web.decorator.UsersTableDecorator" 
				requestURI="friendsList.secureaction" pagesize="20" defaultsort="1" defaultorder="descending" sort="list">
			<display:column property="nickname" titleKey="USER_NICKNAME" sortable="true" headerClass="sortable"/>
			<display:column property="firstname" titleKey="USER_FIRSTNAME" sortable="true" headerClass="sortable"/>
			<display:column property="lastname" titleKey="USER_LASTNAME" sortable="true" headerClass="sortable"/>
			<display:column property="actions" titleKey="ACTIONS" />
		</display:table>

</div>

<%@ include file="../include/footer.jsp" %>
	