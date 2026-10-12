<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ page import="com.cathay.common.test.EbafFrameworkTester"%>
<!DOCTYPE html> 
<html> 
	<head> 
	<meta isamLogin="samlLoginSuccessForAPP"> <%-- APP SAML登入成功判斷會抓此input的value，不可刪!!!! --%>
	<title>國泰人壽行動保險服務櫃檯</title>
	<% 
	response.setHeader("X-Frame-Options", "SAMEORIGIN");

	EbafFrameworkTester eBAFSpec = new EbafFrameworkTester(request);

	//以IP address檢核是否呈現頁面，正向表列可使用此頁面之IP address
	boolean isAuth = eBAFSpec.authUser(request);
	if(!isAuth){
		out.write("<!DOCTYPE html><html><body>No Permission.(" + eBAFSpec.getCleintIP() + ")</body></html>");
		return;
	}
	%>
	<%@ include file="/html/CM/mobi/mi.header.jsp"%>
	<script src="data.js"></script>
	<script src="control.js"></script>
</head> 
<body>

<%
String useMI = (String)pageContext.getAttribute( "useMI" );

String targetHost = request.getScheme() + "://" + request.getServerName();

//若需使用 JBoss 服務，並且目前是由 WAS 服務的，才自動跳轉到 JBoss
if( Boolean.valueOf(useMI) && !request.getServerName().contains("mi.cathaylife.com") ) {
	
	targetHost = targetHost.replaceFirst( "was\\d*", "mi" );
	pageContext.setAttribute( "toMI", "true" );
	
}

%>
<div data-role="page" 
 	 id="jqm-home" 
 	 class="type-home" 	
	 data-mi-subcode="${subcode}" 
	 data-mi-sysindex="${sysindex}" 
	 data-mi-index="${index}" 
 	 data-mi-dispatcher="${dispatcher}"
 	 data-mi-js="${htmlBase}/CM/mobi/mi.index.js"
	 data-mi-syindex="${sysIndex}"
	 data-mi-sbindex="${index}" > 

	<div data-role="header" data-theme="mi" data-position="fixed">
		<h1 align="center">行動保險服務櫃檯<%if(request.getServerName().contains("mi.cathaylife.com")){%>(MI)<%}%></h1> 
		<a href="${miHome}" rel="external" data-icon="home" data-iconpos="notext" data-direction="reverse" class="ui-btn-left" id="hhome">Home</a> 
		<a href="" rel="external" data-icon="back" data-iconpos="notext" data-direction="reverse" class="ui-btn-left jqm-home" id="hback">上一步</a>
		<a href="${miLogout}" rel="external" data-icon="back" data-iconpos="notext" data-direction="reverse" class="ui-btn-right" id="hout">登出</a>
	</div>
	
	<div data-role="content"> 
		
		<div class="content-secondary"> 
			<div id="jqm-homeheader"> 
				<div data-role="collapsible" data-collapsed="false" data-theme="c" id="mBoard"> 
					<ul data-role="listview" data-inset="true" data-theme="c" data-dividertheme="mi" > 
					</ul> 
				</div>
				<div data-role="collapsible" data-collapsed="false" data-theme="c" id="subBoard"> 
					<ul data-role="listview" data-inset="true" data-theme="c" data-dividertheme="mi" > 
					</ul> 
				</div>
				<div data-role="collapsible" data-collapsed="false" data-theme="c" id="toplink"> 
					<ul data-role="listview" data-inset="true" data-theme="c" data-dividertheme="mi" >
					</ul>
				</div>
			</div> 
		</div>
		
		<div class="content-primary" id="hot">
			<div data-role="collapsible" data-collapsed="false" data-theme="c" id="com_notice"> 
					<ul  data-role="listview" data-inset="true" data-theme="c" data-dividertheme="mi">
						<!-- 2013.10.23 新增待補全通知區塊 -->
					</ul>
			</div>
			<div data-role="collapsible" data-collapsed="false" data-theme="c" id="hotNews"> 
					<ul  data-role="listview" data-inset="true" data-theme="c" data-dividertheme="mi">
						<!-- Hot News -->
					</ul>
			</div>
		</div>
		
	</div> 
	
	<div data-role="footer" data-theme="mi" data-position="fixed"> 
		<h4>&nbsp;</h4>
	</div>

</div> 
</body> 
</html> 