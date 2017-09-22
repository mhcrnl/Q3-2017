<%@ include file="../include/header.jsp" %>
<%
FormErrorList errors = (FormErrorList) request.getAttribute("errors");
Category cat = (Category) request.getAttribute("category");
if (cat == null) cat = new Category();
List categories = (List) request.getAttribute("categories");
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="GLOBAL_CATEGORIES_TITLE" /></div>
	<div class="description">
		<b:i18n key="GLOBAL_CATEGORIES_DESC" />
	</div>


	<div id="formLayer">
	<form action="<%=ctx%>/globalCategoryExec.secureaction" method="post">
		
		<!-- ############# NAME ###############  -->
		<%if (errors!=null && errors.containsErrorsForKey("name")){ %>
		<div class="textError" onclick="toggle('errorLayerName')"><b:i18n key="CATEGORY_NAME" />:</div> 
		<%}else{ %>
		<div class="textRequired"><b:i18n key="CATEGORY_NAME" />:</div> 
		<%}%>
		<INPUT type="text" name="name" size="25" maxlength="30"  value="<%= (cat.getName() != null)? cat.getName() : "" %>"><br />
		<%=utils.showErrorsLayer(errors, "name")%>		

		<!-- ############# DESCRIPTION ###############  -->
		<div class="textNormal"><b:i18n key="CATEGORY_DESCRIPTION" />:</div>
		<TEXTAREA name="description" cols="40" rows="5"><%= (cat.getDescription() != null)? cat.getDescription() : "" %></TEXTAREA><br/>
		
		<% if (cat.getId() != null){ %>
		<input type="hidden" name="catId" value="<%=cat.getId()%>" />
		<%}%>

		<input type="submit" name="create" value="<b:i18n key="GLOBAL_CATEGORIES_BUTTON" />" />

	</form>
	</div>

	<display:table name="categories" decorator="com.j2biz.blogunity.web.decorator.GlobalCategoriesTableDecorator" 
			requestURI="listGlobalCategories.secureaction" pagesize="20" defaultsort="1" defaultorder="descending" sort="list">
		<display:column property="name" titleKey="CATEGORY" sortable="true" headerClass="sortable"/>
		<display:column property="actions" titleKey="ACTIONS" />
	</display:table>


</div>

<%@ include file="../include/footer.jsp" %>
	