<%@page language="java" contentType="text/html; charset=Big5"%>
<%@page import="com.cathay.common.im.util.*"%>
<%@page import="com.cathay.common.bo.ReturnMessage"%>
<%@page import="java.util.*"%>

<%
try{
	
	Thread.currentThread().getContextClassLoader().loadClass("com.cathay.im.i18n.LocaleUtil");
	com.cathay.im.i18n.LocaleUtil.clearCache();
	System.out.println("**clearTextResource success");
	
}catch(Exception e){
	System.err.println("**ClearTextResource Failed");
}
%>