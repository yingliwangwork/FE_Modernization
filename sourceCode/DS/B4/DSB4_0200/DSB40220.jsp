<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--
程式：DSB40220.jsp
作者：李俊德
功能：匯款審核查詢
完成：

[20240613]
難字調整
高強禾
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript"
	src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<%--日期用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<%-- 開新視窗 --%>
<%-- [20240613] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type="text/JavaScript">
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSB40220().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//--------------------------------------------------------------------------
//	以下為DSB40220() public method,放在 return 中
//--------------------------------------------------------------------------  
function DSB40220(){

	var grid1;

	var actions = {
		//共用ajax
		ajaxPost : function( actionName, params, successAction){	
			new Ajax.Request( "<%=dispatcher%>/DSB4_0220/" + actionName,{  
					parameters: params, 
					onSuccess: function(response){ successAction(response.responseJSON );
				}
			});
		},
		
		doQuery :  function(APPLY_ID){
			actions.ajaxPost( 'query' , { APPLY_ID : APPLY_ID} ,
				function(resp){
					if (CSRUtil.isSuccess(resp)){
					var rtnList = resp.rtnList;
						
			if (rtnList) {
				grid1.load(rtnList);
			}
			
			var A010Map = resp.A010Map;
			if (A010Map) {
			
			
				//文字欄位
				$w('APPLY_ID BORROW_ID BORROW_NAME LOAN_KIND_NM PREFER_TYPE_NM FILE_FIREINSU').each( 
					function(col){
						$(col).innerHTML = A010Map[col] || '';
					}
				);
				
				//數字欄位
				$w('FIX_PERIOD SPR_PERIOD').each( 
					function(col){
						$(col).innerHTML = A010Map[col] || '0';
					}
				);
				
				// A010Map.MM_CODE in (1,2)
				if( A010Map.MM_CODE == "1" ||  A010Map.MM_CODE == "2") { 
					var REMIT_ACCOUNT = A010Map.REMIT_ACCOUNT;
					var sb = REMIT_ACCOUNT.substring(0, 3) + "-" + REMIT_ACCOUNT.substring(3, 7) + "-" + REMIT_ACCOUNT.substring(7);
					$('REMIT_ACCOUNT').update(sb);
					$('MM_ACCOUNT').update(A010Map.MM_ACCOUNT);
				} else {
					$('REMIT_ACCOUNT').update('無申請理財型');
					$('MM_ACCOUNT').update('無申請理財型');
				}
				
				var FLOAT_TYPE = resp.FLOAT_TYPE;

				$('FLOAT_TYPE_NM').innerHTML = FLOAT_TYPE == 'M' ? "利率調整方式：月調" : "利率調整方式：依商品規定";
				$('PAY_FREQ_NM').innerHTML = resp.PAY_FREQ_NM;
				//20190223 影像編號	
				$('IMG_CASE_ID').setValue( A010Map.IMG_CASE_ID);
				<%--[20221227]新增本金彈性還期間，因尚未上版，先註解--%>
				$('FLEX_PERIOD_NM').innerHTML = A010Map.FLEX_PERIOD_NM || '';
		}
			
			var itemList = resp.itemList;
			
			if (itemList) {
	
				var oTbody = $('tableTbody');
				
				var rowSize = 3; //1row可放 3 筆資料
				
				var emptyMapLen = itemList.length % rowSize;
				emptyMapLen = emptyMapLen > 0 ? rowSize - emptyMapLen : 0;
				
				//補上不足3的資料
				for(var idx=0; idx < emptyMapLen; idx++){
					var emptyMap = {
						NOT_SUPPLY : '',
						FONT_COLOR : ''
					};
					itemList.push(emptyMap);
				}
				
				var oTr; 
				for(var eleIndex = 0; eleIndex < itemList.length; eleIndex++){
					var ele = itemList[eleIndex];
					if(eleIndex % rowSize == 0){
						oTr = new Element('tr');
					}

					var fontColor = 'black';
					if (ele.FONT_COLOR != ''){
					    fontColor = ele.FONT_COLOR;
					}

					oTr.insert(new Element('td', {className : 'tbBlue', width : '33%'}).setStyle('color: ' + fontColor).insert(ele.NOT_SUPPLY));
					
					if(eleIndex % rowSize == rowSize - 1){
						oTbody.insert(oTr);
					}
				}

			}
					}
				}
			);
		},
		
		// 電子謄本影像
		doElandImage : function(){
			actions.ajaxPost( 'elandImage' , { APPLY_ID : $('APPLY_ID').innerHTML} ,
				function(resp){
					if (CSRUtil.isSuccess(resp)){
						$('blockF').innerHTML = '<table>' + (resp.rtnStr || '') + '</table>';
					}
				}
			);
		},
		// 執行完新放匯款初審後再超連結至DSB4_0300(匯款檢核輸入)畫面
		doConfirm1 : function(){
		    var rtnList = grid1.getAllRecords();	
		    var firstList = grid1.getAllRecords()[0];	
			var LP_JSON = {};	
		 	actions.ajaxPost( 'confirm1' ,  { B200List : Object.toJSON(rtnList) } ,
			function(resp){
			       
					if (CSRUtil.isSuccess(resp)){
					     msgWin.setCallback(function(){
			             LP_JSON.action = "<%=dispatcher%>/DSB4_0300/prompt";	
			             LP_JSON.APPLY_ID = firstList.APPLY_ID; //受理編號
			             LP_JSON.SER_NO = firstList.SER_NO; //序號
			             LP_JSON.REMIT_PROCESS = firstList.REMIT_PROCESS; //匯款進度
			             LP_JSON.BQ_ARG = {APPLY_ID:firstList.APPLY_ID};
			             CSRUtil.linkTo(LP_JSON, 'form1');
			             msgWin.setCallback("");
			             });
					}
				});					   
		},
		
		// 理財型生效審核
		doConfirmM : function(){
			var firstList = grid1.getAllRecords();		
			actions.ajaxPost( 'confirmM' ,  { B200List : Object.toJSON(firstList) } ,
			function(resp){
					if (CSRUtil.isSuccess(resp)){
						
					}
				});				
		},
		// 上一頁
		doBack : function(){
			CSRUtil.linkBack();
		}
		//20190223 匯款影像
		, doTranImage: function(){
			actions.ajaxPost( 'TranImage' ,  { APPLY_ID : $('APPLY_ID').innerHTML } ,
			function(resp){
					if (CSRUtil.isSuccess(resp)){
						var url = '${dispatcher}/DSA0_0200/prompt?APPLY_ID='+$F('IMG_CASE_ID');				
						window.open(url, "DSB4_0220", "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
					}
				});	
			/*
			popupWin.popup({									
				src : '${dispatcher}/DSA0_0200/prompt',
				parameters : { 	
					APPLY_ID : $F('IMG_CASE_ID')
				},  	
				cb : function(obj){	}		
			});	*/
		}			
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSB40220" , "匯款作業", "匯款審核查詢" ,1);
			
			grid1 = new TableUI(
				{	
					table:$('grid1'), pageSize: 5, allSortable: false, overDiv: false, title : "已輸入之匯款資料",
					<%-- [20240613] 難字調整 --%>
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{ header: "匯款種類", key: "REMIT_TYPE_NM"},
						{ header: "帳號", key: "REMIT_ACCOUNT_NM"},
						<%-- [20240613] 難字調整：戶名 --%>
						{ header: "戶名", key: "ACCOUNT_NAME", attrs:{ style:"font-family:'EUDC'" }},
						{ header: "備註", key: "COMP_NAME"},
						{ header: "匯款金額", key: "REMIT_AMT", attrs:{align:'right'},
							render:function(record, value){
				                 	return value ? CSRUtil.$fmt( value, "#,###" ) : 0;;
							}
						},
						{ header: "匯款日期", key: "REMIT_DATE",
							render : function(record , value){
							    var memo = "";
								if (diffDay(value, getY2KToday()) != 0){
									memo = "<font color='red'>(非當日匯款件)</font>";
								}
								return value ? Date.toROC(value) + memo : '';
							}
						},
						{ header: "處理進度", key: "REMIT_PROC_NM"}
					]
				}
			);

			$('btn_elandImage').observe('click', actions.doElandImage ); // 電子謄本查詢按鈕	
			
			$('btn_checkInput').observe('click', actions.doConfirm1 ); // 匯款檢核輸入按鈕
			
			$('btn_confirmM').observe('click', actions.doConfirmM ); // 理財型生效審核按鈕
						
			$('btn_back').observe('click', actions.doBack ); // 上一頁按鈕
			
			$('btn_tranImage').observe('click', actions.doTranImage );//20190223 匯款影像

			displayMessage();
			
			
			
			//若是回上頁所發送回來的，還原 form 的輸入欄值後，執行重新查詢
			var LP_JSON = CSRUtil.isBackLink('form1');
			if (LP_JSON){
			
			   $('APPLY_ID_H').value = LP_JSON.BQ_ARG.APPLY_ID;
			}
			
			actions.doQuery($F('APPLY_ID_H'));

			
			
		}// end initApp()--
	}// end return--
}// end DSB40220

//交易憑證
function OpenNewWindow(eviurl) {
	window.open(eviurl,"eDoc","menubar=0,resizable=yes,scrollbars=yes,directories=0,toolbar=0,height=500,width=650");
}

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0"
	marginheight="0">
	<form name="form1" id="form1" method="post">
		<table width="100%" border="0" cellpadding="0" cellspacing="1"
			class="tbBox2">
			<tr>
				<td class="tbYellow0" align="center" colspan="6"><b>匯款審核查詢</b>
				</td>
			</tr>
			<tr align="center">
				<td width="15%" class="tbYellow">受理編號</td>
				<td width="18%" class="tbYellow2" id="APPLY_ID"></td>
				<td width="15%" class="tbYellow">借款人ID</td>
				<td width="19%" class="tbYellow2" id="BORROW_ID"></td>
				<td width="15%" class="tbYellow">借款人姓名</td>
				<%-- [20240613] 難字調整：借款人姓名 --%>
				<td width="18%" class="tbYellow2" id="BORROW_NAME"
					style="font-family: 'EUDC'"></td>
			</tr>
			<tr align="center">
				<td class="tbYellow">貸款類別</td>
				<td class="tbYellow2" id="LOAN_KIND_NM"></td>
				<td class="tbYellow">優惠種類</td>
				<td class="tbYellow2" id="PREFER_TYPE_NM"></td>
				<td class="tbYellow">火險狀況</td>
				<td class="tbYellow2" id="FILE_FIREINSU"></td>
			</tr>
			<tr align="center">
				<td class="tbYellow">定期期數</td>
				<td class="tbYellow2" id="FIX_PERIOD"></td>
				<td class="tbYellow">分期期數</td>
				<td class="tbYellow2" id="SPR_PERIOD"></td>
				<td class="tbYellow">繳別</td>
				<%--20190507 申請書 新增繳別及對應功能：顯示繳別資訊供匯款審核，季繳件貸放後直接將下次應繳日往後+3個月--%>
				<td class="tbYellow2" id="PAY_FREQ_NM"></td>
			</tr>
			<tr align="center">
				<td class="tbYellow">動撥指定帳戶</td>
				<td class="tbYellow2" id="REMIT_ACCOUNT"></td>
				<td class="tbYellow">理財型連結帳戶</td>
				<td class="tbYellow2" id="MM_ACCOUNT"></td>
				<td class="tbYellow" colspan="2" align="left"><font color="red"><div
							id="FLOAT_TYPE_NM"></div></font></td>
			</tr>
			<%--[20221227]新增本金彈性還期間，尚未上版，先註解--%>
			<tr align="center">
				<td class="tbYellow">本金彈性還期間</td>
				<td class="tbYellow2" id="FLEX_PERIOD_NM"></td>
				<td class="tbYellow"></td>
				<td class="tbYellow2"></td>
				<td class="tbYellow" colspan="2"></td>
			</tr>
		</table>
		<table id='grid1' width="100%"></table>
	</form>
	<table width="100%" border="0" cellpadding="0" cellspacing="1"
		class="tbBox2">
		<tr>
			<td class="tbYellow0" align="center" colspan="3"><b>待補全事項</b></td>
		</tr>
		<tbody id='tableTbody'></tbody>
		<tr>
			<td class="tbYellow2" align="center" colspan="3"><font
				color="red">請注意土地及建物謄本資料及時效是否符合公司規定</font></td>
		</tr>
		<tr>
			<td align="center" colspan="3"><input type="hidden"
				id="APPLY_ID_H" name="APPLY_ID" value="${APPLY_ID}"> <input
				id="IMG_CASE_ID" name="IMG_CASE_ID" type="hidden">
			<%--20190223 影像編號 --%> <input type="button" id="btn_tranImage"
				value="匯款影像" class="button"> <%--20190223 增加匯款影像--%> <input
				type="button" id="btn_elandImage" value="電子謄本影像" class="button">
				<input type="button" id="btn_checkInput" value="匯款檢核輸入"
				class="button"> <input type="button" id="btn_confirmM"
				value="理財型生效審核" class="button"> <input type="button"
				id="btn_back" value="上一頁" class="button"></td>
		</tr>
		<tr>
			<td align="center" colspan="3"><span id="blockF"></span></td>
		</tr>
	</table>
</body>
</html>
