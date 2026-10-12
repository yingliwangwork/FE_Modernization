<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html;charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<!--
程式：DSD40130.jsp
功能：電子補發申請書
作者：楊青峰
完成：2021-05-14

[20230407] 問題單: 20230327162440 陳勁谷
1.更新底圖(含.簽名畫面、報表套印)修改style

[20230413] 問題單: 20230411150842 陳勁谷 修改網頁顯示跟列印難字問題

[20230503] 問題單: 20230502173214 陳勁谷
1.調整版面(簽名區、身份證字號、連絡電話、通訊地址等位置如圖)
2.固定底圖大小，避免使用App時會上下移動
-->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/jquery/jquery-3.6.0.js"></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src="${htmlBase}/CM/js/jquery/plugins/jSignature/jSignature.min.js"></script>

<style>
	.backgroudPic {
		background-image: url(../../../images/DSD40130/DSD40130_background.jpg);
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
	    top: 430px;
	    left: 390px;
	}
	
	#APPLYMAN_ID {
	    position: absolute;
	    top: 470px;
	    left: 196px;
	    font-size:25px;
	}
	
	#APPLYMAN_ADD {
	    position: absolute;
	    top: 544px;
	    left: 196px;
	    font-size:20px;
	}
	
	#APPLYMAN_TEL {
	    position: absolute;
	    top: 505px;
	    left: 196px;
	    font-size:25px;
	}
	
	#year {
		position: absolute;
		top: 595px;
		left: 290px;
		font-size:25px;
	}
	
	#month {
		position: absolute;
		top: 595px;
		left: 480px;
		font-size:25px;
	}
	
	#day {
		position: absolute;
		top: 595px;
		left: 660px;
		font-size:25px;
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
		new DSD40130().initApp();
	});
		
	//--------------------------------------------------------------------------
	function DSD40130() {
		
		var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSD4_0130/');
		var postData = <c:out value="${postData}" default="{}" escapeXml="false" />; 
		var buttons = {

			// 確認上傳
			doComplete: function () {
				// 將畫布內容轉換為圖片
                var signData = $("#signPic").attr('src_base64_data');
				
				postData.imgStr = signData;
               	<%--[20230413] 問題單: 20230411150842 陳勁谷 修改網頁顯示跟列印難字問題--%>
               	ajaxRequest.post('complete', postData, function(resp) {
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
				$("#sign").jSignature({'background-color':'transparent',
					'decor-color': 'transparent', 'lineWidth': '1',
					'height': new_heigth, 'width': new_width});
			}		
		}
		
		return {
			
			initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSD40130', '清償作業', '電子補發申請書', 0, true);

				$('#btn_startSign').on('click', buttons.doStartSign);
				$('#btn_review').on('click', buttons.doReview);
				$('#btn_reset').on('click', buttons.doReset);
				$('#btn_complete').on('click', buttons.doComplete);
				
				<%--[20221206173838][20221207]修正電子補發申請書無套印之問題--%>
				$('#APPLYMAN_ID').text(postData.APPLYMAN_ID);
				$('#APPLYMAN_TEL').text(postData.APPLYMAN_TEL);
				$('#year').text(postData.year);
				$('#month').text(postData.month);
				$('#day').text(postData.day);

				actions.fixShowDivHeight();
				
				PageUI.resize();
				displayMessage();
			}		
		};
	}

</script>
</head>
<body>
	<form id="form1" name="form1" style="PADDING: 0px; MARGIN: 0px;">
		<div id="showDiv" >
			<div id="backgroudPic" class="backgroudPic"></div><!-- 底圖 -->
			
			<div id="APPLYMAN_ID" class="APPLYMAN_ID"></div>
			<div id="APPLYMAN_TEL" class="APPLYMAN_TEL"></div>
			
			<%--[20230413] 問題單: 20230411150842 陳勁谷 修改網頁顯示跟列印難字問題 --%>
			<div id="APPLYMAN_ADD" class="APPLYMAN_ADD" style="font-family:'EUDC'">${APPLYMAN_ADD}</div>
			
			<img id="signPic" class="signPic" src="" style="display:none;"/>
			
			<div id="year" class="year"></div>
			<div id="month" class="month"></div>
			<div id="day" class="day"></div>
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