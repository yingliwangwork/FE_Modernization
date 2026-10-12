<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<meta http-equiv="X-UA-Compatible" content="IE=5.5"> 

<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSC33300.jsp
功能：轉帳異常入帳 
作者：溫子恆
完成：2013/09/
      2018-03-12申請書-轉帳扣款收息作業風險檢核：異常入帳在輸入時（掛人工暫收）檢核洗錢防制是否為制裁名單，若是試算分配則由DSC31617檢核
      2019-01-10:申請書(180927000795):ATM異常入帳畫面調整 : 新增全選並連動計算合計
	  [20241104] 修改件 難字調整 吳志鴻
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>

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
Event.observe(window, 'load', new DSC33300().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC33300(){
var grid;
var grid2;
var grid3;
var checkdata=[];
var tempMap={};
function initValidation(){
		//查詢用檢核
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	
		valid1.define('required' , [{ id : "TRANS_STATUS" , errMsg:'請選擇狀態!!'}] );
		//valid1.define( "validate-ROCDate" , { id: "TRANS_DATE", errMsg:'請輸入有效日期格式!!'} );
		valid1.define( "required" , { id: "TRANS_YM", errMsg:'請輸入轉帳年月!!'} );
		valid1.define( "required" , { id: "TRANS_BANK", errMsg:'請選擇轉帳銀行!!'} );
		valid1.define( "required" , { id: "TRANS_GROUP", errMsg:'請選擇轉帳組別!!'} );
		valid2 = new Validation("form", { focusOnError:true, immediate:false});		
		Validation.addAllThese( [
			[ 'PAY_AMT_Required', '請輸入數值格式',
				function( v , elem ) {
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
                    if(checks){
					    return Validation.get('IsEmpty').test(v) || /^[+-]?[\d\,]*\.?\d*([eE][+-]?\d+)?$/.test(v);
					}
					return true;
				}
			]
		]);
	}
//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_3300/" + actionName,
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
	function doCalTotal ( node , boxStatus , records){
		var PAYOFF_LIMIT=records[0].PAYOFF_LIMIT;
		var LOAN_ID=records[0].LOAN_ID;
		if(PAYOFF_LIMIT==1){
		    alert(LOAN_ID+"--屬法務之清償控管");
		}else if(PAYOFF_LIMIT==2){
		    alert(LOAN_ID+"--屬催收之清償控管");
		}else if(PAYOFF_LIMIT==3){
		    alert(LOAN_ID+"--屬放款之清償控管");
		}
		
		var chkList = grid3.getCheckedRecord();
		var allList = grid3.getAllRecords();
		
		ajaxPost( 'total', {'chkList':Object.toJSON(chkList),'allList':Object.toJSON(allList)},
			function(resp){
				grid3.load(resp.allList || [], resp.totalList || [], null, ["Y"]);
			}
		);	
	}
	var buttons={
	
		doQuery : function(){
			if(!valid1.validate()){
				return;
			}
			var qryMap={};
			$$('#table1 select, input[type!=button]').each(function(ele){
				qryMap[ele.id]=ele.value;
			})

			ajaxPost( 'query', {qryMap : Object.toJSON(qryMap)}
				,function(resp){
					grid.load(resp.dataList);
				},function(resp){
					grid.load([]);	
				}
			);
		}
		//輸入
		,doEnter: function(data) {	
			if(!valid1.validate()){				
				return; 
			}
			var qryMap={};
			$$('#table1 select, input[type!=button]').each(function(ele){
				qryMap[ele.id]=ele.value;
			})
			//傳入繳款相關資訊
			var PAY_INFO ={};
			PAY_INFO = {
				RELATION : [{
					BORROW_ID : data.BORROW_ID,
					BORROW_NAME : data.BORROW_NAME,
					PAY_RELATION : "O",
					OTHER_RELATION: "",
					PAY_REASON : ""
				}],			
				PAY_ID : data['PAY_ID'],
				COPR_CODE : '0', //因未留存委託人之COPR_CODE，故預設0
				PAY_NAME : data['PAY_NAME'], 
				noWrite : 'Y' //無繳款人資訊，不需寫入繳款服務單 //2019-01-28：申請書 181128001539 - 繳款服務單新增檢核
			};
			ajaxPost( 'enter', {'accessData' :Object.toJSON(data), 'qryMap' :Object.toJSON(qryMap),PAY_INFO : Object.toJSON(PAY_INFO)}
				,function(resp){
					if(resp.ERR_MSG){ //若有檢核出制裁名單，需連結至洗錢防制檢核紀錄填寫紀錄後才能掛人工暫收
						alert(resp.ERR_MSG);
						var parms = {//180917:申請書(180828001571):新增可疑交易檢核 
							'LINK_TO' : resp.LINK_TO,
							'QUERY_ID' : resp.QUERY_ID,
							'CURRENT_DATE' : resp.CURRENT_DATE
						}; 			
						buttons.doPopup( parms );	
					} else {			
						grid.load(resp.dataList || []);
					}				
				}
				
			);
		}
		,doConfirm :function(record){//選取確認
			
			ajaxPost( 'confirm', {confirmData :Object.toJSON(record),TRANS_YM:$F('TRANS_YM')}
					,function(resp){
						grid2.load(resp.loanList);
					}
					,function(resp){
						 grid2.load([]);
					});
			//畫面區塊顯示控制
			$('grid2').show();
			$('table_a').show();
			$('grid3').hide();
			$('table_b').hide();
		}
		,doCal : function(){//試算
			if(!valid2.validate()){				
					return; 
				}
			var calculatedata =grid2.getCheckedRecord();	
			var qryData=grid2.getAllRecords();
				if(calculatedata.length==0){
				  alert("請至少勾選一筆資料");
				  return;
				}
			
			ajaxPost( 'calculate', {calculatedata :Object.toJSON(calculatedata),'allList':Object.toJSON(qryData)}
					,function(resp){
						
						//grid3.load(resp.calList);
						grid3.load(resp.calList || [], resp.totalList || [], null, ["Y"]);
					}
					,function(resp){
						 grid3.load([]);
					}
					
				);
			//畫面區塊顯示控制
			$('grid3').show();
			$('table_b').show();
	
		}
		,doAssign : function(){		
		var PayList =grid.getCheckedRecord();	
			if(PayList.length==0){
			  alert("請至少勾選一筆資料");
			  return;
			}
			
			var recs = grid3.getAllRecords();
				if(recs.length==0){
					alert("請先進行試算!")
					return;
				}
			
			var BillList = grid3.getCheckedRecord();	
				if(BillList.length==0){
					alert("請於試算清單中至少勾選一筆資料!");
					return;
				}
		
		    //異常入帳金額分配畫面
			var actionUrl='<%=dispatcher%>/DSC3_1617/prompt';	
			var payType=BillList[0].PAY_TYPE;					
			ajaxPost(  
				'assign' ,
				{'BillListStr': Object.toJSON(BillList),'PayListStr':Object.toJSON(PayList),'PAY_TYPE':payType,'ISTIC':'E'},
				function(resp){	
					var BillListStr=resp.BillListStr;
					var PayListStr=resp.PayListStr;							
					var billMap={
						'ISTIC' :'E',
						'BillListStr' : BillListStr,
						'PayListStr':PayListStr,
						'PAY_TYPE': payType,
						'TRANS_STATUS':$F('TRANS_STATUS'),
						'TRANS_BANK':$F('TRANS_BANK'),
						'TRANS_GROUP':$F('TRANS_GROUP')						
					}
					var displayMap={
						ListB:Object.toJSON(grid.getAllRecords())
					}
					var LP_JSON = {
						action :actionUrl,
						LINK_TYPE : "IN",   //連結型態 = IN:內部
						LINK_FROM : "DSC3_3300", //原始連結畫面
						billMap   : billMap,
						displayMap: displayMap
					}
					//alert("billMap.BillListStr:"+billMap.BillListStr);									
					//return;
					CSRUtil.linkTo(LP_JSON , 'form');	
				},
				function(resp){
					//grid2.load([]);
					//$('table_D').hide();
				}
			);
	
		},
		//POP UP 開啟新視窗
	  	doPopup : function ( parms ) {				
			var LINK_TO = parms.LINK_TO;
	  		if('AIL0_1300'==LINK_TO){
	  			//190211 禹含(內部申請書190212000817)：AIL01300初始查詢條件檢核調整(需傳入查詢區間)
	  			parms.QUERY_START_DATE = parms.CURRENT_DATE;
	  			parms.QUERY_END_DATE = parms.CURRENT_DATE;
	  			
				popupWin.popup({
					'src': '/AIWeb/servlet/HttpDispatcher/AIL0_1300/query',
					'parameters' :  {
						'dataObj' : Object.toJSON(parms)  //配合壽五科 洗錢防制檢核紀錄覆核及盡職/加強審查連結調整=>導頁參數調整
					}
				});
			}else if('AIL1_1000'==LINK_TO){//180917:申請書(180828001571):新增可疑交易檢核
				popupWin.popup({
					'src': '/AIWeb/servlet/HttpDispatcher/AIL1_1000/query',
					'parameters' :  {
						'QUR_ID': parms.QUERY_ID,//客戶ID/繳款人ID 
						'QUR_DATE_STR':parms.CURRENT_DATE,
						'QUR_DATE_END':parms.CURRENT_DATE,
						'COUNT':'0',
						'PAGE':'0',
						'TotalPage':'0'
					}
				});
			}
	  	}
	}
return {
			
		initApp : function(){
			<c:forEach var="map" items="${PAY_KIND_MAP}">
				tempMap["${map.key}"]="${map.value}";
			</c:forEach>
			PageUI.createPageWithAllBodySubElement('DSC33300', '繳款方式', '轉帳異常入帳');
			grid = new TableUI(
				{table: $("grid"), allSortable: false,overDiv:false,
				autoCheckBox:{
				    text:'選取',
					type:'radio',
					action:function(node, boxStatus, records ){
						if(!boxStatus) return;//檢核box狀態，避免連續點選，造成載入資料有問題
						buttons.doConfirm(records[0]);
					},
					genRule:function(record,value){
					    return  !record.ACNT_CODE == '1';	
					}
				
				},				
				column:[
                    {header:"貸款帳號",key:"LOAN_ID"},				
					{header:"借款人ID<br>借款人姓名",key:"BORROW_ID", attrs:{style:"font-family:'EUDC'"},  <%-- [20241104] 難字調整: 借款人姓名 --%>
					    render: function(record, value) {
                            var BORROW_NAME = record.BORROW_NAME;
	   					    if(value){
							   return "<span class = 'textRed'>"+value +'<br>'+(BORROW_NAME || '')+"</span>";
						    }
                            return "<span class = 'textRed'>"+(BORROW_NAME || '')+"</span>"; 
                        }
					},
					{header:"繳次",key:"PAY_TERM"},
					{header:"實繳金額",key:"DEDUCT_AMT",
					    render: function (rec,val){
							return MoneyFormat(val) || '';
						}
					},
					{header:"扣帳日期",key:"DEDUCT_DATE",
						render : function(rec,val){
							return val || "";
						}
					},
					{header:"批次處理狀態",key:"ACNT_CSTATUS",
						render :function(rec,val){
							if("25" == rec.ACNT_STATUS) {
								var link = new Element('a',{ href : "#"}).update(val);
									link.observe('click',function(event){						
										var url = "/AIWeb/servlet/HttpDispatcher/AIL0_1300/prompt";												
										window.open(url, "DSC3_3100", "top=250, left=250, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=900, height=600");	
									});
								return link;
							}
							return val;
						}										
					},
					{header:"入帳控制",key:"CACNT_CSTATUS"},			
					{header:"人工暫收",key:"BALC_MEMO",
						input:{type:'TEXT', size:20, maxlength:30}								
					},                      
					{header: "",key: "upd",sortable:false,
						input:{type:'button', text:'輸入',
							genRule:function(record , value){
								return record.ACNT_CODE == '1' ? false : true; 
							},
                            action:function( node , dataObj , textDiv, isOnChange ){ 
								buttons.doEnter(dataObj[0]);
							}			
						}
					}
				]
			});
			grid2 = new TableUI(
				{table: $("grid2"), allSortable: false, pageSize: 20,//overDiv:false,
				autoCheckBox:{
				    text:'選取',
					type:'checkbox'
				},				
				column:[
                    {header:"序號",key:"SEQ_NO"},
                    {header:"借款人ID",key:"BORROW_ID"},
                    {header:"借款人姓名",key:"BORROW_NAME"},	
                    {header:"貸款帳號",key:"LOAN_ID"},					
					{header:"繳款種類",key:"PAY_KIND",
					    input:{
						    type:'select',
							opts:tempMap
						}				
					},	
					{header:"轉帳日",key:"PAY_DATE",
					    render : function (rec , val){
							//return val || "";	
							return Date.toROC(val || "");								
						}
					},
					{header:"部入金額或新繳款日或暫收款金額",key:"PAY_AMT",input:{ className : 'PAY_AMT_Required' ,type:'number'}
					    ,render : function (rec , val){
							return CSRUtil.$fmt(val||0,"#,##0.###");;									
						}
					},
					{header:"擔保品地址",key:"GAGE_ADDR", input:{type:'text',size:50}}			
				]
			});
			grid3 = new TableUI(
				{table: $("grid3"), allSortable: false, pageSize: 20,overDiv:false,
				autoCheckBox:{
				    text:'選取',
					type:'checkbox',
					valueKey: 'preCheck',
					isSelectAll:doCalTotal,	//190110:新增全選 //190110:調整全選也會連動合計
					action: doCalTotal 
				},				
				column:[
                    {header:"貸款帳號",key:"LOAN_ID"},
                    {header:"期數",key:"PAY_TERM"},
                    {header:"應繳日",key:"NEXT_PAYDT",
					    render : function (rec , val){
							return Date.toROC(val || "");									
						}
					},	
                    {header:"實繳日",key:"PAY_DATE",
					    render : function (rec , val){
							return Date.toROC(val || "");									
						}
					},					
					{header:"應繳金額",key:"DUTY_PAYMT",renderInCount:true,
					    render: function (rec,val){
							if(val ||val ===0){ 
								return MoneyFormat(val);
							}
							return "";
						}
					},	
					{header:"適用利率",key:"RATE_VAL",renderInCount:true,
					    render: function (rec,val){
							if(val ||val ===0){ 
								return MoneyFormat(val);
							}
							return "";
						}
					},
					{header:"應攤本金",key:"PRINCIPAL",renderInCount:true,
					    render: function (rec,val){
							if(val ||val ===0){ 
								return MoneyFormat(val);
							}
							return "";
						}
					},
					{header:"利息",key:"INTEREST",renderInCount:true,
					    /*render: function (rec,val){
							if(val ||val ===0){ 
								return MoneyFormat(val);
							}
							return "";
						}*/
					    render: function (rec,val){					    	
							if(val ||val ===0){ 
								//利息欄位=rec.INTEREST+rec.RETAIN_INT
								val=val+rec.RETAIN_INT||0;
								return MoneyFormat(val);
							}
							return "0";
						}						
					},
					{header:"逾期息",key:"DELAY_INT",renderInCount:true,
					    render: function (rec,val){
							if(val ||val ===0){ 
								return MoneyFormat(val);
							}
							return "";
						}
					},
					{header:"違約金",key:"RENEGE",renderInCount:true,
					    render: function (rec,val){
							if(val ||val ===0){ 
								return MoneyFormat(val);
							}
							return "";
						}
					},
					{header:"管理費",key:"LAWSUIT_FEE",renderInCount:true,
					    render: function (rec,val){
							if(val ||val ===0){ 
								return MoneyFormat(val);
							}
							return "";
						}
					},
					{header:"上期結餘",key:"LAST_BALANCE",renderInCount:true,
					    render: function (rec,val){
							if(val ||val ===0){ 
								return MoneyFormat(val);
							}
							return "";
						}
					},
					{header:"代扣稅款",key:"TAX",renderInCount:true,
					    render: function (rec,val){
							if(val||val ===0){ 
								return MoneyFormat(val);
							}
							return "";
						}
					}	
				]
			});
			initValidation();
			//先把畫面區塊都調整到位再顯示訊息
			$('BTN_QUERY').observe('click',buttons.doQuery);
			//$('BTN_CONFIRM').observe('click',buttons.doConfirm);
			$('BTN_CAL').observe('click',buttons.doCal);
			$('BTN_ASSIGN').observe('click',buttons.doAssign);
			$('TRANS_STATUS').value='1';
			$('TRANS_BANK').value='1';
			$('TRANS_GROUP').value='1';
			
			var LP_JSON = CSRUtil.isBackLink('form');
			
			if(LP_JSON){	//由其他頁面，回上一頁
				var displayMap=LP_JSON.displayMap;
				var ListB=displayMap.ListB.evalJSON()||[];
				var billMap=LP_JSON.billMap;	
				//載入查詢條件
				$('TRANS_STATUS').value=billMap.TRANS_STATUS;
				$('TRANS_BANK').value=billMap.TRANS_BANK;
				$('TRANS_GROUP').value=billMap.TRANS_GROUP;
				//載入查詢結果
				grid.load(ListB);
			}
			
			//畫面區塊顯示控制
			$('grid2').hide();			
			$('table_a').hide();
			$('grid3').hide();
			$('table_b').hide();
			
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
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id='table1'>
	<tr>
		<td class="tbYellow"  width='10%'>轉帳年月</td>
			<td class="tbYellow2"  >
			<input id="TRANS_YM"  type="text" class="textBox2 " name="TRANS_YM" value='${TRANS_YM}'  maxlength="5"/>
			
		<td class="tbYellow"  width='10%'>狀態</td>
		<td class="tbYellow2" >
			<select id="TRANS_STATUS">
					<option value="">請選擇</option>
						<c:forEach var="map" items="${TRANS_STATUS_List}">
								<option value="${map.key}">${map.value}</option>
						</c:forEach>
			</select> 
		</td>
		<td class="tbYellow2" width='40%' rowspan='2'>
			<input id="BTN_QUERY" type="button" value="查詢" class="button" >	
		</td>
		</tr>
		<tr>
		<td class="tbYellow"  width='10%'>轉帳銀行</td>
		<td class="tbYellow2" >
			<select id="TRANS_BANK">
					<option value="">請選擇</option>
						<c:forEach var="map" items="${TRANS_BANK_List}">
								<option value="${map.key}">${map.value}</option>
						</c:forEach>
			</select> 
		</td>
		<td class="tbYellow"  width='10%'>轉帳組別</td>
		<td class="tbYellow2" >
			<select id="TRANS_GROUP">
					<option value="">請選擇</option>
						<c:forEach var="map" items="${TRANS_GROUP_List}">
								<option value="${map.key}">${map.value}</option>
						</c:forEach>
			</select> 
		</td>
		</tr>
	</table>
	<table id = "grid" ></table>
	
	<table id = "grid2" ></table>
	<table id="table_a" width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
    <tr>
		<td class="tbYellow2">
			<input type="button" class="button" id="BTN_CAL" value="異常入帳試算"/>				
		</td>

	</tr>
	</table>
	<table id='grid3' width="100%"></table>
	<table id="table_b" width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
    <tr>
		<td class="tbYellow2">
			<input type="button" class="button" id="BTN_ASSIGN" value="金額分配"/>				
		</td>

	</tr>
	</table>
</form>
</body>
</html>