<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ page import="com.cathay.common.im.util.VOTool"%>
<%@ page import="org.apache.commons.collections.MapUtils"%>
<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="com.cathay.common.util.STRING"%>
<%@ page import="org.apache.commons.lang.ObjectUtils"%>
<%

	// 2020-02-06 cheaty77 白帽駭客測試可不登入就觀看此頁面, 可能造成cache內敏感資料外洩
	// 先簡單做直接取session userobject, key值先寫死$Data.$coreSys$UserObject吧
	Object userObj = session.getAttribute("$Data.$coreSys$UserObject");
	if(userObj == null){
		out.write("使用者未登入");
		return;
	}

%>
<%! 
	//資料處理
   public void appendValue(Object value, StringBuffer sbf) { 
		if(value instanceof Object[][]){
			Object[][] strValss = (Object[][])value;
			for(int i=0;i<strValss.length;i++){
				Object[] strVals = strValss[i];
				if(i>0){
					sbf.append("<br>");
				}
				for(int j=0;j<strVals.length;j++){
					Object strVal = strVals[j];
					if(j>0){
						sbf.append("、");
					}
					sbf.append("String[").append(i).append("]").append("[").append(j).append("]=").append(strVal);
				}
			}
		}else if(value instanceof Object[]){
			Object[] strVals = (Object[])value;
			for(int i=0;i<strVals.length;i++){
				Object strVal = strVals[i];
				if(i>0){
					sbf.append("、");
				}
				sbf.append("String[").append(i).append("]");
			}
		}else{
			sbf.append(value);
		}
   } 
%>


<%

	String cacheDesc = request.getParameter("CACHE_DESC");	

	String sys = request.getParameter("SYS");

	String sysDesc = request.getParameter("SYS_DESC");
	
	//是不是第一次連進來(是否為Ajax請求)
	boolean isAjaxRequest = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
	//非第一次連進來,可能是查詢或是要求顯示Detail
	if(isAjaxRequest){
		
		response.setContentType("text/json;application/json;charset=utf-8");
		
		Map param = VOTool.jsonToMap(request.getParameter("param"));
	
		//Ajax請求的cacheDesc,sys,sysDesc 包在param中
		cacheDesc = MapUtils.getString(param, "cacheDesc");
		
		sys = MapUtils.getString(param, "sys");
		
		sysDesc = MapUtils.getString(param, "sysDesc");
		
		//搜尋的關鍵字,用來過濾
		String queryKey = MapUtils.getString(param, "queryKey");

		//若無關鍵字,設為空白,代表搜尋全部
		boolean needQuery = StringUtils.isNotBlank(queryKey);
		if(!needQuery){
			queryKey = "";
		}
		
		Map managerMap = com.cathay.common.util.cache.CacheManager.getManagerMap();

		Map cacheMap = (Map)managerMap.get(cacheDesc);

		Iterator iterator = cacheMap.keySet().iterator();	

		List keyList = new ArrayList();

		while(iterator.hasNext()){			

			Object cacheDtl = iterator.next();
			
			//如果有搜尋條件,則過濾
			if(needQuery){
				String keyStr = ObjectUtils.toString(cacheDtl);
				if(keyStr.indexOf(queryKey) < 0){
					continue;
				}
			}
			
			keyList.add(cacheDtl);

		}
		
		String forDetail = request.getParameter("forDetail");
		
		if("true".equals(forDetail)){
			
			int index = Integer.parseInt(request.getParameter("index"));
			Object value = cacheMap.get(keyList.get(index));
			StringBuffer sb = new StringBuffer();
			
			appendValue(value, sb);
			
			Map responseMap = new HashMap();
			responseMap.put("value",sb.toString());
			out.write(VOTool.toJSON(responseMap));
			return;
		}
		
		//總共的筆數
		int totalCount  = keyList.size();
		
		Map responseData = new HashMap();
			
		Map ErrMsg = new HashMap();
		
		if(totalCount != 0 ){
		
			String loadStrat = request.getParameter("loadStrat");

			String loadEnd = request.getParameter("loadEnd");

			int startWith = STRING.isNumeric(loadStrat) ? Integer.valueOf(loadStrat) : -1;

			int endWith = STRING.isNumeric(loadEnd) ? Integer.valueOf(loadEnd) : -1;
		
			List<Map> rtnList = new ArrayList<Map>();
			
			StringBuffer sbf = new StringBuffer();
		
			int upperBound = totalCount < endWith ? totalCount : endWith;
		
			//根據真分頁查詢傳進來的直做回傳
			for(int printIndex = startWith - 1; printIndex < upperBound; printIndex++){
			
				Object key = keyList.get(printIndex);
			
				Map rtnMap = new HashMap();
				
				rtnMap.put("MULTIKEYS", ObjectUtils.toString(key));
				
				rtnMap.put("index", printIndex);
				
				rtnList.add(rtnMap);
			}
			
			responseData.put("records", rtnList);
			
			boolean isFirstQuery = "Y".equals(request.getParameter("isFirstQuery"));

			if(isFirstQuery){
				
				responseData.put("totalOfRecords", totalCount);
			}
			
			ErrMsg.put("returnCode", 0);
			
			ErrMsg.put("displayMsgDescs", "");
			
			responseData.put("ErrMsg", ErrMsg);
			
			out.write(VOTool.toJSON(responseData));
		}else{
			
			responseData.put("totalOfRecords", 0);
			
			ErrMsg.put("returnCode", 0);
			
			ErrMsg.put("displayMsgDescs", "");
			
			responseData.put("ErrMsg", ErrMsg);
			
			out.write(VOTool.toJSON(responseData));
		}
	}
	if(!isAjaxRequest){
%>

<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp" %>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><!-- InstanceBegin template="file:///D|/CN_Cathay/Templates/iframe.dwt" codeOutsideHTMLIsLocked="false" -->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<!-- InstanceBeginEditable name="doctitle" -->
<title>Cache管理 - 項目明細</title>
<!-- InstanceEndEditable --> 
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javaScript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/javascript">
<!--

	function doBack(){
		var submitForm = $('submitForm');
		submitForm.action = 'showCache.jsp';
		submitForm.submit();
	}	
	function doClose(){
		self.close();
	}
	
	function getParam(){
		var param = {};
		param.cacheDesc = $F('CACHE_DESC') || '';
		param.queryKey = $F('queryKey') || '';
		param.sys = $F('SYS') || '';
		param.sysDesc = $F('SYS_DESC') || '';
		return param;
	}
	
	
	<%-- 關鍵字查詢 --%>
	function doQuery(){
		grid.load( 'showCacheDtl.jsp', getParam() ); 
	}
	<%-- 畫面Detail展開 --%>
	function doDetail(node, record){
		
		var param = getParam();
		new Ajax.Request("showCacheDtl.jsp",{
			parameters : {	
							param : Object.toJSON(getParam()),
							forDetail : "true",
							index : record['index']
			},
			onSuccess :　function(XHT, resp){
				var parent = $(node).parentNode;
				var div = new Element('div').update(resp.value);
				record['orgVal'] = resp.value;
				$(node).remove();
				parent.insert(div);
			}
		});
	}
	
	var grid;
	
	function init(){
		
		grid = new TableUI({
			table: $('grid'), pageSize: 30, isLoadByFatch :true ,
			title : "<%=sys%>　<%=sysDesc%>  <%=cacheDesc%> 內容",
			needHeader:false, 
			column: [
				{header: "", key: 'MULTIKEYS' },
				{header: "", key: "", attrs:{width:"700px","text-align":"center"} , render : function(rec, val){
					var orgVal = rec['orgVal'];
					if(orgVal){
						return orgVal;
					}
					var buttonName = 'btn_'+rec['index'];
					
					var button = new Element('button',{class:'button',id: buttonName,name: buttonName}).update('顯示');
					button.observe('click', function(){doDetail(buttonName, rec);});
					return button;
				}}
				
			]
		});
		
		doQuery();
		
	}
	Event.observe( window , 'load', init );
//-->
</script>
</head>

<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<!-- InstanceBeginEditable name="EditRegion1" -->
	<table class="tbBox2" width="100%">
		<tr class="tbBlue3" align="center">
			<td>
				<input id="queryKey" name="queryKey" type="text" value="">
				<button id="btn_query" name="btn_query" class="button" onClick="doQuery()"/>查詢
			</td>
		</tr>
	</table>
	<table id="grid" name="grid"></table>
	<form id="submitForm" name="submitForm">
			<input id="CACHE_DESC" name="CACHE_DESC" type="hidden" value="<%=cacheDesc%>">
			<input id="SYS" name="SYS" type="hidden" value="<%=sys%>">
			<input id="SYS_DESC" name="SYS_DESC" type="hidden" value="<%=sysDesc%>">
			
	</form>
	
</center>

		<p align="center">
			<input name="close_btn" type="button" class="button"  onClick="doBack()" value="回上頁"/>
			<input name="close_btn" type="button" class="button"  onClick="doClose()" value="關閉視窗"/>	
		</p>
		
</body>
<!-- InstanceEnd --></html>
<%
    } 
%>
	