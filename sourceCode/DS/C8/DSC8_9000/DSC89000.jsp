<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!--
程式：DSC89000.jsp
作者：卓達瑋
功能：放款表單套印
完成：2013/06/20

[20220517]立案單號220427008633 新增商火續保書列印
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript">

var dsc89000 = new DSC89000();

Event.observe(window, 'load', dsc89000.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC89000(){
    var grid;
	//按鈕授權
    //檢核
	var valid1;	
	//紀錄查詢條件
	//var queryMap_rc;
	
	//檢核欄位
	function initValidation(){
		valid1 = new Validation("form1", { focusOnError:true, immediate:false});				
 	    valid1.define('requird' , [{ id : "PRINT_TYPE" , errMsg:'請輸入列印種類!!'}] );
		valid1.define('valid_credit' , [{ id : "LOAN_ID" , errMsg:'請輸入貸款帳號!!'}] );
        valid1.define('valid_credit2' , [{ id : "APPLY_ID" , errMsg:'請輸入受理編號!!'}] );
		valid1.define('valid_credit3' , [{ id : "NEW_PAY_DATE" , errMsg:'請輸入要變更的應繳日!!'}] );
		valid2 = new Validation("form1", { focusOnError:true, immediate:false});	
		valid2.define('validate-positive' , [{ id : "SEQ_NO" , errMsg:'請輸入序號!!'}] );
	    Validation.addAllThese( [
			[ 'valid_credit', '',
				function( value , elem ) {	
					if($F('PRINT_TYPE')!='T005'&&$F('PRINT_TYPE')!='T006'){
					    if(!value){ return false; }									
					}
					return true;
				}
			],
			[ 'valid_credit2', '',
				function( value , elem ) {	
					if($F('PRINT_TYPE')=='T005'||$F('PRINT_TYPE')=='T006'||$F('PRINT_TYPE')=='T007'){
					    if(!value){ return false; }									
					}
					return true;
				}
			],
			[ 'valid_credit3', '',
				function( value , elem ) {	
					if($F('PRINT_TYPE')=='T002'){
					    if(!value){ return false; }									
					}
					return true;
				}
			],
			
		]);
	}	

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_9000/" + actionName,
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
	var action= {
        //將畫面寫入Map	
	    queryMap:function(){
			return{
				APPLY_ID: $F('APPLY_ID'),
				LOAN_ID: $F('LOAN_ID'),
				PRINT_TYPE: $F('PRINT_TYPE'),
				NEW_PAY_DATE:$F('NEW_PAY_DATE'),
				SEQ_NO : $F('SEQ_NO'),
				POLICY_NO :$F('POLICY_NO')<%--20220517--%>
		    }
		},
		//執行列印
		excuteprint : function(map){
		
		    RPTUtil.executePrintByLink('print' , {	'paramMap': Object.toJSON(map)}, true );	
		}
	}	
	// 功能按鈕
	var button = {		
		// 列印
		doPrint: function() {
		
			//檢核
			if(!valid1.validate()){				
				return; 
			}
			
			if($F('PRINT_TYPE')=='T006' || $F('PRINT_TYPE')=='T007'){
				if(!valid2.validate()){				
					return; 
				}
			}
			ajaxPost( 'setprint', {'queryMap' :Object.toJSON(action.queryMap())}
				,function(resp){
                    var PRINT_TYPE=$F('PRINT_TYPE');
					if(resp.msg){
						alert(resp.msg);
						if(PRINT_TYPE=='T003'){
						    return;
						}
					}
					if(PRINT_TYPE=='T006' || PRINT_TYPE=='T007' || PRINT_TYPE=='T008'){<%--20220517--%>
						var frm = $('form1');					
							frm.target = '_blank';
							frm.action = resp.URL+"?PARAMETERS="+resp.PARAMETERS;
							frm.submit();
					}else{
					   action.excuteprint(resp.paramMap); 
					}
					
				}
			);
			
		}
		
	};
	
	function linkToPDF(URL){
	
		window.open(URL);
	}
	
	return {
		initApp : function() {

			PageUI.createPageWithAllBodySubElement( "DSC89000" , "收息資料更新", "放款表單套印" );
            
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			//畫面檢核
			initValidation();
			// 監聽
			$("BTN_PRINT").observe('click', button.doPrint);

			//Input欄位自動轉大寫
			$('LOAN_ID').observe('change',function(){
				$('LOAN_ID').value = $F('LOAN_ID').toUpperCase();
			});		
			$('APPLY_ID').observe('change',function(){
				$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			});
			//畫面預設顯示
			if (!$F('PRINT_TYPE')){
				$("APPLY_ID").hide();
				$("APPLY_ID_S").hide();
				$("LOAN_ID").hide();
				$("LOAN_ID_S").hide();
				$("SEQ_NO").hide();
				$("SEQ_NO_S").hide();
				$("POLICY_NO").hide();<%--20220517--%>
				$("POLICY_NO_S").hide();<%--20220517--%>
				document.getElementById("CHG_DATE").style.display = "none";
			}	
            //連動
			$('PRINT_TYPE').observe('change',function(){
				var PRINT_TYPE=$F('PRINT_TYPE');
				$("SEQ_NO").hide();
				$("SEQ_NO_S").hide();
				if(PRINT_TYPE=='T005'||PRINT_TYPE=='T006' || PRINT_TYPE=='T007'){
				    $("APPLY_ID").show();
					$("APPLY_ID_S").show();
					$("LOAN_ID").hide();
					$("LOAN_ID_S").hide();
					$("POLICY_NO").hide();<%--20220517--%>
					$("POLICY_NO_S").hide();<%--20220517--%>
					document.getElementById("CHG_DATE").style.display = "none";
					if(PRINT_TYPE=='T006' || PRINT_TYPE=='T007'){
						$("SEQ_NO").show();
						$("SEQ_NO_S").show();
					}else {
						$("SEQ_NO").hide();
						$("SEQ_NO_S").hide();
					}
							
				}else if(PRINT_TYPE=='T002'){
				    $("LOAN_ID").show();
					$("LOAN_ID_S").show();
					document.getElementById("CHG_DATE").style.display = "block";
					$("APPLY_ID").hide();
					$("APPLY_ID_S").hide();
					$("POLICY_NO").hide();<%--20220517--%>
					$("POLICY_NO_S").hide();<%--20220517--%>
				}else if(PRINT_TYPE=='T008'){<%--20220517--%>
					$("POLICY_NO").show();
					$("POLICY_NO_S").show();
					$("APPLY_ID").hide();
					$("APPLY_ID_S").hide();
					$("LOAN_ID").hide();
					$("LOAN_ID_S").hide();
					$("SEQ_NO").hide();
					$("SEQ_NO_S").hide();
				}else if (!$F('PRINT_TYPE')){
					$("APPLY_ID").hide();
					$("APPLY_ID_S").hide();
					$("LOAN_ID").hide();
					$("LOAN_ID_S").hide();
					$("POLICY_NO").hide();<%--20220517--%>
					$("POLICY_NO_S").hide();<%--20220517--%>
					document.getElementById("CHG_DATE").style.display = "none";
				}else{
				    $("LOAN_ID").show();
					$("LOAN_ID_S").show();
				    $("APPLY_ID").hide();
					$("APPLY_ID_S").hide();
					$("POLICY_NO").hide();<%--20220517--%>
					$("POLICY_NO_S").hide();<%--20220517--%>
					document.getElementById("CHG_DATE").style.display = "none";
				} 
				
				$('LOAN_ID').value = $F('LOAN_ID').toUpperCase();
			});
			
			PageUI.resize();	
			displayMessage();
			
		},
		
		linkToPDF : linkToPDF
	}
}
</script>
</head>
<body>
<form name="form1" id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" >

<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
    
	<tr>
		<td class='tbYellow' width='2%'>
			列印種類
		</td>
		<td class='tbYellow2' width='10%'>
			<select id="PRINT_TYPE" class="textBox2">
				<option value="">請選擇</option>
				<c:forEach items="${PRINT_TYPE_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
        <td class="tbYellow2" width="3%" align="center" rowspan='2'>
			<input type="button" class="button" id="BTN_PRINT" value="列印" />					
		</td>
	</tr>
	<tr>
	    <td class='tbYellow' width='2%'>
			查詢條件
		</td>
		<td class='tbYellow2' width='10%' >
			<span type="text" id="LOAN_ID_S">貸款帳號:</span>		
			<input id='LOAN_ID'  type="TEXT" class= 'textBox2'   size='13' maxlength='11' /> 
			<span type="text" id="APPLY_ID_S">受理編號:</span>	
			<input id='APPLY_ID'  type="TEXT" class= 'textBox2'   size='13' maxlength='11' /> 
			<div id="CHG_DATE">
			<span type="text" id="NEW_PAY_DATE_S">變更應繳日:</span>	
		    <input id="NEW_PAY_DATE" datatype="ROCDate" type="TEXT" value="${NEW_PAY_DATE}" class="textBox2 "  size="10" maxlength="7" />
		    <img id="calendarGif" class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('NEW_PAY_DATE'))">
		    </div>
			<span type="text" id="SEQ_NO_S">序號:</span>	
			<input id='SEQ_NO'  type="TEXT" class= 'textBox2 validate-positive'   size='13' maxlength='10' value='1'/> 
			<span type="text" id="POLICY_NO_S">保單號碼:</span><%--20220517 --%>
			<input id='POLICY_NO'  type="TEXT" class= 'textBox2'   size='15' maxlength='14' />
		</td>
	   
	</tr>
	<tr>
	    <td class='tbYellow0' width='5%' colspan='3'>
	        <span class='textRed'><b>請先繳至當期期款後，再做查詢，避免試算出金額有誤!</b></span><br>
			<b>特別注意事項：</b><br>
			<b>1.列印時，請將列印設定中，頁面處理/頁面縮放 選擇無。</b><br>
			<b>2.住宅火災及地震險要保書如無法套印時，請改列印<a href='#' onClick="dsc89000.linkToPDF('<c:out value="${URL}"/>' )"/>空白要保書</a>讓要保人暨業務員簽署。</b>
	</tr>
	
</table>
</form>
</body>
</html>	