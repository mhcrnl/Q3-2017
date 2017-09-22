<%@ include file="../include/header.jsp" %>
<%
FormErrorList errors = (FormErrorList) request.getAttribute("errors");
String likeNickname = (String) request.getAttribute("likeNickname");
List foundedUsers = (List)request.getAttribute("foundedUsers");
%>
	<div id="contentLayer">
		<div class="title"><b:i18n key="SEARCH_FOR_USER_TITLE"/></div>
		<div class="description">
			<b:i18n key="SEARCH_FOR_USER_DESC"/>
		</div>
		<div id="formLayer">
			<form method="post" action="<%=ctx%>/searchUserExec.action">
				<!-- ############# NICKNAME ###############  -->
				<%if (errors!=null && errors.containsErrorsForKey("nickname")){ %>
				<div class="textError" onclick="toggle('errorLayerNickname')"><b:i18n key="NICKNAME"/>:</div> 
				<%}else{ %>
				<div class="textRequired"><b:i18n key="NICKNAME"/>:</div> 
				<%}%>
				<input type="text" name="nickname" size="25" maxlength="10" value="<%= (likeNickname != null)? likeNickname : "" %>"/>
				<input type="submit" name="search" value="<b:i18n key="SEARCH_BUTTON"/>" />
				<%=utils.showErrorsLayer(errors, "nickname")%>
			</form>
		</div>

		<div class="text">

			<display:table name="foundedUsers" decorator="com.j2biz.blogunity.web.decorator.UsersTableDecorator" 
					requestURI="searchUserExec.action" pagesize="20" defaultsort="1" defaultorder="descending" sort="list">
				<display:column property="nickname" titleKey="USER_NICKNAME" sortable="true" headerClass="sortable"/>
				<display:column property="firstname" titleKey="USER_FIRSTNAME" sortable="true" headerClass="sortable"/>
				<display:column property="lastname" titleKey="USER_LASTNAME" sortable="true" headerClass="sortable"/>
			</display:table>

		</div>
	</div>	
<%@ include file="../include/footer.jsp" %>