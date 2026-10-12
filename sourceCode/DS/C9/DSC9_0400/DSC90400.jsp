<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC90400.jsp
作者：卓達瑋
功能：理財型展期審查作業
完成：2013/06/17
2019-07-19申請書-新增理財型自動展期作業：新增聯徵記錄欄位顯示為正常或待審，並可帶出徵信報告

[20230324]
難字調整
高強禾
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>

<%-- [20230324] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>

<script type="text/JavaScript">

Event.observe(window, 'load', new DSC90400().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC90400(){
    var grid;
	//按鈕授權
		
	function buttonAuth() {
		var authButtons = { 
			B0168 : 'BTN_SEND',    <%--聯徵送出--%>
			B0169 : 'BTN_CREDIT',    <%--徵信作業--%>
			B0117 : 'BTN_FIRSTCON',    <%--組長覆核--%>
			B0118 : 'BTN_SECONDCON'    <%--主管覆核--%>
		};
		<dz:grantButtons FUNC_ID="DSC90400"  ignored='false'/>
		
	}	

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC9_0400/" + actionName,
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
	};
	var action= {
        //將畫面寫入Map	
	    queryMap:function(){
			return{
				CRED_DEPT: $F('CRED_DEPT'),
				END_DATE: $F('END_DATE'),
				ASSIGN_ID2: $F('Q_ASSIGN_ID2'),
				PROC_STATUS:$F('PROC_STATUS'),
				SORT_KEY: $F('SORT_KEY')
		    }
		},
		//承辦科別下拉選單連動徵信人員下拉選單
	    doChangeASSIGN :function(event){
		    rec_CRED_DEPT = event.target.value;
			if(rec_CRED_DEPT ==''){
				$('Q_ASSIGN_ID2').options.length = 1;
				return;
			}
			ajaxPost( 'changeASSIGN', { CRED_DEPT : rec_CRED_DEPT}
				,function(resp){	    
		
				    var rec_list_A = resp.RLDS2_LIST;
				
					$('Q_ASSIGN_ID2').options.length = 1;
					
					if(rec_list_A){
						 rec_list_A.each(
							function(data) {
								$('Q_ASSIGN_ID2').add(new Option(data.NAME, data.ID));
							}		
						); 	
					}				
                }
			);				
		},
		//徵信作業、組長覆核、主管覆核共同方法
		doconfirm :function(str,str2){
		    var dataList = grid.getCheckedRecord();	
			if(dataList.length==0){
				alert(str);
				return;
			}
			
			for (var i = 0 ; i < dataList.length ; i++){
				var SER_NO = dataList[i].SER_NO;
				
				if(!$('IS_EJCIC_A_' + SER_NO).checked && !$('IS_EJCIC_B_' + SER_NO).checked){
				    alert('貸款帳號:'+ dataList[i].LOAN_ID + '，請選取聯徵是否異常');
					return;
				}
				
				if(!$('IS_PAY_A_' + SER_NO).checked && !$('IS_PAY_B_' + SER_NO).checked){
				    alert('貸款帳號:'+ dataList[i].LOAN_ID + '，請選取繳息是否異常');
					return;
				}
				
				if(!$('IS_EXTEND_A_' + SER_NO).checked && !$('IS_EXTEND_B_' + SER_NO).checked){
				    alert('貸款帳號:'+ dataList[i].LOAN_ID + '，請選取是否展期');
					return;
				}
			}
			
			ajaxPost( str2, {'dataList' :Object.toJSON(dataList)}
				,function(resp){
				    button.doQuery();
				}	
			);
		}
	}	
	// 功能按鈕
	var button = {
			
		// 查詢
		doQuery: function() {	
			ajaxPost( 'query', {'reqMap' :Object.toJSON(action.queryMap())}
				,function(resp){
				    grid.load(resp.rtnList);
				}
				,function(){
				    grid.load([]);
				}
			);
		},
    	//聯徵送出
		dosend: function() {	
		    var data =grid.getCheckedRecord();	
			if(data.length==0){
			  alert("請先勾選欲送出資料，才能作業");
			  return;
			}		
			ajaxPost( 'send', {'dataList' :Object.toJSON(data)}
				,function(resp){
			        var sendList = resp.sendList;	
					popupWin.windowOpen('<%=dispatcher%>/DSA2_2200/prompt',{
						'parameters': {
						    'LINK_FROM': "DSC90400" , 
						    'chkList': sendList				
						}
			        });  
				}
			);
		},
		//徵信作業
		doCredit: function() {	
		    action.doconfirm('請先勾選欲徵信作業資料，才能作業','credit');
		},
		//組長覆核
		doFirstconfirm: function() {	
		    action.doconfirm('請先勾選欲覆核資料，才能作業','firstconfirm');		    
		},
		//主管覆核
		doSecondconfirm: function() {	
		    action.doconfirm('請先勾選欲覆核資料，才能作業','secondconfirm');
		},
		//列印
		doPrint: function(rec) {			
			ajaxPost( 'print', {'LOAN_ID' :rec.LOAN_ID,'END_DATE':rec.END_DATE}
				,function(resp){
					var tempErrMsg = resp.tempErrMsg;	
					if(tempErrMsg){	
						//確認ok , 繼續執行
						if(!confirm('貸款帳號:'+ rec.LOAN_ID +','+tempErrMsg)){
							return;
						}
					}

					RPTUtil.executePrintByLink ( "<%=dispatcher%>/DSC9_0410/prompt" , { 'LOAN_ID': rec.LOAN_ID, 'ASSIGN_ID2': rec.ASSIGN_ID2, 'END_DATE': rec.END_DATE}, true );

				}
			);
		}
		
	};
	
	return {
		initApp : function() {

			PageUI.createPageWithAllBodySubElement( "DSC90400" , "覆審作業", "理財型展期審查作業" );
            grid = new TableUI(
				{table: $("grid"), allSortable:false, pageSize: 20,
				autoCheckBox:{
				    isSelectAll: true,
				    withoutGroup: true,
					genRule:function(record,value){
					    return  record.ROW_TYPE == '1';	
					}
				},	
				<%-- [20230324] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[					
					{header:"貸款帳號",key:"LOAN_ID",
						render:function(rec,val){
							return rec.ROW_TYPE=='1' ? val: rec.C100_LOAN_ID;
						}
					},
					<%-- [20230324] 難字調整 --%>
					{header:"借款人",key:"BORROW_NAME",attrs:{style:"font-family:'EUDC'"}},	
					{header:"借款人ID",key:"BORROW_ID"},
					{header:"使用狀態/契約狀況",key:"MM_STATUS_NM",
					    render : function (rec , val){
							if(rec.ROW_TYPE == '1'){
							    return val||'';
							}else{
							    return rec.LOAN_STATUS_NM ||'';
							}   							
						}
					},
					{header:"原貸帳號",key:"REFER_ID",groupKey:["REFER_ID"]},
                    {header:"擔借款總餘額",key:"REMAIN_AMT",
					    render: function (rec,val){
							if(rec.ROW_TYPE == '1'){
							    return val ? MoneyFormat(val) : "0";
							}else{
							    return '';
							}   							
						}
					},
					{header:"理財型額度",key:"MM_AMT",
					    render: function (rec,val){
							if(rec.ROW_TYPE == '1'){
							    return val ? MoneyFormat(val) : "0";
							}else{
							    return '';
							}   							
						}
					},
					{header:"動用金額",key:"C104_REMAIN_AMT",
					    render: function (rec,val){
							if(rec.ROW_TYPE == '1'){
							    return val ? MoneyFormat(val) : "0";
							}else{
							    return '';
							}   							
						}
					},
                    {header:"本金餘額",key:"C100_REMAIN_AMT",
					    render: function (rec,val){
							if(rec.ROW_TYPE == '1'){
							    return '';
							}else{
							    return val ? MoneyFormat(val) : "0";
							}   							
						}
					},
					{header:"到期日",key:"END_DATE",
					    render : function (rec , val){
							return rec.ROW_TYPE=='1' ? Date.toROC(val||'') : Date.toROC(rec.C100_END_DATE||'');									
						}
					},
					{header:"繳息情況",key:"PAY_REC_NM",
					    render:function(rec , val){ 							
							if(val){
								if(rec.ROW_TYPE == '1'){
									//超連結至DSH0_0307繳息記錄查詢作業
									var link = new Element( 'a' , { href : "#" } ).update(val);	
								    
									link.observe( 'click', function (event){ 
									 	var LP_JSON = {
											action :'<%=dispatcher%>/DSH0_0307/prompt',	
											LOAN_ID : rec.LOAN_ID  //貸款帳號
										}			
										CSRUtil.linkTo(LP_JSON,'form1');
									});										
									return link; 															
							    }
								return val;
							}
							return '';
						}
					
					},
					{header:"聯徵記錄",key:"HYPER_R",
					    render:function(rec , val){ 							
							if(rec.ROW_TYPE == '1'){
								if(rec.REQUESTID ){
									var link = new Element( 'a' , { href : "#" } ).update(val);	
									link.observe( 'click', function (event){ 
										//開啟新視窗(WINDOW OPEN)至 “DSA2_2200”(聯徵系統連結)畫面，將資料傳至聯徵系統
                                       	var chkList=[{
										    TXID: "Q801", //查詢項目
										    MSGID: rec.MSGID, //訊息編號
											QDATE: rec.QDATE, //查詢日期
											QUERYKEY1: rec.QUERYKEY1, //被查詢者的ID
											QUERYKEY2: rec.QUERYKEY2, //關係年月/月/季(標準)
										    ISPRINT: rec.ISPRINT, //是否要列印查詢記錄
										    CASE_ID : rec.LOAN_ID, //[申請書:24120444624]建立聯徵查詢存取軌跡紀錄:多傳入受理編號or貸款帳號
										    NAME: rec.BORROW_NAME
										}]
										//@ 2018/09/28 王文進 調整查詢聯徵歷史資料來源
										var toDay = addDate(getY2KToday(),0,0,-7);
										var qDate = toY2K(rec.QDATE);
										//alert(toDay);
										//alert(qDate);
										//alert(diffDay(qDate, toDay) < 0 );
										if(diffDay(qDate, toDay) >= 0){
											popupWin.windowOpen('<%=dispatcher%>/DSA2_0410/queryDetail',{
												'parameters': {
													'LINK_FROM': "DSC90400",
													'chkList' : Object.toJSON(chkList)				
												}
											});
										}else{
											popupWin.windowOpen('<%=dispatcher%>/DSA2_2200/prompt',{
												'parameters': {
													'LINK_FROM': "DSC90400",
													'chkList' : Object.toJSON(chkList)				
												}
											});
										}
									});										
									return link; 															
								}else{
								    return val;
								} 
							}
							return '';	
						}
					},
					{header:"是否異常",key:"PAY_EJCIC",
					    render : function(rec, val) {
							if(rec.ROW_TYPE == '1'){
								var IS_PAY = "IS_PAY_" + rec.SER_NO;
								var IS_PAY_A = "IS_PAY_A_" + rec.SER_NO;
								var IS_PAY_B = "IS_PAY_B_" + rec.SER_NO;
								var IS_EJCIC = "IS_EJCIC_" + rec.SER_NO;
								var IS_EJCIC_A = "IS_EJCIC_A_" + rec.SER_NO;
								var IS_EJCIC_B = "IS_EJCIC_B_" + rec.SER_NO;
								
								var chk = new Element('input', {type : 'radio' ,id: IS_PAY_A, name: IS_PAY});							
								chk.observe('click', function(event){								
									var tr = this.up('tr')		
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj.IS_PAY ='0';	
								});
								var chk2 = new Element('input', {type : 'radio' ,id: IS_PAY_B, name: IS_PAY});							
								chk2.observe('click', function(event){								
									var tr = this.up('tr')		
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj.IS_PAY ='1';	
								});
								var chk3 = new Element('input', {type : 'radio' ,id:IS_EJCIC_A, name:IS_EJCIC});							
								chk3.observe('click', function(event){								
									var tr = this.up('tr')		
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj.IS_EJCIC ='0';	
								});
								var chk4 = new Element('input', {type : 'radio' ,id:IS_EJCIC_B, name:IS_EJCIC});							
								chk4.observe('click', function(event){								
									var tr = this.up('tr')		
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj.IS_EJCIC ='1';	
								});
								
								var span=new Element('span');
								
								span.insert("繳息").insert(chk).insert("正").insert(chk2).insert("異");
								span.insert("<br>聯徵").insert(chk3).insert("正").insert(chk4).insert("異")
								
								//預設選取設定
								
								if(rec.IS_PAY=='0'){
								    chk.checked=true;	
								}else if(rec.IS_PAY=='1'){
								    chk2.checked=true;	
								}
								if(rec.IS_EJCIC=='0'){
								    chk3.checked=true;	
								}else if(rec.IS_EJCIC=='1'){
								    chk4.checked=true;	
								}
								return span;
						    }
						    return "";
						}
					
					},
					<%-- [20230324] 難字調整 --%>
					{header:"徵信人員",key:"ASSIGN_NAME2",attrs:{style:"font-family:'EUDC'"},
					    render: function (rec,val){
							if(rec.ROW_TYPE == '1'){
							    return val;
							}else{
							    return "";
							}   							
						}
					},
					{header:"徵信日期",key:"EXTEND_DATE",
					    render: function (rec,val){
							if(rec.ROW_TYPE == '1'){
							    return Date.toROC(val || "");
							}else{
							    return "";
							}   							
						}
					},
					<%-- [20230324] 難字調整 --%>
					{header:"覆核人員",key:"CONFIRM_NAME",attrs:{style:"font-family:'EUDC'"},
					    render: function (rec,val){
							if(rec.ROW_TYPE == '1'){
							    return val;
							}else{
							    return "";
							}   							
						}
					},
					{header:"覆核日期",key:"CONFIRM_DATE",
					    render: function (rec,val){
							if(rec.ROW_TYPE == '1'){
							    return Date.toROC(val || "");
							}else{
							    return "";
							}   							
						}
					},
					<%-- [20230324] 難字調整 --%>
                    {header:"主管覆核",key:"FINAL_NAME",attrs:{style:"font-family:'EUDC'"},
					    render: function (rec,val){
							if(rec.ROW_TYPE == '1'){
							    return val;
							}else{
							    return "";
							}   							
						}
					},
					{header:"主管覆核日期",key:"FINAL_DATE",
					    render: function (rec,val){
							if(rec.ROW_TYPE == '1'){
							    return Date.toROC(val || "");
							}else{
							    return "";
							}   							
						}
					},
					{header:"徵信派件日期",key:"ASSIGN_DATE2",
					    render: function (rec,val){
							if(rec.ROW_TYPE == '1'){
							    return Date.toROC(val || "");
							}else{
							    return "";
							}   							
						}
					},
					{header:"是否展期",key:"IS_EXTEND",
					    render : function(rec, val) {
							if(rec.ROW_TYPE == '1'){
								var IS_EXTEND = "IS_EXTEND_" + rec.SER_NO;
								var IS_EXTEND_A = "IS_EXTEND_A_" + rec.SER_NO;
								var IS_EXTEND_B = "IS_EXTEND_B_" + rec.SER_NO;
								
								var chk = new Element('input', {type : 'radio' ,id: IS_EXTEND_A, name:IS_EXTEND});							
								chk.observe('click', function(event){								
									var tr = this.up('tr')		
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj.IS_EXTEND ='1';	
								});
								var chk2 = new Element('input', {type : 'radio' ,id: IS_EXTEND_B, name:IS_EXTEND});							
								chk2.observe('click', function(event){								
									var tr = this.up('tr')		
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj.IS_EXTEND ='0';	
								});
								var span=new Element('span');
								span.insert(chk).insert("是").insert(chk2).insert("否");
								//預設給值
								if(rec.IS_EXTEND=='1'){
								    chk.checked=true;	
								}else if(rec.IS_EXTEND=='0'){
								    chk2.checked=true;	
								}
								return span;
						    }
						    return "";
						}
					},
					{header:"說明",key:"EXTEND_NOTE",
					    render: function (rec,val){
							if(rec.ROW_TYPE == '1'){
								var EXTEND_NOTE = "EXTEND_NOTE_" + rec.SER_NO;
								<%-- [20230324] 難字調整 --%>
						        var TextArea = new Element("TextArea", {id: EXTEND_NOTE, name: EXTEND_NOTE, rows:3, cols:30, alt:'ch'});												
							    TextArea.observe('change', function(event){
									var tr=this.up('tr');
									dataObj = tr.getAttribute("dataObj")|| grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj.EXTEND_NOTE=event.target.value;
									}
							    );
							    //預設給值
							    TextArea.value = val;
                                return TextArea;
							}
                            return "";							
						}
					},
					{header:"處理進度",key:"PROC_STATUS_NM",
					    render: function (rec,val){
							if(rec.ROW_TYPE == '1'){
							    return val;
							}else{
							    return "";
							}   							
						}
					},
					{header:"通知書",key:"EXP_PRINT",
					    render: function (rec,val){
							var check = new Element("input" , {type : 'button' , value : '列印' , className : 'button'} );
							check.observe("click", function(event){
								var tr=this.up('tr');
								dataObj = tr.getAttribute("dataObj")|| grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
								button.doPrint(dataObj);										
							}); 
                            var span=new Element("span");							
							if(rec.ROW_TYPE == '1'){
							    var PRINT_DATE=rec.PRINT_DATE;
								if(PRINT_DATE){
								    return span.insert(Date.toROC(PRINT_DATE)).insert(check);  
								}else{
								    return span.insert(check);  
								}
							}else{
							    return "";
							}   							
						}
					}
				]
			});
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			//畫面檢核
			buttonAuth();
			// 監聽
			$("BTN_QUERY").observe('click', button.doQuery);
            $("BTN_SEND").observe('click', button.dosend);
			$("BTN_CREDIT").observe('click', button.doCredit);
			$("BTN_FIRSTCON").observe('click', button.doFirstconfirm);
			$("BTN_SECONDCON").observe('click', button.doSecondconfirm);
			$("CRED_DEPT").observe('change',action.doChangeASSIGN);//連動徵信人員
			//按鈕權限		
			PageUI.resize();	
			displayMessage();
			
		}
	}
}
</script>
</head>
<body>
<form name="form1" id="form1"  style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" >

<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>

	<tr>
		<td class='tbYellow'>
			承辦科別
		</td>
		<td class='tbYellow2'>
			<select id="CRED_DEPT" class="textBox2">
				<option value="">全部</option>
				<c:forEach items="${CRED_DEPT_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
        <td class='tbYellow'>
			到期月份
		</td>
		<td class='tbYellow2' colspan=3>
			<select id="END_DATE" class="textBox2">
				<c:forEach items="${END_DATE_LIST}" var="map">							
					<option value='${map.END_DATE}'>${map.END_DATE}</option>
				</c:forEach>
			</select>
		</td>
		
		
        <td class="tbYellow2" width="10%" align="center" rowspan='2'>
			<input type="button" class="button" id="BTN_QUERY" value="查詢" />					
		</td>
	</tr>
	<tr>
	    <td class='tbYellow' width='10%'>
			徵信人員
		</td>
		<td class='tbYellow2'>
			<%-- [20230324] 難字調整 --%>
			<select id="Q_ASSIGN_ID2" class="textBox2" alt="ch">
				<option value="">全部</option>
			</select>
		</td>
	    <td class='tbYellow' width='10%'>
			處理進度
		</td>
		<td class='tbYellow2'>
			<select id="PROC_STATUS" class="textBox2">
				<c:forEach items="${PROC_STATUS_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class='tbYellow' width='10%'>
			排序方式
		</td>
		<td class='tbYellow2'>
			<select id="SORT_KEY" class="textBox2">
				<c:forEach items="${SORT_KEY_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
	    <td class="tbYellow1" width="10%" align="center" colspan=7>
			<input type="button" class="button" id="BTN_SEND" value="聯徵送出" />	
            <input type="button" class="button" id="BTN_CREDIT" value="徵信作業" />	
            <input type="button" class="button" id="BTN_FIRSTCON" value="組長覆核" />	
            <input type="button" class="button" id="BTN_SECONDCON" value="主管覆核" />				
		</td>
	</tr>
</table>
<table id='grid' width='100%'></table>
</form>
</body>
</html>	