<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSC31500.jsp
作者：熊偉翔
功能：員工扣薪QC
完成：2012/11/20
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<fmt:setBundle basename="TextResource" />

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<title></title>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script> <!--alert訊息-->
<script type="text/javascript">

var DSC31500 = new DSC31500();

//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', DSC31500.initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


//以下為UI() public method,放在 return 中
function DSC31500(){
	var grid;
	var valid1;	
	var isDNF ;     //當觸發query此事件時:查無資料 
	var rtnList;
	
	//畫面檢核
	function initValidation(){
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_1500/" + actionName,
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
	
	//處理數值欄位部分(三位一撇)
	function formatNumber(val){
		 return CSRUtil.$fmt(val||0,"#,##0.####"); 
	}
	
	
	//--------------------------------------------------------------------------
	// 功能按鈕
	//--------------------------------------------------------------------------	
	
	var buttons = {
		
		//查詢
		doQuery: function(event){
			
			valid1.reset();
			valid1.clear();
			//畫面檢核
			if(!valid1.validate()){
				return; 
			}
				
			//頁面傳入參數			
			var SALARY_GROUP = $F('SALARY_GROUP') ||'';		//扣薪組別
			var WORK_YM = $F('WORK_YM')|| '';   		    //工作年月
			
			ajaxPost( 'query', {'SALARY_GROUP' :SALARY_GROUP, 'WORK_YM': WORK_YM }
				,function(resp){
					//查詢成功
					if(SALARY_GROUP == "90"){//關係企業合併為多筆呈現
						$('SALARY_RESULT1').hide();
						$('SALARY_RESULT2').show();
						
						rtnList = resp.rtnList;
						grid.load(rtnList||[]);
						isDNF = false;
					}else{	//內外勤，以單筆呈現
						$('SALARY_RESULT1').show();
						$('SALARY_RESULT2').hide();
						
						var rtnMap = resp.rtnMap;						
						$w('WORK_YM SALARY_GROUP TOT_CNT').each(
							function(id) {
								$(id + '_SPAN').update(rtnMap[id] || '')  
							}
						);
						$('TOT_AMT_SPAN').update (formatNumber(rtnMap ['TOT_AMT'] ));
						isDNF = false;
					}
				}
				,function(resp){
					isDNF = true;
					if(SALARY_GROUP == "90"){
						grid.load([]);
					}else{
						$w('WORK_YM SALARY_GROUP TOT_CNT').each(
							function(id) {
								$(id + '_SPAN').update('')  
							}
						);
						$('TOT_AMT_SPAN').update ('');
					}					
				}
			);
		},
		
		//確認
		doConfirm : function(event){
			
			//檢核
			//若無查無資料就按確認，丟出錯誤訊息 “查無資料，無法確認!”
			if(isDNF){
				alert("查無資料，無法確認!");
				return;
			}
			
			//頁面傳入參數			
			var SALARY_GROUP = $F('SALARY_GROUP') ;		//扣薪組別
			var WORK_YM = $F('WORK_YM');				//工作年月
			
			ajaxPost('confirm', {'SALARY_GROUP' :SALARY_GROUP, 'WORK_YM': WORK_YM ,'RTNLIST90':Object.toJSON(rtnList)}	);			
				
		}
	};


	return {
	
			initApp : function() {
				
				PageUI.createPageWithAllBodySubElement("DSC31500", "繳款方式", "員工扣薪QC");
				
				grid = new TableUI({
					table: $('SALARY_RESULT2'), pageSize: 20, allSortable: false, overDiv : false,		
					column: [						
						{header:"工作年月", key:'WORK_YM'},
						{header:"扣薪組別", key:'SALARY_GROUP_NM'},
						{header:"總件數", key:'TOT_CNT'},
						{header:"總金額", key:'TOT_AMT',
							render:function(rec,val){
								return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
						}}					
					]	
				});
			
				//-----------------------------------------------------
				//以下為進入初始頁面時需要執行的動作
				//-----------------------------------------------------
				
				//註冊DOM物件 : 監聽	
				$('BTN_0001').observe('click', buttons.doQuery);  //查詢
				$('BTN_0028').observe('click', buttons.doConfirm);//確認
				
				$('SALARY_RESULT1').hide();
				$('SALARY_RESULT2').hide();
				
				//初始頁面alert訊息用	
				displayMessage();
				
				initValidation();
					
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
		<td class='tbYellow' width='10%'>扣薪組別</td>
		<td class='tbYellow2' width='35%'>
			<select id='SALARY_GROUP' class='textBox2  required'> 
				<c:forEach var='item' items='${SALARY_List}'>
					<option value='${item.key}'><c:out value='${item.value}' /></option>
				</c:forEach>
			</select>
		</td>
		<td class='tbYellow' width='10%'>工作年月</td>
		<td class="tbYellow2" width="20%">
			<input id='WORK_YM'  type='text' class="textBox2 required"  size='7' maxlength='5' value='${SYS_DATE}' />
		</td>
		<td class='tbYellow2' colspan='5' align='center'>
			<input id='BTN_0001' type='button' class='button' value='扣薪查詢' />
			<input id='BTN_0028' type='button' class='button' value='確認' />
		</td>
	</tr>
	<tr>
		<td class="tbBox3" width="100%" colspan="9" align="center">扣款查詢結果</td>
	</tr>	
</table>
<table id='SALARY_RESULT1' width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
	<tr align='center'>
		<td class='tbYellow' width='10%'>工作年月</td>
		<td class='tbYellow2' width='15%'>
			<span id='WORK_YM_SPAN'><span>
		</td>
		<td class='tbYellow' width='10%'>薪資組別</td>
		<td class='tbYellow2' width='15%'>
			<span id ='SALARY_GROUP_SPAN'><span>
		</td>
		<td class='tbYellow' width='10%'>總件數</td>
		<td class='tbYellow2' width='15%'>
			<span id ='TOT_CNT_SPAN'><span>
		</td>
		<td class='tbYellow' width='10%'>總金額</td>
		<td class='tbYellow2' width='15%'>
			<span id ='TOT_AMT_SPAN'><span>
		</td>
	</tr>
</table>
<table id="SALARY_RESULT2" width="100%" class="grid" ></table>
</form>
</body>
</html>