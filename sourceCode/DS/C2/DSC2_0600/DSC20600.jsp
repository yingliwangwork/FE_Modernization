<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC20600.jsp
作者：卓達瑋
功能：單位帳務剔除
完成：2013/05/07

[20241030]修改件 CHROME瀏覽器難字調整
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<%--[20241030]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>		<%-- 匯出檔案用 --%>
<script type="text/JavaScript">

Event.observe(window, 'load', new DSC20600().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC20600(){
	
	//檢核
	var valid1;	
    var valid2;	
	//紀錄查詢時條件
	var queryMap_rc ={};
	//檢核欄位
	function initValidation(){
		valid1 = new Validation("form1", { focusOnError:true, immediate:false});				
 	    valid1.define('required' , [{ id : "LOAN_ID" , errMsg:'請輸入貸款帳號查詢!!'}] );
		valid1.define('required' , [{ id : "PAY_TERM" , errMsg:'請輸入繳款期數查詢!!'}] );
		valid1.define('required' , [{ id : "SEQ_NO" , errMsg:'請輸入序號查詢!!'}] );
		valid1.define('required' , [{ id : "PAY_KIND" , errMsg:'請輸入繳款別查詢!!'}] );
		valid2 = new Validation("form1", { focusOnError:true, immediate:false});	
        valid2.define('validate-number' , [{ id : "PAY_TERM" , errMsg:'繳款期數有誤，無法作業!!!'}] );
		valid2.define('validate-number' , [{ id : "SEQ_NO" , errMsg:'序號有誤，無法作業!!!'}] );
		
	}		
    //按鈕授權
		function buttonAuth() {
			var authButtons = { 
				B0170 : 'BTN_DELETE'    <%--剔除--%>
			};
			<dz:grantButtons FUNC_ID="DSC20600" ignored='false'/>
		}
	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_0600/" + actionName,
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
	};
	var actions= {
        //將畫面寫入Map	
	    queryMap : function(){
			return  {
				'LOAN_ID' : $F('LOAN_ID'), 
				'PAY_TERM' : $F('PAY_TERM'), 
				'PAY_KIND' : $F('PAY_KIND'),
                'SEQ_NO' : $F('SEQ_NO') 				
			}		
	    },
		//剔除時需要參數
		deleteMap : function(){
			return  {
				'OLD_LOAN_ID' : $F('OLD_LOAN_ID'), 
				'OLD_PAY_TERM' : $F('OLD_PAY_TERM'), 
				'OLD_SEQ_NO' : $F('OLD_SEQ_NO'),
                'OLD_PAY_KIND' : $F('OLD_PAY_KIND'), 				
				'PAY_TYPE' : $F('PAY_TYPE'),
                'CHECK_GROUP' : $('CHECK_GROUP').innerHTML,
                'CHECK_STATUS' : $F('CHECK_STATUS'),
                'USER_TRN_SERNO' : $F('USER_TRN_SERNO'),
                'DELT_KIND'	: $F('DELT_KIND'),
                'DELT_MEMO'	: $F('DELT_MEMO')	
			}		
	    },
		
	    //查詢後欄位設置
		dosuccessAction : function(resp){
	            //紀錄 rtnMap
                var rtnMap=resp.rtnMap||{};			
			    //span設值(日期)
		        $w('INT_BEGDT INT_ENDDT REAL_PAYDT DUTY_PAYDT CHECK_DATE LAST_PAYDT INPUT_DATE').each(
			        function(ele){
				        $(ele).update(Date.toROC(rtnMap[ele]||''));
				    }
			    )
				//span設值(金額)
				$w('PRINCIPAL TAX_CODE RENEGE LAWSUIT_FEE LAST_BALANCE LAST_PRINCIPAL THIS_BALANCE REAL_PAYMT INTEREST DELAY_INT').each(
			        function(ele){
				        $(ele).update(actions.numberFormat(rtnMap[ele]||'0'));
				    }
			    )
			
				$('DELAY_DAY').update(rtnMap['DELAY_DAY']||'0');
				//span設值
				$w('LOAN_STATUS_NM RATE RETAIN_INT PAY_TYPE_NM CHECK_STATUS_NM CHECK_GROUP INPUT_NM').each(
			        function(ele){
				        $(ele).update(rtnMap[ele]||'');
				    }
			    )
			    //input設值				
			    $w('OLD_LOAN_ID OLD_PAY_TERM OLD_SEQ_NO OLD_PAY_KIND PAY_TYPE CHECK_STATUS USER_TRN_SERNO DELT_MEMO').each(
			        function(ele){
				        $(ele).setValue(rtnMap[ele]||'');
				    }
			    )
				$('OLD_LOAN_ID').value = rtnMap['OLD_LOAN_ID']||'0';
				$('OLD_PAY_TERM').value = rtnMap['OLD_PAY_TERM']||'0';
				$('OLD_SEQ_NO').value = rtnMap['OLD_SEQ_NO']||'0';				
				$('OLD_PAY_KIND').value = rtnMap['OLD_PAY_KIND']||'0';
			
				$('DELT_KIND').value = rtnMap['DELT_KIND']||'0';
			
	
	    },
		
	    // 數值顯示方式處理
	    numberFormat : function (value) {
			return value ? MoneyFormat(value) : '';
		}
		
	}	
	// 功能按鈕
	var button = {
			
		// 查詢
		doQuery: function() {	
		    valid2.reset();
			//檢核
			if(!valid1.validate()){				
				return; 
			}
			ajaxPost( 'query', {'reqMap' :Object.toJSON(actions.queryMap())}
				,function(resp){
				    actions.dosuccessAction(resp);	
				}
				,function(resp){
                    actions.dosuccessAction(resp);
				}
			);
		},
        //剔除
        dodelete :function(){
		    valid1.reset();
			//檢核
			if(!valid2.validate()){				
				return; 
			}			
		
            if( $F('LOAN_ID')!=$F('OLD_LOAN_ID')||$F('PAY_KIND')!=$F('OLD_PAY_KIND')||$F('PAY_TERM')!=$F('OLD_PAY_TERM')||$F('SEQ_NO')!=$F('OLD_SEQ_NO')){
			    alert("欲剔除的貸款帳號、繳款別、繳款期數、序號與原先查詢的資料不同，無法作業!");
				return;
			}
            if($F('DELT_MEMO')==""||$F('DELT_KIND')=="0"){
			   alert("請輸入剔帳原因!");
				return;
			}
            if(!confirm( "確定要剔除?")){
				return;
			}			
			ajaxPost( 'delete', {'deleteMap' :Object.toJSON(actions.deleteMap()),'reqMap' :Object.toJSON(actions.queryMap())}
				,function(resp){
				    actions.dosuccessAction(resp);	
				}
			);	
		},
        //清除
		doCLEAR : function(event){
		    valid1.reset();
			valid2.reset();
            $('DELT_MEMO').setValue('');
			$('DELT_KIND').setValue('0');
            
			//設為初始值
			$('LOAN_ID').setValue(queryMap_rc['LOAN_ID'] ||'');
			$('PAY_TERM').setValue(queryMap_rc['PAY_TERM']||'');
			$('PAY_KIND').setValue(queryMap_rc['PAY_KIND']||'');
			$('SEQ_NO').setValue(queryMap_rc['SEQ_NO']||'');	
			
			if($('LOAN_ID').value){
				ajaxPost( 'query', {'reqMap' :Object.toJSON(queryMap_rc)}
					,function(resp){
						actions.dosuccessAction(resp);	
					}
					,function(resp){
						actions.dosuccessAction(resp);
					}
				);
			}else{
				actions.dosuccessAction({});
			}
		},
        // 上一頁
		doBack : function() {	
			if (window['callbackHandler']) {
				callbackHandler();
				close();
			} else if (parent && parent.popupWin ) {
				if (parent.popupWin.callbackHandler) { parent.popupWin.callbackHandler(); }
				close();
			} else {
				CSRUtil.linkBack();
			}
		}		
		
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSC20600" , "收息帳務", "單位帳務剔除" );

			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
				
			//畫面檢核
			initValidation();
			// 監聽
			$("BTN_QUERY").observe('click', button.doQuery);
			$("BTN_DELETE").observe('click', button.dodelete);
			$("BTN_CLEAR").observe('click', button.doCLEAR);
			$("BTN_BACK").observe('click', button.doBack);
			$('PAY_KIND').setValue('${PAY_KIND}');
            //Input欄位自動轉大寫
			$('LOAN_ID').observe('change',function(){
				$('LOAN_ID').value = $F('LOAN_ID').toUpperCase();
			});	
            if($F('LOAN_ID')!=""){
			    queryMap_rc=actions.queryMap();
				button.doQuery();
			}
			//按鈕權限
            buttonAuth()			
			PageUI.resize();	
			displayMessage();
		}
	}
}
</script>
</head>
<body>
<form name="form1" id="form1"  style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" >

<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
	<input type="hidden" id="OLD_LOAN_ID" value="" />
	<input type="hidden" id="OLD_PAY_TERM" value="" />
	<input type="hidden" id="OLD_SEQ_NO" value="" />
	<input type="hidden" id="OLD_PAY_KIND" value="" />
	<input type="hidden" id="PAY_TYPE" value="" />
	<input type="hidden" id="CHECK_STATUS" value="" />
	<input type="hidden" id="USER_TRN_SERNO" value="" />
	<tr>
		<td class='tbYellow' width='15%'>
			貸款帳號
		</td>
		<td class='tbYellow2' width='10%'>
			<input id='LOAN_ID' type='text' class= 'textBox2'   size='12' maxlength='10' value="${LOAN_ID}"/> 
		</td>
		<td class='tbYellow' width='15%'>
			繳款期數
		</td>
		<td class='tbYellow2' width='10%'>
			<input id='PAY_TERM' type='text' class= 'textBox2'   size='6' maxlength='3' value="${PAY_TERM}"/> 
		</td>
		<td class='tbYellow' width='15%'>
			序號
		</td>
		<td class='tbYellow2' width='10%'>
			<input id='SEQ_NO' type='text' class= 'textBox2'   size='4' maxlength='4' value="${SEQ_NO}"/> 
		</td>
		<td class='tbYellow' width='15%'>
			繳款別
		</td>
		<td class='tbYellow2' width='10%'>
			<select id="PAY_KIND" class="textBox2">
				<option value="">請選擇</option>
				<c:forEach items="${PAY_KIND_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		
		<td class="tbYellow2" width="10%" align="center">
			<input type="button" class="button" id="BTN_QUERY" value="查詢"<%-- 查詢 --%> />	
		    <input type="button" class="button" id="BTN_CLEAR" value="清除"<%-- 清除 --%> />					
		</td>
	</tr>

    <tr>
		<td  colspan="9" width="10%" align="center">
			<input type="button" class="button" id="BTN_DELETE" value="剔除"<%-- 剔除 --%> />					
		</td>
	</tr>
	
</table>
<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
	<tr>
		<td  width='15%'>
			剔帳原因
		</td>
	    <td  width='10%' colspan='5'>
			<select id="DELT_KIND" class="textBox2">
				<option value="0">請選擇</option>
				<c:forEach items="${DELT_KIND_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		    <input id='DELT_MEMO' type='text' class= 'textBox2'   size='63' maxlength='60' value=""/> 
		
		
		</td>
	</tr> 
    <tr>
	    <td class='tbYellow0' colspan='6' width='5%' align="center">
			<B>繳息明細</B>
		</td>
	</tr>
	<tr>
		<td class='tbYellow'  width='15%'>
			計息起日
		</td>
		<td class='tbYellow2' width='5%'>
			<span  id="INT_BEGDT" >	</span>	
		</td>
		<td class='tbYellow'   width='10%'>
			計息終日
		</td>
		<td class='tbYellow2'   colspan='3' width='5%'>
			<span  id="INT_ENDDT" >	</span>	
		</td>
		
	</tr>
	<tr>
		<td class='tbYellow'  width='15%'>
			實繳日
		</td>
		<td class='tbYellow2' width='10%'>
			<span  id="REAL_PAYDT">	</span>	
		</td>
		<td class='tbYellow'  width='10%'>
			應繳日
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="DUTY_PAYDT">	</span>	
		</td>
		<td class='tbYellow'  width='15%'>
			票據日
		</td>
		<td class='tbYellow2' width='10%'>
			<span  id="CHECK_DATE">	</span>	
		</td>

	</tr>
	<tr>
		<td class='tbYellow'  width='5%'>
			上次應繳日
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="LAST_PAYDT">	</span>	
		</td>
		<td class='tbYellow'  width='5%'>
			契約狀況
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="LOAN_STATUS_NM">	</span>	
		</td>

		<td class='tbYellow'  width='5%'>
			適用年利率
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="RATE">	</span>	%
		</td>

	</tr>
	<tr>
		<td class='tbYellow'  width='5%'>
			本金
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="PRINCIPAL">	</span>	
		</td>
		<td class='tbYellow'  width='5%'>
			利息
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="INTEREST">	</span>	
		</td>

		<td class='tbYellow'  width='5%'>
			延滯息
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="DELAY_INT">	</span>	
		</td>
	</tr>
		<tr>
		<td class='tbYellow'  width='5%'>
			違約金		
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="RENEGE">	</span>	
		</td>
		<td class='tbYellow'  width='5%'>
			訴訟管理費
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="LAWSUIT_FEE">	</span>	
		</td>

		<td class='tbYellow'  width='5%'>
			延滯天數
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="DELAY_DAY">	</span>	
		</td>
	</tr>
	</tr>
		<tr>
		<td class='tbYellow'  width='5%'>
			代扣稅款		
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="TAX_CODE">	</span>	
		</td>
		<td class='tbYellow'  width='5%'>
			上期結餘
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="LAST_BALANCE">	</span>	
		</td>

		<td class='tbYellow'  width='5%'>
			年底應提存利息
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="RETAIN_INT">	</span>	
		</td>
	</tr>
	</tr>
		<tr>
		<td class='tbYellow'  width='5%'>
			繳款前本金餘額款		
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="LAST_PRINCIPAL">	</span>	
		</td>
		<td class='tbYellow'  width='5%'>
			本期結餘
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="THIS_BALANCE">	</span>	
		</td>

		<td class='tbYellow'  width='5%'>
			繳款方式
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="PAY_TYPE_NM">	</span>	
		</td>
	</tr>
	</tr>
		<tr>
		<td class='tbYellow'  width='5%'>
			票據狀態		
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="CHECK_STATUS_NM">	</span>	
		</td>
		<td class='tbYellow'  width='5%'>
			實繳金額
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="REAL_PAYMT">	</span>	
		</td>
		<td class='tbYellow'  width='5%'>
			票據組號
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="CHECK_GROUP">	</span>	
		</td>
	</tr>
	<tr>
		<td class='tbYellow'  width='5%'>
			輸入人員		
		</td>
		<td class='tbYellow2' width='15%'>
			<%-- [20241030] 難字調整 --%><span  id="INPUT_NM" style="font-family:'EUDC'">	</span>	
		</td>
		<td class='tbYellow'  width='5%'>
			輸入日期
		</td>
		<td class='tbYellow2' width='15%' colspan='3'>
			<span  id="INPUT_DATE">	</span>	
		</td>
	    
	</tr>
    <tr>
	    <td align="center" colspan='6'>
		<input type= "button" class=  "button" value="回上一頁" id="BTN_BACK" >
	    </td> 
	</tr>	
	
	
</table>
</form>
</body>
</html>	