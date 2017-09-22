<%@ include file="../include/header.jsp" %>
<%
Blog b = (Blog) request.getAttribute("blog");
java.io.File[] themeFiles = (java.io.File[]) request.getAttribute("themeFiles");
java.io.File[] themeDirs = (java.io.File[]) request.getAttribute("themeDirs");
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="EDIT_THEME_TITLE" /></div>
	<div class="description">
		<b:i18n key="EDIT_THEME_DESC" />
	</div>


	<div id="formLayer">
		<form method="post" action="<%=ctx%>/overwriteBlogThemeConfirm.secureaction">
			<!-- ############# NICKNAME ###############  -->
			<div class="textRequired"><b:i18n key="EDIT_THEME_OVERWRITE" />:</div> 
			<select name="themeDir" size="1">
				<%for (int i = 0; i < themeDirs.length; i++){%>
				<option value="<%=themeDirs[i].getName()%>"><%=themeDirs[i].getName()%></option>
				<%}%>
			</select>
			<input type="hidden" name="blogId" value="<%=b.getId()%>"/>
			<input type="submit" name="overwrite theme" value="<b:i18n key="EDIT_THEME_OVERWRITE_BUTTON" />" />
		</form>
	</div>

	<div id="formLayer">
		<form method="post" action="<%=ctx%>/importBlogTheme.secureaction" enctype="multipart/form-data">
			<div class="textRequired"><b:i18n key="EDIT_THEME_IMPORT" />:</div> 
			<input type="file" name="themeFile" size="35"/>
			<input type="hidden" name="blogId" value="<%=b.getId()%>"/>
			<input type="submit" name="import theme" value="<b:i18n key="EDIT_THEME_IMPORT_BUTTON" />" />
		</form>
	</div>

	<div id="formLayer">
		<form method="post" action="<%=ctx%>/exportBlogTheme.secureaction">
			<div class="textRequired"><b:i18n key="EDIT_THEME_EXPORT" />:</div> 
			<select name="compression" size="1">
				<option value="zip">zip</option>
			</select>
			<input type="hidden" name="blogId" value="<%=b.getId()%>"/>
			<input type="submit" name="overwrite theme" value="<b:i18n key="EDIT_THEME_EXPORT_BUTTON" />" />
		</form>
	</div>


	<table cellpadding="2" cellspacing="2" border="0" width="100%">
	<thead>
		<tr bgcolor="#F0F0F0">
			<td width="50%" colspan="2"><b><b:i18n key="FILENAME" /></b></td>
			<td width="150"><b><b:i18n key="FILETIME" /></b></td>
			<td width="100"><b><b:i18n key="FILESIZE" /></b></td>
			<td><b><b:i18n key="ACTIONS" /></b></td>
		</tr>
	</thead>
	<tbody>	
		<% for(int i=0; i<themeFiles.length; i++){%>
		<tr>
			<td width="16">
				<% if (themeFiles[i].getName().endsWith(".theme")){ %>
				<img src="<%=ctx %>/images/icons/theme_file.gif" />
				<%}else{%>
				<img src="<%=ctx %>/images/icons/file.gif" />
				<%}%>
			</td>
			<td width="50%"><%= themeFiles[i].getName() %></td>
			<td width="100"><%= utils.formatDateTime(new Date(themeFiles[i].lastModified()))  %></td>
			<td width="100"><%= ResourceUtils.getPreformattedFilesize(themeFiles[i].length()) %></td>
			<td><nobr>
			<%if (themeFiles[i].getName().endsWith(".theme") || themeFiles[i].getName().endsWith(".css")){ %>
				<a href="<%=ctx %>/editThemeFileForm.secureaction?id=<%=b.getId()%>&file=<%= themeFiles[i].getName() %>"><b:i18n key="EDIT" /></a>
			<%}%>
			</nobr></td>
		</tr>
		<%}%>
	</tbody>
	</table>


</div>

<%@ include file="../include/footer.jsp" %>
	