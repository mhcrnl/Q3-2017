<%@ include file="../include/header.jsp" %>
<% Category cat  = (Category) request.getAttribute("requestedCategory"); %>

<div id="contentLayer">
	<div class="title"><b:i18n key="GLOBAL_CATEGORY_DELETE_TITLE" /></div>
	<div class="description">
		<b:i18n key="GLOBAL_CATEGORY_DELETE_DESC" />
	</div>

	<%
	String[] params = new String[]{cat.getName()};
	request.setAttribute("params", params);
	%>
	<b:i18n key="GLOBAL_CATEGORY_DELETE_TEXT" params="params" /><br/>
	<a href="<%=ctx%>/deleteGlobalCategoryExec.secureaction?id=<%=cat.getId()%>" class="naviLink"><b:i18n key="YES" /></a>
	&nbsp;&nbsp;
	<a href="<%=ctx%>/listGlobalCategories.secureaction" class="naviLink"><b:i18n key="NO" /></a>

</div>
<%@ include file="../include/footer.jsp" %>