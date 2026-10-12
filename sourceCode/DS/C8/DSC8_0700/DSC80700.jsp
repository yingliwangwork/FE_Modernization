<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!--
程式：DSC80700.jsp
作者：陳宥銓
功能：收費代號變更 
完成：2013/06/10

[20230317] 修改程式  楊青峰
難字調整
-->
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

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

<title></title>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<!--alert訊息-->
<script type="text/javascript">

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSC80700().initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC80700(){

	var valid1;
	var valid2;
	
	

	//畫面檢核：變更
	var initValidation = function(){
	
		Validation.addAllThese([		
			[ 'checkInpute',  '新收費代號欄位必須有值且大於3碼!!',
				function(v){
					return 	v.length>3 ? true : false;
				}
			]
		]);
		
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid1.define( "checkInpute" , { id: 'GETINT_CODE2' } );
		
		valid2 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			Validation.addAllThese( [
				[ 'chkLength', '請輸入正確貸款帳號查詢!', function( v ) { return chkLength($F('LOAN_ID'));}]
			] );
			valid2.define( "chkLength" , [{ id : "LOAN_ID" } ] );
	};
	
	// 檢核貸款帳號長度
	var chkLength = function (LOAN_ID) 
	{		
		var chk = true;
		if(LOAN_ID.length != 10 || !(/^[a-zA-Z0-9]+$/.test(LOAN_ID))) {
			chk = false; 
		}
		return chk; 	
	};
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			B004:"btn_update"<%--輸入--%>
		};
		
		<dz:grantButtons FUNC_ID="DSC80700" ignored="false"/>
	}	

	//更新前查詢檢核變數
	var updateRecord = {};
	
	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_0700/" + actionName,
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

//buttons對應的event function
var buttons = {	
		
		//查詢資料
		doQuery : function(event){	
		
			valid1.reset();
				
			// 檢核
			if(!valid2.validate()){ 
				return; 
			}
				
			ajaxPost( 'query' , {'LOAN_ID':$('LOAN_ID').value },
				function(resp){
					
					 //查詢成功,載入資料	
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};				
					$('BORROW_NAME').innerHTML = rtnMap.BORROW_NAME || '' ;
					$('LOAN_STATUS_NM').innerHTML = rtnMap.LOAN_STATUS_NM || '';
					$('GETINT_DEPT').innerHTML = rtnMap.GETINT_DEPT || '';
					$('GETINT_CODE1').value = rtnMap.GETINT_CODE1 || '';
					$('GETINT_CODE2').value = '';
					
					updateRecord = rtnMap;
					
				},
				function(resp){
				    //失敗把前次內容清掉 
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					$('BORROW_NAME').innerHTML = '';
					$('LOAN_STATUS_NM').innerHTML = '';
					$('GETINT_DEPT').innerHTML = '';
					$('GETINT_CODE1').value= '';
					$('GETINT_CODE2').value = '';
					
					updateRecord = {};
				}
			);	
		},
		
		doUpdate : function(event){	
			 if(!updateRecord || !updateRecord.LOAN_ID ){
				alert("查詢後才能變更!");
				return ;
			}
					
			
			if(!valid1.validate()){
				return;			
			}

			if(updateRecord.LOAN_ID != $F('LOAN_ID')){
			   alert("欲變更的貸款帳號與原先查詢的貸款帳號不同，無法作業!!");
			   return ;
			}
	        var reqMap={
				  LOAN_ID:$F('LOAN_ID'),
				  GETINT_DEPT:$('GETINT_DEPT').innerHTML,
				  GETINT_CODE1:$F('GETINT_CODE1'),
				  GETINT_CODE2:$F('GETINT_CODE2')
			      };				
			ajaxPost( 'update' , {'reqMap':Object.toJSON(reqMap),'LOAN_ID':$F('LOAN_ID') },
			   function(resp){
				  	var rtnMap = resp.rtnMap ? resp.rtnMap : {};				
					$('BORROW_NAME').innerHTML = rtnMap.BORROW_NAME || '' ;
					$('LOAN_STATUS_NM').innerHTML = rtnMap.LOAN_STATUS_NM || '';
					$('GETINT_DEPT').innerHTML = rtnMap.GETINT_DEPT || '';
					$('GETINT_CODE1').value = rtnMap.GETINT_CODE1 || '';
					$('GETINT_CODE2').value = '';
			   }
			);	
		}
};
			
return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC80700', '收息資料更新', '收費代號變更');
				
				//-----------------------------------------------------
				//以下為進入初始頁面時需要執行的動作
				//-----------------------------------------------------
				
				initValidation();
				
				//註冊DOM物件 : 監聽
				$('btn_query').observe('click', buttons.doQuery);  //查詢
                $('btn_update').observe('click', buttons.doUpdate);  //變更
                //LOAN_ID大寫
                $('LOAN_ID').observe('blur',function(event){
                	$('LOAN_ID').value=$F('LOAN_ID').toUpperCase();
                });
                
                //新收費代號自動轉大寫
                $('GETINT_CODE2').observe('blur',function(event){
                	$('GETINT_CODE2').value=$F('GETINT_CODE2').toUpperCase();
                });
				
				//初始時執行查詢功能
				if('${LOAN_ID}'){
					$('LOAN_ID').value = '${LOAN_ID}';	
					buttons.doQuery();
				}
				
				
				//初始頁面alert訊息用	
				displayMessage();
				
				PageUI.resize();
				
			}// end initApp()
	};// end return--

}

</script>
</head>
<body>
<form name="form1" id="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" action="">

<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2' id='table1''>
     <tr>
	     <td class='tbYellow' width='10%'>
		                 貸款帳號
		 </td>
		 <td class='tbYellow2' width='15%'>
			<input id='LOAN_ID' type='text' class= 'textBox2'   size='12' maxlength='10' /> 
		</td>
        <td class='tbYellow2' colspan='5' align='left'>
			<input id='btn_query' type='button' class='button' value='查詢' />
			<input id='btn_update' type='button' class='button' value='變更' />
		</td>
	 </tr>
	
	<tr>
		<td class='tbBox3' colspan='10' align='center'>
			變更記錄明細表
		</td>
	</tr>
	
	<tr>
	<td class='tbYellow' width='10%'>
	                  借款人
	</td>		
	<td class='tbYellow2' width='10%' id='BORROW_NAME'  align='left' style="font-family: 'EUDC'"> <%-- [20230317] --%>
	</td>		
	<td class='tbYellow' width='10%'>
	                  契約狀態
	</td>	
	<td class='tbYellow2' width='10%' align='left'>
	          <font id='LOAN_STATUS_NM' color='blue'> </font>
	</td>	
	<td class='tbYellow' width='10%'>
	                  收息單位
	</td>	
	<td class='tbYellow2' width='10%' id='GETINT_DEPT'  align='left'>
	</td>	
	</tr>
    
    <tr>
	<td class='tbYellow' width='10%'>
	                  原收費代號
	</td>		
	<td class='tbYellow2' width='15%'>
			<input id='GETINT_CODE1' type='text' class= 'textBox2'   size='12' maxlength='10' readOnly /> 
		</td>
	<td class='tbYellow' width='10%'>
	                  新收費代號
	</td>	
	<td class='tbYellow2' width='15%' colspan="3">
			<input id='GETINT_CODE2' type='text' class= 'textBox2'   size='12' maxlength='7'  size="8"/> 
		</td>
	</tr>
</table>

</form>
</body>
</html>