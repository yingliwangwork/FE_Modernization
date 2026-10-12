<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC50410.jsp
作者：余凱鈞
功能：收息調整輸入明細作業
完成：2013/09/30
 -->	

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript">
// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC50410().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC50410(){
	var grid;
	var valid;
	var reqMap = {};
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC5_0410/" + actionName,
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
	
	//按鈕授權
	function buttonAuth(){
		var authButtons = {		
			B0003:"btn_INSERT"
		};
		<dz:grantButtons FUNC_ID="DSC50410" />
	}
	
	//檢核
	function initValidation(){
		Validation.addAllThese([
			[ 'validateLOAN_ID', '貸款帳號長度輸入有誤!',
				function(v){
					return v.length == 10 ;
				}
			],
			[ 'validatePART_AMT', '部入金額輸入有誤!',
				function(v){
					return $('PART_AMT').getValue() > 0 ;
				}
			],
			[ 'validatePART_DAY', '變更繳息日輸入有誤!',
				function(v){
					return v >= 1 && v <= 31 ;
				}
			]
		])
		valid = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});	
	}
	
	function defineValid(type){
		if(type=='query'){
			valid.define( "validateLOAN_ID" , { id: "LOAN_ID" , errMsg:"請輸入正確的貸款帳號!" } );	
			valid.define( "required" , { id: "PAYDAY" , errMsg:"請輸入正確的計算日期!" } );	
			valid.define( "validate-ROCDate" , { id: "PAYDAY" , errMsg:"請輸入正確的計算日期!" } );			
		} else if(type=='query1'){
			valid.define( "validateLOAN_ID" , { id: "LOAN_ID" , errMsg:"請輸入正確的貸款帳號!" } );	
			valid.define( "required" , { id: "PAYDAY" , errMsg:"請輸入正確的計算日期!" } );	
			valid.define( "validate-ROCDate" , { id: "PAYDAY" , errMsg:"請輸入正確的計算日期!" } );	
			valid.define( "validatePART_DAY" , { id: "PART_DAY" , errMsg:"請輸入正確的變更繳息日!" } );	
		} else if(type=='query2'){
			valid.define( "validateLOAN_ID" , { id: "LOAN_ID" , errMsg:"請輸入正確的貸款帳號!" } );	
			valid.define( "required" , { id: "PAYDAY" , errMsg:"請輸入正確的計算日期!" } );	
			valid.define( "validate-ROCDate" , { id: "PAYDAY" , errMsg:"請輸入正確的計算日期!" } );	
			valid.define( "validatePART_AMT" , { id: "PART_AMT" , errMsg:"請輸入正確的部入金額!" } );				
		} else if(type=='insert'){
		
		    valid.define( "required" , { id: "PRINCIPAL" , errMsg:"請輸入本金調整金額!" } );
			valid.define( "required" , { id: "INTEREST" , errMsg:"請輸入利息調整金額!" } );	
			valid.define( "required" , { id: "DELAY_INT" , errMsg:"請輸入延滯息調整金額!" } );	
			valid.define( "required" , { id: "RENEGE" , errMsg:"請輸入違約金調整金額!" } );	
			valid.define( "required" , { id: "TAX" , errMsg:"請輸入代扣稅款調整金額!" } );				
		}
	}
	
	//繳款別連動
	function checkPAY_KIND(){	
		var PAY_KIND = $('PAY_KIND').value;
		if (PAY_KIND=="2" || PAY_KIND=="8"){
			$('PART_AMT').readOnly = false;
		}else{
			$('PART_AMT').readOnly = true;
			$('PART_AMT').value = '';
		}
		if (PAY_KIND=="1"){
			$('PART_DAY').readOnly = false;
		}else{
			$('PART_DAY').readOnly = true;
			$('PART_DAY').value = '';
		}	
	}
	
	//點選B區按鈕產生C區資料
	function getAreaC(record){
		$('table_C').show();
		/*$$('#table_C span').each(function(ele){
			ele.update(record[ele.id]);
		});	*/
		var LOAN_ID = record.LOAN_ID;
		if(LOAN_ID && 'X'==LOAN_ID.slice(-1)){
			$('areac').update('貸款帳號：'+LOAN_ID+'，期數：'+record.PAY_TERM+'，繳別：'+record.PAY_KIND+'，序號：'+record.SEQ_NO);
		} else {
			$('areac').update('姓名：'+record.BORROW_NAME+'，貸款帳號：'+LOAN_ID+'，期數：'+record.PAY_TERM+'，繳別：'+record.PAY_KIND+'，序號：'+record.SEQ_NO);
		}
		
		if(record.LOAN_STATUS > 22 || $('isROLE').value == 'Y'  ){
		   $('PRINCIPAL').disabled =false;
		
		}else{
		   $('PRINCIPAL').disabled =true;
		
		}
		
	}
	
	//計算D區總計
	function getSum(){
		var reqMapD = {}; //D區輸入欄位
		$('table_D').select('input[type!=button]').each(function(ele){						
			reqMapD[ele.id] = ele.getValue();
		});
	
		ajaxPost( 'calculate', {reqMap : Object.toJSON(reqMapD)}
			,function(resp){
				var SUM_AMT = CSRUtil.$fmt(resp.SUM_AMT,"#,###")
				$('SUM_AMT').update(SUM_AMT);
			}
		);

	}
	
	//檢核輸入欄位
	function checkField(button){
		var message='';
		if($('LOAN_ID').value!=reqMap.LOAN_ID ){
			message = message + ("貸款帳號【"+$('LOAN_ID').value+"】與先前查詢時的【"+reqMap.LOAN_ID+"】不同，\n");	
		}
		if( toY2K($('PAYDAY').value || '')!=reqMap.PAYDAY){
			message = message + ("計算日期【"+$('PAYDAY').value+"】與先前查詢時的【"+toROC(reqMap.PAYDAY || "")+"】不同，\n");	
		}
		
		if($('PAY_KIND').value!=reqMap.PAY_KIND){
			message = message + ("繳款別【"+$('PAY_KIND').value+"】與先前查詢時的【"+reqMap.PAY_KIND+"】不同，\n");		
		}
		if($('PART_AMT').getValue()!=reqMap.PART_AMT){
			message = message + ("部入金額【"+$('PART_AMT').getValue()+"】與先前查詢時的【"+reqMap.PART_AMT+"】不同，\n");	
		}
		if($('PART_DAY').value!=reqMap.PART_DAY){
			message = message + ("變更繳息日【"+$('PART_DAY').value+"】與先前查詢時的【"+reqMap.PART_DAY+"】不同，\n");		
		}
		if(message!=''){
			alert(message+"請重查資料後再"+button+"!");
			return true;
		}
		return false;	
	}
	
	//C區清空
	function clearC(){
		$$('#table_C span').each(function(ele){
			ele.update();
		});
		$('table_C').hide();
		
		//D區清空
		$('table_D').select('input[type!=button]').each(function(ele){						
			ele.value= 0;
		});
		
		$('ADJUST_REASON').vlaue = '1';	
		$('SUM_AMT').update(0);
	}
					
	var buttons = {	
		//查詢
		doQuery : function(){
			
			valid.reset();			
			valid.clear();
			
			var PAY_KIND = $('PAY_KIND').value; 
			
			//查詢檢核
			if(PAY_KIND=="2"){
				defineValid('query2');
			}else if(PAY_KIND=="1"){
				defineValid('query1');
			}else{
				defineValid('query');
			}
		
			if(!valid.validate()){
				return;
			}
			
			//A區查詢條件
			$('table_A').select('input[type!=button]','select').each(function(ele){						
				reqMap[ele.id] = ele.value;
			});
			
			reqMap.PAYDAY = toY2K($('PAYDAY').value || '');
			reqMap.PART_AMT = $('PART_AMT').getValue();
		
			ajaxPost( 'query', {reqMap : Object.toJSON(reqMap)}
				,function(resp){
					grid.load(resp.rtnList);
					clearC();
				}
			);			
		},	
		//新增
		doInsert : function(){
			valid.reset();			
			valid.clear();
			
			defineValid('insert');
			if(!valid.validate()){
				return;
			}
					
			var CheckedRecord = grid.getCheckedRecord(); //B區資料
			if(CheckedRecord.length==0){
				alert("請至少選取一筆資料!");
				 return;
			}
			
			//檢核查詢條件是否與先前相同
			if(checkField("新增")){
				return;			
			}
			
			var dataMap = {}; //D區資料
			$('table_D').select('input[type!=button]','select').each(function(ele){						
				dataMap[ele.id] = ele.getValue();
			});

			ajaxPost( 'insert', {dataMap : Object.toJSON(dataMap), dataList : Object.toJSON(CheckedRecord), reqMap : Object.toJSON(reqMap)}
				,function(resp){
					grid.load(resp.rtnList);
					$('table_C').hide();
					clearC();
				}
			);
				
		},
		//刪除
		doDelete : function(){	
			valid.reset();			
			valid.clear();
			
			var CheckedRecord = grid.getCheckedRecord(); //B區資料
			if(CheckedRecord.length==0){
				alert("請至少選取一筆資料!");
				 return;
			}
			
			if(!confirm('確定要刪除此利息調整之資料?')){
				return;
			}
			
			//檢核查詢條件是否與先前相同
			if(checkField("刪除")){
				return;			
			}
			
			ajaxPost( 'delete', {dataList : Object.toJSON(CheckedRecord), reqMap : Object.toJSON(reqMap)}
				,function(resp){
					grid.load(resp.rtnList);
					clearC();
				}
			);		
		},
		//覆核
		doConfirm : function(){
			valid.reset();			
			valid.clear();
			
			var CheckedRecord = grid.getCheckedRecord(); //B區資料
			if(CheckedRecord.length==0){
				alert("請至少選取一筆資料!");
				 return;
			}
			
			//檢核查詢條件是否與先前相同
			if(checkField("覆核")){
				return;			
			}
			
			ajaxPost( 'confirm', {dataList : Object.toJSON(CheckedRecord) , reqMap : Object.toJSON(reqMap)}
				,function(resp){
					grid.load(resp.rtnList);
					clearC();
				}
			);	

		},
		//清除
		doClear : function(){	
			valid.reset();			
			valid.clear();
			
			//A區清空
			$('table_A').select('input[type!=button]').each(function(ele){						
				ele.value= '';
			});
			$('PAY_KIND').value = 0;
			
			//B區清空
			grid.load();
			
			//C區清空
			clearC();
			
			//D區清空
			$('table_D').select('input[type!=button]').each(function(ele){						
				ele.value= 0;
			});
			
			$('ADJUST_REASON').vlaue = '1';
			
			$('SUM_AMT').update(0);
			
			$('PAYDAY').value = '${ROC_SYSDATE}';
		
		},
		//上一頁
		doBack : function(event){
			CSRUtil.linkBack() ; 
		}	
	};

	return{	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSC50410" , "利率調整" , "收息調整輸入明細" , 1);
			
			grid = new TableUI({
				table: $('grid'), pageSize: 20, allSortable: true, 	
				autoCheckBox:{
					text:'選取', 
					type:'radio',
					action:function(node, boxStatus, records ){
						getAreaC(records[0]);
					}
				},					
				column: [
					{header:"貸款帳號", key:'LOAN_ID'},
					
					{header:"期數", key:'PAY_TERM',
						render : function (rec , val){
						
							if("9"==rec.PAY_KIND){
								return "清償違約金";
							}else if("3"==rec.PAY_KIND || "8"==rec.PAY_KIND){
								return "清償";
							}else if("2"==rec.PAY_KIND){
								return "部入";
							}else if("1"==rec.PAY_KIND){
								return "變更應繳日";
						    }else{
						        return val ;
						    }
							
					}},
					{header:"應繳日", key:'NEXT_PAYDT',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					{header:"商品利率", key:'PROD_RATE',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : "" ; 
					}},
					{header:"適用利率", key:'RATE',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : "" ; 
					}},
					{header:"應繳金額", key:'DUTY_PAYMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"應攤本金", key:'PRINCIPAL', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},	
					{header:"利息", key:'INT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},	
					{header:"災戶攤繳", key:'VICTIM_INT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},	
					{header:"逾期息", key:'DELAY_INT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},	
					{header:"違約金", key:'RENEGE', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},	
					{header:"訴訟費", key:'LAWSUIT_FEE', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},	
					{header:"上期結餘", key:'LAST_BALANCE', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},	
					{header:"代扣稅款", key:'TAX', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}}					
				]	
			});
							
			initValidation();	
			
			buttonAuth();
						
			$('btn_QUERY').observe('click',buttons.doQuery);
			$('btn_INSERT').observe('click',buttons.doInsert);
			
			$('btn_CLEAR').observe('click',buttons.doClear);
			$('btn_BACK').observe('click',buttons.doBack);
			
			$('PAY_KIND').observe('change',checkPAY_KIND);
			$('PART_AMT').readOnly = true;
			$('PART_DAY').readOnly = true;		
			
			$('today').update(Date.toROC('${today}' || '')); //異動日期

			var getData = '${getData}';
			if(getData == 'Y'){
				var rtnList = <c:out value="${rtnList}" default="[]" escapeXml="false" />;	
				grid.load(rtnList);
				
				var queryMap = <c:out value="${queryMap}" default="{}" escapeXml="false" />;	
				
				$('LOAN_ID').value = queryMap.LOAN_ID || '';
				$('PAY_KIND').value = queryMap.PAY_KIND ;
				$('PAYDAY').value = toROC(queryMap.PAYDAY || '');
				$('PART_AMT').value = CSRUtil.$fmt(queryMap.PART_AMT,"#,###") || ''; 
				$('PART_DAY').value = queryMap.PART_DAY || '';	
				reqMap = queryMap;
		
			}	
			
			$('table_C').hide();
			
			$('PRINCIPAL').observe('blur',getSum);
			$('INTEREST').observe('blur',getSum);
			$('DELAY_INT').observe('blur',getSum);
			$('RENEGE').observe('blur',getSum);
			$('TAX').observe('blur',getSum);	
			
			$('isROLE').value = '${isROLE}';
			
			autoFormatToNumber();
			
			PageUI.resize();			
			displayMessage();			
		}
	};	
}
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
		<input id="isROLE"  type="hidden" name="isROLE"/>
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width= "8%">貸款帳號</td>
				<td class="tbYellow2" width= "10%">
					<input id="LOAN_ID" type="text" class="textBox2" size='13' maxlength="10" onblur="this.value = this.value.toUpperCase()" />
				</td>
				<td class="tbYellow" width= "8%">計算日期</td>
				<td class="tbYellow2" width="10%">
					<input id="PAYDAY" datatype="ROCdate" type="text" class="textBox2" size="8" maxlength="7"  value = '${ROC_SYSDATE}'/>
					<img src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('PAYDAY'))" />		
				</td>
				<td class="tbYellow" width= "8%">繳款別</td>
				<td class="tbYellow2" width= "10%">
					<select id="PAY_KIND" class="areaB">
					<c:forEach var="map" items="${PAY_KIND_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach></select>
				</td>
				<td class="tbYellow" width= "8%">部入金額</td>
				<td class="tbYellow2" width= "10%">
					<input id="PART_AMT" type="text" datatype="number" class="textBox2 validate-number" size='13' maxlength="11" />
				</td>
				<td class="tbYellow" width= "8%">變更繳息日</td>
				<td class="tbYellow2" width= "5%">
					<input id="PART_DAY" type="text" datatype="number" class="textBox2 validate-number" size='5' maxlength="2" />
				</td>
				<td class="tbYellow" width= "10%" align="center">				
					<input type="button" class="button" id="btn_QUERY" value="查詢"/>					
				</td>
			</tr>
			<tr>
				<td align="center" colspan='11'>				
					<input type="button" class="button" id="btn_INSERT" value="新增"/>	
				
					<input type="button" class="button" id="btn_CLEAR" value="清除"/>	
					<input type="button" class="button" id="btn_BACK" value="上一頁"/>						
				</td>			
			</tr>
		</table>
	<form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="grid" width="100%" class="grid" ></table>
		<table id="table_C" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<td class="tbYellow2" >
				<span id = "areac"></span>				
			</td>
		</table>
		<table id="table_D" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="30%">異動原因</td>
				<td class="tbYellow2" >
					<select id="ADJUST_REASON" class="areaB">
					<c:forEach var="map" items="${ADJUST_REASON_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach></select>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >本金調整金額</td>
				<td class="tbYellow2" >
					<input id="PRINCIPAL" type="text" datatype="number" class="textBox2 validate-number" size='11' maxlength="9"  value=0 disabled />
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >利息調整金額</td>
				<td class="tbYellow2" >
					<input id="INTEREST" type="text" datatype="number" class="textBox2 validate-number" size='11' maxlength="9"  value=0 />
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >延滯息調整金額</td>
				<td class="tbYellow2" >
					<input id="DELAY_INT" type="text" datatype="number" class="textBox2 validate-number" size='11' maxlength="9" value=0 />
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >違約金調整金額</td>
				<td class="tbYellow2" >
					<input id="RENEGE" type="text" datatype="number" class="textBox2 validate-number" size='11' maxlength="9" value=0 />
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >代扣稅款調整金額</td>
				<td class="tbYellow2" >
					<input id="TAX" type="text" datatype="number" class="textBox2 validate-number" size='11' maxlength="9" value=0 />
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >異動總金額</td>
				<td class="tbYellow2" >
					<span id="SUM_AMT">0</span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >異動人員</td>
				<td class="tbYellow2" >
					<span id="user">${user}</span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >異動日期</td>
				<td class="tbYellow2" >
					<span id="today"></span>
				</td>
			</tr>
		</table>
	</form>
</body>
</html>		