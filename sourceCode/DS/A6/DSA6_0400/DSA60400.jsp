<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA60400.jsp
功能：重要覆審作業
作者：蔡政均
完成：2020/02/10

[20221228] 修改程式  楊青峰
 新增本金彈性還還款方式
[20241001] 修改件 CHROME瀏覽器難字調整 
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
<%--[20241001]難字css  --%>
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
<script type='text/JavaScript' src='${htmlBase}/CM/js/date.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/popupWin.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/InputUtility.js'></script>

<script type="text/JavaScript">
Event.observe(window, 'load', new DSA60400().initApp);

function DSA60400(){
	
	var valid;
	var valid2;
	var valid3;
    var grid;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA6_0400/');
	//前次查詢條件
	var queryCondition;
	var G_rtnMap = {};
	 
	//畫面檢核
	function initValidation(){
			
		valid = new Validation('form1');
		valid.define( "required" , { id: "REV_YM", errMsg : "覆審年月不可為空"} );
		valid.define( "required" , { id: "REFER_ID", errMsg : "原貸帳號不可為空"} );
		valid.define( "validID", { id: "REFER_ID" , errMsg: "原貸帳號格式有誤" } );
		
		valid2 = new Validation('form1', { mode :"validate"} );
		$w('REV_NUM_A REV_NUM_B REV_NUM_C REV_NUM_D REV_NUM_E REV_NUM_F REV_NUM_G REV_NUM_H REV_NUM_I REV_NUM_J REV_NUM_K').each(function(id){
			var id_value = id + "1";
			valid2.define( "validateRadioCheck" , { id: id_value, errMsg : "請輸入重要覆審要項"} );
		});
		valid2.define( "validateRadioCheck" , { id: "REV_RESULT", errMsg : "請輸入覆審結果"} );
		//valid2.define( "required" , { id: "REV_DESC", errMsg : "說明不可為空"} );
		valid2.define( "required" , { id: "AVG_RATE", errMsg : "請輸入利率"} );
		valid2.define( "required" , { id: "LAND_TAX", errMsg : "土地增值稅不可為空"} );
		valid2.define( "validate1REV_DESC" , { id: "REV_DESC" } );
		valid2.define( "validate2REV_DESC" , { id: "REV_DESC" } );
		valid2.define( "validate3REV_DESC" , { id: "REV_DESC" } );
		valid2.define( "validateAVG_RATE" , { id: "AVG_RATE" } );
		
		valid3 = new Validation('form1', { mode :"validate"} );
		$w('REV_NUM_A REV_NUM_B REV_NUM_C REV_NUM_D REV_NUM_E REV_NUM_F REV_NUM_G REV_NUM_H REV_NUM_I REV_NUM_J REV_NUM_K REV_NUM_L REV_NUM_M REV_NUM_N REV_NUM_O REV_NUM_P REV_NUM_Q REV_NUM_R REV_NUM_S REV_NUM_T REV_NUM_U REV_NUM_V REV_NUM_W REV_NUM_X REV_NUM_Y REV_NUM_Z REV_NUM_AA REV_NUM_AB').each(function(id){
			var id_value = id + "0";
			valid3.define( "validateRadioCheck" , { id: id_value, errMsg : "請輸入重要覆審要項"} );
		});
		valid3.define( "validateRadioCheck" , { id: "REV_RESULT", errMsg : "請輸入覆審結果"} );
		//valid3.define( "required" , { id: "REV_DESC", errMsg : "說明不可為空"} );
		valid3.define( "required" , { id: "AVG_RATE", errMsg : "請輸入利率"} );
		valid3.define( "required" , { id: "LAND_TAX", errMsg : "土地增值稅不可為空"} );
		valid3.define( "validate1REV_DESC" , { id: "REV_DESC" } );
		valid3.define( "validate2REV_DESC" , { id: "REV_DESC" } );
		valid3.define( "validate3REV_DESC" , { id: "REV_DESC" } );
		valid3.define( "validateAVG_RATE" , { id: "AVG_RATE" } );
		
		Validation.addAllThese( [
			[ 'validID', '原貸帳號格式有誤', 
				function(v , node) { 
					if(v){
						<%--原貸帳號10碼英數字--%>
						return v.length == 10 && (/^[a-zA-Z0-9]+$/.test(v)); 
					}
					return true;
				}
			],
			[ 'validateRadioCheck', '請輸入重要覆審要項', 
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
			],
			[ 'validateAVG_RATE', '數值輸入格式錯誤，整數僅接受3位整數，小數點僅接受到小數點後2位!!', 
				function(v , node) { 
					return checkNumeralFormat(v , 3 , 2);
				}
			]
		]);
	};
	
	var actions = {
		getReqMap : function(){
			var record = {};
			record['REFER_ID'] = $F('REFER_ID');
			record['REV_YM'] = $('REV_YM').value; <%-- 民國年月 --%>
			return record;
		},
		getReqBMap : function(){
			var B_Record = G_rtnMap;
			var rev_kind = B_Record["REV_KIND"];
			if(rev_kind == "1"){
				$w('REV_NUM_A REV_NUM_B REV_NUM_C REV_NUM_D REV_NUM_E REV_NUM_F REV_NUM_G REV_NUM_H REV_NUM_I REV_NUM_J REV_NUM_K').each(function(id){
					var radioName = id + rev_kind;
					$$('#form1 input[name="'+ radioName + '"]').each(function(elm){
						if(elm.checked){
							B_Record[id] = elm.value;
						}
					})
				});	
			} else if(rev_kind == "0"){
				$w('REV_NUM_A REV_NUM_B REV_NUM_C REV_NUM_D REV_NUM_E REV_NUM_F REV_NUM_G REV_NUM_H REV_NUM_I REV_NUM_J REV_NUM_K REV_NUM_L REV_NUM_M REV_NUM_N REV_NUM_O REV_NUM_P REV_NUM_Q REV_NUM_R REV_NUM_S REV_NUM_T REV_NUM_U REV_NUM_V REV_NUM_W REV_NUM_X REV_NUM_Y REV_NUM_Z REV_NUM_AA REV_NUM_AB').each(function(id){
					var radioName = id + rev_kind;
					$$('#form1 input[name="'+ radioName + '"]').each(function(elm){
						if(elm.checked){
							B_Record[id] = elm.value;
						}
					})
				});	
			}
			$$('#form1 input[name="REV_RESULT"]').each(function(elm){
				if(elm.checked){
					B_Record[elm.name] = elm.value;
				}
			})
			B_Record["OTHER_REMAIN_AMT"] = $F("OTHER_REMAIN_AMT");
			B_Record["DEPOSIT"] = $F("DEPOSIT");
			B_Record["AVG_RATE"] = $F("AVG_RATE");
			B_Record["REV_DESC"] = $('REV_DESC').value;
			B_Record["CAPT_DESC"] = $('CAPT_DESC').value;
			B_Record["BOSS_DESC"] = $('BOSS_DESC').value;
			return B_Record;
		},
		updateBInfo : function(map, list){
			G_rtnMap = map;
			$('LOSS_RPT_NO').value = map.LOSS_RPT_NO ? map.LOSS_RPT_NO : '';
			$('REV_KIND').value = map.REV_KIND ? map.REV_KIND : '';
			$("REFER_ID_S").update(map.REFER_ID ||'');
			$("APPLY_ID").update(map.APPLY_ID ||'');
			$("REV_YM_S").update(map.REV_YM ||'');
			$("REV_PROCESS_NM").update(map.REV_PROCESS_NM ||'');
			$("BORROW_NAME").update(map.BORROW_NAME ||'');
			$("BORROW_ID").update(map.BORROW_ID ||'');
			$("AGREE_LEVEL_NM").update(map.AGREE_LEVEL_NM ||'');
			$("CRED_NM").update(map.CRED_NM ||'');
			$("GAGE_ADDR").update(map.GAGE_ADDR ||'');
			
			$("GAGE_TYPE_NM").update(map.GAGE_TYPE_NM ||'');
			$("APPR_APPLY_ID").update(map.APPR_APPLY_ID ||'');
			$('AVG_RATE').value = map.AVG_RATE ? localeDisplay.formatNumber(map.AVG_RATE) : ''; //利率
			$("LOAN_DATE").update(localeDisplay.formatDate(map.LOAN_DATE));
			$("OUR_REMAIN_AMT").update(localeDisplay.formatNumber(map.OUR_REMAIN_AMT));
			$("OTHER_REMAIN_AMT").value = map.OTHER_REMAIN_AMT ? localeDisplay.formatNumber(map.OTHER_REMAIN_AMT) : '';
			if(map.REV_KIND == "0"){
				$("OTHER_REMAIN_AMT").disabled = false;
			} else if(map.REV_KIND == "1"){ //消金件預設不可編輯
				$("OTHER_REMAIN_AMT").disabled = true;
			}
			$("REMAIN_AMT").update(localeDisplay.formatNumber(map.REMAIN_AMT));
			$("LAND_TAX").update(localeDisplay.formatNumber(map.LAND_TAX)); //土地增值稅
			$("TOTAL_PRICE").update(localeDisplay.formatNumber(map.TOTAL_PRICE)); //重估市價
			$("IS_LOSS_NM").update(map.IS_LOSS_NM ||''); //是否減損
			$("REALVALUE_RATE").update(map.REALVALUE_RATE ? localeDisplay.formatNumber(map.REALVALUE_RATE)+'%' : ''); //市價比
			$("TOTAL_VALUE").update(localeDisplay.formatNumber(map.TOTAL_VALUE)); //鑑估總值
			$("DEPOSIT").value = map.DEPOSIT ? localeDisplay.formatNumber(map.DEPOSIT) : ''; //押金
			$("MR_REMAIN_AMT").update(localeDisplay.formatNumber(map.MR_REMAIN_AMT)); //分次動撥可動撥餘額
			$("MM_REMAIN_AMT").update(localeDisplay.formatNumber(map.MM_REMAIN_AMT)); //理財型可動撥餘額
			$("REV_GA_AMT").update(localeDisplay.formatNumber(map.REV_GA_AMT)); //曝險金額
			$("REV_GA_RATE").update(map.REV_GA_RATE ? localeDisplay.formatNumber(map.REV_GA_RATE)+'%' : ''); //覆審放款率
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

			var rev_kind = map.REV_KIND;
			if(rev_kind == "1"){
				$('table_D').show();
				$('table_E').hide();
			}else if(rev_kind == "0"){
				$('table_E').show();
				$('table_D').hide();
			}
			actions.updateBRadioButton(list, rev_kind);
		},
		clearBInfo : function(){
			valid2.reset();
			valid3.reset();
			G_rtnMap = {};			
			$w('REFER_ID_S APPLY_ID REV_YM_S REV_PROCESS_NM BORROW_NAME BORROW_ID AGREE_LEVEL_NM CRED_NM GAGE_ADDR').each(function(id){
				$(id).update("");
			});
			$w('GAGE_TYPE_NM APPR_APPLY_ID LOAN_DATE OUR_REMAIN_AMT REMAIN_AMT LAND_TAX').each(function(id){
				$(id).update("");
			});
			$w('TOTAL_PRICE IS_LOSS_NM REALVALUE_RATE TOTAL_VALUE MR_REMAIN_AMT MM_REMAIN_AMT REV_GA_AMT REV_GA_RATE').each(function(id){
				$(id).update("");
			});
			$w('LOAN_TYPE_NM RETURN_TYPE_NM FIX_PERIOD SPR_PERIOD LOAN_KIND_NM PREFER_TYPE_NM LOAN_POS_NM LOAN_POS2_NM').each(function(id){
				$(id).update("");
			});
			$w('REV_NM REV_DATE REV_DESC CAPT_NM CAPT_DATE CAPT_DESC BOSS_NM BOSS_DATE BOSS_DESC').each(function(id){
				$(id).update("");
			});
			$w('AVG_RATE DEPOSIT OTHER_REMAIN_AMT LOSS_RPT_NO REV_KIND REV_ID CAPT_ID BOSS_ID').each(function(id){
				$(id).value = '';
			});
			
			$$('#form1 input[type="radio"]').each(function(elm){
				elm.checked = false;
			})
			
			InputUtility.lengthLimit.doLengthLimit('REV_DESC');
			InputUtility.lengthLimit.doLengthLimit('CAPT_DESC');
			InputUtility.lengthLimit.doLengthLimit('BOSS_DESC');
		},
		defaultBRadioButton : function(form_name, rev_kind){
			<%-- 預設選取 '是' --%>
			if(rev_kind == "1"){
				$w('REV_NUM_A REV_NUM_B REV_NUM_C REV_NUM_D REV_NUM_E REV_NUM_F REV_NUM_G REV_NUM_H REV_NUM_I REV_NUM_J REV_NUM_K').each(function(id){
					var i = 0;
					var radioName = id + rev_kind;
					$$('#form1 input[name="'+ radioName + '"]').each(function(elm){
						if(i == 0){
							elm.checked = true;
						}
						i++; 
					})
				});	
			} else if(rev_kind == "0"){
				$w('REV_NUM_A REV_NUM_B REV_NUM_C REV_NUM_D REV_NUM_E REV_NUM_F REV_NUM_G REV_NUM_H REV_NUM_I REV_NUM_J REV_NUM_K REV_NUM_L REV_NUM_M REV_NUM_N REV_NUM_O REV_NUM_P REV_NUM_Q REV_NUM_R REV_NUM_S REV_NUM_T REV_NUM_U REV_NUM_V REV_NUM_W REV_NUM_X REV_NUM_Y REV_NUM_Z REV_NUM_AA REV_NUM_AB').each(function(id){
					var i = 0;
					var radioName = id + rev_kind;
					$$('#form1 input[name="'+ radioName + '"]').each(function(elm){
						if(i == 0){
							elm.checked = true;
						}
						i++; 
					})
				});	
			}		
			
		},
		updateBRadioButton : function(list, rev_kind){
			var form_name = $('form1');
			if(list.size() == 0){
				actions.defaultBRadioButton(form_name, rev_kind);
				return;
			}
			<%-- 消金件REV_KIND 為 1, 11項 table_D --%>
			<%-- 法金件REV_KIND 為 0, 26項 table_E --%><%-- 配合放款覆審作業管理辦法修訂為28項 --%>
			list.forEach(function(item){
				var num = item["REV_NUM"];
				var finish_kind = item["FINISH_KIND"];
				var index = -1;
				if(finish_kind == 0) {
					index = 2;
				} else if(finish_kind == 1){
					index = 0;
				} else if(finish_kind == 2){
					index = 1;
				}
				if(index != -1) {
					if(rev_kind == "1"){
						switch (num) {
							 case '11A':
								form_name.REV_NUM_A1[index].checked = true;
								break;
							 case '11B':
								form_name.REV_NUM_B1[index].checked = true;
								break;
							 case '11C':
								form_name.REV_NUM_C1[index].checked = true;
								break;
							 case '11D':
								form_name.REV_NUM_D1[index].checked = true;
								break;
							 case '11E':
								form_name.REV_NUM_E1[index].checked = true;
								break;
							 case '11F':
								form_name.REV_NUM_F1[index].checked = true;
								break;
							 case '11G':
								form_name.REV_NUM_G1[index].checked = true;
								break;
							 case '11H':
								form_name.REV_NUM_H1[index].checked = true;
								break;
							 case '11I':
								form_name.REV_NUM_I1[index].checked = true;
								break;
							 case '11J':
								form_name.REV_NUM_J1[index].checked = true;
								break;
							 case '11K':
								form_name.REV_NUM_K1[index].checked = true;
								break;						
							 default:					 
						}
					} else if(rev_kind == "0"){
						switch (num) {
							 case '10A':
								form_name.REV_NUM_A0[index].checked = true;
								break;
							 case '10B':
								form_name.REV_NUM_B0[index].checked = true;
								break;
							 case '10C':
								form_name.REV_NUM_C0[index].checked = true;
								break;
							 case '10D':
								form_name.REV_NUM_D0[index].checked = true;
								break;
							 case '10E':
								form_name.REV_NUM_E0[index].checked = true;
								break;
							 case '10F':
								form_name.REV_NUM_F0[index].checked = true;
								break;
							 case '10G':
								form_name.REV_NUM_G0[index].checked = true;
								break;
							 case '10H':
								form_name.REV_NUM_H0[index].checked = true;
								break;
							 case '10I':
								form_name.REV_NUM_I0[index].checked = true;
								break;
							 case '10J':
								form_name.REV_NUM_J0[index].checked = true;
								break;
							 case '10K':
								form_name.REV_NUM_K0[index].checked = true;
								break;
							 case '10L':
								form_name.REV_NUM_L0[index].checked = true;
								break;
							 case '10M':
								form_name.REV_NUM_M0[index].checked = true;
								break;
							 case '10N':
								form_name.REV_NUM_N0[index].checked = true;
								break;
							 case '10O':
								form_name.REV_NUM_O0[index].checked = true;
								break;
							 case '10P':
								form_name.REV_NUM_P0[index].checked = true;
								break;
							 case '10Q':
								form_name.REV_NUM_Q0[index].checked = true;
								break;
							 case '10R':
								form_name.REV_NUM_R0[index].checked = true;
								break;
							 case '10S':
								form_name.REV_NUM_S0[index].checked = true;
								break;
							 case '10T':
								form_name.REV_NUM_T0[index].checked = true;
								break;
							 case '10U':
								form_name.REV_NUM_U0[index].checked = true;
								break;
							 case '10V':
								form_name.REV_NUM_V0[index].checked = true;
								break;
							 case '10W':
								form_name.REV_NUM_W0[index].checked = true;
								break;
							 case '10X':
								form_name.REV_NUM_X0[index].checked = true;
								break;
							 case '10Y':
								form_name.REV_NUM_Y0[index].checked = true;
								break;
							 case '10Z':
								form_name.REV_NUM_Z0[index].checked = true;
								break;	
							<%-- 配合放款覆審作業管理辦法1100928修訂，新增重要覆審要項 --%>
							 case '10AA':
								form_name.REV_NUM_AA0[index].checked = true;
								break;	
							<%-- 配合放款覆審作業管理辦法1101230修訂，新增重要覆審要項 --%>
							 case '10AB':
								form_name.REV_NUM_AB0[index].checked = true;
								break;	
							 default:					 
						}
					}
				}
			})	
		}
	};
	
	function backEndValue(){
		var rtnMap = <c:out value="${rtnMap}" default="null" escapeXml="false"/>;
		var rtnList = <c:out value="${rtnList}" default="[]" escapeXml="false"/>;
		if(rtnMap != null){
			$('REFER_ID').value = rtnMap.REFER_ID ? rtnMap.REFER_ID : '';
			$('REV_YM').value = rtnMap.REV_YM ? rtnMap.REV_YM : '';
			actions.updateBInfo(rtnMap, rtnList);
		}else{
			actions.clearBInfo();
		}
	};
	
	function validateInfoB(){
		var kind = $F("REV_KIND");
		var flag = false;
		if(kind == "1"){
			if(!valid2.validate()){
				flag = true;
			}
		} else if(kind == "0"){
			if(!valid3.validate()){
				flag = true;
			}
		} else {
			if(!valid2.validate()){
				flag = true;
			}
			if(!valid3.validate()){
				flag = true;
			}
		}
		return flag;
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
		<dz:grantButtons FUNC_ID="DSA60400"/>
	};
	
	var buttons = {
		<%-- 查詢 --%>
		doQuery : function(){
			valid.reset();
			valid2.reset();
			valid3.reset();
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
					actions.updateBInfo(rtnMap, rtnList);
				}
				, function(resp){
					actions.clearBInfo();
				}
			);
	    },
		<%-- 借款影像連結 --%>
		doLoanLink : function(){
			popupWin.windowOpen('${dispatcher}/DSA0_0200/prompt',{
				'parameters': {'APPLY_ID': $('APPLY_ID').innerHTML, 'draftyn':'N'},
				'fullScreen': false,
				'attributes': {'resizable': 'yes'},
				'windowName': 'DSA00200' <%--視窗名稱，只會覆掉相同名稱的視窗--%>
			});
	    },
		<%-- 金庫影像連結 --%>
		doTreasuryLink : function(){
			popupWin.windowOpen('${dispatcher}/DSF0_0210/prompt',{
				'parameters': {'REFER_ID': $('REFER_ID_S').innerHTML, 'draftyn':'N'},
				'fullScreen': false,
				'attributes': {'resizable': 'yes'},
				'windowName': 'DSF00210' <%--視窗名稱，只會覆掉相同名稱的視窗--%>
			});
		},
		<%-- 修改 --%>
		doUpdate : function(){
			valid.reset();
			valid2.reset();
			valid3.reset();
			if(validateInfoB()){
				return;
			}
			ajaxRequest.post( 
				'update' , 
				{ reqMap : Object.toJSON(actions.getReqBMap())
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap, rtnList);
				}
			);
	    },
		<%-- 呈核 --%>
		doConfirm : function(){
			valid.reset();
			valid2.reset();
			valid3.reset();
			if(validateInfoB()){
				return;
			}
			ajaxRequest.post( 
				'confirm' , 
				{ reqMap : Object.toJSON(actions.getReqBMap())
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap, rtnList);
				}
			);
	    },
		<%-- 取消 --%>
		doCancel : function(){
			valid.reset();
			valid2.reset();
			valid3.reset();
			if(validateInfoB()){
				return;
			}
			ajaxRequest.post( 
				'cancel' , 
				{ reqMap : Object.toJSON(actions.getReqBMap())
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap, rtnList);
				}
			);
	    },		
		<%-- 組長同意 --%>
		doCaptainConfirm : function(){
			valid.reset();
			valid2.reset();
			valid3.reset();
			if(validateInfoB()){
				return;
			}
			ajaxRequest.post( 
				'captainConfirm' , 
				{ reqMap : Object.toJSON(actions.getReqBMap())
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap, rtnList);
				}
			);
	    },
		<%-- 組長退回 --%>
		doCaptainReject : function(){
			valid.reset();
			valid2.reset();
			valid3.reset();
			if(validateInfoB()){
				return;
			}
			ajaxRequest.post( 
				'captainReject' , 
				{ reqMap : Object.toJSON(actions.getReqBMap())
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap, rtnList);
				}
			);
	    },
		<%-- 科主管同意 --%>
		doManagerConfirm : function(){
			valid.reset();
			valid2.reset();
			valid3.reset();
			if(validateInfoB()){
				return;
			}
			ajaxRequest.post( 
				'managerConfirm' , 
				{ reqMap : Object.toJSON(actions.getReqBMap())
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap, rtnList);
				}
			);
	    },
		<%-- 科主管退回 --%>
		doManagerReject : function(){
			valid.reset();
			valid2.reset();
			valid3.reset();
			if(validateInfoB()){
				return;
			}
			ajaxRequest.post( 
				'managerReject' , 
				{ reqMap : Object.toJSON(actions.getReqBMap())
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap, rtnList);
				}
			);
	    },
		<%-- 取消覆核 --%>
	    doCancelConfirm : function(){
			valid.reset();
			valid2.reset();
			valid3.reset();
			if(validateInfoB()){
				return;
			}
			ajaxRequest.post( 
				'cancelConfirm' , 
				{ reqMap : Object.toJSON(actions.getReqBMap())
				},
				function(resp){
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = resp.rtnList ? resp.rtnList : [];
					actions.updateBInfo(rtnMap, rtnList);
				}
			);
	    },
		<%-- 聯徵紀錄查詢 --%>
		doJcicRecord : function(){
			popupWin.windowOpen('${dispatcher}/DSA2_0410/prompt',{
				'parameters': {'APPLY_ID': $('APPLY_ID').innerHTML},
				'fullScreen': false,
				'attributes': {'resizable': 'yes'},
				'windowName': 'DSA60400' <%--視窗名稱，只會覆掉相同名稱的視窗--%>
			});
	    },
		<%--覆審鑑價連結 --%>
	    doApprLink : function(){
			popupWin.windowOpen('${dispatcher}/DSA3_3500/prompt',{
				'parameters': {
					'APPLY_ID': $('APPLY_ID').innerHTML,
					'REFER_ID': $('REFER_ID_S').innerHTML,
					'REV_YM': $('REV_YM_S').innerHTML,
					'REV_TYPE': '1',
				},
				'fullScreen': false,
				'attributes': {'resizable': 'yes'},
				'windowName': 'DSA60400' <%--視窗名稱，只會覆掉相同名稱的視窗--%>
			});
	    }		
    };

	return{
	
		initApp : function(){
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' numberFields="OTHER_REMAIN_AMT" dateymFields="REV_YM"/>
			PageUI.createPageWithAllBodySubElement(
				'DSA60400',
				'覆審作業',
				'重要覆審作業'
			);
			
			<%-- 按鈕事件監聽 --%>
			$('btn_query').observe('click', buttons.doQuery);<%--查詢--%>
			$('btn_loan_link').observe('click', buttons.doLoanLink);<%--借款影像連結--%>
			$('btn_treasury_link').observe('click', buttons.doTreasuryLink);<%--金庫影像連結--%>
			$('btn_jcic_record').observe('click', buttons.doJcicRecord);<%--聯徵紀錄查詢--%>
			$('btn_appr_link').observe('click', buttons.doApprLink);<%--覆審鑑價連結--%>
			$('btn_update').observe('click', buttons.doUpdate);<%--修改--%>
			$('btn_confirm').observe('click', buttons.doConfirm);<%--呈核--%>
			$('btn_cancel').observe('click', buttons.doCancel);<%--取消--%>
			$('btn_captainConfirm').observe('click', buttons.doCaptainConfirm);<%--組長同意--%>
			$('btn_captainReject').observe('click', buttons.doCaptainReject);<%--組長退回--%>
			$('btn_managerConfirm').observe('click', buttons.doManagerConfirm);<%--科主管同意--%>
			$('btn_managerReject').observe('click', buttons.doManagerReject);<%--科主管退回--%>
			$('btn_cancelConfirm').observe('click', buttons.doCancelConfirm);<%--取消覆核--%>
			
			$('table_D').hide();
			$('table_E').hide();
				
			InputUtility.lengthLimit.add('REV_DESC', 500, true);
			InputUtility.lengthLimit.add('CAPT_DESC', 200, true);
			InputUtility.lengthLimit.add('BOSS_DESC', 200, true);
			buttonAuth();
			initValidation();
			backEndValue();
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
		<td class="tbYellow" width="10%">原貸帳號</td>
		<td class="tbYellow2" width="15%">
			<input id="REFER_ID" name="REFER_ID" type='text' class='textBox2' onblur="this.value = this.value.toUpperCase()" size='12' maxlength='10'/>
		</td>
		<td class="tbYellow" width="10%">覆審年月<font color="red">※例：11010</font></td>
		<td class="tbYellow2" width="15%">
			<input id="REV_YM" name="REV_YM" type='text' class='textBox2' size='7' maxlength='5'/>
		</td>		
		<td class="tbYellow2" align="left" width="50%">
			<button id="btn_query" type="button" class="button">查詢</button>
			<button id="btn_loan_link" type="button" class="button">借款影像連結</button>
			<button id="btn_treasury_link" type="button" class="button">金庫影像連結</button>
			<button id="btn_jcic_record" type="button" class="button">聯徵紀錄查詢</button>
			<button id="btn_appr_link" type="button" class="button">覆審鑑價連結</button>
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
		<td class="tbYellow" width="10%">原貸帳號</td>
		<td class="tbYellow2" width="15%">
			<input name="REV_KIND" id="REV_KIND" type='hidden' class='textBox2'/>
			<input name="LOSS_RPT_NO" id="LOSS_RPT_NO" type='hidden' class='textBox2'/>
			<span id="REFER_ID_S" name="REFER_ID_S"/>
		</td>
		<td class="tbYellow" width="10%">受理編號</td>
		<td class="tbYellow2" width="15%">
			<span id="APPLY_ID" name="APPLY_ID"/>
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
	<%--[20241001]難字調整--%>
	<tr>
		<td class="tbYellow">借款人</td>
		<td class="tbYellow2">
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
			<span id="CRED_NM" name="CRED_NM" style="font-family:'EUDC'"/>
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">擔保品地址</td>
		<td class="tbYellow2" colSpan="7">
			<span id="GAGE_ADDR" name="GAGE_ADDR" style="font-family:'EUDC'"/>
		</td>	
	</tr>
	<tr>
		<td class="tbYellow">擔保品種類</td>
		<td class="tbYellow2">
			<span id="GAGE_TYPE_NM" name="GAGE_TYPE_NM"/>
		</td>
		<td class="tbYellow">鑑價報告編號</td>
		<td class="tbYellow2">
			<span id="APPR_APPLY_ID" name="APPR_APPLY_ID"/>
		</td>	
		<td class="tbYellow"><font color='red'>利率</font></td>
		<td class="tbYellow2">
			<input id="AVG_RATE" name="AVG_RATE" datatype="number" intLength="2" decLength="4" pattern="###.####" title="利率" type='text' class='textBox2' size='10' maxlength='7'/>
		</td>
		<td class="tbYellow">貸放日期</td>
		<td class="tbYellow2">
			<span id="LOAN_DATE" name="LOAN_DATE"/>
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">餘額(本公司)</td>
		<td class="tbYellow2">
			<span id="OUR_REMAIN_AMT" name="OUR_REMAIN_AMT" datatype="number" pattern="###,###,###"/>
		</td>
		<td class="tbYellow">餘額(他公司)</td>
		<td class="tbYellow2">
			<input id="OTHER_REMAIN_AMT" name="OTHER_REMAIN_AMT" datatype="number" pattern="###,###,###" title="餘額(他公司)" type='text' class='textBox2' size='15' maxlength='13'/>
		</td>		
		<td class="tbYellow">本金餘額</td>
		<td class="tbYellow2">
			<span id="REMAIN_AMT" name="REMAIN_AMT" datatype="number" pattern="###,###,###"/>
		</td>
		<td class="tbYellow">土地增值稅</td>
		<td class="tbYellow2">
			<font color='blue'><span id="LAND_TAX" name="LAND_TAX" datatype="number" pattern="###,###,###"/></font>
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">重估市價</td>
		<td class="tbYellow2">
			<span id="TOTAL_PRICE" name="TOTAL_PRICE" datatype="number" pattern="###,###,###"></span>
			<font color='blue'><span id="IS_LOSS_NM" name="IS_LOSS_NM"></span></font>
		</td>
		<td class="tbYellow">市價比</td>
		<td class="tbYellow2">
			<span id="REALVALUE_RATE" name="REALVALUE_RATE" datatype="number" pattern="###.####"/>
		</td>		
		<td class="tbYellow">鑑估總值</td>
		<td class="tbYellow2">
			<span id="TOTAL_VALUE" name="TOTAL_VALUE" datatype="number" pattern="###,###,###"/>
		</td>
		<td class="tbYellow"><font color='red'>押金</font></td>
		<td class="tbYellow2">
			<input id="DEPOSIT" name="DEPOSIT" datatype="number" pattern="###,###,###" title="押金" type='text' class='textBox2' size='15' maxlength='13'/>
		</td>			
	</tr>
	<tr>
		<td class="tbYellow">分次動撥可動撥餘額</td>
		<td class="tbYellow2">
			<span id="MR_REMAIN_AMT" name="MR_REMAIN_AMT" datatype="number" pattern="###,###,###"/>
		</td>
		<td class="tbYellow">理財型可動撥餘額</td>
		<td class="tbYellow2">
			<span id="MM_REMAIN_AMT" name="MM_REMAIN_AMT" datatype="number" pattern="###,###,###"/>
		</td>		
		<td class="tbYellow">曝險金額</td>
		<td class="tbYellow2">
			<span id="REV_GA_AMT" name="REV_GA_AMT" datatype="number" pattern="###,###,###"/>
		</td>
		<td class="tbYellow">覆審放款率</td>
		<td class="tbYellow2">
			<span id="REV_GA_RATE" name="REV_GA_RATE" datatype="number" pattern="###.####"/>
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
<table id="table_D" width="100%" class="tbBox2">	
	<tr>
		<td class="tbYellow0" align="center" colSpan="2">
			<strong>重要覆審要項</strong>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="75%">
			1.是否非為本公司利害關係人之案件?</td>
		<td class="tbYellow2" width="25%">
			<span id="REV_NUM_A1"/>
			<input name="REV_NUM_A1" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_A1" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_A1" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			2.是否非為金控利害關係人之案件?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_B1"/>
			<input name="REV_NUM_B1" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_B1" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_B1" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			3.是否遵循放款定價政策及相關作業規範?
			<font color='blue'>(103年4月14日前核准之案件請勾選不適用)</font></td>
		<td class="tbYellow2">
			<span id="REV_NUM_C1"/>
			<input name="REV_NUM_C1" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_C1" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_C1" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			4.貸放資料建檔是否正確(利率、貸款金額)?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_D1"/>
			<input name="REV_NUM_D1" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_D1" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_D1" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			5.查詢JCIC，借保人債信是否正常?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_E1"/>
			<input name="REV_NUM_E1" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_E1" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_E1" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			6.資金流向情形與貸款用途相符?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_F1"/>
			<input name="REV_NUM_F1" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_F1" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_F1" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			7.擔保品產權、持份無異動(附謄本)?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_G1"/>
			<input name="REV_NUM_G1" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_G1" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_G1" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			8.近半年繳款狀況是否正常?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_H1"/>
			<input name="REV_NUM_H1" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_H1" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_H1" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			9.實地勘查擔保品無異常狀況?
			<font color='blue'>(不需進行實地覆審之案件請勾選不適用)</font></td>
		<td class="tbYellow2">
			<span id="REV_NUM_I1"/>
			<input name="REV_NUM_I1" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_I1" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_I1" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			10.覆審時無其他不良徵兆?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_J1"/>
			<input name="REV_NUM_J1" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_J1" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_J1" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			11.擔保品價值是否足以確保債權?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_K1"/>
			<input name="REV_NUM_K1" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_K1" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_K1" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
</table>
<table id="table_E" width="100%" class="tbBox2">	
	<tr>
		<td class="tbYellow0" align="center" colSpan="2">
			<strong>重要覆審要項</strong>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" colSpan="2"><font color='blue'>一、一般事項</font></td>
	</tr>
	<tr>
		<td class="tbYellow" width="75%">
			1.核定層級未逾越授權範圍?</td>
		<td class="tbYellow2" width="25%">
			<span id="REV_NUM_A0"/>
			<input name="REV_NUM_A0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_A0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_A0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			2.核定時約定及批示事項依約履行?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_B0"/>
			<input name="REV_NUM_B0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_B0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_B0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			3.授信戶、負責人、保證人於本公司之還本付息正常?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_C0"/>
			<input name="REV_NUM_C0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_C0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_C0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			4.授信戶、負責人、保證人信用正常(JCIC)?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_D0"/>
			<input name="REV_NUM_D0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_D0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_D0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			5.資金流向情形與貸款用途相符?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_E0"/>
			<input name="REV_NUM_E0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_E0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_E0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			6.中長期放款依原定攤還計劃按期攤還本息?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_F0"/>
			<input name="REV_NUM_F0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_F0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_F0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			7.是否遵循放款定價政策及相關作業規範?
			<font color='blue'>(103年4月14日前核准之案件請勾選不適用)</font></td>
		<td class="tbYellow2">
			<span id="REV_NUM_G0"/>
			<input name="REV_NUM_G0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_G0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_G0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			8.法人金融科負責之企金授信件是否落實責任投資原則?
			<font color='blue'>(105年1月1日前核准之案件請勾選不適用)</font></td>
		<td class="tbYellow2">
			<span id="REV_NUM_H0"/>
			<input name="REV_NUM_H0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_H0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_H0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			9.借款人或保證人是否有可能影響債權或債務履行之負面事件或新聞?</td><%-- 配合放款覆審作業管理辦法1100928修訂，新增重要覆審要項 --%>
		<td class="tbYellow2">
			<span id="REV_NUM_AA0"/>
			<input name="REV_NUM_AA0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_AA0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_AA0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			10.是否落實追蹤專案融資聯貸案之專案計畫執行進度?</td><%-- 配合放款覆審作業管理辦法1101230修訂，新增重要覆審要項 --%>
		<td class="tbYellow2">
			<span id="REV_NUM_AB0"/>
			<input name="REV_NUM_AB0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_AB0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_AB0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow" colSpan="2"><font color='blue'>二、營運及財務狀況</font></td>
	</tr>
	<tr>
		<td class="tbYellow">
			1.會計師出具無保留意見財簽，未更換簽證會計師?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_I0"/>
			<input name="REV_NUM_I0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_I0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_I0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			2.最近三年營收趨勢無連續下滑情形?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_J0"/>
			<input name="REV_NUM_J0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_J0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_J0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			3.最近三年本業獲利無連續下滑情形?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_K0"/>
			<input name="REV_NUM_K0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_K0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_K0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			4.最近三年毛利率無連續下滑情形?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_L0"/>
			<input name="REV_NUM_L0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_L0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_L0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			5.最近三年稅前淨利無連續下滑情形?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_M0"/>
			<input name="REV_NUM_M0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_M0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_M0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			6.存貨或應收帳款無鉅額增加情形?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_N0"/>
			<input name="REV_NUM_N0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_N0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_N0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			7.存貨或應收帳款週轉天期無拉長情形?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_O0"/>
			<input name="REV_NUM_O0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_O0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_O0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			8.總借款成長率小於營收成長率?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_P0"/>
			<input name="REV_NUM_P0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_P0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_P0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			9.(長期股權投資/總資產)小於40%?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_Q0"/>
			<input name="REV_NUM_Q0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_Q0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_Q0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow" colSpan="2"><font color='blue'>三、擔保品</font></td>
	</tr>
	<tr>
		<td class="tbYellow">
			1.完成首順位設定?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_R0"/>
			<input name="REV_NUM_R0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_R0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_R0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			2.未有第三人設定次順位?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_S0"/>
			<input name="REV_NUM_S0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_S0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_S0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			3.未過戶予第三人?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_T0"/>
			<input name="REV_NUM_T0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_T0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_T0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			4.未遭第三人申請限制登記、假扣押、假處分等?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_U0"/>
			<input name="REV_NUM_U0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_U0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_U0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			5.未遭第三人佔用?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_V0"/>
			<input name="REV_NUM_V0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_V0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_V0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			6.外觀未變化，附近無重大不利變化(如新建電塔、汙染等嫌惡設施)?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_W0"/>
			<input name="REV_NUM_W0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_W0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_W0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>	
	<tr>
		<td class="tbYellow">
			7.不動產擔保品每年至少調閱謄本並實地履勘一次，且拍照存查?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_X0"/>
			<input name="REV_NUM_X0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_X0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_X0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			8.動產擔保品每年至少實地履勘一次，並拍照存查?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_Y0"/>
			<input name="REV_NUM_Y0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_Y0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_Y0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>
	<tr>
		<td class="tbYellow">
			9.擔保品價值是否足以確保債權?</td>
		<td class="tbYellow2">
			<span id="REV_NUM_Z0"/>
			<input name="REV_NUM_Z0" type='radio' class='textBox2' value="1"/>是
			<input name="REV_NUM_Z0" type='radio' class='textBox2' value="2"/>否
			<input name="REV_NUM_Z0" type='radio' class='textBox2' value="0"/>不適用
		</td>		
	</tr>	
</table>
<table id="table_F1" width="100%" class="tbBox2">
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
	<%--[20241001]難字調整--%>
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
<table id="table_F2" width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">說明</td>
		<td class="tbYellow2" width="90%">
			<textarea rows=5 cols=110 id="REV_DESC" name="REV_DESC" class="textBox2 checkInputLength" maxLength="500" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
		</td>	
	</tr>
</table>
<table id="table_G1" width="100%" class="tbBox2">
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
<table id="table_G2" width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">組長批示</td>
		<td class="tbYellow2" width="90%">
			<textarea rows=3 cols=110 id="CAPT_DESC" name="CAPT_DESC" class="textBox2 checkInputLength" maxLength="200" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
		</td>	
	</tr>
</table>
<table id="table_H1" width="100%" class="tbBox2">
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
<table id="table_H2" width="100%" class="tbBox2">
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