<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--
程式：DSC22000.jsp
功能：法務入帳試算
作者：林秉宏
完成：2013/09/17
240614資訊部門內部專用申請書:240611006875自提優化：放款相關帳務查詢畫面移除線上出帳按鈕 BY余凱鈞
 -->

<title></title>
 
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/date.js'></script>
<script type="text/JavaScript" src='<%=htmlBase%>/CM/js/calendar.js'></script><%-- 日曆用 --%>
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
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
<script type='text/javascript'>

	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', new DSC22000().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSC22000(){	

		var valid1, valid2;
		var rtnMap=[];
		var Detail_List=[];
		var ACNT_STATUS;
		
		// 檢核
		var initValidation = function(){	
		
			valid1 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid1.define( "required" , [{ id : "ACNT_DATE", errMsg : '請輸入結帳日期!' } ] );
			valid1.define( "validate-ROCDate" , [{ id : "ACNT_DATE" , errMsg:"結帳日期須符合民國年月日格式!" } ] );
			
			valid2 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid2.define( "required" , [{ id : "ACNT_DATE", errMsg : '結帳日期有誤請再次確認!' } ] );
			valid2.define( "validate-ROCDate" , [{ id : "ACNT_DATE" , errMsg:"結帳日期須符合民國年月日格式!" } ] );
		};
		
		// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSC2_2000/' + actionName,
			{  
				parameters: params, 
				onSuccess: function(response)
				{
					var resp = response.responseJSON
					if(CSRUtil.isSuccess(resp)){
						if(successAction){
							successAction(resp);
						}
					}else{
						if(errorAction){
							errorAction(resp);
						}
					}
				}
			});
		};	
	//actions
		var actions = {
		
			// 查詢
			doQuery: function(){

				// 檢核
				valid2.reset();
				if(!valid1.validate()){ 
					return; 
				}

				// 頁面傳入參數
				ajaxPost( 'query' , { 'ACNT_DATE' : $F('ACNT_DATE') },
					function(resp){		
						$('appendArea').update(''); 
						ACNT_STATUS = resp.ACNT_STATUS;
						appendTable(resp);
					},function(resp){
						$('appendArea').update(''); 
					}
				);	
			}
		};

			
		//查詢後組成欄位
		var appendTable = function(resp){
            
			var tr1 = new Element('tr');
			var td11 = makeTd({className:'tbBlue', width:"20%", align:'center'}, "項目");
			var td12 = makeTd({className:'tbBlue', width:"20%", align:'center'}, "借方金額");
			var td13 = makeTd({className:'tbBlue', width:"20%", align:'center'}, "借方件數");
			var td14 = makeTd({className:'tbBlue', width:"20%", align:'center'}, "貸方金額");
			var td15 = makeTd({className:'tbBlue', width:"20%", align:'center'}, "貸方件數");
			tr1.insert(td11).insert(td12).insert(td13).insert(td14).insert(td15);
			$('appendArea').insert(tr1);
			
			Detail_List = resp.Detail_List;
			for (var i = 0; i < Detail_List.length; i++) {
				var tr2 = new Element('tr');
                //220621問題單編號 20211216-0202 BY余凱鈞
                //原本理財型催收轉出後入案款不會沖後來利滾產生的應收，程式加了這段後，未針對帳務的部分也調整。
                //故也需自動沖帳
				if (Detail_List[i]['SEQ_NO'] < 10) {
					var td21 = makeLinkTd(Detail_List[i]['ITEM'], Detail_List[i]['NAME']);
					tr2.insert(td21);
				} else {
					var td21 = makeTd({className:'tbYellow', width:"20%", align:'left'}, Detail_List[i]['ITEM']);
					tr2.insert(td21);
				}
				if (Detail_List[i]['DB_CR'] == 'DR') {
					var span22 = new Element('span').update(gridFmtRender(Detail_List[i]['AMT']));
					var td22 = makeTd({className:'tbBlue2', width:"20%", align:'right'}, span22);
					var span23 = new Element('span').update(gridFmtRender(Detail_List[i]['CNT']));
					var td23 = makeTd({className:'tbBlue2', width:"20%", align:'right'}, span23);
					var td24 = makeTd({className:'tbYellow2', width:"20%", align:'center'}, '');
					var td25 = makeTd({className:'tbYellow2', width:"20%", align:'center'}, '');
					tr2.insert(td22).insert(td23).insert(td24).insert(td25);
				} else {
					var td22 = makeTd({className:'tbBlue2', width:"20%", align:'center'}, '');
					var td23 = makeTd({className:'tbBlue2', width:"20%", align:'center'}, '');
					var span24 = new Element('span').update(gridFmtRender(Detail_List[i]['AMT']));
					var td24 = makeTd({className:'tbYellow2', width:"20%", align:'right'}, span24);
					var span25 = new Element('span').update(gridFmtRender(Detail_List[i]['CNT']));
					var td25 = makeTd({className:'tbYellow2', width:"20%", align:'right'}, span25);
					tr2.insert(td22).insert(td23).insert(td24).insert(td25);
				}
				$('appendArea').insert(tr2);
			}

			rtnMap = resp.rtnMap;
			var tr3 = new Element('tr');
			var td31 = makeTd({className:'tbYellow', width:"20%", align:'left'}, "總計:");
			var span32 = new Element('span').update(gridFmtRender(rtnMap['DTOTAL_AMT']));
			var td32 = makeTd({className:'tbBlue2', width:"20%", align:'right'}, span32);
			var span33 = new Element('span').update(gridFmtRender(rtnMap['DTOTAL_CNT']));
			var td33 = makeTd({className:'tbBlue2', width:"20%", align:'right'}, span33);
			var span34 = new Element('span').update(gridFmtRender(rtnMap['CTOTAL_AMT']));
			var td34 = makeTd({className:'tbYellow2', width:"20%", align:'right'}, span34);
			var span35 = new Element('span').update(gridFmtRender(rtnMap['CTOTAL_CNT']));
			var td35 = makeTd({className:'tbYellow2', width:"20%", align:'right'}, span35);	
			tr3.insert(td31).insert(td32).insert(td33).insert(td34).insert(td35);
			$('appendArea').insert(tr3);
			
			var tr4 = new Element('tr');
			var td41 = makeTd({className:'tbYellow', width:"20%", align:'left'}, "結帳人員");
			var td42 = makeTd({className:'tbYellow2', width:"80%", colspan:'4', align:"center", style:"font-family:'EUDC'"}, rtnMap['EMP_NAME'] || '');
			tr4.insert(td41).insert(td42);
			$('appendArea').insert(tr4);
        };
        
		// 設定欄位屬性
		var makeTd = function(status, obj){
			var td = new Element('td' , status );
			td.update(obj);
			return td;
		};
		
		// 超連結(法務入帳帳務明細表)
		var makeLinkTd = function(ITEM, QUERY_TYPE){
		
			var link = new Element( 'a' , { href : "#" } ).update(ITEM || '');	
			link.observe( 'click', function (event){ 
				var LP_JSON = { 
					action :'<%=dispatcher%>/DSC2_2710/prompt',	 	
					QUERY_TYPE : QUERY_TYPE, 
					ACNT_DATE : $F('ACNT_DATE'),
					ACNT_GROUP : '${ACNT_GROUP}',
					ACNT_STATUS : ACNT_STATUS				
				}			
				CSRUtil.linkTo(LP_JSON , 'form1');
			});			
			var td = makeTd({className : 'tbYellow', width:"10%", align:'left'}, link);
			return td;
		};
		
		// 金額格式化
		var gridFmtRender = function(value) { 
			return value || value === 0 ? CSRUtil.$fmt(value, '#,##0.#####', 0) : ''; 
		};
		
		return {
			
			initApp : function() {
	
				PageUI.createPageWithAllBodySubElement(
					'DSC22000' ,
					'收息帳務' , 
					'法務入帳試算'
				);				
				initValidation();
				
				// 查詢
				$('BTN_query').observe('click', actions.doQuery);
								
				var LP_JSON = CSRUtil.isBackLink('form1');
	   			if (LP_JSON) {	   			 
	   			 	$('ACNT_DATE').value = LP_JSON.ACNT_DATE;
	   			 	actions.doQuery() ; 
	   			 }
	   			 
	   				
				PageUI.resize();
				displayMessage();
		
			} // end initApp()		
		} // end return
	}

</script>
</head>
<body>

<form id="form1" name="form1"  style="PADDING: 0px; MARGIN: 0px;">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow">
			結帳日期
		</td>
		<td class="tbYellow2">
			<input id="ACNT_DATE" name="ACNT_DATE" type="text" class="textBox2 " value='${ACNT_DATE}' datatype="ROCDate" size="9" maxlength="7"/>
			<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onclick="getCalendarFor($('ACNT_DATE'))">
		</td>
		<td class="tbYellow2" align='center'>
			<input id="BTN_query" type="button" value="查詢" class="button"> 
		</td>
	</tr>
</table>

<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
    <tbody id='appendArea'></tbody>	
</table>

</form>		
</body>
</html>