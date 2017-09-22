<%@ include file="../include/header.jsp" %>
<% 
FormErrorList errors = (FormErrorList) request.getAttribute("errors"); 
Blog blog = (Blog) request.getAttribute("blog");
java.io.File themeFile  = (java.io.File) request.getAttribute("themeFile");
String themeFileContent = (String) request.getAttribute("themeFileContent");
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="EDIT_THEME_FILE_TITLE" /></div>
	<div class="description">
		<b:i18n key="EDIT_THEME_FILE_DESC" />
	</div>

	<div id="formLayer">
	<form action="<%=ctx%>/editThemeFileExec.secureaction" method="post">

		<!-- ############# FILE ###############  -->
		<div class="textRequired"><%=themeFile.getName()%></div><br/> 

		<!-- ############# CONTENT ###############  -->		
		<TEXTAREA name="fileContent" cols="100" rows="30"><%= (themeFileContent != null)? themeFileContent : "" %></TEXTAREA><br/>

		<input type="hidden" name="file" value="<%=themeFile.getName()%>" />
		<input type="hidden" name="id" value="<%=blog.getId()%>" />
		<input type="submit" name="edit file content" value="<b:i18n key="EDIT_THEME_FILE_BUTTON" />">
	</form>
	</div>
</div>

<%@ include file="../include/footer.jsp" %>
	