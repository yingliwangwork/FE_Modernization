<%@ page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%>
<%@ page import="com.mps.util.ActiveXObject"%>
<%@ page import="com.mps.util.ActiveXObjectC2"%>
<%@ page import="java.util.*"%>
<%@ page import="com.cathay.common.service.authenticate.*" %>
<%@ page import="com.cathay.common.trx.UCData" %>


<%@ page import="com.cathay.common.service.ConfigManager"%>
<%@ page import="com.cathay.common.util.FieldOptionList" %>
<%@ page import="com.cathay.common.util.*"%>
<%@ page import="com.cathay.av.p0.module.AV_P0Z001"%>
<% 
String IS_VIEW_EXE = STRING.objToStrNoNull(FieldOptionList.getName("AV", "IS_VIEW_EXE", "IS_VIEW_EXE"));//是否使用新的瀏覽EXE
String IS_IFRAM = STRING.objToStrNoNull(FieldOptionList.getName("AV", "IS_VIEW_EXE", "IS_VIEW_EXE_IFRAM"));

com.igsapp.wibc.dataobj.html.HttpSessionContext sessionCtx = new com.igsapp.wibc.dataobj.html.HttpSessionContext(session);
UserObject uObj = (UserObject) sessionCtx.getValue(UCData.USER_OBJECT);


//============== 測點 ==============
if("M".equals(IS_VIEW_EXE) ){//測點

	Map IS_VIEW_EXE_M = FieldOptionList.getFieldOptions("AV", "IS_VIEW_EXE_M");//測點的清單
	String ipAddress = STRING.objToStrNoNull(request.getHeader("OrigClientAddr"));
	if ("".equals(ipAddress)) {
		ipAddress = request.getRemoteAddr();
	}
	if (IS_VIEW_EXE_M.containsValue(ipAddress)//使用者電腦ip
	   ||IS_VIEW_EXE_M.containsValue(uObj.getDivNo())//單位代號
	   ||IS_VIEW_EXE_M.containsValue(uObj.getEmpID())){//使用者ID
		IS_VIEW_EXE = "Y";
	}else{
		IS_VIEW_EXE = "N";
	}
}
//======================================== 



String apply_id=request.getParameter("APPLY_ID");
//String ServerName = request.getServerName();
//20220110 配合壽程科優化影像網路切換，改呼叫壽程模組取得URL
String unit = uObj.getDivNo();
String url = request.getScheme() + "://" +request.getServerName() + ":" + request.getServerPort() + "/AVWeb";
url = new AV_P0Z001().getImgUrl(unit,url);
/*if ("T".equals(ServerType) || StringUtils.isBlank(ServerType)) //測試、本機環境
{
	url = "https://twas3.cathaylife.com.tw/AVWeb";
} else if (ServerName.indexOf("swas") >= 0)
{
	url = "https://swas3.cathaylife.com.tw/AVWeb";
} else {
	url = "https://was3.cathaylife.com.tw/AVWeb";		//能抓到servlet的url
}*/

ActiveXObjectC2 obj = new ActiveXObjectC2("IMView.cab", url);
String draftyn = (String) request.getParameter("draftyn")!=null?(String) request.getParameter("draftyn"):"N";
//文件formcode，Mode:FieldView會用到
String DTAV0011_FORMCODE = (String) request.getParameter("DTAV0011_FORMCODE")!=null?(String) request.getParameter("DTAV0011_FORMCODE"):"";
//欄位名稱fieldName，Mode:FieldView會用到
String fieldName = request.getParameter("fieldName");
obj.setParam("type","view");
if("APPLY_IMAGE".equals(fieldName) || "CHECKDATA_IMAGE".equals(fieldName) ) {//由客戶資料照會表進來,只顯示受理檢核表部分欄位項目
	obj.setParam("Mode", ActiveXObject.IM_OBJECT_VIEWMODE_FIELD);	//檢視影像時要用的模式//各畫面欄位名稱
} else {
	obj.setParam("Mode", ActiveXObject.IM_OBJECT_VIEWMODE_VIEW);	//檢視影像時要用的模式
}
obj.setParam("Business","DP");
obj.setParam("center",uObj.getDivNo());
obj.setParam("Userunit", uObj.getDivNo());
obj.setParam("UserID", uObj.getEmpID());
obj.setParam("CName", uObj.getEmpName());
obj.setParam("width", "100%");
obj.setParam("height", "100%");
obj.setParam("key", apply_id);
obj.setParam("draftyn", draftyn);

if(!"Y".equals(IS_VIEW_EXE) ){//測點..非Y，舊程式
	out.println(obj);
}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<SCRIPT language="JavaScript" type="text/JavaScript">

function loadDoc() {

	var IS_VIEW_EXE = "<%=IS_VIEW_EXE%>";
	var IS_IFRAM="<%=IS_IFRAM%>";
	if( "Y"==IS_VIEW_EXE  ){
	  var xhttp = new XMLHttpRequest();
	  xhttp.onreadystatechange = function() {
	    if (this.readyState == 4 && this.status == 200) {
	      document.getElementById("demo").innerHTML = this.responseText;
	    }
	  };
	var fieldName = "<%=fieldName%>";
	  var str = '{';
		if("APPLY_IMAGE"==fieldName || "CHECKDATA_IMAGE"==fieldName ) {
			str=str+'"Mode":"FieldView",';
		} else {
			str=str+'"Mode":"View",';
		}
	    str=str+'"scantitle":"案件瀏覽",\
	    "URL":"<%=url%>",\
		"Business":"DP",\
	    "UserID":"<%=uObj.getEmpID()%>",\
	    "CName":"<%=uObj.getEmpName()%>",\
		"Key":"<%=apply_id%>",\
	    "EncString":"<%=apply_id%>",\
		"UserCenter":"<%=uObj.getDivNo()%>",\
		"UserUnit":"<%=uObj.getDivNo()%>",\
		"FormCode":"<%=DTAV0011_FORMCODE%>",\
		"Field":"<%=fieldName%>",\
		"ViewTitle":"案件瀏覽",\
		"DraftYN":"<%=draftyn%>",\
	    }';
	  var jsonstr = encodeURI(str);
	  
	  var URLexe="https://localhost:9002/mps?appname=IMView&ver=1.0.0.0&&param="+jsonstr			  
			  +"&apptitle="+encodeURI("瀏覽"+'<%=apply_id%>')
			  +"&closepre=Y&_="
			  +(new Date().getTime());
	  
	  if("Y"==IS_IFRAM){
	        var ifrmae = document.getElementById('iframe');
	   		ifrmae.src = URLexe;
	  }else{
		  var xhttp = new XMLHttpRequest();
		  xhttp.onreadystatechange = function() {
		    if (this.readyState == 4 && this.status == 200) {
	  			window.close();
		    }
		  };
		  
		  xhttp.open("GET", URLexe,true);
	  	  xhttp.send();
	  }
	  
	}else{
		document.getElementById('obj1').Field ='<%=request.getParameter("fieldName")%>';
	}
}

<!--
/*
function setParentWindow() {
	if( window.opener ){
		if(!window.opener.caseWin){
			window.opener.caseWin = window;
		}
	}
	setTimeout("setParentWindow()", 1000);		
}
*/
-->
</SCRIPT>
<title>影像瀏覽器</title>

</head>
<!--<body topmargin="0" leftmargin="0" onload="document.getElementById('obj1').Field ='<%=request.getParameter("fieldName")%>';setParentWindow();">-->
<body topmargin="0" leftmargin="0" onload="loadDoc();">
<%
/*String apply_id=request.getParameter("APPLY_ID");
//String noteedityn = (String) request.getParameter("noteedityn")!=null?(String) request.getParameter("noteedityn"):"N";
//String noteviewyn = (String) request.getParameter("noteviewyn")!=null?(String) request.getParameter("noteviewyn"):"N";
String draftyn = (String) request.getParameter("draftyn")!=null?(String) request.getParameter("draftyn"):"N";
String fieldName = request.getParameter("fieldName");
HashMap parameters = new HashMap();
//Log.error("showImage.jsp   request.getServerName()==>>>"+request.getServerName());
parameters.put("type", ActiveXObject.IM_OBJECT_TYPE_VIEW);		//要掃描或要檢視影像
if (request.getServerName().indexOf("twas") >= 0 || request.getServerName().indexOf("10.87.50.156") >= 0)
{
	parameters.put("url", "https://twas3.cathaylife.com.tw/AVWeb");
} else if (request.getServerName().indexOf("swas") >= 0)
{
	parameters.put("url", "https://swas3.cathaylife.com.tw/AVWeb");
} else {
	parameters.put("url", "https://was3.cathaylife.com.tw/AVWeb");		//能抓到servlet的url
}

com.igsapp.wibc.dataobj.html.HttpSessionContext sessionCtx = new com.igsapp.wibc.dataobj.html.HttpSessionContext(session);
UserObject uObj = (UserObject) sessionCtx.getValue(UCData.USER_OBJECT);

parameters.put("business", "DP");			//業務別
parameters.put("center", uObj.getDivNo());		//作業中心代號(可不填)
parameters.put("unit", uObj.getDivNo());			//單位代號
parameters.put("userid", uObj.getEmpID());		//使用者ID
parameters.put("cname", uObj.getEmpName());		//使用者姓名
parameters.put("width", "100%");		//影像元件的寬
parameters.put("height", "100%");		//影像元件的高
parameters.put("key", apply_id);
//parameters.put("noteedityn", noteedityn);		//是否編輯便條紙
//parameters.put("noteviewyn", noteviewyn);		//是否顯示便條紙
parameters.put("draftyn", draftyn);			//是否可使用工作底稿
if("APPLY_IMAGE".equals(fieldName) || "CHECKDATA_IMAGE".equals(fieldName) ) {//由客戶資料照會表進來,只顯示受理檢核表部分欄位項目
	parameters.put("viewMode", ActiveXObject.IM_OBJECT_VIEWMODE_FIELD);	//檢視影像時要用的模式//各畫面欄位名稱
} else {
	parameters.put("viewMode", ActiveXObject.IM_OBJECT_VIEWMODE_VIEW);	//檢視影像時要用的模式
}
parameters.put("request", request);

out.println(new ActiveXObject(parameters));*/





%>


<iframe id="iframe" width="10%" height="10%" style="display: none;"> </iframe>
<p id="demo"></p> 
</body>
</html>