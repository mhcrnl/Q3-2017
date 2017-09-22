<%@ include file="../include/header.jsp" %>
<%
Blog b = (Blog) request.getAttribute("blog");
%>

<div id="contentLayer">
	<div class="title"><b:i18n key="LIST_LOGS_TITLE" /></div>
	<div class="description">
		<b:i18n key="LIST_LOGS_DESC" />
	</div>


	<display:table name="files" decorator="com.j2biz.blogunity.web.decorator.FilesTableDecorator" 
				requestURI="listLogs.secureaction" pagesize="20" defaultsort="1" defaultorder="descending" sort="list">
	
		<display:column property="filename" titleKey="FILENAME" sortable="true" headerClass="sortable" sortProperty="name"/>
		<display:column property="filetime" titleKey="FILETIME" />
		<display:column property="filesize" titleKey="FILESIZE" />
		<display:column property="logsActions" titleKey="ACTIONS" />
	</display:table>




</div>

<%@ include file="../include/footer.jsp" %>
	