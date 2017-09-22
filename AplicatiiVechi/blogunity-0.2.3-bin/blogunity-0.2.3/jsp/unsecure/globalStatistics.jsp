<%@ include file="../include/header.jsp" %>

	<div id="contentLayer">
		<div class="title"><b:i18n key="STATISTICS_TITLE"/></div>
		<div class="description">
			<b:i18n key="STATISTICS_DESC"/>
		</div>

		<div class="text">
			<ul>
				<li><b:i18n key="STATISTICS_USERS_NUMBER"/>: <%= request.getAttribute("totalUsers") %></li>
				<li><b:i18n key="STATISTICS_INDIVIDUAL_BLOGS_NUMBER"/>: <%= request.getAttribute("individualBlogs") %></li>
				<li><b:i18n key="STATISTICS_COMMUNITY_BLOGS_NUMBER"/>: <%= request.getAttribute("communityBlogs") %></li>
				<li><b:i18n key="STATISTICS_POST_NUMBER"/>: <%= request.getAttribute("totalPosts") %></li>
				<li><b:i18n key="STATISTICS_COMMENTS_NUMBER"/>: <%= request.getAttribute("totalComments") %></li>
			</ul>
		</div>

	</div>	
<%@ include file="../include/footer.jsp" %>