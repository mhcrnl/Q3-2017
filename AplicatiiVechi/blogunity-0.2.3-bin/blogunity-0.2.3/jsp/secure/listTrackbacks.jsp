<%@ include file="../include/header.jsp"%>


<div id="contentLayer">
<div class="title"><b:i18n key="ENTRY_TRACKBACKS_TITLE" /></div>

<br/>
<div class="smalltitle"><b:i18n key="INCOMING_TRACKBACKS_TITLE" /></div>
<div class="description"><b:i18n key="ENTRY_TRACKBACKS_DESC" /></div>
<display:table id="incoming" name="incomingTrackbacks"
	decorator="com.j2biz.blogunity.web.decorator.TrackbacksTableDecorator"
	requestURI="listTrackbacks.secureaction" pagesize="20" defaultsort="1"
	defaultorder="descending" sort="list">
	<display:column property="url" titleKey="TRACKBACK_URL" sortable="true"
		headerClass="sortable" />
	<display:column property="title" titleKey="TRACKBACK_TITLE"
		sortable="true" headerClass="sortable" />
	<display:column property="direction" titleKey="TRACKBACK_DIRECTION" />
	<display:column property="loggedIp" titleKey="TRACKBACK_LOGGED_IP"
		sortable="true" headerClass="sortable" />
	<display:column property="decoratedDate"
		titleKey="TRACKBACK_RECEIVE_TIME" sortable="true"
		headerClass="sortable" sortProperty="date" />
	<display:column property="content" titleKey="TRACKBACK_CONTENT" />
	<display:column property="actions" titleKey="ACTIONS" />
</display:table> <br />
<br />

<div class="smalltitle"><b:i18n key="OUTGOING_TRACKBACKS_TITLE" /></div>
<display:table id="outgoing" name="outgoingTrackbacks"
	decorator="com.j2biz.blogunity.web.decorator.TrackbacksTableDecorator"
	requestURI="listTrackbacks.secureaction" pagesize="20" defaultsort="1"
	defaultorder="descending" sort="list">
	<display:column property="url" titleKey="TRACKBACK_URL" sortable="true"
		headerClass="sortable" />
	<display:column property="direction" titleKey="TRACKBACK_DIRECTION" />
	<display:column property="status"
		titleKey="TRACKBACK_OUTGOING_STATUS" sortable="true"
		headerClass="sortable" sortProperty="registerTime" />
	<display:column property="decoratedDate" titleKey="TRACKBACK_SENT_TIME"
		sortable="true" headerClass="sortable" sortProperty="date" />
</display:table>

</div>


<%@ include file="../include/footer.jsp"%>

