<%@ page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%>
<%@ page import="com.mps.util.ActiveXObject"%>
<%@ page import="com.mps.util.ActiveXObjectC2"%>                                                                                                                             
<%@ page import="com.igsapp.wibc.dataobj.html.HttpResponseContext" %>                                                                                                                                 
<%@ page import="com.cathay.common.util.STRING"%>                                                                                                                                                     
<%@ page import="com.cathay.common.service.ConfigManager" %>                                                                                                                                          
<%@ page import="java.util.*"%>
<%@ page import="com.cathay.common.service.authenticate.*" %>
<%@ page import="com.cathay.common.trx.UCData" %>

<%@ page import="com.cathay.common.service.ConfigManager"%>
<%@ page import="com.cathay.common.util.FieldOptionList" %>
<%@ page import="com.cathay.common.util.*"%>

<%@ taglib uri="/CXL" prefix="CXL" %>                                                                                                                                                                 
<CXL:csCommon trace="false" htmlBaseName="htmlBase"                                                                                                                                                   
                            cssBaseName="cssBase"                                                                                                                                                     
                            imageBaseName="imageBase"                                                                                                                                                 
                            dispatcherName="dispatcher" />  
                            
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<title>影像瀏覽器</title>

<%                                                                                                           

String SCAN_EXE = STRING.objToStrNoNull(FieldOptionList.getName("AV", "SCAN_EXE", "SCAN_EXE"));
String URL_EXE = FieldOptionList.getName("AV", "newEXE", FieldOptionList.getName("AV", "newEXE", "URL_SET"));

String ServerType = STRING.objToStrNoNull(ConfigManager.getProperty("ebaf.ServerType"));	
HttpResponseContext resp = new HttpResponseContext(request);                                                                                                                                          
String url = "";
if (request.getServerName().indexOf("twas") >= 0 || request.getServerName().indexOf("10.87.50.156") >= 0){
	url = "https://twas3.cathaylife.com.tw/AVWeb";	//測試
} else if (request.getServerName().indexOf("swas") >= 0){
	url = "https://swas3.cathaylife.com.tw/AVWeb";	//平測
} else {
	url = "https://was3.cathaylife.com.tw/AVWeb";	//正測
}                                                                                    
String  businessNo= (String)resp.getOutputData("businessNo")!=null?(String) resp.getOutputData("businessNo"):"";	//業務別                                                                            
String  UserCenter= (String)resp.getOutputData("UserCenter")!=null?(String) resp.getOutputData("UserCenter"):"";	//作業中心代號(可不填)                                                              
String  Userunit= (String)resp.getOutputData("Userunit")!=null?(String) resp.getOutputData("Userunit"):"";	//單位代號                                                                                
String  Userid= (String)resp.getOutputData("Userid")!=null?(String) resp.getOutputData("Userid"):"";	//使用者ID                                                                                      
String  Cname= (String)resp.getOutputData("Cname")!=null?(String) resp.getOutputData("Cname"):"";	//使用者姓名                                                                                        
String  Key= (String)resp.getOutputData("Key")!=null?(String) resp.getOutputData("Key"):"";	//受理編號                                                                                                
String  Mode= (String)resp.getOutputData("Mode")!=null?(String) resp.getOutputData("Mode"):"";                                                                                                        
String  doDisplay= (String)resp.getOutputData("doDisplay")!=null?(String) resp.getOutputData("doDisplay"):"";                                                                                         
String  setAppendType= (String)resp.getOutputData("setAppendType")!=null?(String) resp.getOutputData("setAppendType"):"";                                                                             
String  scanTitle= (String)resp.getOutputData("scanTitle")!=null?(String) resp.getOutputData("scanTitle"):"";	//                                                                                      
String  isComplementLogged= (String)resp.getOutputData("isComplementLogged")!=null?(String) resp.getOutputData("isComplementLogged"):"";	//                                                          
String  setOMRIgnored= (String)resp.getOutputData("setOMRIgnored")!=null?(String) resp.getOutputData("setOMRIgnored"):"";	//                                                                          
String  doCheckCoverDocno= (String)resp.getOutputData("doCheckCoverDocno")!=null?(String) resp.getOutputData("doCheckCoverDocno"):"";	//                                                              
String  isReplaceable= (String)resp.getOutputData("isReplaceable")!=null?(String) resp.getOutputData("isReplaceable"):"";	//                                                                          
String  isErasable= (String)resp.getOutputData("isErasable")!=null?(String) resp.getOutputData("isErasable"):"";	//                                                                                  
String  isClassifiable= (String)resp.getOutputData("isClassifiable")!=null?(String) resp.getOutputData("isClassifiable"):"";	//                                                                      
String  setCasenoCheckType= (String)resp.getOutputData("setCasenoCheckType")!=null?(String) resp.getOutputData("setCasenoCheckType"):"";	//                                                          
String  Encstring= (String)resp.getOutputData("Encstring")!=null?(String) resp.getOutputData("Encstring"):"";	//                                                                                      
                                                                                                                                                                                                      
String  AddPartURL="";                                                                                                                                                                                
                                                                                                                                                                                                      
if("ADDPART".equals((String)resp.getOutputData("Mode")) && !"".equals((String)resp.getOutputData("Key"))){                                                                                            
	  AddPartURL=request.getScheme() + "://" +request.getServerName() + ":" + request.getServerPort() + "/ATWeb/servlet/HttpDispatcher/ATA4_2000/join2002?APPLY_NO="+ (String)resp.getOutputData("Key");
}else{                                                                                                                                                                                                
	  AddPartURL= (String)resp.getOutputData("AddPartURL")!=null?(String) resp.getOutputData("AddPartURL"):"";	//                                                                                      
}                                                                                                                                                                                                     
String  AllFormShow= (String)resp.getOutputData("AllFormShow")!=null?(String) resp.getOutputData("AllFormShow"):"";	//                                                                                
String  Logtype= (String)resp.getOutputData("Logtype")!=null?(String) resp.getOutputData("Logtype"):"";	//                                                                                            
String  UNBPM= (String)resp.getOutputData("UNBPM")!=null?(String) resp.getOutputData("UNBPM"):"";	//                                                                                                  
String  DBWriteStyle= (String)resp.getOutputData("DBWriteStyle")!=null?(String) resp.getOutputData("DBWriteStyle"):"";	//                                                                            
String  Idcase= (String)resp.getOutputData("Idcase")!=null?(String) resp.getOutputData("Idcase"):"";	//                                                                                              
String  URLWrite= request.getHeader("Cookie");	//                                                                                                                                                    
String width="99%";                                                                                                                                                                                   
String height="99%";                                                                                                                                                                                  
String  LoadReplaceList= (String)resp.getOutputData("LoadReplaceList")!=null?(String) resp.getOutputData("LoadReplaceList"):""  ;	//                                                                  
                                                                                                                                                                                                      
String  usegroupdiv= (String)resp.getOutputData("usegroupdiv")!=null?(String) resp.getOutputData("usegroupdiv"):"";	//                                                                                
                                                                                                                                                                                                      
String  delType= (String)resp.getOutputData("delType")!=null?(String) resp.getOutputData("delType"):""  ;	//                                                                                          
String  upload_batch= (String)resp.getOutputData("upload_batch")!=null?(String) resp.getOutputData("upload_batch"):""  ;	//                                                                          
String  separatebycaseno= (String)resp.getOutputData("separatebycaseno")!=null?(String) resp.getOutputData("separatebycaseno"):""  ;	//                                                              


//============== 測點 ==============
if("M".equals(SCAN_EXE) ){//測點

	Map isSCAN_EXE_M = FieldOptionList.getFieldOptions("AV", "isSCAN_EXE_M");
	String ipAddress = STRING.objToStrNoNull(request.getHeader("OrigClientAddr"));
	if ("".equals(ipAddress)) {
		ipAddress = request.getRemoteAddr();
	}
	if (isSCAN_EXE_M.containsValue(ipAddress)||isSCAN_EXE_M.containsValue(Userunit)||isSCAN_EXE_M.containsValue(Userid)){
		SCAN_EXE = "Y";
	}else{
		SCAN_EXE = "N";
	}
}
//========================================

 %>


<SCRIPT>





	var win; 
	
	
	//----------EXE
function loadDoc() {

	var ServerType = "<%=ServerType%>";
	
		var jsonStr = '{\
		"scantitle":"<%=scanTitle%>",\
			"url":"<%=url%>",\
			"businessno":"<%=businessNo%>",\
			"userid":"<%=Userid%>",\
			"cname":"<%=Cname%>",\
			"key":"<%=Key%>",\
			"urlwrite":"<%=request.getHeader("Cookie")%>",\
			"mode":"<%=Mode%>",\
			"dodisplay":"<%=doDisplay%>",\
			"setappendtype":"<%=setAppendType%>",\
			"iscomplementlogged":"<%=isComplementLogged%>",\
			"setomrignored":"<%=setOMRIgnored%>",\
			"docheckcoverdocno":"<%=doCheckCoverDocno%>",\
			"isreplaceable":"<%=isReplaceable%>",\
			"iserasable":"<%=isErasable%>",\
			"isclassifiable":"<%=isClassifiable%>",\
			"setcasenochecktype":"<%=setCasenoCheckType%>",\
			"usercenter":"<%=UserCenter%>",\
			"userunit":"<%=Userunit%>",\
			"logtype":"<%=Logtype%>",\
			"loadreplacelist":"<%=LoadReplaceList%>",\
			"unbpm":"<%=UNBPM%>",\
			"dbwritestyle":"<%=DBWriteStyle%>",\
			"idcase":"<%=Idcase%>",\
			"encstring":"<%=Encstring%>",\
			"delType":"<%=delType%>",\
			"upload_batch":"<%=upload_batch%>",\
			"separatebycaseno":"<%=separatebycaseno%>",\
			"addparturl":"<%=AddPartURL%>",\
			"allformshow":"<%=AllFormShow%>",\
			"usegroupdiv":"<%=usegroupdiv%>"\
		}';

	  aaa( "<%=URL_EXE%>"+"/mps?appname=IMScan_New&ver=1.0.0.0&param="+encodeURI(jsonStr)
	       +"&apptitle="+encodeURI("["+ServerType+"]"+'<%=scanTitle%>')+"&closepre=Y&_="+(new Date().getTime()));
			
			
			
	
}


function aaa(url)
{
   var ifrmae = document.getElementById('iframe');
   if(ifrmae==null){
   	setTimeout("loadDoc();", 500);
   }else{
   	ifrmae.src = url;
   }
   
}
	
	
	function openWin(){
		var SCAN_EXE = "<%=SCAN_EXE%>";
		if("Y"==SCAN_EXE){
			loadDoc();
		}else{
			openWinOld();
		}
	}                                                                                                                                                                                           
	function openWinOld(){                                                                                                                                                                                 
		if(!win){                                                                                                                                                                                         
			var action = "<%=url%>/AV/B1/AVB1_0100/AVB10100_i.jsp?"+                                                                                                                                   
			"&businessNo=<%=businessNo%>"+                                                                                                                                                                  
			"&UserCenter=<%=UserCenter%>"+                                                                                                                                                                  
			"&Userunit=<%=Userunit%>"+                                                                                                                                                                      
			"&Userid=<%=Userid%>"+                                                                                                                                                                          
			"&Cname=<%=Cname%>"+                                                                                                                                                                            
			"&Key=<%=Key%>"+                                                                                                                                                                                
			"&Mode=<%=Mode%>"+                                                                                                                                                                              
			"&doDisplay=<%=doDisplay%>"+                                                                                                                                                                    
			"&setAppendType=<%=setAppendType%>"+                                                                                                                                                            
			"&scanTitle=<%=scanTitle%>"+                                                                                                                                                                    
			"&isComplementLogged=<%=isComplementLogged%>"+                                                                                                                                                  
			"&setOMRIgnored=<%=setOMRIgnored%>"+                                                                                                                                                            
			"&doCheckCoverDocno=<%=doCheckCoverDocno%>"+                                                                                                                                                    
			"&isReplaceable=<%=isReplaceable%>"+                                                                                                                                                            
			"&isErasable=<%=isErasable%>"+                                                                                                                                                                  
			"&isClassifiable=<%=isClassifiable%>"+                                                                                                                                                          
			"&setCasenoCheckType=<%=setCasenoCheckType%>"+                                                                                                                                                  
			"&Encstring=<%=Encstring%>"+                                                                                                                                                                    
			"&AllFormShow=<%=AllFormShow%>"+                                                                                                                                                                
			"&Logtype=<%=Logtype%>"+                                                                                                                                                                        
			"&UNBPM=<%=UNBPM%>"+                                                                                                                                                                            
			"&DBWriteStyle=<%=DBWriteStyle%>"+                                                                                                                                                              
			"&Idcase=<%=Idcase%>"+                                                                                                                                                                          
			"&LoadReplaceList=<%=LoadReplaceList%>"+                                                                                                                                                        
			"&usegroupdiv=<%=usegroupdiv%>"+                                                                                                                                                                
			"&delType=<%=delType%>"+                                                                                                                                                                        
			"&upload_batch=<%=upload_batch%>"+                                                                                                                                                              
			"&separatebycaseno=<%=separatebycaseno%>"+                                                                                                                                                      
			"&AddPartURL=<%=AddPartURL%>"+                                                                                                                                                                  
			"";                                                                                                                                                                                             
			win = window.open(action, '<%=businessNo%>'+'<%=Mode%>', "height=600, width=800, status=no, toolbar=no, menubar=no, location=no, resizable=yes");                                                                       
		}                                                                                                                                                                                                 
	}
</SCRIPT>


</head>
<body onLoad="openWin()">  
<iframe id="iframe" width="10%" height="10%" style="display: none;"  > </iframe>
</body>
</html>