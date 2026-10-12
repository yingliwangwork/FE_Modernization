<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!--
程式：DSD11800.jsp
功能：催收明細作業
作者：卓達瑋
完成：2013/09/

[20230711] 修改件
1.新增「列印劃撥單」、「查詢火險」、「查詢扣款不成原因」頁籤   

[20240322]難字
 --> 

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type="text/javaScript" src="<%=htmlBase%>/CM/js/ui/tabs.js"></script>         <%-- 頁簽使用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>

<%-- [20240322]難字 --%>
<style type="text/css">
@font-face {
    font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>

<script type="text/javascript">


Event.observe(window, 'load', new DSD11800().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD11800(){
    var LOAN_ID='${LOAN_ID}';
    var INPUT_TYPE='${INPUT_TYPE}';
     
	//頁簽
	function CreateTabs(resp){

			tabs = new Tabs({
			
				id:'tabsMenu',
				
				tabs:[
				{id:"DSD11801", "title":"首頁"},
				{id:"DSD11802", "title":"修改地址電話擔保品"},
				{id:"DSE12501", "title":"新增修改催收情況"},
				{id:"DSD12000", "title":"維護地址電話"},
				{id:"DSD11804", "title":"製作存證信函"},
				{id:"DSD10410", "title":"催收簡訊發送"},
				{id:"DSH00300", "title":"客戶資料查詢"},
				{id:"DSH00200", "title":"貸款繳息試算"},
				{id:"DSD11800", "title":"催繳函"},
				<%--[20230711]新增「列印劃撥單」、「查詢火險」、「查詢扣款不成原因」頁籤--%>
				{id:"DSC33700", "title":"列印劃撥單"},
				{id:"DSB30400", "title":"查詢火險"},
				{id:"DSD11300", "title":"查詢扣款不成原因"}
			    ],
				beforeSwitch: function(info){
			/*		//調整外部的高度大小，固定下來，讓上下的 scroll 不生效
					var h = document.body.clientHeight;
					
					//調整高度
					//h = h  - 100;
					h=h-150;
					$$('#contents iframe').each(function(it){
						it.height = h;
					});
			*/		
					var f = $(info.to);					
					if(info.to == 'DSD10410'){	
					    f.src= "<%=dispatcher%>/"+info.to.substring(0,4)+"_"+info.to.substring(4,9)+"/prompt?LOAN_ID="+LOAN_ID+"&MOBILE="+$('MOBILE').innerHTML+"&FUNC_ID=DSD11800&INPUT_TYPE="+INPUT_TYPE;	
					}else if(info.to == 'DSD11804'){					
					    f.src= "<%=dispatcher%>/"+info.to.substring(0,4)+"_"+info.to.substring(4,9)+"/prompt?LOAN_ID="+LOAN_ID+"&DEPT_ID="+$("DEPT_ID").innerHTML;
					}else if(info.to == 'DSE12501'){					
					    f.src= "<%=dispatcher%>/"+info.to.substring(0,4)+"_"+info.to.substring(4,9)+"/prompt?LOAN_ID="+LOAN_ID+"&INPUT_TYPE="+INPUT_TYPE;
					}else if(info.to == 'DSD12000'){
					    f.src= "<%=dispatcher%>/"+info.to.substring(0,4)+"_"+info.to.substring(4,9)+"/prompt?LOAN_ID="+LOAN_ID+"&DATA_SRC=A&FUNC_ID=DSD11800";
					}else if(info.to == 'DSD11800'){
					    buttons.doPrint();
					}else if(info.to == 'DSH00300'){					
						f.src= "<%=dispatcher%>/"+info.to.substring(0,4)+"_"+info.to.substring(4,9)+"/prompt?LOAN_ID="+LOAN_ID;				
					}else if(info.to == 'DSH00200'){					
						f.src= "<%=dispatcher%>/"+info.to.substring(0,4)+"_"+info.to.substring(4,9)+"/prompt?LOAN_ID="+LOAN_ID;	
					}else if(info.to == 'DSC33700'){ <%--[20230711]新增「列印劃撥單」頁籤判斷，將LOAN_ID_Q參數帶入--%>
						f.src= "<%=dispatcher%>/"+info.to.substring(0,4)+"_"+info.to.substring(4,9)+"/prompt?LOAN_ID_Q="+LOAN_ID;					
					}else{
					    f.src= "<%=dispatcher%>/"+info.to.substring(0,4)+"_"+info.to.substring(4,9)+"/prompt?LOAN_ID="+LOAN_ID;					
					}
				},
				beforeSwitchShowCover: true
			});
	
		}
	
	
	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_1800/" + actionName,
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
			}
		);
	}
	
	//各種action
	var actions = {
		showdata :function(rtnMap){
		    $w('DEPT_ID LOAN_ID BORROW_NAME LOAN_STATUS_NM PAY_TERM MOBILE REMAIN_AMT_RATE TRANS_EXTRACT_ADD').each(
						function(ele){
							$(ele).update(rtnMap[ele]||'');
						}
			)
			$('REAL_PAYDT').update(Date.toInputROC( rtnMap['REAL_PAYDT'] || '' ,'/'));
			$('NEXT_PAYDATE').update(Date.toInputROC( rtnMap['NEXT_PAYDATE'] || '' ,'/'));
	        var DAY_TEL_AREA_value;
			if(rtnMap['DAY_TEL_AREA']){
			    DAY_TEL_AREA_value=rtnMap['DAY_TEL_AREA']+"-";
			}else{
			    DAY_TEL_AREA_value="";
			}
			var DAY_TEL_NUM_value=rtnMap['DAY_TEL_NUM']||'';
			var DAY_TEL_EXT_value;
			if(rtnMap['DAY_TEL_EXT']){
			    DAY_TEL_EXT_value="#"+rtnMap['DAY_TEL_EXT'];
			}else{
			    DAY_TEL_EXT_value="";
			}
			var NIGHT_TEL_AREA_value;
			if(rtnMap['NIGHT_TEL_AREA']){
			    NIGHT_TEL_AREA_value=rtnMap['NIGHT_TEL_AREA']+"-";
			}else{
			    NIGHT_TEL_AREA_value="";
			}
			var NIGHT_TEL_NUM_value=rtnMap['NIGHT_TEL_NUM']||'';
			var NIGHT_TEL_EXT_value;
			if(rtnMap['NIGHT_TEL_EXT']){
			    NIGHT_TEL_EXT_value="#"+rtnMap['NIGHT_TEL_EXT'];
			}else{
			    NIGHT_TEL_EXT_value="";
			}
			$("DAY_TEL").update(DAY_TEL_AREA_value+DAY_TEL_NUM_value+DAY_TEL_EXT_value);
			$("NIGHT_TEL").update(NIGHT_TEL_AREA_value+NIGHT_TEL_NUM_value+NIGHT_TEL_EXT_value);
			
			
		},
		getLink :function(LOAN_ID){
			var link = new Element('a', { 'href' : '#'}).update(LOAN_ID);
			var LP_JSON = {	action :'<%=dispatcher%>/DSD1_1800/prompt',
							LOAN_ID : LOAN_ID,INPUT_TYPE : INPUT_TYPE};							
			link.onclick = function() {
				CSRUtil.linkTo(LP_JSON, 'form1');
			};			
			return link;			
		}
		
		
	};
		
		
	//按鈕功能	
	var buttons = {
		
		//初始查詢
		doQuery : function(){		
			
			ajaxPost( 'query' , { LOAN_ID : LOAN_ID},
				function(resp){						
                    var rtnList=resp.rtnList;
					actions.showdata(rtnList[0]);
					var LOANList =resp.LOANList ||[];					
					 $('LOANList').update('');
					for(var i = 0 ; i < LOANList.length; i++){
									
						$('LOANList').insert(actions.getLink(LOANList[i].LOAN_ID));	
						if( i != LOANList.length-1){
							$('LOANList').insert('、');	
						}							
					}									
					CreateTabs(resp);
				},
				function(resp){
				    actions.showdata("");
					//CreateTabs();
			    }
			);
		},
		// 列印
		doPrint: function() {
			
			ajaxPost('print', { 'LOAN_ID': LOAN_ID },
				function(resp){					
					RPTUtil.executePrintByResponse(resp, true);			
				}		
			);
		    
            //RPTUtil.executePrintByLink('print' , {	'LOAN_ID': LOAN_ID}, true );	
			
		}
	
	};

	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSD11800','催收作業','催收明細作業');

			buttons.doQuery();//初始查詢
			PageUI.resize();

			displayMessage();				
		}
	}
}
</script>
</head>
<body>
<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
		<tr>
			<td class='tbYellow' width="8%">
				收息單位
			</td>
			<td class='tbYellow2' width="10%">
				<span  id="DEPT_ID" ></span>	
			</td>
			<td class='tbYellow' width="8%">
				貸款帳號
			</td>
			<td class='tbYellow2' width="10%">
				<span  id="LOAN_ID" ></span>	
			</td>
            <td class='tbYellow' width="8%">
				姓名
			</td>
			<td class='tbYellow2' width="10%" colspan="3">
				<span  id="BORROW_NAME" style="font-family:'EUDC'"></span>	<%-- [20240322]難字 --%>
			</td>
		</tr>
		<tr>
		    <td class='tbYellow' width="8%">
		   	    契約效力
			</td>
			<td class='tbYellow2' width="10%">
				<span  id="LOAN_STATUS_NM" ></span>	
			</td>
			<td class='tbYellow' width="8%">
		   	    上期實繳日
			</td>
			<td class='tbYellow2' width="10%">
				<span  id="REAL_PAYDT" ></span>	
			</td>
		    <td class='tbYellow' width="8%">
		   	    下期應繳日
			</td>
			<td class='tbYellow2' width="10%">
				<span  id="NEXT_PAYDATE" ></span>	
			</td>
			<td class='tbYellow' width="12%">
		   	    已繳期數
			</td>
			<td class='tbYellow2' width="6%">
				<span  id="PAY_TERM" ></span>	
			</td>	
		</tr>
		<tr>
			<td class='tbYellow' width="8%">
				電話(日)
			</td>
			<td class='tbYellow2' width="10%">
				<span  id="DAY_TEL" ></span>	
			</td>
			<td class='tbYellow' width="8%">
				電話(夜)
			</td>
			<td class='tbYellow2' width="10%">
				<span  id="NIGHT_TEL" ></span>	
			</td>
            <td class='tbYellow' width="8%">
				行動電話
			</td>
			<td class='tbYellow2' width="10%">
				<span  id="MOBILE" ></span>	
			</td>
			 <td class='tbYellow' width="12%">
				餘額放款率（％）
			</td>
			<td class='tbYellow2' width="6%">
				<span  id="REMAIN_AMT_RATE" ></span>	
			</td>
		</tr>
		<tr>
			<td class='tbYellow' width="8%">
				相關帳號
			</td>
			<td class='tbYellow2' width="10%" rowSpan = "2" colSpan = "7">
				<span id="LOANList" ></span><font color="red"><span  id="TRANS_EXTRACT_ADD" ></span></font>	
			</td>			
		</tr>
		
    </table>
	<div id='tabsMenu' style="width:100%"></div>		
		<div id="contents" class="tab">		
		<iframe id="DSD11801" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSD11802" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSE12501" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSD12000" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSD11804" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSD10410" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSH00300" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSH00200" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSD11800" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<%--[20230711]新增「列印劃撥單」、「查詢火險」、「查詢扣款不成原因」頁籤--%>
		<iframe id="DSC33700" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSB30400" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSD11300" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
	</div>	
</form>	
</body>
</html>