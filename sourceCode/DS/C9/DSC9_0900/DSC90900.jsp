<!--
程式：DSC90900.jsp
功能：銀行理財型交易
作者：余凱鈞
完成: 2018-10-30 原DP recvMsg.jsp
-->
<%@ page language="java" buffer="8kb" autoFlush="true" isThreadSafe="true" isErrorPage="false" %>
<%@ page contentType="text/html; charset=Big5" %>
<%@ page import="cathay.util.*"%>
<%@ page import="cathay.dp.task.*"%>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*"%>
<%@ page import="com.cathay.ds.c9.module.DS_C90900"%>
<%@ page import="org.apache.log4j.Logger"%>
<%
	int xmlLength=request.getContentLength();
	StringBuffer sbRecvMsg = new StringBuffer();
	Logger log = Logger.getLogger("RengineJSP");

	Enumeration aaa = request.getParameterNames();
	String aa = "";
	while (aaa.hasMoreElements()) {
		aa = (String) aaa.nextElement();
		log.fatal("-------------XML init--->"+request.getParameter(aa).toString());
	}
		//取得遠端資料
		log.fatal("-------------XML init--->遠端USER主機"+request.getRemoteHost());
		log.fatal("-------------XML init--->遠端USER IP"+request.getRemoteAddr());
		//取得本端資料
		log.fatal("-------------XML init--->本端系統 IP"+request.getLocalAddr());
		log.fatal("-------------XML init--->本端系統主機名稱"+request.getLocalName());

	log.debug("DSC90900.jsp ==> 系統檢測:" + "程式執行開始");
	if (xmlLength > 0){		
		String strTempRecvMsg = "";
		strTempRecvMsg = request.getReader().readLine();
		while(strTempRecvMsg != null){
			sbRecvMsg.append(strTempRecvMsg.trim());
			strTempRecvMsg = request.getReader().readLine();
		}
	}
	String strRecvMsg = sbRecvMsg.toString();
	log.fatal("DSC90900.jsp ==> 收到的訊息:" + strRecvMsg);
	DS_C90900 theDS_C90900 = new DS_C90900();
	String strSendMsg = theDS_C90900.recvMsg(strRecvMsg);
	log.fatal("DSC90900.jsp ==> 送出的訊息:" + strSendMsg);
	PrintWriter gw = response.getWriter();
	gw.write(strSendMsg);
	gw.close();
%>