<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>


<!--
程式：DSC80100.jsp
作者：熊偉翔
功能：變更資料查詢
完成：2012/12/06

[20230315] 修改程式  楊青峰
難字調整
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<%-- [20230315] --%>
<style type="text/css">
	@font-face {
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
	         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	      font-weight: normal;
	      font-style: normal
	}
</style>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script> <!--alert訊息-->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript">


var DSC80100 = new DSC80100();

//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', DSC80100.initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


//以下為UI() public method,放在 return 中
function DSC80100(){
		
	var grid;
	var valid1;	
	
	//畫面檢核(設定)
	function initValidation(){
		Validation.addAllThese([
			[ 'validateQueryParam',  '貸款帳號或查詢日期至少要輸入一種', 
				function(v,elm) {
					return !(Validation.get('IsEmpty').test($F('LOAN_ID')) && Validation.get('IsEmpty').test($F('QUERY_DT')));
				}
			],
			['validLOAN_ID', '貸款帳號格式有誤', function(v , node) { 
				if(v){
					<%--貸款帳號10碼英數字--%>
					return v.length == 10 && (/^[a-zA-Z0-9]+$/.test(v)); 
				}
				return true;
			}]
		]);
		valid1 = new Validation("form1", { focusOnError:true, immediate:false});
	}	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_0100/" + actionName,
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
	
	//-------------------------------------------------	
	//TableUI使用function
	//-------------------------------------------------
	
	//POP UP 開啟新視窗
  	function doPopup( page , parms ) {
  		var config = { 'src' : '<%=dispatcher%>/' + page + '/prompt' , 'parameters' :parms , 'width':650, 'height':350};
		popupWin.popup(config);
  	}
	
	
	//--------------------------------------------------------------------------
	// 功能按鈕
	//--------------------------------------------------------------------------	
	
	var buttons = {
		
		//查詢
		doQuery: function(event){
			valid1.reset();
			valid1.clear();
			
			//檢核:當變更種類是全部時，貸款帳號為必輸欄位
			var CHG_KIND = $F('CHG_KIND');
			
			if(!CHG_KIND) {
				valid1.define( "required" , { id: "LOAN_ID" , errMsg: "貸款帳號為必需輸入資料"} );
			}
			
			//畫面檢核	
			//貸款帳號或查詢日期至少要輸入一種
			valid1.define( "validateQueryParam" , { id: "LOAN_ID"} );
			<%--貸款帳號10碼英數字--%>
			valid1.define( "validLOAN_ID" , { id: "LOAN_ID"} );
			
			//畫面檢核
			if(!valid1.validate()){
				return; 
			}
			
			var LOAN_ID = $F('LOAN_ID');
			var QUERY_DT = $F('QUERY_DT');
			ajaxPost( 'query', {'LOAN_ID' :LOAN_ID , 'QUERY_DT' :QUERY_DT , 'CHG_KIND' :CHG_KIND }
				,function(resp){
					grid.load(resp.rtnList || []);  //載入資料
				}
				,function(resp){	
					//如果失敗,把前一次的內容清掉
					grid.load([]);
				}
			);
		}  
	};


	return {
	
			initApp : function() {
				
				PageUI.createPageWithAllBodySubElement("DSC80100", "收息資料更新", "變更資料查詢");
				
				//產生 Grid 物件	
				grid = new TableUI ( { table: $("grid"), pageSize: 50, allSortable:true,
					<%-- [20230315] --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						
						{header: '變更日期',key: 'APPLY_DATE_ROC' },
						{header: '貸款帳號',key: 'LOAN_ID' },
						{header: '變更種類',key: 'CHG_KIND_NM',                       
							render : function(rec , val){							
								if(val){
									var link = new Element('a', { 'href' : '#'}).update(val);
									var CHG_KIND = rec.CHG_KIND;
									var parms = {
											'LOAN_ID':rec.LOAN_ID,			//貸款帳號
											'APPLY_DATE':rec.APPLY_DATE,	//變更日期
											'CHG_KIND':rec.CHG_KIND,		//變更種類
											'SEQ_NO':rec.SEQ_NO,			//變更序號
											'INPUT_ID':rec.INPUT_ID,		//變更人員
											'OPTION1':rec.OPTION1,			//OPTION1
											'OPTION2':rec.OPTION2,			//OPTION2
											'TABLE':rec.TABLE,			    //TABLE_NM
											'INPUT_DATE':rec.INPUT_DATE		//INPUT_DATE
										};
									if(CHG_KIND =='1'){
										link.observe('click', function(){doPopup( "DSC8_0101" , parms )}); //收費代號
									}else if(CHG_KIND =='5'){
										link.observe('click', function(){doPopup( "DSC8_0102" , parms )});	//收費代號
									}else if(CHG_KIND =='6'){
										parms.PAGE_TYPE = '1';//1=>應繳日期變更
										link.observe('click', function(){doPopup( "DSC8_0103" , parms )});
									}else if(CHG_KIND =='7'){
										link.observe('click', function(){doPopup( "DSC8_0104" , parms )});
									}else if(CHG_KIND =='9'){
										link.observe('click', function(){doPopup( "DSC8_0105" , parms )});
									}else if(CHG_KIND =='11'){
										link.observe('click', function(){doPopup( "DSC8_0106" , parms )});
									}else if(CHG_KIND =='12'){
										link.observe('click', function(){doPopup( "DSC8_0107" , parms )});
									}else if(CHG_KIND =='13'){
										link.observe('click', function(){doPopup( "DSC8_0108" , parms )});
									}else if(CHG_KIND =='14' || CHG_KIND =='15' || CHG_KIND =='34'){
										link.observe('click', function(){doPopup( "DSC8_0109" , parms )});
									}else if(CHG_KIND =='16'){
										link.observe('click', function(){doPopup( "DSC8_0110" , parms )});
									}else if(CHG_KIND =='17'){
										link.observe('click', function(){doPopup( "DSC8_0111" , parms )});
									}else if(CHG_KIND =='18'){
										link.observe('click', function(){doPopup( "DSC8_0112" , parms )});
									}else if(CHG_KIND =='19'){
										link.observe('click', function(){doPopup( "DSC8_0113" , parms )});
									}else if(CHG_KIND =='20'){
										link.observe('click', function(){doPopup( "DSC8_0114" , parms )});
									}else if(CHG_KIND =='93'||CHG_KIND =='22'||CHG_KIND =='92'||CHG_KIND =='94'){
										link.observe('click', function(){doPopup( "DSC8_0115" , parms )});
									}else if(CHG_KIND =='23'){
										link.observe('click', function(){doPopup( "DSC8_0116" , parms )});
									}else if(CHG_KIND =='24'){
										link.observe('click', function(){doPopup( "DSC8_0117" , parms )});
									}else if(CHG_KIND =='25'){
										link.observe('click', function(){doPopup( "DSC8_0118" , parms )});
									}else if(CHG_KIND =='26'){
										link.observe('click', function(){doPopup( "DSC8_0119" , parms )});
									}else if(CHG_KIND =='27'){
										link.observe('click', function(){doPopup( "DSC8_0120" , parms )});
									}else if(CHG_KIND =='28'){
										link.observe('click', function(){doPopup( "DSC8_0121" , parms )});
									}else if(CHG_KIND =='29'){
										link.observe('click', function(){doPopup( "DSC8_0122" , parms )});
									}else if(CHG_KIND =='30'){
										link.observe('click', function(){doPopup( "DSC8_0123" , parms )});
									}else if(CHG_KIND =='31'){
										link.observe('click', function(){doPopup( "DSC8_0124" , parms )});		
									}else if(CHG_KIND =='32'){
										link.observe('click', function(){doPopup( "DSC8_0125" , parms )}); //個件控管設定
									}else if(CHG_KIND =='33'){
										link.observe('click', function(){doPopup( "DSC8_0126" , parms )}); //契約狀況	
									}else if(CHG_KIND =='21'){
										link.observe('click', function(){doPopup( "DSC8_0127" , parms )}); //原貸帳號
									}else if(CHG_KIND =='35'){
										link.observe('click', function(){doPopup( "DSC8_0128" , parms )});//本金彈性還變更	
									}else if(CHG_KIND =='36'){
										parms.PAGE_TYPE = '2';//2=>特殊事件緩繳
										link.observe('click', function(){doPopup( "DSC8_0103" , parms )});//特殊事件緩繳
									}
									
									return link;
								}else {
									return '';
								}
						    } },
						{header: '變更序號',key: 'SEQ_NO' },
						{header: '變更單位',key: 'INPUT_DEPT' },
						{header: '變更人員',key: 'INPUT_ID' ,
								render : function(rec , val){
									return rec.INPUT_NAME || val;
								}}
					]
                     
				});
				
			
				//-----------------------------------------------------
				//以下為進入初始頁面時需要執行的動作
				//-----------------------------------------------------
				
				//畫面檢核
				initValidation();
				
				//註冊DOM物件 : 監聽	
				$('BTN_0001').observe('click', buttons.doQuery);  //查詢
				<%--[20240408]從其他頁面連結過來，接值自動查詢(查詢日期不設定，顯示全部資料)--%>
				<c:if test='${not empty LOAN_ID && not empty CHG_KIND}'>
					$('LOAN_ID').setValue('${LOAN_ID}');
					$('CHG_KIND').setValue('${CHG_KIND}');
					$('QUERY_DT').setValue('');
					buttons.doQuery();
				</c:if>
				
				//初始頁面alert訊息用	
				displayMessage();
					
				PageUI.resize();
				
			}// end initApp()
	};// end return--
}

</script>
</head>
<body>
<form name='form1' id='form1' style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>
<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
		<tr>
		<td class='tbYellow' width='10%'>
				貸款帳號
		</td>
		<td class='tbYellow2' width='15%'>
			<input id='LOAN_ID' type='text' class= 'textBox2'   size='12' maxlength='10' onblur="this.value = this.value.toUpperCase()"/> 
		</td>
		<td class='tbYellow' width='10%'>
				查詢日期
		</td>
		<td class='tbYellow2' width='15%'>
			<input id='QUERY_DT' datatype ='ROCDate' type='text' class= 'textBox2'  size='9' maxlength='7' value='${SYS_DATE}' />
			<img src="/DSWeb/images/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('QUERY_DT'))">
		</td>
		<td class='tbYellow' width='10%'>變更種類</td>
		<td class='tbYellow2' width='35%'>
			<select id='CHG_KIND' class='textBox2'> 
				<option value =''>全部</option>
				<c:forEach var='item' items='${CHG_KIND_List}'>
					<option value='${item.key}'><c:out value= '${item.value}' /></option>
				</c:forEach>
			</select>
		</td>
		<td class='tbYellow2' colspan='5' align='center'>
			<input id='BTN_0001' type='button' class='button' value='查詢' />
		</td>
	</tr>
	<tr>
		<td class='tbBox3' colspan='11' align='center'>
			變更記錄明細表
		</td>
	</tr>
</table>
</form>
<table id='grid' width='100%'></table>
</body>
</html>