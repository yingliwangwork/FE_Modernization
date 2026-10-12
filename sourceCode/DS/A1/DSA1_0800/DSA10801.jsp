 <%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSA10801.jsp
作者：i9100606
功能：2Q人員謄本確認作業
完成：2011/09/16
更新：
-->

<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">

<%--共用定義的css--%>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<%--[20240723]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<%--自行定義的javaScript--%>
<script type="text/JavaScript">
<!--
<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>

Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function initApp(){

	cleanMsgBoard();

	

	//TableUI的產生        
	new UI().init();    

	PageUI.resize(true);

}

//--------------------------------------------------------------------------  
<%--全域 函數 UI 與 畫面 公用 End----------------------------------------------------%>

<%--Define UI Class Start-------------------------------------------------------%>
function UI(){
	var CredDept='${CredDept}';
	
	            
	//--------------------------------------------------------------------------          
	//UI() private variable        
	//--------------------------------------------------------------------------         
	var grid = {};
	//--------------------------------------------------------------------------          
	//UI() private method        
	//--------------------------------------------------------------------------          
	//***
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ){	
		
		new Ajax.Request( "<%=dispatcher%>/DSA1_0801/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	    	onSuccess: successAction
		});
	}      
	
	//AJAX SuccessAction For Query
	function successActionForQuery(XHT, resp) {
		if(CSRUtil.isSuccess(resp)){
			grid.load(resp.rtnList || []);
			if(resp.rtnList && resp.rtnList.length>0){
				layout.changeTitle(true,resp.rtnList.length);
			}else{
				layout.changeTitle(false);				
			}
		} else{
			grid.load([]);
			layout.changeTitle(false);
		}
	}	
		
	//查詢Function       
	var doQuery = function(){
		ajaxPost('query', 
				$("form1").serialize( true ), 
				successActionForQuery
		);
	};
	
	//超連結
	var doLink = {
		open:function(APPLY_ID, wobNum , queueName , link){
			var LP_JSON = {
				APPLY_ID:APPLY_ID,
				wobNum:wobNum,
				queueName:queueName,
				parameters:{"APPLY_ID":APPLY_ID,"wobNum":wobNum,"queueName":queueName},				
				action:'${dispatcher}/'+ link + '/prompt'
			};
			CSRUtil.linkTo(LP_JSON, 'form1');
		}
	};

	//--------------------------------------------------------------------------        
	//以下為UI() public method,放在 return 中        
	//--------------------------------------------------------------------------          
	return{                              
		//init Function for 初始整個UI Class                
		init:function(){
		
		   
			
			layout.control(CredDept);
			
			
			PageUI.createPageWithAllBodySubElement("DSA10801" , "受理作業" , title, 1);
			
			grid = new TableUI(                         
				{                   				
					table: $('grid'), pageSize: 100 ,  //對應的table實體                  				
					allSortable:true,overDiv: false,
					<%-- [20240723] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[           
						{header: '受理編號',key: 'APPLY_ID',
	  	                 	render: function(rec,val){
							 	if(!val){
							    	return ""; 
							 	} else {
							 	    return val
							 	}
	  	                 	}
	  	                },
						{header: '案件進度',key: 'STEP_NAME',
							render:function(rec,val){
							 	if(!val){ return ""; }
								if(rec.ACTION){
									var link = document.createElement('a');
									link.href = '#';
									link.innerHTML = val;
									link.onclick = function(){
											var link = '';
											
											if('${CredDept}' == 'OP2' && val.indexOf('待土地謄本資料確認')>=0){
												link = 'DSA1_0400';
											}else if('${CredDept}' == 'OP2' && val.indexOf('待建物謄本資料確認')>=0){
												link = 'DSA1_0500';
											}else if('${CredDept}' == 'OP2' && val.indexOf('待送件確認')>=0){
												link = 'DSA1_0601';
											}else if('${CredDept}' == 'OP1'){
												link = 'DSA1_0800';
											}
											if(link!=''){
												doLink.open(rec.APPLY_ID, rec.wobNum , rec.queueName , link);
												val = link;
											}
									};
									return link;								
								}
								return val;
							}
						},
						{header: '處理狀態', key: 'STATUS_NM',
							render:function(rec,val){
							 	if(!val){ return ""; }
							 	if(val.indexOf('處理中')>=0){
							 		return "<font color='gree'>"+val+"</font>";
							 	}
							 	return val;

							}
						},
						{header: '相關資訊', key: 'OTHER', attrs:{'align':'left'},
							render:function(rec,val){
							 	if(!val){ return ""; }
								return "<font color='red'>"+val+"</font>";
							}
						},{header: '比對紀錄', key: 'ASSIGN_2Q_CNT_NAME'}<%--20211202 211126003895 2Q人員謄本查詢作業。(畫面DSA10801)調整--%>
						,{header: '轉派紀錄', key: 'REASSIGN_NAME'}<%--20211202 211126003895 2Q人員謄本查詢作業。(畫面DSA10801)調整--%>
						,{header: '轉派人員', key: 'REASSIGN_INPUT_NAME', attrs:{style:"font-family:'EUDC'"}}<%--20211202 211126003895 2Q人員謄本查詢作業。(畫面DSA10801)調整 [20240723]難字調整--%>
						,{header: '指派日期', key: 'ASSIGN_DATE',
							render:function(rec,val){
							 	if(!val){ return ""; }
								return "<font color='red'>"+Date.toROC(val).replace(" ","<br>")+"</font>";
							}
						},
						{header: '進件日期', key: 'START_DATE',
							render:function(rec,val){
							 	if(!val){ return ""; }
								return "<font color='red'>"+Date.toROC(val).replace(" ","<br>")+"</font>";
							}
						}
					]										
				}                 
			); 
			
			$('BTN_query').observe('click', doQuery);

			doQuery();
			

		}//end init()--                        
	}//end return--        /
	//-------------------------------------------------------------------------- 
}
//--------------------------------------------------------------------------
// 畫面控制
//--------------------------------------------------------------------------
var title;
var layout = {
	control:function(CredDept){
	    if(CredDept == "OP1"){
	    	title = "2Q人員謄本查詢作業";
	    }else{
	    	title = "2Q人員謄本確認作業";
	    }
	
	},
	changeTitle:function(isChange,size){
		if(isChange){
			$$('#table1 th').each(
				function(obj){
					if(obj.innerHTML.indexOf(title)>=0){
						obj.innerHTML = obj.innerHTML.replace(title,title+"共"+size+"筆");
					}
					
				}
			);
		}else{
			$$('#table1 th').each(
				function(obj){
					if(obj.innerHTML.indexOf(title)>=0){
						var oldtitle = obj.innerHTML.substring(obj.innerHTML.indexOf(title),obj.innerHTML.indexOf("筆")+1);
						obj.innerHTML = obj.innerHTML.replace(oldtitle,title);
					}
					
				}
			);				
		}
	}
};
<%--Define UI Class End--------------------------------------------------------%>-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
<form id="form1" name="form1" method="post">
	<table id="table1" width="100%" height="100%" border="0" cellpadding="0" cellspacing="0" class="tbBox2">
		<tr>
			<td class="tbYellow" width="15%">
				承辦科別
			</td>
			<td class="tbYellow2" width="15%">
				<input type="hidden" id="CredDept" name="CredDept" value="${CredDept}"/>	
				<select id="QUERY_DEPT" name="QUERY_DEPT" >			
					<c:forEach var="map" items="${QUERY_DEPT_LIST}" >
						<option value="${map.key}" <c:if test="${map.key eq CHECK_CODE}">selected</c:if> >${map.value}</option>
					</c:forEach>
				</select>	
			</td>
			<td class="tbYellow" width="15%"><%--20211202 211126003895 2Q人員謄本查詢作業。(畫面DSA10801)調整--%>
				比對紀錄
			</td>
			<td class="tbYellow2" width="15%">			
				<select id="QRY_ASSIGN_2Q_CNT" name="QRY_ASSIGN_2Q_CNT" >	
					<option value="">請選擇</option>		
					<c:forEach var="map" items="${ASSIGN_2Q_CNT_LIST}" >
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>	
			</td>
			<td class="tbYellow" width="15%"><%--20211202 211126003895 2Q人員謄本查詢作業。(畫面DSA10801)調整--%>
				轉派紀錄
			</td>
			<td class="tbYellow2" width="15%">				
				<select id="QRY_REASSIGN" name="QRY_REASSIGN" >		
					<option value="">請選擇</option>	
					<c:forEach var="map" items="${REASSIGN_LIST}" >
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>	
			</td>
			<td class="tbYellow" width="10%">
				<input id="BTN_query" type="button" class="button" value="查詢" /> 
			</td>
		</tr>								
	</table>
	<table id="grid" class="grid"></table>	
</form>
</body>
<!-- InstanceEnd -->
</html>
