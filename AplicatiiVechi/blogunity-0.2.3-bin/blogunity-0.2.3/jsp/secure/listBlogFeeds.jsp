<%@ include file="../include/header.jsp" %>
<%
Blog blog = (Blog) request.getAttribute("blog");
User founder = blog.getFounder();
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="BLOG_FEEDS_TITLE" /></div>
	<div class="description">
		<b:i18n key="BLOG_FEEDS_DESC" />
	</div>

	<div class="smalltitle"><b:i18n key="AVAILIABLE_FEEDS" /></div>
	<table border="0" width="100%" cellpadding="2" cellspacing="2">
	<tbody>
		<tr>
			<td width="50%"><b:i18n key="FEEDS_FOR_ALL_CATEGORIES" /></td>
			<td>
				<a target="_blank" href="<%=ctx%>/blogs/<%=blog.getUrlName()%>/feeds/atom_0.3"><img src="<%=ctx%>/images/atom03.gif" border="0"></a>&nbsp;
				<a target="_blank" href="<%=ctx%>/blogs/<%=blog.getUrlName()%>/feeds/rss_2.0"><img src="<%=ctx%>/images/rss2.gif" border="0"></a>&nbsp;
			</td>
		</tr>
		<%for (Iterator i = blog.getCategories().iterator(); i.hasNext(); ){ 
			Category c = (Category) i.next();
		%>
		<tr>
			<td width="50%">
				<%
				String[] params = new String[]{ "<i>"+c.getName()+"</i>" };
				request.setAttribute("params", params);
				%>
				<b:i18n key="FEEDS_FOR_CATEGORY" params="params"/>
			</td>
			<td>
				<a target="_blank" href="<%=ctx%>/blogs/<%=blog.getUrlName()%>/feeds/atom_0.3/<%=c.getId()%>"><img src="<%=ctx%>/images/atom03.gif" border="0"></a>&nbsp;
				<a target="_blank" href="<%=ctx%>/blogs/<%=blog.getUrlName()%>/feeds/rss_2.0/<%=c.getId()%>"><img src="<%=ctx%>/images/rss2.gif" border="0"></a>&nbsp;
			</td>
		</tr>	
		<%}%>
	</tbody>
	</table>

	<br/>
	<div class="smalltitle"><b:i18n key="EXPORT_FEED_TITLE" /></div>
	<div id="formLayer">
		<form method="post" action="<%=ctx%>/exportFeed.secureaction">
			<div class="textRequired"><b:i18n key="EXPORT_FEED_AS" /></div> 
			<select size="1" name="type">
				<option value="atom_0.3">Atom 0.3</option>
				<option value="rss_2.0">RSS 2.0</option>
				<option value="rss_1.0">RSS 1.0</option>
				<option value="rss_0.94">RSS 0.94</option>
				<option value="rss_0.93">RSS 0.93</option>
				<option value="rss_0.92">RSS 0.92</option>
				<option value="rss_0.91">RSS 0.91</option>
				<option value="rss_0.90">RSS 0.90</option>
			</select>
			
			<select size="1" name="compression">
				<option value="none">none</option>
				<option value="zip">zip</option>
				<option value="gzip">gzip</option>
			</select>
			 
			<input type="hidden" name="blogid" value="<%=blog.getId()%>" />
			<input type="submit" name="download" value="<b:i18n key="EXPORT_FEED_BUTTON" />" />
		</form>
	</div>	
	<br/><br/>

	<%if (user.getId().longValue() == founder.getId().longValue() || user.isAdministrator()){
		FormErrorList errors = (FormErrorList) request.getAttribute("errors");
	%>
	<div class="smalltitle"><b:i18n key="IMPORT_FEED_TITLE" /></div>
	<div class="text">
		<b:i18n key="IMPORT_FEED_TEXT1" /><br/><b:i18n key="IMPORT_FEED_TEXT2" />

	</div>
	<br/>
	<div id="formLayer">
		<form method="post" action="<%=ctx%>/importFeed.secureaction" enctype="multipart/form-data">
			<%if (errors!=null && errors.containsErrorsForKey("import")){ %>
			<div class="textError" onclick="toggle('errorLayerImport')"><b:i18n key="IMPORT_FROM" />:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="IMPORT_FROM" />:</div> 
			<%}%>
			<input type="file" name="feedFile" size="35"/>
			<input type="hidden" name="blogid" value="<%=blog.getId()%>" />
			<input type="submit" name="upload" value="<b:i18n key="IMPORT_FEED_BUTTON" />" />
			<%=utils.showErrorsLayer(errors, "import")%>
		</form>
	</div>
	<br/>
	<%}%>	

</div>

<%@ include file="../include/footer.jsp" %>
	