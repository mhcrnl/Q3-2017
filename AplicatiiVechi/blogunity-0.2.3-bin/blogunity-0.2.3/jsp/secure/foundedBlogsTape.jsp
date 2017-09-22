<%@ include file="../include/header.jsp" %>
<%
List entries = (List) request.getAttribute("entries");
%>

<div id="contentLayer">

	<div class="title"><b:i18n key="FOUNDED_BLOGS_TAPE_TITLE" /></div>
	<div class="description">
		<b:i18n key="FOUNDED_BLOGS_TAPE_DESC" />
	</div>


	<table border="0" cellpadding="0" cellspacing="1" width="100%">
	<tbody>
		<%
		if (entries.size() == 0){
		%><tr><td>no entries found</td></tr><%
		}else{
			Iterator it =  entries.iterator();
			while (it.hasNext()){
				Entry e = (Entry) it.next();
                request.setAttribute("entry", e);
			%>
			<tr><td>
				<b:entry/>
			</td></tr>
			<%
			} // end of while
		} // end of if
		%>
		</tbody>
		</table>

</div>


<%@ include file="../include/footer.jsp" %>
	