<%@ include file="../include/header.jsp" %>
<% 
FormErrorList errors = (FormErrorList) request.getAttribute("errors"); 
Category category = (Category) request.getAttribute("category");
Object blogId = request.getAttribute("blogId");
if (category == null) category = new Category();
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="EDIT_CATEGORY_TITLE"/></div>
	<div class="description">
		<b:i18n key="EDIT_CATEGORY_DESC"/>
	</div>

	<div id="formLayer">
	<form action="<%=ctx%>/categoryExec.secureaction" method="post">
		
		<!-- ############# NAME ###############  -->
		<%if (errors!=null && errors.containsErrorsForKey("name")){ %>
		<div class="textError" onclick="toggle('errorLayerName')"><b:i18n key="CATEGORY_NAME"/>:</div> 
		<%}else{ %>
		<div class="textRequired"><b:i18n key="CATEGORY_NAME"/>:</div> 
		<%}%>
		<INPUT type="text" name="name" size="25" maxlength="30"  value="<%= (category.getName() != null)? category.getName() : "" %>"><br />
		<%=utils.showErrorsLayer(errors, "name")%>		

		<!-- ############# DESCRIPTION ###############  -->
		<div class="textNormal"><b:i18n key="CATEGORY_DESCRIPTION"/>:</div>
		<TEXTAREA name="description" cols="45" rows="12"><%= (category.getDescription() != null)? category.getDescription() : "" %></TEXTAREA><br/>
		
		<% if (category.getId() != null){ %>
		<input type="hidden" name="catId" value="<%=category.getId()%>" />
		<%}%>
		<input type="hidden" name="blogId" value="<%=request.getAttribute("blogId") %>" />
		<input type="submit" name="create" value="<b:i18n key="EDIT_CATEGORY_BUTTON"/>" />

	</form>
	</div>

</div>

<%@ include file="../include/footer.jsp" %>
	