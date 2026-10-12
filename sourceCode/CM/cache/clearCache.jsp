<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp" %>
<%@ page import="com.cathay.common.util.cache.*" %>
<%@ page import="org.apache.commons.lang.*" %>
<%

	//此 jsp 每個 web 下都必需存在
	
	//系統別
	String sys = request.getParameter("SYS");
	
	//對此系統別的描述
	String sysDesc = request.getParameter("SYS_DESC");
	
	//對此 cache 的描述
	Object CACHE_DESC = request.getParameter("CACHE_DESC");
	
	//登入 id
	String LOGIN_ID = request.getParameter("LOGIN_ID");
	
	//若未傳入 cache 的描述 , 則清空該系統下所有的 cache 資料
	if(StringUtils.isBlank(ObjectUtils.toString(CACHE_DESC))){
	
		//清除此系統的所有 cache
		//CacheManager.clearCache();	
		
		//寫入 log 檔
		new CacheLogger().doInsertDTZZX006(sys , "ALL" , LOGIN_ID);
		
	}else{
		
		//僅清除該系統下特定的參數
		//CacheManager.clearCache(CACHE_DESC);	
		
		//寫入 log 檔
		new CacheLogger().doInsertDTZZX006(sys , CACHE_DESC.toString() , LOGIN_ID);
	
	}	

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><!-- InstanceBegin template="file:///D|/CN_Cathay/Templates/iframe.dwt" codeOutsideHTMLIsLocked="false" -->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<!-- InstanceBeginEditable name="doctitle" -->
<title>無標題文件</title>
<!-- InstanceEndEditable --> 
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<!-- InstanceBeginEditable name="head" --><!-- InstanceEndEditable -->
</head>

<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<!-- InstanceBeginEditable name="EditRegion1" -->
<form name="form1">
	<input type="hidden" name="SYS" value="<%=sys%>"/>
	<input type="hidden" name="SYS_DESC" value="<%=sysDesc%>"/>
	<input type="hidden" name="LOGIN_ID" value="<%=LOGIN_ID%>"/>
</form>
<script>

<%if(StringUtils.isBlank(ObjectUtils.toString(CACHE_DESC))){%>
	
	//日期物件
	var dateObj = new Date();
	
	//時
	var hours = dateObj.getHours();
	
	if(hours < 10){
	
		hours = "0" + hours;
		
	}
	
	//分
	var minutes = dateObj.getMinutes();
	
	if(minutes < 10){
	
		minutes = "0" + minutes;
		
	}
	
	//秒
	var seconds = dateObj.getSeconds();	
	
	if(seconds < 10){
	
		seconds = "0" + seconds;
		
	}
	
	var msg = hours+" : "+minutes+" : "+seconds+" 清除完成";

	var obj = opener.JimTable;	
	
	var oRow; 
  	var oCell;
  	
  		oRow = obj.insertRow();
  		
			for (var k=0; k<3 ; ++k) { 
			
  		 		oCell = oRow.insertCell() ;  
  		 		oCell.align = 'center'; 		 	
  		 		oCell.className="tbYellow2"; 
  		 	} 		 	
	
		oRow.cells[0].innerHTML = "<%=sys%>"; 
		oRow.cells[1].innerHTML = "<%=sysDesc%>"; 
		oRow.cells[2].innerHTML = msg; 
		
		self.close();
		
<%}else{%>
		
		var URL ='showCache.jsp';			
		
		var frm = document.form1;
		
		frm.action=URL;
		
		frm.submit();
		
<%}%>
</script><!-- InstanceEndEditable -->
</body>
<!-- InstanceEnd --></html>
