<%@ include file="../include/header.jsp" %>
<%
Blog b = (Blog) request.getAttribute("blog");

FormErrorList errors = (FormErrorList) request.getAttribute("errors"); 
String path = request.getParameter("path");
if (org.apache.commons.lang.StringUtils.isEmpty(path)){
    // try to find it on request
    path = (String) request.getAttribute("path");
}
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="LIST_IMAGES_TITLE" /></div>
	<div class="description">
		<b:i18n key="LIST_IMAGES_DESC" />
	</div>
	
	
	<div class="smalltitle"><b:i18n key="UPLOAD_IMAGE" /></div>
	<div id="formLayer">
		<form method="post" action="<%=ctx%>/uploadImage.secureaction" enctype="multipart/form-data">
			<%if (errors!=null && errors.containsErrorsForKey("resource")){ %>
				<div class="textError" onclick="toggle('errorLayerResource')"><b:i18n key="IMAGE_NAME"/>:</div> 
			<%}else{ %>
				<div class="textRequired"><b:i18n key="IMAGE_NAME"/>:</div> 
			<%}%>
		
			<input type="file" name="resource" size="35"/>
			<input type="hidden" name="blogId" value="<%=b.getId()%>"/>
			<%if (org.apache.commons.lang.StringUtils.isNotEmpty(path)){%>
			<input type="hidden" name="path" value="<%=path%>"/>
			<%}%>
			<input type="submit" name="upload image" value="<b:i18n key="UPLOAD_IMAGE_BUTTON" />" />
			<br/>
			<%=utils.showErrorsLayer(errors, "resource")%>	
		</form>
	</div>	
	
	
	<br/>
	<div class="smalltitle"><b:i18n key="CREATE_DIRECTORY" /></div>
	<div id="formLayer">
		<form method="post" action="<%=ctx%>/createBlogImagesDirectory.secureaction">
			
			<%if (errors!=null && errors.containsErrorsForKey("dirName")){ %>
				<div class="textError" onclick="toggle('errorLayerDirName')"><b:i18n key="DIRECTORY_NAME"/>:</div> 
			<%}else{ %>
				<div class="textRequired"><b:i18n key="DIRECTORY_NAME"/>:</div> 
			<%}%>

			<input type="text" name="dirName" size="35" maxlength="40"/>
			<%if (org.apache.commons.lang.StringUtils.isNotEmpty(path)){%>
			<input type="hidden" name="path" value="<%=path%>" />
			<%}%>
			<input type="submit" name="createdir" value="<b:i18n key="CREATE_DIRECTORY_BUTTON" />" />
			<br/>
			<%=utils.showErrorsLayer(errors, "dirName")%>		
			
			<input type="hidden" name="id" value="<%=b.getId()%>" />

		</form>
	</div>		
	
	<br/>
	/ <a href="<%=ctx%>/listBlogImages.secureaction?id=<%=b.getId()%>">images</a>	
	<%if (org.apache.commons.lang.StringUtils.isNotEmpty(path)){
        if (path.charAt(0) == '/') path = path.substring(1);
		String[] splitted = path.split("/");
        String url = ctx + "/listBlogImages.secureaction?id="  + b.getId();
        for (int i = 0; i < splitted.length; i++){
          if ( i == 0) url += "&path=";
            url += "/" + splitted[i];
            out.println("/ ");
            out.println("<a href=\" " + url + "\">");
            out.println(splitted[i]);
            out.println("</a>");
        }
	
	}%>
	
	<br/><br/>
	
	<display:table name="files" decorator="com.j2biz.blogunity.web.decorator.FilesTableDecorator" 
				requestURI="listBlogImages.secureaction" pagesize="20" defaultsort="1" defaultorder="descending" sort="list">
	
		<display:column property="imagename" titleKey="FILENAME" sortable="true" headerClass="sortable" sortProperty="name"/>
		<display:column property="filetime" titleKey="FILETIME" />
		<display:column property="filesize" titleKey="FILESIZE" />
		<display:column property="imagesActions" titleKey="ACTIONS" />
	</display:table>
	


</div>

<%@ include file="../include/footer.jsp" %>
	