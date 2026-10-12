<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSC33100.jsp
功能：劃撥異常入帳 
作者：溫子恆
完成：2013/06/
      2018-03-12申請書 轉帳扣款收息作業風險檢核：異常入帳在輸入時（掛人工暫收）檢核洗錢防制是否為制裁名單，若是試算分配則由DSC31617檢核
	  2018-11-13申請書 資管電匯入帳調整:查詢條件及清單顯示調整
	  [20241104] 修改件 難字調整 吳志鴻
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
Event.observe(window, 'load', new DSC33100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC33100(){
var grid;
var grid2;
var grid3;
var tempMap={};
var PayKindOpts;
var PayKindList;
var REAL_PAYMT_rc;//劃撥金額
	function initValidation(){
		//查詢用檢核
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	
		valid1.define('required' , [{ id : "TRANS_STATUS" , errMsg:'請選擇狀態!!'}] );
		valid1.define( "validate-ROCDate" , { id: "TRANS_DATE", errMsg:'請輸入有效日期格式!!'} );
		valid1.define( "required" , { id: "TRANS_DATE", errMsg:'請輸入劃播日期!!'} );
		
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
	var Gridlist = [
		[
			{header:"貸款帳號",key:"LOAN_ID"},	//增加貸款帳號、借款人、資管轄區和資管人員顯示			
			{header:"借款人ID<br>借款人姓名",key:"BORROW_ID", attrs:{style:"font-family:'EUDC'"},    <%-- [20241104] 難字調整: 借款人姓名 --%>
			    render: function(record, value) {
                          var BORROW_NAME = record.BORROW_NAME;
  					    if(value){
					   return "<span class = 'textRed'>"+value +'<br>'+(BORROW_NAME || '')+"</span>";
				    }
                          return "<span class = 'textRed'>"+(BORROW_NAME || '')+"</span>"; 
                      }
			},	
			{header:"劃撥金額",key:"DEDUCT_AMT",
			    render: function (rec,val){
					return MoneyFormat(val) || '';
				}
			},
			{header:"期數",key:"PAY_TERM"},
			{header:"交易代號",key:"TRANS_CODE"},
			{header:"實繳日",key:"TRANS_DATE",
				render : function (rec , val){
					return Date.toROC(val || "");									
				}},			
			{header:"錯帳之劃撥日期",key:"PRE_DATE"},
			{header:"批次處理狀態",key:"TRANS_CSTATUS"
					,render :function(rec,val){
						if("25" == rec.TRANS_STATUS) {
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
			{header:"入帳控制",key:"ACNT_CSTATUS"},
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
		],
		[
			{header:"貸款帳號", key:'LOAN_ID'},
			/*{header:"電匯帳號", key:'TRANS_NO'},*/
			{header:"借款人ID<br>借款人姓名",key:"BORROW_ID",
			    render: function(record, value) {
                          var BORROW_NAME = record.BORROW_NAME;
  					    if(value){
					   return "<span class = 'textRed'>"+value +'<br>'+(BORROW_NAME || '')+"</span>";
				    }
                          return "<span class = 'textRed'>"+(BORROW_NAME || '')+"</span>"; 
                      }
			},	
			{header:"虛擬帳號", key:'MEMO1_ACCOUNT_IN'},
			{header:"電匯日期", key:'TRANS_DATE',
				render : function (rec , val){
					return Date.toROC(val || "");									
				}
			},
			{header:"交易序號", key:'TRANS_SERNO'},
			{header:"電匯金額", key:'DEDUCT_AMT', sortRule: "number"},
			{header:"匯款人", key:'TRANS_NAME'},
			{header:"入帳控制",key:"TRANS_CSTATUS"
					,render :function(rec,val){
						if("25" == rec.TRANS_STATUS) {
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
			},
			{header:"收息單位",key:"DEPT_NAME",sortable:true},
			{header:"資管轄區", key:'TRANS_AREA_NM'},
			{header:"資管人員", key:'EMP_NAME'}
		]		
	];
	//產生不同樣式的表格
	function gridtable(i){		
		grid = new TableUI(
			{table: $("grid"), allSortable: false, overDiv:false,
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
			column:Gridlist[i]
		});
	}	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_3100/" + actionName,
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
var actions = {
		 //產生TableUI中裡面的input欄位(B區)
		createInputElement : function(colkey,value,type,col_nm,PAY_KIND){
			var theID = colkey;
			if(type == 'number'){ //部入金額或新繳款日或暫收款金額
				var input = new Element('input', 
					{className:'textBox2 PAY_AMT_Required', id:theID, type:'text', datatype:'number', pattern:'#,###', size:'15', maxLength:'15', fieldName:col_nm }
				)
				.setValue( value || value===0 ? CSRUtil.$fmt(value,'#,###') : '')
				.observe('blur' , function(event){						
					var dataObj = grid2.isNew ? grid2.getDataObj(this) : this.up('tr').dataObj;
					var new_value = this.value;
					dataObj[colkey] = new_value.replace(/,/g,'');
				});
				
				//若欄位ID為PAY_AMT，則初始狀態為不可修改
				if(input.id="PAY_AMT" && (PAY_KIND=="0" || PAY_KIND=="3") ){
					value=0;
					input.disable();
				}
				
				return input; 
			}else{ //貸款帳號(新增)
				var input = new Element('input', 
					{className:'textBox2', id:theID, type:'text', size:'12', maxLength:'10', fieldName:col_nm }
				)
				.observe('change' , function(event){						
					var dataObj = grid2.isNew ? grid2.getDataObj(this) : this.up('tr').dataObj;
					var new_value = this.value;
					new_value = (new_value+"").toUpperCase(); //轉大寫
					input.value = new_value;
					dataObj[colkey] = new_value;
				});
				return input; 
			}
		},
		controlPayAMT : function(tr,dataObj){
			if(grid2.isNew){
				var tds = grid2.getThisRecordTD(tr,["PAY_AMT"])[0];
				var node=tds["PAY_AMT"].childNodes[0];
				if(node && node.tagName && node.id){
					if(dataObj.PAY_KIND=="0" || dataObj.PAY_KIND=="3"){
						dataObj.PAY_AMT=0;
						node.value=0;
						node.disable();
					}else{
						node.enable();
					}
				}
			}else{
				var trChildNodes=$(tr).up('tr').select("input#PAY_AMT").each(function(node){
					if(dataObj.PAY_KIND=="0" || dataObj.PAY_KIND=="3"){
						node.disable();
						node.value=0;
						dataObj.PAY_AMT=0;					
					}else{
						node.enable();
					}
				});
			}
		},
		listB_format_and_load:function(list){
			if(!list || !list.length){
				grid.load();
				return;
			}
			var loanStatus = list[0]['LOAN_STATUS'];
			
			$A(list).each(function(record){
				if(!record.SEQ_NO){ return;}
				var LOAN_ID = record.LOAN_ID;
				if(!LOAN_ID){ return; }
				var postFix=LOAN_ID.substr(LOAN_ID.length-1);
				record['postFix'] = postFix;
				if(!record['PAY_KIND']){
					if(("12"==record.LOAN_STATUS || "13"==record.LOAN_STATUS|| "15"==record.LOAN_STATUS)){
						record['PAY_KIND']="9"; //清償已領，預設清償違約金
					}else if("X"==postFix){
						record['PAY_KIND']="2"; //理財型預設部入
					}else{
						record['PAY_KIND']="0"; //預設期款						
					}		
				}
			});
			grid2.load(list , null , null ,['Y']);
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
	  	},
	  	doCalTotal : function( node , boxStatus , records ){ 
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
	};	
var buttons ={
	doQuery : function(){
		if(!valid1.validate()){
			return;
		}
		var qryMap={
			TRANS_DATE : $F('TRANS_DATE'),
			TRANS_STATUS : $F('TRANS_STATUS'),
			PAY_TYPE : $F('PAY_TYPE'),
			TRANS_AREA : $F('TRANS_AREA')
			//TRANS_NO : $F('TRANS_NO')
		}
		
		grid2.load([]);
		$('grid2').hide();
		$('table_a').hide();
		grid3.load([]);
		$('grid3').hide();
		$('table_b').hide();	
		
		ajaxPost( 'query', {qryMap : Object.toJSON(qryMap)}
				,function(resp){
					grid.load(resp.dataList);
				},function(resp){
					grid.load([]);	
				}
			);
	
	}
	,doEnter :function(data){
		if(!valid1.validate()){				
			return; 
		}
		var qryMap={
			TRANS_DATE: $F('TRANS_DATE'),
			TRANS_STATUS: $F('TRANS_STATUS')
		}
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
			COPR_CODE : '0', //無從判斷，預設給0個人
			PAY_NAME : data['TRANS_NAME'], 
			noWrite : 'Y' //無繳款人資訊，不需寫入繳款服務單 //2019-01-28：申請書 181128001539 - 繳款服務單新增檢核
		};		
		ajaxPost( 'enter', {'accessData' :Object.toJSON(data), 'qryMap' :Object.toJSON(qryMap),PAY_TYPE : $F('PAY_TYPE'),PAY_INFO : Object.toJSON(PAY_INFO)}
			,function(resp){
				if(resp.ERR_MSG){ //若有檢核出制裁名單，需連結至洗錢防制檢核紀錄填寫紀錄後才能掛人工暫收
					alert(resp.ERR_MSG);
					var parms = {//180917:申請書(180828001571):新增可疑交易檢核 
						'LINK_TO' : resp.LINK_TO,
						'QUERY_ID' : resp.QUERY_ID,
						'CURRENT_DATE' : resp.CURRENT_DATE
					}; 	
					actions.doPopup( parms );	
				} else {			
					grid.load(resp.dataList || []);
				}
			}
			
		);			
	}
	,doConfirm :function(record){
		
		REAL_PAYMT_rc=record.DEDUCT_AMT;
		ajaxPost( 'confirm', {confirmData :Object.toJSON(record),PAY_DATE:$F('TRANS_DATE'),PAY_TYPE:$F('PAY_TYPE')}
				,function(resp){
					PayKindList=resp.PayKindOpts.evalJSON()||[];
					actions.listB_format_and_load(resp.loanList);
					grid3.load();
				}
				,function(resp){
                     grid2.load([]);
				});
		//畫面區塊顯示控制
		$('grid2').show();
		$('table_a').show();
		$('grid3').hide();
		$('table_b').hide();
	},//新增
	   	doAdd : function(){
					
			var dataList = grid2.getAllRecords();
			if(dataList.length==0){
				alert("請先查詢再新增");
				return;
			}					
			var size = dataList.length-1;	
				
			var LOAN_ID=dataList[size]['LOAN_ID'];
			
			if(!LOAN_ID){
				return;
			}
		 
			var qryMap={
				LOAN_ID: LOAN_ID
			};
			
			var PAY_DATE = grid.getCheckedRecord()[0]['TRANS_DATE'];
			
			ajaxPost('add' ,{'qryMap': Object.toJSON(qryMap), 'dataList': Object.toJSON(dataList),'PAY_DATE':PAY_DATE},			 
				function(resp){	
				    actions.listB_format_and_load(resp.rtnList);
					grid3.load();
					
					grid2.resetDivHeight();
					PageUI.resize(true);
				}
			);
	}
	,doCal : function(){
		if(!valid2.validate()){				
				return; 
			}
		var calculatedata =grid2.getCheckedRecord();	
		var qryData=grid2.getAllRecords();
			if(calculatedata.length==0){
			  alert("請至少勾選一筆資料");
			  return;
			}

		ajaxPost( 'calculate', {'calculatedata' :Object.toJSON(calculatedata),'allList':Object.toJSON(qryData),'PAY_TYPE':$F('PAY_TYPE')}
				,function(resp){
					//grid3.load(resp.calList);
					//dataList.preCheck="Y"的資料，預設勾選
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
					
			ajaxPost(  
				'assign' ,
				{'BillListStr': Object.toJSON(BillList),'PayListStr':Object.toJSON(PayList),'PAY_TYPE':$F('PAY_TYPE'),'ISTIC':'E','PayAllListStr':Object.toJSON(grid.getAllRecords())},
				function(resp){	
					var BillListStr=resp.BillListStr;
					var PayListStr=resp.PayListStr;
					var billMap={
						'ISTIC' :'E',
						'BillListStr' : BillListStr,
						'PayListStr':PayListStr,
						'PAY_TYPE': $F('PAY_TYPE'),
						'TRANS_DATE':$F('TRANS_DATE'),
						'TRANS_STATUS':$F('TRANS_STATUS')
					}
					var displayMap={
						ListB:Object.toJSON(grid.getAllRecords())
					}
					var LP_JSON = {
						action :actionUrl,
						LINK_TYPE : "IN",   //連結型態 = IN:內部
						LINK_FROM : "DSC3_3100", //原始連結畫面
						billMap   : billMap,
						displayMap: displayMap
					}									
					CSRUtil.linkTo(LP_JSON , 'form');	
				},
				function(resp){
					//grid2.load([]);
				}
			);
	
	}
}
	return {
		initApp : function() {
				<c:forEach var="map" items="${PAY_KIND_MAP}">
					tempMap["${map.key}"]="${map.value}";
				</c:forEach>
				var pay_type=$F('PAY_TYPE');
				var title_name = "";
				if(pay_type=="7"){
					title_name = '電匯異常入帳';
				}else{
					title_name = '劃撥異常入帳';
				}
				PageUI.createPageWithAllBodySubElement('DSC33100', '繳款方式', title_name);
				if(pay_type=="7"){
					gridtable(1);
				}else{
					gridtable(0);
				}
				/*
				grid = new TableUI(
					{table: $("grid"), allSortable: false, overDiv:false,
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
					column:Gridlist[0]
				});
				*/
			grid2 = new TableUI(
				{table: $("grid2"), allSortable: false, pageSize: 20,
				autoCheckBox:{
				    text:'選取',
					type:'checkbox',
					genRule:function( rec , value ){                                     
						return rec.SEQ_NO != '' ? true : false;
					} 
				},				
				column:[
                    {header:"序號",key:"SEQ_NO"},
                    {header:"借款人ID",key:"BORROW_ID"},
                    {header:"借款人姓名",key:"BORROW_NAME", attrs:{style:"font-family:'EUDC'"}},	<%-- [20241104] 難字調整: 借款人姓名 --%>
                    {header:"貸款帳號",key:"LOAN_ID",
						render : function(record, value){
							if (record.SEQ_NO == '') {
								return actions.createInputElement('LOAN_ID',value,'','貸款帳號');
							} else {
								return value;
							}
						}
                    },					
					{header:"繳款種類",key:"PAY_KIND"
						,render : function(record, value){
							
							if (record.SEQ_NO == '') {
								return '';
							} else {
								var postFix=record.LOAN_ID.substr(record.LOAN_ID.length-1);
								var loanStatus=record.LOAN_STATUS;
								
								var select =  new Element("select",{name: 'PAY_KIND'})
								.observe('change', function(event){
									var dataObj = grid2.isNew ? grid2.getDataObj(this) : this.up('tr').dataObj;
									dataObj.PAY_KIND=this.value;
									actions.controlPayAMT(this,dataObj);
								});
								
								$A(PayKindList).each(function(item){
									if(("12"==loanStatus || "13"==loanStatus || "15"==loanStatus)){
										if(item.key=="9"){
											select.add(new Option(item.value,item.key));
										}										
									}else if("X"==postFix){
										if(item.key=='2'|| item.key=='3' || item.key=='2A'){
											select.add(new Option(item.value,item.key));
										}
									}else if(item.key!="9" && item.key!='2A'){
										select.add(new Option(item.value,item.key));
									}
								});
								select.setValue( value );
								return select;
							}
						}				
					},	
					{header:"轉帳日",key:"PAY_DATE",
					    render : function (rec , val){
							return Date.toROC(val || "");									
						}
					},
					{header:"部入金額或新繳款日或暫收款金額",key:"PAY_AMT"
					    ,render : function(record, value){
							if (record.SEQ_NO == '') {
								return value;
							} else {
								return actions.createInputElement('PAY_AMT',value,'number','部入金額或新繳款日或暫收款金額',record.PAY_KIND);
							}
						}
					},
					{header:"擔保品地址",key:"GAGE_ADDR", attrs:{style:"font-family:'EUDC'"}}	<%-- [20241104] 難字調整: 擔保品地址 --%>		
				]
			});
			grid3 = new TableUI(
				{table: $("grid3"), allSortable: false, pageSize: 20,
				autoCheckBox:{
				    text:'選取',
					type:'checkbox',
					valueKey: 'preCheck',
					isSelectAll:actions.doCalTotal,	//190110:調整全選也會連動合計
					action: actions.doCalTotal 
				},				
				column:[
                    {header:"貸款帳號",key:"LOAN_ID"},
                    {header:"期數",key:"PAY_TERM",
					    render : function (rec , val){
							if (rec.PAY_KIND=='0' && rec.THIS_TERM =='Y'){
								return '<font color="red">'+val+'</font>'
							}else if("3"==rec.PAY_KIND){
								if("5"==rec.C33501_PAYOFF){
									return "清償(不領)";
								}else if("6"==rec.C33501_PAYOFF){
									return "清償(要領)";
								}else {
									return "清償";							
								}
							}else if("2"==rec.PAY_KIND){
								return "部入";
							}else {
								return val;
							}								
						}
					},
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
				$('BTN_QUERY').observe('click',buttons.doQuery);
				$('BTN_ADD').observe('click', buttons.doAdd); //新增貸款帳號試算
				$('BTN_CAL').observe('click',buttons.doCal);
				$('BTN_ASSIGN').observe('click',buttons.doAssign);
				
				//若為行政中心單位，預設電匯帳號，並不得修改
				/*if($F('def_TRANS_NO')){
					$('TRANS_NO').value = $F('def_TRANS_NO') || "";
				}*/
				
				var LP_JSON = CSRUtil.isBackLink('form');
				var inPayType='${PAY_TYPE}';
				if(LP_JSON){	//由其他頁面，回上一頁
					var displayMap=LP_JSON.displayMap;
					var ListB=displayMap.ListB.evalJSON()||[];
					var billMap=LP_JSON.billMap;	
					//載入查詢條件
					$('TRANS_DATE').value=billMap.TRANS_DATE;
					$('TRANS_STATUS').value=billMap.TRANS_STATUS;
					$('PAY_TYPE').value=billMap.PAY_TYPE;					
					inPayType=billMap.PAY_TYPE;
					$('TRANS_NO').value=billMap.TRANS_NO;
					//載入查詢結果
					if($F('PAY_TYPE')=="7"){
						gridtable(1);
					}else{
						gridtable(0);
					}
					grid.load(ListB);
				}				
			
				//畫面區塊顯示控制
				$('grid2').hide();			
				$('table_a').hide();
				$('grid3').hide();
				$('table_b').hide();
				
				if(inPayType!="7"){
					$('TransDiv1').hide();
				}
								
				//先把畫面區塊都調整到位再顯示訊息
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
<input id="def_TRANS_NO" name="def_TRANS_NO" type="hidden" value="${TRANS_NO}"/>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow"  width='10%'>電匯劃撥日期</td>
			<td class="tbYellow2"  >
			<div id="TransDiv1"><!--電匯帳號  //改由資管轄區查詢
				<select id="TRANS_NO" name='TRANS_NO'>
					<option value="">請選擇</option>
					<c:forEach var="map" items="${TRANS_NOList}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>-->
				資管轄區
				<select id="TRANS_AREA" name='TRANS_AREA'>
					<option value="">全部</option>
					<c:forEach var="map" items="${TRANS_AREAList}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select> 					
			</div>
			<input id="TRANS_DATE"  type="text" class="textBox2 " name="TRANS_DATE" value='${TRANS_DATE}'  datatype="ROCDate" maxlength="7"/>
			<img id = "img_date" src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('TRANS_DATE'))">
		</td>
		<td class="tbYellow2" width='70%' rowspan='2'>
				<input id="BTN_QUERY" type="button" value="查詢" class="button" >	
				<input  type = 'hidden'  id = 'PAY_TYPE' value="${PAY_TYPE}"/>
				<!-- <input type="hidden" name="LP_JSON" id="LP_JSON" /> -->
		</td>
	</tr>
	<tr>
		<td class="tbYellow"  width='10%'>狀態</td>
		<td class="tbYellow2" >
			<select id="TRANS_STATUS">
				<c:forEach var="map" items="${TRANS_STATUS_List}">
						<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select> 
		</td>
	</tr>
</table>
	<table id = "grid" ></table>
	<!--
	<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
    <tr>
		<td class="tbYellow2">
			<input type="button" class="button" id="BTN_CONFIRM" value="選取確認"/>				
		</td>

	</tr>
	</table>
	-->
	
	<table id = "grid2" ></table>
	<table id="table_a" width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
    <tr>
		<td class="tbYellow2">
			<input id = "BTN_ADD" type = "button" class = "button" value = "新增"   />
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
