<%@ include file="../include/header.jsp" %>
	
<div id="contentLayer">
	<div class="title"><b:i18n key="WELCOME"/></div>

	<br/><br/>
	<div  class="smalltitle"><b:i18n key="LAST_10_POSTS"/></div>
	<div class="text">




	<table border="0" cellpadding="0" cellspacing="1" width="100%">
		<thead>
			<tr bgcolor="#F0F0F0">
				<td><b><b:i18n key="ENTRY"/></b></td>
				<td><b><b:i18n key="ENTRY_AUTHOR"/></b></td>
				<td><b><b:i18n key="BLOG"/></b></td>
				<td><b><b:i18n key="ENTRY_CREATE_TIME"/></b></td>
			</tr>
		</thead>
		<tbody>
		<%
		List last10posts = (List)  request.getAttribute("last10posts");
		if (last10posts.size() == 0){%><tr><td colspan="3">no entries found</td></tr><%}
		Iterator it = last10posts.iterator();
		while(it.hasNext()){
			Entry e = (Entry) it.next();
		%>
		<tr>
			<td><%=utils.renderEntry(e, request)%></td>
			<td><%= utils.renderUser(e.getAuthor(), request)%></td>
			<td><%=utils.renderBlog(e.getBlog(), request) %></td>
			<td><%= utils.formatDateTime(e.getCreateTime()) %></td>
		</tr>
		<%
		}
		%>
		</tbody>	
	</table>
	</div>	

	<br/><br/>

	<table border="0" cellpadding="0" cellspacing="0" width="100%">
		<TBODY>
		<tr>
			<td valign="top">

				<div  class="smalltitle"><b:i18n key="LAST_10_REGISTERED_BLOGS"/></div>
				<div class="text">
				<table border="0" cellpadding="0" cellspacing="1" width="100%">
					<thead>
						<tr bgcolor="#F0F0F0">
							<td><b><b:i18n key="BLOG"/></b></td>
							<td><b><b:i18n key="BLOG_FOUNDER"/></b></td>
							<td><b><b:i18n key="BLOG_CREATE_TIME"/></b></td>
						</tr>
					</thead>
					<tbody>
					<%
					List last10blogs = (List)  request.getAttribute("last10blogs");
					if (last10blogs.size() == 0){%><tr><td colspan="3">no blogs found</td></tr><%}
					Iterator it1 = last10blogs.iterator();
					while(it1.hasNext()){
						Blog  b = (Blog) it1.next();
					%>
					<tr>
						<td><%=utils.renderBlog(b, request)%></td>
						<td> <%=utils.renderUser( b.getFounder(), request) %></td>
						<td><%=utils.formatDateTime( b.getCreateTime()) %></td>
					</tr>
					<%
					}
					 %>	
					</tbody>
				</table>
				</div>	

			</td>
			<td valign="top">

				<div  class="smalltitle"><b:i18n key="LAST_10_REGISTERED_USERS"/></div>
				<div class="text">
				<table border="0" cellpadding="0" cellspacing="1" width="100%">
					<thead>
						<tr bgcolor="#F0F0F0">
							<td><b><b:i18n key="USER_NICKNAME"/></b></td>
							<td><b><b:i18n key="USER_FIRSTNAME"/>, <b:i18n key="USER_LASTNAME"/></b></td>
							<td><b><b:i18n key="USER_REGISTER_TIME"/></b></td>
						</tr>
					</thead>
					<tbody>
					<%
					List last10users = (List)  request.getAttribute("last10users");
					if (last10users.size() == 0){%><tr><td colspan="3">no users found</td></tr><%}
					Iterator it2 = last10users.iterator();
					while(it2.hasNext()){
						User  u = (User) it2.next();
					%>
					<tr>
						<td><%= utils.renderUser(u, request)%></td>
						<td><%=u.getFirstname()%> <%=u.getLastname()%></td>
						<td><%=utils.formatDateTime( u.getRegisterTime()) %></td>
					</tr>
					<%
					}
					 %>	
					</tbody>
				</table>
				</div>	

			</td>
		</tr>
		</TBODY>
	</table>

	<br/><br/>

</div>		

<%@ include file="../include/footer.jsp" %>

