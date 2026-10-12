<!DOCTYPE html>
<html>
<head> 
<meta charset="Big5">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<title>國泰金融集團 [SYSTEM TOP]</title>

<%-- ==================================
           JAVA CODE  start
 ================================== --%>
<%@ page contentType="text/html; charset=Big5" %>
<%@ page import="java.lang.StringBuffer" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cathay.common.service.authenticate.*" %>
<%@ page import="com.cathay.common.service.login.LoginInfoHandler" %> 
<%@ page import="com.cathay.common.util.LoginUtil" %>
<%@ include file="/html/CM/header.jsp"%>
<%

	Map systemInfo = LoginInfoHandler.getSystemInfo(request);

	// 取得 R6 HostName
	String R6hostname;
	try {
		ResourceBundle res1 = ResourceBundle.getBundle("hostname");
		if (res1 != null ) {
			R6hostname=res1.getString("hostname"); // 取值
		}else{
			R6hostname="";
		}
	} catch (Exception e) {
		R6hostname="localhost" ;
		System.out.println("===sys_top.jsp hostnameException ===>" + e.getMessage());
	}

	if(java.io.File.separator.equals("/")){
		imageBase = "/CXLDocs/images";
	}

	String IMAGES_SKEL = imageBase + "/CM/skeletons";

	// ============= 修正 XSS 資安弱點 =============
	String strEmpName = null;
	String strOpUnitName = null;
	String originalID = null;
	String originalName = null;
	String authType = request.getParameter("authType");
	String clientIp = "";
	
	boolean isSwitch = false;

	UserObject userObj;
	if(session != null){
		userObj = (UserObject)session.getAttribute("$Data.$coreSys$UserObject");
			if(userObj!=null){
			strOpUnitName = userObj.getOpUnitShortName();
		    strEmpName = userObj.getEmpName();
		    authType = userObj.getAuthType();
		    originalID = userObj.getOriginUserID();
		    if(originalID!=null && originalID.length()>0){
				isSwitch = true;
				try{
		        	Class aClass = Class.forName("com.cathay.fm.component.FM_A0Z001");
					java.lang.reflect.Method aMethod = aClass.getMethod("getEmpName", new Class[]{String.class});
					originalName = (String)aMethod.invoke(aClass.newInstance(), new String[]{originalID});
		        } catch (Exception e) {
		            e.printStackTrace();
		        }
		    }
			clientIp = userObj.getClientIP();
		}
	} else {
		userObj = null;
	}

	if (strEmpName == null) {
		strEmpName = "   "; 
	}
	if (strOpUnitName == null) {
		strOpUnitName = "             ";
	}

	// ============================================

	// ========== 投資平台取得系統日初日 ==========
	// 系統代號
	String sysCode = (String)systemInfo.get("sysCode");


    StringBuffer sbf = new StringBuffer();

	// properties所設定需顯示取得系統日初日期之子系統
	String getSysNos = com.cathay.common.service.ConfigManager.getProperty("sysTopJspShowMchdDateBySysNo");

    if (sysCode != null && getSysNos != null) {

        boolean isShowMchd =false;

        String[] sysNos = getSysNos.split(",");
        for (int i = 0; i < sysNos.length; i++) {
            String sysNo = sysNos[i];
            if (sysNo.equals(sysCode)) {
                isShowMchd = true;
                break;
            }
        }

    	if(isShowMchd){
	        try {
	        
				String uid = (String) systemInfo.get("uid");

	            String useSysCode = sysCode;
	            if (uid != null && !"".equals(uid)) {
	            	Map<String, String> menuSettingMap = new com.cathay.common.service.authenticate.MenuTreeHandler().getMainMenuFilterSettingByUID(sysCode, uid);
	            	if(menuSettingMap != null){
	            		useSysCode = menuSettingMap.get("ALIAS_ID");
	            	}
	            }
	            
	            String callModule;
	            Class[] inputClasses;
	            String[] inputValues;
	            if (sysCode.startsWith("J")) {
	                callModule = "com.cathay.jz.g0.module.JZ_G00100";
	                inputClasses = new Class[]{String.class, String.class};
	                 inputValues = new String[]{useSysCode, userObj==null?null:userObj.getDivNo()};
				} else {
	                callModule = "com.cathay.rz.g0.module.RZ_G00100";
	                inputClasses = new Class[]{String.class};
	                inputValues = new String[]{useSysCode};
				}

	            Class aClass = Class.forName(callModule);
	            java.lang.reflect.Method aMethod = aClass.getMethod("getMchdSystemDate", inputClasses);
				String mchdSystemDate = (String)aMethod.invoke(aClass.newInstance(), inputValues);
	            sbf.append(mchdSystemDate);
	            sbf.append(" 已系統日初");
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
		    if (sbf.length() == 0) {
		        sbf.append("無法取得系統日初");
		    }
    	}
    }

    String showMchdMsg = sbf.toString();
    sbf.setLength(0);

	// ============================================

    String[] hostTypeImage = { "", "logo_stag.gif", "logo_test.gif", "logo_deve.gif" };

    int intHostType = LoginUtil.getHostType();

	// 是否為正式環境之HostType
    boolean isProdByHostType = LoginUtil.isProdByHostType(intHostType);

	boolean isBM = sysCode.startsWith("BM");

	String platformDispatcher = null;
	String loginPlatform = null;

	Map eBAF_loginPlatformInfo = LoginInfoHandler.getPlatformInfo(request);

	if(eBAF_loginPlatformInfo!=null){
		platformDispatcher = (String)eBAF_loginPlatformInfo.get("platformDispatcher");
        loginPlatform = (String)eBAF_loginPlatformInfo.get("loginPlatform");
	}

	if(platformDispatcher==null || "".equals(platformDispatcher)){
		if(isBM){
			platformDispatcher = "/CXBWeb/servlet/HttpDispatcher";
		}else{
			String currPlatform = com.cathay.common.service.ConfigManager.getProperty("com.cathay.zz.trx.SysLogin.currPlatform");
			if (currPlatform == null || "".equals(currPlatform)) {
				platformDispatcher = "/CXLWeb/servlet/HttpDispatcher";
			} else {
				sbf.append("/");
				if ("B2C".equals(currPlatform)) {
					sbf.append("CXBWeb");
				} else if ("B2E".equals(currPlatform)) {
					sbf.append("CXPWeb");
				} else if ("IM".equals(currPlatform)) {
					sbf.append("IMWeb");
				} else {
					sbf.append("CXLWeb");
				}
				sbf.append("/servlet/HttpDispatcher");
				platformDispatcher = sbf.toString();
				sbf.setLength(0);
			}
		}
	}

	if(loginPlatform==null || "".equals(loginPlatform)){
		if(isBM){
			loginPlatform = sysCode;
		}
	}

	String showGoBack2Main;
	if(isBM && userObj!=null && !userObj.isValidRole("RLZZA02")){
		showGoBack2Main = "N";
	}else{
		showGoBack2Main = "Y";
	}

	try {
		List top_logo_bg_cathayFinanicalList = com.cathay.common.util.FieldOptionList.getAllOption("ZZ", "sys_top.jsp.group.top_logo_bg2");
		pageContext.setAttribute("top_logo_bg_cathayFinanicalList", top_logo_bg_cathayFinanicalList);
	} catch (Exception e) {
	}

	// 圖檔路徑
	pageContext.setAttribute("IMAGES_SKEL", IMAGES_SKEL);
	// 作業單位
	pageContext.setAttribute("strOpUnitName", strOpUnitName);
	// 使用者
	pageContext.setAttribute("strEmpName", strEmpName);
	// 主機名稱
	pageContext.setAttribute("R6hostname", R6hostname);
	// 登入網路類別
	pageContext.setAttribute("authType", authType);
	// 是否為正式環境
	pageContext.setAttribute("isProdByHostType", new Boolean(isProdByHostType));
	// 環境圖檔logo
	pageContext.setAttribute("logoImageName", hostTypeImage[intHostType]);
	// 是否顯示切換原登入者
	pageContext.setAttribute("isSwitch", new Boolean(isSwitch));
	// 原登入者
	pageContext.setAttribute("originalName", originalName);
	// 系統日初
	pageContext.setAttribute("showMchdMsg", showMchdMsg);
	// 登入平台
	pageContext.setAttribute("loginPlatform", loginPlatform);
	// 登入平台的 Dispatcher
	pageContext.setAttribute("platformDispatcher", platformDispatcher);
	// 使用者ip
	pageContext.setAttribute("clientIp", clientIp);
	// 子系統代碼
	pageContext.setAttribute("sysCode", sysCode);
	// 是否顯示回到主選單頁籤
	pageContext.setAttribute("showGoBack2Main", showGoBack2Main);

	// 時間處理
	pageContext.setAttribute("sysTime", new Date().getTime());
	
	// userObj
	pageContext.setAttribute("eBAF_UserObject_Flag", request.getParameter("eBAF_UserObject_Flag"));
	// 加密後之登入平台相關資訊
	pageContext.setAttribute("eBAF_loginPlatformInfo", request.getParameter("eBAF_loginPlatformInfo"));
	
%>

<%-- ==================================
           JAVA CODE  end
 ================================== --%>

<style>
*{
	margin:0px;
	padding:0px;
	cursor: default;
}

html { overflow: hidden;}

body{
	margin:0px !important;
	padding:0px !important;
	height: 50px !important;
	font-family: 微軟正黑體, 新細明體, Arial Unicode MS;
	overflow:hidden;
	background-color: #C6E49C;
	background-repeat: repeat-x;
	z-index: 0;
}

body.cathayLife{
	background-image: url('${IMAGES_SKEL}/top_logo_bg.jpg');
	background-color: #CDE29F;
}

body.CathayFinanical{
	background-image: url('${IMAGES_SKEL}/top_logo_bg2.jpg');
	background-color: #FFCC00;
}

ul{
	margin:0px;
	padding:0px;
	position: absolute;
	list-style: none;
}
li{
	float:left;
	display:block;
	vertical-align:middle;
}


ul#main_logos{
	top:0px;
	left:0px;
	
}
ul#main_logos li{
	margin-right: 5px;
}

li#logo{
	height: 50px;
	width: 242px;
	background-image: url('${imageBase}/CM/login/top_logo.gif');
	cursor:pointer;
}

li#platform_logo{
	height: 50px;
	width: 181px;
	background-image: url('${IMAGES_SKEL}/${logoImageName}');
}

li#messageArea{
	margin-top: 15px;
	color:#F00;
	font-weight:bold;
	font-size: 15px;
}

ul#userInfo{
	font-size: 12px;
	right:10px;
	top:2px;
}

ul#userInfo li.user_data{
	color:#009;
	margin-right: 10px;
}

ul#menuBar {
	color: #FFF;
	font-size: 15px;
	font-weight: bold;
	text-align:center;
	text-shadow: 1px 1px 0px #000;

	right:0px;
	top:12px;
}
ul#menuBar li{
	width:105px;
	height:38px;
	line-height:31px;
	text-align:center;
	background:url('${IMAGES_SKEL}/btn_shorter.png') left top no-repeat;
	cursor:pointer;
	-overflow:hidden;
}

ul#menuBar li.highlight{
	background-image:url('${IMAGES_SKEL}/btn_shorter2.png');
}

ul#menuBar li.style_b{
	background-position:  left -180px;
}

ul#menuBar li.firstChild{
	background-position:  left -45px;
}

ul#menuBar a {
	position:relative;
	z-index:20;
	color: #FFF;
	text-shadow: #E5F09B;
	display:block;
	width:130px;
	height:38px;
	line-height:50px;
	text-align: center;
	text-decoration: none;
	cursor:pointer;
}

ul#menuBar a:link , ul.tabmenu  a:visited , ul.tabmenu  a:active {
	color: #FFF;
}

ul#menuBar a:hover{
	color: #004B2D;	
	text-shadow: 1px 1px 0px #FFF;
	padding-left: 5px;
	line-height:40px;
	background:url('${IMAGES_SKEL}/btn_shorter.png') left -90px no-repeat;
	z-index: 100 !important;
}

ul#menuBar li.highlight a:hover{
	background-image:url('${IMAGES_SKEL}/btn_shorter2.png');
}

ul#menuBar li.lastChild a:hover{
	background-position: left -135px;
}

ul#menuBar li.style_e a:hover{
	background-position:  left -225px;
}

ul#menuBar li.timer{
	width:150px;
	line-height: 16px;
	font-weight:100;
	font-size:12px;
	overflow: hidden;
	vertical-align:bottom;
	cursor: default;
}

li.timer #dateText{
	text-align:right;
	padding-right: 5px;
	margin-top:-2px;
}

li.timer #timeText{
	text-align:right;
	font-size:13px;
	margin-top:9px;
	font-weight:bold;
	padding-right: 20px;
}
</style>

<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript">
<!--
	var matchSystem = "${sysCode}";

	//--------------------------------------------
	//  時鐘控制項
	//--------------------------------------------

	//var dateFormat = new SimpleDateFormat( "yyyy-MM-dd EEEE" , SimpleDateFormat.TW );
	var weekDay = new Array("日","一","二","三","四","五","六");
	//處理系統與本機時間差
	var timeDiff = ${sysTime} -  (new Date().getTime())
	
	function Time_init(){
		//開始顯示時間
		show_time();
		setInterval("show_time()", 1000);
	}
	
	//時間更新
	function show_time(){
		var sysTime = new Date( new Date().getTime() + timeDiff);
		var sysDay = sysTime.getDay();
		var sysDate = sysTime.getFullYear()+" / "+(sysTime.getMonth()*1+1*1)+" / "+sysTime.getDate()+" 星期"+weekDay[sysDay];
		var strHours = sysTime.getHours();
		if (strHours<10) strHours = "0"+strHours;
		var strMinutes = sysTime.getMinutes();
		if (strMinutes<10) strMinutes = "0"+strMinutes;
		var strSeconds = sysTime.getSeconds();
		if (strSeconds<10) strSeconds = "0"+strSeconds;
		dateText.innerHTML = sysDate;
		timeText.innerHTML = strHours+"："+strMinutes+"："+strSeconds;
	}
	
	//--------------------------------------------
	//  停止事件
	//--------------------------------------------
	function setEventObserve( elem , eventName , func){
		if(elem.removeEventListener) {						//DOM2接口 with bubble
			elem.addEventListener(eventName, func, false);  
		} else if(elem.detachEvent) {					//IE DOM2接口  with bubble
			elem.attachEvent('on'+eventName, func);  
		} else {											//DOM0接口 without bubble
			if( window.Prototype){
				Event.observe(elem, eventName, func);
			}else{
				elem['on'+eventName]=func; 
			}
		}
	}
	function stopEventPop(e){
		 if ( e && e.preventDefault ) //(W3C) 
		 e.preventDefault(); 
		 else //for IE
		 window.event.returnValue = false; 
		 return false;
	 }

	//--------------------------------------------
	//  各項按鈕控制項
	//--------------------------------------------
	<%-- 非正式環境顯示回歸資料再生及問題單選項--%>
	<c:if test="${!isProdByHostType}">
	var recoverEvents = new function(){
		return {
			dataMaker: function(){
				var frm = document.getElementById('forwardForm');
					frm.submit();
			}
		};
	};

	var quest_Events = {
		window_handle:null,
		//建立發送連結 &　發送資訊
		window_open:function (url_options){
			
			var url = "forwardQuest.jsp?";
			if(url_options){
				for(var key in url_options)	{
					url = url + key + "=" + url_options[key] + "&";
				}
			}
			
			quest_Events.window_handle && quest_Events.window_handle.close && quest_Events.window_handle.close();
			
			quest_Events.window_handle = window.open(url.substring(0,url.length-1), 'QuestPage', 'width=1000,height=600,scrollbars=yes,resizable=yes,titlebar=no');
		},
		
		//查詢問題單
		doList:function(){
			quest_Events.window_open({'TYPE': 'QUERY'});
		},
		//開立問題單
		doOpen:function(){
			quest_Events.window_open({'TYPE': 'CREATE'});
		}
	}
	</c:if>

	<%-- AT 系統 待辦事項連結 --%>
	<c:if test="${sysCode eq 'AT'}">
	var AT_events = {

		canLinkTo : true,

		doLinkTo : function(){
			if(!AT_events.canLinkTo){
				return;
			}

			AT_events.canLinkTo=false;

			AT_events.getMainFrame("${dispatcher}/ATB0_1400/prompt?newTxRequest=true&syscode=AT&subcode=ATB0");
			
			setTimeout(function(){ AT_events.canLinkTo=true; },10000);// 10 秒後才可再次執行
		},

		getMainFrame: function( url ){
			var bottomFrame = ( top && top.frames && top.frames['leftFrame'] ) || ( parent && parent.frames && parent.frames['leftFrame'] );
			
			var targetIFrame = bottomFrame && ( (bottomFrame.document && bottomFrame.document.getElementById("mainFrame")) || bottomFrame.frames['mainFrame'] || top.frames['mainFrame'] || parent.frames['mainFrame']);
			
			if(url){
				targetIFrame.setAttribute("src",url);
			}else{
				return targetIFrame;
			}
		}
	};
	</c:if>
	
	//--------------------------------------------
	//  儲存popupWin物件，以免開啟過多彈跳視窗... 所有的popup都會用同一個子視窗開啟
	//--------------------------------------------
	var my_window_handle;
	var my_window_handle2;
	/**
	 *  @public
	 *  @class 開啟影像畫面。
	 *  @param applyNo : 受理編號。
	 *  @param isSameByAssignedEmpId : 是否為相同的人員 ID。
	 *  @param focusFormCode : focus 影像代碼。
	 *  @param isForceOpenMedicalTreatmentImg : 是否開啟體檢影像。
	 **/
	function openImg(applyNo, isSameByAssignedEmpId, focusFormCode, isForceOpenMedicalTreatmentImg){
		<c:choose>
		<c:when test="${sysCode eq 'AA'}">var linkURL = "${dispatcher}/AAZ3_0100/prompt?APLY_NO="+applyNo;
		windowName = "理賠影像";</c:when>
		<c:when test="${sysCode eq 'AT'}">var linkURL = "${dispatcher}/ATV0_0100/prompt?APPLY_NO="+applyNo;
		var windowName = "新契約影像";</c:when>
		<c:otherwise>return;</c:otherwise>
		</c:choose>
		linkURL += "&isSameByAssignedEmpId="+isSameByAssignedEmpId;
	
		if(focusFormCode){
			linkURL += '&FocusFormCode='+focusFormCode;
		}
	
		if(isForceOpenMedicalTreatmentImg){
			linkURL += '&isForceOpenMedicalTreatmentImg='+isForceOpenMedicalTreatmentImg;
		}
	
		var leftPosition = 0;
		var attribute = "status=no,toolbar=no,menubar=no,resizable=no,width="+screen.availWidth+",height="+screen.availHeight+",top=0,left="+leftPosition;
	
		if (my_window_handle && typeof my_window_handle == "object") {
			my_window_handle.close();
		}
	
		my_window_handle = window.open(linkURL,windowName,attribute,true);
	}
	
	/**
	 *  @public
	 *  @class 關閉影像畫面。
	 **/
	function closeImg(){
		my_window_handle = null;
	}
	
	/**
	 *  @public
	 *  @class 調閱影像。
	 *  @param inputOptions(String) : 案件編號。
	 *         inputOptions(Map) : 
	 *         inputOptions.caseNo(String) : 案件編號。
	 *         inputOptions.sysCode(String) : 子系統代碼。
	 *         inputOptions.windowName(String) : 視窗名稱。
	 *         inputOptions.linkURL(String) : 連結網址。
	 *  @param sysCode : 子系統代碼，預設為 AB。
	 **/
	function openImg2(inputOptions, sysCode){
	
		var optionsType = typeof inputOptions;
	
		var caseNo;
		var linkURL;
		var windowName;
	
		if(optionsType=='string'||optionsType=='number'){
			caseNo = inputOptions;
		}else{
			caseNo = inputOptions['caseNo'];
			sysCode = inputOptions['sysCode'];
			windowName = inputOptions['windowName'];
			linkURL = inputOptions['linkURL'];
		}
	
		sysCode = sysCode || 'AB';
		windowName = windowName || 'ATS00902_prt';

		if(!linkURL){
			<c:choose>
			<c:when test="${sysCode eq 'AT'}">linkURL = "${htmlBase}/AT/S0/ATS0_0902/ATS00902_prt.jsp?SYS_CODE="+sysCode+"&CASE_NO="+caseNo; </c:when>
			<c:otherwise>linkURL = "${htmlBase}/AT/S0/ATS0_0902/ATS00902_prt.jsp?SYS_CODE="+sysCode+"&CASE_NO="+caseNo;</c:otherwise>
			</c:choose>
		}
	
		var leftPosition = 0;
		var attribute = "status=no,toolbar=no,menubar=no,resizable=no,width="+screen.availWidth+",height="+screen.availHeight+",top=0,left="+leftPosition;
		if (my_window_handle2 && typeof my_window_handle2 == "object") {
			my_window_handle2.close();
		}
		my_window_handle2 = window.open(linkURL,windowName,attribute,true);
	}
	
-->
</script>

</head>
<body>
	<%-- 開頭logo 及環境圖示 --%>
	<ul id="main_logos">
		<%-- 主系統logo --%>
		<li id="logo" onclick="parent.location.href='<c:out value="${platformDispatcher}"/>/login/loginFromSys?newTxRequest=true&eBAF_loginPlatformInfo=<c:out value="${eBAF_loginPlatformInfo}"/>'; " title="主選單"></li>
		
		<%-- 系統平台 --%>
		<c:if test="${!isProdByHostType && not empty logoImageName}"><li id="platform_logo"></li></c:if>
		
		<li id="messageArea">${showMchdMsg}</li>
    </ul>
    <%-- !!!!!!!!!!!!!!!!!選單修改部分!!!!!!!!!!!!!!!!!!! --%>
    <ul id="menuBar">
	
	  <%-- 非正式環境顯示問題單選項--%>
      <c:if test="${!isProdByHostType}">
      <li highlight="Y"><a href="#" onClick="quest_Events.doList()" >查詢問題單</a></li>
      <li highlight="Y"><a href="#" onClick="quest_Events.doOpen()" >開立問題單</a></li>
      <li highlight="Y"><a href="#" onClick="recoverEvents.dataMaker()" >回歸資料再生</a></li>
      </c:if>
	  
	  <%-- AT 系統 待辦事項連結 --%>
      <c:if test="${sysCode eq 'AT'}">
	  <li highlight="Y"><a target="_self" href="#" onclick="AT_events.doLinkTo();">待辦事項</a></li>	
      </c:if>
	  
      <%-- 在主選單因為不需要有回主選單 --%>
      <c:if test="${showGoBack2Main ne 'N'}">
      <li highlight="N"><a target="_top" href="<c:out value="${platformDispatcher}"/>/login/loginFromSys?newTxRequest=true&eBAF_loginPlatformInfo=<c:out value="${eBAF_loginPlatformInfo}"/>" >主選單</a></li>
      </c:if>
      
      <%-- 登出 --%>
      <li highlight="N"><a target="_top" href="<c:out value="${platformDispatcher}"/>/logout/logout?newTxRequest=true&eBAF_loginPlatformInfo=<c:out value="${eBAF_loginPlatformInfo}"/>">登出</a></li>
	  
	  <%-- 時間顯示區--%>
      <li highlight="N" class="timer"><div id="timeText">00:00:00</div><div id="dateText">00/00/00 星期五</div></li>
      
    </ul>
    <%-- !!!!!!!!!!!!!!!!!選單修改部分!!!!!!!!!!!!!!!!!!! [END]--%>
	
	<%-- 使用者資訊 --%>
    <ul id="userInfo">
    	<li>使用者：</li><li class="user_data">${strEmpName}</li>
        <li>作業單位：</li><li class="user_data">${strOpUnitName}</li>
        <c:if test="${not empty R6hostname}"><li>主機：</li><li class="user_data">${R6hostname}</li></c:if>
		<li>使用者IP：</li><li class="user_data">${clientIp}</li>
		<c:if test="${authType eq '2'}">
            <li class="user_data"><img src='${IMAGES_SKEL}/internet.gif' name='Image_circle' width='15' height='15' border='0' valign='botten' title='外部網路'></li>
        </c:if>
        <c:if test="${isSwitch}">
            <li class="user_data">[ <a href="<c:out value="${platformDispatcher}"/>/login/return?newTxRequest=true&eBAF_loginPlatformInfo=<c:out value="${eBAF_loginPlatformInfo}"/>" target='_top' title='切回登入者' style="cursor:pointer;">原登入者：${originalName}</a> ]</li>
        </c:if>
    </ul>

	<form id="forwardForm" target="_blank" action = "/ZZWeb/servlet/HttpDispatcher/SysLogin/forward">
		<input id="function_id" name="function_id" value="ZZP10100">
		<input id="url" name="url" value="ZZP1_0100/chooseCase">
	</form>

<script type="text/JavaScript">
<!--
	setEventObserve(document , "dragstart" ,stopEventPop ); //關閉拖曳
	setEventObserve(document , "selectstart" , stopEventPop ); //關閉選取

	var cathayFinanicalSysCodes = [<c:forEach var="sysCode" items="${top_logo_bg_cathayFinanicalList}" varStatus="status"><c:if test="${status.index>0}">,</c:if>'${sysCode}'</c:forEach>];

	//--------------------------------------------
	//  畫面logo
	//--------------------------------------------
	var isMatch = false;
	for(var i=0;i<cathayFinanicalSysCodes.length;i++){
		if(matchSystem.indexOf(cathayFinanicalSysCodes[i])==0){
			isMatch = true;
			break;
		}
	}

	if(isMatch){
		document.body.className = "CathayFinanical";
	}else{
		document.body.className = "cathayLife"
	}

	//--------------------------------------------
	//  啟動時間
	//--------------------------------------------
	Time_init();
	
	//--------------------------------------------
	//  處理menu顏色
	//--------------------------------------------
	var menu_lis = document.getElementById("menuBar").getElementsByTagName('li');
	menu_lis[0].className = "firstChild";
	var pre_highlight_status = menu_lis[0].getAttribute("highlight");
	var num_lis = menu_lis.length;
	for( var i = 0 ; i < num_lis ; i++){
		var this_highlight_status = menu_lis[i].getAttribute("highlight");
		if( "Y" == this_highlight_status){
			menu_lis[i].className = menu_lis[i].className + " highlight";
		}
		if( this_highlight_status != pre_highlight_status ){
			menu_lis[i-1].className = menu_lis[i-1].className + " style_e";
			menu_lis[i].className = menu_lis[i].className + " style_b";
		}
		pre_highlight_status = this_highlight_status;
	}
-->
</script>

<%-- 處理IE6的scroll bar --%>
<%--[if IE 6]>
    <script language="JavaScript" type="text/JavaScript">document.body.scroll="no";</script>
<![endif]--%>
    
</body>
</html>
