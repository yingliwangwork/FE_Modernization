<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSC31000.jsp
作者：熊偉翔
功能：ATM劃撥媒體
完成：2012/11/21

240904問題單編號20240410-0083銷帳媒體上傳優化
優化程式，上傳動作增加cover page，避免連續執行造成資料重複及排程異常
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<title></title>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script> <!--alert訊息-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/javascript">

var DSC31000 = new DSC31000();

//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', DSC31000.initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function buttonAuth(){
	var authButtons = {
		B0152:"count_JOB" <%--執行入帳 --%>
	};
	
	<dz:grantButtons FUNC_ID="DSC31000" ignored="false"/>	
}


//以下為UI() public method,放在 return 中
function DSC31000(){
	
	var valid1;	
	
	var path;
	
	var ATM_TYPE ;
	
	<%--CoverPage(鎖定/開放畫面)--%>
	var cover;
	var auxiliary = {
		createCoverPage : function() {
			cover = CSRUtil.createCoverPage('_frontCover');
			cover.show();
		}
		, closeCoverPage : function() {
			if (cover) {
				cover.hide();
			}
		}
	};
	
	//畫面檢核(設定)	
	function initValidation(){
		
		valid1 = new Validation('form1', { focusOnError:true, immediate:false });
			
		Validation.add( "validate-isATMLOGTXT" , "匯入檔案必須為Atmlog.TXT!" , isATMLOGTXT );
		
		Validation.add( "validate-isREMITBKTXT" , "匯入檔案必須為remitbk.TXT!" , isREMITBKTXT );
		
		//Validation.add( "validate-isXXXTXT" , "匯入檔案必須為XXX.TXT!" , isXXXTXT );
		
	}
	
	//檢核是否為ATMLOG.TXT檔
	function isATMLOGTXT(){
		path = $('MEDIA_FILE').value;
		var index = path.lastIndexOf('Atmlog');
		return index != -1;
	}
	
	//檢核是否為REMITBK.TXT檔
	function isREMITBKTXT(){
		path = $('MEDIA_FILE').value;
		var index = path.lastIndexOf('remitbk');
		return index != -1;
	}
	
	//檢核是否為XXX.TXT檔
	function isXXXTXT(){
		path = $('MEDIA_FILE').value;
		var index = path.lastIndexOf('XXX');
		return index != -1;
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_1000/" + actionName,
			{  
				parameters: params, 
				onSuccess:function(response){
					var resp = response.responseJSON;
					if(CSRUtil.isSuccess(resp)){	
						if(successFunction){
							successFunction(resp);
						}
					}else{
						if(errorFunction){
							errorFunction(resp);
						}
					}
				}			
			});
	}	
	
	//-------------------------------------------------	
	//TableUI使用function
	//-------------------------------------------------
	//處理數值欄位部分(三位一撇)
	function formatNumber(val){
		 return CSRUtil.$fmt(val || 0, '#,##0.####'); 
	}
	
	//--------------------------------------------------------------------------
	// 功能按鈕
	//--------------------------------------------------------------------------	
	
	var buttons = {
		
		//執行入帳排程
		doCount_JOB : function(event){
			//發送Ajax,到後端執行 online batch
			ajaxPost('count_JOB', {'ATM_TYPE' :$F('ATM_TYPE'),'TRANS_NO':$F('TRANS_NO')});
				
		},
		//執行入帳排程
		doCount_JOB_Result : function(event){
			//發送Ajax,到後端執行 online batch
			
			ajaxPost( 'count_JOB_Result', {'ATM_TYPE' :$F('ATM_TYPE')}
				,function(resp){
				    $('MSG_TR').show();
					$('LOG_MESSAGE').innerHTML = resp.LOG_MESSAGE;
					
				},function(resp){ 
					$('LOG_MESSAGE').innerHTML = '';
					$('MSG_TR').hide();
					//如果失敗,把前一次的內容清掉
					
				}
			);
			
			
				
		},
		//匯入	
		doUpload:function(event){
				
				valid1.reset();	
				valid1.clear();	
				
				valid1.define( "required" , { id: "MEDIA_FILE" , errMsg: "請選取要匯入的檔案"} );		
				
				ATM_TYPE = $F('ATM_TYPE');
				
				if($F('MEDIA_FILE')){	

					if(!($('MEDIA_FILE').value).match(/(.(txt))$/i)){
						alert('檔案格式錯誤(匯入檔案必須為TXT檔)');
						return;
					}
				
					if(ATM_TYPE === '1'){
						
						valid1.define( "validate-isATMLOGTXT" ,  [{ id : "MEDIA_FILE" , errMsg:"匯入檔案必須為Atmlog.TXT!"}] );
						
					} else if(ATM_TYPE === '2'){
					
						valid1.define( "validate-isREMITBKTXT" , [{ id : "MEDIA_FILE" , errMsg:"匯入檔案必須為remitbk.TXT!"}] );
					} /*else if(ATM_TYPE === '3'){
					
						valid1.define( "validate-isXXXTXT" , [{ id : "MEDIA_FILE" , errMsg:"匯入檔案必須為XXX.TXT!"}] );
					}*/
				}
				
				if(!valid1.validate()){ 
					return; 
				}
				//初始進頁面的時候,隱藏部分顯示欄位
				$w('ONE TWO THREE FOUR').each(
					function(id) {
						$(id + '_TR').hide();
					}
				);
				
				//把檔案匯入
				auxiliary.createCoverPage();
				document.form1.submit();
				
			} ,
			
		//匯入結束的處理
		importEnd:function(event){
				
				var obj = window.importFrame.document.getElementById("filedata").innerHTML.evalJSON();
				
				if(CSRUtil.isSuccess(obj)){
					
					if($F("ATM_TYPE") === "1"){
						
						//先顯示清單
						$w('ONE TWO THREE FOUR').each(
							function(id) {
								$(id + '_TR').show();
							}
						);
						
						//之後把值填入
						var rtnMap = obj.rtnMap;
						$w('TOT_CNT TOT_AMT TOT1_CNT TOT1_AMT TOT2_CNT TOT2_AMT UPLOAD_CNT UPLOAD_AMT OTHET_CNT OTHER_AMT RECOVER_CNT').each(
							function(id) {
								$(id + '_SPAN').update( formatNumber (rtnMap[id] ) );
							}
						);
						$('RECOVER_DETAIL_SPAN').update(rtnMap['RECOVER_DETAIL']);
						
					}else if($F("ATM_TYPE") === "3"){
						//先顯示清單
						$('ONE_TR').show();
						$('FOUR_TR').show();
						$w('TWO THREE').each(
							function(id) {
								$(id + '_TR').hide();
							}
						);
						
						//之後把值填入
						var rtnMap = obj.rtnMap;
						$w('TOT_CNT TOT_AMT UPLOAD_CNT UPLOAD_AMT RECOVER_CNT RECOVER_DETAIL').each(
							function(id) {
								$(id + '_SPAN').update( formatNumber (rtnMap[id] ) );
							}
						);
						$('RECOVER_DETAIL_SPAN').update(rtnMap['RECOVER_DETAIL']);
						
						//取得上傳媒體檔的電匯帳號，提供批次銷帳使用
						$('TRANS_NO').value=rtnMap.TRANS_NO;						
					}else {
						//先顯示清單
						$('ONE_TR').show();
						$w('TWO THREE').each(
							function(id) {
								$(id + '_TR').hide();
							}
						);
						
						//之後把值填入
						var rtnMap = obj.rtnMap;
						$w('TOT_CNT TOT_AMT UPLOAD_CNT UPLOAD_AMT ').each(
							function(id) {
								$(id + '_SPAN').update( formatNumber (rtnMap[id] ) );
							}
						);
					}
					//$('form1').reset() ;   
				}
				
				$("count_JOB").enable();
				
				auxiliary.closeCoverPage();
				
				//顯示訊息
				var Msg = obj.ErrMsg.msgDesc.replace("\\n","");
				
				if(Msg){
					alert(Msg);
				}
			}
		
	};


	return {
	
			initApp : function() {
				
				PageUI.createPageWithAllBodySubElement("DSC31000", "繳款方式", "ATM劃撥媒體");
				
				//-----------------------------------------------------
				//以下為進入初始頁面時需要執行的動作
				//-----------------------------------------------------
				
				//畫面檢核
				initValidation();
				
					
				//註冊DOM物件 : 監聽	
				
				//上傳
				$("btn_upload").observe('click',function(event){	
					buttons.doUpload();
				});
				
				//執行入帳
				$("count_JOB").observe('click',function(event){		
					buttons.doCount_JOB();
				});
				
				
				//執行入帳
				$("count_JOB_Result").observe('click',function(event){		
					buttons.doCount_JOB_Result();
				});
				
				//匯入結束
				$("importFrame").observe('load', function(event){ 	
					buttons.importEnd();
				});
				
				//初始進頁面的時候,隱藏部分顯示欄位
				$w('ONE TWO THREE FOUR').each(
					function(id) {
						$(id + '_TR').hide();
					}
				);
				
				
				//初始頁面alert訊息用	
				displayMessage();
				buttonAuth();
				PageUI.resize();
				$('MSG_TR').hide();
				$("count_JOB").disable();
				
			}// end initApp()
	};// end return--
}

</script>
</head>
<body>
<form name='form1' id='form1' method="post" target="importFrame" enctype="multipart/form-data" action="<%=dispatcher%>/DSC3_1000/upload" style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>
<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
		<tr>
		<td class='tbYellow' width='10%'>媒體種類</td>
		<td class='tbYellow2' width='35%'>
			<select id='ATM_TYPE' name = 'ATM_TYPE' class='textBox2'  > 
				<c:forEach var='item' items='${ATM_TYPE_List}'>
					<option value='${item.key}'><c:out value='${item.value}' /></option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow" width="10%">選取檔案</td>
		<td class="tbYellow2" width="35%">
			<input id="MEDIA_FILE" name="MEDIA_FILE" type="file" size="50" class="textBox2">
			<input id="btn_upload" type="button" class="button" value="檔案上傳">
			<input type="hidden" name="IMPORT_FILE" id="IMPORT_FILE" value="">
			<input type="hidden" name="TRANS_NO" id="TRANS_NO" value="">
		</td>
	</tr>	
	<tr>
		<td class="tbYellow2" colspan="5" align="center">
			<input type="button" class="button" id="count_JOB" value="執行入帳" />
			<input type="button" class="button" id="count_JOB_Result" value="查詢入帳結果" />
		</td>
	</tr>
	
	<tr id = "MSG_TR">
	     <td class="tbYellow2" colspan='10' align='center' >
			<div id="LOG_MESSAGE"  ></div>
		</td>
	</tr>
	<tr>
		<td class='tbBox3' colspan='10' align='center'>
			上傳結果
		</td>
	</tr>
</table>
</form>
<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
	<tr align='center' id = 'ONE_TR'>
		<td class='tbYellow' width='10%'>媒體總件數</td>
		<td class='tbYellow2' width='15%'>
			<span id='TOT_CNT_SPAN'><span>
		</td>
		<td class='tbYellow' width='10%'>媒體總金額</td>
		<td class='tbYellow2' width='15%'>
			<span id ='TOT_AMT_SPAN'><span>
		</td>
		<td class='tbYellow' width='10%'>上傳總件數</td>
		<td class='tbYellow2' width='15%'>
			<span id ='UPLOAD_CNT_SPAN'><span>
		</td>
		<td class='tbYellow' width='10%'>上傳總金額</td>
		<td class='tbYellow2' width='15%'>
			<span id ='UPLOAD_AMT_SPAN'><span>
		</td>
	</tr>
	<tr align='center' id = 'TWO_TR'>
		<td class='tbYellow' width='10%'>虛擬帳號件數</td>
		<td class='tbYellow2' width='15%'>
			<span id='TOT1_CNT_SPAN'><span>
		</td>
		<td class='tbYellow' width='10%'>虛擬帳號金額</td>
		<td class='tbYellow2' width='15%'>
			<span id ='TOT1_AMT_SPAN'><span>
		</td>
		<td class='tbYellow' width='10%'>循環房貸件數</td>
		<td class='tbYellow2' width='15%'>
			<span id ='TOT2_CNT_SPAN'><span>
		</td>
		<td class='tbYellow' width='10%'>循環房貸金額</td>
		<td class='tbYellow2' width='15%'>
			<span id ='TOT2_AMT_SPAN'><span>
		</td>
	</tr>
	<tr align='center' id = 'THREE_TR'>
		<td class='tbYellow' width='10%'>其他件數</td>
		<td class='tbYellow2' width='15%'>
			<span id='OTHET_CNT_SPAN'><span>
		</td>
		<td class='tbYellow' width='10%'>其他件數金額</td>
		<td class='tbYellow2' width='15%'>
			<span id ='OTHER_AMT_SPAN'><span>
		</td>
		<td class='tbYellow' width='10%'></td>
		<td class='tbYellow2' width='15%'></td>
		<td class='tbYellow' width='10%'></td>
		<td class='tbYellow2' width='15%'></td>
	</tr>
	<tr align='center' id = 'FOUR_TR'>
		<td class='tbYellow' width='10%'>剔除件數</td>
		<td class='tbYellow2' width='15%'>
			<span id='RECOVER_CNT_SPAN'><span>
		</td>
		<td class='tbYellow' width='10%'>剔除資料明細</td>
		<td class='tbYellow2' width='45%' colspan='5'>
			<span id ='RECOVER_DETAIL_SPAN'><span>
		</td>
	</tr>
</table>
<iframe id="importFrame" name="importFrame" width="0" height="0"></iframe><%-- 匯入檔案時，模擬Ajax的效果 --%>
</body>
</html>