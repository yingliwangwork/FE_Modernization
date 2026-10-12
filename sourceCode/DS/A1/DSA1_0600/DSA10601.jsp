<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource"/>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script src="<%=htmlBase%>/CM/js/date.js"></script>
<script src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script src="<%=htmlBase%>/CM/js/utility.js"></script>
<script src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
</head>

<script type="text/javascript" >

Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var DATA_MAP = {};

function initApp(){
	cleanMsgBoard();
	setting.buttonAuth();
	
	PageUI.createPageWithAllBodySubElement("DSA10601" , "受理作業" , "2Q人員送件確認", 1);
		
	new UI().init();
	
	PageUI.resize(true);
}

//--------------------------------------------------------------------------
//	以下為UI() public method,放在 return 中
//--------------------------------------------------------------------------  

function UI(){

	return{
	
		init:function(){
				['B1', 'B2', 'B3', 'B4', 'B5'].each(function(e){ 
					$(e+ '_CHECK').observe( "click", function( event ){ 
						var elm = event.element();
						var cond = '#' + e + ' INPUT[type=checkbox]:not([id=' + e + '_CHECK])'
						var checks = $$(cond); 
						var flag = false;
						if(elm.checked == true){
							flag = true;
						} 
	
						checks.each(function(e){e.checked = flag;});
						
					}); 
					$(e+'_SPAN').hide(); 
				});
				
				var LP_JSON = CSRUtil.isBackLink('form1');
				buttonFunction.query(LP_JSON ? LP_JSON.APPLY_ID : '${APPLY_ID}');
				
				
				$("btnSend").observe( "click", function( event ){ buttonFunction.doSend(); } );
				$("btnReject").observe( "click", function( event ){ buttonFunction.doRejcet(); } );
				$("btnReject2").observe( "click", function( event ){ buttonFunction.doRejcet2(); } );
				$("btnMEMO").observe( "click", function( event ){ buttonFunction.doMEMO(); } );
				$("btnCancel").observe( "click", function( event ){ buttonFunction.doCancel(); } );
				$("btnErrClass").observe( "click", function( event ){ buttonFunction.doErrClass(); } );
				//$("btnUpdate2").observe( "click", function( event ){ buttonFunction.doUpdate2(); } );
				$("btnImage").observe( "click", function( event ){ buttonFunction.doImage(); } );
				
		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
}

// ==========================輔助FUNCTION======================================
var auxiliary = {    
	
	// 產生tr
	createTR:function(table, position){
		var tr = table.insertRow(position);
		return tr;
	},
	// 產生td
	createTD:function(tr, position, className, colspan){
		var td = tr.insertCell(position);
		td.className = className;
		if(colspan){
			td.colSpan = colspan;
		}
		return td;
	},
	
	// 產生input物件
	createInput:function(config){
		var input = document.createElement("input");
		input.id = config.id ? config.id : "";
		input.name = config.id ? config.id : "";
		input.className = config.className ? config.className : "";
		input.type = config.type ? config.type : "";
		input.value = config.value ? config.value : "";
		input.onclick = config.clickAction ? config.clickAction : "";
		
		return input;
	},
    
    getcheckBoxValue : function(){
    	var cbs = $$('.cb');
    	var values = [];
    	if(cbs.length){
    		cbs.each(function(e){ if(e.checked) values.push(e.value); });	
    	}
    	return values;
    },
    
    getDATA_MAP : function(){
    	DATA_MAP.RETURN_ITEM_LIST = auxiliary.getcheckBoxValue();
    },
    
    insertDataToTable: function(dataList, tableName){
    	if(dataList){
					$(tableName + '_SPAN').show();
					var table = $(tableName);
					var length = dataList.length;
					var len = length%4;
					var tr;
					for(var i=0; i<length; i++){
						if((i+1)%4==1){
							tr = auxiliary.createTR(table, table.rows.length);
						}
						// radio
						var td = auxiliary.createTD(tr, i%4, "tbBlue2");
						td.width = "25%";
						
						var cb = auxiliary.createInput({id:tableName, className:'cb', type: 'checkbox', value:dataList[i].RETURN_ITEM, clickAction:
							function(){
								
								if(this.checked){
									var cond = '#' + this.name + ' INPUT[type=checkbox]:not([id=' + this.name + '_CHECK])'
									var checks = $$(cond);
									var flag = true;
									checks.each(
										function(e){
											if(!e.checked){
												flag = false;
												return;
											}
										}
									);
									$(this.name+'_CHECK').checked = flag;
								}else{
									$(this.name+'_CHECK').checked = false;
								} 
							}
						});
						td.appendChild(cb);	
						td.appendChild(document.createTextNode(dataList[i].ITEM_NAME));
						if(dataList[i].APPLY_ID){
							cb.checked = true;
						}
					}
					
					//補欄位
					if(len){
						while(4-len){
							var td = auxiliary.createTD(tr, len, "tbBlue2");
							td.width = "25%";
							len++;	
						}
					}
					
					var cond = '#' + tableName + ' INPUT[type=checkbox]:not([id=' + tableName + '_CHECK])'
					var checks = $$(cond); 
					var flag = true;
					checks.each(function(e){
					 	if(!e.checked){
					 		flag = false;
					 		return;
					 	}
					});
						
					if(flag){
						$(tableName+'_CHECK').checked = true;
					}
					
		}
    },
        
    //共用
	ajaxPost : function( actionName, params, successAction, errorAction )
    {
        new Ajax.Request(
            "<%=dispatcher%>/DSA1_0601/" + actionName,
            {
            	parameters:params,
			 	onSuccess:function(resp){				
					successAction(resp.responseJSON);
				}        	
				
            }
        );
    }     
}

// ==========================按鈕 FUNCTION======================================
var buttonFunction = {
	query:function(APPLY_ID_Q){
		auxiliary.ajaxPost("doQuery", {APPLY_ID:APPLY_ID_Q, wobNum:'${wobNum}', queueName:'${queueName}'}, 
			function(resp){
				var rtnMap = resp.rtnMap;
				if(rtnMap){
					['BORROW_NAME', 'CRED_DEPT', 'APPLY_DATE', 'INPUT_ID', 'INPUT_NAME', 'INPUT_DATE'].each(
						function(e){
							DATA_MAP[e] = rtnMap[e]||'';
							$(e+'_span').innerHTML = rtnMap[e]||'';
						}
					);
					
					if(rtnMap['APPLY_ID']){
						var link = document.createElement('a');
						link.href = '#';
						link.innerHTML = rtnMap['APPLY_ID']||'';
						link.onclick = function(){
							hyperlinks.linkDetail('<%=dispatcher%>/DSA1_1700/prompt', rtnMap['APPLY_ID']||'');	
						};			
						$('APPLY_ID_span').appendChild(link);
					}
					DATA_MAP['APPLY_ID'] = rtnMap['APPLY_ID']||'';
					DATA_MAP['MEMO'] = resp.MEMO||'';
					DATA_MAP['RETURN_REASON'] = rtnMap.RETURN_REASON||'';
					DATA_MAP['CRED_CENTER'] = rtnMap.CRED_CENTER||'';
					$('MEMO').innerHTML = resp.MEMO||'';
					$('RETURN_REASON').innerHTML = rtnMap.RETURN_REASON||'';
					auxiliary.insertDataToTable(rtnMap.B1_LIST, 'B1');
					auxiliary.insertDataToTable(rtnMap.B2_LIST, 'B2');
					auxiliary.insertDataToTable(rtnMap.B3_LIST, 'B3');
					auxiliary.insertDataToTable(rtnMap.B4_LIST, 'B4');
					auxiliary.insertDataToTable(rtnMap.B5_LIST, 'B5');
					if(resp.MSG){
						$('button_span').hide();
						$('MSG').innerHTML = resp.MSG;
						DATA_MAP['MSG'] = resp.MSG;
					}
					$('btnSend').disabled = false;
					/*if (rtnMap['SCAN_COMPLETED']) {
						$('btnSend').disabled = false;
						$('btnUpdate2').disabled = true;
					} else {
						$('btnSend').disabled = true;
						$('btnUpdate2').disabled = false;
					}*/
				} else {
					$('btnSend').disabled = true;
					//$('btnUpdate2').disabled = false;				
				}		
			}
		
		);
	},
	
	doSend : function(){
			auxiliary.getDATA_MAP();
			auxiliary.ajaxPost("doSend",{DATA_MAP:Object.toJSON(DATA_MAP)}, function(){
				$$('INPUT[type=button]').each(function(e){ e.disabled = true; });
			});
		
	},	
	doRejcet : function(){
			popupWin.popup({									
				src : '${dispatcher}/DSA1_0803/prompt' ,
				scrolling : 'yes',	
				parameters : { 
					APPLY_ID: APPLY_ID_span.innerText,	
					KIND  	: '1', 	//退回服務中心
					SOURCE  : 'DSA1_0601'								
				},  	
				cb : function(obj){}
			});
			
			//var conf = {};
			//var url = "<%=dispatcher%>" + "/DSA1_0601/link1";
			//conf.src = url;
			//conf.width = document.body.scrollWidth*0.5;
			//conf.height = document.body.scrollHeight*0.3;
			
			//var oEvent = window.event ? window.event : e;
			//conf.left = document.body.scrollLeft + oEvent.clientX - conf.width/2;
			//conf.top = document.body.scrollTop + oEvent.clientY + 15;
			//conf.scrolling = 'no';
			//conf.isAdjWin = 'yes';
		      
			//conf.parameters = Object.toJSON({"width":conf.width, "height":conf.height});
	
			//var callbackFun = function(objs){
			//if(objs){
				//auxiliary.getDATA_MAP();
				//DATA_MAP.RETURN_REASON = objs;
				//auxiliary.ajaxPost("doRejcet",{DATA_MAP:Object.toJSON(DATA_MAP)}, function(){
				//$$('INPUT[type=button]').each(function(e){ e.disabled = true; });
				//});
			//}
		//};
		//hyperlinks.popup(conf, callbackFun);
	},
		doRejcet2 : function(){
			popupWin.popup({									
				src : '${dispatcher}/DSA1_0803/prompt' ,
				scrolling : 'yes',	
				parameters : { 
					APPLY_ID: APPLY_ID_span.innerText,	
					KIND  	: '2', 	//電子補全通知
					SOURCE  : 'DSA1_0601'								
				},  	
				cb : function(obj){}
			});
	},
	doMEMO : function(){
	
			var conf = {};
			
			conf.width = document.body.scrollWidth*0.5;
			conf.height = document.body.scrollHeight*0.3;
			
			var url = "<%=dispatcher%>" + "/DSA1_0601/link2?width="+conf.width+"&height="+conf.height+"&MEMO="+DATA_MAP.MEMO;
			conf.src = url;
			
			var oEvent = window.event ? window.event : e;
			conf.left = document.body.scrollLeft + oEvent.clientX - conf.width/2;
			conf.top = document.body.scrollTop + oEvent.clientY + 15;
			conf.scrolling = 'no';
			conf.isAdjWin = 'yes';
			
			var callbackFun = function(objs){
			if(objs){			
				auxiliary.getDATA_MAP();
				DATA_MAP.MEMO = objs.trim();		
			
				auxiliary.ajaxPost("doMEMO",{DATA_MAP:Object.toJSON(DATA_MAP)}, function(resp){
				DATA_MAP['MEMO'] = resp.MEMO.trim()||'';
				$('MEMO').innerHTML = resp.MEMO.trim()||'';
				});
			}
		};
		hyperlinks.popup(conf, callbackFun);	
	
	},
	doCancel : function(){
			auxiliary.getDATA_MAP();
			auxiliary.ajaxPost("doCancel",{DATA_MAP:Object.toJSON(DATA_MAP)}, function(){});
	},
	doErrClass : function(){
			auxiliary.getDATA_MAP();
			auxiliary.ajaxPost("doErrClass",{DATA_MAP:Object.toJSON(DATA_MAP)}, function(){});
	},    
	/*doUpdate2 : function(){
			auxiliary.getDATA_MAP();
			auxiliary.ajaxPost("doUpdate2",{DATA_MAP:Object.toJSON(DATA_MAP)}, function(){
				$$('INPUT[type=button]').each(function(e){ e.disabled = true; });
			});
		
	},*/
	doImage : function(){
		var APPLY_ID = '${APPLY_ID}';
		popupWin.windowOpen('<%=dispatcher%>/DSA0_0200/prompt',{
			'parameters': {'APPLY_ID': APPLY_ID},
			'fullScreen': false,
			'attributes': {'resizable': 'yes'}
		});
	}

}

//--------------------------------------------------------------------------
// 超連結
//--------------------------------------------------------------------------
var hyperlinks = {
	// popUp
	popup:function(conf, callbackFun){
		popupWin.callbackHandler = callbackFun;
		popupWin.popup(conf);
	},
	// fullPopUp
	fullpopup:function(url, text){
		if(url){
			if(text){
				return popupWin.createFullPopupLink(text, url);
			}else{
				popupWin.fullPopup(url);
			}
		}
	},
	// 開新視窗
	openwindow:function(url, title, attrs){
		
		
		if(url){
			if(attrs){
				window.open(url, title, attrs); 
			}else{
				window.open(url); 
			}
		}
	},
	// 導頁
	linkDetail:function(src, APPLY_ID){
		var LP_JSON = {
			APPLY_ID:APPLY_ID,
			action:src
		};
		CSRUtil.linkTo(LP_JSON, 'form1');
	}

};
// ==========================設定UI FUNCTION======================================
var setting = {  
	//button權限控管
	buttonAuth : function(){
		var authButtons = {
			B0034:"btnSend",  //送件
			B0008:["btnReject","btnReject2"],  //退回服務中心,退回經手人
			B0035:"btnMEMO",  //意見   			
			B0023:"btnCancel",  //取消取件
			B0037:"btnErrClass",  //錯誤歸類
			//B0232:"btnUpdate2",  //轉送鑑價
			B0044:"btnImage"  //影像連結
		};
		<dz:grantButtons FUNC_ID="DSA10601"  ignored="false"/> 	
	}
	
	
}

</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 
<form name="form1" id="form1" method="post">	
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr align="center" class="tbYellow0">
			  <td colspan="8" class="textBold">送件明細表</td>
		</tr>
		<tr align="center" class="tbYellow0">
			<td width="10%" valign="middle" align="center" class="tbBlue">受理編號</td>
			<td width="10%" valign="middle" align="center" class="tbBlue">借款人</td>
			<td width="10%" valign="middle" align="center" class="tbBlue">承辦科別</td>
			<td width="10%" valign="middle" align="center" class="tbBlue">受理日期</td>
			<td width="10%" valign="middle" align="center" class="tbBlue">送件人員ID</td>
			<td width="10%" valign="middle" align="center" class="tbBlue">送件人員姓名</td>
			<td width="10%" valign="middle" align="center" class="tbBlue">送件日期</td>
			<td width="30%" valign="middle" align="center" class="tbBlue">注意事項</td>
		</tr>
		<tr align="center" class="tbYellow0">
			<td class="tbBlue2"><span id="APPLY_ID_span"></span></td>
			<td class="tbBlue2"><span id="BORROW_NAME_span"></span></td>
			<td class="tbBlue2"><span id="CRED_DEPT_span"></span></td>
			<td class="tbBlue2"><span id="APPLY_DATE_span"></span></td>
			<td class="tbBlue2"><span id="INPUT_ID_span"></span></td>
			<td class="tbBlue2"><span id="INPUT_NAME_span"></span></td>
			<td class="tbBlue2"><span id="INPUT_DATE_span"></span></td>
			<td class="tbBlue2">
				<span id="button_span">
					<input id="btnSend" name="btnSend" type="button" class="button" value="送件">
					<!--<input id="btnUpdate2" name="btnUpdate2" type="button" class="button" value="轉送鑑價">-->
					<input id="btnReject" name="btnReject" type="button" class="button" value="退回服務中心">
					<input id="btnReject2" name="btnReject2" type="button" class="button" value="電子補全通知">
					<input id="btnMEMO" name="btnMEMO" type="button" class="button" value="意見">
					<input id="btnCancel" name="btnCancel" type="button" class="button" value="取消取件">
					<input id="btnErrClass" name="btnErrClass" type="button" class="button" value="錯誤歸類">
					<input id="btnImage" name="btnImage" type="button" class="button" value="影像連結">
				</span><span id="MSG"></span>
			</td>
		</tr>
		<tr align="center" class="tbYellow0">
			<td valign="middle" align="center" class="tbBlue">退回原因</td>
			<td colspan="4" align="left" class="tbBlue2">
				<span id="RETURN_REASON">
				</span>
			</td>
			<td valign="middle" align="center" class="tbBlue">意見</td>
			<td colspan="3" align="left" class="tbBlue2">
				<span id="MEMO">
				</span>
			</td>
		</tr>
	</table>
	<table id="B1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr align="center" class="tbYellow0">
			  <td colspan="4" class="textBold">房貸受理接送件單<SPAN ID="B1_SPAN"><INPUT id="B1_CHECK" type="checkbox">全選</SPAN></td>
		</tr>
	</table>
	<table id="B2" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr align="center" class="tbYellow0">
			  <td colspan="4" class="textBold">借款申請書<SPAN ID="B2_SPAN"><INPUT id="B2_CHECK" type="checkbox">全選</SPAN></td>
		</tr>
	</table>
	<table id="B3" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr align="center" class="tbYellow0">
			  <td colspan="4" class="textBold">土地謄本<SPAN ID="B3_SPAN"><INPUT id="B3_CHECK" type="checkbox">全選</SPAN></td>
		</tr>
	</table>
	<table id="B4" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr align="center" class="tbYellow0">
			  <td colspan="4" class="textBold">建物謄本<SPAN ID="B4_SPAN"><INPUT id="B4_CHECK" type="checkbox">全選</SPAN></td>
		</tr>
	</table>
	<table id="B5" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr align="center" class="tbYellow0">
			  <td colspan="4" class="textBold">其他<SPAN ID="B5_SPAN"><INPUT id="B5_CHECK" type="checkbox">全選</SPAN></td>
		</tr>
	</table>	
</form>

</body>
</html>