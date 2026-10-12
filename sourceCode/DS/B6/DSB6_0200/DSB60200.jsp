<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB60200.jsp
作者：王文進
功能：帳號設定輸入。
完成：2012/06/11
-->

<fmt:setBundle basename='TextResource' />

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>

<script type='text/javascript'>

// 產生畫面物件
var DSB60200 = new DSB60200();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB60200.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB60200(){
	
	var chkMap = {};
	
	var grid3;
	var grid4;
	var grid5;
	var grid7;
	var grid8;
	var grid9;
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			B0016:"btn_insert"<%--輸入--%> 
		};
		
		<dz:grantButtons FUNC_ID="DSB60200" ignored="false"/>
	}
	
	//資料來源
	function initAPPLY_OPTION_LIST(node) {
       <c:forEach var="map" items="${APPLY_OPTION_LIST}">
			var elOptNew = document.createElement('option');
			elOptNew.text =  '${map.value}';
			elOptNew.value = '${map.key}';
			node.add(elOptNew);
       </c:forEach>
	}
	
	column1 = [
		{header: "受理編號",key: "NAPPLY_ID",
			render: function( record, value ){
				return value ? value : '';
			}							
		},
		{header: "借款人ID",key: "NBORROW_ID",
			render: function( record, value ){
				return value ? value : '';
			}							
		},
		{header: "借款人姓名",key: "NBORROW_NAME",
			render: function( record, value ){
				return value ? value : '';
			}							
		},
		{header: "借款金額",key: "AGREE_AMT",
			render: function( record, value ){
				return value ? CSRUtil.$fmt(value, CSRUtil.defaultPattern) : '';
			}							
		},
		{header: "作業種類",key: "APPLY_OPTION",
			input:{
				type:'select',
				actionWhenStart:true,
				action : function( node , dataObj , textDiv, record, isOnChange){
					if(!isOnChange){
						initAPPLY_OPTION_LIST(node);
						//設定預設值
						if(!dataObj[0]['APPLY_OPTION']) {
							node.value = "0";
						}else {
							node.value = dataObj[0]['APPLY_OPTION'];
						}
						node.id="APPLY_OPTION"+dataObj[0]["NAPPLY_ID"];
					}
					dataObj[0]["APPLY_OPTION"] = (node.value ? node.value : "");
				},
				genRule:function(record , value){
					return true;
				}
			}
		},
		{header: "匯款金額",key: "REMIT_AMT",
			input:{
				type:'TEXT',
				size:11,
				maxLength:11,
				genRule:function(rec , val){
					return true;
				},
				action:function( node , dataObj , textDiv, orgData , isOnChange ){
					if(!isOnChange){
						node.style.textAlign = 'right';
						node.onkeypress = function(){
							return CSRUtil.pressNumber(event.keyCode);
						};
						node.onkeyup = function(){
							node.up('tr').dataObj["REMIT_AMT"] = (node.value ? node.value.replace(/,/g,"") : "");
							node.value = CSRUtil.$fmt(node.value, CSRUtil.defaultPattern, true);
						};
						node.setAttribute("className" , "checkInputLength");
						node.value = (node.value ? node.value : "0");
						node.maxLength = 11;
						node.id="REMIT_AMT"+dataObj[0]["NAPPLY_ID"];
					}
					dataObj[0]["REMIT_AMT"] = (node.value ? node.value : "");
				}, actionWhenStart:true
			}
		},
		{header: "部入金額",key: "PARTIAL_AMT",
			input:{
				type:'TEXT',
				size:11,
				maxLength:11,
				genRule:function(rec , val){
					return true;
				},
				action:function( node , dataObj , textDiv, orgData , isOnChange ){
					if(!isOnChange){
						node.style.textAlign = 'right';
						node.onkeypress = function(){
							return CSRUtil.pressNumber(event.keyCode);
						};
						node.onkeyup = function(){
							node.up('tr').dataObj["PARTIAL_AMT"] = (node.value ? node.value.replace(/,/g,"") : "");
							node.value = CSRUtil.$fmt(node.value, CSRUtil.defaultPattern, true);
						}; 
						node.setAttribute("className" , "checkInputLength");
						node.value = (node.value ? node.value : "0");
						node.maxLength = 11;
						node.id="PARTIAL_AMT"+dataObj[0]["NAPPLY_ID"];
					}
					dataObj[0]["PARTIAL_AMT"] = (node.value ? node.value : "0");
				}, actionWhenStart:true
			}
		}
	];

	column2 = [
		{header: "受理編號",key: "NAPPLY_ID",
			render: function( record, value ){
				return value ? value : '';
			}							
		},
		{header: "借款人ID",key: "NBORROW_ID",
			render: function( record, value ){
				return value ? value : '';
			}							
		},
		{header: "借款人姓名",key: "NBORROW_NAME",
			render: function( record, value ){
				return value ? value : '';
			}							
		},
		{header: "借款金額",key: "AGREE_AMT",
			render: function( record, value ){
				return value ? CSRUtil.$fmt(value, CSRUtil.defaultPattern) : '';
			}							
		}
	];

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSB6_0200/" + actionName,
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
			});
	}	
	
	//buttons對應的event function
	var buttons = {	
		
		//試算資料
		doInsert : function(event){
			var allRec  = grid4.getAllRecords();  
			
			for(i=0;i<allRec.length;i++){
				allRec[i].APPLY_OPTION = $('APPLY_OPTION'+allRec[i].NAPPLY_ID).value;
				allRec[i].REMIT_AMT = $('REMIT_AMT'+allRec[i].NAPPLY_ID).value.replace(/,/gi,'');
				allRec[i].PARTIAL_AMT = $('PARTIAL_AMT'+allRec[i].NAPPLY_ID).value.replace(/,/gi,'');
			}
			
			chkMap.newList = Object.toJSON(allRec);
			
			ajaxPost('insert',chkMap,successActionOpen);
		},
		
		//查詢資料
		doQuery : function(event){	
			var dataMap = {};
			dataMap.TURN_DATE = $('TURN_DATE').value;
			dataMap.APPLY_LIST = $('APPLY_LIST').value;
			dataMap.LOAN_LIST = $('LOAN_LIST').value;
			
			ajaxPost('query',dataMap,successActionOpen);
		},
		
		//列印
		doPrint : function(event){
			window.open("", "DSB6_0201", "top=50, left=50,  toolbar=no, resizable=yes, location=0, status=0, scrollbars=1, titlebar=0, width=800, height=600");
			
			var url = "<%=dispatcher%>/DSB6_0201/prompt";			
			var form = $('form1');
			$('newList').value = Object.toJSON(grid4.getAllRecords());
			form.target='DSB6_0201';
			form.action=url;
			form.submit();
		},
		
	    //回上頁
	    doBack:function(){
	    	CSRUtil.linkBack();
	    }

	};
	
		//成功
	var successActionOpen = function(resp){
		var isOK = resp.isOK;
		chkMap.TURN_DATE = $('TURN_DATE').value;
		chkMap.APPLY_LIST = $('APPLY_LIST').value;
		chkMap.LOAN_LIST = $('LOAN_LIST').value;
		chkMap.APPLY_SUM = resp.ApplySum ? resp.ApplySum : '0';
		chkMap.LOAN_SUM = resp.LoanSum ? resp.LoanSum : '0';
                chkMap.SUM_BALC_AMT = resp.BalcSum ? resp.BalcSum : '0';
		chkMap.NEW_REMAIN_AMT = resp.NewRemainAmt ? resp.NewRemainAmt : '0';
		chkMap.OLD_REMAIN_AMT = resp.OldRemainAmt ? resp.OldRemainAmt : '0';
		chkMap.CredDept = resp.CredDept ? resp.CredDept : '';
		chkMap.oldList = resp.oldList ? Object.toJSON(resp.oldList) : [];
		chkMap.oldsumList = resp.oldsumList ? Object.toJSON(resp.oldsumList) : [];
		
		if(isOK == false){
			//將 Errmsg1、Errmsg2、Errmsg3、Errmsg4放至畫面,參見畫面一
			$('tableA').hide();
			$('tableB_3').hide();
			$('tableB_4').hide();
			$('tableB_5').hide();
			$('tableB_7').hide();
			$('tableB_8').hide();
			$('tableB_9').hide();
			$('tableC').show();
			Errmsg1 = resp.Errmsg1 ? resp.Errmsg1 : '';
			Errmsg2 = resp.Errmsg2 ? resp.Errmsg2 : '';
			Errmsg3 = resp.Errmsg3 ? resp.Errmsg3 : '';
			Errmsg4 = resp.Errmsg4 ? resp.Errmsg4 : '';
			$('Errmsg').innerHTML = Errmsg1+Errmsg2+Errmsg3+Errmsg4;
		}else{
			$('tableA').show();
			$('tableB_3').show();
			$('tableB_4').show();
			$('tableB_5').show();
			$('tableB_7').hide();
			$('tableB_8').hide();
			$('tableB_9').hide();
			$('tableC').show();
			//(新件正常件)-
			//alert(resp.isFinalCheck + '\n' + resp.isCashed + '\n' + resp.isOldStatus);
			if("0"==resp.isCashed && "0"==resp.isOldStatus){
				//isFinalCheck = ‘0’   and      //無清償主檔紀錄
     			//isCashed = ‘0’        and      //無未兌現票紀錄
				//isOldStatus = ‘0’              //舊件狀態正常
				//參見畫面二,如下1.4.2.4				
				grid4 = new TableUI ( {
						table:$("grid4"), allSortable:true, overDiv:false,
						column:column1
					});
				
				$('TURN_DATE_VIEW').innerHTML = resp.TURN_DATE ? Date.toROC(resp.TURN_DATE) : '';
				$('RENEW_GPID_VIEW').innerHTML = resp.B400Map.RENEW_GPID ? resp.B400Map.RENEW_GPID : '';
				$('RENEW_PROC_NM_VIEW').innerHTML = resp.B400Map.RENEW_PROC_NM ? resp.B400Map.RENEW_PROC_NM : '';
				grid3.load(resp.addrList || []);
				grid4.load(resp.newList || []);
				grid5.load(resp.oldList || []);
				if("1"==resp.isFinalCheck){
					$('tableB_8').show();
					grid8.load(resp.finalList || []);
				}
				$('APPLY_SUM_VIEW').innerHTML = resp.ApplySum ? CSRUtil.$fmt(resp.ApplySum, CSRUtil.defaultPattern) : '0';
				$('LOAN_SUM_VIEW').innerHTML = resp.LoanSum ? CSRUtil.$fmt(resp.LoanSum, CSRUtil.defaultPattern) : '0';
				NewRemainAmt = resp.NewRemainAmt ? CSRUtil.$fmt(resp.NewRemainAmt, CSRUtil.defaultPattern) : '0';
				$('NEW_REMAIN_AMT_VIEW').innerHTML = "新件多餘差額＝<font color=red >" + NewRemainAmt + "</font>元";
				OldRemainAmt = resp.OldRemainAmt ? CSRUtil.$fmt(resp.OldRemainAmt, CSRUtil.defaultPattern) : '0';
				$('OLD_REMAIN_AMT_VIEW').innerHTML = "應補差額＝<font color=red >" + OldRemainAmt + "</font>元";
				buttonAuth();
            }else{
                //(新件正常件,但有其他資訊不能輸入)-
           		//輸入按鈕disable,
				//(4-b區)輸入欄位不顯示,
				//其他區塊參見畫面三~畫面六,如下1.4.2.5~1.4.2.7
				grid4 = new TableUI ( {
						table:$("grid4"), allSortable:true, overDiv:false,
						column:column2
					});
            	
            	//$("btn_insert").disabled = true;
            	if("1"==resp.isCashed){
					$('tableB_7').show();
					grid7.load(resp.cashList || []);
				}
				if("1"==resp.isFinalCheck){
					$('tableB_8').show();
					grid8.load(resp.finalList || []);
				}
				if("1"==resp.isOldStatus){
					$('grid5').hide();
					grid5.load([]);
					$('OLD_MSG_VIEW').innerHTML = resp.old_msg ? "<B>"+resp.old_msg+"</B>" : '';
				}else{
					$('grid5').show();
					grid5.load(resp.oldList || []);
					$('OLD_MSG_VIEW').innerHTML = '';
				}
				if("1"==resp.prepayList){
					$('tableB_9').show();
					grid9.load(resp.prepayList || []);
				}
				
				$('TURN_DATE_VIEW').innerHTML = resp.TURN_DATE ? Date.toROC(resp.TURN_DATE) : '';
				$('RENEW_GPID_VIEW').innerHTML = resp.B400Map.RENEW_GPID ? resp.B400Map.RENEW_GPID : '';
				$('RENEW_PROC_NM_VIEW').innerHTML = resp.B400Map.RENEW_PROC_NM ? resp.B400Map.RENEW_PROC_NM : '';
				grid3.load(resp.addrList || []);
				grid4.load(resp.newList || []);
				$('APPLY_SUM_VIEW').innerHTML = resp.ApplySum ? CSRUtil.$fmt(resp.ApplySum, CSRUtil.defaultPattern) : '0';
				$('LOAN_SUM_VIEW').innerHTML = resp.LoanSum ? CSRUtil.$fmt(resp.LoanSum, CSRUtil.defaultPattern) : '0';
				NewRemainAmt = resp.NewRemainAmt ? CSRUtil.$fmt(resp.NewRemainAmt, CSRUtil.defaultPattern) : '0';
				$('NEW_REMAIN_AMT_VIEW').innerHTML = "新件多餘差額＝<font color=red >" + NewRemainAmt + "</font>元";
				OldRemainAmt = resp.OldRemainAmt ? CSRUtil.$fmt(resp.OldRemainAmt, CSRUtil.defaultPattern) : '0';
				$('OLD_REMAIN_AMT_VIEW').innerHTML = "應補差額＝<font color=red >" + OldRemainAmt + "</font>元";
			}
			
		}
		//20160426 舊件是否正進行轉帳扣款
		if (resp.EXTRACT_MSG) {
			alert(resp.EXTRACT_MSG);
		}
		fix();
		PageUI.resize(true);  
	};
	
	return {

			initApp : function() {		
				//PageUI.createPageWithAllBodySubElement("DSB60200", "借新還舊", "帳號設定輸入", 1);
				PageUI.createPage("DSB60200", "借新還舊", "帳號設定輸入");
				PageUI.loadin(["tableA","tableB_3","tableB_4","tableB_5","tableB_7","tableB_8","tableB_9","tableC"] ,1);
					
				grid3 = new TableUI ( {
						table:$("grid3"), allSortable:true, overDiv:false,
						column:[
							{header: "新件受理編號∕舊件貸款帳號",key: "ID", attrs:{width:"35%"},
								render: function( record, value ){
									return value ? value : '';
								}							
							},
							{header: "擔保品地址",key: "GAGE_ADDR",
								render: function( record, value ){
									return value ? value : '';
								}							
							}
						]
					});
					
				grid4 = new TableUI ( {
						table:$("grid4"), allSortable:true, overDiv:false,
						column:column1
					});
					
				grid5 = new TableUI ( {
						table:$("grid5"), allSortable:true, overDiv:false,
						split: ['PAY_DATE'],
						column:[
							{header: "帳號",key: "OLOAN_ID", attrs:{ rowSpan:2 },
								render: function( record, value ){
									return value ? value : '';
								}							
							},
							{header: "借款人ID",key: "OBORROW_ID", attrs:{ rowSpan:2 },
								render: function( record, value ){
									return value ? value : '';
								}							
							},
							{header: "借款人姓名",key: "OBORROW_NAME", attrs:{ rowSpan:2 },
								render: function( record, value ){
									return value ? value : '';
								}							
							},
							{header: "期數",key: "PAID_TIMES", attrs:{ rowSpan:2 },
								render: function( record, value ){
									return value ? CSRUtil.$fmt(value, CSRUtil.defaultPattern) : '';
								}							
							},
							{header: "應繳日",key: "NEXT_PAYDT",
								render: function( record, value ){
									return value ? Date.toROC(value) : '';
								}							
							},
							{header: "應繳金額",key: "DUTY_PAYMT",
								render: function( record, value ){
									return value ? CSRUtil.$fmt(value, CSRUtil.defaultPattern) : '';
								}							
							},
							{header: "利息",key: "INTEREST",
								render: function( record, value ){
									return value ? CSRUtil.$fmt(value, CSRUtil.defaultPattern) : '';
								}							
							},
							{header: "違約金",key: "RENEGE",
								render: function( record, value ){
									return value ? CSRUtil.$fmt(value, CSRUtil.defaultPattern) : '';
								}							
							},
							{header: "上期結餘",key: "LAST_BALANCE",
								render: function( record, value ){
									return value ? CSRUtil.$fmt(value, CSRUtil.defaultPattern) : '';
								}							
							},
							{header: "未清償金額",key: "LOAN_REMAIN", attrs:{ rowSpan:2 },
								render: function( record, value ){
									return value ? CSRUtil.$fmt(value, CSRUtil.defaultPattern) : '';
								}							
							},
							{header: "人工暫收金額",key: "BALC_AMT", attrs:{ rowSpan:2 },
								render: function( record, value ){
									return value ? CSRUtil.$fmt(value, CSRUtil.defaultPattern) : '';
								}							
							},
							{header: "實繳日",key: "PAY_DATE",
								render: function( record, value ){
									return value ? Date.toROC(value) : '';
								}							
							},
							{header: "應攤本金",key: "PRINCIPAL",
								render: function( record, value ){
									return value ? CSRUtil.$fmt(value, CSRUtil.defaultPattern) : '';
								}							
							},
							{header: "逾期息",key: "DELAY_INT",
								render: function( record, value ){
									return value ? CSRUtil.$fmt(value, CSRUtil.defaultPattern) : '';
								}							
							},
							{header: "管理費",key: "LAWSUIT_FEE",
								render: function( record, value ){
									return value ? CSRUtil.$fmt(value, CSRUtil.defaultPattern) : '';
								}							
							},
							{header: "代扣稅款",key: "TAX",
								render: function( record, value ){
									return value ? CSRUtil.$fmt(value, CSRUtil.defaultPattern) : '';
								}							
							}
						]
					});
					
				grid7 = new TableUI ( {
						table:$("grid7"), allSortable:true, overDiv:false,
						column:[
							{header: "貸款帳號",key: "CLOAN_ID",
								render: function( record, value ){
									return value ? value : '';
								}							
							},
							{header: "繳款期數",key: "PAY_TERM",
								render: function( record, value ){
									return value ? value : '';
								}							
							},
							{header: "繳款別",key: "PAY_KIND_NM",
								render: function( record, value ){
									return value ? value : '';
								}							
							},
							{header: "序號",key: "SEQ_NO",
								render: function( record, value ){
									return value ? value : '';
								}							
							},
							{header: "繳款方式",key: "PAY_TYPE_NM",
								render: function( record, value ){
									return value ? value : '';
								}							
							},
							{header: "實繳日",key: "REAL_PAYDT",
								render: function( record, value ){
									return value ? Date.toROC(value) : '';
								}							
							},
							{header: "實繳金額",key: "REAL_PAYMT",
								render: function( record, value ){
									return value ? CSRUtil.$fmt(value, CSRUtil.defaultPattern) : '';
								}							
							}
						]
					});
					
				grid8 = new TableUI ( {
						table:$("grid8"), allSortable:true, overDiv:false,
						column:[
							{header: "貸款帳號",key: "FLOAN_ID",
								render: function( record, value ){
									return value ? value : '';
								}							
							},
							{header: "是否核發清償證明",key: "FINAL_CHECK",
								render: function( record, value ){
									return value ? value : '';
								}							
							}
						]
					});
					
				grid9 = new TableUI ( {
						table:$("grid9"), allSortable:true, overDiv:false,
						column:[
							{header: "貸款帳號",key: "PLOAN_ID",
								render: function( record, value ){
									return value ? value : '';
								}							
							},
							{header: "預繳期數",key: "PREPAY_TIMES",
								render: function( record, value ){
									return value ? value : '';
								}							
							}
						]
					});
			
				//註冊DOM物件
				//click事件
				//回上頁
				$('btn_back').observe('click',function(event){buttons.doBack();});
				$("btn_insert").observe("click", buttons.doInsert );	
				//列印
				$('btn_print').observe('click',function(event){buttons.doPrint();});
			
				
				fix();

				displayMessage();	
				
				buttonAuth();

				buttons.doQuery();

			}
	};	
};

</script>
</head>
<body>	
<form id="form1" name="form1">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
		<tr>
			<td class="tbYellow" width="15%">
				切轉日期
				<input type="hidden" id="TURN_DATE" name="TURN_DATE" class="textBox2" value="<c:out value = '${TURN_DATE}'/>" />  
				<input type="hidden" id="APPLY_LIST" name="APPLY_LIST" class="textBox2" value="<c:out value = '${APPLY_LIST}'/>" />
				<input type="hidden" id="LOAN_LIST" name="LOAN_LIST" class="textBox2" value="<c:out value = '${LOAN_LIST}'/>" />
				<input type="hidden" id="newList" name="newList" class="textBox2"  />
			</td>
			<td class="tbYellow2" width="15%" id="TURN_DATE_VIEW">
			</td>
			<td class="tbYellow" width="15%">
				借新還舊組號
			</td>
			<td class="tbYellow2" width="20%" id="RENEW_GPID_VIEW">
			</td>
			<td class="tbYellow" width="15%">
				新放進度
			</td>
			<td class="tbYellow2" width="20%" id="RENEW_PROC_NM_VIEW">
			</td>
		</tr>
		<tr>
			<td align="center" colspan="6">
				 <input type="button" class="button" value="輸入" id="btn_insert">
				 <input id="btn_print" type="button" class="button" value="列印" />
			</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB_3">
		<tr>
    		<td class="tbYellow0" align="center"><B>擔保品資訊</B></td>
    	</tr>
		<tr>
		    <td align="center">
				<table id='grid3' width="100%"></table>
		    </td>
		</tr>
    </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB_4">
		<tr>
    		<td class="tbYellow0" align="center"><B>新件</B></td>
    	</tr>
		<tr>
		    <td align="center">
				<table id='grid4' width="100%"></table>
		    </td>
		</tr>
		<tr>
			<td class="tbBlue0" align="left">新件借款總額＝<font color=green id="APPLY_SUM_VIEW"></font>元</td>
		</tr>
    </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB_7">
		<tr>
    		<td class="tbYellow0" align="left"><font color=red><B>舊件票據未兌現資料：</B></font></td>
    	</tr>
		<tr>
		    <td align="center">
				<table id='grid7' width="100%"></table>
		    </td>
		</tr>
    </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB_8">
		<tr>
			<td class="tbYellow0" align="left"><font color=red><B>舊件是否核發清償證明：</B></font></td>								
		</tr>
		<tr>
		    <td align="center">
				<table id='grid8' width="100%"></table>
		    </td>
		</tr>
    </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB_9">
		<tr>
			<td class="tbYellow0" align="left"><font color=red><B>舊件預繳紀錄：</B></font></td>								
		</tr>
		<tr>
		    <td align="center">
				<table id='grid9' width="100%"></table>
		    </td>
		</tr>
    </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB_5">
		<tr>
		    <td class="tbYellow0" align="center"><B>舊件</B></td>
		</tr>
		<tr>
		    <td align="center">
				<table id='grid5' width="100%"></table>
		    </td>
		</tr>
		<tr>
		    <td align="left" id="OLD_MSG_VIEW">
		    </td>
		</tr>
		<tr>
			<td class="tbBlue0" align="left">舊件未清償總額＝<font color=green id="LOAN_SUM_VIEW"></font>元</td>
		</tr>
    </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableC">
		 <tr>
		    <td class="tbYellow" align="left" id="Errmsg">                                     
		    </td>
		 </tr>
		<tr>
			<td class="tbYellow0" align="left" id="NEW_REMAIN_AMT_VIEW"></td>
		</tr>
		<tr>
			<td class="tbYellow0" align="left" id="OLD_REMAIN_AMT_VIEW"></td>
		</tr>
		 <tr>
		    <td align="center">
				<input type="button" class="button" value="回上一頁" id="btn_back">
		    </td>
		 </tr>
	</table>
</form>
</body>
</html>