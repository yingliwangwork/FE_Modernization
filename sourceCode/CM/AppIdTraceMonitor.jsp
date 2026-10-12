<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cathay.common.util.db.*"%>
<%@ page import="com.cathay.common.util.*"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="org.apache.commons.collections.buffer.CircularFifoBuffer"%>
<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="org.apache.log4j.Logger"%>
<%@ page import="java.sql.Timestamp"%>
<%@ page import="java.sql.Date"%>
<%
	List allThreadStatusList = AppIdTraceHelper.getAllThreadStatus();
	Collections.sort(allThreadStatusList);
%>
<HTML>
<HEAD>
<META http-equiv="Content-Type" content="text/html; charset=BIG5">
<META name="GENERATOR" content="IBM WebSphere Studio">
<TITLE>AppIdTraceMonitor.jsp</TITLE>
<link href="./../CM/css/cm.css" rel="stylesheet" type="text/css">
<script language='javaScript'>

function displayHistory(obj){
	var tr=document.getElementById(obj);
	if (tr.style.display=='none'){
		tr.style.display='block';
	}
	else{
		tr.style.display='none';
	}
}

</script>
</HEAD>
<BODY  bgcolor="#F0FBC6">
	<form name='form1' method='POST'>
	<tbody>
	<table width=100% border=0 align=center cellpadding="0" cellspacing="1" class="tbBox2">
	
	<tr class="tbBlue">
		<td align=left width='20%'>Thread Name</td>
		<td align=right width='15%'>交易經過時間 (ms)&nbsp;</td>
		<td align=center >交易 ID</td>
		<td align=center>URL</td>
		<td align=center width='15%'>最大連線數</td>
	</tr>
<%
	StringBuffer downloadCtx=new StringBuffer();
	boolean isOddLine=false;
	int index=0;
	long currentTime=System.currentTimeMillis() ;
	String printTime=new Timestamp(currentTime).toString();
			
	for (Iterator itr=allThreadStatusList.iterator() ;itr.hasNext() ;){
		AppIdTraceBo bo=(AppIdTraceBo) itr.next() ;
		if (bo.getFifoBuff().size() ==0){
			continue;//若無SQL History, 則不列出
		}
		
		String[] urlData=StringUtils.split( bo.getUrl() ,"/");
		String txName="";
		String txAction="";
		String txInfo="";
		if (urlData!=null && urlData.length >2){
			txName=urlData[urlData.length -2];
			txAction=urlData[urlData.length -1];
			txInfo=txName+" . "+txAction;
		}
		
		String subTrName="sub"+index;
		String[] infoData=getAppIdSqlCodeMsg(bo.getFifoBuff(),true);
		String sqlInfo="";
		String maxConn="";
		if (infoData!=null){
			if (infoData.length >0){
				sqlInfo=infoData[0];
			}
			if (infoData.length >1){
				maxConn=infoData[1];
			}
		}
		
		long startTime=0;
		if (StringUtils.isNotBlank( bo.getStartTime())){
			startTime=Long.parseLong(bo.getStartTime() );
		}

		long diffTime=currentTime - startTime ;
		boolean warnRecord=false;

		//差異時間大於 1 分鐘
		if (diffTime >= 60000){
			warnRecord=true;
		}
%>
		<tr class="<%=isOddLine ? "tbBlue3" : "tbYellow2"%>">
			<td align=left><a href='#' onclick="displayHistory('<%=subTrName%>'); return false;"><%= bo.getThreadId()%></a></td>
			<td align=right><%=warnRecord ? "<font color=RED>" : "" %><%=startTime >0 ? String.valueOf( diffTime ) : ""%><%=warnRecord ? "</font>" : "" %>&nbsp;</td>
			<td align=left>&nbsp;<font color=Burgundy><%=txInfo%></font></td>
			<td align=left>&nbsp;<%=bo.getUrl()%></td>
			<td align=center><%=maxConn%></td>
		</tr>
		<tr name='<%=subTrName%>' id='<%=subTrName%>' style='display: none'><td colspan=5 BGCOLOR="#4E8975"><%=sqlInfo%></td></tr>

<%

		//下載格式設定
		String[] downloadData=getAppIdSqlCodeMsg(bo.getFifoBuff(),false);
		if (downloadData!=null){
			if (downloadData.length >0){
				downloadCtx.append ("=====================================\n");			
				downloadCtx.append ("列印時間 = "+ printTime + "\n");
 				downloadCtx.append ("Thread Name = "+ bo.getThreadId() + "\n");
				downloadCtx.append ("交易經過時間 (ms) = "+ (startTime >0 ? String.valueOf( diffTime ) : "") + "\n");
				downloadCtx.append ("交易 ID = "+ txInfo+"\n");
				downloadCtx.append ("URL = "+ bo.getUrl() + "\n");
				downloadCtx.append ("最大連線數="+maxConn+"\n");
				downloadCtx.append ("\n"+downloadData[0]+"\n");
				downloadCtx.append ("=====================================\n");
			}
		}
		
		isOddLine=!isOddLine;
		index++;
	}
	System.out.println(printTime );
	
%>
	</table>
	<input type='button' value='下載' onclick='download();'>
	</tbody>
	<input type='hidden' name='FILE_DATA' value='<%=Base64.encodeString(downloadCtx.toString(),false)%>'>
	<input type='hidden' name='FILE_NAME' value='report.txt'>
	</form>
	
<script language='javaScript'>
function download(){
	var frm=document.form1;
	frm.action='./downloadPage.jsp';
	frm.submit();
}
</script>
</BODY>
</HTML>

<%!

	//傳入的 SQL 歷程以簡易的格式輸出
	private String[] getAppIdSqlCodeMsg(CircularFifoBuffer appIdSqlCodeBuf,boolean htmlCode) {
		StringBuffer sb = new StringBuffer("");
		Hashtable usedAppId = new Hashtable();
		int maxConn=0;
		for (Iterator itr2 = appIdSqlCodeBuf.iterator(); itr2.hasNext();) {
			String info = (String) itr2.next();

			//調整輸出格式
			String[] infoDeatail = StringUtils.split(info, ":");
			//前置識別符號
			String prefixString = "";
			String appId ="";
			String sqlCode="";
			
			if (infoDeatail != null){
				if (infoDeatail.length > 0) {
					appId = infoDeatail[0];
					//相同的 AppId 只會出現一次
					if (usedAppId.containsKey(appId) == false) {
						usedAppId.put(appId, String.valueOf(usedAppId.size() + 1));
					}
					prefixString = StringUtils.repeat("*", Integer.parseInt(usedAppId.get(appId)+""));
					
				}
				if (infoDeatail.length > 1) {
					sqlCode= infoDeatail[1];
				}
			}
			if (htmlCode){
				sb.append(
				"<strong><font color=RED>"+prefixString +"</font>&nbsp;"+
				"<font color=#FFFFFF>" + StringUtils.left( appId,appId.length() - 4) + "</font>"+
				"<font color=YELLOW>"+ sqlCode+"</font></strong><br>");
			}
			else{
				sb.append(prefixString + info+"\n");
			}
		}
		return new String[]{sb.toString(),String.valueOf(usedAppId.size())};
	}
%>