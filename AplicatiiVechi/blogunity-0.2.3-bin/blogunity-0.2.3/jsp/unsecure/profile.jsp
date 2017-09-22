<%@ include file="../include/header.jsp" %>
<%
User requestedUser = (User)request.getAttribute("requestedUser");
List friendOfList = (List) request.getAttribute("friendOfList");
%>
	
	<div id="contentLayer">
		<div class="title">
			<% request.setAttribute("param", new String[]{requestedUser.getNickname()}); %>
			<b:i18n key="PROFILE_TITLE" params="param"/>
		</div>
		<div class="description">
			<b:i18n key="PROFILE_DESC"/>
		</div>
		
		<table border="0" height="100%" width="100%">
			<TBODY>
				<tr><td width="150" valign="top">
					<div style="width: 120px;">
						<%
						Set pics = requestedUser.getUserpics();
						if (pics.size() > 0){
							for (Iterator it= pics.iterator(); it.hasNext(); ){
								Userpic pic = (Userpic) it.next();
							%> 
							<img src="<%=request.getContextPath() + pic.getUrl() %>" title="<%= pic.getName()%>" alt="<%= pic.getName()%>"><br/>
							<%
							}
						}else{ %>
						<b:i18n key="NO_USERPICS_FOUND"/>
						<%}%>
					</div>
				</td>
				<td width="90%" valign="top">
					<div class="smalltitle"><b:i18n key="PROFILE_INFO"/></div>
					<TABLE border="0" cellpadding="2" cellspacing="2">
						<tbody>
						<tr>
							<td width="150"><div class="textRequired"><b:i18n key="USER_NICKNAME"/>:</div></td>
							<td><%= requestedUser.getNickname() %></td>
						</tr>
						<tr>
							<td><div class="textRequired"><b:i18n key="USER_FIRSTNAME"/>:</div></td>
							<td><%= requestedUser.getFirstname() %></td>
						</tr>
						<tr>
							<td><div class="textRequired"><b:i18n key="USER_LASTNAME"/>:</div></td>
							<td><%= requestedUser.getLastname() %></td>
						</tr>
						<tr>
							<td><div class="textRequired"><b:i18n key="USER_SEX"/>:</div></td>
							<td><%= (requestedUser.getSex() == User.MALE)? "male" : "female" %></td>
						</tr>
						<%if (requestedUser.getUserSettings().getShowEmail()){%>
						<tr>
							<td><div class="textRequired"><b:i18n key="USER_EMAIL"/>:</div></td>
							<td><a href="mailto:<%= requestedUser.getEmail() %>"><%= requestedUser.getEmail() %></a></td>
						</tr>
						<%}%>
						<tr>
							<td><div class="textRequired"><b:i18n key="USER_LANGUAGE"/>:</div></td>
							<td><%= requestedUser.getLanguage().getDisplayLanguage() %></td>
						</tr>					
						<%if (requestedUser.getBirthday() != null){%>
						<tr>
							<td><div class="textRequired"><b:i18n key="USER_BIRTHDAY"/>:</div></td>
							<td><%= utils.formatDate(requestedUser.getBirthday()) %></td>
						</tr>
						<%}%>
						<%if (requestedUser.getIcq() != null){%>
						<tr>
							<td><div class="textRequired"><b:i18n key="USER_ICQ"/>:</div></td>
							<td><%= requestedUser.getIcq() %></td>
						</tr>
						<%}%>
						<%if (requestedUser.getMsn() != null){%>
						<tr>
							<td><div class="textRequired"><b:i18n key="USER_MSN"/>:</div></td>
							<td><%= requestedUser.getMsn() %></td>
						</tr>
						<%}%>
						<%if (requestedUser.getYahoo() != null){%>
						<tr>
							<td><div class="textRequired"><b:i18n key="USER_YAHOO"/>:</div></td>
							<td><%= requestedUser.getYahoo() %></td>
						</tr>
						<%}%>
						<%if (requestedUser.getJabber() != null){%>
						<tr>
							<td><div class="textRequired"><b:i18n key="USER_JABBER"/>:</div></td>
							<td><%= requestedUser.getJabber() %></td>
						</tr>
						<%}%>
						<%if (requestedUser.getHomepage() != null){%>
						<tr>
							<td><div class="textRequired"><b:i18n key="USER_HOMEPAGE"/>:</div></td>
							<td><a href="<%= requestedUser.getHomepage() %>"><%= requestedUser.getHomepage() %></a></td>
						</tr>
						<%}%>
						<tr>
							<td><div class="textRequired"><b:i18n key="USER_REGISTER_TIME"/>:</div></td>
							<td><%= utils.formatDateTime(requestedUser.getRegisterTime()) %></td>
						</tr>
						<tr>
							<td><div class="textRequired"><b:i18n key="USER_LAST_UPDATE"/>:</div></td>
							<td><%= utils.formatDateTime(requestedUser.getLastUpdateTime()) %></td>
						</tr>
						</tbody>
					</TABLE>

					<!-- ############# BIOGRAPHY #############  -->
					<br/>
					<div class="smalltitle"><b:i18n key="PROFILE_BIO"/></div>
					<TABLE border="0" cellpadding="2" cellspacing="2">
						<tbody>
						<tr>
							<td>
								<% if (requestedUser.getBio() != null) out.println (requestedUser.getBio());
 									else{ %><b:i18n key="NO_BIO_FOUND"/><%}
								 %>
							</td>
						</tr>
						</tbody>
					</TABLE>

					<!-- ############# FRIENDS #############  -->
					<br/>
					<div class="smalltitle"><b:i18n key="PROFILE_FRIENDS"/></div>
					<TABLE border="0" cellpadding="2" cellspacing="2">
						<tbody>
						<tr>
							<td>
								<%
								Set friends = requestedUser.getFriends();
								if (friends.size() > 0){
									Iterator it = friends.iterator();
									while (it.hasNext()){
										User u = (User) it.next();
									    %><%= utils.renderUser(u, request)%>&nbsp;<%
									}
								}else{
									%><b:i18n key="NO_FRIENDS_FOUND"/><%
								}
								%>
							</td>
						</tr>
						</tbody>
					</TABLE>

					<!-- ############# FRIEND OF #############  -->
					<br/>
					<div class="smalltitle"><b:i18n key="PROFILE_FRIEND_OF"/></div>
					<TABLE border="0" cellpadding="2" cellspacing="2">
						<tbody>
						<tr>
							<td>
								<%
								if (friendOfList.size() > 0){
									Iterator itx = friendOfList.iterator();
									while (itx.hasNext()){
										User u = (User) itx.next();
									    %><%= utils.renderUser(u, request)%>&nbsp;<%
									}
								}else{
									%><b:i18n key="NO_FRIEND_OF_FOUND"/><%
								}
								%>
							</td>
						</tr>
						</tbody>
					</TABLE>

					<!-- ############# FOUNDED BLOGS #############  -->
					<br/>
					<div class="smalltitle"><b:i18n key="PROFILE_FOUNDED_BLOGS"/></div>
					<TABLE border="0" cellpadding="2" cellspacing="2">
						<tbody>
						<tr>
							<td>
								<%
								Set foundedBlogs = requestedUser.getFoundedBlogs();
								if (foundedBlogs.size() > 0){
									Iterator it1 = foundedBlogs.iterator();
									while (it1.hasNext()){
										
										Blog b = (Blog) it1.next();
									    %>
						
										<%= utils.renderBlog(b, request) %>&nbsp;
										<%
									}
								}else{
									%><b:i18n key="NO_FOUNDED_BLOGS_FOUND"/><%
								}
								%>
							</td>
						</tr>
						</tbody>
					</TABLE>


					<!-- ############# JOINED BLOGS #############  -->
					<br/>
					<div class="smalltitle"><b:i18n key="PROFILE_JOINED_BLOGS"/></div>
					<TABLE border="0" cellpadding="2" cellspacing="2">
						<tbody>
						<tr>
							<td>
								<%
								Set contributedBlogs = requestedUser.getContributedBlogs();
								if (contributedBlogs.size() > 0){
									Iterator it2 = contributedBlogs.iterator();
									while (it2.hasNext()){
										Blog b = (Blog) it2.next();
									    %>
										<%= utils.renderBlog(b, request) %>&nbsp;
										<%
									}
								}else{
									%><b:i18n key="NO_JOINED_BLOGS_FOUND"/><%
								}
								%>
							</td>
						</tr>
						</tbody>
					</TABLE>

					<!-- ############# FAVORITE BLOGS #############  -->
					<br/>
					<div class="smalltitle"><b:i18n key="PROFILE_FAVORITE_BLOGS"/></div>
					<TABLE border="0" cellpadding="2" cellspacing="2">
						<tbody>
						<tr>
							<td>
								<%
								Set favoriteBlogs = requestedUser.getFavoriteBlogs();
								if (favoriteBlogs.size() > 0){
									Iterator it3 = favoriteBlogs.iterator();
									while (it3.hasNext()){
										
										Blog b = (Blog) it3.next();
									    %>
										<%= utils.renderBlog(b, request) %>&nbsp;
										<%
									}
								}else{
									%><b:i18n key="NO_FAVORITE_BLOGS_FOUND"/><%
								}
								%>
							</td>
						</tr>
						</tbody>
					</TABLE>

					<!-- ############# POSTED COMMENTS #############  -->
					<br/>
					<div class="smalltitle"><b:i18n key="PROFILE_POSTED_COMMENTS"/></div>
					<TABLE border="0" cellpadding="2" cellspacing="2">
						<tbody>
						<tr>
							<td>
								<%
								Set comments = requestedUser.getComments();
								if (comments.size() > 0){
									Iterator it3 = comments.iterator();
									
									while (it3.hasNext()){
										Comment c = (Comment) it3.next();
									    %><%= utils.renderComment(c, request)%><br><%
									
									}
								}else{
									%><b:i18n key="NO_POSTED_COMMENTS_FOUND"/><%
								}
								%>
							</td>
						</tr>
						</tbody>
					</TABLE>


				</td></tr>
			</TBODY>
			
		</table>

		
	</div>	

<%@ include file="../include/footer.jsp" %>








