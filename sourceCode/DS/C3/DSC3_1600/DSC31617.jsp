<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程DSC31617.jsp
功能：異常入帳金額分配 
作者：溫子?
完成：2013/08/
      2018-03-12申請書-轉帳扣款收息作業風險檢核：異常入帳在入帳時檢核洗錢防制是否為制裁名單
      
[2021-12-01] 異常入帳檢核優化 by 君櫂:
 1. 目前只有電匯異常入帳的選取確認時檢核該筆是否已入帳過，也需要在異常入帳金額分配畫面再次檢核，避免同時多人針對同一筆帳都入成功。
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type='text/javascript'>
Event.observe(window, 'load', new DSC31617().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC31617(){
var grid;
var gridB;
var gridC;
var BillList;
var ISTIC="";
var PAY_TYPE="";
var dataListB=[];
var dataListC =[];

	function initValidation(){
		//查詢用檢核
		
		valid1 = new Validation("form", { focusOnError:true, immediate:false});		
		Validation.addAllThese( [
			[ 'PAY_AMT_Required', '繳票金額及現金不可同時為 0 或 負值，請輸入數值格式',
				function( v , elem ) {
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
                    if(checks){
						if(!v||v==0){
							return false;
						}
					    return  Validation.get('IsEmpty').test(v) || /^\d+$/.test(v.replace(/,/g,''));
					}
					return true;
				},
			]
		]);
	}
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_1617/" + actionName,
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
	var buttons={
	
		doCalculate : function(){

			ajaxPost( 'calculate', {BillList : '${BillList}' ,PayList:'${PayList}'}
				,function(resp){
					grid.load(resp.PayList);
					dataListB = resp.BillList;
					gridB.load(dataListB);
					$$("#grid input:checked[type = 'radio']").each(
						function(elem){					
							elem.setAttribute("checked", false);				
						}
					);
					$$("#gridB input:checked[type = 'checkbox']").each(
						function(elem){					
							elem.setAttribute("checked", false);				
						}
					);
					
					$('TOTAL_AMT').value = CSRUtil.$fmt(parseInt(resp.TOTAL_AMT),"#,###") ; 
				},function(resp){
					//grid.load([]);	
				}
			);
		}
		,doAssign : function(record){
											
			valid1.reset();			
			valid1.clear();
			
			//每次分配時，要將實繳金額清空			
			for(var i=0; i< dataListB.length ; i++){
				dataListB[i].TRADE_AMT=0;
				dataListB[i].preCheck="N";				
			}
			
			//檢核B區是否有資料
			if(dataListB.size()==0){
				alert("異常入帳金額分配無資料!")
				return;
			}

			ajaxPost( 'assign', {PayList : Object.toJSON(record), BillList : Object.toJSON(dataListB)}
				,function(resp){
					dataListB = resp.rtnList;
					gridB.load(dataListB, null, null, ["Y"]);
				}
			);
		
		}
		,doChkAssign : function(){
			
			if(!valid1.validate()){				
				return; 
			}
			var radios=grid.getCheckedRecord();
			var gridB_Confirm =gridB.getCheckedRecord();	
				
				if(radios.length==0){
					alert("請至少點選一筆資料");
					return;
				}
				if(gridB_Confirm.length==0){
					alert("請至少勾選一筆資料");
					return;
				} 
				ajaxPost( 'chkassign', {CheckMap : Object.toJSON(radios[0]), BillList : Object.toJSON(gridB_Confirm), dataListB : Object.toJSON(gridB.getAllRecords()),dataListC:Object.toJSON(dataListC)}

				,function(resp){

					var rtnList = resp.rtnList;
					dataListC=rtnList;
						
					gridC.load(dataListC);
					$('table_C').show();
					$('gridC').show();
					
					//重新顯示尚未分配之清單
					gridB.load(resp.rtnListB);
					dataListB= resp.rtnListB;
				});
		} 
		,doCancel :function(){
				
			//選取確認LIST清空
			dataListC = [];	
						
			//B區重新讀取初始接值之LIST
			dataListB= BillList;	
			gridB.load(BillList);
			
			gridC.load([]);
			$('table_C').hide();
			$('gridC').hide();			
			
		}
		,doBillIn :function(){
			
			//判斷C區是否有值
			if(!dataListC.size()>0){
				alert("請產生票據入帳試算結果後，再做入帳確認!");
				return;
			}
			
			//[2021-12-01] 異常入帳金額分配畫面再次檢核，避免同時多人針對同一筆帳都入成功
			var CheckMap =grid.getCheckedRecord();
			
			
			//傳入繳款相關資訊
			var payMap = grid.getAllRecords()[0];
			var PAY_INFO ={};
			PAY_INFO = {
				RELATION : [{
					BORROW_ID : payMap.BORROW_ID,
					BORROW_NAME : payMap.BORROW_NAME,
					PAY_RELATION : "O",
					OTHER_RELATION: "",
					PAY_REASON : ""
				}],			
				PAY_ID : payMap['PAY_ID'],
				COPR_CODE : payMap['COPR_CODE'],
				PAY_NAME : payMap['PAY_NAME'], 
				noWrite : 'Y' //無繳款人資訊，不需寫入繳款服務單 //2019-01-28：申請書 181128001539 - 繳款服務單新增檢核
			};
			ajaxPost( 'billin', {BillList : Object.toJSON(dataListC), PAY_TYPE : '${PAY_TYPE}',ISTIC : '${ISTIC}',TOTAL_AMT:$F('TOTAL_AMT'),SPEC:'1',PAY_INFO : Object.toJSON(PAY_INFO) , CheckMap : Object.toJSON(CheckMap) }
				,function(resp){
					if(resp.ERR_MSG){ //若有檢核出制裁名單，需連結至洗錢防制檢核紀錄填寫紀錄後才能掛人工暫收
						alert(resp.ERR_MSG);
						var parms = { 
							'LINK_TO' : resp.LINK_TO,
							'QUERY_ID' : resp.QUERY_ID,
							'CURRENT_DATE' : resp.CURRENT_DATE
						}; 		
						buttons.doPopup( parms );	
					} else {	
						if(resp.TIPS_MSG){
							alert(resp.TIPS_MSG); //2018-03-12提示：若繳款人為制裁名單，需提示(因無ID資訊無法填寫洗錢防制檢核紀錄，請確實申報，並與收費管理科聯繫)
						}					
						var LP_JSON = {	
							action : '<%=dispatcher%>/DSC3_1620/prompt',
							BillListStr : resp.BillListStr,
							PAY_TYPE : '${PAY_TYPE}',
							ISTIC : '${ISTIC}',
							INPUT_ID : resp.INPUT_ID,
							INPUT_DEPT : resp.INPUT_DEPT
						};
						CSRUtil.linkTo(LP_JSON , 'form');
					}
				}			
			);	
		
		}
		//POP UP 開啟新視窗
	  	,doPopup : function ( parms ) {	
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
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC31617', '繳款方式', '異常入帳金額分配 ');

					grid = new TableUI(
						{table: $("grid"), allSortable: false, pageSize: 20,
						autoCheckBox:{
							text:'選取',
							type:'radio',
							action:function(node, boxStatus, records ){
								if(!boxStatus) return; //檢核box狀態，避免連續點選，造成載入資料有問題					
								buttons.doAssign(records[0]);
							}
						
						},				
						column:[											
							{header:"貸款帳號",key:"LOAN_ID"},
							{header:"交易日期",key:"TRANS_DATE"},
							//{header:"交易時間",key:"TRANS_TIME"},
							{header:"序號",key:"SEQ_NO",
								render: function (rec,val){
									return val|| '－';
								}},
							{header:"帳號",key:"ACCOUNT",
								render: function (rec,val){
									return val|| '－';
								}},
							{header:"扣款金額",key:"FACE_AMT",sortRule:"number"},
							{header:"轉帳手續費",key:"HANDLE_FEE",sortRule:"number",
								render: function (rec,val){
									return val|| '－';
								}}
							
						]
					});
					gridB = new TableUI(
						{table: $("gridB"), allSortable: false, pageSize: 20,
						autoCheckBox:{
							text:'選取',
							type:'checkbox',
							valueKey: 'preCheck'
						},				
						column:[
							{header:"貸款帳號",key:"LOAN_ID"},				
							//{header:"繳款別",key:"PAY_KINDC"},
							{header:"期數",key:"PAY_TERM",					    
								render: function (rec,value){
									if("4"==rec.PAY_KIND){
										return "暫收款";
									}else if("3"==rec.PAY_KIND){
										return "清償";
									}else if("2"==rec.PAY_KIND){
										return "部入";
									}else if("1"==rec.PAY_KIND){
										return "變更應繳日";
									}else{
										return value;
									}
								}
							},
							{header:"應繳金額",key:"DUTY_PAYMT",sortRule:"number"},
							{header:"實繳金額",key:"TRADE_AMT"/*,
								render: function (rec,val){

										var input1 = new Element("input" , {type : 'TEXT',size:15,maxlength:7 , 'datatype':'number',className:'PAY_AMT_Required'} );/*'style':'text-align:right',  input做靠右*										input1.value=MoneyFormat(val)||0;
										input1.observe('blur', function(event){
										var tr=this.up('tr');
										var dataObj = tr.getAttribute("dataObj")|| gridB.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
										var new_value = event.target.value;
										dataObj.REAL_PAYMT=new_value.replace(/,/g,'');
										})			
									var span = new Element('span');
									span.insert(input1);
									return span;
								}*/
								, attrs: {align:"right"},
								render:function(rec,val){
									return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
								},  
								input:{type:'number' , size:10 , maxlength:10 , className : 'textBox2 AMT_Required validate-number'}       
							}/*,
							{header:"手續費筆數",key:"CHARGE_CNT",
								render: function (rec,val){
									if(rec.TYPE=='E'){
										return val;
									}else{
										var input1 = new Element("input" , {type : 'TEXT',size:5,maxlength:7 , 'datatype':'number'} );//'style':'text-align:right',  input做靠右
										input1.value=val||0;
										input1.observe('blur', function(event){
										var tr=this.up('tr');
										var new_value = event.target.value;
										var	 dataObj = tr.getAttribute("dataObj")|| gridB.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
										dataObj.CHARGE_CNT=new_value.replace(/,/g,'');

									})			
									var span = new Element('span');
									span.insert(input1);
									return span;
									}
								}
							}*/
							
						]
					});
					gridC = new TableUI(
						{table: $("gridC"), allSortable: false, pageSize: 20,
								
						column:[
							{header:"貸款帳號",key:"LOAN_ID"},				
							//{header:"繳款別",key:"PAY_KINDC"},
							{header:"期數",key:"PAY_TERM",					    
								render: function (rec,value){
									if("4"==rec.PAY_KIND){
										return "暫收款";
									}else if("3"==rec.PAY_KIND){
										return "清償";
									}else if("2"==rec.PAY_KIND){
										return "部入";
									}else if("1"==rec.PAY_KIND){
										return "變更應繳日";
									}else{
										return value;
									}
								}
							},
							{header:"應繳金額",key:"DUTY_PAYMT",sortRule:"number"},
							{header:"實繳金額",key:"REAL_PAYMT",sortRule:"number"},
							{header:"暫應收款",key:"BALC_AMT",
								render: function (rec,val){
									return (val||val===0) ? "<font color='red'>"+CSRUtil.$fmt(val,"#,###")+"</font>" : 0 ; 
								}},
							{header:"繳款序號",key:"SEQ_NO",
								render: function (rec,val){
									return val|| '－';
								}},
							{header:"繳款貸款帳號",key:"PAY_LOANID"},
							{header:"繳款金額",key:"REAL_PAYMT",sortRule:"number"}/*,
							{header:"手續費筆數",key:"CHARGE_CNT",
								render: function (rec,val){
									return val||0;
								}
							}*/
							
						]
					});
				initValidation();
				//先把畫面區塊都調整到位再顯示訊息
				$('btn_CHKASSIGN').observe('click',buttons.doChkAssign);
				$('btn_CANCEL').observe('click',buttons.doCancel);
				$('btn_BILLIN').observe('click',buttons.doBillIn);
				
				$('btn_return').observe('click', function(){
					CSRUtil.linkBack();
				});
				
				<c:choose>
					<c:when test='${not empty BillList}'>
					   BillList = ${BillList};
					</c:when>
					<c:otherwise>
					   BillList = [];
					</c:otherwise>
				</c:choose>	
				
				$('table_C').hide();
				$('gridC').hide();
	
				ISTIC = '${ISTIC}';
				PAY_TYPE = '${PAY_TYPE}';
				
				buttons.doCalculate();
				fix();	
				//初始頁面alert訊息用	
				displayMessage();
			}
	}
}
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
    <form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id='table_A'>
			<input id="ISTIC" type="hidden" value='${ISTIC}'>
			<tr>
				<td class="tbYellow0" colspan='2'><B>繳款金額清單</B>
					<input id="btn_return" type="button" class="button" value="回上一頁" />	
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%">合計</td>		
				<td class="tbYellow2" width="90%">
					<input id="TOTAL_AMT" type="text" datatype="number" class="textBox2 validate-number" size='15' maxlength="11" value='0' readOnly/>
				</td>	
			</tr>	
		</table>	
		<table id = "grid" ></table>
		<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2' id='table_B'>
			<tr>
				
				<td class="tbYellow0"><B>金額分配設定</B>
					<input type="button" class="button" id="btn_CHKASSIGN" value="選取確認"/>				
				</td>

			</tr>
		</table>
		<table id = "gridB" ></table>
		<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2' id='table_C'>
			<tr>
				<td class="tbYellow0"><B>帳號沖列試算結果</B>
					<input type="button" class="button" id="btn_BILLIN" value="入帳確認"/>	
					<input type="button" class="button" id="btn_CANCEL" value="取消選取確認"/>				
				</td>

			</tr>
		</table>
		<table id = "gridC" ></table>
	</form>
</body>
</html>