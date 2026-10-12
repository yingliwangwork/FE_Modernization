<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC31600.jsp
功能：櫃台電匯劃撥預入帳
作者：陳宥銓
完成：2013/09/25

[20180824] 修改件:  
1.input 欄位不設type='DATE'
2.input 欄位增加name = theID+'_input'
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" /><!--匯入外部Javascript 與 css-->
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>		  <%-- 月曆用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			 <%-- 日期用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<%-- [20241104]難字 css --%>
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

Event.observe(window, 'load', DSC31600().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC31600(){
	
	var valid1;
    var grid;
	var grid2;
 	var PayKindOpts;
 	var ISTICLOpts;
 	var PayKindList;
 	var ISTICList;  
	var isSRV = '${isSRV}';	
	//畫面檢核
	function initValidation(){
	
	    Validation.addAllThese([
			/*	
			[ 'PAY_AMT_Required', '繳票金額及現金不可同時為 0 或 負值，請輸入數值格式',
				function( v , elem ) {
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
					var pay_kind=parseInt(elem.up('tr').select("select")[0].value);	//取得繳款別
					//alert("checks:"+checks+",PAY_KIND:"+pay_kind.value+",v:"+v);
                    if(checks){	
						if((pay_kind==1||pay_kind==2 || pay_kind==4)&&(!v||v==0)){
							return false;
						}
					    return  Validation.get('IsEmpty').test(v) || /^\d+$/.test(v.replace(/,/g,''));
					}
					return true;
				},
			]
	    	*/
		]);
	
		valid1 = new Validation("form1", { focusOnError:true, immediate:false, mode:'validator'});	

	}
	
	/*
   //按鈕授權
	function buttonAuth() {
		var authButtons = { 
			B0003 : 'btn_query',
			B0004 : 'btn_cal',
			B0005 : 'btn_assign'		
		};
		//<dz:grantButtons FUNC_ID ="DSC31600"/>
	} */
	
	//共用的Ajax
	var ajaxRequest = new CSRUtil.AjaxHandler.request('<%=dispatcher%>/DSC3_1600/');
	
	var actions = {
		//數字格式化1
		formatAMT : function(val){ return (val || val ===0 )? CSRUtil.$fmt(val,'#,###'):''; },
		
		//連結至DSC22200頁面
		LINKTO: function(event){ popupWin.popup({'src':'<%=dispatcher%>/DSC2_2200/prompt'}); },
		
		 //產生TableUI中裡面的input欄位(B區)
		createInputElement : function(colkey,value,type,col_nm,PAY_KIND){
			var theID = colkey;
			if(type == 'date'){ //實繳日				
				var input = new Element('input', 
					//[20180824] input不設type='DATE', 增加name = theID+'_input'
					{className:'textBox2 validate-ROCDate required', id:theID, name:theID+'_input', datatype:'ROCdate', size:'9', maxlength:'7', fieldName:col_nm }
				)
				.setValue(Date.toInputROC( value || '' ,''))
				.observe('change' , function(event){
					var dataObj = grid.isNew ? grid.getDataObj(this) : this.up('tr').dataObj;
					dataObj[colkey] = toY2K(event.target.value||'');
				 });
				return input;
			}else if(type == 'number'){ //部入金額或新繳款日或暫收款金額
				var input = new Element('input', 
					//[20180824] 增加name = theID+'_input'
					{className:'textBox2 PAY_AMT_Required', id:theID, name:theID+'_input', type:'text', datatype:'number', pattern:'#,###', size:'15', maxLength:'15', fieldName:col_nm }
				)
				.setValue( value || value===0 ? CSRUtil.$fmt(value,'#,###') : '')
				.observe('blur' , function(event){						
					var dataObj = grid.isNew ? grid.getDataObj(this) : this.up('tr').dataObj;
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
					//[20180824] 增加name = theID+'_input'
					{className:'textBox2', id:theID, name:theID+'_input', type:'text', size:'12', maxLength:'10', fieldName:col_nm }
				)
				.observe('change' , function(event){						
					var dataObj = grid.isNew ? grid.getDataObj(this) : this.up('tr').dataObj;
					var new_value = this.value;
					new_value = (new_value+"").toUpperCase(); //轉大寫
					input.value = new_value;
					dataObj[colkey] = new_value;
				});
				return input; 
			}
		},
		controlPayAMT : function(tr,dataObj){
			if(grid.isNew){
				var tds = grid.getThisRecordTD(tr,["PAY_AMT"])[0];
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
		controlISTIC : function(e){
			var value = this.value;
			$A(grid.getAllRecords()).each(function(record){
				record['ISTIC']=value;
			})
			$$('#grid select[name=ISTIC]').each(function(ele){				
				ele.value=value;
			});
			
		},
		clearQry : function(event){
			var qryStr=this.id;
			$w("LOAN_ID BORROW_ID BORROW_NAME").each(function(QRY_KEY){
				if(QRY_KEY == qryStr){ return;}
				$(QRY_KEY).setValue('');
			});
		},
		genOptionList : function(billMap,listB){
		 	ajaxRequest.post(  
				'genOptionList' , 
				{'billMap': Object.toJSON(billMap)},			 
				function(resp){
					PayKindList=resp.PayKindOpts.evalJSON()||[];
					ISTICList=resp.ISTICLOpts.evalJSON()||[];
					actions.listB_format_and_load(listB);
				}
			);
	  	},
		listB_format_and_load:function(list){
			if(!list || !list.length){
				grid.load();
				return;
			}
			var ISTIC_default = list[0]['ISTIC'];
			var loanStatus = list[0]['LOAN_STATUS'];
			if(!ISTIC_default){
				if( $F('PAY_TYPE') =="1" && (loanStatus==33 || loanStatus==36)){
					ISTIC_default = 'C'; 	//33協商還款,36更生還款
				}else{
					ISTIC_default = ISTICList[0].key;
				}
			}
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
				record['ISTIC'] = ISTIC_default;
			});
			grid.load(list , null , null ,['Y']);
		},
		doCalTotal : function( node , boxStatus , records ){ 
								
			var chkList = grid2.getCheckedRecord();
			var allList = grid2.getAllRecords();
			
			ajaxRequest.post( 'total', {'chkList':Object.toJSON(chkList),'allList':Object.toJSON(allList)},
				function(resp){
					grid2.load(resp.allList || [], resp.totalList || [], null, ["Y"]);
				}
			);		
		}
	  	
	};
	
	var buttons={
		//查詢
		doQuery : function(){
				
			var LOAN_ID=$F('LOAN_ID');
			var BORROW_ID=$F('BORROW_ID');
			var BORROW_NAME=$F('BORROW_NAME');
			
			if(!LOAN_ID && !BORROW_ID && !BORROW_NAME){
				alert("請輸入任一個查詢條件!");
				return;
			}
			var postFix=LOAN_ID.substr(LOAN_ID.length-1);			
			if("X"==postFix){
				alert("理財型房貸請輸入借款人ID查詢!");
				return;
			}
		 
			var qryMap={
				LOAN_ID: LOAN_ID,
				BORROW_ID: BORROW_ID,
				BORROW_NAME:BORROW_NAME
			};
		 
		 
			ajaxRequest.post(  
				'query' , 
				{'qryMap': Object.toJSON(qryMap),'PAY_TYPE':$F('PAY_TYPE'),'SPEC':$F('SPEC')},			 
				function(resp){	
				    actions.listB_format_and_load(resp.dataList);
					grid2.load();
					$('MSG').update('');
					
					grid.resetDivHeight();
					PageUI.resize(true);
				},
				function(resp){
					grid.load();
					grid2.load();
				}
			);
	  	},
	   	//新增
	   	doAdd : function(){
					
			var dataList = grid.getAllRecords();
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

			ajaxRequest.post(  
				'add' , 
				{'qryMap': Object.toJSON(qryMap), 'dataList': Object.toJSON(dataList)},			 
				function(resp){	
				    actions.listB_format_and_load(resp.rtnList);
					grid2.load();
					$('MSG').update('');
					
					grid.resetDivHeight();
					PageUI.resize(true);
				}
			);
	   },
	   //試算
	   doCal: function(){
	   
			if(!valid1.validate()){				
				return; 
			}
			var qryData=grid.getAllRecords();
			var cal_data =grid.getCheckedRecord();	
			if(cal_data.length==0){
			  alert("請至少勾選一筆資料");
			  return;
			}
			
			//cal_data逐筆檢查是否為理財型帳號部入且餘額=0。	
			//240911此段參數有誤，改至後端檢核
			//問題單20240911-0027餘額0元理財型部入檢核錯誤調整		
			/*for(var i=0;i<cal_data.length;i++){
				var loanID=cal_data[i].LOAN_ID;
				var post_fix=loanID.trim().charAt(loanID.length-1);	//貸款帳號尾碼
				var pay_kind=parseInt(cal_data[i].PAY_KIND);	//繳款方式
				var remainx_amt=new Number(cal_data[i].REMAINX_AMT);	//理財型餘額
				var pay_amt=new Number(cal_data[i].PAY_AMT);	//繳款金額(部入才需輸入)
				
				if("X"==post_fix && 2==pay_kind && 0==remainx_amt){//理財型帳號才判斷					
					alert("理財型帳號:"+loanID+",餘額為0，請確認是否要進行部入交易。");
					break;
				}
			}*/
						
			ajaxRequest.post(  
				'calculate' , 
				{'selectList': Object.toJSON(cal_data),'allList':Object.toJSON(qryData),PAY_TYPE:$F('PAY_TYPE'),SPEC:$F('SPEC')},			 
				function(resp){	

					//dataList.preCheck="Y"的資料，預設勾選
					grid2.load(resp.calList || [], resp.totalList || [], null, ["Y"]);
				   
				   	if(resp.MSG){
				   		$('table_D').show();
						if ($F('PAY_TYPE') == '7'){
							$('MSG').innerHTML= ('<font color="red" size="4">' +resp.MSG+'</font>') || '';  //訊息
						}else{
							$('MSG').innerHTML= resp.MSG || '';  //訊息
						}
				   	}else{
				   		$('MSG').update('');
				   	}
				   	<%--[申請書24051555111]理財型還款清償與帳務作業優化:檢核是否有人工暫應收待處理(暫應收編號開頭CB&DB)，提示內容：有人工暫收or應收,請通知放企科帳務人員TEMPORARY_MSG--%>
					if(resp.isSHOW){
						$('TEMPORARY_MSG').update('有人工暫收or應收,請通知放企科帳務人員');
					}
				   	$('ISTIC').value=resp.ISTIC;
				   	$('PAY_TYPE').value=resp.PAY_TYPE;				   
					grid2.resetDivHeight();
					if (resp.EXTRACT_MSG) {
						alert(resp.EXTRACT_MSG);
					}
					PageUI.resize(true);	
				},
				function(resp){
					grid2.load([]);
					$('table_D').hide();
				}
			);
	   }
	   //金額分配
	   ,doAssign : function(){
			var LoanIdList = grid.getCheckedRecord();	
				if(LoanIdList.length==0){
					alert("請於查詢結果中至少勾選一筆資料!");
					return;
				}
				
			
			var recs = grid2.getAllRecords();
				if(recs.length==0){
					alert("請先進行試算!")
					return;
				}
			
			var BillList = grid2.getCheckedRecord();	
				if(BillList.length==0){
					alert("請於試算清單中至少勾選一筆資料!");
					return;
				}
				
				var isXZeroPayOff = false;
				for (var i=0; i<BillList.length; i++){
					var BillMap=BillList[i];
					var LOAN_ID = BillMap['LOAN_ID'];
					if(BillMap['PAY_KIND'] == "3" && LOAN_ID.trim().charAt(LOAN_ID.length-1) =="X" && BillMap['DUTY_PAYMT'] == 0){
						isXZeroPayOff = true;	
					}			
				}
				
				if(BillList.length>1 && isXZeroPayOff){
					alert("理財型0元清償請單筆入帳!");
					return;
				}
				
				
				var actionUrl="";
				
				if("0"==$F('ISTIC')){
					actionUrl='<%=dispatcher%>/DSC3_1611/prompt';					
				}else if("3"==$F('ISTIC')){
					actionUrl='<%=dispatcher%>/DSC3_1612/prompt';
				}else if("1"==$F('ISTIC') || "2"==$F('ISTIC') || "4"==$F('ISTIC')){
					actionUrl='<%=dispatcher%>/DSC3_1613/prompt';
				}else if("C"==$F('ISTIC')){
					actionUrl='<%=dispatcher%>/DSC3_1614/prompt';
				}else if("7"==$F('ISTIC')){
					actionUrl='<%=dispatcher%>/DSC3_1615/prompt';
				}else if("5"==$F('ISTIC')){
					actionUrl='<%=dispatcher%>/DSC3_1616/prompt';
				}else if("E"==$F('ISTIC')){
					actionUrl='<%=dispatcher%>/DSC3_1617/prompt';					
				}else{
					alert("繳款方式有誤!");
					return;
				}				
				ajaxRequest.post(  
				'assign' ,
				{'BillListStr': Object.toJSON(BillList),'PAY_TYPE':$F('PAY_TYPE'),'ISTIC':$F('ISTIC')},
				function(resp){	
					var BillListStr=resp.BillListStr;
					
					var billMap={
						'ISTIC' : $F('ISTIC'),
						'BillListStr' : BillListStr,
						'PAY_TYPE': $F('PAY_TYPE'),
						'SPEC':$F('SPEC')
					}
					var displayMap={
						ListB:Object.toJSON(grid.getAllRecords())
					}

					var LP_JSON = {
						action :actionUrl,
						LINK_TYPE : "IN",   //連結型態 = IN:內部
						LINK_FROM : "DSC3_1600", //原始連結畫面
						billMap   : billMap,
						displayMap: displayMap
					}									
					CSRUtil.linkTo(LP_JSON , 'form1');	
				},
				function(resp){
					//grid2.load([]);
					//$('table_D').hide();
				}
			);		
		}
    }

	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSC31600','核心放款','查詢試算',1);
			
			initValidation();
			
			//按鈕事件監聽
		    $('btn_query').observe('click', buttons.doQuery); //查詢
		    $('btn_add').observe('click', buttons.doAdd); //查詢
			$('btn_cal').observe('click', buttons.doCal); //試算
			$('btn_assign').observe('click', buttons.doAssign); //金額分配
			$('LOAN_ID').observe('click', actions.clearQry); //貸款帳號
			$('BORROW_ID').observe('click', actions.clearQry); //借款人ID
			$('BORROW_NAME').observe('click', actions.clearQry); //借款人姓名
			
			
			grid = new TableUI(
				{table: $("grid"), pageSize : 0, allSortable: false, overDiv:false, 
					autoCheckBox:{
						text:'選取', 
						type:'checkbox',
						isSelectAll:true,
						valueKey: 'preCheck',
						action:function( node , boxStatus , records ){ 						
							//下拉選單沒change時的處理
							var tr = node.up('tr');
							var dataObj = records[0];
							if(grid.isNew){
								var tds = grid.getThisRecordTD(node)[0];
								for( var td_key in tds ){
									$(tds[td_key]).select('select').each(function(ele){
										if(!dataObj[ele.name]){
											dataObj[ele.name] = ele.value;
										}	
									});
								}
							}else{
								tr.select('select').each(function(ele){
									if(!dataObj[ele.name]){
										dataObj[ele.name] = ele.value;
									}
								});	
							}	
							
							var PAYOFF_LIMIT=records[0].PAYOFF_LIMIT;
							var LOAN_ID=records[0].LOAN_ID;
							if(PAYOFF_LIMIT==1){
								alert(LOAN_ID+"--屬法務之清償控管");
							}else if(PAYOFF_LIMIT==2){
								alert(LOAN_ID+"--屬催收之清償控管");
							}else if(PAYOFF_LIMIT==3){
								alert(LOAN_ID+"--屬放款之清償控管");
							}
						},
						genRule:function( record , value ){
							//if(record.SEQ_NO != '')才顯示INPUT                                      
							return record.SEQ_NO != '' ? true : false;
						} 
					}, 
				column:[	
					
					{header:"序號", key:"SEQ_NO"},
					{header:"借款人姓名",key:"BORROW_NAME"},
					{header:"借款人ID", key:"BORROW_ID"},
					{header:"貸款帳號",key:"LOAN_ID",
						render : function(record, value){
							if (record.SEQ_NO == '') {
								return actions.createInputElement('LOAN_ID',value,'','貸款帳號');
							} else {
								return value;
							}
						}
					},
					{header:"繳款種類",key:"PAY_KIND",
						render : function(record, value){
							if (record.SEQ_NO == '') {
								return '';
							} else {
								var postFix=record.postFix;
								var loanStatus=record.LOAN_STATUS;
								
								var select =  new Element("select",{name: 'PAY_KIND', id:"PAY_KIND" + record.SEQ_NO}) 
								.observe('change', function(event){
									var dataObj = grid.isNew ? grid.getDataObj(this) : this.up('tr').dataObj;
									dataObj.PAY_KIND=this.value;
									actions.controlPayAMT(this,dataObj);
								});
								
								$A(PayKindList).each(function(item){
									if(("12"==loanStatus || "13"==loanStatus || "15"==loanStatus)){
										if(item.key=="9"){
											select.add(new Option(item.value,item.key));
										}										
									}else if("X"==postFix){
										if(item.key=='2'|| ("N" == isSRV && item.key=='3') || item.key=='2A'){
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
					{header:"繳款方式",key:"ISTIC",
						render : function(record, value){
							if (record.SEQ_NO == '') {
								return '';
							} else {
								var loanStatus=record.LOAN_STATUS;
								var PAY_TYPE = $F('PAY_TYPE');
								var select = new Element("select",{name: 'ISTIC', id:"ISTIC" + record.SEQ_NO})
								.observe('change', actions.controlISTIC);	
								for(var i=0;i<ISTICList.length;i++){
									var item=ISTICList[i];
									if( PAY_TYPE =="1" && (loanStatus==33 || loanStatus==36) && item.key=="C"){	//33協商還款,36更生還款
										select.add(new Option(item.value,item.key));
									}else{
										select.add(new Option(item.value,item.key));
									}
								}
								select.value=value;
								return select;
							}
						}	
					},
					{header:"實繳日/票據日",key:"PAY_DATE",
						render : function(record, value){
							if (record.SEQ_NO == '') {
								return value;
							} else {
								return actions.createInputElement('PAY_DATE',value,'date','實繳日/票據日');
							}
						}
					},
					{header:"部入金額或新繳款日或暫收款金額",key:"PAY_AMT", 
						render : function(record, value){
							if (record.SEQ_NO == '') {
								return value;
							} else {
								return actions.createInputElement('PAY_AMT',value,'number','部入金額或新繳款日或暫收款金額',record.PAY_KIND);
							}
						}
					},
					{header:"擔保品地址",key:"GAGE_ADDR"}
				]
				});		
				
				
				grid2 = new TableUI(
				{table: $("grid2"), pageSize : 20, allSortable: false, overDiv:false, 
					autoCheckBox:{
							text:'選取', 
							type:'checkbox',
							valueKey: 'preCheck',
							isSelectAll:actions.doCalTotal,//190110:調整全選也會連動合計	
							action: actions.doCalTotal
					}, 
				column:[
                    {header:"貸款帳號",key:"LOAN_ID"},
                    {header:"期數",key:"PAY_TERM",
                    	render : function (rec , val){					    	
							if("4"==rec.PAY_KIND){
								return "暫收款";
							}else if("3"==rec.PAY_KIND){
								return "清償";
							}else if("2"==rec.PAY_KIND || "2A"==rec.PAY_KIND){
								return "部入";
							}else if("1"==rec.PAY_KIND){
								return "變更應繳日";
							}else{
								//if("0"==rec.PAY_KIND && diffDay(getY2KToday(), addDate(rec.NEXT_PAYDT, 0, -1, 0)) > 0){
								if("0"==rec.PAY_KIND && diffDay(rec.NEXT_PAYDT, getY2KToday()) < 0){
									return "<font color='red'>"+val+"</font>";
								}else{
									return val;
								}
							}									
						}
                    },
                    {header:"應繳日",key:"NEXT_PAYDT",                    	
					    render : function (rec , val){
					    	if("4"==rec.PAY_KIND){
								return "";
							}else{
								if("0"==rec.PAY_KIND && diffDay(rec.NEXT_PAYDT, getY2KToday()) < 0){
						    		return "<font color='red'>"+Date.toROC(val || "")+"</font>";
						    	}else{			    	
									return Date.toROC(val || "");
								}
							}									
						}
					},	
                    {header:"實繳日/票據日",key:"PAY_DATE",
					    render : function (rec , val){
							return Date.toROC(val || "");									
						}
					},					
					{header:"應繳金額",key:"DUTY_PAYMT",renderInCount:true,
					    render: function (rec,val){					    	
							if(val ||val ===0){ 
								if("0"==rec.PAY_KIND && diffDay(rec.NEXT_PAYDT, getY2KToday()) < 0){
									return "<font color='red'>"+CSRUtil.$fmt(val,"#,###")+"</font>";
								}else{
									return CSRUtil.$fmt(val,"#,###");
								}
							}
							return "0";
						}
					},	
					{header:"適用利率",key:"RATE_VAL",
					    render: function (rec,val){				    					    	
							if(val ||val ===0){ 
								return CSRUtil.$fmt(val,"#,###");
							}
							return "";
						}
					},
					{header:"應攤本金",key:"PRINCIPAL",renderInCount:true,
					    render: function (rec,val){					    	
							if(val ||val ===0){ 
								return CSRUtil.$fmt(val,"#,###");
							}
							return "0";
						}
					},
					{header:"利息",key:"INTEREST",renderInCount:true,
					    render: function (rec,val){					    	
							if(val ||val ===0){ 
								//利息欄位=rec.INTEREST+rec.RETAIN_INT
								val=val+rec.RETAIN_INT||0;
								return CSRUtil.$fmt(val,"#,###");
							}
							return "0";
						}
					},{header:"災戶攤繳息",key:"VICTIM_INT",
					    render: function (rec,val){					    	
							if(val ||val ===0){ 
								return CSRUtil.$fmt(val,"#,###");
							}
							return "0";
						}
					},
					{header:"逾期息",key:"DELAY_INT",renderInCount:true,
					    render: function (rec,val){
							if(val ||val ===0){ 
								return CSRUtil.$fmt(val,"#,###");
							}
							return "0";
						}
					},
					{header:"違約金",key:"RENEGE",renderInCount:true,
					    render: function (rec,val){
							if(val ||val ===0){ 
								return CSRUtil.$fmt(val,"#,###");
							}
							return "0";
						}
					},
					{header:"管理費",key:"LAWSUIT_FEE",renderInCount:true,
					    render: function (rec,val){
							if(val ||val ===0){ 
								return CSRUtil.$fmt(val,"#,###");
							}
							return "0";
						}
					},
					{header:"上期結餘",key:"LAST_BALANCE",
					    render: function (rec,val){
							if(val ||val ===0){ 
								return CSRUtil.$fmt(val,"#,###");
							}
							return "0";
						}
					},
					{header:"代扣稅款",key:"TAX",
					    render: function (rec,val){
							if(val||val ===0){ 
								return CSRUtil.$fmt(val,"#,###");
							}
							return "0";
						}
					}	
				]
				});		

		//	buttonAuth();
			//SPEC='${SPEC}'||"";
			$('SPEC').value='${SPEC}'||"0";
			
			autoFormatToNumber();
			
			$('table_D').hide();			
			displayMessage();
			//畫面初始時取得
			PayKindList='${PayKindOpts}'.evalJSON()||[];
			ISTICList='${ISTICLOpts}'.evalJSON()||[];
			
			var LP_JSON = CSRUtil.isBackLink('form1');
			if(LP_JSON){	//由其他頁面，回上一頁
				var displayMap=LP_JSON.displayMap;
				var ListB=displayMap.ListB.evalJSON()||[];
				var billMap=LP_JSON.billMap;
				$('PAY_TYPE').value=billMap.PAY_TYPE;
				$('SPEC').value=billMap.SPEC||"0";
				//依billMap.PAY_TYPE，取得下拉選單清單，並載入gird
				actions.genOptionList(billMap,ListB);						
			}
			
			PageUI.resize(true);				
		}// end initApp()	
		
	}; //end return
}
</script>
</head>
<body>
<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
				<td class="tbYellow" width="10%">借款人ID</td>		
				<td class="tbYellow2" width="10%">
						<input id="BORROW_ID" name="BORROW_ID" type='text' class= 'textBox2'  size='12' maxlength='10' onblur="this.value = this.value.toUpperCase()" value='' />
				</td>			
				<td class="tbYellow" width="10%">貸款帳號</td>		
				<td class="tbYellow2" width="10%">
					    <input id="LOAN_ID" name="LOAN_ID" type='text' class= 'textBox2' size='12' maxlength='10' onblur="this.value = this.value.toUpperCase()"/>
				</td>			
				<td class="tbYellow" width="10%">借款人姓名</td>		
				<td class="tbYellow2" width="10%">
						<input id="BORROW_NAME" name="BORROW_NAME" type='text' class= 'textBox2'  size='12' maxlength='10' alt="ch" />
				</td>	
				<td class="tbYellow2" width="10%" align="center">
					<input id = "btn_query" type = "button" class = "button" value = "查詢"   />		
				</td>			
		</tr>		
</table>

	<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow0"><B>查詢結果</B>
		<input id = "btn_add" type = "button" class = "button" value = "新增"   />		
		<input type="hidden" name="LP_JSON" id="LP_JSON" /></td>
	</tr>
	</table>
	<table id = "grid" ></table>
	<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
    <tr>
		<td class="tbYellow2" width="50%">
			<input type="button" class="button" id="btn_cal" value="試算"/>				
		</td>
	</tr>
	</table>
	<table id="table_C" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow0"><B>試算清單</B> <span id="TEMPORARY_MSG"></span>
		<input  type = 'hidden'  id = 'ISTIC' value="${ISTIC}"/>
		<input  type = 'hidden'  id = 'PAY_TYPE' value="${PAY_TYPE}"/>
		<input  type = 'hidden'  id = 'SPEC' value="${SPEC}"/></td>
	</tr>
	</table>
	<table id = "grid2" ></table>
	<table id="table_D" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow0">			
			<B>◎訊息:		
			<span id="MSG"></span>
			</B>
		</td>
	</tr>
	</table>
	<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
    <tr>
		<td class="tbYellow2" width="50%">
			<input type="button" class="button" id="btn_assign" value="金額分配"/>				
		</td>
	</tr>
	</table>
</form>	
</body>
</html>