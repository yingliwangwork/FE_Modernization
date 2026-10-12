<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<!--
程式：DSE10500.jsp
功能：陳報債權作業
作者：陳宥銓
完成：2013/08/07

[20240207]
難字調整
高強禾

[20240314]問題單號:20240311162105
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<fmt:setBundle basename="TextResource" /><!--匯入外部Javascript 與 css-->
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>  <%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>		 <%-- 月曆用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			 <%-- 日期用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/RPTUtil.js'></script>
<%-- [20240207] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type="text/JavaScript"><!--
	
	Event.observe(window, 'load', DSE10500().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
	
	function DSE10500(){
		
		var valid1;
		var valid2;
	    var grid;
		var grid1;
	    var E024_vo;
		//var fileList;
		//var dataMap;
		//var rtnList;
		var REFER_ID='${REFER_ID}';
		var LOAN_ID='${LOAN_ID}';    
		var SALE_DATE='${SALE_DATE}'; 
		
		//畫面檢核
		function initValidation(){
			valid1 = new Validation("table_B", { focusOnError:true, immediate:false, mode:'validator'});	
			Validation.addAllThese( [
				[ 'RENEGE_OFFSET_check', '請選擇違約金抵充方式!', function(v){ return ($('RENEGE_OFFSET1').checked || $('RENEGE_OFFSET2').checked) }]
			] );
			valid1.define( "RENEGE_OFFSET_check", [{ id : "RENEGE_OFFSET1" }, { id : "RENEGE_OFFSET2" }] );
			
			valid2 = new Validation("table_C", { focusOnError:true, immediate:false, mode : 'validator'});
			valid2.define( "required" , { id: "UNDIS_INT"  } );//刪除理由	
			valid2.define( "required" , { id: "UNDIS_RENEGE"  } );//刪除理由
		}
		
	   //按鈕授權
		function buttonAuth() {
			var authButtons = { 
				B0028 : 'btn_confirm',
				B0072 : 'btn_calculate',
				B0003 : 'btn_insert',
				B0111 : 'btn_update',		
				B0005 : 'btn_delete',
				B0070 : 'btn_agree',
				B0071 : 'btn_cancel',
				B0076 : 'btn_upload',
				B0225 : 'btn_insert2'					
			};
			<dz:grantButtons FUNC_ID ="DSE10500" />
		}
		
		function buttonEnable() {
		
			var ACTION_TYPE = $('ACTION_TYPE').value;
			var LINK_FROM = $('LINK_FROM').value;
			var LINK_TYPE = $('LINK_TYPE').value;
	
			if(ACTION_TYPE == 'Q'){
				$('btn_query').enable();
				$('btn_confirm').disable();
				$('btn_calculate').disable();
				$('btn_insert').disable();
				$('btn_update').disable();
				$('btn_delete').disable();
				$('btn_agree').disable();
				$('btn_cancel').disable();
				$('btn_upload').disable();
			}
			else if(ACTION_TYPE == 'U'){
				$('btn_query').enable();
				$('btn_confirm').enable();
				$('btn_calculate').enable();
				$('btn_insert').enable();
				$('btn_update').enable();
				$('btn_delete').enable();
				$('btn_agree').enable();
				$('btn_cancel').disable();
				$('btn_upload').enable();
			}else if(!ACTION_TYPE){
				//TODO 
				$('btn_query').enable();
				$('btn_confirm').enable();
				$('btn_calculate').enable();
				$('btn_insert').enable();
				$('btn_update').enable();
				$('btn_delete').enable();
				$('btn_agree').enable();
				$('btn_cancel').disable();
				$('btn_upload').enable();
			}
		}
			
		//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSE1_0500/" + actionName,
				{  
					parameters: params, 
					onSuccess:function(response){
						var resp = response.responseJSON
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
				}
			);
		}
		
		//--------------------------------------------------------------------------
		// 建立/關閉coverPage(不讓使用者在上載時做任何事)
		//--------------------------------------------------------------------------
		var auxiliary = {
			createCoverPage:function(){
				CSRUtil.createCoverPage('_frontCover');
				$('_frontCover').show();
			},
			closeCoverPage: function(){
				$('_frontCover').hide();
			}
		};
		
		var actions = {
		
			// 抵充順序輸入欄位控制
			doCASEAMT_OFFSET : function(){
			
				if ($('CASEAMT_OFFSET').value == "1") {
					$$('#grid input[type = "text"]').each(function(ele){
						ele.enable();
					});
				} else {
					$$('#grid input[type = "text"]').each(function(ele){
						ele.disable();
					});
				}
			},
			
			// 產生input物件
			makeInput : function(id, value, str){
				var input = new Element('input', {'id':id, 'type':'text', 'class':'textBox2 validate-positive-integer',
					'fieldname':str, 'size':'4', 'maxlength':'3', 'value':value});
				return input;
			},
			
			// 取得拍定日期下拉選單
			getDate : function(){
			
				if($F('REFER_ID') == ''){
					return;
				}
				
				ajaxPost( 'date', {'REFER_ID' : $F('REFER_ID'), 'OPERATION_KIND' : $F('OPERATION_KIND')},
					function(resp){
	 		
						var SALE_DATE_List = resp.SALE_DATE_List || [];

						$('SALE_DATE_A').options.length = 1;
						SALE_DATE_List.each(
							function(ele) {
								$('SALE_DATE_A').add(new Option(ele.SALE_DATE_ROC + ele.STS, ele.SALE_DATE_ROC));
							}  
						); 		
					}			
				);
			},
			
			// 取得區塊D重查
			getClick : function(){
				$$('#grid input[type = "radio"]').each(function(ele){
					if (ele.checked) {
						ele.click();
					}
				});
			},
			
			//下載檔案
			getDownLoadFile : function(FILE_ID)  {
				RPTUtil.downloadFile( '<%=dispatcher%>/DSE1_0500/download', {'FILE_ID':FILE_ID});						
			},
			<%--[20240314]問題單號:20240311162105--%>
			removeInputTypeFile : function(){
				var input = $('import_file');
				$('import_file').remove();
				parseEUDC("ap");
				$('import').insert(input);
			}
		};
		
		var buttons={
			//查詢
			doQuery: function(event){
			
				valid1.reset();
				
				ajaxPost( 'query' , {'REFER_ID' : $F('REFER_ID'), 'SALE_DATE_A' : $F('SALE_DATE_A'), 'OPERATION_KIND' : $F('OPERATION_KIND')},			 
					function(resp){	
					
						//B區塊
						setValuesB(resp);

						//C區塊
						grid.load(resp.rtnList || []);
						var radios = $$('#grid input[type = "radio"]');
						if (resp.rtnList.length > 0 ) {
							radios[0].click();
						}
						
						// 抵充方式(指定抵充)
						if ($('CASEAMT_OFFSET').value == '1') {
							//指定抵充
							$$('#grid input[type = "text"]').each(function(ele){
								ele.enable();
							});
						} else {
							//法定抵充
							$$('#grid input[type = "text"]').each(function(ele){
								ele.disable();
							});
						}

						//D區塊	
						//setValuesD(resp);
					
						//上傳附件
						grid1.load(resp.fileList || []);
					},
					function(resp){
					
						//B區塊
						$$('#table_B input[type!="button"]').each(
							function(text){
								text.value = '';
							}
						);
						
						//C區塊
						grid.load([]);

						//D區塊
						$$('#table_C input[type!="button"]').each(
							function(text){
								text.value = '';
							}
						);
						
						$$('#table_C span[field!="FILE"]').each(
							function(text){
								text.innerHTML = '';
							}
						);
						
						//上傳附件
						grid1.load([]);
					}
				);
			},
			//確認
			doConfirm: function(event){

				var REFER_ID1=$F('REFER_ID1');
				if(!REFER_ID1){
					alert("請先查詢後再確認!");
					return;
				}
			
				if(REFER_ID1!=$F('REFER_ID')){
					alert("欲確認的原貸帳號與原先查詢不同，請重新查詢後再作業!");
					return;
				}
				
				if(!valid1.validate()){
					return;
				}

				var dataList = grid.getAllRecords();
				
				if ($('CASEAMT_OFFSET').value == '1') {
					var itemList = [];
					var isOne = false;
					var isDuplicate = true;
					$$('#grid input[type = "text"]').each(function(ele){
						if (ele.getValue() == '1') {
							isOne = true;
						}
						for (var idx = 0; idx < dataList.length; idx++) {
							if (ele.getValue() == itemList[idx]) {
								isDuplicate = false;
							}
							if (idx == (dataList.length-1)) {
								itemList.push(ele.getValue());
							}
						}
					});
					
					if (!isOne) {
						alert("抵充順序需由1開始!");
						return;
					}
	
					if (!isDuplicate) {
						alert("抵充順序不可重複!");
						return;
					}
				}

				if (!confirm("原有資料會被覆蓋，請確認是否繼續作業?")){
				     return;
				}	

				//取得抵充順序欄位值
				var LOAN_ID_CHK = dataList[0]['LOAN_ID'];
				for (var idx = 0; idx < dataList.length; idx++) {
					var LOAN_ID_CHK = dataList[idx]['LOAN_ID'];
					$$('#grid input[type = "text"]').each(function(ele){
						if (ele.id == LOAN_ID_CHK) {
							dataList[idx]['OFFSET_SEQ'] = ele.getValue();
						}
					});
				}

				ajaxPost( 'confirm', {'reqMapB' : Object.toJSON(reqMapB()), 'dataList' : Object.toJSON(dataList)},
					function(resp){

						//C區塊
					    grid.load(resp.dataList || []);
					    
					    // 抵充方式(指定抵充)
						if ($('CASEAMT_OFFSET').value == '1') {
							//指定抵充
							$$('#grid input[type = "text"]').each(function(ele){
								ele.enable();
							});
						} else {
							//法定抵充
							$$('#grid input[type = "text"]').each(function(ele){
								ele.disable();
							});
						}
						
					    //D區塊	
						//setValuesCAL(resp);
						setValuesD(resp);
					}			
				);
			},
		    //試算
			doCalculate: function(event){
			
				valid1.reset();
				valid2.reset();
				if(!valid2.validate()){
					return;
				}
			
				var isConfirm = true;
				$$('#grid input[type = "text"]').each(function(ele){
					if (ele.getValue() == '') {
						isConfirm = false;
					}
				});
				if (!isConfirm) {
					alert("請先確認後再試算!");
					return;
				}	
				
				if(!$F('REFER_ID2')){
					alert('請先點選一筆貸款帳號資料!');
					return;
				}	
		
				var chkList = grid.getCheckedRecord();
				if (chkList.length == 0) {
					//若未點選radio box 取全部資料
					chkList = grid.getAllRecords();
				}
				var LOAN_ID_CHK = chkList[0]['LOAN_ID'];
				var OFFSET_SEQ;
				$$('#grid input[type = "text"]').each(function(ele){
					if (ele.id == LOAN_ID_CHK) {
						OFFSET_SEQ = ele.getValue();
					}
				});
				
				ajaxPost( 'calculate', {'reqMapB' : Object.toJSON(reqMapB()), 'reqMapD' : Object.toJSON(reqMapD()), 'OFFSET_SEQ' : OFFSET_SEQ},
					function(resp){
					
					    //D區塊	
						//setValuesCAL(resp);	
						setValuesD(resp);		    
					}	  				 
				);
			},
		    //新增
			doInsert: function(event){			
				
				valid1.reset();
				
				var REFER_ID1=$F('REFER_ID1');
				if(!REFER_ID1){
					alert("請先查詢後再新增!");
					return;
				}
				
				var chkList = grid.getCheckedRecord();
				if (chkList.length == 0) {
					//若未點選radio box 取全部資料
					chkList = grid.getAllRecords();
				}
				var LOAN_ID_CHK = chkList[0]['LOAN_ID'];
				var OFFSET_SEQ;
				$$('#grid input[type = "text"]').each(function(ele){
					if (ele.id == LOAN_ID_CHK) {
						OFFSET_SEQ = ele.getValue();
					}
				});
			   	
				ajaxPost( 'insert', {'reqMapB' : Object.toJSON(reqMapB()), 'reqMapD' : Object.toJSON(reqMapD()), 'OFFSET_SEQ' : OFFSET_SEQ},
					function(resp){	
						actions.getDate();
						
						//C區塊
						grid.load(resp.rtnList || []);
						var radios = $$('#grid input[type = "radio"]');
						if (resp.rtnList.length > 0 ) {
							radios[0].click();
						}
					}		
				);
			},
			//新增協議清償
			doInsert2: function(event){			
				
				valid1.reset();
				
				var REFER_ID1=$F('REFER_ID1');
				if(!REFER_ID1){
					alert("請先查詢後再新增協議清償!");
					return;
				}
				
				if (E024_vo.OPERATION_KIND != '1') {
					alert('原作業種類需為入案款，請重新查詢!!');
				}
				
				var chkList = grid.getCheckedRecord();
				if (chkList.length == 0) {
					//若未點選radio box 取全部資料
					chkList = grid.getAllRecords();
				}
				var LOAN_ID_CHK = chkList[0]['LOAN_ID'];
				var OFFSET_SEQ;
				$$('#grid input[type = "text"]').each(function(ele){
					if (ele.id == LOAN_ID_CHK) {
						OFFSET_SEQ = ele.getValue();
					}
				});

				ajaxPost( 'insert2', {'reqMapB' : Object.toJSON(reqMapB()), 'reqMapD' : Object.toJSON(reqMapD()), 'OFFSET_SEQ' : OFFSET_SEQ},
					function(resp){	
						actions.getDate();
					}		
				);
			},
		    //異動
		    doUpdate: function(event){
		    	
		    	valid1.reset();
		    
		    	var REFER_ID1=$F('REFER_ID1');
				if(!REFER_ID1){
					alert("請先查詢後再異動!");
					return;
				}
				
				var chkList = grid.getCheckedRecord();
				if (chkList.length == 0) {
					//若未點選radio box 取全部資料
					chkList = grid.getAllRecords();
				}
				var LOAN_ID_CHK = chkList[0]['LOAN_ID'];
				var OFFSET_SEQ;
				$$('#grid input[type = "text"]').each(function(ele){
					if (ele.id == LOAN_ID_CHK) {
						OFFSET_SEQ = ele.getValue();
					}
				});

				ajaxPost( 'update' , {'reqMapB' : Object.toJSON(reqMapB()), 'reqMapD' : Object.toJSON(reqMapD()), 'OFFSET_SEQ' : OFFSET_SEQ},
					function(resp){					
						actions.getClick();
					}
				);
			},
			//刪除
			doDelete: function(event){
				
				valid1.reset();
				
				var REFER_ID1=$F('REFER_ID1');
				if(!REFER_ID1){
					alert("請先查詢後再刪除!");
					return;
				}
						
			     ajaxPost( 'delete' , {'reqMapB' : Object.toJSON(reqMapB()), 'reqMapD' : Object.toJSON(reqMapD())},
					function(resp){
						
						actions.getDate();
						
						$$('#table_C input[type!="button"]').each(
							function(text){
								text.value = '';
							}
						);
						
						$$('#table_C span[field!="FILE"]').each(
							function(text){
								text.innerHTML = '';
							}
						);
						
						actions.getClick();
					}	
				);
			},
			//覆核
			doAgree: function(event){
			
				valid1.reset();
				
				var REFER_ID1=$F('REFER_ID1');
				if(!REFER_ID1){
					alert("請先查詢後再覆核!");
					return;
				}
				
				var dataList = grid.getAllRecords();

				ajaxPost( 'agree' , {'reqMapB' : Object.toJSON(reqMapB()), 'reqMapD' : Object.toJSON(reqMapD()), 'dataList' : Object.toJSON(dataList)},
					function(resp){
						actions.getDate();
						actions.getClick();
					}
				);
			},
			//取消覆核
			doCancel: function(event){
					
				valid1.reset();
				
				var REFER_ID1=$F('REFER_ID1');
				if(!REFER_ID1){
					alert("請先查詢後再取消覆核!");
					return;
				}

				var dataList = grid.getAllRecords();

				ajaxPost( 'cancel' , {'reqMapB' : Object.toJSON(reqMapB()), 'reqMapD' : Object.toJSON(reqMapD()), 'dataList' : Object.toJSON(dataList)},
					function(resp){
						actions.getDate();
						actions.getClick();
					}
				);
			},
			//上傳
			doUpload: function(event){
			
				valid1.reset();
				
				if(!$F('import_file')){
					alert('請選擇資料檔再執行上載!');
					return;
				}
				
				if(!$F('REFER_ID2')){
					alert('請先點選一筆貸款帳號資料!');
					return;
				}
				
				if($('REFER_ID').value!=$('REFER_ID1').value){
					alert("查詢用之原貸帳號與作業用之原貸帳號不同，請重新查詢!");
					return;
				}

				auxiliary.createCoverPage();
				$('form1').submit();			
			},  
			//上傳結束
			importEnd: function(event){

				var filedata;
				filedata = window.importFrame.document.getElementById('filedata');
				if(!filedata){
					return;
				}
			
				var obj = filedata.innerHTML.evalJSON();		
				
				var Msg = obj.ErrMsg.msgDesc.replace('\\n','');
				if(Msg){
					alert(Msg);
				}	
				if(CSRUtil.isSuccess(obj)){	
					var rtnList=obj.File_mapList||[];
					grid1.load(obj.File_mapList);								
				}else{
					var rtnList=obj.File_mapList||[];
					grid1.load(rtnList);	
				}							
				auxiliary.closeCoverPage();
			},
			//影像檔
			doLink: function(event){
				popupWin.popup({									
					src : '<%=dispatcher%>/DSF0_0210/prompt' ,		
					scrolling : 'yes',	
					parameters : { 
						'REFER_ID' : $F('REFER_ID')	
					}  			
				});	
			}
	    };
	    
	   	//原貸帳號債權分配(B區塊)
		var setValuesB = function(resp) {
					  
			E024_vo = resp.DTDSE024_vo || [];

			$w('RENEGE_OFFSET1 RENEGE_OFFSET2').each(
				function(id) {	
					if($(id).value == E024_vo.RENEGE_OFFSET){
						$(id).checked = true;
					} else {
						$(id).checked = false;
					}
				}
			);
			
			$('RENEGE_OFFSET').value = E024_vo.CASEAMT_TYPE || ''; //違約金抵充方式
			
			$('CASEAMT_TYPE').value = E024_vo.CASEAMT_TYPE || '1'; //案款種類
			
			$('CASEAMT_OFFSET').value = E024_vo.CASEAMT_OFFSET || '2'; //案款抵充方式
			
			$w('COURT_AMT1 COURT_AMT2 COURT_AMT3').each(
				function(id) {		
					$(id).value = gridFmtRender(E024_vo[id]);
				}
			);

			$('REFER_ID1').value = E024_vo.REFER_ID || $F('REFER_ID');
			if (E024_vo['SALE_DATE']) {
				$('SALE_DATE_B').value = Date.toInputROC(E024_vo['SALE_DATE']);
				$('SALE_DATE_D').innerHTML = Date.toROC(E024_vo['SALE_DATE']);
			} else {
				$('SALE_DATE_B').value = Date.toInputROC(getY2KToday());
				$('SALE_DATE_D').innerHTML = Date.toROC(getY2KToday());
			}
		};
	    
	    //貸款帳號分配明細(D區塊)
		var setValuesD = function(resp) {

			var dataMap = resp.dataMap || [];

			<%-- [20240207] 移除LAW_NAME、INPUT_NAME、CONFIRM_NAME --%>
			$w('DELAY_DAY CREDIT_NOTE WRITEOFF_STATUS_NAME').each(
				function(id) {		
					$(id).innerHTML = dataMap[id] || '';
				}
			);
			
			$w('LAST_BALANCE DELAY_INT RENEGE1 TOTAL_FEE2 TOTAL_CREDIT REMAIN_AMT SHORT_AMT').each(
				function(id) {		
					$(id).innerHTML = gridFmtRender(dataMap[id]);
				}
			);
			
			$w('INPUT_DATE CONFIRM_DATE SUBMIT_DATE WRITEOFF_DATE').each(
				function(id) {		
					$(id).innerHTML = Date.toROC(dataMap[id] || '');
				}
			);
			
			if (dataMap['SALE_DATE']) {
				$('SALE_DATE_D').innerHTML = Date.toROC(dataMap['SALE_DATE']);
			} else {
				$('SALE_DATE_D').innerHTML = Date.toROC(getY2KToday());
			}

			<%-- [20240207] 增加LAW_NAME、INPUT_NAME、CONFIRM_NAME --%>
			$w('COURT_NAME CASE_NO BORROW_NAME BORROW_ID CON_ZIP CON_ADDR NOTE TOTAL_AMT LAW_ID LAW_NAME INPUT_NAME CONFIRM_NAME').each(
				function(id) {		
					$(id).value = dataMap[id] || '';
				}
			);
			
			$w('COURT_NAME CASE_NO BORROW_NAME BORROW_ID CON_ZIP CON_ADDR NOTE TOTAL_AMT').each(
				function(id) {		
					$(id).value = dataMap[id] || '';
				}
			);
			
			$w('RENE_DATE1 RENE_DATE2').each(
				function(id) {		
					$(id).value = dataMap[id] || '0';
				}
			);

			$w('YEAR_RATE SALE_ROUND SALE_TIMES NEW_COURT_AMT CREDIT_AMT RENEGE2 TOTAL_FEE1 SALE_AMT UNDIS_INT UNDIS_RENEGE UNDIS_FEE').each(
				function(id) {		
					$(id).value = gridFmtRender(dataMap[id]);
				}
			);
			
			$w('LAST_PAYDT ACNT_DATE').each(
				function(id) {		
					$(id).value = Date.toInputROC(dataMap[id] || '');
				}
			);
		};
		
		//貸款帳號分配明細 for試算(D區塊)
		var setValuesCAL = function(resp) {

			var dataMap = resp.dataMap;

			$w('DELAY_DAY CREDIT_NOTE').each(
				function(id) {		
					$(id).innerHTML = dataMap[id] || '';
				}
			);
			
			$w('LAST_BALANCE DELAY_INT RENEGE1 TOTAL_FEE2 TOTAL_CREDIT REMAIN_AMT SHORT_AMT').each(
				function(id) {		
					$(id).innerHTML = gridFmtRender(dataMap[id]);
				}
			);

			$w('YEAR_RATE TOTAL_AMT RENE_DATE1 RENE_DATE2').each(
				function(id) {		
					$(id).value = dataMap[id] || '';
				}
			);
			
			$w('NEW_COURT_AMT UNDIS_INT UNDIS_RENEGE UNDIS_FEE CREDIT_AMT RENEGE2 TOTAL_FEE1').each(
				function(id) {		
					$(id).value = gridFmtRender(dataMap[id]);
				}
			);
			
			$w('LAST_PAYDT').each(
				function(id) {		
					$(id).value = Date.toInputROC(dataMap[id] || '');
				}
			);
			
			$w('SALE_DATE_D').each(
				function(id) {		
					$(id).innerHTML = Date.toROC(dataMap['SALE_DATE'] || '');
				}
			);
		};
	    
	    //金額格式化
		var gridFmtRender = function(value) { 
			return value || value === 0 ? CSRUtil.$fmt(value, '#,##0.#####', 0) : ''; 
		};
		
		//移除逗號
		var fmtRemove = function(value){
			return value.replace(/,/g, "");
		};
		
		//取得貸款帳號 對應 抵充順序
		var getOFFSET_SEQ = function(){
		
			var chkList = grid.getCheckedRecord();
			if (chkList.length == 0) {
				//若未點選radio box 取全部資料
				chkList = grid.getAllRecords();
			}
			var LOAN_ID_CHK = chkList[0]['LOAN_ID'];
			$$('#grid input[type = "text"]').each(function(ele){
				if (ele.id == LOAN_ID_CHK) {
					return ele.getValue();
				}
			});
		}
		
		//產生查詢回傳資料(B區塊)
		var reqMapB = function(){
		
			var reqMap = {};

			var reqMap={
				'LOAN_ID' : $('LOAN_ID').value,
				'SALE_DATE_B': $('SALE_DATE_B').value,
				'COURT_AMT1': fmtRemove($('COURT_AMT1').value),
				'COURT_AMT2': fmtRemove($('COURT_AMT2').value),
				'COURT_AMT3': fmtRemove($('COURT_AMT3').value),
				'REFER_ID': $F('REFER_ID1') || $F('REFER_ID') ,
				'WRITEOFF_STATUS': $F('WRITEOFF_STATUS'),
				'CASEAMT_TYPE': $('CASEAMT_TYPE').value,
				'CASEAMT_OFFSET': $('CASEAMT_OFFSET').value,
				'OPERATION_KIND': $('OPERATION_KIND').value
			};
			
			if($('RENEGE_OFFSET1').checked){
				reqMap.RENEGE_OFFSET = $('RENEGE_OFFSET1').value;		
			}else if($('RENEGE_OFFSET2').checked){
				reqMap.RENEGE_OFFSET = $('RENEGE_OFFSET2').value;		
			}
			return reqMap;	
		};
		
		//產生查詢回傳資料(D區塊)
		var reqMapD = function(){
		
			var reqMap = {};
 
			$$('#table_C input[type!="button"], #table_C select').each(
				function(text){
					var table = text.up('table');
					if(table.id == 'table_C'){
						reqMap[text.id] = fmtRemove(text.value);
					}
				}
			);
			
			$$('#table_C span[field!="FILE"]').each(
				function(text){
					var table = text.up('table');
					if(table.id == 'table_C'){
						reqMap[text.id] = fmtRemove(text.innerHTML);
					}
				}
			);
			
			$w('INPUT_DATE CONFIRM_DATE SUBMIT_DATE WRITEOFF_DATE').each(
				function(id) {		
					//將非數字的取代成空白
					reqMap[id] = reqMap[id].replace(/\D/g, "") || '';
				}
			);

			return reqMap;	
		};
	
		return{
		
			initApp : function(){
			
				PageUI.createPageWithAllBodySubElement('DSE10500','法務件','陳報債權作業',1);
				
				initValidation();
				
				//按鈕事件監聽
			    $('btn_query').observe('click', buttons.doQuery);//查詢
				$('btn_confirm').observe('click', buttons.doConfirm);//確認
				$('btn_calculate').observe('click', buttons.doCalculate);//計算
				$('btn_insert').observe('click', buttons.doInsert);//新增
				$('btn_insert2').observe('click', buttons.doInsert2);//新增協議清償
				$('btn_update').observe('click', buttons.doUpdate);//異動
				$('btn_delete').observe('click', buttons.doDelete);//刪除
				$('btn_agree').observe('click', buttons.doAgree);//複核
				$('btn_cancel').observe('click', buttons.doCancel);//取消複核
				$('btn_upload').observe('click', buttons.doUpload);//上傳
				$('importFrame').observe('load', buttons.importEnd); //匯入結束
				$('btn_link').observe('click', buttons.doLink);//影像檔
				
				//buttonEnable() ;
				
				grid = new TableUI(
					{
						table: $("grid"), pageSize : 10, allSortable: false, overDiv:false,	
						autoCheckBox:{
							text:'選取', 
							type:'radio',
							isSelectAll:false,
							action:function( node , boxStatus , records ){ 
								$('LOAN_ID').value=records[0].LOAN_ID;
								$('REFER_ID2').value=records[0].REFER_ID;
								$('OPERATION_KIND2').value=records[0].OPERATION_KIND;
								//點選的radio才執行ajax
								if (!boxStatus) {
									return;
								}								
								ajaxPost( 'queryB' , {'LOAN_ID':records[0].LOAN_ID, 'SALE_DATE':$('SALE_DATE_B').value, 'OPERATION_KIND':$('OPERATION_KIND').value, 'REFER_ID':records[0].REFER_ID},
									function(resp){
										//D區塊	
										setValuesD(resp);
									}
								);		
							}	
						}, 
		                <%-- [20240207] 難字調整 --%>
		                afterLoad: function() {
		                	if ( "function" === typeof(parseEUDC) ) { actions.removeInputTypeFile(); }<%--[20240314]問題單號:20240311162105--%>
		                },
		                pageChange: function() {
		                	if ( "function" === typeof(parseEUDC) ) { actions.removeInputTypeFile(); }<%--[20240314]問題單號:20240311162105--%>
		                },
						column:[								
							{header:"貸款帳號", key:"LOAN_ID"},
							{header:"原貸帳號", key:"REFER_ID"},
							{header:"抵充順序", key:"OFFSET_SEQ",
								render : function (record , value){						
									return actions.makeInput(record['LOAN_ID'], value, '抵充順序');
								}  
							},
							{header:"契約效力", key:"LOAN_STATUS_NM"},
							<%-- [20240207] 難字調整：借款人、擔保品地址 --%>
							{header:"借款人", key:"BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},
							{header:"擔保品地址", key:"GAGE_ADDR", attrs:{ style:"font-family:'EUDC'" }}							
						]
					});
				
				grid1 = new TableUI(
					{
						table: $("grid1"), pageSize : 5, allSortable: false, overDiv:false,	
		                <%-- [20240207] 難字調整 --%>
		                afterLoad: function() {
		                	if ( "function" === typeof(parseEUDC) ) { actions.removeInputTypeFile(); }<%--[20240314]問題單號:20240311162105--%>
		                },
		                pageChange: function() {
		                	if ( "function" === typeof(parseEUDC) ) { actions.removeInputTypeFile(); }<%--[20240314]問題單號:20240311162105--%>
		                },
						column:[	
							{header:"檔名", key:"FILE_NM",
								render:function(rec, val){
									
									if(val){
										var alink = new Element('a', {href :'#'});
										alink.setAttribute('FILE_ID',rec.FILE_ID);
										alink.update(val).observe('click',function(){actions.getDownLoadFile(rec.FILE_ID)});
											return alink;
									}else{
										return val;
									}	
								}
								
							
							},
							<%-- [20240207] 難字調整：上傳人員 --%>
							{header:"上傳人員", key:"LST_PROC_NAME", attrs:{ style:"font-family:'EUDC'" }},
							{header:"上傳時間", key:"LST_PROC_DT"},
							{header:"刪除附件", key:"del_FILE",
								render:function(rec, val){
								
									var button = new Element('input',{value:'刪除附件',type:'button'});
									button.className = 'button';
									var span = new Element('span');
								
									button.onclick=function(){
										if (!confirm("附件將會刪除，請確認是否繼續作業?")){
											return;
										}
										
										if(!$F('REFER_ID2')){
											alert('請先點選一筆貸款帳號資料!');
											return;
										}
										
										if($('REFER_ID').value!=$('REFER_ID1').value){
											alert("查詢用之原貸帳號與作業用之原貸帳號不同，請重新查詢!");
											return;
										}
										
										var reqMap={
											'REFER_ID': $F('REFER_ID2'),
											'OPERATION_KIND': $F('OPERATION_KIND2'),
											'SALE_DATE_B': $F('SALE_DATE_B'),
											'FILE_ID': rec.FILE_ID
										}

									 	ajaxPost('deleteFile' , {'reqMap':Object.toJSON(reqMap)},
											function(resp){
												grid1.load(resp.fileList || []);
											}
										);
								  	};
								   	span.insert(button);
									return span;
									
							   	}
							}
						]
					}
				);
				
				// 原貸帳號 連動 拍定日期下拉選單
				$('REFER_ID').observe('blur', actions.getDate);
				// 作業種類 連動 拍定日期下拉選單
				$('OPERATION_KIND').observe('change', actions.getDate);
				
				if(SALE_DATE!=''){
					$('SALE_DATE_A').value = SALE_DATE;
				}
				
				// 下拉選單初始預設
				$('CASEAMT_TYPE').setValue("1"); //案款種類
				$('CASEAMT_OFFSET').setValue("2"); //案款抵充方式
				$('OPERATION_KIND').setValue("1"); //作業種類
	
				buttonAuth();
				$('CASEAMT_OFFSET').observe('change', actions.doCASEAMT_OFFSET);
				
				autoFormatToNumber();
						
				PageUI.resize();			
				displayMessage();	
				
			}// end initApp()			
		}; //end return
	}
	
--></script>
</head>
<body>

<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="13%">
			原貸帳號
		</td>		
		<td class="tbYellow2" width="20%" >
			<input id="REFER_ID" name="REFER_ID" type='text' class='textBox2' size='12' maxlength='10' onblur="this.value = this.value.toUpperCase()" value="${REFER_ID}"/>
			<input id="ACTION_TYPE" type="hidden" value="${ACTION_TYPE}" />
		</td>	
		<td class="tbYellow" width="13%">
			作業種類
		</td>	
		<td class="tbYellow2" width="20%">
			<select id="OPERATION_KIND">
				<c:forEach items="${OPERATION_KIND_List}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
		</td>	
		<td class="tbYellow" width="13%">
			拍定日期
		</td>		
		<td class="tbYellow2" id='TD_SALE_DATE_A' width="11%">
			<select id="SALE_DATE_A">	
				<option value="">全部</option>		
				<c:forEach items="${SALE_DATE_List}" var="row">
					<option value="${row.SALE_DATE_ROC}" />
						${row.SALE_DATE_ROC}+${row.STS}
					</option>	
				</c:forEach>				
			</select>
		</td>	
		<td class="tbYellow2" width="10%" align="center">
			<input id="btn_query" type="button" class="button" value="查詢" />	
			<input id="btn_link" type="button" class="button" value="影像檔 " />	
		</td>			
	</tr>		
</table>

<form id="form1" method="post" target="importFrame" enctype="multipart/form-data" action="<%=dispatcher%>/DSE1_0500/upload" style="PADDING: 0px; MARGIN: 0px;">
	<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow1" colspan="6" align="center">			
				<input id="btn_confirm" type="button" class="button" value ="確認" />
				<input id="REFER_ID1" type="hidden" value=""/>
			</td>
		</tr>		
		<tr>
			<td class="tbYellow" width="13%" align="left">
				拍定日期
			</td>
			<td class="tbYellow2" width="20%" >
				<input id="SALE_DATE_B" name="SALE_DATE_B" datatype ="ROCDate" type='text' fieldName="拍定日期" class="textBox2 validate-ROCDate required" size='9' maxlength='7' /> 
				<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('SALE_DATE_B'))">
			</td>
			<td class="tbYellow" width="13%" align="left">
				違約金抵充方式
			</td>
			<td class="tbYellow2" width="54%"  colspan="3">
				<input id='RENEGE_OFFSET1' name='RO' type ='radio' value='1'/>費用>違約金>利息>本金
				<input id='RENEGE_OFFSET2' name='RO' type ='radio' value='2'/>費用>利息>本金>違約金
				<input id="RENEGE_OFFSET" type="hidden" value=""/>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="13%">
				法院分配執行費
			</td>		
			<td class="tbYellow2" width="20%">
				<input id="COURT_AMT1" type='text' fieldName="法院分配執行費" class='textBox2 required' datatype='number' size='12' maxlength='10' />
			</td>	
			<td class="tbYellow" width="13%">
				法院分配程序費用
			</td>		
			<td class="tbYellow2" width="20%">
				<input id="COURT_AMT2" type='text' fieldName="法院分配程序費用" class='textBox2 required' datatype='number' size='12' maxlength='10' />
			</td>
			<td class="tbYellow" width="13%">
				其他法院分配款
			</td>		
			<td class="tbYellow2" width="21%">
				<input id="COURT_AMT3" type='text' fieldName="其他法院分配款" class='textBox2 required' datatype='number' size='12' maxlength='10' />
			</td>	
		</tr>
		<tr>
			<td class="tbYellow" width="10%">
				案款種類
			</td>	
			<td class="tbYellow2" width="10%">
				<select id="CASEAMT_TYPE">		
					<c:forEach items="${CASEAMT_TYPE_List}" var="row">
						<option value="${row.key}" />
							${row.value}
						</option>	
					</c:forEach>				
				</select>
			</td>		
			<td class="tbYellow" width="10%">
				案款抵充方式
			</td>	
			<td class="tbYellow2" width="10%" colspan='3'>
				<select id="CASEAMT_OFFSET">
					<c:forEach items="${CASEAMT_OFFSET_List}" var="row">
						<option value="${row.key}" />
							${row.value}
						</option>	
					</c:forEach>				
				</select>
			</td>
			
		</tr>
	</table>
	
	<table id ="grid" ></table>
	
	<table id="table_C" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow1" colspan="6" align="center">			
				<input id="btn_calculate" type="button" class="button" value="試算" />				
				<input id="btn_insert" type="button" class="button" value="新增" />		
				<input id="btn_insert2" type="button" class="button" value="新增協議清償" />		
				<input id="btn_update" type="button" class="button" value="異動" />				
				<input id="btn_delete" type="button" class="button" value="刪除" />	
				<input id="btn_agree" type="button" class="button" value="覆核" />			
				<input id="btn_cancel" type="button" class="button" value="取消覆核" />
			</td>
		</tr>		
		<tr>
			<td class="tbYellow" width="13%">
				逾期日
			</td>		
			<td class="tbYellow2" width="20%" >
				<input id="LAST_PAYDT" datatype="ROCDate" type='text' fieldName="拍定日期" class="textBox2 validate-ROCDate" size='9' maxlength='7' /> 
				<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('LAST_PAYDT'))">
			</td>		
			<td class="tbYellow" width="13%">
				拍定日期
			</td>		
			<td class="tbYellow2" width="20%" >
				<span id="SALE_DATE_D"></span>
			</td>
			<td class="tbYellow" width="13%">
				法院分配款
			</td>		
			<td class="tbYellow2" width="21%">
				<input id="NEW_COURT_AMT" type='text' class='textBox2' datatype='number' size='12' maxlength='10' />
			</td>		
		</tr>	
		<tr>
			<td class="tbYellow">
				本金餘額
			</td>		
			<td class="tbYellow2">
				<input id="CREDIT_AMT" type='text' class='textBox2' datatype='number' size='12' maxlength='10' />
			</td>	
			<td class="tbYellow">
				適用年利率
			</td>		
			<td class="tbYellow2">
				<input id="YEAR_RATE" type='text' class='textBox2'  size='12' maxlength='10' />(%)
			</td>	
			<td class="tbYellow">
				暫收款
			</td>
			<td class="tbYellow2">
				<span id="LAST_BALANCE"></span>
			</td>		
		</tr>
		<tr>
			<td class="tbYellow">
				延遲天數
			</td>		
			<td class="tbYellow2">
				<span id="DELAY_DAY"></span>
			</td>	
			<td class="tbYellow">
				違約天數(一)
			</td>		
			<td class="tbYellow2">
				<input id="RENE_DATE1" type='text' class='textBox2'  size='12' maxlength='10' />
			</td>	
			<td class="tbYellow">
				違約天數(二)
			</td>
			<td class="tbYellow2">
				<input id="RENE_DATE2" type='text' class='textBox2' size='12' maxlength='10' />
			</td>		
		</tr>
		<tr>
			<td class="tbYellow">
				延遲利息
			</td>		
			<td class="tbYellow2">
				<span id="DELAY_INT"></span>
			</td>	
			<td class="tbYellow">
				違約金(一)
			</td>		
			<td class="tbYellow2">
				<span id="RENEGE1"></span>
			</td>	
			<td class="tbYellow">
				違約金(二)
			</td>
			<td class="tbYellow2">
				<input id="RENEGE2" type='text' class='textBox2' datatype='number' size='12' maxlength='10' />
			</td>		
		</tr>
		<tr>
			<td class="tbYellow">
				營業費用合計
			</td>		
			<td class="tbYellow2">
				<input id="TOTAL_FEE1" type='text' class='textBox2' datatype='number' size='12' maxlength='10' />
			</td>	
			<td class="tbYellow">
				<font color="red"><B>代墊費用合計</B></font>
			</td>		
			<td class="tbYellow2">
				<span id="TOTAL_FEE2"></span>
			</td>	
			<td class="tbYellow">
				債權合計
			</td>
			<td class="tbYellow2">
				<span id="TOTAL_CREDIT"></span>
				<input id="TOTAL_AMT" type="hidden" value=""/>
			</td>		
		</tr>
		<tr>
			<td class="tbYellow">
				拍定次數
			</td>		
			<td class="tbYellow2">
				<input id="SALE_ROUND" type='text' class='textBox2' size='4' maxlength='3' datatype='number'/>輪
				<input id="SALE_TIMES" type='text' class='textBox2' size='4' maxlength='3' datatype='number'/>拍
			</td>	
			<td class="tbYellow">
				拍定金額
			</td>		
			<td class="tbYellow2">
				<input id="SALE_AMT" type='text' class='textBox2' datatype='number' size='12' maxlength='10' />
			</td>	
			<td class="tbYellow">
				<font color="blue"><B>債權餘額</B></font>
			</td>
			<td class="tbYellow2">
				<span id="REMAIN_AMT"></span>
			</td>		
		</tr>
		<tr>
			<td class="tbYellow">
				債權註記
			</td>		
			<td class="tbYellow2">
				<span id="CREDIT_NOTE"></span>
			</td>	
			<td class="tbYellow">
				拍賣不足本金
			</td>
			<td class="tbYellow2" colspan="3">
				<span id="SHORT_AMT"></span>
			</td>		
		</tr>
		<tr>
			<td class="tbYellow">
				<font color="red"><B>未受分配利息</B></font>
			</td>		
			<td class="tbYellow2">
				<input id="UNDIS_INT" type='text' class='textBox2' datatype='number' size='12' maxlength='10' fieldName = "未受分配利息"/>
			</td>	
			<td class="tbYellow">
				<font color="red"><B>未受分配違約金</B></font>
			</td>		
			<td class="tbYellow2" >
				<input id="UNDIS_RENEGE" type='text' class='textBox2' datatype='number' size='12' maxlength='10' fieldName = "未受分配違約金"/>
			</td>	
			<td class="tbYellow" >
				<font color="red"><B>未受分配程序費用</B></font>
			</td>
			<td class="tbYellow2" >
				<input id="UNDIS_FEE" type='text' class='textBox2' datatype='number' size='12' maxlength='10' />
			</td>		
		</tr>
		<tr>
			<td class="tbYellow0" >
				法院
			</td>		
			<td class="tbYellow2">
				<select id="COURT_NAME">			
					<c:forEach items="${COURT_Map}" var="row">
						<option value="${row.value}" />
							${row.value}
						</option>	
					</c:forEach>				
				</select>
			</td>
			<td class="tbYellow" >
				案號<font color="red">※例：80速12345</font>
			</td>		
			<td class="tbYellow2"  colspan="3">
				<input id="CASE_NO" type='text' class='textBox2'  size='50' maxlength='30' />
			</td>	
		</tr>
		<tr>
			<td class="tbYellow0" >
				姓名
			</td>		
			<td class="tbYellow2" >
				<%-- [20240207] 難字調整：姓名 --%>
				<input id="BORROW_NAME" type='text' class='textBox2'  size='12' maxlength='10' alt="ch" />
				<input id="BORROW_ID" type="hidden" value=''/>
			</td>	
			<td class="tbYellow0" >
				通訊郵遞區號(債務人)
			</td>		
			<td class="tbYellow2" >
				<input id="CON_ZIP" type='text' class='textBox2'  size='12' maxlength='10' />
			</td>	
			<td class="tbYellow0" >
				通訊地址(債務人)	
			</td>		
			<td class="tbYellow2" >
				<%-- [20240207] 通訊地址(債務人) --%>
				<input id="CON_ADDR" type='text' class='textBox2'  size='30' maxlength='30' alt="ch" />
			</td>	
		</tr>
		<tr>
			<td class="tbYellow0" >
				物證備註
			</td>		
			<td class="tbYellow2"  colspan="5">
				<input id="NOTE" type='text' class='textBox2' size='40' maxlength='50' />
			</td>	
		</tr>
		<tr>
			<td class="tbYellow0" >
				承辦法務
			</td>		
			<td class="tbYellow2" >
				<%-- [20240207] 難字調整：承辦法務，因為會取得文字，所以span改為input --%>
				<input type="text" id="LAW_NAME" name="LAW_NAME" alt="ch" class="textDisable" readonly />
				<input id="LAW_ID" type="hidden" value=""/>
			</td>	
			<td class="tbYellow" >
				輸入人員
			</td>		
			<td class="tbYellow2" >
				<%-- [20240207] 難字調整：輸入人員，因為會取得文字，所以span改為input --%>
				<input type="text" id="INPUT_NAME" name="INPUT_NAME" alt="ch" class="textDisable" readonly />
				<input id="INPUT_ID" type="hidden" value=""/>
			</td>	
			<td class="tbYellow" >
				輸入日期
			</td>		
			<td class="tbYellow2" >
				<span id="INPUT_DATE"></span>
			</td>	
		</tr>
		<tr>
			<td class="tbYellow" >
				入帳日期
			</td>		
			<td class="tbYellow2" >
				<input id="ACNT_DATE" datatype ="ROCDate" type='text' fieldName="拍定日期" class="textBox2 validate-ROCDate" size='9' maxlength='7' /> 
				<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('ACNT_DATE'))">
			</td>	
			<td class="tbYellow" >
				覆核人員
			</td>		
			<td class="tbYellow2" >
				<%-- [20240207] 難字調整：覆核人員，因為會取得文字，所以span改為input --%>
				<input type="text" id="CONFIRM_NAME" name="CONFIRM_NAME" alt="ch" class="textDisable" readonly />
				<input id="CONFIRM_ID" type="hidden" value=""/>
			</td>	
			<td class="tbYellow" >
				覆核日期
			</td>		
			<td class="tbYellow2" >
				<span id="CONFIRM_DATE"></span>
			</td>	
		</tr>
		<tr>
			<td class="tbYellow" >
				提呆日期
			</td>		
			<td class="tbYellow2" >
				<span id="SUBMIT_DATE"></span>
			</td>	
			<td class="tbYellow" >
				轉呆日期
			</td>		
			<td class="tbYellow2" >
				<span id="WRITEOFF_DATE"></span>
			</td>	
			<td class="tbYellow" >
				呆帳轉銷狀態
			</td>		
			<td class="tbYellow2" >
				<span id="WRITEOFF_STATUS_NAME"></span>
				<input id="WRITEOFF_STATUS" type="hidden" value=''/>
			</td>	
			<input id="LOAN_ID" type="hidden" value=""/>
			<input id="REFER_ID2"  name="REFER_ID" type="hidden" value=""/>
			<input id="OPERATION_KIND2"  name="OPERATION_KIND" type="hidden" value=""/>
		</tr>
		<tr>
		<td class="tbYellow" >
				附件上傳
			</td>		
			<td class="tbYellow2"  colspan="5">
				<span id="import" field="FILE">
					<input id="import_file" name="import_file" fieldName="附件上載" type="file" size="40" class="button" />
				</span>
				<input id="btn_upload" type="button" class="button" value="上載" /><br>
				<table id = "grid1" ></table>
			</td>	
			<iframe id="importFrame" name="importFrame" width="0" height="0"></iframe><%-- 匯入檔案時，模擬Ajax的效果 --%>
		</tr>
</table>
</form>	

</body>
</html>