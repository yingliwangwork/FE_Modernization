<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!--
程式：DSC81700.jsp
作者：陳宥銓
功能：優質客戶變更
完成：2013/06/24

[20230321]
難字調整
高強禾
-->
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<title></title>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>       <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>   <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>   <!--alert訊息-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>  <%-- 日曆用--%>
<script type="text/javascript">

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSC81700().initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC81700(){

var valid1;
var valid2;
var updateRecord = {};

	//畫面檢核：變更
	function  initValidation(){
	     valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
		 valid1.define( "required", { id: "LOAN_ID_Q" , errMsg:"請輸入貸款帳號，謝謝!!" } );
		
		valid2 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
		 valid2.define( "required", { id: "NEW_VIP_BEGDT" , errMsg:"請輸入新優惠起日，謝謝!!" } );
		 valid2.define("validate-ROCDate",{ id: "NEW_VIP_BEGDT" , errMsg:"新優惠起日格式有誤，謝謝!!" });
		 valid2.define( "required", { id: "NEW_VIP_GRADE" , errMsg:"請拉選新優惠等級，謝謝!!" } );
		 
	}
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			B004:"btn_update"<%--輸入--%>
		};
		
		<dz:grantButtons FUNC_ID="DSC81700" ignored="false"/>
	}	

	
	
	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_1700/" + actionName,
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
		     
			  valid2.reset();

			if(!valid1.validate()){
				return;			
		     }
		
			ajaxPost( 'query' , {'LOAN_ID':$F('LOAN_ID_Q')},
				function(resp){
					
					 //查詢成功,載入資料	
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};		
		            $('BORROW_NAME').value = rtnMap.BORROW_NAME || '' ;
					$('BORROW_NAME_Q').value = rtnMap.BORROW_NAME || '' ;
					$('VIP_BEGDT').value  = rtnMap.VIP_BEGDT || '';
					$('VIP_GRADE').value = rtnMap.VIP_GRADE || '';
					$('NEW_VIP_GRADE').value = '';
					updateRecord = rtnMap;
					
				},
				function(resp){
				    //失敗把前次內容清掉 
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					$('BORROW_NAME').value = '';
					$('BORROW_NAME_Q').value = '';
					$('VIP_BEGDT').value  = '';
					$('VIP_GRADE').value = '';
					$('NEW_VIP_GRADE').value = '';
					 updateRecord = {};
				
				}
			);	
		},
		
		doUpdate : function(event){	
		
		      valid1.reset();
			 
		
			 
			 if(!updateRecord || !updateRecord.BORROW_NAME || updateRecord.BORROW_NAME != $F('BORROW_NAME')){
				alert("查詢後才能變更!");
				return ;
			}
					


			if(updateRecord.LOAN_ID != $F('LOAN_ID_Q')){
			   alert("欲變更的貸款帳號與原先查詢的貸款帳號不同，無法作業!!");
			   return ;
			}
			
			 if(!valid2.validate()){
				return;			
		     }
			
			
	        var reqMap={
				  LOAN_ID:$F('LOAN_ID_Q'),
				  BORROW_NAME:$F('BORROW_NAME_Q'),
				  VIP_BEGDT:$F('VIP_BEGDT'),
				  VIP_GRADE:$F('VIP_GRADE'),
				  NEW_VIP_BEGDT:$F('NEW_VIP_BEGDT'),
				  NEW_VIP_GRADE:$F('NEW_VIP_GRADE')
			      };				
			ajaxPost( 'update' , {'reqMap':Object.toJSON(reqMap),'LOAN_ID':$F('LOAN_ID_Q')},
			   function(resp){
				  
			   }
			);	
		}
};
			
return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC81700', '變更作業', '優質客戶變更');
				
				//-----------------------------------------------------
				//以下為進入初始頁面時需要執行的動作
				//-----------------------------------------------------
				
				
				//註冊DOM物件 : 監聽
				$('btn_query').observe('click', buttons.doQuery);  //查詢
                $('btn_update').observe('click', buttons.doUpdate);  //變更
                
                
                initValidation();
				
				
				//初始頁面alert訊息用	
				displayMessage();
				
				PageUI.resize();
				
			}// end initApp()
	};// end return--

}

</script>
</head>
<body>
<form name="form" id="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" action="">

<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2' id='table1''>
     <tr>
	     <td class='tbYellow' width='10%'>
		                 貸款帳號
		 </td>
		 <td class='tbYellow2'  colspan='3' width='15%' align='left'>
			<input id='LOAN_ID_Q' type='text' class= 'textBox2'   size='12' maxlength='10'  onblur="this.value = this.value.toUpperCase()" /> 
		</td>
        <td class='tbYellow2' colspan='2' align='left' >
			<input id='btn_query' type='button' class='button' value='查詢' />
			<input id='btn_update' type='button' class='button' value='變更' />
		</td>
	 </tr>
	
	<tr>
	<td class='tbYellow' width='10%'>
	                  借款人姓名
	</td>		
	<td class='tbYellow2' width='10%'  align='left'>
		<%-- [20230321] 難字調整 --%>
		<input id='BORROW_NAME' type='text' class='textBox2' size='12' maxlength='10' alt='ch' readOnly /> 
	</td>		
	<td class='tbYellow' width='10%'>
	                  原優惠起日
	</td>	
	<td class='tbYellow2' width='10%' align='left'>
	          <input id='VIP_BEGDT' type='text' class= 'textBox2'   size='12' maxlength='10' readOnly /> 
	</td>	
	<td class='tbYellow' width='10%'>
	                  原優惠等級
	</td>	
	<td class='tbYellow2' width='10%' align='left'>
	        <select id='VIP_GRADE' class='textBox2' maxlength='15'  disabled> 
				<option value =''>請選擇</option>
				<c:forEach var='item' items='${VIP_GRADE_List}'>
					<option value='${item.key}' <c:if test=''>selected</c:if>><c:out value= '${item.value}' /></option>
				</c:forEach>
			</select>
			   
	</td>	
	<tr>
		<td class='tbBox3' colspan='10' align='center'>
			 優質客戶變更
		</td>
	</tr>
	</tr>
    
    <tr>
	<td class='tbYellow' width='10%'>
	                  借款人姓名
	</td>		
	<td class='tbYellow2' width='15%' align='left'>
		<%-- [20230321] 難字調整 --%>
		<input id='BORROW_NAME_Q' type='text' class='textBox2' size='12' maxlength='10' alt='ch' readOnly /> 
	</td>
	<td class='tbYellow' width='10%'>
	                  新優惠起日
	</td>	
	<td class='tbYellow2' width='15%' align='left'>
			<input id='NEW_VIP_BEGDT' datatype ='ROCDate' type='text' class= 'textBox2'  size='9' maxlength='7' value='${SYS_DATE}'/> 
			<img src="/DSWeb/images/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('NEW_VIP_BEGDT'))">
		</td>
	<td class='tbYellow' width='10%'>
	                  新優惠等級
	</td>		
	<td class='tbYellow2' width='15%' align='left'>
			   <select id='NEW_VIP_GRADE' class='textBox2' maxlength='15' > 
				<option value =''>請選擇</option>
				<c:forEach var='item' items='${VIP_GRADE_List}'>
					<option value='${item.key}'><c:out value= '${item.value}' /></option>
				</c:forEach>
			</select>
	</td>
	</tr>
	
	<tr>
		<td class='tbYellow2'  colspan='6' align='left'>
			<br>
			 ※在新優惠起日有個別優惠者，不得作優質客戶變更</br>
			 ※9803起，退休員工等級擴充定義，變更為特定員工等級 ( 含退休員工、轉關係企業員工、行專件) </br>	
			 ※請先查詢再變更。<br>
			 <br>
		</td>
	</tr>
</table>

</form>
</body>
</html>