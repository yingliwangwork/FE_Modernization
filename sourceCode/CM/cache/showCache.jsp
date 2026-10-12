<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%

	// 2020-02-06 cheaty77 白帽駭客測試可不登入就觀看此頁面, 可能造成cache內敏感資料外洩
	// 先簡單做直接取session userobject, key值先寫死$Data.$coreSys$UserObject吧
	Object userObj = session.getAttribute("$Data.$coreSys$UserObject");
	if(userObj == null){
		out.write("使用者未登入");
		return;
	}

	//系統別
	String sys = request.getParameter("SYS");
	//對此系統別的描述
	String sysDesc = request.getParameter("SYS_DESC");
	//登入 id
	String LOGIN_ID = request.getParameter("LOGIN_ID");
	//存放 cache 的物件
	Map managerMap = com.cathay.common.util.cache.CacheManager.getManagerMap();
	
	List keys = Arrays.asList(managerMap.keySet().toArray());
	Collections.sort(keys);
	
	List<Map> rtnList = new ArrayList<Map>();
	
	for(Object obj : keys){
		Map rtnMap = new HashMap();
		
		String cacheDesc = obj.toString();
		Map cacheMap = (Map)managerMap.get(cacheDesc);	
		
		rtnMap.put("CACHE_NM", cacheDesc);
		
		rtnMap.put("CACHE_SIZE", cacheMap.size());
		
		rtnList.add(rtnMap);
		
	}	

	pageContext.setAttribute("rtnList", com.cathay.common.im.util.VOTool.toJSON(rtnList));
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp" %>
<title>Cache管理 - 項目名稱</title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javaScript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/javascript">

	function doClose() {
		self.close();
	}

	function showDtl(cacheDesc) {
		var frm = document.form1;
		frm.CACHE_DESC.value = cacheDesc;
		frm.action='showCacheDtl.jsp';
		frm.submit();
	}
	
	function clearDtl(cacheDesc){
		var frm = document.form1;
		frm.CACHE_DESC.value = cacheDesc;
		frm.action='clearCache.jsp';
		frm.submit();
	}
	
	var grid;
	
	function init(){
		grid = new TableUI({
			table: $('grid'), pageSize: 0, 
			title : "<%=sys%>　<%=sysDesc%>",
			column: [
				{header: "cache 名稱", key: 'CACHE_NM', render: function(rec, val){
					var size = rec['CACHE_SIZE'];
					if(size){
						var a = new Element('a',{href:"#"}).update(val);
						a.observe('click', function(){showDtl(val)});
						return a;
					}
					return val;
				}},
				{header: "cache size", key: 'CACHE_SIZE' }
			]
		});
		
		var rtnList = <c:out value="${rtnList}" default="[]" escapeXml = "false"></c:out>;
		
		grid.load(rtnList);
	}
	
	Event.observe( window , 'load', init );

</script>
</head>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

<form name="form1" method="get">
	<center>
		<table id='grid' name='grid'></table>
	</center>
	<input type="hidden" name="CACHE_DESC" />
	<input type="hidden" name="SYS" value="<%=sys%>" />
	<input type="hidden" name="SYS_DESC" value="<%=sysDesc%>" />
	<input type="hidden" name="LOGIN_ID" value="<%=LOGIN_ID%>" />
	<p align="center">
		<input name="close_btn" type="button" class="button" onClick="doClose()" value="關閉視窗" />	
	</p>
</form>
</body>
</html>