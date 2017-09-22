<%@ include file="../include/header.jsp" %>
<% 
FormErrorList errors = (FormErrorList) request.getAttribute("errors"); 
Blog newBlog = (Blog) request.getAttribute("newBlog");
java.io.File[] themeDirs = (java.io.File[]) request.getAttribute("themeDirs");
if (newBlog == null) newBlog = new Blog();
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="CREATE_BLOG_TITLE" /></div>
	<div class="description">
		<b:i18n key="CREATE_BLOG_DESC" />
	</div>

	<div id="formLayer">
	<form action="<%=ctx%>/createBlogExec.secureaction" method="post">

		<!-- ############# URL-NAME ###############  -->
		<%if (errors!=null && errors.containsErrorsForKey("urlname")){ %>
		<div class="textError" onclick="toggle('errorLayerUrlname')"><b:i18n key="BLOG_URLNAME" />:</div> 
		<%}else{ %>
		<div class="textRequired"><b:i18n key="BLOG_URLNAME" />:</div> 
		<%}%>
		<INPUT type="text" name="urlname" size="25" maxlength="30"  value="<%= (newBlog.getUrlName() != null)? newBlog.getUrlName() : "" %>"><br />
		<%=utils.showErrorsLayer(errors, "urlname")%>		

		<!-- ############# FULL-NAME ###############  -->		
		<div class="textRequired"><b:i18n key="BLOG_FULLNAME" />:</div> 
		<INPUT type="text" name="fullname" size="25" maxlength="50"  value="<%= (newBlog.getFullName() != null)? newBlog.getFullName() : "" %>"><br />


		<!-- ############# DESCRIPTION ###############  -->
		<%if (errors!=null && errors.containsErrorsForKey("description")){ %>
		<div class="textError" onclick="toggle('errorLayerDescription')"><b:i18n key="BLOG_DESCRIPTION" />:</div> 
		<%}else{ %>
		<div class="textRequired"><b:i18n key="BLOG_DESCRIPTION" />:</div>
		<%}%>
		<TEXTAREA name="description" cols="45" rows="10"><%= (newBlog.getDescription() != null)? newBlog.getDescription() : "" %></TEXTAREA><br />
		<%=utils.showErrorsLayer(errors, "description")%>	

		<!-- ############# KEYWORDS ###############  -->
		<div class="textNormal"><b:i18n key="BLOG_KEYWORDS" />:</div>
		<TEXTAREA name="keywords" cols="45" rows="10"><%= (newBlog.getKeywords() != null)? newBlog.getKeywords() : "" %></TEXTAREA><br/>

		<!-- ############# BLOG THEME ###############  -->
		<%if (errors!=null && errors.containsErrorsForKey("themeDir")){ %>
		<div class="textError" onclick="toggle('errorLayerThemeDir')"><b:i18n key="BLOG_THEME" />:</div> 
		<%}else{ %>
		<div class="textRequired"><b:i18n key="BLOG_THEME" />:</div>
		<%}%>
		<select size="1" name="themeDir">
			<%for (int i=0; i < themeDirs.length; i++){%>
			<option value="<%=themeDirs[i].getName()%>"><%=themeDirs[i].getName()%></option>
			<%}%>
		</select><br/>
		<%=utils.showErrorsLayer(errors, "themeDir")%>


		<!-- ############# BLOG TYPE ###############  -->
		<div class="textRequired"><b:i18n key="BLOG_TYPE" />:</div>
		<select size="1" name="type">
			<%if (user.getUserSettings().getIndividualBlogsPerUser() == -1 || user.getUserSettings().getIndividualBlogsPerUser() > user.getNumberOfIndividualBlogsFounded() ){%>
				<OPTION value="<%=Blog.INDIVIDUAL_BLOG%>" <%=(newBlog.getType() == Blog.INDIVIDUAL_BLOG)? "selected" : ""%>>individual</OPTION>
			<%}%>
			<%if (user.getUserSettings().getCommunityBlogsPerUser() == -1 || user.getUserSettings().getCommunityBlogsPerUser() > user.getNumberOfCommunityBlogsFounded() ){%>
			<OPTION value="<%=Blog.COMMUNITY_BLOG%>" <%=(newBlog.getType() == Blog.COMMUNITY_BLOG)? "selected" : ""%>>community</OPTION>
			<%}%>
		</select><br/>

		<%if (user.getUserSettings().getCommunityBlogsPerUser() == -1 || user.getUserSettings().getCommunityBlogsPerUser() > user.getNumberOfCommunityBlogsFounded() ){%>
		<!-- ############# COMMUNITY TYPE ###############  -->
		<div class="textRequired"><b:i18n key="BLOG_COMMUNITY_TYPE" />:</div>
		<select size="1" name="communityType">

			<OPTION value="<%=Blog.PUBLIC_COMMUNTIY%>" <%=(newBlog.getCommunityType() == Blog.PUBLIC_COMMUNTIY)? "selected" : ""%>>public</OPTION>
			<OPTION value="<%=Blog.PRIVATE_COMMUNTIY%>" <%=(newBlog.getCommunityType() == Blog.PRIVATE_COMMUNTIY)? "selected" : ""%>>private</OPTION>
		</select><br/>
		<%}%>

		<input type="submit" name="create" value="<b:i18n key="CREATE_BLOG_BUTTON" />">

	</form>
	</div>
</div>


<%@ include file="../include/footer.jsp" %>
	