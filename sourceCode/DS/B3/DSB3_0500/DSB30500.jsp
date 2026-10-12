<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSB30500.jsp
作者：謝雅筑
功能：火險續保作業
完成：2012/05/28

[20240613]
難字調整
高強禾
-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<%-- [20240613] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type="text/javascript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSB30500().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB30500(){
	
	var valid;
	var grid;
	var queryMap = {};
	var confirmBTNList = [];
	var seq2=0;
		
	
	//按鈕權限
	var authButtons = {
			B0122:"btn_create"<%--產生--%>,
			B0159:"btn_download"<%--下載--%>,
			B0160:"btn_excute"<%--執行--%>,
			B0005:"btn_delete"<%--刪除--%>,
			B0028:[]<%--確認--%>						
	};
	
	var buttonAuth = function() {
		<dz:grantButtons FUNC_ID="DSB30500" ignored="false"/>
	}	
				
	var actions = {

		//查詢
		doQuery:function(){
			valid.reset();
			var QUERY_TYPE = commonTools.getType('QUERY_TYPE');
			if(!validItemDefine.query(QUERY_TYPE)){
				alert('查詢別選取有誤，無法執行查詢');
				return;
			}

			if( !valid.validate() ) {
	    		return;
	    	}
	    	
	    	var reqMap = commonTools.getParam(QUERY_TYPE);
	    	reqMap.QUERY_TYPE = QUERY_TYPE;
	    	queryMap = reqMap;
			ajaxPost('query',{reqMap:Object.toJSON(reqMap)},
				function(resp){
					actions.authBeforeLoad(resp.rtnList);
				},
				function(){
					actions.authBeforeLoad([]);
				}
			);
		},
		
		//產生
		doCreate:function(){
			valid.reset();
			var QUERY_TYPE = commonTools.getType('QUERY_TYPE');
			if(QUERY_TYPE != '5'){
				alert('請選取回傳國泰產險火險暫保扣款確認名單，再執行產生');
				return;
			}
			var EXECUTE_TYPE = commonTools.getType('EXECUTE_TYPE');

			if(!validItemDefine.create(EXECUTE_TYPE)){
				alert('請選取執行別，再執行產生');
				return;
			}

			if( !valid.validate() ) {
	    		return;
	    	}
	    	
	    	//var reqMap = EXECUTE_TYPE=='5'?commonTools.getParam(QUERY_TYPE):{};
	    	var reqMap = {};
	    	if (EXECUTE_TYPE=='5'){
	    		reqMap = commonTools.getParam(QUERY_TYPE);
	    	} else if (EXECUTE_TYPE=='4'){
	    		reqMap = commonTools.getParam4(QUERY_TYPE);
	    		reqMap.END_YM = $F('END_YM_3');
	    	}
	    	reqMap.EXECUTE_TYPE = EXECUTE_TYPE;
			ajaxPost('create',{reqMap:Object.toJSON(reqMap)},
				function(resp){
					var rtnMap = resp.rtnMap||{};
					actions.authBeforeLoad(rtnMap?[rtnMap]:[]);
					var EXECUTE_DATE = rtnMap.EXECUTE_TIME.substring(0,10);
					//儲存查詢條件
					queryMap = {QUERY_TYPE:'3', EXECUTE_DATE_STR:EXECUTE_DATE, EXECUTE_DATE_END:EXECUTE_DATE};
					$('B393_EXECUTE_TIME').innerHTML = resp.B393_CREATE_NAME+'/'+resp.B393_EXECUTE_TIME+'出單年月'+resp.B393_END_YM;
			
				}
			);
			
		},
		
	
		//確認
		doConfirm:function(record){
			ajaxPost('confirm',{record:Object.toJSON(record),reqMap:Object.toJSON(queryMap)},
				function(resp){
					actions.authBeforeLoad(resp.rtnList);
				}
			);
		},
		
		//開啟檔案
		doGetFile:function(FILE_ID) {
			RPTUtil.downloadFile( '<%=dispatcher%>/DSB3_0500/getFile', { 'FILE_ID': FILE_ID} );
		},
		
		//Load時重新授權
		authBeforeLoad:function(rtnList){
			authButtons.B0028=[];
			grid.load(rtnList?rtnList:[]);
			buttonAuth();
		},
		
		//下載
		doDownload:function(){
			valid.reset();
			var FILE_TYPE = commonTools.getType('FILE_TYPE');
			
			if(!validItemDefine.DLnEXC(FILE_TYPE)){
				alert('檔案別選取有誤，無法下載');
				return;
			}
			if( !valid.validate() ) {
	    		return;
	    	}
			
			var INPUT_DATA = '';
			if('D'==FILE_TYPE){    
			
			}else if('A'==FILE_TYPE){
				INPUT_DATA = $F('FILE_YM_A');
			}else if('B'==FILE_TYPE){
				INPUT_DATA = $F('FILE_YM_B');
			}else if('C'==FILE_TYPE){
				INPUT_DATA = $F('FILE_YMD_C');
			}else if('CF'==FILE_TYPE){
				INPUT_DATA = $F('FILE_YMD_CF');
			}else if('CD'==FILE_TYPE){
				INPUT_DATA = $F('FILE_SN');
			}else{
				alert('檔案別選取有誤');
				return;
			}
				    	
			ajaxPost('download',{
					FILE_TYPE : FILE_TYPE,
					INPUT_DATA : INPUT_DATA
				},
				function(resp){
				},
				function(){
				}
			);
		},
		
		//執行
		doExcute:function(){
			valid.reset();
			var FILE_TYPE = commonTools.getType('FILE_TYPE');
			
			if(!validItemDefine.DLnEXC(FILE_TYPE)){
				alert('檔案別選取有誤，無法執行');
				return;
			}
			if( !valid.validate() ) {
	    		return;
	    	}
			
			var INPUT_DATA = '';
			if('D'==FILE_TYPE){    
			
			}else if('A'==FILE_TYPE){
				INPUT_DATA = $F('FILE_YM_A');
			}else if('B'==FILE_TYPE){
				INPUT_DATA = $F('FILE_YM_B');
			}else if('C'==FILE_TYPE){
				INPUT_DATA = $F('FILE_YMD_C');
			}else if('CF'==FILE_TYPE){
				INPUT_DATA = $F('FILE_YMD_CF');
			}else if('CD'==FILE_TYPE){
				INPUT_DATA = $F('FILE_SN');
			}else{
				alert('檔案別選取有誤');
				return;
			}
				    	
			ajaxPost('excute',{
					FILE_TYPE : FILE_TYPE,
					INPUT_DATA : INPUT_DATA
				},
				function(resp){
				},
				function(){
				}
			);
		},
		
		//刪除
		doDelete:function(){
			valid.reset();
			var FILE_TYPE = commonTools.getType('FILE_TYPE');
			
			if(!validItemDefine.DLnEXC(FILE_TYPE)){
				alert('檔案別選取有誤，無法刪除');
				return;
			}
			if( !valid.validate() ) {
	    		return;
	    	}
			
			var INPUT_DATA = '';
			if('D'==FILE_TYPE){    
			
			}else if('A'==FILE_TYPE){
				INPUT_DATA = $F('FILE_YM_A');
			}else if('B'==FILE_TYPE){
				INPUT_DATA = $F('FILE_YM_B');
			}else if('C'==FILE_TYPE){
				INPUT_DATA = $F('FILE_YMD_C');
			}else if('CF'==FILE_TYPE){
				INPUT_DATA = $F('FILE_YMD_CF');
			}else if('CD'==FILE_TYPE){
				INPUT_DATA = $F('FILE_SN');
			}else{
				alert('檔案別選取有誤');
				return;
			}
				    	
			ajaxPost('delete',{
					FILE_TYPE : FILE_TYPE,
					INPUT_DATA : INPUT_DATA
				},
				function(resp){
				},
				function(){
				}
			);
		}
	};
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSB3_0500/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT,resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction(resp);
		 		}
	        }}
		);
	}
	

	var commonTools = {
	
		getType:function(name){
			var v = '';
			$$('#tableA input:checked[name='+name+']').each(function(o){
				 v = o.value;
			});
			return v;
		},
		
		getParam:function(type){
			var reqMap = {};
			
			if(type == '0'){
				reqMap.END_YM = $F('END_YM_0');
				
			}else if(type == '1'){
				reqMap.END_YM = $F('END_YM_1');
				
			}else if(type == '2'){
				reqMap.END_YM = $F('END_YM_2');
				
			}else if(type == '3'){
				reqMap.EXECUTE_DATE_STR = toY2K($F('EXECUTE_DATE_STR_1'));
				reqMap.EXECUTE_DATE_END = toY2K($F('EXECUTE_DATE_END_1'));
				
			}else if(type == '4'){
				reqMap.EXECUTE_DATE_STR = toY2K($F('EXECUTE_DATE_STR_2'));
				reqMap.EXECUTE_DATE_END = toY2K($F('EXECUTE_DATE_END_2'));
				
			}else if(type == '5'){
				reqMap.PAY_DATE_STR = toY2K($F('PAY_DATE_STR'));
				reqMap.PAY_DATE_END = toY2K($F('PAY_DATE_END'));
				reqMap.LOT_NO = $F('LOT_NO');
			}		
			return reqMap;
		},
		getParam4:function(type){
			var reqMap = {};
			if(type == '4'){
				reqMap.END_YM = $F('END_YM_3');
				
			}		
			return reqMap;
		}
		
	};
	
	var validItemDefine = {
		query:function(type){
			if(valid){
				valid.clear();
			}
			if(type == '0'){
				valid.define( "validate-ROCYYMM" , [{ id : "END_YM_0"}]);
				return true;
				
			}else if(type == '1'){
				valid.define( "validate-ROCYYMM" , [{ id : "END_YM_1"}]);
				return true;
				
			}else if (type == '2'){
				valid.define( "validate-ROCYYMM" , [{ id : "END_YM_2"}]);
				return true;
				
			}else if (type == '3'){
				valid.define( "validate-ROC-STR" , [{ id : "EXECUTE_DATE_STR_1"}]);
				valid.define( "validate-ROC-END" , [{ id : "EXECUTE_DATE_END_1"}]);
				valid.define( "validate-DATE-BETWEEN" , [{ id : "EXECUTE_DATE_STR_1"}]);
				return true;
				
			}else if (type == '4'){
				valid.define( "validate-ROC-STR" , [{ id : "EXECUTE_DATE_STR_2"}]);
				valid.define( "validate-ROC-END" , [{ id : "EXECUTE_DATE_END_2"}]);
				valid.define( "validate-DATE-BETWEEN" , [{ id : "EXECUTE_DATE_STR_2"}]);
				return true;
				
			}else{
				return false;
			}		
		},
		
		DLnEXC:function(type){
			if(valid){
				valid.clear();
			}
			
			if(type == 'D'){
				return true;
				
			}else if(type == 'A'){
				valid.define( "validate-ROCYYMM2" , [{ id : "FILE_YM_A"}]);
				return true;
				
			}else if(type == 'B'){
				valid.define( "validate-ROCYYMM2" , [{ id : "FILE_YM_B"}]);
				return true;
				
			}else if (type == 'C'){
				valid.define( "validate-ROCDATE" , [{ id : "FILE_YMD_C"}]);
				return true;
				
			}else if (type == 'CF'){
				valid.define( "validate-ROCDATE" , [{ id : "FILE_YMD_CF"}]);
				return true;
				
			}else if (type == 'CD'){
				valid.define( "validate-NUMBER3" , [{ id : "FILE_SN"}]);
				return true;
				
			}else{
				return false;
			}		
		},
		
		create:function(type){
			if(valid){
				valid.clear();
			}
			if(type == '3' || type == '4' || type == '5'){
				if(type == '5'){
					valid.define( "validate-ROC-STR" , [{ id : "PAY_DATE_STR"}]);
					valid.define( "validate-ROC-END" , [{ id : "PAY_DATE_END"}]);
					valid.define( "validate-DATE-BETWEEN" , [{ id : "PAY_DATE_STR"}]);
					valid.define( "validate-NUMBER3" , [{ id : "LOT_NO"}]);
				}
				if(type == '4'){
					valid.define( "validate-END-YM-3" , [{ id : "END_YM_3"}]);
				}
				return true;
			}else{
				return false;
			}
		}
	};
	
	var authAgain = function(){
		authButtons.B0028 = [];
		$$('#grid input[type=button]').each(function(o){
			if(o.value == '確認'){
				authButtons.B0028.push(o.id);
			}
		});
		buttonAuth();
	};
	
	return{                              
		initApp:function(){
			PageUI.createPage("DSB30500" , "火險作業" , "火險續保作業", false);
			PageUI.loadin(["tableA","grid"] ,1);
			
			grid = new TableUI ( {
				table: $("grid"), pageSize: 10, allSortable:true,afterLoad:authAgain,
				<%-- [20240613] 難字調整 --%>
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
					column:[
						{header: "檔案年月" ,key: "END_YM" },
						{header: "執行時間" ,key: "EXECUTE_TIME" },
						{header: "執行別" ,key: "EXECUTE_TYPE_NM" },
						{header: "訊息" ,key: "MESSAGE" },
						{header: "輸入檔案" ,key: "INPUT_FILE_NAME" ,
		              		render:function(record,value){
		              			if(value){
		              				value = new Element('a', {href :'#'}).update(value).observe('click',function(){actions.doGetFile(record.INPUT_FILE_ID)});
		              			}	          
		              			return value;
		              		}
            			},
						{header: "輸出檔案" ,key: "OUTPUT_FILE_NAME" ,
		              		render:function(record,value){
		              			if(value){
		              				value = new Element('a', {href :'#'}).update(value).observe('click',function(){actions.doGetFile(record.OUTPUT_FILE_ID)});
		              			}	          
		              			return value;
		              		}
            			},
            			<%-- [20240613] 難字調整：產生人員 --%>
            			{header: "產生人員", key: "CREATE_NAME", attrs:{ style:"font-family:'EUDC'" }},
						{header: "傳送輸出檔案時間" ,key: "SENT_OUTPUT_FILE_TIME" },
						<%-- [20240613] 難字調整：確認人員 --%>
						{header: "確認人員", key: "CONFIRM_NAME", attrs:{ style:"font-family:'EUDC'" }},
                        {header: "確認送出檔案",key: "confirm_OK",sortable:false,
							render:function ( record, value ) { 
                            	var EXECUTE_TYPE = record.EXECUTE_TYPE;
                            	var isGen = false;
    							var types = ['0','1','3','4','5'];
    							types.each(function(type){
	    							if(type == EXECUTE_TYPE){
	    								isGen = true;
	    							}
    									
    							});
    							/*
    							var div = new Element('div');
								if(isGen){
									var btn1 = new Element("input", {
										id:'Y'+seq2, type:"button", className:'button',
										value:"確認",
										onclick:function() {
											actions.doConfirm(record);
										}
									});
									seq2++;
									//authButtons.B0028.push(btn1.id);
									div.insert(btn1);
								}
								return div;
								*/
								//[20180626]改使用click
								var div = new Element('div');
								if(isGen){
									var btn1 = new Element('button', {type:'button', 'class':'button'}).update("確認");
									btn1.observe( 'click', function (event){ 	
										actions.doConfirm(record);
									});	
									div.insert(btn1);
								}
								return div; 
							}					

                         }                              
					]
				
			});	
						
			valid = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			Validation.addAllThese([
				[ 'validate-ROCYYMM', '請輸入正確民國年月格式再執行查詢',
					function(v){
						var date = v+'01';
						return isROCdate(date);				
					}
				],
				[ 'validate-ROC-STR', '請輸入正確民國日期格式再執行查詢',
					function(v){
						return isROCdate(v);				
					}
				],
				[ 'validate-ROC-END', '請輸入正確民國日期格式再執行查詢',
					function(v){
						return isROCdate(v);				
					}
				],
				[ 'validate-DATE-BETWEEN', '起日大於迄日',
					function(str_dt, node){
						var end_dt = $F(node.getAttribute('endDateId'));
						if( !Validation.get('IsEmpty').test(str_dt) && !Validation.get('IsEmpty').test(end_dt) ){	//確認有輸入
							return diffDayROC( str_dt , end_dt ) >= 0;
						}
						return true;
									
					}
				],
				[ 'validate-ROCYYMM2', '請輸入正確檔案年月',
					function(v){
						var date = v+'01';
						return isROCdate(date);				
					}
				],	
				[ 'validate-ROCDATE', '請輸入正確檔案年月日',
					function(v){
						return isROCdate(v);				
					}
				],	
				[ 'validate-NUMBER3', '請輸入正確批號',
					function(v){
						return !isNaN(v) && v.length==3;				
					}
				],
				[ 'validate-END-YM-3', '請輸入正確出單年月',
					function(v){
						return !isNaN(v) && v.length==5;				
					}
				]
			]);		

			//查詢
			$('btn_query').observe('click',function(event){
					actions.doQuery();
				}
			);
			
			//產生
			$('btn_create').observe('click',function(event){
					actions.doCreate();
				}
			);	
			
			//下載
			$('btn_download').observe('click',function(event){
					actions.doDownload();
				}
			);
			
			//執行
			$('btn_excute').observe('click',function(event){
					actions.doExcute();
				}
			);
			
			//刪除
			$('btn_delete').observe('click',function(event){
					actions.doDelete();
				}
			);
			
			displayMessage();
	
			<%-- [20240613] 難字調整：移除「$('B393_EXECUTE_TIME').innerHTML」 --%>
			
			buttonAuth();
		}                 
	}

}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
		
<!------------------------ A區--------------------->	
			
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
				<form id="form1" name="form1" method="post">
				<tr>
					<td class="tbYellow" colSpan="2"><input name="FILE_TYPE" type="radio" value="D" checked>國壽自費贈送火險請款資料檢核
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;檔案名稱：<c:if test="${not empty fileMap.DSB3_B070}">${fileMap.DSB3_B070}</c:if>
					</td>
					<td class="tbYellow2" colSpan="2"></td>
					<td class="tbYellow2" rowSpan="6" colSpan="3" align="center" >
						<input id="btn_download" name="btn_download" type="button" class="button" value="下載" />
						<input id="btn_excute" name="btn_excute" type="button" class="button" value="執行" />
						<input id="btn_delete" name="btn_delete" type="button" class="button" value="刪除" /><br>
					</td>
				</tr>
				<tr>
					<td class="tbYellow"><input name="FILE_TYPE" type="radio" value="A">產險次次次月到期保單資料(A格式)
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;檔案名稱：<c:if test="${not empty fileMap.DSB3_B010}">${fileMap.DSB3_B010}</c:if></td>
					<td class="tbYellow">檔案年月</td>
					<td class="tbYellow2" colSpan="2"><input id="FILE_YM_A" name="FILE_YM_A" type="text" fieldName="檔案年月" class="textBox2" size="6" maxlength="5" value="${A_END_YM}" /></td>

				</tr>
				<tr>
					<td class="tbYellow" ><input name="FILE_TYPE" type="radio" value="B">產險回覆暫保號及保費資料(B格式)
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;檔案名稱：<c:if test="${not empty fileMap.DSB3_B020}">${fileMap.DSB3_B020}</c:if></td>
					<td class="tbYellow" >檔案年月</td>
					<td class="tbYellow2" colSpan="2"><input id="FILE_YM_B" name="FILE_YM_B" type="text" fieldName="檔案年月" class="textBox2" size="6" maxlength="5" value="${END_YM}" /></td>
				</tr>				
				<tr>
					<td class="tbYellow" ><input name="FILE_TYPE" type="radio" value="C">產險回覆出單資料(自動扣款件C格式)
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;檔案名稱：<c:if test="${not empty fileMap.DSB3_B030_Ccathay_life}">${fileMap.DSB3_B030_Ccathay_life}</c:if></td>
					<td class="tbYellow" >檔案年月日</td>
					<td class="tbYellow2" colSpan="2">
						<input id="FILE_YMD_C" name="FILE_YMD_C" type="text" fieldName="檔案年月日" class="textBox2" size="8" maxlength="7" value="${TODAY}" datatype="ROCDate"/>
						<img src="<%=imageBase%>/CM/calendar.gif" width="20" height="18" onclick="getCalendarFor($('FILE_YMD_C'))">
					</td>
				</tr>	
				<tr>
					<td class="tbYellow" ><input name="FILE_TYPE" type="radio" value="CF">產險回覆出單資料(贈送件C格式)
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;檔案名稱：<c:if test="${not empty fileMap.DSB3_B030_CFcathay_life}">${fileMap.DSB3_B030_CFcathay_life}</c:if></td>
					<td class="tbYellow" >檔案年月日</td>
					<td class="tbYellow2" colSpan="2">
						<input id="FILE_YMD_CF" name="FILE_YMD_CF" type="text" fieldName="檔案年月日" class="textBox2" size="8" maxlength="7" value="${TODAY}" datatype="ROCDate"/>
						<img src="<%=imageBase%>/CM/calendar.gif" width="20" height="18" onclick="getCalendarFor($('FILE_YMD_CF'))">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" ><input name="FILE_TYPE" type="radio" value="CD">產險回覆出單資料(代墊件C格式)
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;檔案名稱：<c:if test="${not empty fileMap.DSB3_B030_CDcathay_life}">${fileMap.DSB3_B030_CDcathay_life}</c:if></td>
					<td class="tbYellow" >批號</td>
					<td class="tbYellow2" colSpan="2"><input id="FILE_SN" name="FILE_SN" type="text" fieldName="批號" class="textBox2" size="4" maxlength="3"  /></td>
				</tr>
				<tr>
					<td class="tbYellow"><input name="QUERY_TYPE" type="radio" value="0" checked>國壽自費贈送火險請款資料檢核</td>
					<td class="tbYellow">檔案年月</td>
					<td class="tbYellow2" colSpan="2"><input id="END_YM_0" name="END_YM_0" type="text" fieldName="檔案年月" class="textBox2" size="6" maxlength="5" value="${END_YM}" /></td>
					<td class="tbYellow2" rowSpan="5" colSpan="3" align="center" >
						<input id="btn_query" name="btn_query" type="button" class="button" value="查詢" /><br>
					</td>
				</tr>
				<tr>
					<td class="tbYellow"><input name="QUERY_TYPE" type="radio" value="1">回傳國泰產險火險續保資料</td>
					<td class="tbYellow">檔案年月</td>
					<td class="tbYellow2" colSpan="2"><input id="END_YM_1" name="END_YM_1" type="text" fieldName="檔案年月" class="textBox2" size="6" maxlength="5" value="${END_YM}" /></td>
				</tr>
				<tr>
					<td class="tbYellow" ><input name="QUERY_TYPE" type="radio" value="2">國泰產險火險續保資料寫入火險檔</td>
					<td class="tbYellow" >檔案年月</td>
					<td class="tbYellow2" colSpan="2"><input id="END_YM_2" name="END_YM_2" type="text" fieldName="檔案年月" class="textBox2" size="6" maxlength="5" value="${END_YM}" /></td>
				</tr>
				<tr>
					<td class="tbYellow" ><input name="QUERY_TYPE" type="radio" value="3">國泰產險火險暫保扣款確認名單</td>
					<td class="tbYellow" >產生日期</td>
					<td class="tbYellow2" colSpan="2">
						<input type="text" datatype="ROCDate" fieldName="產生日期(起)" class="textBox2" size="8" maxlength="7" name="EXECUTE_DATE_STR_1" id="EXECUTE_DATE_STR_1" endDateId="EXECUTE_DATE_END_1" value="${TODAY}"/>
						<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('EXECUTE_DATE_STR_1'))">
						~
						<input type="text" datatype="ROCDate" fieldName="產生日期(訖)" class="textBox2" size="8" maxlength="7" name="EXECUTE_DATE_END_1" id="EXECUTE_DATE_END_1" value="${TODAY}"/>
						<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('EXECUTE_DATE_END_1'))">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" ><input name="QUERY_TYPE" type="radio" value="4">國泰產險火險續保出單入檔</td>
					<td class="tbYellow" >入檔日期</td>
					<td class="tbYellow2" colSpan="2">
						<input type="text" datatype="ROCDate" fieldName="入檔日期(起)" class="textBox2" size="8" maxlength="7" name="EXECUTE_DATE_STR_2" id="EXECUTE_DATE_STR_2" endDateId="EXECUTE_DATE_END_2" value="${TODAY}"/>
						<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('EXECUTE_DATE_STR_2'))">
						~
						<input type="text" datatype="ROCDate" fieldName="入檔日期(訖)" class="textBox2" size="8" maxlength="7" name="EXECUTE_DATE_END_2" id="EXECUTE_DATE_END_2" value="${TODAY}" />
						<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('EXECUTE_DATE_END_2'))">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" rowSpan="3" ><input name="QUERY_TYPE" type="radio" value="5">回傳國泰產險火險暫保扣款確認名單</td>
					<td class="tbYellow" colSpan="6"><input name="EXECUTE_TYPE" type="radio" value="3">自動扣款件</td>
				</tr>
				<tr>
					<td class="tbYellow" ><input name="EXECUTE_TYPE" type="radio" value="4">贈送件</td>
					<td class="tbYellow" width = "15%">出單年月</td>
					<td class="tbYellow2" ><input id="END_YM_3" name="END_YM_3" type="text" fieldName="出單年月" class="textBox2" size="6" maxlength="5" value="${END_YM3}" /></td>
					<td class="tbYellow" >最後作業人員時間</td>
					<%-- [20240613] 難字調整：最後作業人員時間 --%>
					<td class="tbYellow2" >
						<font color=red>
							<span id="B393_EXECUTE_TIME" name="B393_EXECUTE_TIME" style="font-family:'EUDC'">
								${B393_CREATE_NAME}/${B393_EXECUTE_TIME}出單年月${B393_END_YM}
							</span>
						</font>
					</td>
				</tr>
				<tr>
					<td class="tbYellow" ><input name="EXECUTE_TYPE" type="radio" value="5">代墊件</td>
					<td class="tbYellow" width = "15%">帳管費入帳期間</td>
					<td class="tbYellow2" >
						<input type="text" datatype="ROCDate" fieldName="帳管費入帳期間(起)" class="textBox2" size="8" maxlength="7" name="PAY_DATE_STR" id="PAY_DATE_STR" endDateId="PAY_DATE_END" value="${TODAY}"/>
						<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('PAY_DATE_STR'))">
						~
						<input type="text" datatype="ROCDate" fieldName="帳管費入帳期間(訖)" class="textBox2" size="8" maxlength="7" name="PAY_DATE_END" id="PAY_DATE_END" value="${TODAY}"/>
						<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('PAY_DATE_END'))">
					</td>
					<td class="tbYellow" >批號</td>
					<td class="tbYellow2" ><input id="LOT_NO" name="LOT_NO" type="text" fieldName="批號" class="textBox2 " size="6" /></td>
				</tr>
				<tr >
					<td align="center" colspan="7">
						<input id="btn_create" type="button" class="button" value="產生" />
					</td>
				</tr>
               </form>
			</table>
<!------------------------ B區--------------------->											
			<table id="grid" class="grid"></table>

</body>
<!-- InstanceEnd -->
</html>