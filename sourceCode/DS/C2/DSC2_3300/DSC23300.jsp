<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!--
程式：DSC23300.jsp
作者：卓達瑋
功能：理則型動撥帳務查詢 
完成：2013/06/06
240612資訊部門內部專用申請書:240611006875自提優化：放款相關帳務查詢畫面移除線上出帳按鈕 BY余凱鈞
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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>    <%-- 月曆專用 --%> 
<script type="text/javaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
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

Event.observe(window, 'load', new DSC23300().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC23300(){

	//檢核
	var valid1;	
    var valid2;

	//檢核欄位
	function initValidation(){
		valid1 = new Validation("form1", { focusOnError:true, immediate:false});				
 	    valid1.define('validate-ROCDate' , [{ id : "ACNT_DATE" , errMsg:'請輸入結帳日期！'}] );
		valid1.define('required' , [{ id : "ACNT_DATE" , errMsg:'請輸入結帳日期！'}] );
		valid1.define('required' , [{ id : "ACNT_GROUP" , errMsg:'請選擇結帳組別！'}] );
		valid2 = new Validation("form1", { focusOnError:true, immediate:false});				
 	    valid2.define('validate-ROCDate' , [{ id : "ACNT_DATE" , errMsg:'結帳日期有誤請再次確認！'}] );
		valid2.define('required' , [{ id : "ACNT_GROUP" , errMsg:'結帳組別有誤請再次確認！'}] );
	}		

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_3300/" + actionName,
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
				ACNT_DATE: $F('ACNT_DATE'),
				ACNT_GROUP: $F('ACNT_GROUP')
		    }
		},
		//查詢後長欄位
		appendTable :function (rtnMap){
            
			var tr = new Element('tr');
			var td1 = action.makeTr({className : 'tbYellow0',width:"10%",colspan:'3',align:'center'},"借方項目");
			var td2 = action.makeTr({className : 'tbYellow0',width:"10%", colspan:'3',align:"center" },"貸方項目");
			tr.insert(td1).insert(td2);
			var tr2 = new Element('tr');
			var td3 = action.makeTr({className : 'tbBlue',width:"10%", align:"center" },"");
			var td4 = action.makeTr({className : 'tbBlue',width:"10%", align:"center"},"件數");
			var td5 = action.makeTr({className : 'tbBlue',width:"10%", align:"center"},"金額");
			var td6 = action.makeTr({className : 'tbYellow',width:"10%", align:"center" },"");
			var td7 = action.makeTr({className : 'tbYellow',width:"10%", align:"center"},"件數");
			var td8 = action.makeTr({className : 'tbYellow',width:"10%", align:"center"},"金額");
			tr2.insert(td3).insert(td4).insert(td5).insert(td6).insert(td7).insert(td8);
			
			var tr3 = new Element('tr');
			action.setlinkspan(tr3,"短期擔保貸款",rtnMap.SHORT_CNT,rtnMap.SHORT_AMT,"SHORT_CNT","SHORT_AMT","SHORT");
			action.setlinkspan(tr3,"銀行存款",rtnMap.CASH_CNT,rtnMap.CASH_AMT,"CASH_CNT","CASH_AMT","CASH");
		    var tr4 =new Element('tr');
			action.setlinkspan(tr4,"其他應收款-人工",rtnMap.DB_CNT,rtnMap.DB_AMT,"DB_CNT","DB_AMT","DB");
			action.setlinkspan(tr4,"沖其他應收款-人工",rtnMap.WDB_CNT,rtnMap.WDB_AMT,"WDB_CNT","WDB_AMT","WDB");
	        
			var tr5 =new Element('tr');
			var td9 = action.makeTr({className : 'tbYellow1',width:"10%",colspan:'2',align:'left'},"總計:");
		    var span = new Element('span').update(action.numberFormat(rtnMap.DTOTAL_AMT||''));
			var td10 = action.makeTr({className : 'tbYellow1',width:"10%", align:"right"},span);
			var td11 = action.makeTr({className : 'tbYellow1',width:"10%",colspan:'2',align:'left'},"總計:");
			var span1 = new Element('span').update(action.numberFormat(rtnMap.CTOTAL_AMT||''));
			var td12 = action.makeTr({className : 'tbYellow1',width:"10%", align:"right"},span1);
			tr5.insert(td9).insert(td10).insert(td11).insert(td12);
			
			var tr6 =new Element('tr');
			var td13 = action.makeTr({className : 'tbYellow0',width:"10%",align:'left',style:"font-family:'EUDC'"},"結帳人員");
		    var span2 = new Element('span').update((rtnMap.EMP_NAME||''));
			var td14 = action.makeTr({className : 'tbYellow2',width:"10%", colspan:'5',align:"center"},span2);
			tr6.insert(td13).insert(td14);
			$('appendArea').insert(tr).insert(tr2).insert(tr3).insert(tr4).insert(tr5).insert(tr6);  
        },
		//設定欄位屬性
		makeTr :function(status , obj){
			var td = new Element('td' , status );
			td.update(obj);
			return td;
		},
		// 數值顯示方式處理
	    numberFormat : function (value) {
			return value ? MoneyFormat(value) : '0';
		},
		//長欄位共同部分(超連結)
		setlinkspan :function(tr,str,val1,val2,id1,id2,QT){
			var link = new Element( 'a' , { href : "#" } ).update(str);	
			link.observe( 'click', function (event){ 
				var LP_JSON = {
					action :'<%=dispatcher%>/DSC2_3310/prompt',	 	
					QUERY_TYPE : QT, 
					ACNT_DATE : $F('ACNT_DATE'),
					ACNT_GROUP : $F('ACNT_GROUP')
					
				}			
				CSRUtil.linkTo(LP_JSON , 'form1');
			});
			var td3 = action.makeTr({className : 'tbYellow2',width:"10%", align:"left"},link);
			var spanA = new Element('span',{id :id1}).update(action.numberFormat(val1||''));
			var td4 = action.makeTr({className : 'tbYellow2',width:"10%", align:"right"},spanA);
			var spanB = new Element('span',{id :id2}).update(action.numberFormat(val2||''));
			var td5 = action.makeTr({className : 'tbYellow2',width:"10%", align:"right"},spanB);    
			tr.insert(td3).insert(td4).insert(td5);
		}
	}	
	// 功能按鈕
	var button = {
			
		// 查詢
		doQuery: function() {	
			//檢核
			if(!valid1.validate()){				
				return; 
			}
			
			ajaxPost( 'query', {'reqMap' :Object.toJSON(action.queryMap())}
				,function(resp){
				    $('appendArea').update(''); 
					action.appendTable(resp.rtnMap);
					$('IS_BALANCE').value = resp.rtnMap.IS_BALANCE;
				}
				,function(){
				    $('appendArea').update('');
				    $('IS_BALANCE').value = 'N';
				}
			);
		}
	};
	
	return {
		initApp : function() {

			PageUI.createPageWithAllBodySubElement( "DSC23300" , "繳款方式", "理則型動撥帳務查詢" );

			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			//畫面檢核
			initValidation();
			// 監聽
			$("BTN_QUERY").observe('click', button.doQuery);
			//按鈕權限		
			PageUI.resize();	
			displayMessage();
			 if(CSRUtil.isBackLink('form1')){    
				button.doQuery();  
			 }
		}
	}
}
</script>
</head>
<body>
<form name="form1" id="form1"  style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" >


   <input type="hidden" id="IS_BALANCE" value="N" />

<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>

	<tr>
		<td class='tbYellow' width='5%'>
			結帳日期
		</td>
		<td class='tbYellow2' width='10%'>
			<input id="ACNT_DATE" name = "ACNT_DATE" datatype="ROCDate" type="text" class="textBox2 "  size="10" maxlength="7" value="${SYS_DATE}"/>
			<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('ACNT_DATE'))">
		</td>
        <td class='tbYellow' width='15%'>
			結帳組別
		</td>
		<td class='tbYellow2' width='10%'>
			<select id="ACNT_GROUP" name = "ACNT_GROUP" class="textBox2">
				<c:forEach items="${ACNT_GROUP_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
        <td class="tbYellow2" width="10%" align="center">
			<input type="button" class="button" id="BTN_QUERY" value="查詢" />					
		</td>
	</tr>
</table>
<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
    <tbody id = "appendArea" >																	
	</tbody>	
</table>


</form>
</body>
</html>	