<%@ include file="../include/header.jsp" %>
<% 
Blog b = (Blog) request.getAttribute("requestedBlog");
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="EDIT_BLOG_TITLE" /></div>
	<div class="description">
		<b:i18n key="EDIT_BLOG_DESC" />
	</div>

	<div id="formLayer">
	<form action="<%=ctx%>/editBlogExec.secureaction" method="post">

		<!-- ############# URL-NAME ###############  -->
		<div class="textRequired"><b:i18n key="BLOG_URLNAME" />:</div> 
		<%= b.getUrlName() %><br/><br/>

		<!-- ############# FULL-NAME ###############  -->		
		<div class="textRequired"><b:i18n key="BLOG_FULLNAME" />:</div> 
		<INPUT type="text" name="fullname" size="25" maxlength="50"  value="<%= (b.getFullName() != null)? b.getFullName() : "" %>"><br />

		<div class="textRequired"><b:i18n key="BLOG_DESCRIPTION" />:</div> 
		<TEXTAREA name="description" cols="45" rows="10"><%= ( b.getDescription() != null)? b.getDescription(): ""%></TEXTAREA><br/>

		<div class="textRequired"><b:i18n key="BLOG_KEYWORDS" />:</div> 
		<TEXTAREA name="keywords" cols="45" rows="10"><%= (b.getKeywords() != null)? b.getKeywords() : "" %></TEXTAREA><br/>

		<% if (b.getType() == Blog.COMMUNITY_BLOG){%>
			<div class="textRequired"><b:i18n key="BLOG_COMMUNITY_TYPE" />:</div>
			<select size="1" name="communityType">
				<OPTION value="<%= Blog.PUBLIC_COMMUNTIY %>" <%= (b.getCommunityType()==Blog.PUBLIC_COMMUNTIY)? "selected" : "" %>>public</OPTION>
				<OPTION value="<%= Blog.PRIVATE_COMMUNTIY%>" <%= (b.getCommunityType()==Blog.PRIVATE_COMMUNTIY)? "selected" : "" %>>private</OPTION>
			</select><br/>
		<%}%>

		<input type="hidden" name="id" value="<%=b.getId() %>">
		<input type="submit" name="edit" value="<b:i18n key="EDIT_BLOG_BUTTON" />">

		
	</form>
	</div>

	<table width="100%" cellpadding="5" cellspacing="5">
		<TBODY>
		<tr>
		<td width="50%" valign="top">
			<a name="categories">&nbsp;</a>
			<div class="smalltitle"><b:i18n key="EDIT_BLOG_CATEGORIES_TITLE" /></div>
			<TABLE width="100%" cellpadding="2" cellspacing="2">
			<TBODY>
				<tr align="right"><td colspan="3">
						<a href="<%=ctx%>/categoryForm.secureaction?blogId=<%=b.getId()%>"><b:i18n key="CREATE" /></a>
				</td></tr>
				<tr bgcolor="#F0F0F0">
					<td width="80%"><b><b:i18n key="CATEGORY_NAME" /></b></td>
					<td><b><b:i18n key="CATEGORY_TYPE" /></b></td>
					<td><b><b:i18n key="ACTIONS" /></b></td>
				</tr>
				<% 
				Set categories = b.getCategories();
				if (categories.size() > 0){
					Iterator it = categories.iterator();
					while (it.hasNext()){
						Category cat = (Category) it.next();
					%>
					<tr>
						<td><%=cat.getName() %></td>
						<td><%= (cat.getType() == Category.LOCAL)? "local" : "global"%></td>
						<% if (cat.getType() == Category.LOCAL){ %>
							<td align="center">
								<nobr>
								<a href="<%=ctx%>/categoryForm.secureaction?blogId=<%=b.getId()%>&catId=<%=cat.getId() %>"><b:i18n key="EDIT" /></a>
								&nbsp;|&nbsp;
								<a href="<%=ctx%>/categoryDelete.secureaction?blogId=<%=b.getId()%>&catId=<%=cat.getId() %>"><b:i18n key="DELETE" /></a>
								</nobr>
							</td>
						<%}else{%>
							<td>&nbsp;</td>
						<%}%>
					</tr>
					<%
					}
				}
				else{%> 
					<tr><td colspan="3"><b:i18n key="NO_CATEGORIES_FOUND" /></td></tr>
				<%}
				%>
				<tr align="right"><td colspan="3">
					<a href="<%=ctx%>/categoryForm.secureaction?blogId=<%=b.getId()%>"><b:i18n key="CREATE" /></a>
				</td></tr>
			</TBODY>
			</TABLE>
		</td>
		<td width="50%" valign="top">
			<a name="links">&nbsp;</a>
			<div class="smalltitle"><b:i18n key="EDIT_BLOG_LINKS_TITLE" /></div>
			<TABLE width="100%" cellpadding="2" cellspacing="2">
			<TBODY>
				<tr align="right"><td colspan="4">
					<a href="<%=ctx%>/linkForm.secureaction?blogId=<%=b.getId()%>"><b:i18n key="CREATE" /></a>
				</td></tr>
				<tr bgcolor="#F0F0F0">
					<td width="80%"><b><b:i18n key="LINK_NAME" /></b></td>
					<td><b><b:i18n key="LINK_URL" /></b></td>
					<!--   <td>order</td> -->
					<td><b><b:i18n key="ACTIONS" /></b></td>
				</tr>
				<% 
				Set links = b.getLinks();
				if (links.size() > 0){
					Iterator itx = links.iterator();
					while (itx.hasNext()){
						Link link = (Link) itx.next();
					%>
					<tr>
						<td><%=link.getName() %></td>
						<td><a href="<%=link.getUrl() %>" target="_blank"><%=link.getUrl() %></a></td>
						<!--  <td><%=link.getOrder() %></td> -->
						<td align="center">
							<nobr>
							<a href="<%=ctx%>/linkForm.secureaction?blogId=<%=b.getId()%>&linkId=<%=link.getId() %>"><b:i18n key="EDIT" /></a>
							&nbsp;|&nbsp;
							<a href="<%=ctx%>/linkDelete.secureaction?blogId=<%=b.getId()%>&linkId=<%=link.getId() %>"><b:i18n key="DELETE" /></a>
							</nobr>
						</td>
					</tr>
					<%
					}
				}
				else{%> 
					<tr><td colspan="4"><b:i18n key="NO_LINKS_FOUND" /></td></tr>
				<%}
				%>
				<tr align="right"><td colspan="4">
					<a href="<%=ctx%>/linkForm.secureaction?blogId=<%=b.getId()%>"><b:i18n key="CREATE" /></a>
				</td></tr>
			</TBODY>
			</TABLE>
		</td>
		</tr>
		</TBODY>
		</table>

</div>

<%@ include file="../include/footer.jsp" %>
	