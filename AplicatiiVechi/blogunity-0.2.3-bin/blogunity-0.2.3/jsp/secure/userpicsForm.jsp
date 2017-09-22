<%@ include file="../include/header.jsp" %>
<%
FormErrorList errors = (FormErrorList) request.getAttribute("errors");
Userpic newPic = (Userpic) request.getAttribute("newPic");
Set pics = user.getUserpics();
int userpicsPerUser = user.getUserSettings().getUserpicsPerUser();
int hasAlreadyUserpics = pics.size();
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="EDIT_USERPICS_TITLE"/></div>
	<div class="description">
		<b:i18n key="EDIT_USERPICS_DESC"/>
	</div>
		<table border="0" cellpadding="2" cellspacing="2">
		<tbody>
		<%
		int counter = 0;
		for (Iterator it = pics.iterator(); it.hasNext(); ){
			Userpic pic = (Userpic) it.next();
			%>
			
			<%if (counter == 0) out.println("<tr>");%>
			<td align="center">
				<b><b:i18n key="USERPIC_NAME"/>:</b> <%= pic.getName() %><br>
				<img src="<%=request.getContextPath() + pic.getUrl() %>" title="<%= pic.getName()%>" alt="<%= pic.getName()%>"><br>
				<a href="<%= request.getContextPath()%>/deleteUserpic.secureaction?userpicId=<%=pic.getId()%>"><b:i18n key="DELETE"/></a>
			</td>
			<%
			counter++;
			if (counter == 7){ 
				out.println("</tr>");
				counter = 0 ;
			}
		}
		%>		
		</tbody>
		</table>

		<% 
		if ( userpicsPerUser == -1 || userpicsPerUser > hasAlreadyUserpics ){
			java.io.File[] avatars = (java.io.File[]) request.getAttribute("avatars"); 
			if (avatars.length > 0){
		%>

		<br/>
		<div class="smalltitle"><b:i18n key="AVAILABLE_SYSTEM_USERPICS" /></div>

			<table border="0" width="100%">
			<tbody>
			<tr><td width="50%">
			<div id="formLayer">
			<form method="post" action="<%=ctx%>/editUserpicsExec.secureaction">

			<!-- ############# NAME ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("name")){ %>
			<div class="textError" onclick="toggle('errorLayerName')"><b:i18n key="USERPIC_NAME"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="USERPIC_NAME"/>:</div> 
			<%}%>
			<input type="text" name="name" size="10" maxlength="20"  
									value="<%= (newPic != null && newPic.getName() != null)? newPic.getName() : ""%>"/><br />
			<%=utils.showErrorsLayer(errors, "name")%>
				
		
			<!-- ############# USEPIC ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("url")){ %>
			<div class="textError" onclick="toggle('errorLayerUrl')"><b:i18n key="USERPIC_IMAGE"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="USERPIC_IMAGE"/>:</div> 
			<%}%>
			<select name="url" size="1" onChange="toggleImage('<%=ctx%>' , this)" 
						onmousemove="toggleImage('<%=ctx%>' ,this)" onblur="toggleImage('<%=ctx%>' ,this)">
				<% 
				String url= (newPic != null && newPic.getUrl() != null)? newPic.getUrl() : "";
				for (int i=0; i < avatars.length; i++){ 
					String p = "/images/avatars/" + avatars[i].getName();
				%>
				<option value="<%=p%>" <%=(url.equals(p))? "selected" : ""%>><%=avatars[i].getName()%></option>
				<%} %>
			</select>
			<br>
			<%=utils.showErrorsLayer(errors, "url")%>

			<input type="submit" name="add userpic" value="<b:i18n key="ADD_USERPIC_BUTTON"/>" />
			</form>	
			</div>	
	
			</td>
			<td><img name="userpic" src="<%=ctx + "/images/avatars/" + avatars[0].getName()%>"></td></tr>
			</tbody>
			</table>

			<%}%>

		<br/>
		<div class="smalltitle"><b:i18n key="UPLOAD_USERPIC" /></div>
		<div id="formLayer">
			<form method="post" action="<%=ctx%>/uploadUserpic.secureaction" enctype="multipart/form-data">
				<!-- ############# NAME ###############  -->
				<%if (errors!=null && errors.containsErrorsForKey("uploadname")){ %>
				<div class="textError" onclick="toggle('errorLayerUploadname')"><b:i18n key="USERPIC_NAME"/>:</div> 
				<%}else{ %>
				<div class="textRequired"><b:i18n key="USERPIC_NAME"/>:</div> 
				<%}%>
				<input type="text" name="uploadname" size="10" maxlength="20"  
										value="<%= (newPic != null && newPic.getName() != null)? newPic.getName() : ""%>"/><br />
				<%=utils.showErrorsLayer(errors, "uploadname")%>
					
			
				<!-- ############# USEPIC ###############  -->
				<%if (errors!=null && errors.containsErrorsForKey("userpic")){ %>
				<div class="textError" onclick="toggle('errorLayerUserpic')"><b:i18n key="USERPIC_IMAGE"/>:</div> 
				<%}else{ %>
				<div class="textRequired"><b:i18n key="USERPIC_IMAGE"/>:</div> 
				<%}%>
				<input type="file" name="userpic" size="35"/>
				<input type="submit" name="upload" value="<b:i18n key="UPLOAD_USERPIC_BUTTON" />" />
				<%=utils.showErrorsLayer(errors, "userpic")%>
			</form>
		</div>

		<%}else{
			request.setAttribute("params", new String[]{ String.valueOf(userpicsPerUser) });
		%>
			<br>

			<b:i18n key="MAXIMAL_NUMBER_OF_USERPICS_ARRIVED" params="params"/>
			<!--  <i>User can define maximal <%=userpicsPerUser%> usepics.</i> -->
		<%}%>
	
</div>
<%@ include file="../include/footer.jsp" %>
