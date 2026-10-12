<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA21015.jsp
作者：i9100621
功能：線上放款審查會
完成：2012/02/01
-->
<html>
<head>
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script language="JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSA21015().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA21015(){

	var valid1;
	var INST_TYPE = '${INST_TYPE}';
	var INST_LEVEL = '${INST_LEVEL}';
	var REJ_LEVEL = '${REJ_LEVEL}';
	INST_LEVEL = (INST_LEVEL==''||INST_LEVEL==null)? INST_LEVEL: parseInt(INST_LEVEL,10);

	var buttonAuth = function (){
		var authButtons = {
				B0007:"btn_agree"<%--同意--%> ,
				B0087:"btn_reject"<%--不同意--%>,
				B0088:"btn_meeting"<%--召開會議討論--%>,
				B0079:"btn_getFile"<%--鑑價影像檔--%>
		};
		<dz:grantButtons FUNC_ID="DSA21015" ignored="false"/>
	};
          
	
	//頁面控制
	var colControl = {
		//<input>enable
		isEdit:function(){
			if(( '${A010Map.GAGE_TYPE}' != '1')){
				$('btn_DSA21006').disabled = true;
                                $('btn_DSA21008').disabled = true;
			}else{
				$('btn_DSA21006').disabled = false;
                                $('btn_DSA21008').disabled = false;
			}
			
			//非影像件,不開啟影像連結
			var TOTAL_PAGE = '${A010Map.TOTAL_PAGE}';
			if (TOTAL_PAGE != null && TOTAL_PAGE != '' && parseInt(TOTAL_PAGE) > 0) {
				$('btn_DSA00200').disabled = false;
			} else {
				$('btn_DSA00200').disabled = true;
			}	
			
			//if INST_TYPE = ‘D’ 不顯示召開會議討論BUTTON
			<c:if test="${INST_TYPE eq 'D'}">
				$('btn_meeting').hide();
			</c:if>
				
		}		
	};
	

	//同意,不同意,召開會議
	function doActionBy(action){

		var dataMap = getDataMap();
		
		var params = { inputMap:Object.toJSON(dataMap)};
		
		//成功
		var successAction = function(resp){
			loadAllData(resp);
		};
		
		
		ajaxPost(action,params,successAction,null);	
	}
	
	//鑑價影像檔             
	function doGetFile(){
	
		var dataMap = getDataMap();
		var APPR_APPLY_ID = $F('APPR_APPLY_ID');
		if (APPR_APPLY_ID){
			dataMap.APPLY_ID = APPR_APPLY_ID;
		}
				
		var params = { inputMap:Object.toJSON(dataMap)};
		//成功
		//var successActionOpen = function(resp){
		//	if(resp.apprPath && resp.apprPath!=''){
		//		var theAction = resp.apprPath;
		//		window.open(theAction);
		//	}else{
		//		alert('取得鑑價影像檔失敗');
		//	}
		//};
		var successActionOpen = function(resp){
			if(resp.isExternal && resp.isApprExternalAuth) { //高級主管由外網登入開啟影像
				RPTUtil.download({'downloadFileName': resp.apprFileNM,	'downloadFileFullPath': resp.apprPath});
			} else {
				window.open(resp.apprPath);
			}
		};
		
		ajaxPost('getFile',params,successActionOpen,null);
	}
	
	//不動產明細
	function doOpenDSA21006(){
		var url = "<%=dispatcher%>/DSA2_1006/prompt?APPLY_ID="+'${APPLY_ID}';
	
		window.open(url,"DSA2_1006", "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
	}
	
	//批覆書
	function doOpenDSA21007(){
		var url = "<%=dispatcher%>/DSA2_1007/prompt?APPLY_ID="+'${APPLY_ID}';
	
		window.open(url,"DSA2_1007", "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
	}

    //鑑估表
	function doOpenDSA21008(){
		var url = "<%=dispatcher%>/DSA2_1008/prompt?APPLY_ID="+'${APPLY_ID}';
	
		window.open(url,"DSA2_1008", "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
	}
	
	//影像連結
	function doOpenDSA00200(){
		//var url = "${pageContext.request.contextPath}/servlet/HttpDispatcher/DSA0_0200/prompt?APPLY_ID="+'${APPLY_ID}';
		//window.open(url, "DSA0_0200");
		popupWin.windowOpen('<%=dispatcher%>/DSA0_0200/prompt',{
			'parameters': {'APPLY_ID': $F('APPLY_ID')},
			'fullScreen': false,
			'attributes': {'resizable': 'yes'}
		});		
	}
	
	//取得畫面資料
	function getDataMap(){
		var dataMap = {};
		$w('REFER_ID APPLY_ID APPR_APPLY_ID CRED_DEPT AGREE_LEVEL REJ_LEVEL COMMENT APPLY_GROUP').each(
			function(key){
				dataMap[key] = $F(key);
			}
		);		
		dataMap.INST_LEVEL = INST_LEVEL;
		dataMap.INST_TYPE = INST_TYPE;	
		return dataMap;
	}
					
	//載入資料
	function loadAllData(resp){
		var	A010Map = resp.A010Map?resp.A010Map:{};
		var	A130Map = resp.A130Map?resp.A130Map:{};
		var	rejectMap = resp.rejectMap?resp.rejectMap:{};
		
		//hidden 欄位
		$('APPR_APPLY_ID').value = A130Map.APPR_APPLY_ID;
		//$('CRED_DEPT').value = A010Map.CRED_DEPT;
		$('REJ_LEVEL').value = rejectMap.REJ_LEVEL;	
		$('AGREE_LEVEL').value =  A130Map.AGREE_LEVEL;//呈核層級
		$('APPLY_GROUP').value = A010Map.APPR_GROUP;
		<c:if test="${INST_TYPE eq 'C'}">
			loadData.blockC(A010Map,A130Map);
		</c:if>	
		<c:if test="${INST_TYPE eq 'D'}">
			loadData.blockB(rejectMap);
		</c:if>			
		loadData.blockD(A130Map,resp);		
	}
	
	var loadData = {
		
		blockB:function(rejectMap){//退件批覆書(D)
			<c:if test="${INST_TYPE eq 'D'}">
			$('REJ_ITEM_NM').innerHTML = rejectMap.REJ_ITEM_NM || '';//退件原因大項	
			$('REJ_REASON_NM').innerHTML = rejectMap.REJ_REASON_NM|| '';//退件原因
			$('SEND_CHECK_NM').innerHTML = rejectMap.SEND_CHECK_NM|| '';//是否送件控管
			$('REJ_NAME').innerHTML = rejectMap.REJ_NAME|| '';//退件人員	
			$('REJ_NOTE').innerText = rejectMap.REJ_NOTE|| '';//退件備註
			$('REJ_LEVEL_NM').innerHTML = rejectMap.REJ_LEVEL_NM|| '';//退件核定層級	
			</c:if>	
		},
		
		blockC:function(A010Map,A130Map){//一般,快審件(C)
			<c:if test="${INST_TYPE eq 'C'}">
			$('RETURN_TYPE').value = A010Map.RETURN_TYPE || '';//還款方式
			$('FIX_YY').value = A010Map.FIX_YY || '';//定期.年 (整數)
			$('FIX_MM').value = A010Map.FIX_MM || '';//定期.月(整數)
			$('SPR_YY').value = A010Map.SPR_YY || '';//分期.年	(整數)
			$('SPR_MM').value = A010Map.SPR_MM || '';//分期.月(整數)

			$('A_VALUE').value = A130Map.A_VALUE || '';//A值	DECIMAL(5,2)
			//利率區塊控制
			//colControl.blockC1C2(A010Map.MM_CODE);

			<c:if test="${A010Map.MM_CODE eq '0' || A010Map.MM_CODE eq '2'}">
				$('INTEREST').value = A130Map.INTEREST || '';//一般型調整後利率 DECIMAL(6,4)
			</c:if>
			<c:if test="${A010Map.MM_CODE eq '1' || A010Map.MM_CODE eq '2'}">

				$('INTEREST_M').value = A130Map.INTEREST_M || '';//理財型表定利率	 DECIMAL(6,4)
			</c:if>

			//$('AGREE_LEVEL_SELECT').value =  A130Map.AGREE_LEVEL;//呈核層級

			radio.setValue('TRANS_CODE',A130Map.TRANS_CODE);//呈核原因

			<c:if test="${(INST_TYPE eq 'C') && INST_LEVEL <= 40 }">
				$('TOTAL_GAGE_AMT').value = CSRUtil.$fmt(A130Map.TOTAL_GAGE_AMT,'#,###.####');
			
				tmp_TRANS_REASON = A130Map.TRANS_REASON || '';

				$('TRANS_REASON').value = tmp_TRANS_REASON.replace('<br>','');//轉呈原因 :字數限制250中文字大小	
			</c:if>
			</c:if>	
		},
		
		blockD:function(A130Map,resp){//主管批示區塊
			$('COMMENT').innerHTML = '';
			$('AGREE_LEVEL_NM').innerHTML = A130Map.AGREE_LEVEL_NM;
			$('AGREE_HISTORY').innerHTML = resp.AGREE_HISTORY;
			$('ONLINE_HISTORY').innerHTML = resp.ONLINE_HISTORY;
		}			
		
	};
	
	var radio = {
		
		getValue:function(name){
			var v = '';
			$$('#form1 input[name="'+name+'"]').each( function(radio){ 
				if(radio.checked){
				 	v = radio.value;
				 }
			} );
			return v;		
		},
		
		setValue:function(name,v){
			$$('#form1 input[name="'+name+'"]').each( function(radio){ 
				if(radio.value == v){
				 	radio.checked = true;
				 }
			} );		
		}	
	};	
	//檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim
	function doTrimTextArea (val){
		//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==S==
		if($(val).value.length>0){
			$(val).value = $(val).value.replace(/'/gi, "").replace(/"/gi, "");
			while(true){
				ln0 = $(val).value.length;
				while(true){
					ln1 = $(val).value.length;
					if($(val).value.indexOf('\r\n')>=0){
						//trim掉最後一個\r\n
						$(val).value = $(val).value.replace(/\r\n$/g, "");
						if(ln1 == $(val).value.length){
							break;	
						}
					}else{
						break;
					}
				}
				while(true){
					ln2 = $(val).value.length;
					if($(val).value.indexOf(' ')>=0){
						$(val).value = $(val).value.replace(/ $/g, "");
						if(ln2 == $(val).value.length){
							break;	
						}
					}else{
						break;
					}
				}
	
				if(ln0 == $(val).value.length){
					break;	
				}
			}
		}
		//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==E==
	}
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		
		new Ajax.Request( "<%=dispatcher%>/DSA2_1015/" + actionName,
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

	return{                              
		initApp:function(){
		
			<c:if test="${INST_TYPE eq 'C'}">
				PageUI.createPageWithAllBodySubElement("DSA21015" , "核貸作業" , "線上放款審查會", 0,'${titleNotDisplay}' == 'Y');
			</c:if>
			
			<c:if test="${INST_TYPE eq 'D'}">
				PageUI.createPageWithAllBodySubElement("DSA21015" , "核貸作業" , "大額件退件審核", 0,'${titleNotDisplay}' == 'Y');
			</c:if>
			
			//同意                   
			$('btn_agree').observe('click',function(event){                                        
					doTrimTextArea ('COMMENT');
					if(INST_TYPE == 'C' && INST_LEVEL <= 40){
						doTrimTextArea ('TRANS_REASON');
					}
					doActionBy('agree');					
				}                        
			);
			
			
			//不同意                   
			$('btn_reject').observe('click',function(event){                                        
					doTrimTextArea ('COMMENT');
					if(INST_TYPE == 'C' && INST_LEVEL <= 40){
						doTrimTextArea ('TRANS_REASON');
					}
					doActionBy('reject');					
				}                        
			);
			
			//召開會議討論作業                
			$('btn_meeting').observe('click',function(event){                                        
					doTrimTextArea ('COMMENT');
					if(INST_TYPE == 'C' && INST_LEVEL <= 40){
						doTrimTextArea ('TRANS_REASON');
					}
					doActionBy('meeting');					
				}                        
			);			
			
			//鑑價影像檔               
			$('btn_getFile').observe('click',function(event){                                        
					doGetFile();					
				}                        
			);
			
			//批覆書               
			$('btn_DSA21007').observe('click',function(event){                                        
					doOpenDSA21007();					
				}                        
			);													
			
			//不動產明細
			$('btn_DSA21006').observe('click',function(event){                                        
					doOpenDSA21006();					
				}                        
			);	
			
			//影像連結
			$('btn_DSA00200').observe('click',function(event){                                        
					doOpenDSA00200();					
				}                        
			);	

            //鑑估表
			$("btn_DSA21008").observe('click',function(event){
				    doOpenDSA21008();
			});	
			
			//頁面<input>enable控制            
			colControl.isEdit();
			
			//利率區塊控制
			//colControl.blockC1C2('${A010Map.MM_CODE}');	

			var MM_CODE = '${A010Map.MM_CODE}';
			$('AGREE_AMT_P').innerHTML = ('${rtnMap.AGREE_AMT_P}' ? MoneyFormat('${rtnMap.AGREE_AMT_P}') : 0 ) + '&nbsp萬';
			if(MM_CODE == '1' || MM_CODE == '2'){//當為理財型
				$('AGREE_AMT_M').innerHTML = ('${rtnMap.AGREE_AMT_M}' ? MoneyFormat('${rtnMap.AGREE_AMT_M}') : 0 ) + '&nbsp萬';
			}
			
			$('APPR_REALVALUE').innerHTML = ('${rtnMap.APPR_REALVALUE}' ? MoneyFormat('${rtnMap.APPR_REALVALUE}') : 0 ) + '&nbsp元';	

			<c:if test="${INST_TYPE eq 'C'}">
				$('iniarea').hide();		
			</c:if>
			
			buttonAuth();
			fix();
			displayMessage();

		}                 
	}

}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
	<span>
		<form id="form1" name="form1" method="post">
			
			<input type="hidden" id="APPLY_ID" name="APPLY_ID" value="<c:out value='${APPLY_ID}' />">
			<input type="hidden" id="REFER_ID" name="REFER_ID" value="<c:out value='${REFER_ID}' />">
			<input type="hidden" id=APPR_APPLY_ID value="${A130Map.APPR_APPLY_ID}" >
			<!--<input type="hidden" id="CRED_DEPT" value="${A010Map.CRED_DEPT}" >-->
			<input type="hidden" id="CRED_DEPT" value="${CRED_DEPT}" >
			<input type="hidden" id="REJ_LEVEL" value="${rejectMap.REJ_LEVEL}" >		
			<input type="hidden" id="AGREE_LEVEL" value="${A130Map.AGREE_LEVEL}" >		
			<input type="hidden" id="APPLY_GROUP" value="${A010Map.APPR_GROUP}" >
<!------------------------ A區--------------------->	
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
				<tr>
					<td class="tbYellow"  colspan = "4">
						<span><c:out value='${rtnMap.PREFER_TYPE_NM}' /></span>
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="20%">受理編號</td>
					<td class="tbYellow2" colspan = "3"><c:out value='${A010Map.APPLY_ID}' />&nbsp<c:out value='${rtnMap.LOAN_TYPE_NM}' /></td>					
				</tr>
				<tr>					
					<td class="tbYellow">借款人</td>
					<td class="tbYellow2"><c:out value='${A010Map.BORROW_NAME}' />&nbsp&nbsp<c:out value='${A010Map.BORROW_ID}' /></td>
					<td class="tbYellow" width = "14%">借款人資料</td>
					<td class="tbYellow2"><c:out value='${rtnMap.BORR_DATA}' /></td>
				</tr>
				<tr>					
					<td class="tbYellow">借款用途</td>
					<td class="tbYellow2" colspan = "3"><c:out value='${rtnMap.LOAN_POS_NM}' /></td>					
				</tr>
				<tr>
					<c:choose>
						<c:when test="${A010Map.MM_CODE eq '1' || A010Map.MM_CODE eq '2'}">
							<td class="tbYellow">擬准一般型貸款</td>
							<td class="tbYellow2" id = "AGREE_AMT_P" ></td>					
							
							<td class="tbYellow">擬准理財型貸款</td>
							<td class="tbYellow2" id = "AGREE_AMT_M" ></td>
						</c:when>
						<c:otherwise> 
							<td class="tbYellow" >擬准一般型貸款</td>
							<td class="tbYellow2" id = "AGREE_AMT_P" colspan ="3"></td>	
						</c:otherwise>
					</c:choose>
				</tr>
				<tr>					
					<td class="tbYellow">擔累貸金額╱鑑估總值</td>
					<td class="tbYellow2"><c:out value='${rtnMap.GA_RATE}' /> &nbsp%</td>
					<td class="tbYellow">區域放款率</td>
					<td class="tbYellow2"><c:out value='${rtnMap.LOAN_LIMIT_C}' /> &nbsp %</td>
				</tr>
				<tr>					
					<td class="tbYellow">擬准一般型利率</td>
					<td class="tbYellow2"><c:out value='${rtnMap.INTEREST}' /> &nbsp%</td>
					<td class="tbYellow">一般型表定利率</td>
					<td class="tbYellow2"><c:out value='${rtnMap.INTEREST_CONT1}' /> &nbsp %</td>
				</tr>
				<c:if test="${A010Map.MM_CODE eq '1' || A010Map.MM_CODE eq '2'}">
					<tr>					
						<td class="tbYellow">擬准理財型利率</td>
						<td class="tbYellow2" colspan = "3"><c:out value='${rtnMap.INTEREST_CONT2}' />&nbsp %</td>					
					</tr>
				</c:if>
				</tr>
				<tr>					
					<td class="tbYellow">擔保品</td>
					<td class="tbYellow2"><c:out value='${rtnMap.FLOOR_NM}' /> &nbsp <c:out value='${rtnMap.BUILD_TYPE_NM}' /> &nbsp <c:out value='${rtnMap.USE_STATUS_NM}' /> &nbsp <c:out value='${rtnMap.REAL_USE_NM}' /></td> 
					<td class="tbYellow">屋齡</td>
					<td class="tbYellow2"><c:out value='${rtnMap.BUILD_AGE}' /> &nbsp 年</td>
				</tr>
				<tr>					
					<td class="tbYellow">還款方式</td>
					<td class="tbYellow2"><c:out value='${RETURN_TYPE_NM}' /></td>
					<td class="tbYellow">年期</td>
					<td class="tbYellow2">
					<c:if test="${A010Map.FIX_YY != '0' || A010Map.FIX_MM != '0'}">
						定期
					</c:if>
					<c:if test="${A010Map.FIX_YY != '0'}">
						<c:out value='${A010Map.FIX_YY}' />年&nbsp
					</c:if>
					<c:if test="${A010Map.FIX_MM != '0'}">
						<c:out value='${A010Map.FIX_MM}' />月&nbsp
					</c:if>
					<c:if test="${A010Map.SPR_YY != '0' || A010Map.SPR_MM != '0'}">
						分期 
					</c:if> 
					<c:if test="${A010Map.SPR_YY != '0'}">
						<c:out value='${A010Map.SPR_YY}' />年&nbsp
					</c:if> 
					<c:if test="${A010Map.SPR_MM != '0'}">
						<c:out value='${A010Map.SPR_MM}' />月&nbsp
					</c:if> 
					</td> 					
				</tr>				
				<tr>					
					<td class="tbYellow">擔保品座落</td>
					<td class="tbYellow2" colspan = "3">( <c:out value='${rtnMap.AREA_CODE_930318}' /> )<c:out value='${rtnMap.GAGE_ADDR}' /> </td>					
				</tr>
				<tr>					
					<td class="tbYellow">判定時價</td>
					<td class="tbYellow2" colspan = "3" id = "APPR_REALVALUE"></td>					
				</tr>
			</table>									
<!------------------------ B區--------------------->											
			<c:if test="${INST_TYPE eq 'D'}" >						
			<div id="blockB" >	
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
				<tr>
					<td class="tbYellow" rowSpan="6" width="2%">退<br>件<br>批<br>覆<br>書</td>
					<td class="tbYellow" width="23%">退件原因大項</td>
					<td class="tbYellow2" width="75%"><span id="REJ_ITEM_NM">${rejectMap.REJ_ITEM_NM}</span></td>								
				</tr>
				<tr>
					<td class="tbYellow" >退件原因</td>
					<td class="tbYellow2" ><span id="REJ_REASON_NM">${rejectMap.REJ_REASON_NM}</span></td>							
				</tr>
				<tr>
					<td class="tbYellow" >是否送件控管</td>
					<td class="tbYellow2" ><span id="SEND_CHECK_NM">${rejectMap.SEND_CHECK_NM}</span></td>								
				</tr>																					
				<tr>
					<td class="tbYellow" >退件人員</td>
					<td class="tbYellow2" ><span id="REJ_NAME">${rejectMap.REJ_NAME}</span></td>									
				</tr>
				<tr>
					<td class="tbYellow" >退件備註</td>
					<td class="tbYellow2" ><span id="REJ_NOTE">${rejectMap.REJ_NOTE}</span></td>								
				</tr>																				
				<tr>
					<td class="tbYellow" >退件核定層級</td>
					<td class="tbYellow2" ><span id="REJ_LEVEL_NM">${rejectMap.REJ_LEVEL_NM}</span></td>									
				</tr>
			</table>
			</div>
			</c:if>
<!------------------------ C區--------------------->											
			<c:if test="${INST_TYPE eq 'C'}">
			<div id="blockC" >	
			<table id="blockC" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
				
				<tbody id = "iniarea">
				<tr>
					<td class="tbYellow" width="2%">年期</td>
					<td class="tbYellow2" width="98%" colspan="2">
						還款方式						
						<select class="textBox2" name="RETURN_TYPE" id="RETURN_TYPE"  onchange="changeEvent.FIX_SPR_CONTROL(this.value)" disabled>
                             <c:forEach var="map" items="${RETURN_TYPE_LIST}">
                               <option value="${map.key}">${map.value}</option>
                             </c:forEach>
                           </select>
                           	定期	<input type="text" datatype="number" id="FIX_YY" name="FIX_YY" fieldName="定期(年)" class="textBox2 validate-digits" size="6" disabled>年
                           	<input type="text" datatype="number" id="FIX_MM" name="FIX_MM" fieldName="定期(月)" class="textBox2 validate-digits" size="6"  disabled>月+
                           	分期	<input type="text" datatype="number" id="SPR_YY" name="SPR_YY" fieldName="分期(年)" class="textBox2 validate-digits" size="6"  disabled>年	
                           	<input type="text" datatype="number" id="SPR_MM" name="SPR_MM" fieldName="分期(月)" class="textBox2 validate-digits" size="6" disabled>月			                            							
					</td>								
				</tr>
				<tr>
					<td class="tbYellow" >A值</td>
					<td class="tbYellow2" colspan="2">
						<select class="textBox2" name="A_VALUE" id="A_VALUE" >
                             <c:forEach var="map" items="${A_VALUE_LIST}">
                               <option value="${map.key}">${map.value}</option>
                             </c:forEach>
                           </select>
					</td>
				</tr> 
				<tr>
					<td class="tbYellow" >利率</td>
					<td class="tbYellow2" colspan="2">
					<c:if test="${A010Map.MM_CODE eq '0' || A010Map.MM_CODE eq '2'}">
					一般型調整後利率<input type="text" datatype="number" id="INTEREST" name="INTEREST" fieldName="一般型調整後利率" class="textBox2 validate-number" size="15" disabled>
					<BR><BR>
					</c:if>
					<c:if test="${A010Map.MM_CODE eq '1' || A010Map.MM_CODE eq '2'}">
					理財型表定利率<input type="text" datatype="number" id="INTEREST_M" name="INTEREST_M" fieldName="理財型表定利率" class="textBox2 validate-number" size="15" disabled>
					<BR><BR>
					</c:if>
					</td>						
				</tr>
				</tbody> 
				
				<c:if test="${(INST_TYPE eq 'C') && INST_LEVEL <= 40 }">
				<tr>
					<td class="tbYellow2" colspan="2">
						須呈核至<select class="textBox2" name="AGREE_LEVEL" id="AGREE_LEVEL" onchange="changeEvent.buttonShow(this.value)" disabled>								
                             <c:forEach var="map" items="${AGREE_LEVEL_LIST}">
                               <option value="${map.key}" >${map.value}</option>
                             </c:forEach>
                           </select>(最高核定層級)<br>
                             <c:forEach var="map" items="${TRANS_CODE_LIST}">
                                <input type="radio" name="TRANS_CODE" class="textBox2 chkTRANS_CODE chkAGREE_LEVEL" value="${map.key}" disabled>${map.value}
                             </c:forEach>
                             <br>含本次累貸金額：<input type="text" datatype="number" id="TOTAL_GAGE_AMT" name="TOTAL_GAGE_AMT" fieldName="含本次累貸金額" class="textBox2 chkTOTAL_GAGE_AMT1 chkTOTAL_GAGE_AMT2" size="15"  disabled>萬
                             <br>是否召開線上放審會<input type="radio" id="IS_ONLINE1" name="IS_ONLINE" class="textBox2 chkIS_ONLINE chkIS_ONLINE1" value="1">是<input type="radio" id="IS_ONLINE0" name="IS_ONLINE" class="textBox2" value="0">否
					</td>
					<td width="55%" class="tbYellow2">
					轉呈原因：<br>
					<textarea  name="TRANS_REASON" id="TRANS_REASON" class="textBox2 chkTRANS_REASON1 chkTRANS_REASON2" rows="3" cols="55" disabled></textarea>
					</td>
				</tr>
				</c:if>				
			</table>
			</div>			
<!------------------------ D區--------------------->											
			</c:if>	
			<div id="blockD">	
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
				<tr>
					<td class="tbYellow" width="2%" align="center">主<BR>管<BR>批<BR>示</td>
					<td width="60%" class="tbYellow2"><textarea  name="COMMENT" id="COMMENT" rows="5" cols="72" ></textarea></td>
					<td class="tbYellow" width="8%" align="center" >核<BR>定<BR>層<BR>級</td>
					<td class="tbYellow2" width="15%"><span id="AGREE_LEVEL_NM">${A130Map.AGREE_LEVEL_NM}</span></td>
					<td class="tbYellow2" width="15%">			
					<input id="btn_DSA21007" type="button" class="button" value="批覆書"><BR>
                    <input id="btn_DSA21008" type="button" class="button" value="鑑估表">
					<input id="btn_DSA00200" type="button" class="button" value="影像連結"><BR>
					<input id="btn_getFile" type="button" class="button" value="鑑價影像檔"><BR>
					<input id="btn_DSA21006" type="button" class="button" value="不動產明細"><BR>
					<input id="btn_agree" type="button" class="button" value="同意"><BR>
					<input id="btn_reject" type="button" class="button" value="不同意"><BR>
					<input id="btn_meeting" type="button" class="button" value="召開會議討論">
					</td>	
				</tr>
				<tr>
					<td class="tbYellow" width="2%" align="center">批<BR>示<BR>歷<BR>程</td>
					<td class="tbYellow2" width="15%" colspan="4"><span id="AGREE_HISTORY">${AGREE_HISTORY}</span></td>
				</tr>
				<tr style=display:none>
					<td class="tbYellow" width="2%" align="center">線上放審會批示</td>
					<td class="tbYellow2" width="15%" colspan="4"><span id="ONLINE_HISTORY">${ONLINE_HISTORY}</span></td>
				</tr>									
			</table>
			</div>
		</form>
	</span>
</body>
<!-- InstanceEnd -->
</html>