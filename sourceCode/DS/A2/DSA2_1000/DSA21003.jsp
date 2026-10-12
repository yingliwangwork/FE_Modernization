<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
Date        Version Description Author
2011-10-03  1.0     Created     陳正毅

程式功能概要說明：
程式功能	動產簽件作業
程式名稱	DSA2_1003.java
作業方式	ONLINE 

@author 楊宗翰
@since 2011-11-04

[20191108] : 修改件
             申請書190910001301-增列「交易觀察對象」判斷與顯示:
             1.「試算」 , 新增檢核
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>

<script type="text/JavaScript">

<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


var validator;

var pattern_time = /(\d+)-(\d+)-(\d\d) (\d+):(\d+)/;	// 日期格式
var pattern_date = /(\d+)-(\d+)-(\d\d)/;	// 日期格式(date)


var A010_VO;


function initApp(){

	PageUI.createPageWithAllBodySubElement("DSA21003" , "核貸作業" , "法金簽件作業",0,'${titleNotDisplay}' == 'Y');

	autoFormatToNumber();	
	
	validator = new Validator();
	
	new UI().init();
	//20200527 修正無新契約但有顯示小腳丫
	//近3個月是否有投保新契約
	<%-- 20200901 效能問題，畫面改成一律顯示超連結，由另一個畫面去查新契約資料 --%>
	/*<c:if test="${hasATApply eq 'N'}">		
		$$('.hasATApply').each(function(ele){
			ele.hide();
		});
	</c:if>*/
	
	<c:if test="${not empty A010_VO}">		
		alert("查詢完成");
	</c:if>
	
}


function checkInput(msg, isConfirm){
	

	if(parent.form1){
		var APPLY_ID = parent.form1.APPLY_ID.value;
	
		if(APPLY_ID==''){
			alert(msg);
			return false;
		}
		
		if(APPLY_ID != $F('APPLY_ID')){
		 	alert('欲異動的受理編號:'+APPLY_ID+'與原先查詢的'+$F('APPLY_ID')+'不同，請重新查詢!');
		 	return false;
		}
	}
	
	if(isConfirm){
		valid1.reset();
			
		if( !valid1.validate() ) {
			return false;
		}
	}
	
	
	return true;
}


var valid1;
var hasCal;

function UI(){

	function initValidation(){
		valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});	
		Validation.addAllThese([
			[ 'chkLOAN_LIMIT',  '須輸入0~100的數字', function(v){ 
				var len = v.length;
				if( (len<=0) || (isNaN(v)) ){
					return false;
				}else if( v<0 || v>100) {
					return false;
				}
				return true;
			 } ],
			[ 'chkTextArea1',  '字數限制2000字大小', function(v){
						return validation.checkInputLength(v, 2000, null, null);
					 }
			] 		
		]);		
	}
	
	return {
		init:function() {
			displayMessage();
			initValidation();
						
			$("btn_cal").observe('click',function(event){
				doTrimTextArea();
				buttons.doCalCheck();	
				//buttons.doCal();										
			});
			$("btn_confirm").observe('click',function(event){
				doTrimTextArea();
				buttons.doConfirmCheck();										
			});
			
			$("btn_delete").observe('click',function(event){
				buttons.doDelete();										
			});

			
			//批覆書
			$("btn_DSA21007").observe('click',function(event){
				buttons.doLinkToPDF('DSA2_1007');
			});	

			//不動產明細
			$("btn_DSA21006").observe('click',function(event){
				buttons.doLinkToPDF('DSA2_1006');
			});
			//設定利率，當a130有值就顯示a130的結果
			<c:choose>
				<c:when test="${empty A130_VO or empty A130_VO.INTEREST }">
					$('INTEREST').setValue(CSRUtil.$fmt('${RATE_MAP.INTEREST}', "#,###.##"));
				</c:when>
				<c:otherwise>
					$('INTEREST').setValue(CSRUtil.$fmt('${A130_VO.INTEREST}', "#,###.##"));
				</c:otherwise>
			</c:choose>
		}
	};
}

//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	
	doConfirmCheck:function(){
		var msg = '請先查詢，再進行簽件!';
		if(!checkInput(msg, true)){
				return;
		}		
		if(parent.form1.CONTROL_CODE.value == "ERR"){
	    
	       	alert("本件為特殊控管件,無法進行簽件!!");
	    	return;
	    }
	    if(!hasCal){
				alert("請先試算，再進行簽件!");
				return false;
			}
	    
		var queryData = {
			APPLY_ID: '${A010_VO.APPLY_ID}',
			INTEREST: $F('INTEREST'),
			AGREE_AMT: $F('AGREE_AMT'),
			LIMIT_AMT: $F('LIMIT_AMT'),
			LOAN_LIMIT: $F('LOAN_LIMIT'),
			CRED_STATUS1: $('CRED_STATUS1').checked == true? '1':'0',
			CRED_STATUS2: $('CRED_STATUS2').checked == true? '1':'0',
			CRED_STATUS3: $('CRED_STATUS3').checked == true? '1':'0',
			CRED_NOTE: $('CRED_NOTE').innerHTML.trim(),
			A_VALUE: $F('A_VALUE'),
			CRED_DEPT: $F('CRED_DEPT'),
			//20191114 申請書190911001639:不當招攬,查詢受理日前三個月內是否有投保新契約
			//20190424 申請書200407001711 徵信報告書加強審查作業：調整為送件日前三個月
			BORROW_ID: '${A010_VO.BORROW_ID}', 
			APPLY_DATE: '${A010_VO.APPLY_DATE}', 
			SEND_DATE: '${A010_VO.SEND_DATE}'
		};
		var actionName = "confirmCheck"; 
		var params = {"queryData":Object.toJSON(queryData)};
		
		new Ajax.Request( 
			"<%=dispatcher%>/DSA2_1003/" + actionName,
			{ parameters: params,
		       onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){								
					if (resp.UpdateCheckMSG1 == 'OK'){
						buttons.doConfirm(params);
					} else {
						msgWin.setCallback(function(){   
							buttons.doConfirm(params);
						});
					}
				}
		    }}
		);
		//ajaxPost(actionName, params);
	},
	// 20191108 增加 檢核
	doCalCheck:function(){
		var msg = '請先查詢，再進行試算!';
		if(!checkInput(msg)){
			return;
		}		
		var actionName = "calCheck"; 
		var queryData = {
			APPLY_ID: '${A010_VO.APPLY_ID}',
			BORROW_ID: '${A010_VO.BORROW_ID}', 
			INTEREST: $F('INTEREST'),
			AGREE_AMT: $F('AGREE_AMT'),
			LIMIT_AMT: $F('LIMIT_AMT'),
			LOAN_LIMIT: $F('LOAN_LIMIT'),
			CRED_STATUS1: $('CRED_STATUS1').checked == true? '1':'0',
			CRED_STATUS2: $('CRED_STATUS2').checked == true? '1':'0',
			CRED_STATUS3: $('CRED_STATUS3').checked == true? '1':'0',
			CRED_NOTE: $('CRED_NOTE').innerHTML.trim(),
			A_VALUE: $F('A_VALUE'),
			CRED_DEPT: $F('CRED_DEPT')
		};
		var params = {"queryData":Object.toJSON(queryData)};		 	
		new Ajax.Request( 
			"<%=dispatcher%>/DSA2_1003/" + actionName,
			{ parameters: params,
	          onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){								
					if (resp.UpdateCheckMSG1 == 'OK'){
						buttons.doCal(params);
					} else {
						msgWin.setCallback(function(){   
							buttons.doCal(params);
						});
					}
				}
	        }}
		);		 
	},
	doCal:function(queryData){		 
		msgWin.clearCallback(); 
		var actionName = "cal";		 
		hasCal = false;
		new Ajax.Request( 
			"<%=dispatcher%>/DSA2_1003/" + actionName,
			{ parameters: queryData,
	          onSuccess: function(XHT, resp){										
				if(CSRUtil.isSuccess(resp)){									
					hasCal = true;
					loadQryData(resp);
				}				
	        }}
		);		 
	},doConfirm:function(queryData){		 
		msgWin.clearCallback(); 
		var actionName = "confirm";		 
		hasCal = false;	
		new Ajax.Request( 
			"<%=dispatcher%>/DSA2_1003/" + actionName,
			{ parameters: queryData,
	          onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					var checkMoneyLaunderMsg = resp.checkMoneyLaunderMsg;
					var CHK_ID = resp.CHK_ID; //洗錢防制檢核紀錄畫面傳入ID
					if (checkMoneyLaunderMsg) {
						alert(checkMoneyLaunderMsg);
						if (CHK_ID) {
							//190211 禹含(內部申請書190212000817)：AIL01300初始查詢條件檢核調整(需傳入查詢區間)
							var parms = { 
								'QUERY_ID' : CHK_ID,
								'QUERY_START_DATE' : resp.CURRENT_DATE,
								'QUERY_END_DATE' : resp.CURRENT_DATE
							}; 		
							buttons.doPopupWin(parms);
						}	
					} else {
						loadQryData(resp);
					}
				}
	        }}
		);
		//ajaxPost(actionName, params);
	},
	doDelete:function(){
		var msg = '請先查詢，再進行退件呈核!';
		if(!checkInput(msg, false)){
				return;
		}		
						
		var queryData = {
			APPLY_ID: '${A010_VO.APPLY_ID}'
		};
		var actionName = "delete"; 
		var params = {"queryData":Object.toJSON(queryData)};
		ajaxPost(actionName, params);
	},
	
	//導頁至DSA21006、DSA21007
	doLinkToPDF:function(target){
		var url = "<%=dispatcher%>/"+target+"/prompt?APPLY_ID="+$F('APPLY_ID');
		window.open(url,target, "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
	},
	
	//開啟新視窗(洗錢防制檢核紀錄)
  	doPopupWin:function(parms){			
		popupWin.popup({
			'src': '/AIWeb/servlet/HttpDispatcher/AIL0_1300/query',
			'parameters' :  {
				'dataObj' : Object.toJSON(parms)  //配合壽五科 洗錢防制檢核紀錄覆核及盡職/加強審查連結調整=>導頁參數調整
			}
		});
  	},
  	
  	//新契約受理查詢作業
  	linkToDSA21018 : function(){
  		
  		popupWin.popup({
			'src': "<%=dispatcher%>/DSA2_1018/prompt?",
			'parameters' :  {
				'APPLY_ID' : '${A010_VO.APPLY_ID}',
				'BORROW_ID' : '${A010_VO.BORROW_ID}',
				'APPLY_DATE' : '${A010_VO.SEND_DATE}' <%--20200424 申請書200407001711 徵信報告書加強審查作業：調整為送件日前三個月--%>
			}
		});
  	
  	}
};

function loadQryData(resp){
	A010_VO = resp.A010_VO;
	var A130_VO = resp.A130_VO;
	$('BORROW_NAME_SPAN').innerHTML = A010_VO.BORROW_NAME || '';
	$('APPLY_PROCESS_NM_SPAN').innerHTML = resp.APPLY_PROCESS_NM || '';
	$('AGREE_PROCESS_NM_SPAN').innerHTML = resp.AGREE_PROCESS_NM || '';
	var INTEREST = A130_VO? (A130_VO.INTEREST || resp.RATE_MAP.INTEREST) : resp.RATE_MAP.INTEREST;
	$('INTEREST').value = CSRUtil.$fmt(INTEREST, "#,###.##");
	$('AGREE_AMT').value = CSRUtil.$fmt(A130_VO.AGREE_AMT, "#,###.####");
	$('LIMIT_AMT').value = CSRUtil.$fmt(A130_VO.LIMIT_AMT, "#,###.####");
	$('LOAN_LIMIT').value =CSRUtil.$fmt(A130_VO.LOAN_LIMIT, "#,###.####");
	$('CRED_NOTE').innerHTML = A130_VO.CRED_NOTE || '';
	$('INPUT_NAME_SPAN').innerHTML = resp.INPUT_NAME || '';
	$('INPUT_DATE_SPAN').innerHTML = Date.toROC(A130_VO.INPUT_DATE);
	$('A_VALUE').setValue(A130_VO.A_VALUE||'0');
	
	//徵信狀況
	if('1' == A130_VO.CRED_STATUS1){$('CRED_STATUS1').checked = true;}
	if('1' == A130_VO.CRED_STATUS2){$('CRED_STATUS2').checked = true;}
	if('1' == A130_VO.CRED_STATUS3){$('CRED_STATUS3').checked = true;}
	
	//近3個月是否有投保新契約
	<%-- 20200901 效能問題，畫面改成一律顯示超連結，由另一個畫面去查新契約資料 --%>
	/*if('Y'==resp.hasATApply){
		$$('.hasATApply').each(function(ele){
			ele.show();
		});
	}else{
		$$('.hasATApply').each(function(ele){
			ele.hide();
		});
	}*/
}

//檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim
function doTrimTextArea (){
	//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==S==
	if($('CRED_NOTE').value.length>0){
		$('CRED_NOTE').value = $('CRED_NOTE').value.replace(/'/gi, "").replace(/"/gi, "");
		while(true){
			ln0 = $('CRED_NOTE').value.length;
			while(true){
				ln1 = $('CRED_NOTE').value.length;
				if($('CRED_NOTE').value.indexOf('\r\n')>=0){
					//trim掉最後一個\r\n
					$('CRED_NOTE').value = $('CRED_NOTE').value.replace(/\r\n$/g, "");
					if(ln1 == $('CRED_NOTE').value.length){
						break;	
					}
				}else{
					break;
				}
			}
			while(true){
				ln2 = $('CRED_NOTE').value.length;
				if($('CRED_NOTE').value.indexOf(' ')>=0){
					$('CRED_NOTE').value = $('CRED_NOTE').value.replace(/ $/g, "");
					if(ln2 == $('CRED_NOTE').value.length){
						break;	
					}
				}else{
					break;
				}
			}

			if(ln0 == $('CRED_NOTE').value.length){
				break;	
			}
		}
	}
	//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==E==
}

//--------------------------------------------------------------------------
// 共用－Ajax
//--------------------------------------------------------------------------
function ajaxPost( actionName, params, successAction, errorAction){
   	new Ajax.Request( 
		"<%=dispatcher%>/DSA2_1003/" + actionName,
		{ parameters: params,
          onSuccess: function(XHT, resp){
			if(CSRUtil.isSuccess(resp)){
				loadQryData(resp);
			}
        }}
	);
}

//-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

							<form name="form1" id="form1" method="post" action="">

							<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
							<input type='hidden' id='APPLY_ID' value='${A010_VO.APPLY_ID}'>							
							<input type='hidden' id='CRED_DEPT' name='CRED_DEPT' value='${A010_VO.CRED_DEPT}'>
							<input type='hidden' id='AGENT_DEPT_IS_720' name=AGENT_DEPT_IS_720 value='${AGENT_DEPT_IS_720}'>
								<tr>
									<td class="tbYellow2" colspan="4" align="center" width="12%">										
										<input id="btn_cal" name="btn_cal" type="button" class="button" value="試算">
										<input id="btn_confirm" name="btn_confirm" type="button" class="button" value="簽件">	
										<input id="btn_delete" name="btn_delete" type="button" class="button" value="取消">	
										<input id="btn_DSA21007" type="button" class="button" value="批覆書">
										<input id="btn_DSA21006" type="button" class="button" value="不動產明細">	
									</td>
								</tr>																
								
							</table>
							
							<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
								<tr>
									<td class="tbYellow" width="15%">
										受理編號
									</td>
									<td class="tbYellow2" width="29%">
										<span id=APPLY_ID_SPAN>${A010_VO.APPLY_ID}</span>
									</td>
									<td class="tbYellow" width="12%">
										借款人
									</td>
									<td class="tbYellow2" width="32%" colspan="3">
										<span id=BORROW_NAME_SPAN>${A010_VO.BORROW_NAME}</span>
										
										<img id="img_getfile" class="hasATApply" style="cursor: hand;" src="<%=imageBase%>/DS/star5.gif" border=0 onClick="buttons.linkToDSA21018()">
										<span id="hasATApply_s" class="hasATApply">三個月內新契約資訊</span>
									</td>
									
								</tr>
								<tr>
									<td class="tbYellow" width="15%">
										受理進度
									</td>
									<td class="tbYellow2" width="29%">
										<span id=APPLY_PROCESS_NM_SPAN>${APPLY_PROCESS_NM}</span>
									</td>
									<td class="tbYellow" width="12%">
										批示進度
									</td>
									<td class="tbYellow2" width="32%" colspan="3">
										<span id=AGREE_PROCESS_NM_SPAN>${AGREE_PROCESS_NM}</span>
									</td>
								</tr>
								<tr>
									<td class="tbYellow" width="15%">
										利率：
									</td>
									<td class="tbYellow2" width="35%" >
										<input type="text" class="textBox2 required" fieldName="利率" datatype="number" size="5" name="INTEREST" id="INTEREST" value="<cathay:formatNumber type="number" pattern="#,###.##" value="${RATE_MAP.INTEREST}" />" ><span>％</span>
									</td>								
									<td class="tbYellow" width="15%">
										擬准金額：
									</td>
									<td class="tbYellow2" width="35%" colspan="3" >
										<input type="text" class="textBox2 required" fieldName="擬准金額" datatype="number" size="15" name="AGREE_AMT" id="AGREE_AMT" value="<cathay:formatNumber type="number" pattern="#,###.####" value="${AGREE_AMT}" />" ><span>萬</span>
									</td>	
								</tr>
								<tr>
									<td class="tbYellow" width="15%">
										放款值(元)：
									</td>
									<td class="tbYellow2" width="20%" >
									
										<input type="text" class="textBox2 required"  fieldName="放款值(元)" datatype="number" size="15" name="LIMIT_AMT" id="LIMIT_AMT" value="<cathay:formatNumber type="number" pattern="#,###.####" value="${A130_VO.LIMIT_AMT}" />" ><span>元</span>
									</td>	
									<td class="tbYellow" width="15%">
										放款率：
									</td>
									<td class="tbYellow2" width="20%">
										<input type="text" class="textBox2 chkLOAN_LIMIT" fieldName="放款率" datatype="number" size="5" maxlength="5" name="LOAN_LIMIT" id="LOAN_LIMIT" value="<c:out value="${A130_VO.LOAN_LIMIT}" />" ><span>％</span>
									</td>	
									<td class="tbYellow" width="15%">
										業績A值：
									</td>	
									<td class="tbYellow2" width="29%">
										<select id="A_VALUE" fieldName="業績A值"  <c:if test="${A010_VO.GAGE_TYPE eq 6 || A010_VO.GAGE_TYPE eq 7}">disabled</c:if>>
											<c:forEach var="map" items="${AValueMAP}">
												<option value="${map.key}" <c:if test="${map.key eq A_VALUE}">selected</c:if>>${map.value}</option>
											</c:forEach>
										</select>
									</td>						
								</tr>																																
								
								<tr>
									<td class="tbYellow" width="15%">
										徵信狀況：
									</td>
									<td class="tbYellow2" width="29%">
										<input type='checkBox' name='CRED_STATUS1' id='CRED_STATUS1' value='${A130_VO.CRED_STATUS1}' <c:if test="${A130_VO.CRED_STATUS1 eq 1}">checked</c:if> >
										繳息正常<br/>
										<input type='checkBox' name='CRED_STATUS2' id='CRED_STATUS2' value='${A130_VO.CRED_STATUS2}' <c:if test="${A130_VO.CRED_STATUS2 eq 1}">checked</c:if> >
										支存正常<br/>
										<input type='checkBox' name='CRED_STATUS3' id='CRED_STATUS3' value='${A130_VO.CRED_STATUS3}' <c:if test="${A130_VO.CRED_STATUS3 eq 1}">checked</c:if> >
										聯徵正常
									</td>
									
									<td class="tbYellow" width="15%">
										備註資料：
									</td>
									<td class="tbYellow2" width="29%" colspan="3">
										<textarea class="required2 chkTextArea1" fieldName="備註資料"  id="CRED_NOTE" name="CRED_NOTE" wrap="hard" cols="30" rows="10" ><c:out value="${A130_VO.CRED_NOTE}" /></textarea>
									</td>								
								</tr>
																								
								<tr>
									<td class="tbYellow" width="15%">
										作業人員：
									</td>
									<td class="tbYellow2" width="29%" >
										<span id=INPUT_NAME_SPAN>${INPUT_NAME}</span>
									</td>	
									<td class="tbYellow" width="15%">
										作業日期：
									</td>
									<td class="tbYellow2" width="29%"  colspan="3">
										<span id=INPUT_DATE_SPAN><cathay:calendar type="ROC" value="${A130_VO.INPUT_DATE}" /></span>
									</td>								
								</tr>
							</table>
							</form>
							
						
						
</body>
</html>