<%@ include file="../include/header.jsp" %>
<% 
Comment comment = (Comment) request.getAttribute("requestedComment");
Entry e = comment.getCommentedEntry();
FormErrorList errors = (FormErrorList) request.getAttribute("errors");
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="EDIT_COMMENT_TITLE"/></div>
	<div class="description">
		<b:i18n key="EDIT_COMMENT_DESC"/>
	</div>

	<div id="formLayer">
	<form action="<%=ctx%>/editCommentExec.secureaction" method="post">

		<!-- ############# NAME ###############  -->
		<div class="textRequired"><b:i18n key="COMMENT_AUTHOR"/>:</div> 
		<%= utils.renderUser(comment.getAuthor(), request) %><br/><br/>

		<!-- ############# TITLE ###############  -->
		<%if (errors!=null && errors.containsErrorsForKey("title")){ %>
		<div class="textError" onclick="toggle('errorLayerTitle')"><b:i18n key="COMMENT_TITLE"/>:</div> 
		<%}else{ %>
		<div class="textRequired"><b:i18n key="COMMENT_TITLE"/>:</div> 
		<%}%>
		<input type="text" name="title" size="25" maxlength="50" 
						value="<%= ( comment.getRawTitle() != null)? comment.getRawTitle(): ""%>" /><br/>
		<%=utils.showErrorsLayer(errors, "title")%>

		<!-- ############# COMMENT ###############  -->
		<div class="textRequired"><b:i18n key="COMMENT_BODY"/>:</div> 
		<TEXTAREA name="comment" cols="45" rows="20"><%= (comment.getRawBody() != null)? comment.getRawBody() : "" %></TEXTAREA><br/>

		<input type="hidden" name="id" value="<%=comment.getId() %>">
		<input type="submit" name="edit" value="<b:i18n key="EDIT_COMMENT_BUTTON"/>">

		
	</form>
	</div>


</div>

<%@ include file="../include/footer.jsp" %>
	