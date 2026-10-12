<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--
程式：DSA32000.jsp
作者：李俊德
功能：鑑價初估作業
完成：
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>        <%-- 日曆用 --%>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>            <%--日期用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>   <%-- 開新視窗 --%>

<script type="text/JavaScript">
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSA32000().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//查詢條件顯示區塊
var reqMap = {};

//合計、選取資料
var TOTobj = [];
//--------------------------------------------------------------------------
//	以下為DSA32000() public method,放在 return 中
//--------------------------------------------------------------------------  
function DSA32000(){
	
	var grid1;

	var valid;
	
	var actions = {
	
		//共用ajax
		ajaxPost : function( actionName, params, successAction){	
			new Ajax.Request( "<%=dispatcher%>/DSA3_2000/" + actionName,{  
					parameters: params, 
					onSuccess: function(response){ successAction(response.responseJSON );
				}
			});
		},
		// 查詢
		doQuery : function(){

			valid.reset();
			if( !valid.validate() ) {
	    		return;
	    	}	
			
			reqMap = {};
			reqMap.BEG_DATE = $F('BEG_DATE');
			reqMap.END_DATE = $F('END_DATE');
			actions.ajaxPost( 'query' ,  { reqMap : Object.toJSON(reqMap) } ,
				function(resp){
					if (CSRUtil.isSuccess(resp)){
						process.load(resp);
					} else {
						grid1.load([]);
					}
				}
			);				
		},
		// 件數超連結(房貸初估明細)
		doLinkByTypeCnt : function(AREA_NO, Q_TYPE){
			var LP_JSON = {};
			LP_JSON.action = "<%=dispatcher%>/DSA3_2001/prompt";	
			LP_JSON.AREA_NO = AREA_NO;
			LP_JSON.BEG_DATE = reqMap.BEG_DATE;
			LP_JSON.END_DATE = reqMap.END_DATE;
			LP_JSON.Q_TYPE = Q_TYPE; //統計種類:1:初估申請,2:進件,3:核准,4:貸放
			CSRUtil.linkTo(LP_JSON, 'form1');
		}
	};
	
	var process = {
		load : function(resp){

			var sumList = resp.sumList;
			subALLobj = [];
			var AREA_NAME = sumList[0].AREA_NM;
			sumList[0].AREA_NM = '業務通路小計';
			sumList[0].TYPE1_CNT = '<div align="right">' + sumList[0].TYPE1_CNT + '</div>';
			sumList[0].TYPE2_CNT = '<div align="right">' + sumList[0].TYPE2_CNT + '</div>';
			sumList[0].TYPE3_CNT = '<div align="right">' + sumList[0].TYPE3_CNT + '</div>';
			sumList[0].TYPE4_CNT = '<div align="right">' + sumList[0].TYPE4_CNT + '</div>';
			subALLobj.push({ text:'業務通路小計', key:{AREA_NM:AREA_NAME}, value : sumList[0] });
			
//			AREA_NAME = sumList[1].AREA_NM;
//			sumList[1].AREA_NM = '展業小計';
//			sumList[1].TYPE1_CNT = '<div align="right">' + sumList[1].TYPE1_CNT + '</div>';
//			sumList[1].TYPE2_CNT = '<div align="right">' + sumList[1].TYPE2_CNT + '</div>';
//			sumList[1].TYPE3_CNT = '<div align="right">' + sumList[1].TYPE3_CNT + '</div>';
//			sumList[1].TYPE4_CNT = '<div align="right">' + sumList[1].TYPE4_CNT + '</div>';
//			subALLobj.push({ text:'展業小計', key:{AREA_NM:AREA_NAME}, value : sumList[1] });
			
			AREA_NAME = sumList[1].AREA_NM;
			sumList[1].AREA_NM = '其他小計';
			sumList[1].TYPE1_CNT = '<div align="right">' + sumList[2].TYPE1_CNT + '</div>';
			sumList[1].TYPE2_CNT = '<div align="right">' + sumList[2].TYPE2_CNT + '</div>';
			sumList[1].TYPE3_CNT = '<div align="right">' + sumList[2].TYPE3_CNT + '</div>';
			sumList[1].TYPE4_CNT = '<div align="right">' + sumList[2].TYPE4_CNT + '</div>';
			subALLobj.push({ text:'其他小計', key:{AREA_NM:AREA_NAME}, value : sumList[2] });
			
			subTOTobj = [];
			subTOTobj.push(subALLobj);
			
			TOTobj = [];
			sumList[2].AREA_NM = '合計';
			sumList[2].TYPE1_CNT = '<div align="right">' + sumList[2].TYPE1_CNT + '</div>';
			sumList[2].TYPE2_CNT = '<div align="right">' + sumList[2].TYPE2_CNT + '</div>';
			sumList[2].TYPE3_CNT = '<div align="right">' + sumList[2].TYPE3_CNT + '</div>';
			sumList[2].TYPE4_CNT = '<div align="right">' + sumList[2].TYPE4_CNT + '</div>';
			TOTobj.push({ text:'合計', value : sumList[2] });
			
			var rtnList = resp.rtnList;
			//載入資料
			grid1.load(rtnList, TOTobj, subTOTobj);

		}
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSA32000" , "鑑價作業", "鑑價初估統計" );

			grid1 = new TableUI(
				{	
					table:$('grid1'), allSortable: false, split:["TYPE1_CNT"], overDiv: true, pageSize:0,
					column:[
						{ header: "區部", key: "AREA_NM", attrs:{rowSpan:2}, groupKey:["AREA_NM"]},
						{ header: "初估申請", attrs:{ colSpan:2 }, empty:'rowSpan_down'},
						{ header: "進件", attrs:{ colSpan:2 }, empty:'rowSpan_down'},
						{ header: "核准", attrs:{ colSpan:2 }, empty:'rowSpan_down'},
						{ header: "貸放", attrs:{ colSpan:2 }, empty:'rowSpan_down'},
						{ header: "件數", key: "TYPE1_CNT", attrs:{ align:'right' },
							render:function(record, value){
									if (value == 0){ return value; }
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = value;
				                	link.onclick = function( event ) { actions.doLinkByTypeCnt( record.AREA_NO, "1" ); };
				                 	return link;
							}
						},
						{ header: "金額", key: "TYPE1_AMT",
							render : function(record , value){
								value = value ? CSRUtil.$fmt(value, "#,##0") : "0";
								return '<div align="right">' + value + '</div>';
							}, renderInCount:true
						},
						{ header: "件數", key: "TYPE2_CNT", attrs:{ align:'right' },
							render:function(record, value){
									if (value == 0){ return value; }
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = value;
				                	link.onclick = function( event ) { actions.doLinkByTypeCnt( record.AREA_NO, "2" ); };
				                 	return link;
							}
						},
						{ header: "金額", key: "TYPE2_AMT",
							render : function(record , value){
								value = value ? CSRUtil.$fmt(value, "#,##0") : "0";
								return '<div align="right">' + value + '</div>';
							}, renderInCount:true
						},
						{ header: "件數", key: "TYPE3_CNT", attrs:{ align:'right' },
							render:function(record, value){
									if (value == 0){ return value; }
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = value;
				                	link.onclick = function( event ) { actions.doLinkByTypeCnt( record.AREA_NO, "3" ); };
				                 	return link;
							}
						},
						{ header: "金額", key: "TYPE3_AMT",
							render : function(record , value){
								value = value ? CSRUtil.$fmt(value, "#,##0") : "0";
								return '<div align="right">' + value + '</div>';
							}, renderInCount:true
						},
						{ header: "件數", key: "TYPE4_CNT", attrs:{ align:'right' },
							render:function(record, value){
									if (value == 0){ return value; }
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = value;
				                	link.onclick = function( event ) { actions.doLinkByTypeCnt( record.AREA_NO, "4" ); };
				                 	return link;
							}
						},
						{ header: "金額", key: "TYPE4_AMT",
							render : function(record , value){
								value = value ? CSRUtil.$fmt(value, "#,##0") : "0";
								return '<div align="right">' + value + '</div>';
							}, renderInCount:true
						}
					]
				}
			);
			
			valid = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			valid.define( "validate-ROCDate-Interval" , [{ id : "BEG_DATE"}, { id : "END_DATE"}] );

			$('btn_query').observe('click', actions.doQuery ); // 查詢按鈕		
		
			autoFormatToDate();
			
			fix();

			displayMessage();
			
			//若是回上頁所發送回來的，還原 form 的輸入欄值後，執行重新查詢
			CSRUtil.isBackLink('form1');
			
			actions.doQuery(); //初始查詢
			
		}// end initApp()--
	}// end return--
}// end DSA32000

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form name="form1" id="form1" method="post">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
			<tr>
				<td class="tbYellow">申請日期</td>
				<td class="tbYellow2">
					<input name="BEG_DATE" id="BEG_DATE" datatype="ROCDate" type="text" class="textBox2 validate-ROCDate required" fieldName="申請日期起日" size="10" maxlength="7" value="${BEG_DATE}"> 
					<img src="<%=imageBase%>/CM/cal.gif" alt="Date" onclick="getCalendarFor($('BEG_DATE'))">
					~ 
					<input name="END_DATE" id="END_DATE" datatype="ROCDate" type="text" class="textBox2 validate-ROCDate required" fieldName="申請日期迄日" size="10" maxlength="7" value="${END_DATE}"> 
					<img src="<%=imageBase%>/CM/cal.gif" alt="Date" onclick="getCalendarFor($('END_DATE'))">
				</td>
				<td class="tbYellow2" align="center" >
				    <input type="button" id="btn_query" value="查詢" class="button">
				</td>
			</tr>
		</table>
		<table id='grid1' width="100%"></table>
	</form>
	<div class="tbBox2 tbYellow2">
		本表自動設定為14日內案件，欲查詢14日前案件請自動調整日期。
	</div>
	
</body>
</html>
