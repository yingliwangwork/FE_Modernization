<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!--
程式：DSE11200.jsp
功能：法務個件異動
作者：卓達瑋
完成：2013/08/13

[20240207]
難字調整
高強禾
 --> 

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" /><!--匯入外部Javascript 與 css-->
<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/javaScript" src="<%=htmlBase%>/CM/js/ui/tabs.js"></script>         <%-- 頁簽使用 --%>
<script src="${htmlBase}/CM/js/ui/popupWin.js"></script>
<%-- [20240207] 難字調整 --%>
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


Event.observe(window, 'load', new DSE11200().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE11200(){
    var valid1;
	var valid2;
	function initValidation(){
            Validation.addAllThese( [
				[ 'LOAN_ID_checklength', '貸款帳號長度必需為10碼',
					function( v , elem ) {
						
						if(v.length!=10){
							return false
						}
						return true;
					}
				]
		    ]);
			//查詢用檢核
			valid1 = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'})	
			valid1.define( "required" , { id: "LOAN_ID" , errMsg:"貸款帳號不可為空!!" } );
			valid1.define( "LOAN_ID_checklength" , { id: "LOAN_ID"} );
			valid2 = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'})	
			valid2.define( "required" , { id: "LOAN_ID" , errMsg:"貸款帳號不可為空!!" } );
			valid2.define( "required" , { id: "FILE_NO" , errMsg:"案件編號不可為空!!" } );
			valid2.define( "required" , { id: "LAW_PROCESS_DATE" , errMsg:"法務進度日不可為空!!" } );
			valid2.define( "required" , { id: "LAW_PROCESS" , errMsg:"法務進度不可為空!!" } );
    }
	function buttonAuth() {
		var authButtons = { 		
			B0111 : 'BTN_UPDATE',
			B0174 : 'BTN_PRINT',
			B0044 : 'BTN_LEGAL'
		};
		<dz:grantButtons FUNC_ID ="DSE11200"/>
	}
	//頁簽
	function CreateTabs(TabList){
			var tabsList=[];
			var size=TabList.length;
			var ANCESTOR_ID=TabList[TabList.length-1].ANCESTOR_ID;
			var LOAN_ID_A=TabList[0].LOAN_ID;
			var REFER_ID_A=TabList[1].REFER_ID;
			var SEQ_NO=TabList[0].SEQ_NO;
			for(var i=0;i<size;i++){
			var tabMap={};
			tabMap['id']=TabList[i].FUNC_ID;
			tabMap['title']=TabList[i].TITLE;
			tabsList.push(tabMap);
			}
			
			tabs = new Tabs({
			
				id:'tabsMenu',
				
				tabs:tabsList,
				beforeSwitch: function(info){
		/*			//調整外部的高度大小，固定下來，讓上下的 scroll 不生效
					var h = document.body.clientHeight;
					
					//調整高度
					//h = h  - 100;
					h=h-150;
					$$('#contents iframe').each(function(it){
						it.height = h;
					});					
		*/			
					var f = $(info.to);
					if(info.to == 'DSE11700'){
					    f.src= "<%=dispatcher%>/"+info.to.substring(0,4)+"_"+info.to.substring(4,9)+"/prompt?ANCESTOR_ID="+ANCESTOR_ID;
					}else if(info.to == 'DSE11201'){
					    f.src= "<%=dispatcher%>/"+info.to.substring(0,4)+"_"+info.to.substring(4,9)+"/prompt?LOAN_ID="+LOAN_ID_A+"&SEQ_NO="+SEQ_NO;
					}else if(info.to == 'DSE11202'){
					    f.src= "<%=dispatcher%>/"+info.to.substring(0,4)+"_"+info.to.substring(4,9)+"/prompt?LOAN_ID="+LOAN_ID_A+"&REFER_ID="+REFER_ID_A;
					}else if(info.to == 'DSD12000'){
					    f.src= "<%=dispatcher%>/"+info.to.substring(0,4)+"_"+info.to.substring(4,9)+"/prompt?REFER_ID="+REFER_ID_A+"&DATA_SRC=B";
					}else if(info.to == 'DSE12501'){
					    f.src= "<%=dispatcher%>/"+info.to.substring(0,4)+"_"+info.to.substring(4,9)+"/prompt?LOAN_ID="+LOAN_ID_A+"&INPUT_TYPE=3";
					}else{
					    f.src= "<%=dispatcher%>/"+info.to.substring(0,4)+"_"+info.to.substring(4,9)+"/prompt?LOAN_ID="+LOAN_ID_A;
					}

				},
				beforeSwitchShowCover: true
			});
	
		}
	
	
	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSE1_1200/" + actionName,
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
		    $w('BORROW_NAME INPUT_NAME RENEGE').each(
						function(ele){
							$(ele).update(rtnMap[ele]||'');
						}
			)
			$('INPUT_DATE').update(Date.toInputROC( rtnMap['INPUT_DATE'] || '' ,'/'));
			$('REJECT_DATE').update(Date.toInputROC( rtnMap['REJECT_DATE'] || '' ,'/'));
			$('LAW_PROCESS_DATE').setValue(Date.toInputROC( rtnMap['LAW_PROCESS_DATE'] || '' ,''));   
			$('FILE_NO').setValue(rtnMap['FILE_NO']||'');
			$('SEQ_NO').setValue(rtnMap['SEQ_NO']||'');
			$('LAW_PROCESS').setValue(rtnMap['LAW_PROCESS']||'');

		
		}
		
	};
		
		
	//按鈕功能	
	var buttons = {
		
		//初始查詢
		doQuery : function(){		
			
			valid2.reset();			
			if(!valid1.validate()){
				return;
			}
			
			ajaxPost( 'query' , { LOAN_ID : $F('LOAN_ID'),"SEQ_NO":$F('SEQ_NO')},
				function(resp){						
                    var rtnMap=resp.rtnMap;
					actions.showdata(rtnMap);
				    $("contents").show();
					var Tab_List=resp.Tab_List;
					CreateTabs(Tab_List);
				},
				function(resp){
				    $w('BORROW_NAME INPUT_NAME').each(
						function(ele){
							$(ele).update('');
						}
					)
					$('INPUT_DATE').update('');
					$('REJECT_DATE').update('');
			        $('LAW_PROCESS_DATE').setValue('');   
				    $('FILE_NO').setValue('');
					$('SEQ_NO').setValue('');
					$("contents").hide();
			    }
			);
		},
		//分頁查詢
		doQueryTab : function(){
		    
			valid2.reset();			
			if(!valid1.validate()){
				return;
			}
			
		    ajaxPost( 'querytab' , { LOAN_ID : $F('LOAN_ID'),"SEQ_NO":$F('SEQ_NO')},
				function(resp){						
                    $("contents").show();
					var Tab_List=resp.Tab_List;
					CreateTabs(Tab_List);

					
				},
				function(resp){
				    $("contents").hide();
			    }
			);
		}
		,
		// 列印
		doPrint: function() {
		    
			valid2.reset();			
			if(!valid1.validate()){
				return;
			}
			var reqMap={};
		    reqMap['FILE_NO'] = $('FILE_NO').getValue()||'';
			reqMap['LAW_PROCESS_DATE'] = toY2K($('LAW_PROCESS_DATE').getValue()||'');
			reqMap['SEQ_NO'] = $('SEQ_NO').getValue()||'';
			reqMap['LAW_PROCESS'] = $('LAW_PROCESS').getValue()||'';
		    reqMap['LOAN_ID'] = $F('LOAN_ID');
			
            //RPTUtil.executePrintByLink('print' , {	'LOAN_ID': $F('LOAN_ID'),'inputMap' : Object.toJSON(reqMap) }, true );	
			ajaxPost('print', { inputMap : Object.toJSON(reqMap) , LOAN_ID :  $F('LOAN_ID')},
			function(resp){
				
				RPTUtil.executePrintByResponse(resp, true);			
			}		
		);
			
			
			
		},
		// 法務卷宗
		doLegal: function() {
		    
			valid2.reset();			
			if(!valid1.validate()){
				return;
			}
			var reqMap={};
			reqMap['FILE_NO'] = $F('FILE_NO');
			reqMap['LAW_PROCESS_DATE'] = toY2K($F('LAW_PROCESS_DATE'));
			reqMap['SEQ_NO'] = $F('SEQ_NO');
		    reqMap['LAW_PROCESS'] = $F('LAW_PROCESS');
		    reqMap['LOAN_ID'] = $F('LOAN_ID');
			
		    ajaxPost( 'legaltab' , { 
					inputMap : Object.toJSON(reqMap) 
		    	},
				function(resp){		
		    		var REFER_ID = resp.REFER_ID;
		    		if(REFER_ID){
		    			var strlink='/AVWeb/servlet/HttpDispatcher/AVE0_6000/query';
		    			popupWin.windowOpen(strlink,{
		    				parameters : { 
		    				    'IMG_KIND_OPT'	: 'DS03',    //文件代碼
		    					'LINK_TYPE' : 'Y',
		    					'RCPT_NO' : REFER_ID       //原貸帳號
		    				}
		    			});		    			
		    		}
				}
			);
		},		
		//修改
		doUpdate : function(){
            
			valid1.reset();			
			if(!valid2.validate()){
				return;
			}
			
			
			var reqMap={};
		    reqMap['FILE_NO'] = $('FILE_NO').getValue()||'';
			reqMap['LAW_PROCESS_DATE'] = toY2K($('LAW_PROCESS_DATE').getValue()||'');
			reqMap['SEQ_NO'] = $('SEQ_NO').getValue()||'';
			reqMap['LAW_PROCESS'] = $('LAW_PROCESS').getValue()||'';
		    reqMap['LOAN_ID'] = $F('LOAN_ID');
			
			
			//發送ajax
			ajaxPost( 'update' , { 
					inputMap : Object.toJSON(reqMap) 
				},
				function(resp){	
					actions.showdata(resp.rtnMap);
				}
			);	
		
		}
		
		
		
	};
	

	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSE11200','法務件','法務個件異動');
			initValidation();
							
						
							
			//按鈕事件監聽
			$("BTN_QUERY").observe('click', buttons.doQuery);
            $("BTN_UPDATE").observe('click', buttons.doUpdate);
			$("BTN_PRINT").observe('click', buttons.doPrint);
			$("BTN_LEGAL").observe('click', buttons.doLegal);

			//Input欄位自動轉大寫
			$('LOAN_ID').observe('change',function(){
				$('LOAN_ID').value = $F('LOAN_ID').toUpperCase();
			});	
			
			
            <c:if test="${not empty LOAN_ID}">
			buttons.doQuery();//初始查詢
		    </c:if>
			
		    buttonAuth();
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
			<input type="hidden" id="SEQ_NO" value="">
			<td class='tbYellow' width="8%">
				貸款帳號
			</td>
			<td class='tbYellow2' width="10%">
				<input id='LOAN_ID' type='text' class= 'textBox2'   size='12' maxlength='10' value="${LOAN_ID}"/> 
			</td>
			<td class='tbYellow' width="6%">
				借款人
			</td>
			<td class='tbYellow2' width="7%">
				<%-- [20240207] 難字調整：借款人 --%>
				<span  id="BORROW_NAME" style="font-family:'EUDC'"></span>	
			</td>
			<td class='tbYellow' width="8%">
				法務進度
			</td>
			<td class='tbYellow2' width="10%">
				
				<select id="LAW_PROCESS" class="textBox2">
				<option value = "" >請選擇</option>
					<c:forEach items="${LAW_PROCESS_LIST}" var="map">							
						<option value='${map.key}'>${map.value}</option>
					</c:forEach>
				</select
			</td>
			<td class='tbYellow' width="8%">
				法務進度日
			</td>
			<td class='tbYellow2' width="12%">
				<input id="LAW_PROCESS_DATE" datatype="ROCDate" type="text" class="textBox2 "  size="10" maxlength="7" value=""/>
		     	<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('LAW_PROCESS_DATE'))">
			</td>
			
			<td class="tbYellow2" width="10%" rowspan="3"  align="center">
				<input type="button" class="button" id="BTN_QUERY" value="查詢"/>	
				<input type="button" class="button" id="BTN_UPDATE" value="異動"/>	
				<input type="button" class="button" id="BTN_PRINT" value="列印" />	
				<input type="button" class="button" id="BTN_LEGAL" value="法務卷宗" />	
					
			</td>
		</tr>
		<tr>
		    <td class='tbYellow' >
				法務人員
			</td>
			<td class='tbYellow2' >
				<%-- [20240207] 難字調整：法務人員 --%>
				<span  id="INPUT_NAME" style="font-family:'EUDC'">	</span>	
			</td>
			<td class='tbYellow'>
				受理日
			</td>
			<td class='tbYellow2' >
				<span  id="INPUT_DATE" >　 </span>	
			</td>
		    <td class='tbYellow' >
				退件日
			</td>
			<td class='tbYellow2' >
				<span  id="REJECT_DATE" > 　</span>	
			</td>
			<td class='tbYellow' >
				案件編號
			</td>
			<td class='tbYellow2' >
				<input id='FILE_NO' type='text' class= 'textBox2'    size='13' maxlength='11' /> 
			</td>
		
		</tr>
		<tr>
		    <td class='tbYellow' >
				違約金判斷<!--2018-01-08申請書-修改法院陳報債權及拍不足債權試算作業，對保日期在104.08.12(含)之後且貸款用途為購屋者於法務個件異動增加違約金判斷顯示，符合條件則顯示【違約金計收9期案件】-->
			</td>
			<td class='tbYellow2' colspan="7"  >
				<span  id="RENEGE" >	</span>	
			</td>
		
		</tr>
		
    </table>
	<div id='tabsMenu' style="width:100%"></div>		
		<div id="contents" class="tab">		
		<iframe id="DSE11201" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSD12000" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSE11202" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSE12501" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSD11805" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSE11203" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSE11204" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSE11205" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSE11206" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSE11208" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSE11207" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSE11209" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		<iframe id="DSE11700" frameborder="0" scrolling="auto" border="0" style="display:none;width:100%" ></iframe>
		
	</div>	
</form>	
</body>
</html>