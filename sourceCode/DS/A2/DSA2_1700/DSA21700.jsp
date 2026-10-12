<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA21700.jsp
作者：i9100621
功能：核貸進度查詢
完成：2011/10/13
更新：
[20201130]修改件  外網多筆個資遮蔽  何宗霖
[20231012]問題單編號20230425-0117核貸進度查詢畫面查詢條件優化 BY余凱鈞
//1.增加案件來源：銀行/國壽
//2.日期改成查詢區間，並限制最長是4個月
[20240730] 修改件 難字調整
-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">

<%--共用定義的css--%>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<%--[20240730]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type='text/javaScript' src="<%=htmlBase%>/CM/js/ui/LocaleDisplay.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>

<%--自行定義的javaScript--%>
<script type="text/JavaScript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var validator;
<%--[20201130]外網多筆個資遮蔽--%>
var preTd;
<%--var preBORROW_NAME_MASK;--%>

function initApp(){

	cleanMsgBoard();
	displayMessage();

	PageUI.createPageWithAllBodySubElement("DSA21700" , "核貸作業" , "核貸進度查詢", 1);

	//TableUI的產生        
	new UI().init();    
		
	PageUI.resize(true); 
}

function UI(){                

	var grid;        
	var BQ_ARG={};//查詢條件 	
	//var OPER_CODE_LIST = {};
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		
		new Ajax.Request( "<%=dispatcher%>/DSA2_1700/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT, resp){
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
	
	
	function linkTo_DSC8_3100(BORROW_ID,BORROW_NAME,CONTROL_SOURCE){
	  
        popupWin.popup({
			src: '<%=dispatcher%>/DSC8_3100/prompt',scrolling : 'yes',
			parameters: { 
				LOAN_ID : BORROW_ID,
				BORROW_NAME : BORROW_NAME,
				CONTROL_TYPE : 'U',
				CONTROL_SOURCE : CONTROL_SOURCE
			}, 
			width: 600, 
			height: 350,
			cb : function(obj){}
		});
	}  
	
	function initTableUI(){
		grid = new TableUI( {
			table: $('grid'), pageSize: 10, split: ['SEND_DATE'],
			<%--[20240730] 難字調整 --%>
			afterLoad: function() {
				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
			},
			pageChange: function() {
				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
			},
			column:[	
				//{ key: 'SER_NO_NUMBER', header: '序<br>號', sortable: false, attrs:{rowSpan:2} },				
				<%--[20201130]外網多筆個資遮蔽_增加切換按鈕
				{ header: "個資顯示", key: "",
					render:function(rec, val, sn){
						var button = new Element('button',{ 'type' : 'button' , 'class' : 'button' });
						button.update("點我");
						button.observe('click', function(){
							if(preTd){
								grid.setValueToTD(preTd, "BORROW_NAME_MASK", preBORROW_NAME_MASK);
							}
							preTd = this;
							preBORROW_NAME_MASK = rec['BORROW_NAME_MASK'];
							grid.setValueToTD(this, "BORROW_NAME_MASK", rec['BORROW_NAME']);
						});
               			return button;
					},
					attrs:{rowSpan:2}
				},--%>
				{ key: 'APPLY_ID', header: '受理編號<br>', 
					render: function(record, value) {
						if(value){
							var link = document.createElement('a');
							link.href = '#';
							link.innerHTML = value;
							link.onclick = function(){
								doLink('DSA1_1700',record.APPLY_ID);
							};
							value = link;								
						}
						return value;
					}
				},
				<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
				<%--[20240730] 難字調整 --%>
				{ key: 'BORROW_NAME', header: '借款人<br>', attrs:{style:"font-family:'EUDC'"}},
				{ key: 'PROCESS_NAME', header: '受理進度<br>'},
				{ key: 'ELITE_AGENT', header: '優先承辦<br>',
				          render:function(record,value){
								if(value){
									value = '<font color="red">' + value + '</font>';
								}
							 	return value;
							}
				},
				{ key: 'LOAN_TYPE_NAME', header: '貸款類別<br>', 
						render: function(record, value) {
							if(record.FAST_AGREE == 'A'){
								value = value+'<br>(快速審核)';
							}
							
							return value;
						}
					},
				/*
				{ key: 'IMAGE_TYPE', header: '影像件(LC)',
							render:function(record,value){
								if(value){
									value = '<font color="red">' + value + '</font>';
								}
								if (record.LC_NAME) {
									value = value + '<font color="blue">(' + record.LC_NAME + ')</font>';
								}
							 	return value;
							}
					}, */
				{ key: 'CRED_DEPT_NM', header: '承辦科別'},	
				
				{header: "特殊件控管",key: "CONTROL_CODE",render:function(rec, val){
						//超連結至DSC8_3100
						if(rec.CONTROL_CODE){
							var link = new Element('a', { href : '#' });
							link.update( "<font color='red'>"+val+"</font>" );	
								link.observe('click', 
									function(){ linkTo_DSC8_3100(rec.BORROW_ID,rec.BORROW_NAME,rec.CONTROL_SOURCE);	
								});
							return link;
						}
						return "<font color='red'>"+val+"</font>";
					}},

				
				
				{ key: 'REJ_REASON', header: '退<br>件<br>', 
						render: function(record, value) {
							if(value){
								var link = document.createElement('a');
								link.href = '#';
								if (value.length>5) {
									link.innerHTML = value.substring(0, 6);
								} else {
									link.innerHTML = value;
								}
								link.onclick = function(){
									doLink('DSA2_1200',record.APPLY_ID);
								};
								value = link;								
							}
							return value;
						}
					},

				{ key: 'RESEND_NOTE', header: '重<br>複<br>', 
						render: function(record, value) {
							value = value == '1'? 'V':'';
							return value;
						}
					},		
				{ key: 'CRED_STATUS', header: '債<br>信<br>', 
						render: function(record, value) {
							value = value == '1'? 'V':'';
							return value;
						}
					},		
				{ key: 'LOAN_NOTE', header: '曾<br>貸<br>', 
						render: function(record, value) {
							value = value == '1'? 'V':'';
							return value;
						}
					},		
				/*
				{ key: 'GUAR_NOTE', header: '曾<br>保<br>', 
						render: function(record, value) {
							value = value == '1'? 'V':'';
							return value;
						}
					},*/
				{ key: 'REJECT_NOTE', header: '曾<br>退<br>', 
						render: function(record, value) {
							value = value == '1'? 'V':'';
							return value;
						}
					},		
				{ key: 'IS_APPRAISAL', header: '免<br>鑑<br>', 
						render: function(record, value) {
							value = (value == '1' || value == '3'|| value == '5')? 'V':'';
							return value;
						}
					},		
				/*
				{ key: 'SUPPLY_CODE', header: '補<br>全<br>', 
						render: function(record, value) {
							value = value == '1'? 'V':'';
							return value;
						}
					},*/
				<%--[20240730] 難字調整 --%>
				{ key: 'CRED_NAME', header: '徵信人員<br>', attrs:{style:"font-family:'EUDC'"}},
				{ key: 'REMIT_NAME', header: '匯款人員<br>', attrs:{style:"font-family:'EUDC'"}},
				{ key: 'SEND_DATE', header: '送件日期<br>',
							render:function(record,value){
							 	return value ? Date.toROC(value) : '';
							}
					}, 
				{ key: 'PACK_DATE', header: '包裹日期<br>',
							render:function(record,value){
							 	return value ? Date.toROC(value) : '';
							}
					},  
				{ key: 'AGREE_DATE', header: '核准日期<br>',
							render:function(record,value){
							 	return value ? Date.toROC(value) : '';
							}
					},  
				{ key: 'Comment', header: '備註事項<br>',
							render:function(record,value){
								if(value){
									value = '<font color="red">' + value + '</font>';
								}
							 	return value;
							}
					}, 
				{ key: 'LOAN_DATE', header: '貸放日期',
							render:function(record,value){
								return value ? Date.toROC(value) : '';
							}
					}, 
				{ key: 'DOC_DEPT_NM', header: '案件單位'},
				{ key: 'SUPPLY_STATUS_NM', header: '核貸前補全狀態'},	
				{ key: 'APPR_APPLY_ID', header: '鑑價紀錄參照', sortable: false, attrs:{colSpan:6},
						render: function(record, value) {
							if(value){
								var link = document.createElement('a');
								link.href = '#';
								link.innerHTML = value;
								link.onclick = function(){
									doLink('DSA3_0500',record.APPR_APPLY_ID);
								};
								value = link;								
							}							
							else{
								value = '兩年內無鑑價紀錄';
							}
							return value;
						}
					}, 
				<%--[20240730] 難字調整 --%>
				{ key: 'APPR_NAME', header: '鑑價人員<br>', attrs:{style:"font-family:'EUDC'"}}, 
				{ key: 'REMIT_ASSIGN_DATE', header: '匯款派件<br>',
							render:function(record,value){
							 	return value ? Date.toROC(value) : '';
							}
					}
			]
       	} );	
	}
	
	//查詢
	function doQuery(isBackQuery){
		
		//if 「承辦科別」、「查詢方式」若皆為空白
		if($F('CRED_DEPT') == "" && $F('QUERY_TYPE') == ""){
			alert("承辦科別、查詢方式，須擇一選擇");
			return;
		}
		
		//if「徵信人員」、「查詢方式」若皆為空白且「受理進度」為請選擇
		if($F('CRED_ID') == "" && $F('QUERY_TYPE') == ""&& $F('APPLY_PROCESS') == ""){
			alert("徵信人員、查詢方式及受理進度，須擇一選擇");
			return;
		}

		//受理編號,借款人ID轉大寫
		if($F('QUERY_TYPE')=='BORROW_ID' || $F('QUERY_TYPE')=='APPLY_ID'){
			$('QRY_COND1').value = $F('QRY_COND1').toUpperCase();
		}
		
		if(!checkInput()){
			return;
		}
		
		//儲存目前查詢條件
		if(!isBackQuery){
			BQ_ARG = setBQ_ARG();
		}
	
		preTd = null ;//再次查詢時清除preTd，避免顯示到上一次的暫存個資
		
		var params = { info:Object.toJSON(BQ_ARG) };
		var successAction = function(resp){
			//if為連結回來,重產生[徵信人員]下拉清單
			if(isBackQuery && resp.CRED_ID_LIST){
				createCRED_ID_Select(resp.CRED_ID_LIST);
				$('CRED_ID').value = BQ_ARG.CRED_ID;
			}
			grid.load(resp.rtnList.evalJSON());
		};
		var errorAction = function(resp){
			grid.load([]);
			//if為連結回來,重產生[徵信人員]下拉清單
			if(isBackQuery && resp.CRED_ID_LIST){
				createCRED_ID_Select(resp.CRED_ID_LIST);
				$('CRED_ID').value = BQ_ARG.CRED_ID;
			}
		};

		ajaxPost( 'query', params, successAction, errorAction);	
	}

	//[承辦科別]連動[徵信人員]
	function doGetCRED_IDMap(){
		$('CRED_ID').options.length = 1;
		var CRED_DEPT = $F('CRED_DEPT');
		if(!CRED_DEPT){
			return;
		}
		
		ajaxPost('getCRED_IDList',{'CRED_DEPT':CRED_DEPT}, 
			function(resp){
				createCRED_ID_Select(resp.CRED_ID_LIST);	
			}
		);
	}
	
	//建立[徵信人員]選單
	function createCRED_ID_Select(optList){
	 	for(var i=0; i<optList.length; i++) {
			var oOption = document.createElement("option");
			oOption.text = optList[i].NAME;
			oOption.value = optList[i].ID;
			$('CRED_ID').options.add(oOption);			
		}			
	}

	//	檢核Function
	function checkInput() {
		validator.clear();
		validator.errHandler = new AlertHandler();
		
		var QUERY_TYPE = $F('QUERY_TYPE');
		if (QUERY_TYPE){
			if (QUERY_TYPE == 'AGREE_DATE' || QUERY_TYPE == 'PACK_DATE' || QUERY_TYPE == 'SEND_DATE'){
				validator.define('QRY_COND2','','日期(起)格式有誤', 'isROCdate');
				validator.define('QRY_COND3','','日期(迄)格式有誤', 'isROCdate');			
			}else if (QUERY_TYPE == 'BORROW_ID'){
				if(!validation.checkROCID($F('QRY_COND1')) && !validation.checkUniSN($F('QRY_COND1'))){
					validator.define('QRY_COND1','','借款人須符合身分證字號或統編格式',  'string', '-1', '-1');
				}		
			}else {
				if($F('QRY_COND1').trim() == ''){
					validator.define('QRY_COND1','查詢條件','內容不可為空', 'string', '-1', '-1');
				}
			}
		}
			
		return validator.validate();
	}
	
	
	//超連結
	function doLink(link,APPLY_ID){
			BQ_ARG.isBack = 'Y';
			var LP_JSON = {
				APPLY_ID:APPLY_ID,
				BQ_ARG:BQ_ARG,
				action:'${dispatcher}/'+ link + '/prompt'
			};
			CSRUtil.linkTo(LP_JSON, 'form1');		
	}
	
	//儲存目前查詢值
	function setBQ_ARG(){
		var ARG={};
		ARG.CRED_DEPT = $F('CRED_DEPT');
		ARG.CRED_ID = $F('CRED_ID');
		ARG.QUERY_TYPE = $F('QUERY_TYPE');
		ARG.APPLY_PROCESS = $F('APPLY_PROCESS');
		ARG.QRY_COND1 = $F('QRY_COND1');
		ARG.QRY_COND2 = $F('QRY_COND2');
		ARG.QRY_COND3 = $F('QRY_COND3');
		//ARG.OPER_CODE = $F('OPER_CODE');
		ARG.SOURCE = $F('SOURCE');
		return ARG;
	}
	
	<%--查詢方式連動--%>
    <%--function getOPER_CODE(){
		var QUERY_TYPE = $F('QUERY_TYPE');
		var OPER_CODE = $('OPER_CODE');
		OPER_CODE.length = 0;
		if(!QUERY_TYPE){
			return;
		}
		
		if(QUERY_TYPE == "APPLY_ID" || QUERY_TYPE == "BORROW_ID" || QUERY_TYPE == "BORROW_NAME"){
			var oOption = new Option(OPER_CODE_LIST['='],'=');
			OPER_CODE.add(oOption);
			return;
		}
		
		for(map in OPER_CODE_LIST){
			var oOption =  new Option(OPER_CODE_LIST[map],map);
			OPER_CODE.add(oOption);
		}
	}--%>
	
	//查詢方式連動查詢條件
	function genQueryCond(){ 
		var QUERY_TYPE = $F('QUERY_TYPE');
		if(QUERY_TYPE ==''){
			$('QRY_COND1').value ='';
			$('QRY_COND2').value ='';
			$('QRY_COND3').value ='';
			
			$('QRY_COND1').hide();
			$('QRY_COND2').hide();
			$('QRY_COND3').hide();
		} else {		
			if (QUERY_TYPE == "APPLY_ID" || QUERY_TYPE == "BORROW_ID" || QUERY_TYPE == "BORROW_NAME"){
				$('QRY_COND1').show();
				$('QRY_COND2').value ='';
				$('QRY_COND3').value ='';
				$('QRY_COND2').hide();
				$('QRY_COND3').hide();							
			} else {
				$('QRY_COND1').hide();
				$('QRY_COND1').value ='';
				$('QRY_COND2').show();
				$('QRY_COND3').show();
			}				
		}			 
	 }
	
	function setRadioValue( radioName , value ){
		var radios = document.getElementsByName(radioName);
		for( var i=0 ; i<radios.length ; i++ ){
			if( radios[i].value == value ){
				radios[i].checked = true;
				break;
			}else{
				radios[i].checked = false;
			}
		}
	}
	
	return{                              
              
		init:function(){
			<cathay:LocaleDisplay sysCode='DS' dateFields='QRY_COND2 QRY_COND3' var='localeDisplay' />	
			initTableUI();
			validator = new Validator();     
			
			//查詢                    
			$('btn_query').observe('click',function(event){                                        
					doQuery(false);					
				}                        
			);
			
			//承辦科別]連動   
			$('CRED_DEPT').observe('change',function(event){                                        
					doGetCRED_IDMap();					
				}                        
			); 
			
			$('SOURCE').value = "0"; 
			
			<%--查詢方式連動--%>
			$('QUERY_TYPE').observe('change',genQueryCond);
			$('QUERY_TYPE').simulate('change');
		   var LP_JSON = CSRUtil.isBackLink('form1');

		   if(LP_JSON){
		   		BQ_ARG = LP_JSON.BQ_ARG;
				doQuery(true);		
		   }
		   <%-- <c:forEach items="${OPER_CODE_LIST}"  var="map">
				OPER_CODE_LIST["${map.key}"]= "${map.value}" ;
		   </c:forEach> --%>
		   		   				
			$('QRY_COND1').hide();
			$('QRY_COND2').hide();
			$('QRY_COND3').hide();
		}                 
	}
}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >

<form id="form1" name="form1" method="post">	
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="12%">承辦科別</td>
		<td class="tbYellow2" width="36%">
			<select class="textBox2" name="CRED_DEPT" id="CRED_DEPT">
	                         <option value=""></option>												
	                         <c:forEach var="map" items="${DEPT_LIST}">
	                           <option value="${map.key}">${map.value}</option>
	                         </c:forEach>
	                       </select>
		</td>
		<td class="tbYellow" width="12%">徵信人員</td>
		<td class="tbYellow2" width="25%">
			<select class="textBox2" name="CRED_ID" id="CRED_ID" alt="ch">
				<option value=""></option>
			</select>
		</td>
		<td class="tbYellow" rowspan="3" align="center" width="15%"><input id="btn_query" name="btn_query" type="button" class="button" value="查詢"></td>
	</tr>
	<tr>
		<td class="tbYellow">查詢方式</td>
		<td class="tbYellow2">
			<select class="textBox2" name="QUERY_TYPE" id="QUERY_TYPE">
	                         <option value=""></option>													
	                         <c:forEach var="map" items="${QUERY_TYPE_LIST}">
	                           <option value="${map.key}">${map.value}</option>
	                         </c:forEach>
	                       </select>
			<%--<select class="textBox2" name="OPER_CODE" id="OPER_CODE">
	                         <c:forEach var="map" items="${OPER_CODE_LIST}">
	                           <option value="${map.key}" <c:if test="${map.key eq '='}">selected</c:if>  >${map.value}</option>
	                         </c:forEach>
	                       </select> --%>											
			<input id="QRY_COND1" name="QRY_COND1" type="text" class="textBox2" size="15" value="">
			<input id="QRY_COND2" name="QRY_COND2" type="text" class="textBox2" /> 
			<input id="QRY_COND3" name="QRY_COND3" type="text" class="textBox2" />	
		</td>
		<td class="tbYellow">受理進度</td>
		<td class="tbYellow2">
			<select class="textBox2" name="APPLY_PROCESS" id="APPLY_PROCESS">
	                         <option value="">全部</option>													
	                         <c:forEach var="map" items="${APPLY_PROCESS_LIST}">
	                           <option value="${map.key}">${map.value}</option>
	                         </c:forEach>
	                       </select>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">案件來源</td>
		<td class="tbYellow2" colSpan="3">
			<select id="SOURCE" name = "SOURCE">
			       	<option value='0'>國壽</option>
			       	<option value='1'>世華</option>
			</select>
		</td>
	</tr>							
</table>

<table id="grid" class="grid"></table>
</form>
</body>
<!-- InstanceEnd -->
</html>
