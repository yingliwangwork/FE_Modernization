<%@ page language="java" contentType="text/html; charset=big5" pageEncoding="BIG5" %>
<%@ page import="com.cathay.common.test.EbafFrameworkTester"%>
<!DOCTYPE html> 
<html> 
	<head> 
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
	<% request.getSession().invalidate(); %>
	<%
	String targetHost = "//" + request.getServerName();
	%>
	<script>
	$(document).ready(function(){
	
		$("#btn_confirm").bind('click', function(event){
				
			event.preventDefault();	
			var targetPage = $(this).attr('href');
							
			$.mi.ajax({
			
				url: '${dispatcher}/MIMain/input?newTxRequest=true',
				data: {'userID':$('#userID').val(), 'passWD':$('#passWD').val(), 'isMobile':$('#isMobile').val(), 'hostName':'<%=request.getServerName()%>'},
				loadingMsg : '登入中請稍候',
				success: function(resp){
				
					if(resp.useMI) {
						loginToMI();
						return;
					}
					window.location = targetPage;
						
				}
			
			});
			
		});
		
		function loginToMI() {
					
			var $form = $('<form>'),
				protocol = window.location.protocol;
			$form.attr('method', 'post');
			$form.attr('action', protocol + '<%=targetHost%>'.replace( /was\d*/, 'mi' ) + '/ALWeb/servlet/HttpDispatcher/MIMain/inputApp?newTxRequest=true');
			$form.append( $('<input type="hidden" name="userID">').val($('#userID').val()) );
			$form.append( $('<input type="hidden" name="isMobile">').val($('#isMobile').val()) );
			$form.append( $('<input type="hidden" name="passWD">').val($('#passWD').val()) );
			$form.append( $('<input type="hidden" name="hostName">').val($('#hostName').val()) );
			
			$(document.body).append($form);
			
			setTimeout(
				function(){
					$.mi.showLoadingMsg('登入中請稍候');
					$form.submit();
				},
			100);			
			
		
		}
		
	});
	</script>
	</head> 
	<body>
		<div data-role="page" id="login">
			<div data-role="header" data-theme="mi" data-position="fixed">
				<h1>國泰人壽行動保險服務櫃檯</h1>
			</div>
			<div data-role="content" align="center">
				<div data-role="fieldcontain"> 
					<label>帳號:</label> 
					<input type="text" name="userID" id="userID" value="" style="width:150px" maxlength="10"/> 
				</div>
				<div data-role="fieldcontain"> 
					<label for="search">密碼:</label> 
					<input type="password" name="passWD" id="passWD" value="" style="width:150px" maxlength="20"/> 
				</div>
				<div data-role="controlgroup" data-type="horizontal">
					<a href="${htmlBase}/CM/mobi/mi.index.jsp" id="btn_confirm" data-icon="gear" rel="external" data-role="button" data-theme="b" >登入</a>
					<input name="isMobile" id="isMobile" type="hidden" value="1">
				</div>
			</div>
			<div data-role="footer" data-theme="mi" data-position="fixed">
				<h4>Enrich Your Life</h4>
			</div>
		</div>
	</body>
</html>