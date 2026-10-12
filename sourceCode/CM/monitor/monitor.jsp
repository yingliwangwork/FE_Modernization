<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ page import="com.cathay.zz.z0.module.ZZ_Z0Z001" %>
<%@ page import="java.util.*" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">

<%@ taglib uri="/CXL" prefix="CXL" %>
<CXL:csCommon trace="false" htmlBaseName="htmlBase" 
                           cssBaseName="cssBase" 
                           imageBaseName="imageBase"
                           dispatcherName="dispatcher">

<%
	com.igsapp.wibc.dataobj.Context.ResponseContext resp = (com.igsapp.wibc.dataobj.Context.ResponseContext)request.getAttribute("$Attribute.responseContext");
	String strSysCode = "";
	String strSysName = "";
	ZZ_Z0Z001 zz_z0z001 = new ZZ_Z0Z001();
	String[] systems = null;
	String[] sysProd = {"AA","AB","AC","AD","AE","AG","AH","AI","AJ","AK","AM","AP","AR","AT","AV","CB","DB","DD","DF","DJ","DN","FA","FM"};
	String[] sysProd2 = {"AA","AB","AC","AD","AJ","AK","AM","AP","AT","AW","CB","DD","DF","DJ","EA","FA","FM","FN","FW","GC"};
	String[] sysStag = {"AA","AB","AC","AD","AE","AG","AH","AI","AJ","AK","AM","AP","AR","AT","AV","CB","DB","DD","DF","DJ","DN","FA","FM"};
	String[] sysTest = {"AA","AB","AC","AD","AE","AG","AH","AI","AJ","AK","AM","AP","AR","AT","AV","CB","DB","DD","DF","DJ","DN","FA","FM"};
	

	Hashtable hostname = new Hashtable();
	hostname.put("10.87.48.45","cxlcs3ap");
	hostname.put("10.87.48.42","cxlcs4ap");
	hostname.put("10.87.48.46","cxlcs5ap");
	hostname.put("10.87.48.43","cxlcs1ap");
	hostname.put("202.154.204.13","was2.cathaylife.com.tw");
	hostname.put("10.87.48.44","was3.cathaylife.com.tw");
	hostname.put("was1.cathaylife.com.tw","was1");
	hostname.put("was2.cathaylife.com.tw","was2");
	hostname.put("was3.cathaylife.com.tw","was3");
	hostname.put("swas3.cathaylife.com.tw","swas3");
	hostname.put("twas3.cathaylife.com.tw","twas3");


	Hashtable status = new Hashtable();
	status.put("cxlcs1ap","0");
	status.put("cxlcs3ap","0");
	status.put("cxlcs4ap","0");
	status.put("cxlcs5ap","0");
	status.put("was1.cathaylife.com.tw","0");
	status.put("was2.cathaylife.com.tw","0");
	status.put("was3.cathaylife.com.tw","0");
	status.put("was1","0");
	status.put("was2","0");
	status.put("was3","0");
	status.put("cxlcs1as","1");
	status.put("cxlcs2as","1");
	status.put("swas3.cathaylife.com.tw","1");
	
	String strServerIP = request.getServerName();
	String strServerName = (hostname.get(strServerIP)!=null?hostname.get(strServerIP).toString():"");
	String strStatus = (status.get(strServerName)!=null?status.get(strServerName).toString():"");
	String isProd = ("0".equals(strStatus)?"1":"0");
	//子網頁refresh的秒數
	String strRefresh = "30";
	
	if("0".equals(strStatus)){
		if("was2.cathaylife.com.tw".equalsIgnoreCase(strServerName) || "was2".equalsIgnoreCase(strServerName))
			systems = sysProd2;
		else
			systems = sysProd;
	}else if("1".equals(strStatus)){
		systems = sysStag;
	}else{
		systems = sysTest;
	}
	
	
	int row = 6;
	int col = 5;
	
	StringBuffer sb = new StringBuffer();
	sb.append(" rows='");
	for(int i=0; i<row-1;i++){
		sb.append(100/row).append("%, ");
	}
	sb.append("*'  cols='");
	for(int i=0; i<col-1;i++){
		sb.append(100/col).append("%, ");
	}
	sb.append("*' ");
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<meta http-equiv="refresh" content="120; url=<%=htmlBase%>/CM/monitor/monitor.jsp">
<title>國泰人壽</title>
</head>

<frameset rows="50,*" cols="*" frameborder="NO" border="0" framespacing="0" >
  	<frame src="<%=htmlBase%>/CM/monitor/monitor_top.jsp?serverName=<%=strServerName%>&serverIP=<%=strServerIP%>&isProd=<%=isProd%>" name="topFrame" scrolling="no" noresize >
	<frameset <%=sb.toString()%> frameborder="YES" border="1" framespacing="0" >
	<%
		for(int i=0; i<systems.length; i++){
	%>
	 	<frameset rows="25,*" cols="*" frameborder="NO" border="0" framespacing="0" >
	  		<frame src="/CXLWeb/html/CM/monitor/monitor_title.jsp?syscode=<%=systems[i]%>&sysname=<%=java.net.URLEncoder.encode( zz_z0z001.getSysName(systems[i]))%>&refresh=<%=strRefresh%>" scrolling="no" >
		  	<frame name='frame_<%=systems[i]%>' src="/<%=systems[i]%>Web/html/CM/monitor/monitor_info.jsp?syscode=<%=systems[i]%>&sysname=<%=java.net.URLEncoder.encode( zz_z0z001.getSysName(systems[i]))%>&refresh=<%=strRefresh%>" scrolling="no" >
	  	</frameset>
	<%
		}
	%>
	  	<frameset rows="25,*" cols="*" frameborder="NO" border="0" framespacing="0" >
		  <frame src="/CXLWeb/html/CM/monitor/monitor_title.jsp?syscode=ZZ&sysname=<%=java.net.URLEncoder.encode( zz_z0z001.getSysName("ZZ"))%>&refresh=<%=strRefresh%>" scrolling="no" >
		  <frame name='frame_ZZ' src="/CXLWeb/html/CM/monitor/monitor_info.jsp?syscode=ZZ&sysname=<%=java.net.URLEncoder.encode( zz_z0z001.getSysName("ZZ"))%>&refresh=<%=strRefresh%>" scrolling="no" >
		</frameset>
	</frameset>
</frameset>

<noframes>

<body>
</body>
</noframes>

</html>
</CXL:csCommon>
