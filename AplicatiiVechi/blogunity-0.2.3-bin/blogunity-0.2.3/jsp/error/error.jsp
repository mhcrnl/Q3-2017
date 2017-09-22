<%@ page isErrorPage="true"%>
<%@ include file="../include/header.jsp" %>

<div id="contentLayer">
	<div class="title">An error has occurred</div>
	<div class="description">
		Sorry, but there has been a problem - if this
		problem persists, please <a href="http://www.j2biz.com/jira">raise an issue</a>
	</div>

		<%if (exception != null) {%>
		<pre><%=exception.getMessage() %></pre>
		<a href="#" onClick="toggle('stacktraceLayer')" class="naviLink">click here to toggle error's stacktrace</a>
		<div id="stacktraceLayer" style="visibility: hidden; display: none; margin-left: -55px;">
				<pre>
				<%= org.apache.commons.lang.exception.ExceptionUtils.getFullStackTrace(exception) %>
				</pre>
		</div>
		<%}%>

</div>

<%@ include file="../include/footer.jsp" %>
