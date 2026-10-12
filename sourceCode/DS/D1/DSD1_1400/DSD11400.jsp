<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSD11400.jsp
功能：單筆移送法務查詢
作者：卓達瑋
完成：2013/08/28

[20240326]
難字調整
高強禾
 --> 

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<%-- [20240326] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type="text/javascript">


Event.observe(window, 'load', new DSD11400().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD11400(){
	
    var grid;
	
	//按扭權限
	function buttonAuth(){
		var authButtons = {
				B0218:"BTN_CONFIRM" 			
			
		};
	
		<dz:grantButtons FUNC_ID="DSD11400" />
	}
	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_1400/" + actionName,
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
			}
		);
	}

	//按鈕功能	
	var buttons = {
		//初始查詢
		doQuery : function(){		
            var REFER_ID=$F('REFER_ID');
			var LOAN_ID=$F('LOAN_ID');
			var BORROW_ID=$F('BORROW_ID');
			var BORROW_NAME=$F('BORROW_NAME');
			if(!REFER_ID&&!LOAN_ID&&!BORROW_ID&&!BORROW_NAME){
			    alert("請至少輸入一項查詢條件");
                return;				
			}
			var reqMap={};
			reqMap['REFER_ID']=REFER_ID;
			reqMap['LOAN_ID']=LOAN_ID;
			reqMap['BORROW_ID']=BORROW_ID;
			reqMap['BORROW_NAME']=BORROW_NAME;
			ajaxPost( 'query' , { reqMap : Object.toJSON(reqMap)},
				function(resp){						
				    grid.load(resp.rtnList||'');
				},
				function(resp){
					 grid.load('');
				}
			);
		},
		//移送法務
		doConfirm : function(){
			var tmpList = grid.getCheckedRecord();			
				if( tmpList.length == 0 ){
					alert('至少需選擇一筆資料!');
					return;			
				}
				ajaxPost( 'confirm' , { reqList : Object.toJSON(tmpList)});
		}
		
	};
	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSD11400','催收作業','單筆移送法務');
			
			//產生 Grid 物件	
			grid = new TableUI({
				table: $('grid'), pageSize: 10, allSortable: true,	
				autoCheckBox:{
					text:'選取',
                    isSelectAll :true,					
					type:'checkbox',
					returnValue:["LOAN_ID"]
				},
				<%-- [20240326] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column: [
				    {header:"帳號", key:'LOAN_ID',
					    render:function(rec , val){ 							
						if(val){
							//超連結至 ”DSD01800” 催收明細作業畫面。
							var link = new Element( 'a' , { href : "#" } ).update(val);	
							link.observe( 'click', function (event){ 
                                var url = "<%=dispatcher%>/DSD1_1800/prompt?LOAN_ID="+val+"&INPUT_TYPE=2";									
							    window.open(url, "DSD1_1400", "top=250, left=250, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=900, height=600");	
							});										
							return link; 															
						}
						return '';
						}
					
					},
					<%-- [20240326] 難字調整：姓名 --%>
					{header:"姓名", key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header:"收息單位", key:'DEPT_ID'},
					{header:"契約狀況", key:'LOAN_STATUS_NM'},
					{header:"已繳期數", key:'PAID_TIMES',
					    render :function(record,value){
						    return (value||value===0) ? CSRUtil.$fmt(value,"#,###") : 0;
						}
					},
					{header:"上次應繳日", key:'LAST_PAYDT',
					    render :function(record,value){
						    return Date.toROC( value|| '');
						}
					},
					{header:"下次應繳日", key:'NEXT_PAYDT',
					    render :function(record,value){
						    return Date.toROC( value|| '');
						}
					},
					{header:"貸款餘額", key:'REMAIN_AMT',
					    render :function(record,value){
						    return (value||value===0) ? CSRUtil.$fmt(value,"#,###") : 0;
						}
					},
				    {header:"白天電話", key:'DAY_TEL_AREA'
					    ,render : function(record, value){
							var DAY_TEL_NUM=record.DAY_TEL_NUM||'';
							var DAY_TEL_EXT=record.DAY_TEL_EXT||'';
						    if(value){
						       	return value +"-"+(DAY_TEL_NUM ||'')+(DAY_TEL_EXT?"#":"")+(DAY_TEL_EXT||'');
						    }else{
						        return (DAY_TEL_NUM ||'')+(DAY_TEL_EXT?"#":"")+(DAY_TEL_EXT||''); 
							}							
						}
					},
					{header:"夜間電話", key:'NIGHT_TEL_AREA'
					    ,render : function(record, value){
							var NIGHT_TEL_NUM=record.NIGHT_TEL_NUM||'';
							var NIGHT_TEL_EXT=record.NIGHT_TEL_EXT||'';
						    if(value){
						       	return value +"-"+(NIGHT_TEL_NUM ||'')+(NIGHT_TEL_EXT?"#":"")+(NIGHT_TEL_EXT||'');
						    }else{
						        return (NIGHT_TEL_NUM ||'')+(NIGHT_TEL_EXT?"#":"")+(NIGHT_TEL_EXT||''); 
							}							
						}
					},
					{header:"行動電話", key:'MOBILE'}
				]	
			});	
			
			
			buttonAuth();
			//按鈕事件監聽
			$('BTN_QUERY').observe('click',buttons.doQuery); 
            $('BTN_CONFIRM').observe('click',buttons.doConfirm); 
			//Input欄位自動轉大寫
			$('BORROW_ID').observe('change',function(){
				$('BORROW_ID').value = $F('BORROW_ID').toUpperCase();

			});	
			$('BORROW_ID').observe('click',function(){
				$('REFER_ID').value = '';
				$('LOAN_ID').value = '';
				$('BORROW_NAME').value = '';
			});	

			$('REFER_ID').observe('change',function(){
				$('REFER_ID').value = $F('REFER_ID').toUpperCase();
			});	
			$('REFER_ID').observe('click',function(){
				$('BORROW_ID').value = '';
				$('LOAN_ID').value = '';
				$('BORROW_NAME').value = '';
			});	

			$('LOAN_ID').observe('change',function(){
				$('LOAN_ID').value = $F('LOAN_ID').toUpperCase();
				
			});
            $('LOAN_ID').observe('click',function(){
				$('REFER_ID').value = '';
				$('BORROW_ID').value = '';
				$('BORROW_NAME').value = '';
			});
			
			$('BORROW_NAME').observe('click',function(){
				$('LOAN_ID').value = '';
				$('REFER_ID').value = '';
				$('BORROW_ID').value = '';
			});	
            //$('form1').hide();
			
			PageUI.resize();
			displayMessage();
						
		}
	}
}
</script>
</head>

<body>
    <table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>					
				<td class="tbYellow" width="8%" align="left">原貸帳號</td>
				<td class="tbYellow2"  >
					<input id="REFER_ID" type="text" size='12' maxlength="10" />
				</td>
	            <td class="tbYellow" align='left'>貸款帳號</td>
			    <td class="tbYellow2">    
					<input id="LOAN_ID" type="text" size='12' maxlength="10" />
			    </td>
				<td class="tbYellow" align='left'>借款人ID</td>
			    <td class="tbYellow2">    
					<input id="BORROW_ID" type="text" size='12' maxlength="10" />
			    </td>
				<td class="tbYellow" align='left'>借款人姓名</td>
			    <td class="tbYellow2">    
					<%-- [20240326] 難字調整：借款人姓名 --%>
					<input id="BORROW_NAME" type="text" size='12' maxlength="10" alt="ch" />
			    </td>
				
			    <td class="tbYellow2" width="15%">    
					<input type="button" class="button" id="BTN_QUERY" value="查詢"/>	
			    </td>
			</tr>
			<tr>
				<td colspan='9' align='center'>
					<input type="button" class="button" id="BTN_CONFIRM" value="移送法務"/>	
				</td>
			</tr>

		</table>


	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		
		<table id="grid" width="100%" class="grid" ></table>
	    <table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
		    <tr>
			    <td class="tbYellow2">    
			        <font color="blue"><b>一、作業說明</b></font><br>   
			        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.各種貸款規定請參照放款作業手冊及發文規定。<br>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.本作業提供區部催收人員將符合移送法務之案件做移送處理。<br>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3.該作業提供以<font color="red">借款人</font>的角度篩選符合移送法務條件之案件。<br>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.讓使用者可在作業時間內快速完成所需之處理程序。<br>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5.本作業主要是將貸款案件之契約狀況異動為<font color="blue">「移送法務中」</font>及將該帳號之相關資料
					<font color="blue">寫入法務檔</font>，<br>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;並與法務作業中之<font color="red">【法務到案確認】</font>為一連貫程序。<br>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;6.該案件需待被派件之法務人員作<font color="blue">到案確認作業</font>後，該案件才算正式進入<font color="red">法務程序</font>。<br>
					<font color="blue"><b>二、操作方式</b></font><br>  
				    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.使用者可將欲<font color="red">移送法辦</font>的案件打勾，再予以送出即可。
			</tr>
        </table>
	</form>	
</body>
</html>