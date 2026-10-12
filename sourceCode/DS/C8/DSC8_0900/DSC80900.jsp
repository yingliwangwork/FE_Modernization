<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC80900.jsp
功能：原貸帳號變更
作者: 陳宥銓
完成：2013/06/20

[20230317] 修改程式  楊青峰
難字調整
 -->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<%-- [20230317] --%>
<style type="text/css">
	@font-face {
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
	         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	      font-weight: normal;
	      font-style: normal
	}
</style>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>       <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>   <%-- CSR相關處理用 --%>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>       <%-- 標準外框表格 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>       <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>

<script type='text/javascript'>
Event.observe(window, 'load', new DSC80900().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC80900(){
var grid;
var valid1;
var valid2;
var ReferList;

       function initValidation(){
            
            
            Validation.addAllThese([
				[ 'chkBORROW_ID', '', 
					function(v,elm) {				
						if((Validation.get('checkROCID').test(v))||(Validation.get('checkUniSN').test(v))){
							return true;
						}
						return false;
					}
				],
			]);
            
			valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			valid1.define( "required" , { id: "BORROW_ID_Q" , errMsg:"請輸入身份證字號，謝謝!!" } );
			valid1.define( "chkBORROW_ID" , { id: "BORROW_ID_Q" , errMsg:"身份證字號格式錯誤" } );	
			
			valid2 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			valid2.define( "required" , { id: "LOAN_ID_TEMP" , errMsg:"請輸入原貸件貸款帳號，謝謝!!" } );
			//valid2.define( "checkROCID" , { id: "LOAN_ID_TEMP" , errMsg:"原貸件貸款帳號格式錯誤" } );
			
		}
		
		//按鈕權限
	   function buttonAuth(){
		  var authButtons = {
			B0028:"BTN_CONFIRM"<%--確認--%>
		  };
		
		   <dz:grantButtons FUNC_ID="DSC80900" ignored="false"/>
	    }	
//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_0900/" + actionName,
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

	doQuery : function(event){
		
		valid2.reset();		

		if(!valid1.validate()){
				return;			
		}
		
		 $('LOAN_ID_TEMP').value='';
			 
		ajaxPost( 'query' , {'BORROW_ID':$F('BORROW_ID_Q')},
			 
			 function(resp){
			    ReferList = resp.rtnList || [];
			    grid.load(resp.rtnList);
			},
			
			function(resp){
			    grid.load([]);
			}
			
		);
	},
	
	
	doConfirm : function(){
		
		    valid1.reset();
			
			var recs=grid.getAllRecords();
			if(recs.length==0){
			   alert("請先查詢，謝謝 !")
			   return;
			}
			
			var checkedRecord = grid.getCheckedRecord(['LOAN_ID','REFER_ID']);
			if(checkedRecord.length==0){
				alert("請選取一筆資料");
				return;
			}	 
			
			 if(!valid2.validate()){
				return;			
		    }
			
			//2015-09-02檢核是否為同借款人的帳號
			var noREFER_ID = true;
			var LOAN_ID_TEMP = $('LOAN_ID_TEMP').value;
			if(LOAN_ID_TEMP.length != 10){
				alert("請輸入10碼之原貸帳號");
				return;				
			}
			for(var i = 0 ; i < ReferList.size() ; i++){
				var LOAN_ID =ReferList[i]['LOAN_ID'];
				if (LOAN_ID_TEMP == LOAN_ID){
					noREFER_ID = false;
					break;
				}
			}
			if(noREFER_ID){
				alert("欲變更之原貸帳號非此借款人借貸案件");
				return;			
			}
			
			ajaxPost( 'confirm', {dataList:Object.toJSON(checkedRecord),'LOAN_ID_TEMP':$F('LOAN_ID_TEMP'),'BORROW_ID':$F('BORROW_ID_Q')},
			    function(resp){
					grid.load(resp.rtnList);		
				},
				function(resp){
					grid.load([]);
				}
			);
	}
}
	return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC80900', '變更作業', '原貸款帳號變更');
								grid = new TableUI(
				{table: $("grid"), pageSize : 10, allSortable: false, overDiv:true,	 split: ['DOWN'],
					autoCheckBox:{
							text:'選取', 
							type:'checkbox',
							isSelectAll:true 
				}, pageChange:function(){
					$$('#grid input[type=text]').each(
						function(ele){
							ele.readOnly = true;
						}
					)
					
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); } <%-- [20230317] --%>
				},
				<%-- [20230317] --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[	
					
					{header:"貸款帳號", key:"LOAN_ID",
					    input:{ 
						type:'TEXT' , size:13
						}
					},
					{header:"原貸帳號",key:"REFER_ID",
						render:function(record, value){
							return '<font color="red">' + value + '</font>';
						}
					},
					{header:"姓名",key:"BORROW_NAME"},
					{header:"貸款日期",key:"LOAN_DATE"},
					{header:"貸款類別",key:"LOAN_TYPE_NM"},
					{header:"契約狀態",key:"LOAN_STATUS_NM"},
					{header:'',key:"DOWN"},
					{header:''},
					{header:"擔保品地址",key:"GAGE_ADDR"},
					{header:''},
					{header:''},
					{header:''}
				]
				});

				//註冊DOM物件 : 監聽
				$('BTN_QUERY').observe('click', buttons.doQuery);  //查詢
                $('BTN_CONFIRM').observe('click', buttons.doConfirm);  //變更
               
                initValidation();
				
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
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="1%">身分證字號</td>
			<td class="tbYellow2" width="2%">
				<input id="BORROW_ID_Q" type="text" class="textBox2" maxlength='10' onblur="this.value = this.value.toUpperCase()" />
			</td>	
			<td class="tbYellow2" width="2%" align='center'>
			    <input id="BTN_QUERY" type="button" value="查詢" class="button" >
			</td>
		</tr>
		<tr>
		     <td class="tbYellow0" width="5%" align='center' colspan='8'>原貸款帳號變更</td>
		</tr>
		<tr>
			<td class="tbYellow" width="1%" align='center'>原貸件貸款帳號</td>
			<td class="tbYellow2" width="1%" >
				<input id="LOAN_ID_TEMP" type="text" class="textBox2" maxlength='10' onblur="this.value = this.value.toUpperCase()" />
			</td>	
			<td class="tbYellow2" width="4%">
			    <input id="BTN_CONFIRM" type="button" value="確認" class="button" >
			</td>
		</tr>
	</table>
	<table id = "grid" ></table>
</form>
</body>
</html>