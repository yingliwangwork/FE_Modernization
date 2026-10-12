<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ page import="java.io.*" %>
<%@ page import="com.igsapp.wibc.dataobj.Context.*" %>
<%@ page import="com.igsapp.wibc.dataobj.html.HttpResponseContext" %>
<%@ page import="com.igsapp.wibc.dataobj.html.HttpTxContext" %>                         
<%@ page import="com.cathay.util.*" %>                     
<%
HttpResponseContext resp = new HttpResponseContext(request);//取出 trx addOutputData 中的值
HttpTxContext txCxt = new HttpTxContext(session);//取出自 trx putValue 中的值 
	Object FILE_DATA=resp.getOutputData("FILE_DATA");
	Object FILE_NAME=resp.getOutputData("FILE_NAME");
	FileDownLoadHelper.downLoad( response,FILE_NAME,FILE_DATA);
%>