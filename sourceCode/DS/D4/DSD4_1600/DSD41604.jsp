<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<html>
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSD41604.jsp
功能：電子簽收條
作者：黃柏堯
完成：2021-07-14

[20220301]問題單[20220225170250]
電子簽收條，中華民國年月日主動帶系統日期
作者：高強禾

-->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/jquery/jquery-3.6.0.js"></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src="${htmlBase}/CM/js/jquery/plugins/jSignature/jSignature.min.js"></script>


<%-- [20220301]問題單[20220225170250] 電子簽收條，中華民國年月日主動帶系統日期 --%>
<style>
	.backgroudPic {
		background-image: url(../../../images/DSD41604/DSD41604_background.jpg);
		height:1172px;
	}
	
	#showDiv {
		position: relative;
	    width: 827px;
	    overflow:scroll;
		margin:auto;
	}
	
	#signDiv{
		position: relative;
		margin:auto;
	}
	
	#sign {
	    position: relative;
	    background-color : #DCDCDC;
		margin:auto;
	}
	
	#signPic {
	    position: absolute;
	    width: 250px;
	    height:100px;
	    top: 775px;
	    left: 200px;
	}
	
	#APPLY_DATE_ROC {
	    position: absolute;
	    top: 81px;
	    left: 185px;
	}
	
	#RECEIVE_DEPT {
	    position: absolute;
	    top: 109px;
	    left: 150px;
	}
	
	#BORROW_NAME {
	    position: absolute;
	    top: 137px;
	    left: 132px;
	}
	
	#BORROW_NAME_RM {
	    position: absolute;
	    top: 164px;
	    left: 59px;
	}
	
	#LOAN_IDS {
	    position: absolute;
	    top: 221px;
	    left: 150px;
	}
	
	#SIGN_TXT1 {
	    position: absolute;
	    top: 291px;
	    left: 700px;
	    text-align: center;
	}
	
	#SIGN_TXT2 {
	    position: absolute;
	    top: 319px;
	    left: 700px;
	    text-align: center;
	}
	
	#SIGN_TXT3 {
	    position: absolute;
	    top: 347px;
	    left: 700px;
	    text-align: center;
	}
	
	#SIGN_TXT4 {
	    position: absolute;
	    top: 375px;
	    left: 700px;
	    text-align: center;
	}
	
	#SIGN_TXT5 {
	    position: absolute;
	    top: 403px;
	    left: 700px;
	    text-align: center;
	}
	
	#SIGN_TXTOT {
	    position: absolute;
	    top: 456px;
	    left: 150px;
	}
	
	#RECEIVE_ROLE_01 {
		position: absolute;
	    top: 676px;
	    left: 60px;
	    font-size: 25;
	}
	
	#RECEIVE_ROLE_03 {
		position: absolute;
	    top: 676px;
	    left: 177px;
	    font-size: 25;
	}
	
	#RECEIVE_ROLE_02 {
		position: absolute;
	    top: 676px;
	    left: 313px;
	    font-size: 25;
	}
	
	#RECEIVE_ROLE_04 {
		position: absolute;
	    top: 676px;
	    left: 430px;
	    font-size: 25;
	}
	
	#year {
		position: absolute;
		top: 885px;
		left: 465px;
		text-align: center;
	}
	
	#month {
		position: absolute;
		top: 885px;
		left: 581px;
		text-align: center;
	}
	
	#day {
		position: absolute;
		top: 885px;
		left: 700px;
		text-align: center;
	}
	
	#RECEIVE_ID {
	    position: absolute;
	    top: 718px;
	    left: 180px;
	}
	
	#RECEIVE_TEL {
	    position: absolute;
	    top: 718px;
	    left: 477px;
	}
	
	#RECEIVE_MEMO {
	    position: absolute;
	    top: 756px;
	    left: 180px;
	}
	
	#SEND_BACK {
	    position: absolute;
	    top: 992px;
	    left: 418px;
	    font-size: 10px;
	}
	
	#SEND_BACK_DIV {
	    position: absolute;
	    top: 959px;
	    left: 450px;
	    font-size: 10px;
	}
	
	#SEND_BACK_DIV_ADDR {
	    position: absolute;
	    top: 975px;
	    left: 170px;
	    font-size: 10px;
	}
	
	@font-face{
		font-family: 'EUDC';
		src: url('/DSWeb/hanlinks/eudc.ttf') format("truetype");
		font-weight:normal;
		font-style:normal
	}
</style>

<script type='text/javascript'>

	$(document).ready(function () {
		new DSD41604().initApp();
	});
		
	//--------------------------------------------------------------------------
	function DSD41604() {
		
		var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSD4_1604/');
		var postData = <c:out value="${postData}" default="{}" escapeXml="false" />;
		var RCVD_DATA = <c:out value="${RCVD_DATA}" default="{}" escapeXml="false" />;
		var buttons = {
				
			// 確認上傳
			doComplete: function () {
				
				// 將畫布內容轉換為圖片
                var signData = $("#signPic").attr('src_base64_data');

               	postData.imgStr = signData;
               	ajaxRequest.post('complete', { 'postData':JSON.stringify(postData), 'RCVD_DATA':JSON.stringify(RCVD_DATA) }, function(resp) {
					alert('上傳完成');
					parent.popupWin.close();
               	});
			},
			
			// 重新簽名
			doReset: function (){
				$('#showDiv').hide();
				$('#signDiv').show();
				$("#sign").jSignature("reset");
                $('#signPic').hide();
				$('#signPic').attr('src','');
				$('#btn_complete').hide();
				$('#btn_review').show();
			},
			
			// 開始簽名
			doStartSign : function(){
				$('#showDiv').hide();
				$('#signDiv').show();
				$('#btn_startSign').hide();
				$('#btn_review').show();
				$('#btn_reset').show();
			},
			
			// 預覽簽名
			doReview : function(){
				if($("#sign").jSignature('getData', 'native').length === 0){
	                alert('請先簽名');
	                return;
				}
				
				$('#showDiv').show();
				$('#signDiv').hide();
				$('#btn_review').hide();
				$('#btn_complete').show();
				
				// 將畫布內容轉換為圖片
                var datapair = $("#sign").jSignature("getData", "image");
                $('#signPic').show();
				$('#signPic').attr('src','data:'+datapair[0]+','+datapair[1]);
				$('#signPic').attr('src_base64_data',datapair[1]);
			}
		};
		
		var actions = {
			//為響應不同裝置大小，by popwin大小控制顯示區域高度
			fixShowDivHeight:function(){
				var window_heigth = window.innerHeight-60;
				$('#showDiv').height(window_heigth);
				
				var window_width = window.innerWidth-30;
				var new_heigth;
				var new_width;
				if(window_heigth*2.5 < window_width){
					new_heigth = window_heigth;
					new_width = window_heigth*2.5;
				}else{
					new_heigth = window_width/2.5;
					new_width = window_width;
				}
				$('#sign').height(new_heigth-10);
				$('#sign').width(new_width);
				//註冊簽名區域
				$("#sign").jSignature({
					'background-color':'transparent',
					'decor-color':'transparent', 
					'lineWidth':'1',
					'height':new_heigth, 
					'width':new_width});
			}		
		}
		
		return {
			
			initApp : function() {
				PageUI.createPageWithAllBodySubElement('DSD41604', '電子簽收條', '報表上傳', 0, true);
				
				$('#btn_startSign').on('click', buttons.doStartSign);
				$('#btn_review').on('click', buttons.doReview);
				$('#btn_reset').on('click', buttons.doReset);
				$('#btn_complete').on('click', buttons.doComplete);
				
				<%--[20230413] 問題單: 20230411150842 陳勁谷 修改網頁顯示跟列印難字問題 --%>
				$('#REFER_ID').text(postData.REFER_ID);
				$('#APPLY_DATE').text(postData.APPLY_DATE);
				$('#LOAN_IDS').text(postData.LOAN_IDS);
				$('#APPLY_DATE_ROC').text(postData.APPLY_DATE_ROC);
				$('#SIGN_TXT1').text(postData.SIGN_TXT1);
				$('#SIGN_TXT2').text(postData.SIGN_TXT2);
				$('#SIGN_TXT3').text(postData.SIGN_TXT3);
				$('#SIGN_TXT4').text(postData.SIGN_TXT4);
				$('#SIGN_TXT5').text(postData.SIGN_TXT5);
				<%-- [20220301]問題單[20220225170250] 電子簽收條，中華民國年月日主動帶系統日期 --%>
				$('#year').text(postData.year);
				$('#month').text(postData.month);
				$('#day').text(postData.day);
				<%-- [20230328181334][20220410]新增欄位-領取角色 --%>
				$('#RECEIVE_ROLE_01').text(postData.RECEIVE_ROLE_01);
				$('#RECEIVE_ROLE_02').text(postData.RECEIVE_ROLE_02);
				$('#RECEIVE_ROLE_03').text(postData.RECEIVE_ROLE_03);
				$('#RECEIVE_ROLE_04').text(postData.RECEIVE_ROLE_04);
				$('#RECEIVE_ID').text(postData.RECEIVE_ID);
				$('#RECEIVE_TEL').text(postData.RECEIVE_TEL);

				actions.fixShowDivHeight();
				
				displayMessage();
				
			}		
		};
	}

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING: 0px; MARGIN: 0px;">	
		
		<div id="showDiv" >
			<%--[20230413] 問題單: 20230411150842 陳勁谷 修改網頁顯示跟列印難字問題 --%>
			<div id="backgroudPic" class="backgroudPic"></div><!-- 底圖 -->
			<div id="APPLY_DATE_ROC" class="APPLY_DATE_ROC"></div>
			<div id="RECEIVE_DEPT" class="RECEIVE_DEPT" style="font-family:'EUDC'">${postData_t.RECEIVE_DEPT}</div>
			<div id="BORROW_NAME" class="BORROW_NAME" style="font-family:'EUDC'">${postData_t.BORROW_NAME}</div>
			<div id="BORROW_NAME_RM" class="BORROW_NAME_RM" style="font-family:'EUDC'">${postData_t.BORROW_NAME_RM}</div>
			<div id="LOAN_IDS" class="LOAN_IDS"></div>
			<div id="SIGN_TXT1" class="SIGN_TXT1"></div>
			<div id="SIGN_TXT2" class="SIGN_TXT2"></div>
			<div id="SIGN_TXT3" class="SIGN_TXT3"></div>
			<div id="SIGN_TXT4" class="SIGN_TXT4"></div>
			<div id="SIGN_TXT5" class="SIGN_TXT5"></div>
			<div id="SIGN_TXTOT" class="SIGN_TXTOT" style="font-family:'EUDC'">${postData_t.SIGN_TXTOT}</div>
			<img id="signPic" class="signPic" src="" style="display:none;"/>
			<%-- [20220301]問題單[20220225170250] 電子簽收條，中華民國年月日主動帶系統日期 --%>
			<div id="year" class="year"></div>
			<div id="month" class="month"></div>
			<div id="day" class="day"></div>
			<%-- [20230328181334][20220410]新增欄位-領取角色 --%>
			<div id="RECEIVE_ROLE_01" class="RECEIVE_ROLE_01"></div>
			<div id="RECEIVE_ROLE_02" class="RECEIVE_ROLE_02"></div>
			<div id="RECEIVE_ROLE_03" class="RECEIVE_ROLE_03"></div>
			<div id="RECEIVE_ROLE_04" class="RECEIVE_ROLE_04"></div>
			<div id="RECEIVE_ID" class="RECEIVE_ID"></div>
			<div id="RECEIVE_TEL" class="RECEIVE_TEL"></div>
			<div id="RECEIVE_MEMO" class="RECEIVE_MEMO" style="font-family:'EUDC'">${postData_t.RECEIVE_MEMO}</div>
			<div id="SEND_BACK" class="SEND_BACK" style="font-family:'EUDC'">${postData_t.SEND_BACK}</div>
			<div id="SEND_BACK_DIV" class="SEND_BACK_DIV" style="font-family:'EUDC'">${postData_t.SEND_BACK_DIV}</div>
			<div id="SEND_BACK_DIV_ADDR" class="SEND_BACK_DIV_ADDR" style="font-family:'EUDC'">${postData_t.SEND_BACK_DIV_ADDR}</div>
		</div>
		<div id="btnDiv"><center>
			<button type="button" id="btn_startSign" class="button">開始簽名</button>
			<button type="button" id="btn_review" class="button" style="display:none;">預覽</button>
			<button type="button" id="btn_reset" class="button" style="display:none;">重新簽名</button>
			<button type="button" id="btn_complete" class="button" style="display:none;">確認上傳</button>
		</center></div>
		<div id="signDiv" style="display:none;"><!-- [20221109][20221107174502] 嘗試避免簽名時畫面跟著被拖拉 -->
			<div id="sign" style="touch-action: none;"></div><!-- 簽名區域 -->
		</div>
	</form>		
</body>
</html>