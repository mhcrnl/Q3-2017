<%@ include file="../include/header.jsp" %>
<%
FormErrorList errors = (FormErrorList) request.getAttribute("errors");
SystemConfiguration configuration = (SystemConfiguration) request.getAttribute("configuration");
BlogSettings blogSettings = configuration.getDefaultBlogSettings();
UserSettings userSettings = configuration.getDefaultUserSettings();
ArrayList locales = (ArrayList)request.getAttribute("locales");

%>
<div id="contentLayer">
	<div class="title"><b:i18n key="EDIT_SYSCONFIG_TITLE"/></div>
	<div class="description">
		<b:i18n key="EDIT_SYSCONFIG_DESC"/>
	</div>
	<div id="formLayer">
		<form method="post" action="<%=ctx%>/editSystemConfigurationExec.secureaction">
			<!-- ############# DATA DIR ###############  -->
			<div class="textRequired"><b:i18n key="SYSCONFIG_DATA_DIRECTORY"/>:</div> 
			<%= configuration.getDataDir()%><br /><br /><br />

			<!-- ############# TEMP DIR ###############  -->
			<div class="textRequired"><b:i18n key="SYSCONFIG_TEMP_DIRECTORY"/>:</div> 
			<%= configuration.getTempDir()%><br /><br /><br />


			<!-- ############# SYSTEM LOCALE ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("systemLocale")){ %>
			<div class="textError" onclick="toggle('errorLayerSystemLocale')"><b:i18n key="SYSCONFIG_LOCALE"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_LOCALE"/>:</div> 
			<%}%>
			<select name="systemLocale" size="1">
			<%
			for (Iterator i = locales.iterator(); i.hasNext();) { 
				Locale locale = (Locale) i.next();
			%>
				<option value="<%=locale.toString()%>" <%=(configuration.getSystemLocale().equals(locale)? "selected" : "")%>><%=locale.getDisplayLanguage()%></option>
			<%} %>
			</select><br />
			<%=utils.showErrorsLayer(errors, "systemLocale")%>

			<!-- ############# SITE TITLE ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("siteTitle")){ %>
			<div class="textError" onclick="toggle('errorLayerSiteTitle')"><b:i18n key="SYSCONFIG_SITE_TITLE"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_SITE_TITLE"/>:</div> 
			<%}%>
			<input type="text" name="siteTitle" size="25" maxlength="50"  value="<%= configuration.getSiteTitle()%>"/><br />
			<%=utils.showErrorsLayer(errors, "siteTitle")%>	

			<!-- ############# SITE DESCRIPTION ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("siteDescription")){ %>
			<div class="textError" onclick="toggle('errorLayerSiteDescription')"><b:i18n key="SYSCONFIG_SITE_DESCRIPTION"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_SITE_DESCRIPTION"/>:</div> 
			<%}%>
			<textarea cols="43" rows="10" name="siteDescription"><%= (configuration.getSiteDescription() != null) ? configuration.getSiteDescription() : ""%></textarea><br />
			<%=utils.showErrorsLayer(errors, "siteDescription")%>	

			<!-- ############# SITE KEYWORDS ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("siteKeywords")){ %>
			<div class="textError" onclick="toggle('errorLayerSiteKeywords')"><b:i18n key="SYSCONFIG_SITE_KEYWORDS"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_SITE_KEYWORDS"/>:</div> 
			<%}%>
			<textarea cols="43" rows="10" name="siteKeywords"><%= ( configuration.getSiteKeywords() != null) ? configuration.getSiteKeywords() : ""%></textarea><br />
			<%=utils.showErrorsLayer(errors, "siteKeywords")%>	


			<!-- ############# DATE/TIME FORMAT ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("datetimeFormat")){ %>
			<div class="textError" onclick="toggle('errorLayerDatetimeFormat')"><b:i18n key="SYSCONFIG_DATETIME_FORMAT"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_DATETIME_FORMAT"/>:</div> 
			<%}%>
			<input type="text" name="datetimeFormat" size="25" maxlength="50"  value="<%= configuration.getDatetimeFormat()%>"/><br />
			<%=utils.showErrorsLayer(errors, "datetimeFormat")%>	

			<!-- ############# DATE FORMAT ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("dateFormat")){ %>
			<div class="textError" onclick="toggle('errorLayerDateFormat')"><b:i18n key="SYSCONFIG_DATE_FORMAT"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_DATE_FORMAT"/>:</div> 
			<%}%>
			<input type="text" name="dateFormat" size="25" maxlength="50"  value="<%= configuration.getDateFormat()%>"/><br />
			<%=utils.showErrorsLayer(errors, "dateFormat")%>	

			<!-- ############# TIME FORMAT ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("timeFormat")){ %>
			<div class="textError" onclick="toggle('errorLayerTimeFormat')"><b:i18n key="SYSCONFIG_TIME_FORMAT"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_TIME_FORMAT"/>:</div> 
			<%}%>
			<input type="text" name="timeFormat" size="25" maxlength="50"  value="<%= configuration.getTimeFormat()%>"/><br />
			<%=utils.showErrorsLayer(errors, "timeFormat")%>

			<!-- ############# INDIVIDUAL BLOGS PER USER ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("individualBlogsPerUser")){ %>
			<div class="textError" onclick="toggle('errorLayerIndividualBlogsPerUser')"><b:i18n key="SYSCONFIG_INDIVIDUAL_BLOGS_PER_USER"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_INDIVIDUAL_BLOGS_PER_USER"/>:</div> 
			<%}%>
			<input type="text" name="individualBlogsPerUser" size="2" maxlength="2"  value="<%= userSettings.getIndividualBlogsPerUser()%>"/> (use -1 for unlimited)<br /><br /><br />
			<%=utils.showErrorsLayer(errors, "individualBlogsPerUser")%>	

			<!-- ############# COMMUNITY BLOGS PER USER ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("communityBlogsPerUser")){ %>
			<div class="textError" onclick="toggle('errorLayerCommunityBlogsPerUser')"><b:i18n key="SYSCONFIG_COMMUNITY_BLOGS_PER_USER"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_COMMUNITY_BLOGS_PER_USER"/>:</div> 
			<%}%>
			<input type="text" name="communityBlogsPerUser" size="2" maxlength="2"  value="<%= userSettings.getCommunityBlogsPerUser()%>"/> (use -1 for unlimited)<br /><br /><br />
			<%=utils.showErrorsLayer(errors, "communityBlogsPerUser")%>


			<!-- ############# USERPICS PER USER ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("userpicsPerUser")){ %>
			<div class="textError" onclick="toggle('errorLayerUserpicsPerUser')"><b:i18n key="SYSCONFIG_USERPICS_PER_USER"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_USERPICS_PER_USER"/>:</div> 
			<%}%>
			<input type="text" name="userpicsPerUser" size="2" maxlength="2"  value="<%= userSettings.getUserpicsPerUser()%>"/> (use -1 for unlimited)<br /><br /><br />
			<%=utils.showErrorsLayer(errors, "userpicsPerUser")%>

			<!-- ############# USERPIC MAX SIZE ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("userpicMaxSize")){ %>
			<div class="textError" onclick="toggle('errorLayerUserpicMaxSize')"><b:i18n key="SYSCONFIG_USERPIC_MAX_SIZE"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_USERPIC_MAX_SIZE"/>:</div> 
			<%}%>
			<input type="text" name="userpicMaxSize" size="10" maxlength="10"  value="<%= userSettings.getMaxUserpicSize()%>"/> (bytes)<br /><br /><br />
			<%=utils.showErrorsLayer(errors, "userpicMaxSize")%>

			<!-- ############# USERPIC MAX WIDTH ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("userpicMaxWidth")){ %>
			<div class="textError" onclick="toggle('errorLayerUserpicMaxWidth')"><b:i18n key="SYSCONFIG_USERPIC_MAX_WIDTH"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_USERPIC_MAX_WIDTH"/>:</div> 
			<%}%>
			<input type="text" name="userpicMaxWidth" size="10" maxlength="10"  value="<%= userSettings.getMaxUserpicWidth()%>"/> (pixels)<br /><br /><br />
			<%=utils.showErrorsLayer(errors, "userpicMaxWidth")%>

			<!-- ############# USERPIC MAX HEIGHT ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("userpicMaxHeight")){ %>
			<div class="textError" onclick="toggle('errorLayerUserpicMaxHeight')"><b:i18n key="SYSCONFIG_USERPIC_MAX_HEIGHT"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_USERPIC_MAX_HEIGHT"/>:</div> 
			<%}%>
			<input type="text" name="userpicMaxHeight" size="10" maxlength="10"  value="<%= userSettings.getMaxUserpicHeight()%>"/> (pixels)<br /><br /><br />
			<%=utils.showErrorsLayer(errors, "userpicMaxHeight")%>


			<!-- ############# ALLOW NEW USERS ###############  -->
			<div class="textRequired"><b:i18n key="SYSCONFIG_ALLOW_NEW_USERS"/></div> 
			<input type="checkbox" name="allowNewUsers" <%=(configuration.getAllowNewUsers())? "checked" : "" %>/><br /><br /><br />

			<!-- ############# VALIDATE NEW USERS ###############  -->
			<div class="textRequired"><b:i18n key="SYSCONFIG_VALIDATE_NEW_USERS"/></div> 
			<input type="checkbox" name="validateNewUsers" <%=(configuration.getValidateNewUsers())? "checked" : "" %>/><br /><br /><br />

			<!-- ############# ACTIVATE RANKING? ###############  -->
			<!-- 
			<div class="textRequired"><b:i18n key="SYSCONFIG_ACTIVATE_RANKING"/></div> 
			<input type="checkbox" name="rankingOn" <%= (configuration.getRankingOn())? "checked" : "" %> disabled/> (availiable from version 0.2) <br />
			-->

			<!-- ############# THEME EDIT? ###############  -->
			<div class="textRequired"><b:i18n key="SYSCONFIG_THEME_EDITING"/></div> 
			<input type="checkbox" name="themeEditingAllowed" <%=(blogSettings.getThemeEditingAllowed())? "checked" : "" %> /><br /><br /><br />

			<!-- ############# ACCESS LOG ENABLED? ###############  -->
			<div class="textRequired"><b:i18n key="SYSCONFIG_ACCESS_LOG_ENABLED"/></div> 
			<input type="checkbox" name="accesslogEnabled" <%=(blogSettings.getAccessLoggingEnabled())? "checked" : "" %> /><br /><br /><br />


			<!-- ############# SMTP HOST ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("smtpHost")){ %>
			<div class="textError" onclick="toggle('errorLayerSmtpHost')"><b:i18n key="SYSCONFIG_SMTP_HOST"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_SMTP_HOST"/>:</div> 
			<%}%>
			<input type="text" name="smtpHost" size="25" maxlength="50"  value="<%= org.apache.commons.lang.StringUtils.isNotEmpty(configuration.getSmtpHost())?configuration.getSmtpHost() : "" %>"/><br />
			<%=utils.showErrorsLayer(errors, "smtpHost")%>

			<!-- ############# SMTP USER ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("smtpUser")){ %>
			<div class="textError" onclick="toggle('errorLayerSmtpUser')"><b:i18n key="SYSCONFIG_SMTP_USER"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_SMTP_USER"/>:</div> 
			<%}%>
			<input type="text" name="smtpUser" size="25" maxlength="50"  value="<%= org.apache.commons.lang.StringUtils.isNotEmpty(configuration.getSmtpUser())?configuration.getSmtpUser() : ""%>"/><br />
			<%=utils.showErrorsLayer(errors, "smtpUser")%>

			<!-- ############# SMTP PASSWORD ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("smtpPassword")){ %>
			<div class="textError" onclick="toggle('errorLayerSmtpPassword')"><b:i18n key="SYSCONFIG_SMTP_PASSWORD"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_SMTP_PASSWORD"/>:</div> 
			<%}%>
			<input type="password" name="smtpPassword" size="25" maxlength="50"  value="<%= org.apache.commons.lang.StringUtils.isNotEmpty(configuration.getSmtpPassword())?configuration.getSmtpPassword() : ""%>"/><br />
			<%=utils.showErrorsLayer(errors, "smtpPassword")%>


			<!-- ############# SMTP SENDER NAME ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("smtpSenderName")){ %>
			<div class="textError" onclick="toggle('errorLayerSmtpSenderName')"><b:i18n key="SYSCONFIG_SMTP_SENDER_NAME"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="SYSCONFIG_SMTP_SENDER_NAME"/>:</div> 
			<%}%>
			<input type="text" name="smtpSenderName" size="25" maxlength="50"  value="<%= org.apache.commons.lang.StringUtils.isNotEmpty(configuration.getSmtpSenderName())?configuration.getSmtpSenderName() : ""%>"/><br />
			<%=utils.showErrorsLayer(errors, "smtpSenderName")%>

			<!-- ############# USER PASSWORD ENCRYPTION ###############  -->
			<br/><br/><b:i18n key="SYSCONFIG_PASSWORD_ENCRYPTION_MESSAGE"/><br/><br/>
			
			<div class="textRequired"><b:i18n key="SYSCONFIG_PASSWORD_ENCRYPTION_TYPE"/>:</div> 
			<%if (configuration.getPasswordEncryptionType() == PasswordEncryptionService.MD5){%>MD5
			<%}else if (configuration.getPasswordEncryptionType() == PasswordEncryptionService.SHA){%>SHA
			<%}else{%>NONE
			<%} %>	
			<br/><br/>
			
			

			<input type="submit" name="edit system configuration" value="<b:i18n key="EDIT_SYSCONFIG_BUTTON"/>" />
		</form>	
	</div>
</div>


<%@ include file="../include/footer.jsp" %>
