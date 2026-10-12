<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA60300.jsp
功能：一般覆審作業
作者：蔡政均
完成：2020/01/21

[20221228] 修改程式  楊青峰
 新增本金彈性還還款方式
[20240930] 修改件 CHROME瀏覽器難字調整
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" />
<!--匯入外部Javascript 與 css-->
<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
<%--[20240930]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!-- 必要 -->
<!-- 目前系統常用的表格工具 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/popupWin.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/InputUtility.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/date.js'></script>

<script type="text/JavaScript">
Event.observe(window, 'load', new DSA60300().initApp);

function DSA60300(){
	
	var valid;
	var valid1;
    var grid;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA6_0300/');
	//前次查詢條件
	var queryCondition;
	var G_rtnMap = {};
	 
	//畫面檢核
	function initValidation(){
			
		valid = new Validation('form1');
		valid.define( "required" , { id: "REV_YM", errMsg : "覆審年月不可為空"} );
		valid.define( "required" , { id: "LOAN_ID", errMsg : "貸款帳號不可為空"} );
		valid.define( "validID", { id: "LOAN_ID" , errMsg: "貸款帳號格式有誤" } );
		
		valid1 = new Validation('form1', { mode :"validate"} );
		valid1.define( "validateRadioCheck" , { id: "REV_NUM_A", errMsg : "請輸入一般覆審要項"} );
		valid1.define( "validateRadioCheck" , { id: "REV_NUM_B", errMsg : "請輸入一般覆審要項"} );
		valid1.define( "validateRadioCheck" , { id: "REV_NUM_C", errMsg : "請輸入一般覆審要項"} );
		valid1.define( "validateRadioCheck" , { id: "REV_NUM_D", errMsg : "請輸入一般覆審要項"} );
		valid1.define( "validateRadioCheck" , { id: "REV_NUM_E", errMsg : "請輸入一般覆審要項"} );
		valid1.define( "validateRadioCheck" , { id: "REV_NUM_F", errMsg : "請輸入一般覆審要項"} );
		valid1.define( "validateRadioCheck" , { id: "REV_NUM_G", errMsg : "請輸入一般覆審要項"} );
		valid1.define( "validateRadioCheck" , { id: "REV_NUM_H", errMsg : "請輸入一般覆審要項"} );
		valid1.define( "validateRadioCheck" , { id: "REV_NUM_I", errMsg : "請輸入一般覆審要項"} );
		valid1.define( "validateRadioCheck" , { id: "REV_NUM_J", errMsg : "請輸入一般覆審要項"} );
		valid1.define( "validateRadioCheck" , { id: "REV_NUM_K", errMsg : "請輸入一般覆審要項"} );
		valid1.define( "validateRadioCheck" , { id: "REV_RESULT", errMsg : "請輸入覆審結果"} );
		//valid1.define( "required" , { id: "REV_DESC", errMsg : "說明不可為空"} );
		valid1.define( "validate1REV_DESC" , { id: "REV_DESC" } );
		valid1.define( "validate2REV_DESC" , { id: "REV_DESC" } );
		valid1.define( "validate3REV_DESC" , { id: "REV_DESC" } );
		
 		Validation.addAllThese( [
			[ 'validID', '貸款帳號格式有誤', 
				function(v , node) { 
					if(v){
						<%--貸款帳號10碼英數字--%>
						return v.length == 10 && (/^[a-zA-Z0-9]+$/.test(v)); 
					}
					return true;
				}
			],
 			[ 'validateRadioCheck', '請輸入一般覆審要項', 
				function(val,ele){
					var name = ele.id;
					var flag = false;
					$$('#form1 input[name="'+ name + '"]').each(function(elm){
						if(elm.checked){
							flag = true;
						}
					})
					return flag;
				} 
			],
			[ 'validate1REV_DESC', '說明請勿輸入單引號!!',
				function(v){
					return (v.indexOf('\'') != -1) ? false : true ;
				}
			],
			[ 'validate2REV_DESC', '說明請勿輸入半形逗號!!',
				function(v){
					return (v.indexOf(',') != -1) ? false : true ;
				}
			],
			[ 'validate3REV_DESC', '覆審結果為異常，說明必須輸入!!',
				function(v){
					if(v.length == 0){
						var form_name = $('form1');
						return (form_name.REV_RESULT[1].checked) ? false : true ;
					}
					return true;
				}
			]
		]);
	};
	
	var actions = {
		getReqMap : function(){
			var record = {};
			record['LOAN_ID'] = $F('LOAN_ID');
			record['REV_YM'] = $('REV_YM').value; //民國年月
			return record;
		},
		getReqBMap : function(){
			var B_Record = G_rtnMap;
			$$('#form1 input[type="radio"]').each(function(elm){
				if(elm.checked){
					B_Record[elm.name] = elm.value;
				}
			})
			B_Record["REV_DESC"] = $('REV_DESC').value;
			B_Record["CAPT_DESC"] = $('CAPT_DESC').value;
			B_Record["BOSS_DESC"] = $('BOSS_DESC').value;
			return B_Record;
		},
		updateBInfo : function(map){
			G_rtnMap = map;
			$("LOAN_ID_S").update(map.LOAN_ID ||'');
			$("APPLY_ID_S").update(map.APPLY_ID ||'');
			$("REV_YM_S").update(map.REV_YM ||'');
			$("REV_PROCESS_NM").update(map.REV_PROCESS_NM ||'');
			$("BORROW_NAME").update(map.BORROW_NAME ||'');
			$("BORROW_ID").update(map.BORROW_ID ||'');
			$("AGREE_LEVEL_NM").update(map.AGREE_LEVEL_NM ||'');
			$("CRED_NM").update(map.CRED_NM ||'');
			$("GAGE_ADDR").update(map.GAGE_ADDR ||'');
			$("LOAN_AMT").update(localeDisplay.formatNumber(map.LOAN_AMT));
			$("SUM_REMAIN_AMT").update(localeDisplay.formatNumber(map.SUM_REMAIN_AMT));
			$("RATE").update(localeDisplay.formatNumber(map.RATE, 2));
			$("LOAN_DATE").update(map.LOAN_DATE ? Date.toROC(map.LOAN_DATE) : '');
			$("LOAN_TYPE_NM").update(map.LOAN_TYPE_NM ||'');
			$("RETURN_TYPE_NM").update(map.RETURN_TYPE_NM ||'');
			$("FIX_PERIOD").update(map.FIX_PERIOD ||'');
			$("SPR_PERIOD").update(map.SPR_PERIOD ||'');
			$("LOAN_KIND_NM").update(map.LOAN_KIND_NM ||'');
			$("PREFER_TYPE_NM").update(map.PREFER_TYPE_NM ||'');
			$("LOAN_POS_NM").update(map.LOAN_POS_NM ||'');
			$("LOAN_POS2_NM").update(map.LOAN_POS2_NM ||'');
			
			<%-- [20221228] 新增本金彈性還期間 --%>
			$("FLEX_PERIOD_NM").update(map.FLEX_PERIOD_NM ||'');
			
			$("REV_NM").update(map.REV_NM ||'');
			$('REV_ID').value = map.REV_ID ? map.REV_ID : '';
			$("REV_DATE").update(map.REV_DATE ||'');
			var form_name = $('form1');
			if(map.REV_RESULT == "0"){
				form_name.REV_RESULT[0].checked = true;
			} else if(map.REV_RESULT == "1"){
				form_name.REV_RESULT[1].checked = true;
			}
			$('REV_DESC').value = map.REV_DESC ? map.REV_DESC : '';
			$('CAPT_ID').value = map.CAPT_ID ? map.CAPT_ID : '';
			$("CAPT_NM").update(map.CAPT_NM ||'');
			$("CAPT_DATE").update(map.CAPT_DATE ||'');
			$('CAPT_DESC').value = map.CAPT_DESC ? map.CAPT_DESC : '';
			$('BOSS_ID').value = map.BOSS_ID ? map.BOSS_ID : '';
			$("BOSS_NM").update(map.BOSS_NM ||'');
			$("BOSS_DATE").update(map.BOSS_DATE ||'');
			$('BOSS_DESC').value = map.BOSS_DESC ? map.BOSS_DESC : '';
			
			InputUtility.lengthLimit.doLengthLimit('REV_DESC');
			InputUtility.lengthLimit.doLengthLimit('CAPT_DESC');
			InputUtility.lengthLimit.doLengthLimit('BOSS_DESC');
			
			//模擬textarea keyup動作
			$w('REV_DESC CAPT_DESC BOSS_DESC').each( 
				function(id){
					$(id).simulate('keyup');
				}
			);
		},
		clearBInfo : function(){
			valid1.reset();
			$("LOAN_ID_S").update("");
			$("APPLY_ID_S").update("");
			$("REV_YM_S").update("");
			$("REV_PROCESS_NM").update("");
			$("BORROW_NAME").update("");
			$("BORROW_ID").update("");
			$("AGREE_LEVEL_NM").update("");
			$("CRED_NM").update("");
			$("GAGE_ADDR").update("");
			$("LOAN_AMT").update("");
			$("SUM_REMAIN_AMT").update("");
			$("RATE").update("");
			$("LOAN_DATE").update("");
			$("LOAN_TYPE_NM").update("");
			$("RETURN_TYPE_NM").update("");
			$("FIX_PERIOD").update("");
			$("SPR_PERIOD").update("");
			$("LOAN_KIND_NM").update("");
			$("PREFER_TYPE_NM").update("");
			$("LOAN_POS_NM").update("");
			$("LOAN_POS2_NM").update("");

			$$('#form1 input[type="radio"]').each(function(elm){
				elm.checked = false;
			})
			
			$("REV_NM").update("");
			$("REV_ID").value = '';
			$("REV_DATE").update("");
			$("REV_DESC").value = '';
			$("CAPT_ID").value = '';
			$("CAPT_NM").update("");
			$("CAPT_DATE").update("");
			$("CAPT_DESC").value = '';
			$("BOSS_ID").value = '';
			$("BOSS_NM").update("");
			$("BOSS_DATE").update("");
			$("BOSS_DESC").value = '';
			
			InputUtility.lengthLimit.doLengthLimit('REV_DESC');
			InputUtility.lengthLimit.doLengthLimit('CAPT_DESC');
			InputUtility.lengthLimit.doLengthLimit('BOSS_DESC');
		},
		defaultBRadioButton : function(form_name){
			<%-- 預設選取 '是' --%>
			form_name.REV_NUM_A[0].checked = true;
			form_name.REV_NUM_B[0].checked = true;
			form_name.REV_NUM_C[0].checked = true;
			form_name.REV_NUM_D[0].checked = true;
			form_name.REV_NUM_E[0].checked = true;
			form_name.REV_NUM_F[0].checked = true;
			form_name.REV_NUM_G[0].checked = true;
			form_name.REV_NUM_H[0].checked = true;
			form_name.REV_NUM_I[0].checked = true;
			form_name.REV_NUM_J[0].checked = true;
			form_name.REV_NUM_K[0].checked = true;
		},
		updateBRadioButton : function(list){
			var form_name = $('form1');
			if(list.size() == 0){
				actions.defaultBRadioButton(form_name);
				return;
			}
			list.forEach(function(item){
				var num = item["REV_NUM"];
				var kind = item["FINISH_KIND"];
				var index = -1;
				if(kind == 0) {
					index = 2;
				} else if(kind == 1){
					index = 0;
				} else if(kind == 2){
					index = 1;
				}
				if(index != -1) {
					switch (num) {
						 case '00A': case '01A':
							form_name.REV_NUM_A[index].checked = true;
							break;
						 case '00B': case '01B':
							form_name.REV_NUM_B[index].checked = true;
							break;
						 case '00C': case '01C':
							form_name.REV_NUM_C[index].checked = true;
							break;
						 case '00D': case '01D':
							form_name.REV_NUM_D[index].checked = true;
							break;
						 case '00E': case '01E':
							form_name.REV_NUM_E[index].checked = true;
							break;
						 case '00F': case '01F':
							form_name.REV_NUM_F[index].checked = true;
							break;
						 case '00G': case '01G':
							form_name.REV_NUM_G[index].checked = true;
							break;
						 case '00H': case '01H':
							form_name.REV_NUM_H[index].checked = true;
							break;
						 case '00I': case '01I':
							form_name.REV_NUM_I[index].checked = true;
							break;
						 case '00J': case '01J':
							form_name.REV_NUM_J[index].checked = true;
							break;
						 case '00K': case '01K':
							form_name.REV_NUM_K[index].checked = true;
							break;						
						 default:					 
					}
				}
			})	
		}
	};
	
	function backEndValue(){
		var rtnMap = <c:out value="${rtnMap}" default="null" escapeXml="false"/>;
		var rtnList = <c:out value="${rtnList}" default="[]" escapeXml="false"/>;
		if(rtnMap != null){
			$('LOAN_ID').value = rtnMap.LOAN_ID ? rtnMap.LOAN_ID : '';
			$('REV_YM').value = rtnMap.REV_YM ? rtnMap.REV_YM : '';
			actions.updateBInfo(rtnMap);
			actions.updateBRadioButton(rtnList);
		}else{
			actions.clearBInfo();
		}
	};
	
	function buttonAuth(){
		var authButtons = {
			B0004:"btn_update", <%--修正 --%>
			B0073:"btn_confirm", <%--呈核 --%>
			B0085:"btn_cancel", <%--取消呈核 --%>
			B0017:"btn_captainConfirm", <%--組長同意 --%>
			B0018:"btn_captainReject", <%--組長退回 --%>
			B0019:"btn_managerConfirm", <%--科主管同意 --%>
			B0020:"btn_managerReject", <%--科主管退回 --%>
			B0071:"btn_cancelConfirm" <%--取消覆核 --%>
		};
		<dz:grantButtons FUNC_ID="DSA60300"/>
	};
	
	var buttons = {
		<%-- 查詢 --%>
		doQuery : function(){
			valid.reset();
			valid1.reset();
			if(!valid.validate()){
				return;
			}		
			queryCondition = actions.getReqMap();
			ajaxRequest.post( 
				'query' , 
				{ reqMap : Object.toJSON(queryCondition)
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap);
					actions.updateBRadioButton(rtnList);
				}
				, function(resp){
					actions.clearBInfo();
				}
			);
	    },
		<%-- 借款影像連結 --%>
		doLoanLink : function(){
			popupWin.windowOpen('${dispatcher}/DSA0_0200/prompt',{
				'parameters': {'APPLY_ID': $('APPLY_ID_S').innerHTML, 'draftyn':'N'},
				'fullScreen': false,
				'attributes': {'resizable': 'yes'},
				'windowName': 'DSA00200' <%--視窗名稱，只會覆掉相同名稱的視窗--%>
			});
	    },
		<%-- 金庫影像連結 --%>
		doTreasuryLink : function(){
			popupWin.windowOpen('${dispatcher}/DSF0_0210/prompt',{
				'parameters': {'LOAN_ID': $('LOAN_ID_S').innerHTML, 'draftyn':'N'},
				'fullScreen': false,
				'attributes': {'resizable': 'yes'},
				'windowName': 'DSF00210' <%--視窗名稱，只會覆掉相同名稱的視窗--%>
			});
		},
		<%-- 修改 --%>
		doUpdate : function(){
			valid.reset();
			valid1.reset();
			if(!valid1.validate()){
				return;
			}
			ajaxRequest.post( 
				'update' , 
				{ reqMap : Object.toJSON(actions.getReqBMap())
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap);
					actions.updateBRadioButton(rtnList);
				}
			);
	    },
		<%-- 呈核 --%>
		doConfirm : function(){
			valid.reset();
			valid1.reset();
			if(!valid1.validate()){
				return;
			}
			ajaxRequest.post( 
				'confirm' , 
				{ reqMap : Object.toJSON(actions.getReqBMap())
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap);
					actions.updateBRadioButton(rtnList);
				}
			);
	    },
		<%-- 取消 --%>
		doCancel : function(){
			valid.reset();
			valid1.reset();
			if(!valid1.validate()){
				return;
			}
			ajaxRequest.post( 
				'cancel' , 
				{ reqMap : Object.toJSON(actions.getReqBMap())
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap);
					actions.updateBRadioButton(rtnList);
				}
			);
	    },		
		<%-- 組長同意 --%>
		doCaptainConfirm : function(){
			valid.reset();
			valid1.reset();
			if(!valid1.validate()){
				return;
			}
			ajaxRequest.post( 
				'captainConfirm' , 
				{ reqMap : Object.toJSON(actions.getReqBMap())
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap);
					actions.updateBRadioButton(rtnList);
				}
			);
	    },
		<%-- 組長退回 --%>
		doCaptainReject : function(){
			valid.reset();
			valid1.reset();
			if(!valid1.validate()){
				return;
			}
			ajaxRequest.post( 
				'captainReject' , 
				{ reqMap : Object.toJSON(actions.getReqBMap())
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap);
					actions.updateBRadioButton(rtnList);
				}
			);
	    },
		<%-- 科主管同意 --%>
		doManagerConfirm : function(){
			valid.reset();
			valid1.reset();
			if(!valid1.validate()){
				return;
			}
			ajaxRequest.post( 
				'managerConfirm' , 
				{ reqMap : Object.toJSON(actions.getReqBMap())
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap);
					actions.updateBRadioButton(rtnList);
				}
			);
	    },
		<%-- 科主管退回 --%>
		doManagerReject : function(){
			valid.reset();
			valid1.reset();
			if(!valid1.validate()){
				return;
			}
			ajaxRequest.post( 
				'managerReject' , 
				{ reqMap : Object.toJSON(actions.getReqBMap())
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap);
					actions.updateBRadioButton(rtnList);
				}
			);
	    },
		<%-- 取消覆核 --%>
	    doCancelConfirm : function(){
			valid.reset();
			valid1.reset();
			if(!valid1.validate()){
				return;
			}
			ajaxRequest.post( 
				'cancelConfirm' , 
				{ reqMap : Object.toJSON(actions.getReqBMap())
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap);
					actions.updateBRadioButton(rtnList);
				}
			);
	    }	
    };

	return{
	
		initApp : function(){
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' dateymFields="REV_YM"/>
			PageUI.createPageWithAllBodySubElement(
				'DSA60300',
				'覆審作業',
				'一般覆審作業'
			);
			
			//按鈕事件監聽
			$('btn_query').observe('click', buttons.doQuery);<%-- 查詢 --%>
			$('btn_loan_link').observe('click', buttons.doLoanLink);<%-- 借款影像連結 --%>
			$('btn_treasury_link').observe('click', buttons.doTreasuryLink);<%-- 金庫影像連結 --%>
			$('btn_update').observe('click', buttons.doUpdate);<%-- 修改 --%>
			$('btn_confirm').observe('click', buttons.doConfirm);<%-- 呈核 --%>
			$('btn_cancel').observe('click', buttons.doCancel);<%-- 取消 --%>
			$('btn_captainConfirm').observe('click', buttons.doCaptainConfirm);<%-- 組長同意 --%>
			$('btn_captainReject').observe('click', buttons.doCaptainReject);<%-- 組長退回 --%>
			$('btn_managerConfirm').observe('click', buttons.doManagerConfirm);<%-- 科主管同意 --%>
			$('btn_managerReject').observe('click', buttons.doManagerReject);<%-- 科主管退回 --%>
			$('btn_cancelConfirm').observe('click', buttons.doCancelConfirm);<%-- 取消覆核 --%>
			
			InputUtility.lengthLimit.add('REV_DESC', 500, true);
			InputUtility.lengthLimit.add('CAPT_DESC', 200, true);
			InputUtility.lengthLimit.add('BOSS_DESC', 200, true);
			buttonAuth();
			initValidation();
			backEndValue();
			parseEUDC();
			displayMessage();			
		}	
		
	};
}
</script>
</head>
<body>
<form name='form1' id='form1'>
<table id="table_A" width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">貸款帳號</td>
		<td class="tbYellow2" width="15%">
			<input id="LOAN_ID" name="LOAN_ID" type='text' class='textBox2' onblur="this.value = this.value.toUpperCase()" size='12' maxlength='10'/>
		</td>	
		<td class="tbYellow" width="10%">覆審年月<font color="red">※例：11010</font></td>
		<td class="tbYellow2" width="15%">
			<input id="REV_YM" name="REV_YM" type='text' class='textBox2' size='7' maxlength='5'/>
		</td>		
		<td class="tbYellow2" align="left" width="50%">
			<button id="btn_query" type="button" class="button">查詢</button>
			<button id="btn_loan_link" type="button" class="button">借款影像連結</button>
			<button id="btn_treasury_link" type="button" class="button">金庫影像連結</button>
		</td>		
	</tr>
	<tr>
		<td align="center" colSpan="5">
			<button id="btn_update" type="button" class="button">修改</button>
			<button id="btn_confirm" type="button" class="button">呈核</button>
			<button id="btn_cancel" type="button" class="button">取消</button>
			<button id="btn_captainConfirm" type="button" class="button">組長同意</button>
			<button id="btn_captainReject" type="button" class="button">組長退回</button>
			<button id="btn_managerConfirm" type="button" class="button">科主管同意</button>
			<button id="btn_managerReject" type="button" class="button">科主管退回</button>
			<button id="btn_cancelConfirm" type="button" class="button">取消覆核</button>
		</td>	
	</tr>
</table>
<table id="table_B" width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">貸款帳號</td>
		<td class="tbYellow2" width="15%">
			<span id="LOAN_ID_S" name="LOAN_ID_S"/>
		</td>
		<td class="tbYellow" width="10%">受理編號</td>
		<td class="tbYellow2" width="15%">
			<span id="APPLY_ID_S" name="APPLY_ID_S"/>
		</td>	
		<td class="tbYellow" width="10%">覆審年月</td>
		<td class="tbYellow2" width="15%">
			<span id="REV_YM_S" name="REV_YM_S"/>
		</td>
		<td class="tbYellow" width="10%">覆審進度</td>
		<td class="tbYellow2" width="15%">
			<span id="REV_PROCESS_NM" name="REV_PROCESS_NM"/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">借款人</td>
		<td class="tbYellow2">
			<%--[20240930]難字調整--%>
			<span id="BORROW_NAME" name="BORROW_NAME" style="font-family:'EUDC'"/>
		</td>
		<td class="tbYellow">統一編號</td>
		<td class="tbYellow2">
			<span id="BORROW_ID" name="BORROW_ID"/>
		</td>
		<td class="tbYellow">核貸層級</td>
		<td class="tbYellow2">
			<span id="AGREE_LEVEL_NM" name="AGREE_LEVEL_NM"/>
		</td>
		<td class="tbYellow">原徵信人員</td>
		<td class="tbYellow2">
			<%--[20240930]難字調整--%>
			<span id="CRED_NM" name="CRED_NM" style="font-family:'EUDC'"/>
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">擔保品地址</td>
		<td class="tbYellow2" colSpan="7">
			<%--[20240930]難字調整--%>
			<span id="GAGE_ADDR" name="GAGE_ADDR" style="font-family:'EUDC'"/>
		</td>	
	</tr>
	<tr>
		<td class="tbYellow">借款金額</td>
		<td class="tbYellow2">
			<span id="LOAN_AMT" name="LOAN_AMT" datatype="number" pattern="###,###,###" />
		</td>
		<td class="tbYellow">本金餘額</td>
		<td class="tbYellow2">
			<span id="SUM_REMAIN_AMT" name="SUM_REMAIN_AMT" datatype="number" pattern="###,###,###"/>
		</td>		
		<td class="tbYellow">利率</td>
		<td class="tbYellow2">
			<span id="RATE" name="RATE" datatype="number" pattern="###.####"/>
		</td>
		<td class="tbYellow">貸放日期</td>
		<td class="tbYellow2">
			<span id="LOAN_DATE" name="LOAN_DATE"/>
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">貸款類別</td>
		<td class="tbYellow2">
			<span id="LOAN_TYPE_NM" name="LOAN_TYPE_NM"/>
		</td>
		<td class="tbYellow">還款方式</td>
		<td class="tbYellow2">
			<span id="RETURN_TYPE_NM" name="RETURN_TYPE_NM"/>
		</td>	
		<td class="tbYellow">定期期數</td>
		<td class="tbYellow2">
			<span id="FIX_PERIOD" name="FIX_PERIOD"/>
		</td>
		<td class="tbYellow">分期期數</td>
		<td class="tbYellow2">
			<span id="SPR_PERIOD" name="SPR_PERIOD"/>
		</td>			
	</tr>
	<tr>
		<td class="tbYellow">貸款種類</td>
		<td class="tbYellow2">
			<span id="LOAN_KIND_NM" name="LOAN_KIND_NM"/>
		</td>	
		<td class="tbYellow">優惠種類</td>
		<td class="tbYellow2">
			<span id="PREFER_TYPE_NM" name="PREFER_TYPE_NM"/>
		</td>	
		<td class="tbYellow">借款主用途</td>
		<td class="tbYellow2">
			<span id="LOAN_POS_NM" name="LOAN_POS_NM"/>
		</td>
		<td class="tbYellow">借款次用途</td>
		<td class="tbYellow2">
			<span id="LOAN_POS2_NM" name="LOAN_POS2_NM"/>
		</td>		
	</tr>
	<%-- [20221228] 新增 本金彈性還期間 欄位 --%>
	<tr>
		<td class="tbYellow">本金彈性還期間</td>
		<td class="tbYellow2" colspan="7">
			<span id="FLEX_PERIOD_NM" name="FLEX_PERIOD_NM" />
		</td>
	</tr>
</table>	
<table id="table_C" width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow0" align="center" colSpan="2">
			<strong>一般覆審要項</strong>
		</td>
	</tr>	
	<tr>
		<td class="tbYellow" colSpan="2"><font color='blue'>一、一般事項</font></td>
	</tr>
	<tr>
		<td class="tbYellow" width="75%">
			1.核定層級是否符合標準，未逾越授權範圍(貸放額度及利率等)?</td>
		<td class="tbYellow2" width="25%">
			<span id="REV_NUM_A"/>
			<input name="REV_NUM_A" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_A" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_A" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			2.借款金額達新台幣二仟萬元者，是否已提供最近年度綜合所得稅結算申報書影本或申報繳款書影本或扣繳憑單影本?
			<font color='blue'>(借款金額未達二仟萬元者及法人件勾選不適用)</font></td>
		<td class="tbYellow2">
			<span id="REV_NUM_B"/>
			<input name="REV_NUM_B" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_B" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_B" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			3.是否按核貸條件撥貸，貸放資料建檔正確(利率、貸款金額等)?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_C"/>
			<input name="REV_NUM_C" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_C" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_C" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			4.借保人之債信紀錄，均已確實於批覆書上揭露?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_D"/>
			<input name="REV_NUM_D" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_D" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_D" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			5.借款人及保證人是否均已辦妥對保手續?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_E"/>
			<input name="REV_NUM_E" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_E" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_E" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			6.是否遵循放款定價政策及相關作業規範?
			<font color='blue'>(103年04月14日前核准之案件請勾選不適用)</font></td>
		<td class="tbYellow2">
			<span id="REV_NUM_F"/>
			<input name="REV_NUM_F" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_F" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_F" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow" colSpan="2"><font color='blue'>二、擔保品</font></td>
	</tr>
	<tr>
		<td class="tbYellow">
			1.擔保品已辦妥設定手續，並無瑕疵?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_G"/>
			<input name="REV_NUM_G" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_G" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_G" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			2.擔保品已辦妥以本公司為優先受益人之保險?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_H"/>
			<input name="REV_NUM_H" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_H" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_H" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			3.承作第二順位抵押貸款，貸款最高金額應扣除首順位抵押權設定金額後之餘額?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_I"/>
			<input name="REV_NUM_I" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_I" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_I" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow" colSpan="2"><font color='blue'>三、資金流向</font></td>
	</tr>
	<tr>
		<td class="tbYellow">
			1.資金流向情形與貸款用途相符?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_J"/>
			<input name="REV_NUM_J" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_J" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_J" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			2.代償前順位貸款，所撥款項應匯至前順位銀行，並取得清償證明且已塗銷前順位抵押權?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_K"/>
			<input name="REV_NUM_K" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_K" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_K" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
</table>
<table id="table_D1" width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow0" align="center" colSpan="4">
			<strong>裁決與批示</strong>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%">覆審結果</td>
		<td class="tbYellow2" width="90%" colSpan="3">
			<span id="REV_RESULT"/>
			<input name="REV_RESULT" type='radio' class='textBox2' value="0"/>正常
			<input name="REV_RESULT" type='radio' class='textBox2' value="1"/>異常
		</td>		
	</tr>
	<tr>
		<td class="tbYellow" width="10%">覆審人員</td>
		<td class="tbYellow2" width="15%">
			<input name="REV_ID" id="REV_ID" type='hidden' class='textBox2'/>
			<span id="REV_NM" name="REV_NM" style="font-family:'EUDC'"/>
		</td>
		<td class="tbYellow" width="10%">日期</td>
		<td class="tbYellow2" width="65%">
			<span id="REV_DATE" name="REV_DATE"/>
		</td>		
	</tr>
</table>
<table id="table_D2" width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">說明</td>
		<td class="tbYellow2" width="90%">
			<textarea rows=5 cols=110 id="REV_DESC" name="REV_DESC" class="textBox2 checkInputLength" maxLength="500" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
		</td>	
	</tr>
</table>
<%--[20241001]難字調整--%>
<table id="table_E1" width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">覆核人員</td>
		<td class="tbYellow2" width="15%">
			<input name="CAPT_ID" id="CAPT_ID" type='hidden' class='textBox2'/>
			<span id="CAPT_NM" name="CAPT_NM" style="font-family:'EUDC'"/>
		</td>
		<td class="tbYellow" width="10%">日期</td>
		<td class="tbYellow2" width="65%">
			<span id="CAPT_DATE" name="CAPT_DATE"/>
		</td>		
	</tr>
</table>
<table id="table_E2" width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">組長批示</td>
		<td class="tbYellow2" width="90%">
			<textarea rows=3 cols=110 id="CAPT_DESC" name="CAPT_DESC" class="textBox2 checkInputLength" maxLength="200" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
		</td>	
	</tr>
</table>
<table id="table_F1" width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">科主管</td>
		<td class="tbYellow2" width="15%">
			<input name="BOSS_ID" id="BOSS_ID" type='hidden' class='textBox2'/>
			<span id="BOSS_NM" name="BOSS_NM" style="font-family:'EUDC'"/>
		</td>
		<td class="tbYellow" width="10%">日期</td>
		<td class="tbYellow2" width="65%">
			<span id="BOSS_DATE" name="BOSS_DATE"/>
		</td>		
	</tr>
</table>
<table id="table_F2" width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">主管批示</td>
		<td class="tbYellow2" width="90%">
			<textarea rows=3 cols=110 id="BOSS_DESC" name="BOSS_DESC" class="textBox2 checkInputLength" maxLength="200" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
		</td>	
	</tr>
</table>
</form>
</body>
</html>