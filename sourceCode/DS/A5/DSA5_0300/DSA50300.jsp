<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA50300.jsp
作者：謝雅筑
功能：受理單位維護
完成：2012/06/07
-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSA50300().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA50300(){
	var valid;
	
	var buttonAuth = function (){
		var authButtons = {
			B0003:"btn_insert"<%--新增--%> ,
			B0004:"btn_update"<%--修改--%> ,
			B0005:"btn_delete"<%--刪除--%> 
		};
		<dz:grantButtons FUNC_ID="DSA50300" ignored="false"/>
	};	
	
	var actions = {

		//查詢
		doQuery:function(){
			$('Q_APPLY_DEPT').value = $F('Q_APPLY_DEPT').toUpperCase();
			valid.reset();
			valid.clear();
			if( !valid.validate() ) {
	    		return;
	    	}	

			ajaxPost('query',{Q_APPLY_DEPT:$F('Q_APPLY_DEPT'),Q_APPLY_YEAR:$F('Q_APPLY_YEAR')},
				function(resp){
					commonTools.loadData(resp.rtnMap);
				},
				function(){
					commonTools.loadData({});
				}
			);
		},

		
		//新增
		doInsert:function(){
			$('Q_APPLY_DEPT').value = $F('Q_APPLY_DEPT').toUpperCase();
			valid.reset();
			addValidItem();
			if( !valid.validate() ) {
	    		return;
	    	}			
	    	
	    	var dataMap = {};
	    	dataMap.APPLY_DEPT = $F('Q_APPLY_DEPT');
	    	dataMap.APPLY_YEAR = $F('Q_APPLY_YEAR');
	    	dataMap.APPLY_NO =  $F('APPLY_NO');
	    	
			ajaxPost('insert',{DTDSA005VO:Object.toJSON(dataMap)},
				function(resp){
					commonTools.loadData(resp.rtnMap);
				}
			);
	    	
		},
		
		//修正,刪除
		doAction1:function(act){
			$('Q_APPLY_DEPT').value = $F('Q_APPLY_DEPT').toUpperCase();
			valid.reset();
			addValidItem();
			if( !valid.validate() ) {
	    		return;
	    	}			

	    	if($F('APPLY_DEPT')==''||$F('APPLY_YEAR')==''){
	    		alert('請先查詢再做UPDATE或DELETE!');
	    		return;
	    	}
	    	
	    	if(!checkNotChange($F('Q_APPLY_DEPT'),$F('APPLY_DEPT'),'單位')){
	    		return;
	    	}
	    	
	    	if(!checkNotChange($F('Q_APPLY_YEAR'),$F('APPLY_YEAR'),'年度')){
	    		return;
	    	}
	    	
	    	if(act=='delete'){
	    		if(!confirm('確定要刪除'+$F('Q_APPLY_DEPT')+'此受理單位之資料?')){
	    			return;
	    		}
	    	}
	    	var dataMap = commonTools.getParams();
			ajaxPost(act,{DTDSA005VO:Object.toJSON(dataMap)},
				function(resp){
					commonTools.loadData(resp.rtnMap);
				}
			);
	    	
		}

	};
	
	//undefined,null 顯示''
	var noNull = function(v){
		if(v == null || v == undefined){
			v='';
		}
		return v; 
	};
	
	//新增,修正,刪除使用
	var addValidItem = function(){
		if(valid){
			valid.clear();
		}
		valid.define( "validate-positive-msg-change" , [{ id : "APPLY_NO"}]);
	};
	
	var checkNotChange = function(v1,v2,name){
		if(v1 != v2){
   			alert('欲作業的'+name+':'+v1+'與原先查詢的'+name+':'+v2+'不同,無法作業!');
    		return false;	
    	}else{
    		return true;
    	}
	};
	
	var commonTools = {	
		//載入查詢資料	
		loadData:function(rtnMap){
			rtnMap= rtnMap?rtnMap:{};
			$$('#tableB input').each(function(o){
				o.value = noNull(rtnMap[o.id]);
			});	
			$('INPUT_NM').update(noNull(rtnMap.INPUT_NM));
			var INPUT_DATE = noNull(rtnMap.INPUT_DATE);
			$('INPUT_DATE').update(INPUT_DATE?Date.toROC(INPUT_DATE):INPUT_DATE);		
		},
		//取得資料	
		getParams:function(){
			var dataMap = {};
			$$('#tableB input').each(function(o){
				dataMap[o.id] = o.value;
			});		
			return dataMap;		
		}
	};
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSA5_0300/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT,resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction(resp);
		 		}
	        }}
		);
	}
	

	return{                              
		initApp:function(){
			PageUI.createPage("DSA50300" , "管理作業" , "受理單位維護", false);
			PageUI.loadin(["form1"] ,1);
			
			valid = new Validation("form1", { focusOnError:true, immediate:false });
			Validation.addAllThese([
				[ 'validate-positive-msg-change', '受理序號有誤, 請檢查後重新輸入!',
					function(v){
						return (v!=''&& v!='0' && Validation.get('validate-digits').test(v));		
					}
				]				
			]);	
			//查詢
			$('btn_query').observe('click',function(event){actions.doQuery();});
			
			//新增
			$('btn_insert').observe('click',function(event){actions.doInsert();});
			
			//修正
			$('btn_update').observe('click',function(event){actions.doAction1('update');});
			
			//刪除
			$('btn_delete').observe('click',function(event){actions.doAction1('delete');});

			autoFormatToNumber();
			buttonAuth();
			displayMessage();

		}        
	}

}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body>
<!------------------------ A區--------------------->		
	<form id="form1" name="form1" method="post">	
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">	
				<tr>
					<td class="tbYellow" width="15%" >單位</td>
					<td class="tbYellow2" width="20%">
						<input id="Q_APPLY_DEPT" name="Q_APPLY_DEPT" type="text" fieldName="單位" class="textBox2 required" size="6" maxlength="5" />
					</td>
					<td class="tbYellow" width="15%" >年度</td>
					<td class="tbYellow2" width="20%">
						<input id="Q_APPLY_YEAR" name="Q_APPLY_YEAR" type="text" fieldName="年度" class="textBox2 required validate-integer" size="4" maxlength="3" />
					</td>
					<td class="tbYellow2" width="30%" align="center">
						<input id="btn_query" type="button" class="button" value="查詢" />
					</td>
				</tr>
				<tr>
					<td align="center" colspan="5">
						<input id="btn_insert" type="button" class="button" value="新增" />
						<input id="btn_update" type="button" class="button" value="修改" />
						<input id="btn_delete" type="button" class="button" value="刪除" />
					</td>
				</tr>
			</table>
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB">	
				<tr>
					<td class="tbYellow" width="15%" >受理序號</td>
					<td class="tbYellow2" width="85%" >
						<input id="INPUT_ID" name="INPUT_ID" type="hidden" />
						<input id="APPLY_DEPT" name="APPLY_DEPT" type="hidden" />
						<input id="APPLY_YEAR" name="APPLY_YEAR" type="hidden" />
						<input id="APPLY_NO" name="APPLY_NO" type="text" class="textBox2" size="5" maxlength="4" />
						&mdash;由此序號之後
					</td>
				</tr>
				<tr>
					<td class="tbYellow" >作業人員</td>
					<td class="tbYellow2"><span id="INPUT_NM"></span></td>
				</tr>
				<tr>
					<td class="tbYellow" >作業日期</td>
					<td class="tbYellow2"><span id="INPUT_DATE"></span></td>
				</tr>
			</table>
	</form>	
</body>
<!-- InstanceEnd -->
</html>