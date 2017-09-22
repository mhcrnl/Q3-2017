<%@ include file="../include/header.jsp" %>
<%
FormErrorList errors = (FormErrorList) request.getAttribute("errors");
Blog blog = (Blog) request.getAttribute("blog");
User newContributor = (User) request.getAttribute("newContributor");

User founder = blog.getFounder();
Set contributors = (Set) request.getAttribute("contributors");
Set waitingUsers = (Set) request.getAttribute("waitingUsers");
%>
<div id="contentLayer">
	<div class="title"><b:i18n key="BLOG_MEMBERS_TITLE" /></div>
	<div class="description">
		<b:i18n key="BLOG_MEMBERS_DESC" />
	</div>

	<%if (user.getId().longValue() == founder.getId().longValue()){%>
	<div id="formLayer">
		<form method="post" action="<%=ctx%>/addContributorToCommunityBlog.secureaction">
			<!-- ############# NICKNAME ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("nickname")){ %>
			<div class="textError" onclick="toggle('errorLayerNickname')"><b:i18n key="USER_NICKNAME" />:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="USER_NICKNAME" />:</div> 
			<%}%>
			<input type="text" name="nickname" size="25" maxlength="10" value="<%= (newContributor != null)? newContributor.getNickname() : "" %>"/>
			<input type="hidden" name="blogid" value="<%=blog.getId()%>" />
			<input type="submit" name="add as contributor" value="add as contributor" />
			<%=utils.showErrorsLayer(errors, "nickname")%>
		</form>
	</div>
	<br/>
	<%}%>	

	<div class="smalltitle"><b:i18n key="BLOG_FOUNDER" /></div>
	<table>
		<thead>
			<tr bgcolor="#F0F0F0">
				<td><b><b:i18n key="USER_NICKNAME" /></b></td>
				<td><b><b:i18n key="USER_FIRSTNAME" /></b></td>
				<td><b><b:i18n key="USER_LASTNAME" /></b></td>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td><%=utils.renderUser(founder, request) %></td>
				<td><%=founder.getFirstname() %></td>
				<td><%=founder.getLastname() %></td>
			</tr>
		</tbody>
	</table>

	<br/><br/>
	<div class="smalltitle"><b:i18n key="USER_CONTRIBUTORS" /></div>
	<display:table name="contributors" decorator="com.j2biz.blogunity.web.decorator.CommunityMembersTableDecorator" 
			requestURI="listCommunityBlogMembers.secureaction" pagesize="20" defaultsort="1" id="contributorsTable" defaultorder="descending" sort="list">
		<display:column property="nickname" titleKey="USER_NICKNAME" sortable="true" headerClass="sortable"/>
		<display:column property="firstname" titleKey="USER_FIRSTNAME" sortable="true" headerClass="sortable"/>
		<display:column property="lastname" titleKey="USER_LASTNAME" sortable="true" headerClass="sortable"/>
		<%if (user.getId().longValue() == founder.getId().longValue()){%>
		<display:column property="contributorsActions" titleKey="ACTIONS" />
		<%}%>
	</display:table>




	<%if (user.getId().longValue() == founder.getId().longValue() 
			&& blog.getCommunityType() == Blog.PRIVATE_COMMUNTIY){%>
	<br/><br/>
	<div class="smalltitle"><b:i18n key="USER_WAITING" /></div>
	<display:table name="waitingUsers" decorator="com.j2biz.blogunity.web.decorator.CommunityMembersTableDecorator" 
			requestURI="listCommunityBlogMembers.secureaction" pagesize="20" defaultsort="1" id="waitingTable" defaultorder="descending" sort="list">
		<display:column property="nickname" titleKey="USER_NICKNAME" sortable="true" headerClass="sortable"/>
		<display:column property="firstname" titleKey="USER_FIRSTNAME" sortable="true" headerClass="sortable"/>
		<display:column property="lastname" titleKey="USER_LASTNAME" sortable="true" headerClass="sortable"/>
		<display:column property="waitingUsersActions" titleKey="ACTIONS" />
	</display:table>
	<%}%>

</div>

<%@ include file="../include/footer.jsp" %>
	
