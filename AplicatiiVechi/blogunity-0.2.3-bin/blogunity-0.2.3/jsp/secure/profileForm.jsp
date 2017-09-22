<%@ include file="../include/header.jsp" %>
<%
FormErrorList errors = (FormErrorList) request.getAttribute("errors");
ArrayList locales = (ArrayList)request.getAttribute("locales");
%>
<div id="contentLayer">
	<div class="title"><b:i18n key="EDIT_PROFILE_TITLE"/></div>
	<div class="description">
		<b:i18n key="EDIT_PROFILE_DESC"/>
	</div>
	
	<div id="formLayer">
		<form method="post" action="<%=ctx%>/editProfileExec.secureaction">
			<!-- ############# NICKNAME ###############  -->
			<div class="textRequired"><b:i18n key="USER_NICKNAME"/>:</div> 
			<%=user.getNickname()%><br /><br />

			<!-- ############# PASSWORD ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("password")){ %>
			<div class="textError" onclick="toggle('errorLayerPassword')"><b:i18n key="USER_PASSWORD"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="USER_PASSWORD"/>:</div> 
			<%}%>
			<input type="password" name="password" size="25" maxlength="10"/><br />
			<%=utils.showErrorsLayer(errors, "password")%>
			
			<!-- ############# FIRSTNAME ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("firstname")){ %>
			<div class="textError" onclick="toggle('errorLayerFirstname')"><b:i18n key="USER_FIRSTNAME"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="USER_FIRSTNAME"/>:</div> 
			<%}%>
			<input type="text" name="firstname" size="25" maxlength="25"  
					value="<%= (user.getFirstname() != null)? user.getFirstname() : "" %>"/><br />
			<%=utils.showErrorsLayer(errors, "firstname")%>
		

			<!-- ############# LASTNAME ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("lastname")){ %>
			<div class="textError" onclick="toggle('errorLayerLastname')"><b:i18n key="USER_LASTNAME"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="USER_LASTNAME"/>:</div> 
			<%}%>
			<input type="text" name="lastname" size="25" maxlength="25"  
					value="<%= (user.getLastname() != null)? user.getLastname() : "" %>"/><br />
			<%=utils.showErrorsLayer(errors, "lastname")%>


			<!-- ############# EMAIL ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("email")){ %>
			<div class="textError" onclick="toggle('errorLayerEmail')"><b:i18n key="USER_EMAIL"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="USER_EMAIL"/>:</div> 
			<%}%>
			<input type="text" name="email" size="25" maxlength="25"  
					value="<%= (user.getEmail() != null)? user.getEmail() : "" %>"/><br />
			<%=utils.showErrorsLayer(errors, "email")%>

			<!-- ############# LANGUAGE ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("language")){ %>
			<div class="textError" onclick="toggle('errorLayerLanguage')"><b:i18n key="USER_LANGUAGE"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="USER_LANGUAGE"/>:</div> 
			<%}%>
			<select name="language" size="1">
			<%
			for (Iterator i = locales.iterator(); i.hasNext();) { 
				Locale locale = (Locale) i.next();
			%>
				<option value="<%=locale.toString()%>" <%=(user.getLanguage().equals(locale)? "selected" : "")%>>
					<%=locale.getDisplayLanguage(user.getLanguage())%>
				</option>
			<%} %>
			</select><br />
			<%=utils.showErrorsLayer(errors, "language")%>			

			<!-- ############# SEX ###############  -->
			<div class="textRequired"><b:i18n key="USER_SEX"/>:</div> 
			<select size="1" name="sex">
				<option value="<%= User.MALE%>" <%=(user.getSex() == User.MALE)? "selected" : ""%>>male</option>
				<option value="<%= User.FEMALE%>" <%=(user.getSex() == User.FEMALE)? "selected" : ""%>>female</option>
			</select><br />

			<!-- ############# ICQ ###############  -->
			<div class="textNormal"><b:i18n key="USER_ICQ"/>:</div>
			<input type="text" name="icq" size="25" maxlength="25" 
							value="<%= (user.getIcq() != null)? user.getIcq() : "" %>"/><br />

			<!-- ############# MSN ###############  -->
			<div class="textNormal"><b:i18n key="USER_MSN"/>:</div>
			<input type="text" name="msn" size="25" maxlength="25" 
							value="<%= (user.getMsn() != null)? user.getMsn() : "" %>"/><br />

			<!-- ############# YAHOO ###############  -->
			<div class="textNormal"><b:i18n key="USER_YAHOO"/>:</div>
			<input type="text" name="yahoo" size="25" maxlength="25" 
							value="<%= (user.getYahoo() != null)? user.getYahoo() : "" %>"/><br />

			<!-- ############# JABBER ###############  -->
			<div class="textNormal"><b:i18n key="USER_JABBER"/>:</div>
			<input type="text" name="jabber" size="25" maxlength="25" 
							value="<%= (user.getJabber() != null)? user.getJabber() : "" %>"/><br />

			<!-- ############# HOMEPAGE ###############  -->
			<div class="textNormal"><b:i18n key="USER_HOMEPAGE"/>:</div>
			<input type="text" name="homepage" size="25" maxlength="25" 
							value="<%= (user.getHomepage() != null)? user.getHomepage() : "" %>"/><br />

			<!-- ############# BIO ###############  -->
			<div class="textNormal"><b:i18n key="USER_BIO"/>:</div>
			<textarea cols="43" rows="15" name="bio"><%= (user.getBioRaw() != null)? user.getBioRaw() : "" %></textarea><br />
			
			<!-- ############# BIRTHDAY ###############  -->
			<div class="textRequired"><b:i18n key="USER_BIRTHDAY"/>:</div>
			<% 
			Date birthday = user.getBirthday();
			Calendar c = Calendar.getInstance();
			if (birthday != null) c.setTime(birthday);
			%>
			<select size="1" name="day">
			<%
			int day = c.get(Calendar.DAY_OF_MONTH);
			for (int i=1; i<=31; i++){%>
				<option value="<%=i%>" <%=(i==day)? "selected":""%>><%=i%></option>
			<%}%>
			</select>
			<select size="1" name="month">
			<%
			int month = c.get(Calendar.MONTH) +1 ;
			for (int i=1; i<=12; i++){%>
				<option value="<%=i%>"<%=(i==month)? "selected":""%>><%=i%></option>
			<%}%>
			</select>
			<select size="1" name="year">
			<%
			int year = c.get(Calendar.YEAR);
			for (int i=1950; i<=1995; i++){%>
				<option value="<%=i%>"<%=(i==year)? "selected":""%>><%=i%></option>
			<%}%>
			</select><br />

			<!-- ############# SHOW EMAIL? ###############  -->
			<div class="textRequired"><b:i18n key="USER_SHOW_EMAIL"/></div>
			<input type="checkbox" name="showEmail" <%=(user.getUserSettings().getShowEmail())? "checked" : "" %>/><br />

			<input type="submit" name="edit profile" value="<b:i18n key="EDIT_PROFILE_BUTTON"/>" />
		</form>
	</div>	
</div>		

<%@ include file="../include/footer.jsp" %>
