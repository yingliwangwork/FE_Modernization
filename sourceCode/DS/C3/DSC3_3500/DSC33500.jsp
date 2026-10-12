<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>

<!--
程式：DSC33500.jsp
功能：電匯通報作業
作者：余凱鈞
完成：2014/08/26

[20241104] 修改件 難字調整 吳志鴻
 -->
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<meta http-equiv="X-UA-Compatible" content="IE=5.5"> 

<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript' src="${htmlBase}/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="${htmlBase}/CM/js/RPTUtil.js"></script>		<%-- 匯出檔案用 --%>

<%-- [20241104] 難字調整 --%>
<style type="text/css">
	@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
	}
</style>

<script type='text/javascript'>
Event.observe(window, 'load', new DSC33500().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC33500(){
	var grid;
	var tmpMap;
	function initValidation(){
		//查詢用檢核
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	;
		valid1.define( "required" , { id: "TRANS_DATES", errMsg:'請輸入電匯日期(起)' } );
		valid1.define( "required" , { id: "TRANS_DATEE", errMsg:'請輸入電匯日期(迄)' } );
		valid1.define( "validate-ROCDate-Interval" , [{ id : "TRANS_DATES" },{ id : "TRANS_DATEE" }] );		
		valid1.define( "validate-ROCDate" , { id: "TRANS_DATES" } );
		valid1.define( "validate-ROCDate" , { id: "TRANS_DATEE" } );		
	}
		
	//建立 ajax request 物件
    var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC3_3500/');
	
	
	var buttons={
		//查詢
		doQuery : function(){
			valid1.reset();
			if(!valid1.validate()){
				return;
			}
			//權限調整:0800客服及服務中心僅能以貸款帳號或借款人id查詢
			if ("Y" == $F('LIMIT_ROLE')){
				if(!$F('LOAN_ID') && !$F('BORROW_ID')){ //2018-11-27兩欄位都空再跳訊息
				    alert("請輸入貸款帳號或借款人ID查詢！")
					return;
				}
			}
			var reqMap={};
			$w('TRANS_DATES TRANS_DATEE PROC_STATUS LOAN_ID BORROW_ID TRANS_AREA').each(function(ele){
				reqMap[ele] = $(ele).value || '';
			})
			tmpMap = reqMap;
			var PROC_STATUS = $('PROC_STATUS').value;		
			ajaxRequest.post( 'query', {reqMap: Object.toJSON(reqMap)}
				,function(resp){
					grid.load(resp.rtnList);
					$('BTN_DELETE').disabled = false;	
					
					if(PROC_STATUS == '99'){						
						$('BTN_DELETE').disabled = true;									
					}
				},function(resp){
					grid.load([]);	
				});
		},
		//新增
		doInsert : function(){
			var LP_JSON = {
					action :'${dispatcher}/DSC3_3501/prompt',
					'SOURCE' : 'I',
					'LOAN_ID' : $F('LOAN_ID')
				}
			CSRUtil.linkTo(LP_JSON , 'form');					
		},			
		//刪除
		doDelete : function(){
			valid1.reset();
			if(!valid1.validate()){
				return;
			}		
			var checkRecord = grid.getCheckedRecords();
			if(checkRecord.length == 0){
				alert('請至少選取一筆欲刪除資料');
				return;
			}
					
			var reqMap={};
			$w('TRANS_DATES TRANS_DATEE PROC_STATUS LOAN_ID BORROW_ID TRANS_AREA').each(function(ele){
				reqMap[ele] = $(ele).value || '';
			})
			
			for(key in reqMap){
				if(reqMap[key] != tmpMap[key]){
					alert('查詢條件已變動，請先重新查詢，再進行刪除');
					return;
				}			
			}
			
			ajaxRequest.post( 'delete', {reqList: Object.toJSON(checkRecord), reqMap: Object.toJSON(reqMap)}
				,function(resp){
					grid.load(resp.rtnList || []);
				});
		},
		//匯出
		doExport : function (){
			if( grid.getAllRecords().length == 0 ){
				alert('請先查詢再匯出');
				return;
			};			
			
			var reqMap={};
			$w('TRANS_DATES TRANS_DATEE PROC_STATUS LOAN_ID BORROW_ID TRANS_AREA').each(function(ele){
				reqMap[ele] = $(ele).value || '';
			})
			
			for(key in reqMap){
				if(reqMap[key] != tmpMap[key]){
					alert('查詢條件已變動，請先重新查詢，再進行匯出');
					return;
				}			
			}
			
			var exportParams = {
				querycondition : Object.toJSON(reqMap),
				gridJSON : grid.getXlsSettingJSON("電匯通報"),
				isExport : "Y"
			}
			
			RPTUtil.executeCreateXlsFile("<%=dispatcher%>/DSC3_3500/export", exportParams );
		}		
	}

	return {
			
		initApp : function(){

			PageUI.createPageWithAllBodySubElement('DSC33500', '繳款方式', '電匯通報作業');
			grid = new TableUI(
				{table: $("grid"), allSortable: true, overDiv:false, pageSize:20,
				autoCheckBox:{
				    text:'選取',
					type:'checkbox',
					isSelectAll:true,
                    genRule:function(record , value){ 
						return record.PROC_STATUS == '99' ? false : true; 
					} 				
				},				
				column:[
					{header:"資管轄區",key:"TRANS_AREA_NM"},
					{header:"輸入單位",key:"INPUT_DEPT_NM"},
					{header:"輸入人員",key:"INPUT_NM",attrs:{style:"font-family:'EUDC'"}},	<%-- [20241104] 難字調整: 輸入人員 --%>	
                    {header:"電匯日期",key:"TRANS_DATE",
					    render : function (rec , val){
							return Date.toROC(val || "");									
						}},	
				    {header:"狀態",key:"PROC_STATUS_NM"},							
					{header:"電匯帳號",key:"TRANS_NO_NM"},
					{header:"序號",key:"TRANS_SERNO"},
					{header:"貸款帳號",key:"LOAN_ID",
						render:function(rec,val){							
							if(val){
								//以貸款帳號超連結至DSC33501電匯通報作業明細
								var link = new Element( 'a' , { 'href' : "#" } ).update(val);
								var reqMap = {
									'TRANS_DATE' : rec.TRANS_DATE,
									'TRANS_NO' : rec.TRANS_NO,
									'TRANS_SERNO' : rec.TRANS_SERNO,
									'LOAN_ID' : rec.LOAN_ID,
									'PAY_TERM' : rec.PAY_TERM,
									'PAY_KIND' : rec.PAY_KIND																			
								}
								
								var LP_JSON = { 
									action :'${dispatcher}/DSC3_3501/prompt',
									'reqMap' : Object.toJSON(reqMap),				
									'SOURCE' : 'U'
								}; 		
								link.observe('click', function(){CSRUtil.linkTo(LP_JSON , 'form')});
								return link;
							}	
							return '';
						}},
					{header:"虛擬帳號",key:"ACCOUNT_NO"},						
					{header:"繳款期數",key:"PAY_TERM"},
					{header:"繳款別",key:"PAY_KIND_NM",
						render: function (rec,val){	
							if("3"==rec.PAY_KIND){
								if("5"==rec.PAYOFF_LIMIT){
									return "清償(不領)";
								}else if("6"==rec.PAYOFF_LIMIT){
									return "清償(要領)";
								}else {
									return "清償";							
								}
							}else{
								return val;
							}
					}},
					{header:"電匯金額",key:"TRANS_AMT", sortRule:"number",
						render: function (rec,val){	
							if(val ||val ===0){ 
								return MoneyFormat(val);
							}
							return "";
						}},
					{header:"備註",key:"TRANS_REMARK_NM"},						
					{header:"其他備註",key:"REMARK"}
				]
			});
			autoCreateDate(); 
			autoFormatToDate();	
			
			initValidation();
			
			$('BTN_QUERY').observe('click',buttons.doQuery);
			$('BTN_INSERT').observe('click',buttons.doInsert);				
			$('BTN_DELETE').observe('click',buttons.doDelete);		
			$('BTN_EXPORT').observe('click', buttons.doExport);			
			
			//若為資產管理科人員，電匯帳號下拉選單設定預設值
			//$('TRANS_NO').value = $F('def_TRANS_NO') || "";
			//若為行政中心單位，預設電匯帳號，並不得修改
			/*
			if($F('def_TRANS_NO')){
				$('TRANS_NO').value = $F('def_TRANS_NO') || "";
				$('TRANS_NO').disabled = true;
			}
			*/
			
			var LP_JSON = CSRUtil.isBackLink('form');			
			if(LP_JSON){ //由其他頁面，回上一頁
				buttons.doQuery();  
			}

			fix();	
			//初始頁面alert訊息用	
			displayMessage();
		}
	}
}
</script>
</head>
<body>
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
    <!--<input id="def_TRANS_NO" name="def_TRANS_NO" type="hidden" value="${TRANS_NO}"/>-->
	<input id="LIMIT_ROLE" name="LIMIT_ROLE" type="hidden" value="${LIMIT_ROLE}"/>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id='table1'>
		<tr>
			<td class = "tbYellow" width = "7%">電匯日期</td>
			<td class = "tbYellow2" width = "18%">
				<input type='text' id='TRANS_DATES' class="textBox2" name='TRANS_DATES' maxlength='7' size='8' value="${SYS_DATE}" datatype="ROCDate"/>
				~
				<input type='text' id='TRANS_DATEE' class="textBox2" name='TRANS_DATEE' maxlength='7' size='8' value="${SYS_DATE}" datatype="ROCDate"/>
			</td>		
			<!--<td class="tbYellow"  width = "7%">電匯帳號</td>
			<td class="tbYellow2" width = "15%">
				<select id="TRANS_NO" name='TRANS_NO'>
					<option value="">請選擇</option>
					<c:forEach var="map" items="${TRANS_NOList}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select> 
			</td>-->
			<td class="tbYellow"  width = "7%">資管轄區</td>
			<td class="tbYellow2" width = "18%">
				<select id="TRANS_AREA" name='TRANS_AREA'>
					<option value="">全部</option>
					<c:forEach var="map" items="${TRANS_AREAList}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select> 
			</td>				
			<td class="tbYellow" width = "7%">狀態</td>
			<td class="tbYellow2" width = "18%">
				<select id="PROC_STATUS" name='PROC_STATUS'>
					<option value="">全部</option>
					<c:forEach var="map" items="${PROC_STATUSList}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select> 
			</td>
			<td class="tbYellow2" width = "25%" align= "center" rowspan="2">
				<input id="BTN_QUERY" type="button" value="查詢" class="button" >	
				<input id="BTN_EXPORT" type="button" value="匯出" class="button" >	
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="7%">貸款帳號</td>		
			<td class="tbYellow2" width="18%">
				<input id="LOAN_ID" name="LOAN_ID" type='text' class= 'textBox2' size='12' maxlength='10' onblur="this.value = this.value.toUpperCase()"/>
			</td>	
			<td class="tbYellow" width="7%">借款人ID</td>		
			<td class="tbYellow2" width="18%">
				<input id="BORROW_ID" name="BORROW_ID" type='text' class= 'textBox2' size='12' maxlength='10' onblur="this.value = this.value.toUpperCase()"/>
			</td>				
			<td class="tbYellow2" width="25%" colspan="2"></td>		
		</tr>
		<tr>
			<td class="tbYellow2" colspan='9' align= "center">
				<input id="BTN_INSERT" type="button" value="新增通報資料" class="button" >					
				<input id="BTN_DELETE" type="button" value="刪除" class="button" >	
			</td>		
		</tr>
	</table>
	<table id = "grid" ></table>
</form>
</body>
</html>