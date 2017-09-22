<%@ include file="../include/header.jsp" %>
<% 
FormErrorList errors = (FormErrorList) request.getAttribute("errors"); 
Link link = (Link) request.getAttribute("link");
if (link == null) link = new Link();
Object blogId = request.getAttribute("blogId");
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="EDIT_LINK_TITLE"/></div>
	<div class="description">
		<b:i18n key="EDIT_LINK_DESC"/>
	</div>

	<div id="formLayer">
	<form action="<%=ctx%>/linkExec.secureaction" method="post">
		
		<!-- ############# NAME ###############  -->
		<%if (errors!=null && errors.containsErrorsForKey("name")){ %>
		<div class="textError" onclick="toggle('errorLayerName')"><b:i18n key="LINK_NAME"/>:</div> 
		<%}else{ %>
		<div class="textRequired"><b:i18n key="LINK_NAME"/>:</div> 
		<%}%>
		<INPUT type="text" name="name" size="25" maxlength="30"  
				value="<%= (link.getName() != null)? link.getName() : "" %>"><br />
		<%=utils.showErrorsLayer(errors, "name")%>		


		<!-- ############# URL ###############  -->
		<%if (errors!=null && errors.containsErrorsForKey("url")){ %>
		<div class="textError" onclick="toggle('errorLayerUrl')"><b:i18n key="LINK_URL"/>:</div> 
		<%}else{ %>
		<div class="textRequired"><b:i18n key="LINK_URL"/>:</div> 
		<%}%>
		<INPUT type="text" name="url" size="25" maxlength="30"  
					value="<%= (link.getUrl() != null)? link.getUrl() : "" %>"><br />
		<%=utils.showErrorsLayer(errors, "url")%>	

		<% if (link.getId() != null){ %>
		<input type="hidden" name="linkId" value="<%=link.getId()%>" />
		<%}%>
		<input type="hidden" name="blogId" value="<%=blogId %>">
		<input type="submit" name="create" value="<b:i18n key="EDIT_LINK_BUTTON"/>">


	</form>
	</div>
</div>

<%@ include file="../include/footer.jsp" %>
	