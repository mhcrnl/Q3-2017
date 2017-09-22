<%
if (!com.j2biz.blogunity.BlogunityManager.getSystemConfiguration().isAllowNewUsers()) 
		throw new com.j2biz.blogunity.exception.BlogunityException(I18NStatusFactory.create(I18N.ERRORS.USER_REGISTERING_NOT_ALLOWED));
		
FormErrorList errors = (FormErrorList) request.getAttribute("errors");
User newUser = (User) request.getAttribute("newUser");
ArrayList locales = (ArrayList)request.getAttribute("locales");
if (newUser == null) newUser = new User();
%>
<%@ include file="../include/header.jsp" %>

<div id="contentLayer">
	<div class="title"><b:i18n key="REGISTER_TITLE"/></div>
	<div class="description">
		<b:i18n key="REGISTER_DESC"/>
	</div>
	<div id="formLayer">
		<form method="post" action="<%=ctx%>/registerUserExec.action">

			<!-- ############# NICKNAME ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("nickname")){ %>
			<div class="textError" onclick="toggle('errorLayerNickname')"><b:i18n key="USER_NICKNAME"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="USER_NICKNAME"/>:</div> 
			<%}%>
			<input type="text" name="nickname" size="25" maxlength="10" 
							value="<%= (newUser.getNickname() != null)? newUser.getNickname() : "" %>"/><br />
			<%=utils.showErrorsLayer(errors, "nickname")%>


			<!-- ############# PASSWORD ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("password")){ %>
			<div class="textError" onclick="toggle('errorLayerPassword')"><b:i18n key="USER_PASSWORD"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="USER_PASSWORD"/>:</div> 
			<%}%>
			<input type="password" name="password" size="25" maxlength="10"  
						value="<%= (newUser.getPassword() != null)? newUser.getPassword() : "" %>"/><br />
			<%=utils.showErrorsLayer(errors, "password")%>



			<!-- ############# FIRSTNAME ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("firstname")){ %>
			<div class="textError" onclick="toggle('errorLayerFirstname')"><b:i18n key="USER_FIRSTNAME"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="USER_FIRSTNAME"/>:</div> 
			<%}%>
			<input type="text" name="firstname" size="25" maxlength="25"  
							value="<%= (newUser.getFirstname() != null)? newUser.getFirstname() : "" %>"/><br />
			<%=utils.showErrorsLayer(errors, "firstname")%>
		

			<!-- ############# LASTNAME ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("lastname")){ %>
			<div class="textError" onclick="toggle('errorLayerLastname')"><b:i18n key="USER_LASTNAME"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="USER_LASTNAME"/>:</div> 
			<%}%>
			<input type="text" name="lastname" size="25" maxlength="25"  
						value="<%= (newUser.getLastname() != null)? newUser.getLastname() : "" %>"/><br />
			<%=utils.showErrorsLayer(errors, "lastname")%>		

			<!-- ############# EMAIL ###############  -->
			<%if (errors!=null && errors.containsErrorsForKey("email")){ %>
			<div class="textError" onclick="toggle('errorLayerEmail')"><b:i18n key="USER_EMAIL"/>:</div> 
			<%}else{ %>
			<div class="textRequired"><b:i18n key="USER_EMAIL"/>:</div> 
			<%}%>
			<input type="text" name="email" size="25" maxlength="25"  
						value="<%= (newUser.getEmail() != null)? newUser.getEmail() : "" %>"/><br />
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
				<option value="<%=locale.toString()%>" <%=(newUser.getLanguage().equals(locale)? "selected" : "")%>>
					<%=locale.getDisplayLanguage(newUser.getLanguage())%>
				</option>

			<%} %>
			</select><br />
			<%=utils.showErrorsLayer(errors, "language")%>

			<!-- ############# SEX ###############  -->
			<div class="textRequired"><b:i18n key="USER_SEX"/>:</div> 
			<select size="1" name="sex">
				<option value="<%= User.MALE%>" <%=(newUser.getSex() == User.MALE)? "selected" : ""%>>male</option>
				<option value="<%= User.FEMALE%>" <%=(newUser.getSex() == User.FEMALE)? "selected" : ""%>>female</option>
			</select><br />

			<!-- ############# ICQ ###############  -->
			<div class="textNormal"><b:i18n key="USER_ICQ"/>:</div>
			<input type="text" name="icq" size="25" maxlength="25" value="<%= (newUser.getIcq() != null)? newUser.getIcq() : "" %>"/><br />

			<!-- ############# MSN ###############  -->
			<div class="textNormal"><b:i18n key="USER_MSN"/>:</div>
			<input type="text" name="msn" size="25" maxlength="25" value="<%= (newUser.getMsn() != null)? newUser.getMsn() : "" %>"/><br />

			<!-- ############# YAHOO ###############  -->
			<div class="textNormal"><b:i18n key="USER_YAHOO"/>:</div>
			<input type="text" name="yahoo" size="25" maxlength="25" value="<%= (newUser.getYahoo() != null)? newUser.getYahoo() : "" %>"/><br />

			<!-- ############# JABBER ###############  -->
			<div class="textNormal"><b:i18n key="USER_JABBER"/>:</div>
			<input type="text" name="jabber" size="25" maxlength="25" value="<%= (newUser.getJabber() != null)? newUser.getJabber() : "" %>"/><br />

			<!-- ############# HOMEPAGE ###############  -->
			<div class="textNormal"><b:i18n key="USER_HOMEPAGE"/>:</div>
			<input type="text" name="homepage" size="25" maxlength="25" value="<%= (newUser.getHomepage() != null)? newUser.getHomepage() : "" %>"/><br />

			<!-- ############# BIO ###############  -->
			<div class="textNormal"><b:i18n key="USER_BIO"/>:</div>
			<textarea cols="43" rows="15" name="bio"><%= (newUser.getBioRaw() != null)? newUser.getBioRaw() : "" %></textarea><br />
			
			<!-- ############# BIRTHDAY ###############  -->
			<div class="textRequired"><b:i18n key="USER_BIRTHDAY"/>:</div>
			<% 
			Date birthday = newUser.getBirthday();
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
			<input type="checkbox" name="showEmail" <%=(newUser.getUserSettings().getShowEmail())? "checked" : "" %>"/><br />

			<!-- ############# REGISTER BUTTON ###############  -->
			<input type="submit" name="register" value="<b:i18n key="REGISTER_BUTTON"/>" />
		</form>
	</div>	
</div>		

<%@ include file="../include/footer.jsp" %>