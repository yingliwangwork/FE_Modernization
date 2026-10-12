<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC90300.jsp
作者：卓達瑋
功能：理財型展期派件作業 
完成：2013/06/06
2018-10-16申請書-理財展期屆期派件調整：消金審查三科(桃竹)裁撤，新增改派承辦科別功能
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

<script type="text/javascript" src="<%=htmlBase%>/CM/js/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
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

Event.observe(window, 'load', new DSC90300().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC90300(){
    var grid;
	//檢核
	var valid1;	
	//按鈕授權
		
	function buttonAuth() {
		var authButtons = { 
			B0067 : 'BTN_SEND'    <%--派件--%>
		};
		<dz:grantButtons FUNC_ID="DSC90300"  ignored='false'/>
		
	}
	//檢核欄位
	function initValidation(){
		valid1 = new Validation("form1", { focusOnError:true, immediate:false});				
		valid1.define('required' , [{ id : "ASSIGN_ID2" , errMsg:'請先選取新徵信人員，才能作業！'}] );
	}		

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC9_0300/" + actionName,
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
		//新承辦科別下拉選單連動新徵信人員下拉選單
		doChangeASSIGN2 :function(event){
		    rec_CRED_DEPT = event.target.value;
			if(rec_CRED_DEPT ==''){
				$('ASSIGN_ID2').options.length = 1;
				return;
			}
			ajaxPost( 'changeASSIGN', { CRED_DEPT : rec_CRED_DEPT}
				,function(resp){	    
		
				    var rec_list_A = resp.RLDS2_LIST;
				
					$('ASSIGN_ID2').options.length = 1;
					
					if(rec_list_A){
						 rec_list_A.each(
							function(data) {
								$('ASSIGN_ID2').add(new Option(data.NAME, data.ID));
							}		
						); 	
					}				
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
    	//派件
		dosend: function() {	
		    var data =grid.getCheckedRecord();	
			if(data.length==0){
			  alert("請先勾選欲派件資料，才能作業");
			  return;
			}
			if(!valid1.validate()){
				return; 
			} 
			
			ajaxPost( 'send', {'dataList' :Object.toJSON(data),'ASSIGN_ID2':$F('ASSIGN_ID2'),'NEW_CRED_DEPT':$F('NEW_CRED_DEPT'),'reqMap' :Object.toJSON(action.queryMap())}
				,function(resp){
			        grid.load(resp.rtnList);
				}
			);
		}
	};
	
	return {
		initApp : function() {

			PageUI.createPageWithAllBodySubElement( "DSC90300" , "覆審作業", "理財型展期派件作業" );
            grid = new TableUI(
				{table: $("grid"), pageSize: 20, allSortable:false,		
				autoCheckBox:{
				    isSelectAll:true,
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
                    {header:"借款人姓名",key:"BORROW_NAME",attrs:{style:"font-family:'EUDC'"}},	
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
													'LINK_FROM': "DSC90400", //若要改成DSC90300記得要調整DSA2_2200
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
					{header:"徵信派件日期",key:"ASSIGN_DATE2",
					    render: function (rec,val){
							if(rec.ROW_TYPE == '1'){
							    return Date.toROC(val || "");
							}else{
							    return "";
							}   							
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
					}
				]
			});
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			//畫面檢核
			initValidation();
			buttonAuth();
			// 監聽
			$("BTN_QUERY").observe('click', button.doQuery);
            $("BTN_SEND").observe('click', button.dosend);
			$("CRED_DEPT").observe('change',action.doChangeASSIGN);//連動徵信人員
			$("NEW_CRED_DEPT").observe('change',action.doChangeASSIGN2);//連動新徵信人員
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
		<td class='tbYellow' width='10%'>
			承辦科別
		</td>
		<td class='tbYellow2' width='20%'>
			<select id="CRED_DEPT" class="textBox2">
				<option value="">全部</option>
				<c:forEach items="${CRED_DEPT_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
        <td class='tbYellow' width='10%'>
			到期月份
		</td>
		<td class='tbYellow2' width='50%' colspan=3>
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
		<td class='tbYellow2' width='20%'>
			<%-- [20230324] 難字調整 --%>
			<select id="Q_ASSIGN_ID2" class="textBox2" alt="ch">
				<option value="">全部</option>
			</select>
		</td>
		<td class='tbYellow' width='10%'>
			處理進度
		</td>
		<td class='tbYellow2' width='20%'>
			<select id="PROC_STATUS" class="textBox2">
				<c:forEach items="${PROC_STATUS_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class='tbYellow' width='10%'>
			排序方式
		</td>
		<td class='tbYellow2' width='20%'>
			<select id="SORT_KEY" class="textBox2">
				<c:forEach items="${SORT_KEY_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	<tr> 
		<td class='tbYellow1'colspan='7' align="center">
            <input type="button" class="button" id="BTN_SEND" value="派件" />	
		</td>
	</tr>
	<tr>
		<td class='tbYellow' width='10%'>
			新承辦科別
		</td>
		<td class='tbYellow2' width='20%'>
			<select id="NEW_CRED_DEPT" class="textBox2">
				<option value="">全部</option>
				<c:forEach items="${CRED_DEPT_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>	
	    <td class='tbYellow' >
			新徵信人員
		</td>
		<td class='tbYellow2' colspan='4'>
			<%-- [20230324] 難字調整 --%>
			<select id="ASSIGN_ID2" class="textBox2" alt="ch">
				<option value="">請選擇</option>
			</select>
		</td>
	</tr>
</table>
<table id='grid' width='100%'></table>
</form>
</body>
</html>	