<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--
程式：DSC33501.jsp
功能：電匯通報作業明細 
作者：陳雯婷
完成：2014/08/26
2018/10/02申請書-資管電匯入帳調整、貸款繳息試算連結電匯通報作業
1.貸款繳息試算連結，並增加原貸帳號查詢
2.
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='${htmlBase}/CM/js/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/date.js"></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/utility.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/popupWin.js"></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>

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
Event.observe(window, 'load', new DSC33501().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC33501(){
var gridB;
var gridC;
var gridE;
var gridF;
var valid1;
var emailList;
var PAY_KINDList=<c:out value="${PAY_KINDList}" default="[]" escapeXml="false" />;
var TRANS_REMARKList=<c:out value="${TRANS_REMARKList}" default="[]" escapeXml="false" />;
var SEND_TYPEList=<c:out value="${sSEND_TYPEList}" default="[]" escapeXml="false" />;
//var PAY_KINDList='${PAY_KINDList}'.evalJSON()||[]; //141006若SOURCE等於U，${PAY_KINDList}會是空值，導致.evalJSON取失敗，頁面錯誤
var PAYOFF_LIMITList=<c:out value="${PAYOFF_LIMITList}" default="[]" escapeXml="false" />;
var isSRV = '${isSRV}';

	function initValidation(){
		//查詢用檢核
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	;
		//valid1.define( "required" , { id: "TRANS_NO", errMsg:'請輸入電匯帳號' } );
	    valid1.define( "required" , { id: "SEND_TYPE", errMsg:'請輸入收據寄送方式' } );
		valid1.define( "required" , { id: "LOAN_ID_ACCOUNT", errMsg:'請輸入虛擬帳戶' } );
	}
	
	//建立 ajax request 物件
    var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC3_3501/');
	
	//自動轉大寫
	 function formatUpperCase(col){   
		$(col).value=$(col).value.toUpperCase();
	 }

	
	var buttons={
	
		//查詢
		doQuery : function(val){
			
			var LOAN_ID=$F('LOAN_ID');
			var BORROW_ID=$F('BORROW_ID');
			var REFER_ID=$F('REFER_ID');
			if(!BORROW_ID && !LOAN_ID && !REFER_ID){
				alert('請輸入任一個查詢條件');
				return;
			}else if(LOAN_ID && 'X'==LOAN_ID.slice(-1)){
				alert('理財型房貸請輸入借款人ID查詢');
				return;
			}else if(REFER_ID && 'X'==REFER_ID.slice(-1)){
				alert('理財型房貸請輸入借款人ID查詢');
				return;
			}
			
			//檢核輸入長度
			if(LOAN_ID){
				if(LOAN_ID.length != 10){
					alert('請輸入正確貸款帳號');
					return;
				}
			} else if(REFER_ID){
				if(REFER_ID.length != 10){
					alert('請輸入正確原貸帳號');
					return;
				}
			} else if(BORROW_ID){
				if(BORROW_ID.length != 10 && BORROW_ID.length != 8 ){
					alert('請輸入正確借款人ID');
					return;
				}
			}
			
			//畫面區塊顯示控制
			$('gridB').hide();
			$('tableB').hide();
			$('gridC').hide();
			$('tableC').hide();
			$('tableD').hide();
			$('gridE').hide();
			$('gridF').hide();
			$('gridB').show();
			$('tableB').show();

			ajaxRequest.post( 'query', {BORROW_ID : BORROW_ID, LOAN_ID : LOAN_ID, REFER_ID : REFER_ID, PAY_DATE_C:$F('PAY_DATE_C'), LINK_FROM:$F('LINK_FROM'),isPROOF:$F('isPROOF')}
				,function(resp){
				    var dataList = resp.dataList||[];
					if("1" == val && $F('LINK_FROM')=='DSH00200' && $F('isPROOF')){ //若從貸款繳息試算過來是清償將要領/不領帶入
						for (var i=0; i<dataList.length; i++){
							var dataMap=dataList[i];	
							if ('X'!= dataMap.LOAN_ID.slice(-1)){
								if ("0" == $F('isPROOF')) {
									dataMap.C33501_PAYOFF = "5";
								} else if ("1" == $F('isPROOF')){
									dataMap.C33501_PAYOFF = "6";
								}
							}
						}
					}

					for (var i=0; i<dataList.length; i++){
						var dataMap=dataList[i];
						if ($('PAY_KIND_C').value == "2") {
							dataMap.PAY_AMT = $F('PAY_AMT');
						}
					}
					
					gridB.load(dataList, [], null, ["Y"]);
					//gridB.checkAll(true);
					//預設電匯帳號	
					//$('TRANS_NO').value = resp.TRANS_NO;
					if("1" == val && $F('LINK_FROM')=='DSH00200'){
						buttons.doCalculate();
					}

				},function(resp){
					gridB.load([]);	
				}
			);
		}
		//試算
		,doCalculate : function(){

			var selectList =gridB.getCheckedRecord();	
			if(selectList.length==0){
				  alert("請至少選取一筆資料");
				  return;
			}

			for(var i=0; i<selectList.length; i++){
				var selectMap=selectList[i];			
				selectMap['ISTIC']='7';
				selectMap['PAY_TYPE']='7';
				
				var PAY_AMT=selectMap['PAY_AMT'];
				if(!PAY_AMT && PAY_AMT!=0){
					selectMap['PAY_AMT']=0;
				}
				
				var PAY_KIND=selectMap['PAY_KIND'];
				if(!PAY_KIND && PAY_KIND!=0){
					selectMap['PAY_KIND']=0;
				}
		
				var C33501_PAYOFF=selectMap['C33501_PAYOFF'];
				if(C33501_PAYOFF=="0"){
					selectMap['C33501_PAYOFF']="";
				}

				var PAY_DATE=selectMap['PAY_DATE'];
				
				//西元轉民國
				if(isDate(PAY_DATE)){
					PAY_DATE=toROC(PAY_DATE);
				}

				if(!isROCdate(PAY_DATE)){
					alert('請輸入正確的電匯日期:貸款帳號'+selectMap['LOAN_ID']);
					return;
				}

				PAY_AMT=selectMap['PAY_AMT'];
				PAY_KIND=selectMap['PAY_KIND'];
				if(PAY_KIND=='2' && (!PAY_AMT || PAY_AMT<=0)){
					alert('請輸入正確的部入金額:貸款帳號'+selectMap['LOAN_ID']);
					return;
				}
				
				if(PAY_KIND=='4' && (!PAY_AMT || PAY_AMT<=0)){
					alert('請輸入正確的暫收款金額:貸款帳號'+selectMap['LOAN_ID']);
					return;
				}
				
				C33501_PAYOFF=selectMap['C33501_PAYOFF'];
				if(PAY_KIND=='3' && !C33501_PAYOFF){
					alert('請輸入清償領取方式:貸款帳號'+selectMap['LOAN_ID']);
					return;
				}
				
				var LOAN_ID=selectMap['LOAN_ID'];
				if(LOAN_ID && 'X'==LOAN_ID.slice(-1) && PAY_KIND=='2' && selectMap['REMAIN_AMT']==0){
					if(!confirm('理財型帳號:'+LOAN_ID+',餘額為0，請確認是否要進行部入交易')){
						return;
					}	
				}
					
				selectMap['PAY_DATE']=toY2K(PAY_DATE);
				
			}

			var allList=gridB.getAllRecords();
			ajaxRequest.post( 'calculate', {'selectList' :Object.toJSON(selectList),'allList':Object.toJSON(allList)}
					,function(resp){	
						var totalList=resp.totalList;
						gridC.load(resp.calList||[],  totalList|| []);
						gridC.checkAll(true);
						$('T_DUTY_PAYMT').setValue(totalList[0]['value']['DUTY_PAYMT']);
						
						$('gridC').show();
						$('tableC').show();
						
						var errmsg=resp.errmsg||'';
						if(errmsg){
							 $('tableD').show();
							 $('MSG').update(errmsg);
						}	
						$('LOAN_ID_ACCOUNT').options.length = 2;
						buttons.setACCOUNT_NOList(resp);
						
						//reset 收據寄送方式，由作業人員重新點選
						$('SEND_TYPE').value="";
						$('EMAIL_LIST').update("");
						$('CONADDR_LIST').update("");
						
						//若是用貸款帳號查詢，《電匯通報作業明細畫面》【虛擬帳戶】帶入『該查詢帳號』，若是用ID查詢，《電匯通報作業明細畫面》【虛擬帳戶】帶入『各自通報』，使用者可修改。
						if($F('LINK_FROM')=='DSH00200'){
						    if($F('LOAN_ID')){
								$('LOAN_ID_ACCOUNT').value = $F('LOAN_ID');
							} else {
		                        $('LOAN_ID_ACCOUNT').value = "XX";
							} 
						}
					}
					,function(resp){
						 gridC.load([]);
					}
					
				);			
	
		}

		//確認
		,doConfirm : function(){

			valid1.reset();
			if(!valid1.validate()){
				return;
			}	
			var reqList =gridC.getCheckedRecord();	
			if(reqList.length==0){
				alert("請至少選取一筆欲審核資料");
				return;
			}
			
			for(var i=0; i<reqList.length; i++){
				var reqMap=reqList[i];			
				var TRANS_REMARK = reqMap['TRANS_REMARK'] || '';
				var REMARK = reqMap['REMARK'] || '';
				if (("9" == TRANS_REMARK) && !REMARK){
					alert("若備註選擇其他，請輸入其他備註");
					return;
				}
			}

			ajaxRequest.post(  
					'confirm' ,
					{'reqList':Object.toJSON(reqList), 'TRANS_AMT':$F('T_DUTY_PAYMT'), 'SEND_TYPE':$F('SEND_TYPE'), 'LOAN_ID_ACCOUNT':$F('LOAN_ID_ACCOUNT')},
					function(resp){	
						gridE.show();
						gridE.load(resp.rtnList || []);
					}
				);
	
		}	
		
		//繳款種類連動輸入金額欄位
		,PAY_KINDChangePAY_AMT: function(node, dataObj){
		
			var val=node.value;
			var input = gridB.getAutoInput(node,['PAY_AMT'])[0];
			if(val=='2' || val=='4'){	
				input["PAY_AMT"].readOnly=false;
				input["PAY_AMT"].value='';
				dataObj.PAY_AMT = '';
			}else{	
				input["PAY_AMT"].readOnly=true;
				input["PAY_AMT"].value=0;
				dataObj.PAY_AMT = 0;
			}
			
			var input2 = gridB.getAutoInput(node,['C33501_PAYOFF'])[0];
			if(val=='3'){	
				input2["C33501_PAYOFF"].disabled = false;
				input2["C33501_PAYOFF"].value='0';							
			}else{
				input2["C33501_PAYOFF"].disabled = true;
				input2["C33501_PAYOFF"].value='0';									
			} 		
			
		},
		
		//電匯日期控制
		controlPAY_DATE : function(e){
			var value = this.value;			
		},
		
	    //產生虛擬帳戶下拉選單
		setACCOUNT_NOList : function(resp){
		    var ACCOUNT_NOList = resp.ACCOUNT_NOList;									
			if(ACCOUNT_NOList){
				ACCOUNT_NOList.each(
					function(data) {
						var opt = new Option(data.LOAN_ID, data.LOAN_ID);
						$('LOAN_ID_ACCOUNT').add(opt);
					}		
				); 	
			}
		},
		changeSendType: function(){
			var selectList = gridC.getCheckedRecord();
			var emailText="";
			var conAddrText="";
			for(var i=0; i<selectList.length; i++){
				var selectMap=selectList[i];			
				if(selectMap['EMAIL']){
					emailText=emailText+selectMap['LOAN_ID']+",EMAIL:"+selectMap['EMAIL']+"<BR>";
				}else{
					emailText=emailText+selectMap['LOAN_ID']+",EMAIL:<font color='red'>未設定電子信箱</font><BR>";
				}
				
				if(selectMap['CON_ADDR']){
					if(selectMap['POST_REJECT'] && selectMap['POST_REJECT']=="Y"){
						conAddrText=conAddrText+selectMap['LOAN_ID']+",通訊地址:<font color='red'>郵件退件過，請先確認。</font><BR>";
					}else{
						conAddrText=conAddrText+selectMap['LOAN_ID']+",通訊地址:"+selectMap['CON_ADDR']+"<BR>";
					}
				}else{
					conAddrText=conAddrText+selectMap['LOAN_ID']+",通訊地址:<font color='red'>客戶通訊地址不詳，請先確認。</font><BR>";
				}				
			}
			
			$('EMAIL_LIST').update("");
			$('CONADDR_LIST').update("");
			if($F('SEND_TYPE')=="1"){
			//選擇書面(通訊地址)，才須顯示CON_ADDR(by LOAN_ID)
				$('CONADDR_LIST').update(conAddrText);
			}else if($F('SEND_TYPE')=="2"){
			//選擇電子收據，才須顯示email(by LOAN_ID)
				$('EMAIL_LIST').update(emailText);
			}
		},
		//修改
		doUpdate : function(){

			var reqMap =gridF.getAllRecords()[0];
					
			var TRANS_REMARK = reqMap['TRANS_REMARK'] || '';
			var REMARK = reqMap['REMARK'] || '';
			if (("9" == TRANS_REMARK) && !REMARK){
				alert("若備註選擇其他，請輸入其他備註");
				return;
			}	

			//檢核是否無設定電子信箱
			if("2" == reqMap['SEND_TYPE'] && !reqMap['EMAIL']){
				alert(reqMap['LOAN_ID']+",EMAIL:未設定電子信箱");
				return;
			}
				
			//檢核地址是否有問題
			if("1" == reqMap['SEND_TYPE'] && !reqMap['CON_ADDR']){	
				alert(reqMap['LOAN_ID']+",通訊地址:客戶通訊地址不詳，請先確認。");
				return;
			}
			
			if("1" == reqMap['SEND_TYPE'] && reqMap['CON_ADDR'] && reqMap['POST_REJECT']=="Y"){	
				alert(reqMap['LOAN_ID']+",通訊地址:郵件退件過，請先確認。");
				return;
			}							

			ajaxRequest.post('update' ,
					{'reqMap':Object.toJSON(reqMap)},
					function(resp){	
						gridF.load(resp.rtnList || []);
					},function(resp){
	
					}
				);
		}
	}
	
	var actions = {
		//231221問題單號:20230705-0268電匯通報作業畫面操作及檢核優化:調整全選也會連動合計
		doCalTotal : function( node , boxStatus , records ){ 
			var chkList = gridC.getCheckedRecord();
			var allList = gridC.getAllRecords();
			ajaxRequest.post( 'total', {'chkList':Object.toJSON(chkList),'allList':Object.toJSON(allList)},
				function(resp){
					var totalList=resp.totalList;
					gridC.load(resp.allList || [],  totalList|| [], null, ['Y']);								
					$('T_DUTY_PAYMT').setValue(totalList[0]['value']['DUTY_PAYMT']);
					$('LOAN_ID_ACCOUNT').options.length = 2;
					buttons.setACCOUNT_NOList(resp);
								
					buttons.changeSendType();
				}
			);			
		}
	}
	
	return {
			
		initApp : function(){
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay"/>
			PageUI.createPageWithAllBodySubElement('DSC33501', '收息作業', '電匯通報作業明細');
			
			gridB = new TableUI(
				{table: $("gridB"), allSortable: false, pageSize: 20,title:'查詢結果',
				autoCheckBox:{
				    isSelectAll: true,
					text:'選取',
					valueKey: 'preCheck',
					type:'checkbox'					
				},
				afterLoad : function() {
					$$('#gridB select[name=PAY_KIND]').each(function(ele){	
						var val=ele.value;
						var input = gridB.getAutoInput(ele,['PAY_AMT'])[0];
						if(val=='2' || val =='4'){	
							input["PAY_AMT"].readOnly=false;
						}else{	
							input["PAY_AMT"].readOnly=true;
						}
						
						var input2 = gridB.getAutoInput(ele,['C33501_PAYOFF'])[0];
						if(val=='3'){	
							input2["C33501_PAYOFF"].disabled = false;
						}else{
							input2["C33501_PAYOFF"].disabled = true;
						} 	
					});
				},				
				column:[
                    {header:"序號",key:"SEQ_NO"},
                    {header:"借款人姓名",key:"BORROW_NAME"},
                    {header:"借款人ID",key:"BORROW_ID"},	
                    {header:"貸款帳號",key:"LOAN_ID"},					
					{header:"繳款種類",key:"PAY_KIND",
						/*input:{type:"select" ,opts : PAY_KINDList,
							action:function( node , dataObj , textDiv, orgData ){  
									buttons.PAY_KINDChangePAY_AMT(node, dataObj[0]);
								}	
						}*/
						render : function(record, value){

							var LOAN_ID = record.LOAN_ID;
							var postFix=LOAN_ID.substr(LOAN_ID.length-1);
							var loanStatus=record.LOAN_STATUS;
							var select =  new Element("select",{name: 'PAY_KIND', id:'sPAY_KIND'+record.SEQ_NO}); //20190710給自動化測試能抓到
							var TMP_PAY_KIND;
							if($F('LINK_FROM')=='DSH00200'){
								TMP_PAY_KIND = $F('PAY_KIND_C');
							}
							$A(PAY_KINDList).each(function(item){
								if(("12"==loanStatus || "13"==loanStatus || "15"==loanStatus)){
									if(item.key=="9"){
										select.add(new Option(item.value,item.key));
											TMP_PAY_KIND = item.key;
									}										
								}else if("X"==postFix){
									if(item.key=='2'|| item.key=='2A'){
										select.add(new Option(item.value,item.key));
										if(!TMP_PAY_KIND){
											TMP_PAY_KIND = item.key;
										} else if ("3" == TMP_PAY_KIND){
											TMP_PAY_KIND = '2A';
										}										
									}
								}else if(item.key!="9" && item.key!='2A'){
									select.add(new Option(item.value,item.key));
									if(!TMP_PAY_KIND){
										TMP_PAY_KIND = item.key;
									}									
								}
							});
							
							if(TMP_PAY_KIND){
								select.setValue(TMP_PAY_KIND);
							}
								
							select.observe('change', function(event){
								var dataObj = gridB.isNew ? gridB.getDataObj(this) : this.up('tr').dataObj;
								dataObj.PAY_KIND=this.value;
								buttons.PAY_KINDChangePAY_AMT(this, dataObj);
							});
					
							record.PAY_KIND = TMP_PAY_KIND;
							return select;
						}						
					},	
					{header:"清償領取",key:"C33501_PAYOFF",
						input:{type:"select" ,opts : PAYOFF_LIMITList, attrs :{disabled :true}}
					},						
					/*{header:"繳款方式",key:"ISTIC",
						 input:{type:'select',
								opts:{'7':'電匯'}
						 }                               	
					},*/
					{header:"電匯日期",key:"PAY_DATE",
						input:{type:'rocdate', 
							   action:function( inputNode , Records , TextElement , orgData , isOnChange ){
									if(isOnChange){
										$A(gridB.getAllRecords()).each(function(record){
											record['PAY_DATE']=inputNode.value;
										})
										$$('#gridB input[key=PAY_DATE]').each(function(ele){	
											ele.value=inputNode.value;
										});
									}}}

					},		
					{header:"部入金額",key:"PAY_AMT", 
						render :function(record, value){
							if(value) {
								return value;
							}
							return 0;
						},
						input:{type:'number',attrs :{readOnly :true}
						}
					 }
				]
			});
			
			
			
			gridC = new TableUI(
				{table: $("gridC"), allSortable: false, title:'試算清單',split: ['TRANS_REMARK'],
				autoCheckBox:{
					isSelectAll:actions.doCalTotal,//231221問題單號:20230705-0268電匯通報作業畫面操作及檢核優化:調整全選也會連動合計
					text:'選取',
					type:'checkbox',
					valueKey: 'preCheck',
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
							}else if("2"==rec.PAY_KIND ){
								if("Y" == rec.IS_PAYOFF){
									return "部入結清";
								}
								return "部入";
							}else if("4"==rec.PAY_KIND ){	
								return "暫收款";
							}else {
								return val;
							}								
						}
					},
                    {header:"應繳日",key:"NEXT_PAYDT", sortRule: "date",
					    render : function (rec , val){
							if (rec.PAY_KIND=='0' && rec.THIS_TERM =='Y'){
							   return '<font color="red">'+val+'</font>'
							}else {
								return val;
							}								
						}},	
                    {header:"電匯日期",key:"PAY_DATE", sortRule: "date"},					
					{header:"應繳金額",key:"DUTY_PAYMT", sortRule: "number",
					    render : function (rec , val){
							if (rec.PAY_KIND=='0' && rec.THIS_TERM =='Y'){
							   return '<font color="red">'+val+'</font>'
							}else {
								return val;
							}								
						}},	
					{header:"適用利率",key:"RATE_VAL"},
					{header:"應攤本金",key:"PRINCIPAL", sortRule: "number"},
					{header:"利息",key:"INTEREST", renderInCount:true,
					    render: function (rec,val){				
							if(val ||val ===0){ 
								val=val+ (rec.RETAIN_INT || 0);
								return CSRUtil.$fmt(val,"#,###");
							}
							return "0";
						}},
					{header:"災戶攤繳息",key:"VICTIM_INT", sortRule: "number"},
					{header:"逾期息",key:"DELAY_INT", sortRule: "number"},
					{header:"違約金",key:"RENEGE", sortRule: "number"},
					{header:"管理費",key:"LAWSUIT_FEE", sortRule: "number"},
					{header:"上期結餘",key:"LAST_BALANCE", sortRule: "number"},
					{header:"代扣稅款",key:"TAX", sortRule: "number"},
					{header:"備註",key:"TRANS_REMARK",
						input:{type:"select" ,opts : TRANS_REMARKList,
							   action:function( inputNode , Records , TextElement , orgData , isOnChange ){
									if(isOnChange){
										$A(gridC.getAllRecords()).each(function(record){
											record['TRANS_REMARK']=inputNode.value;
										})
										$$('#gridC select[key=TRANS_REMARK]').each(function(ele){	
											ele.value=inputNode.value;
										});
										var name = "";
										if ("9" != inputNode.value && "" != inputNode.value){
											name = inputNode.options[inputNode.selectedIndex].innerText;
										}
										$A(gridC.getAllRecords()).each(function(record){
											record['REMARK']=name;
										})
										$$('#gridC input[key=REMARK]').each(function(ele){	
											ele.value=name;
										});
									}}					
						}
					},						
					{header:"其他備註",key:"REMARK",
						render :function(){
							return "";
						},
						input:{type:'text',maxlength:'80',width:'90',size:'80'
						},attrs:{colSpan:5}
					 },
					{header:"",key:"",  attrs:{colSpan:9}}
				]
			});
					
			gridE = new TableUI(
				{table: $("gridE"),allSortable: false,pageSize: 10,title:'電匯通報作業明細', overDiv:false,
				split: ['PROC_STATUS_NM','SEND_TYPE_NM'],<%--分割欄位ID--%> 
				column:[
                    {header:"貸款帳號",key:"LOAN_ID", attrs:{rowSpan:3}},				
					{header:"期數",key:"PAY_TERM", attrs:{rowSpan:3}},
					{header:"繳款別",key:"PAY_KIND_NM", attrs:{rowSpan:3},
						render: function (rec,val){	
							if("3"==rec.PAY_KIND){
								if("5"==rec.PAYOFF_LIMIT){
									return "清償(不領)";
								}else if("6"==rec.PAYOFF_LIMIT){
									return "清償(要領)";
								}else {
									return "清償";							
								}
							} else {
								return val;
							}
						}},
					{header:"電匯日期",key:"TRANS_DATE", sortRule: "date"},
					{header:"電匯帳號",key:"TRANS_NO_NM", attrs:{colSpan:2}},
					{header:"序號",key:"TRANS_SERNO"},
					{header:"電匯金額",key:"TRANS_AMT", sortRule: "number"},			
					{header:"應繳金額",key:"DUTY_PAYMT", sortRule: "number"},
					{header:"適用利率",key:"RATE"},
					{header:"應攤本金",key:"PRINCIPAL", sortRule: "number"},
					{header:"上期結餘",key:"LAST_BALANCE", sortRule: "number"},					
					{header:"輸入日期",key:"INPUT_DATE", sortRule: "datetime"},
					{header:"輸入人員",key:"INPUT_NM",attrs:{style:"font-family:'EUDC'"},
						render: function (rec,val){	
						    if (val) {
								return rec.INPUT_DEPT_NM + " " + val;
							}
							return "";
						}
					},													
					{header:"狀態",key:"PROC_STATUS_NM"},
					{header:"虛擬帳戶",key:"ACCOUNT_NO", attrs:{colSpan:2}},					
					{header:"利息",key:"INTEREST", renderInCount:true,
					    render: function (rec,val){				
							if(val ||val ===0){ 
								val=val+ (rec.RETAIN_INT || 0);
								return CSRUtil.$fmt(val,"#,###");
							}
							return "0";
						}},
					{header:"災戶攤繳息",key:"VICTIM_INT", sortRule: "number"},
					{header:"逾期息",key:"DELAY_INT", sortRule: "number"},
					{header:"違約金",key:"RENEGE", sortRule: "number"},
					{header:"管理費",key:"LAWSUIT_FEE", sortRule: "number"},
					{header:"代扣稅款",key:"TAX", sortRule: "number"},						
					{header:"入帳日期",key:"ACNT_DATE", sortRule: "datetime"},
					{header:"入帳人員",key:"ACNT_NM",attrs:{style:"font-family:'EUDC'"},
						render: function (rec,val){	
						    if (val) {
								return rec.ACNT_DEPT_NM + " " + val;
							}
							return "";
						}
					},	
					{header:"收據寄送方式",key:"SEND_TYPE_NM"},
					{header:"收據寄送地址",key:"SEND_ADDR", attrs:{colSpan:5}},	
					{header:"備註",key:"TRANS_REMARK_NM"},						
					{header:"其他備註",key:"REMARK", attrs:{colSpan:2}},					
					{header:"刪除日期",key:"DELETE_DATE", sortRule: "datetime"},
					{header:"刪除人員",key:"DELETE_NM",attrs:{style:"font-family:'EUDC'"},
						render: function (rec,val){	
						    if (val) {
								return rec.DELETE_DEPT_NM + " " + val;
							}
							return "";
						}
					}							
				]
			});

			gridF = new TableUI(
				{table: $("gridF"),allSortable: false,pageSize: 10,title:'電匯通報作業明細', overDiv:false,
				split: ['PROC_STATUS_NM','SEND_TYPE'],<%--分割欄位ID--%> 
				column:[
                    {header:"貸款帳號",key:"LOAN_ID", attrs:{rowSpan:3}},				
					{header:"期數",key:"PAY_TERM", attrs:{rowSpan:3}},
					{header:"繳款別",key:"PAY_KIND_NM", attrs:{rowSpan:3},
						render: function (rec,val){	
							if("3"==rec.PAY_KIND){
								if("5"==rec.PAYOFF_LIMIT){
									return "清償(不領)";
								}else if("6"==rec.PAYOFF_LIMIT){
									return "清償(要領)";
								}else {
									return "清償";							
								}
							} else {
								return val;
							}
						}},
					{header:"電匯日期",key:"TRANS_DATE", sortRule: "date"},
					{header:"電匯帳號",key:"TRANS_NO_NM", attrs:{colSpan:2}},
					{header:"序號",key:"TRANS_SERNO"},
					{header:"電匯金額",key:"TRANS_AMT", sortRule: "number"},			
					{header:"應繳金額",key:"DUTY_PAYMT", sortRule: "number"},
					{header:"適用利率",key:"RATE"},
					{header:"應攤本金",key:"PRINCIPAL", sortRule: "number"},	
					{header:"上期結餘",key:"LAST_BALANCE", sortRule: "number"},					
					{header:"輸入日期",key:"INPUT_DATE", sortRule: "datetime"},
					{header:"輸入人員",key:"INPUT_NM",attrs:{style:"font-family:'EUDC'"},
						render: function (rec,val){	
						    if (val) {
								return rec.INPUT_DEPT_NM + " " + val;
							}
							return "";
						}
					},											
					{header:"狀態",key:"PROC_STATUS_NM"},
					{header:"虛擬帳戶",key:"ACCOUNT_NO", attrs:{colSpan:2}},					
					{header:"利息",key:"INTEREST", renderInCount:true,
					    render: function (rec,val){				
							if(val ||val ===0){ 
								val=val+ (rec.RETAIN_INT || 0);
								return CSRUtil.$fmt(val,"#,###");
							}
							return "0";
						}},
					{header:"災戶攤繳息",key:"VICTIM_INT", sortRule: "number"},
					{header:"逾期息",key:"DELAY_INT", sortRule: "number"},
					{header:"違約金",key:"RENEGE", sortRule: "number"},
					{header:"管理費",key:"LAWSUIT_FEE", sortRule: "number"},
					{header:"代扣稅款",key:"TAX", sortRule: "number"},							
					{header:"入帳日期",key:"ACNT_DATE", sortRule: "datetime"},
					{header:"入帳人員",key:"ACNT_NM",attrs:{style:"font-family:'EUDC'"},
						render: function (rec,val){	
						    if (val) {
								return rec.ACNT_DEPT_NM + " " + val;
							}
							return "";
						}
					},			
					{header:"收據寄送方式",key:"SEND_TYPE",
						input:{type:"select" ,opts : SEND_TYPEList,
							   action:function( inputNode , Records , TextElement , orgData , isOnChange ){
									if(isOnChange){
										$A(gridF.getAllRecords()).each(function(record){
											record['SEND_TYPE']=inputNode.value;
										})
										$$('#gridF select[key=SEND_TYPE]').each(function(ele){	
											ele.value=inputNode.value;
										});
									}}					
						}														
					},
					{header:"收據寄送地址",key:"SEND_ADDR", attrs:{colSpan:5, style:"font-family:'EUDC'"}},							
					{header:"備註",key:"TRANS_REMARK",
						input:{type:"select" ,opts : TRANS_REMARKList,
							   action:function( inputNode , Records , TextElement , orgData , isOnChange ){
									if(isOnChange){
										$A(gridF.getAllRecords()).each(function(record){
											record['TRANS_REMARK']=inputNode.value;
										})
										$$('#gridF select[key=TRANS_REMARK]').each(function(ele){	
											ele.value=inputNode.value;
										});
										var name = "";
										if ("9" != inputNode.value && "" != inputNode.value){
											name = inputNode.options[inputNode.selectedIndex].innerText;
										}
										$A(gridF.getAllRecords()).each(function(record){
											record['REMARK']=name;
										})
										$$('#gridF input[key=REMARK]').each(function(ele){	
											ele.value=name;
										});
									}}					
						}
					},						
					{header:"其他備註",key:"REMARK",
						render :function(){
							return "";
						},
						input:{type:'text',maxlength:'80',width:'30',size:'30'
						},  attrs:{colSpan:2}
					},
					{header:"刪除日期",key:"DELETE_DATE", sortRule: "datetime"},
					{header:"刪除人員",key:"DELETE_NM",attrs:{style:"font-family:'EUDC'"},
						render: function (rec,val){	
						    if (val) {
								return rec.DELETE_DEPT_NM + " " + val;
							}
							return "";
						}
					}					
				]
			});

			initValidation();
			
			$('BTN_QUERY').observe('click', function(event){
				buttons.doQuery();
			});			
			
			$('BTN_CON').observe('click',buttons.doConfirm);
			$('BTN_CAL').observe('click',buttons.doCalculate);
			$('BTN_UPDATE').observe('click',buttons.doUpdate);
			
			//上一頁
			$('BTN_BACK').observe('click', function(event){	
				if(window.isPopupWin && window.popupWinBack){
				    // 呼叫callback Function(若有) 並關閉
					window.popupWinBack(); 
				}else if(window.parent && window.parent.popupWin){
					//呼叫callback Function(若有) 並關閉
					window.parent.popupWin.back();
				}else{
					CSRUtil.linkBack();
				}
			});	 
			

			$('BORROW_ID').observe('focus',function(event){
				$('LOAN_ID').setValue('');
				$('REFER_ID').setValue('');
			});
			$('LOAN_ID').observe('focus',function(event){
				$('BORROW_ID').setValue('');
				$('REFER_ID').setValue('');
			});
			$('REFER_ID').observe('focus',function(event){
				$('BORROW_ID').setValue('');
				$('LOAN_ID').setValue('');
			});			
			
			$('BORROW_ID').observe('keyup',function(event){
				formatUpperCase('BORROW_ID');
			});
			$('LOAN_ID').observe('keyup',function(event){
				formatUpperCase('LOAN_ID');
			});
			$('REFER_ID').observe('keyup',function(event){
				formatUpperCase('REFER_ID');
			});
			
			$('SEND_TYPE').observe('change',buttons.changeSendType);
			/*
			$('SEND_TYPE').observe('change',function(event){				
				if($F('SEND_TYPE')=="1"){
				//選擇書面(通訊地址)，才須顯示CON_ADDR(by LOAN_ID)
					$('EMAIL_LIST').update(emailText);
				}else if($F('SEND_TYPE')=="2"){
				//選擇電子收據，才須顯示email(by LOAN_ID)
					$('CONADDR_LIST').update(emailText);
				}else{
					$('EMAIL_LIST').update("");
					$('CONADDR_LIST').update("");
				}
			});
			*/
			
			//畫面區塊顯示控制
			$('gridB').hide();
			$('tableB').hide();
			$('gridC').hide();
			$('tableC').hide();
			$('tableD').hide();
			$('gridE').hide();	
				
			if($F('SOURCE')=='U'){
				$('tableA').hide();	
				var rtnList = <c:out value="${rtnList}" default="[]" escapeXml="false"/>;
				gridF.load(rtnList||[]);
				$('tableF').show();				
			}else if($F('SOURCE')=='I'){
				$('gridF').hide();	
				$('tableF').hide();
			}
            if($F('LINK_FROM')=='DSH00200'){
				buttons.doQuery("1");
			}
			parseEUDC();
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
<input id="SYS_DATE"  type="hidden" name="SYS_DATE" value='${SYS_DATE}'/>
<input id="SOURCE"  type="hidden" name="SOURCE" value='${SOURCE}'/>
<input id="T_DUTY_PAYMT"  type="hidden" name="T_DUTY_PAYMT"/>
<input id="LINK_FROM"  type="hidden" name="LINK_FROM" value='${LINK_FROM}'/>
<input id="PAY_DATE_C"  type="hidden" name="PAY_DATE_C" value='${PAY_DATE}'/>
<input id="PAY_KIND_C"  type="hidden" name="PAY_KIND_C" value='${PAY_KIND}'/>
<input id="isPROOF"  type="hidden" name="isPROOF" value='${isPROOF}'/>
<input id="PAY_AMT"  type="hidden" name="PAY_AMT" value='${PAY_AMT}'/>

<input id="BTN_BACK" type="button" value="上一頁" class="button" >	
	<table id='tableA' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow"  width='10%'>借款人ID</td>
		<td class="tbYellow2" width='15%'>
			<input id="BORROW_ID"  type="text" class="textBox2 " name="BORROW_ID" maxlength="10" onblur="this.value = this.value.toUpperCase()" value = "${BORROW_ID}"/>
		</td>	
		<td class="tbYellow"  width='10%'>貸款帳號</td>
		<td class="tbYellow2" width='15%'>
			<input id="LOAN_ID"  type="text" class="textBox2 " name="LOAN_ID" maxlength="10" value='${LOAN_ID}' onblur="this.value = this.value.toUpperCase()" />
		</td>
		<td class="tbYellow"  width='10%'>原貸帳號</td>
		<td class="tbYellow2" width='15%'>
			<input id="REFER_ID"  type="text" class="textBox2 " name="REFER_ID" maxlength="10" value='${REFER_ID}' onblur="this.value = this.value.toUpperCase()" />
		</td>		
		<td class="tbYellow2" width='25%' rowspan='2'>
			<input id="BTN_QUERY" type="button" value="查詢" class="button" >	
		</td>
	</tr>
	</table>
	<table id='gridB' ></table>
	<table id='tableB' width="100%">
		<tr>
			<td class="tbYellow2" width='40%'>
				<input id="BTN_CAL" type="button" value="試算" class="button" >	
			</td>
		</tr>
	</table>
	
	<table id='gridC' ></table>
	<table id='tableC' width="100%" class="tbBox2">
		<tr>
		    <td class="tbYellow" align="left" width='10%'>虛擬帳戶</td>
				<td class="tbYellow2" width='15%'>
				    <select id="LOAN_ID_ACCOUNT" >
						<option value = "" >請選擇</option>					
						<option value = "XX" >各自通報</option>
					</select>			
			</td>
			<td class="tbYellow"  width='10%'>收據寄送</td>
			<td class="tbYellow2" width='15%'>
				<select id="SEND_TYPE">
					<option value="">請選擇</option>
					<c:forEach var="map" items="${SEND_TYPEList}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>				
				</select> 
			</td>				
			<td class="tbYellow2">			
				<input id="BTN_CON" type="button" value="確認" class="button" >	
			</td>
			<td class="tbYellow2">			
				<span id="EMAIL_LIST" ></span>	
				<span id="CONADDR_LIST" ></span>
			</td>	
		</tr>
	</table>
	<table id='tableD' width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
		<tr>
		<td class="tbYellow0">
			<B>◎訊息:		
			<span id='MSG'></span>
			</B>
		</td>
		</tr>
	</table>

	<table id='gridE' ></table>
	<table id='gridF' ></table>	
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id='tableF'>
		<tr>
			<td class="tbYellow2" align= "center">			
				<input id="BTN_UPDATE" type="button" value="修改" class="button" >	
			</td>		
		</tr>
	</table>
</form>
</body>
</html>