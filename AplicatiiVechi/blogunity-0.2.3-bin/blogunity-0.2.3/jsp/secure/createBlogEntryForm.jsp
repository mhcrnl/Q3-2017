<%@ include file="../include/header.jsp" %>
<% 
FormErrorList errors = (FormErrorList) request.getAttribute("errors"); 
Entry e = (Entry) request.getAttribute("previewEntry");
Blog b = (Blog) request.getAttribute("blog");
Boolean isPreview  = (Boolean) request.getAttribute("isPreview");
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="CREATE_ENTRY_TITLE"/></div>
	<div class="description">
		<b:i18n key="CREATE_ENTRY_DESC"/>
	</div>

	<!-- ############ PREVIEW BEGIN ##################  -->
	<%if (e !=  null && isPreview != null && isPreview.booleanValue()){%>
	<table width="100%" cellpadding="2" cellspacing="2">
		<TBODY>
			<tr><td width="100%">
				<% request.setAttribute("entry", e); %>
				<b:entry/>
			<tr><td>
		</TBODY>
		</table>
	<%} %>
	<!-- ############ PREVIEW END ##################  -->

	<div id="formLayer">
	<form action="<%=ctx%>/createBlogEntryExec.secureaction" method="post" accept-charset="UTF-8" >
		<a name="wikiSyntaxAnchor" ></a>
		<a href="#wikiSyntaxAnchor" onClick="toggle('wikiSyntax')" class="naviLink"><b:i18n key="WIKI_SYNTAX_LINK"/></a>
		<div id="wikiSyntax" style="visibility: hidden; display: none; margin-left: 0px;">
			<%@ include file="../include/wikiSyntax.jsp" %>
		</div>
		<br/><br/>


		<!-- ############# BLOG ###############  -->
		<div class="textRequired"><b:i18n key="BLOG"/>:</div> 
		<INPUT type="hidden" name="blogId" value="<%=b.getId() %>">
		<%= utils.renderBlog(b, request) %><br/><br/>

		<!-- ############# ALIAS ###############  -->
		<%if (errors!=null && errors.containsErrorsForKey("alias")){ %>
		<div class="textError" onclick="toggle('errorLayerAlias')"><b:i18n key="ENTRY_ALIAS"/>:</div> 
		<%}else{ %>
		<div class="textRequired"><b:i18n key="ENTRY_ALIAS"/>:</div> 
		<%}%>
		<input type="text" name="alias" size="30"maxlength="50" value="<%= (e != null && e.getAliasname() != null)? e.getAliasname() : ""%>"><br />
		<%=utils.showErrorsLayer(errors, "alias")%>		

		<!-- ############# TITLE ###############  -->
		<%if (errors!=null && errors.containsErrorsForKey("title")){ %>
		<div class="textError" onclick="toggle('errorLayerTitle')"><b:i18n key="ENTRY_TITLE"/>:</div> 
		<%}else{ %>
		<div class="textRequired"><b:i18n key="ENTRY_TITLE"/>:</div> 
		<%}%>
		<input type="text" name="title" size="30"maxlength="50" value="<%= (e != null)? e.getRawTitle() : ""%>"><br />
		<%=utils.showErrorsLayer(errors, "title")%>		

		<!-- ############# CATEGORY ###############  -->
		<% 
		Set categories = b.getCategories(); 
		if (categories.size() > 0){
		%>
			<%if (errors!=null && errors.containsErrorsForKey("category")){ %>
			<div class="textError" onclick="toggle('errorLayerCategory')"><b:i18n key="ENTRY_CATEGORY"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="ENTRY_CATEGORY"/>:</div> 
			<%}%>
			<SELECT multiple size="5" name="catId" class="multiselect">
				<%	
				Iterator it2 = categories.iterator();
				while (it2.hasNext()){
					Category cat = (Category) it2.next();
					String selected = (e!=null && e.containsCategory(cat))? "selected" : "";
					%><OPTION value="<%=cat.getId()%>" <%=selected%>><%=cat.getName()%></OPTION><%
				}
				 %>
			</SELECT><br />
			<%=utils.showErrorsLayer(errors, "category")%>	
		<%}%>

		<!-- ############# USERPIC ###############  -->
		<div class="textNormal"><b:i18n key="USER_USERPIC"/>:</div> 
		<SELECT size="1" name="userpicId" onChange="toggleImage('<%=ctx %>', this)" onmousemove="toggleImage('<%=ctx%>', this)" onblur="toggleImage('<%=ctx%>',this)">
			<OPTION value="" >--- no userpic ---</OPTION>
			<%	
			for (Iterator it = user.getUserpics().iterator(); it.hasNext();){
				Userpic pic = (Userpic) it.next();
				String selected = (e!=null && e.getUserpic()!= null && e.getUserpic().getId().longValue() == pic.getId().longValue())? "selected" : "";
				%><OPTION value="<%=pic.getId()%>|<%=pic.getUrl()%>" <%=selected%>><%=pic.getName()%></OPTION><%
			}
			%>
		</SELECT>
		<%if (e!=null && e.getUserpic()!= null){%>
			<img name="userpic" src="<%=ctx + e.getUserpic().getUrl()%>">
		<%}else {%>
			<img name="userpic">
		<%}%>
		<br />


		<!-- ############# EXCERPT ###############  -->
		<div class="textNormal"><b:i18n key="ENTRY_EXCERPT"/>:</div> 
		<TEXTAREA name="excerpt" cols="70" rows="12"><%= (e != null && e.getRawExcerpt() != null)? e.getRawExcerpt() : ""%></TEXTAREA><br />


		<!-- ############# BODY ###############  -->
		<%if (errors!=null && errors.containsErrorsForKey("body")){ %>
		<div class="textError" onclick="toggle('errorLayerBody')"><b:i18n key="ENTRY_BODY"/>:</div> 
		<%}else{ %>
		<div class="textRequired"><b:i18n key="ENTRY_BODY"/>:</div> 
		<%}%>
		<TEXTAREA name="body" cols="70" rows="22"><%= (e != null && e.getRawBody() != null)? e.getRawBody() : ""%></TEXTAREA><br />
		<%=utils.showErrorsLayer(errors, "body")%>	
		
		<!-- ############# PING SITES ######### -->
		<div class="textRequired"><b:i18n key="ENTRY_TRACKBACK_PINGS"/>:</div>
		<TEXTAREA name="pingsites" cols="70" rows="4"></TEXTAREA><br />


		<!-- ############# ALLOW COMMENTING? ###############  -->
		<div class="textRequired"><b:i18n key="ENTRY_ALLOW_COMMENTING"/></div> 
		<%
		String checked = "";
		if (e!= null){
			if (e.isCommentingAllowed()) checked="checked";
		}else{ checked="checked"; }
		%>
		<INPUT type="checkbox" name="commenting" <%= checked%>><br/>

		<!-- ############# ALLOW ANONYMOUS COMMENTING? ###############  -->
		<div class="textRequired"><b:i18n key="ENTRY_ALLOW_ANONYMOUS_COMMENTING"/></div> 
		<%
		checked = "";
		if (e!= null){
			if (e.isAnonymousCommentingAllowed()) checked="checked";
		}else{ checked="checked"; }
		%>
		<INPUT type="checkbox" name="anonymousCommenting" <%= checked%>><br/>
		<br/>
		<!-- ############# ALLOW TRACKBACKS? ###############  -->
		<div class="textRequired"><b:i18n key="ENTRY_ALLOW_TRACKBACKS"/></div> 
		<%
		checked = "";
		if (e!= null){
			if (e.isTrackbackAllowed()) checked="checked";
		}else{ checked="checked"; }
		%>
		<INPUT type="checkbox" name="trackbacking" <%= checked%>><br/>
		<br/>


		<!-- ############# TYPE ###############  -->
		<div class="textRequired"><b:i18n key="ENTRY_TYPE"/>:</div> 
		<SELECT size="1" name="entryType">
			<OPTION value="<%=Entry.PUBLIC%>" <%=(e!=null && Entry.PUBLIC == e.getType())? " selected" : ""%>>PUBLIC</OPTION>
			<OPTION value="<%=Entry.DRAFT%>" <%=(e!=null && Entry.DRAFT == e.getType())? " selected" : ""%>>DRAFT</OPTION>
		</SELECT>
		<br />

		<input name="submit" value="Preview" type="submit">
	    <input name="submit" value="Post to Blog" type="submit">

	</form>
	</div>



</div>


<%@ include file="../include/footer.jsp" %>
	