<%@ include file="../include/header.jsp" %>
<% 
long current = System.currentTimeMillis();
long startup = BlogunityManager.getStartupTime().getTime();
long uptime = current - startup;

long days = uptime / 1000 / 60 / 60 /24 ;

long _sum1 = uptime - days*24*60*60*1000;
long hours = _sum1 / 1000/60/60;

long _sum2 = _sum1 - hours*60*60*1000;
long minutes =_sum2 /60/1000 ;

long _sum3 = _sum2 - minutes*60*1000;
long seconds = _sum3 / 1000;

int freeMemPercent = (int) (100 * Runtime.getRuntime().freeMemory() / Runtime.getRuntime().totalMemory());
int usedMemPercent = (int) (100 - freeMemPercent);

%>

<div id="contentLayer">
	<div class="title"><b:i18n key="LIST_SYSINFO_TITLE" /></div>
	<div class="description">
		<b:i18n key="LIST_SYSINFO_DESC" />
	</div>

	<table cellpadding="2" cellspacing="2" border="0" width="100%">
	<tbody>
		<tr class=even>
			<td width="300"><b>Blogunity Version</b></td>
			<td width="50%"><%= IConstants.VERSION%></td>
		</tr>
		<tr class="odd">
			<td width="300"><b>Blogunity Codename</b></td>
			<td width="50%"><%=IConstants.CODENAME%></td>
		</tr>
		<tr class="even">
			<td width="300"><b>Blogunity Build</b></td>
			<td width="50%"><%=IConstants.BUILD%></td>
		</tr>
		<tr class="odd">
			<td width="300"><b>Uptime</b></td>
			<td width="50%"><%=days%> Day(s), <%=hours%> Hour(s), <%=minutes %> Minute(s), <%=seconds %> Second(s)</td>
		</tr>
		<tr class="even">
			<td width="300"><b>System Date/Time</b></td>
			<td width="50%"><%=new Date(System.currentTimeMillis())%></td>
		</tr>
		<tr class="odd">
			<td width="300"><b>File Encoding</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.FILE_ENCODING %></td>
		</tr>
		<tr class="even">
			<td width="300"><b>File Separator</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.FILE_SEPARATOR%></td>
		</tr>
		<tr class="odd">
			<td width="300"><b>Java Version</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_VERSION%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>Operating System architecture</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.OS_ARCH%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>Operating System name</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.OS_NAME%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>Operating System version</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.OS_VERSION%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>Java Classpath</b></td>
			<td width="50%"><%=org.apache.commons.lang.WordUtils.wrap(org.apache.commons.lang.SystemUtils.JAVA_CLASS_PATH, 100, "<br/>", true)%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>Java Class Version</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_CLASS_VERSION%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>Java Compiler</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_COMPILER%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>Java Extension Directory(s)</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_EXT_DIRS%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>Java Home</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_HOME%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>Java IO Temp-Directory</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_IO_TMPDIR%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>Java Library Path</b></td>
			<td width="50%"><%=org.apache.commons.lang.WordUtils.wrap(org.apache.commons.lang.SystemUtils.JAVA_LIBRARY_PATH, 100, "<br/>", true)%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>Java Runtime Name</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_RUNTIME_NAME%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>Java Runtime Version</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_RUNTIME_VERSION%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>Java Specification Name</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_SPECIFICATION_NAME%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>Java Specification Vendor</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_SPECIFICATION_VENDOR%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>Java Specification Version</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_SPECIFICATION_VERSION%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>Java Vendor</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_VENDOR%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>Java Vendor URL</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_VENDOR_URL%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>JavaVM Info</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_VM_INFO%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>JavaVM Name</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_VM_NAME%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>JavaVM Specification Name</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_VM_SPECIFICATION_NAME%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>JavaVM Specification Vendor</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_VM_SPECIFICATION_VENDOR%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>JavaVM Specification Version</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_VM_SPECIFICATION_VERSION%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>JavaVM Vendor</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_VM_VENDOR%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>JavaVM Version</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.JAVA_VM_VERSION%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>Server Name</b></td>
			<td width="50%"><%=request.getServerName()%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>Server Port</b></td>
			<td width="50%"><%=request.getServerPort()%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>Server Info</b></td>
			<td width="50%"><%=BlogunityManager.getServletContext().getServerInfo()%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>Protocol</b></td>
			<td width="50%"><%=request.getProtocol()%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>Line separator</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.LINE_SEPARATOR%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>Path separator</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.PATH_SEPARATOR%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>User's country code</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.USER_COUNTRY%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>User's directory</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.USER_DIR%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>User's home directory</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.USER_HOME%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>User's language</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.USER_LANGUAGE%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>User's name</b></td>
			<td width="50%"><%=org.apache.commons.lang.SystemUtils.USER_NAME%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>Total Memory</b></td>
			<td width="50%"><%=ResourceUtils.getPreformattedFilesize( Runtime.getRuntime().totalMemory())%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>Free Memory</b></td>
			<td width="50%"><%= ResourceUtils.getPreformattedFilesize(Runtime.getRuntime().freeMemory())%></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>Used Memory</b></td>
			<td width="50%"><%= ResourceUtils.getPreformattedFilesize(Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory())%></td>
		</tr>

		<tr class="even">
			<td width="300"><b>Max. Memory</b></td>
			<td width="50%"><%= ResourceUtils.getPreformattedFilesize(Runtime.getRuntime().maxMemory()) %></td>
		</tr>

		<tr class="odd">
			<td width="300"><b>Memory Graph</b></td>
			<td width="50%">
				<table border="0" cellpadding="0" cellspacing="0" width="300">
					<TBODY>
					<tr>
						<td bgcolor="red" width="<%=usedMemPercent%>%" height="10"><img src="<%=ctx%>/images/1px.gif" width="<%=usedMemPercent%>%" height="10"></td>
						<td bgcolor="green" width="<%=freeMemPercent%>%" height="10"><img src="<%=ctx%>/images/1px.gif" width="<%=freeMemPercent%>%" height="10"></td>
					</tr>
					<tr>
						<td style="text-align: center"><%=usedMemPercent%>%</td>
						<td style="text-align: center"><%=freeMemPercent%>%</td>
					</tr>
					</TBODY>
				</table>
			</td>
		</tr>

	</tbody>
	</table>


</div>

<%@ include file="../include/footer.jsp" %>
	
