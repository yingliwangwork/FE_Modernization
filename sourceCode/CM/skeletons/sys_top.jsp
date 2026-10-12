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
<%@ page import="com.cathay.common.util.FieldOptionList"%>
<%-- header.jsp會引入沒有用的js檔案，採用HTML註解使其失效 --%><!--  
<%@ include file="/html/CM/header.jsp"%> -->

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
	String sysCode = systemInfo != null && systemInfo.get("sysCode") != null ? String.valueOf(systemInfo.get("sysCode")) : null;


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

        String uid = systemInfo != null && systemInfo.get("uid") != null ? String.valueOf(systemInfo.get("uid")) : null;
        // 取得子系統分流代碼
        String useSysCode = sysCode;
        if (uid != null && !"".equals(uid)) {
        	Map<String, String> menuSettingMap = new com.cathay.common.service.authenticate.MenuTreeHandler().getMainMenuFilterSettingByUID(sysCode, uid);
        	if(menuSettingMap != null){
        		useSysCode = menuSettingMap.get("ALIAS_ID");
        		pageContext.setAttribute("useSysCode", useSysCode);
        	}
        }

        // 過濾特定不要使用HCMD DATE子系統
	    if(isShowMchd && !sysCode.equals(useSysCode)){
	    	String hiddenSysNos = com.cathay.common.service.ConfigManager.getProperty("sysTopJspHiddenMchdDateByUserSysNo");
	    	if(hiddenSysNos != null){
	    		sysNos = hiddenSysNos.split(",");
		        for (int i = 0; i < sysNos.length; i++) {
		            String sysNo = sysNos[i];
		            if (sysNo.equals(useSysCode)) {
		                isShowMchd = false;
		                break;
		            }
		        }
	    	}
	    }

    	if(isShowMchd){
	        try {

	            String callModule = "com.cathay.rz.g0.module.RZ_G00100";
	            String callMethod = "getMchdSystemDateByDivNo";
	            Class[] inputClasses = new Class[]{String.class, String.class};
	            String[] inputValues = new String[]{useSysCode, userObj==null?null:userObj.getDivNo()};

	            Class aClass = Class.forName(callModule);
	            java.lang.reflect.Method aMethod = aClass.getMethod(callMethod, inputClasses);
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

	// ========== 投資平台取得多國語系下拉選單 ==========

	List<Map> availResource = null;
	String targetLocale = null;
	boolean isReload = false;
	if (sysCode != null && (sysCode.startsWith("L") || sysCode.startsWith("R") || "EP".equals(sysCode) || "EH".equals(sysCode) || "XR".equals(sysCode) || "GH".equals(sysCode) ) ){
		    try {
			    targetLocale = request.getParameter("targetLocale");

			    if(targetLocale!=null && !"".equals(targetLocale)){
                   isReload = true;
			    }

	            String callModule = "com.cathay.zz.h0.trx.ZZH0_1500";
	            String callMethod = "getAvailResource";

	            Class aClass = Class.forName(callModule);
	            java.lang.reflect.Method aMethod = aClass.getMethod(callMethod);
				List<String> tmpAvailResource = (List<String>) aMethod.invoke(aClass.newInstance());
				if(tmpAvailResource!=null){
				   availResource = new ArrayList<Map>();
				   for(String res : tmpAvailResource){
				       Map tmpMap = new HashMap<String, String>();
				       tmpMap.put("key", res);
				       tmpMap.put("upperCase", res.toUpperCase());
				       availResource.add(tmpMap);
				   }
				}
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
	}

	// ============================================

    String[] hostTypeCode = { "prod", "stag", "test", "deve" };

    int intHostType = LoginUtil.getHostType();

	// 是否為正式環境之HostType
    boolean isProdByHostType = LoginUtil.isProdByHostType(intHostType);

    //20200629 判定環境
    String env_prefix = "t";
    if (LoginUtil.isProd()) {
        env_prefix = "";
    } else if (LoginUtil.isStag()) {
        env_prefix = "s";
    }
	pageContext.setAttribute("env_prefix", env_prefix);


	boolean isBM = sysCode != null && "BM".startsWith(sysCode);

	String platformDispatcher = null;
	String loginPlatform = null;

	Map eBAF_loginPlatformInfo = LoginInfoHandler.getPlatformInfo(request);

	if(eBAF_loginPlatformInfo!=null){
		platformDispatcher = (String)eBAF_loginPlatformInfo.get("platformDispatcher");
        loginPlatform = (String)eBAF_loginPlatformInfo.get("loginPlatform");
	}
	
	String loginSysCode = com.cathay.common.service.ConfigManager.getProperty("com.cathay.zz.trx.SysLogin.loginSysCode");
	String currPlatform = com.cathay.common.service.ConfigManager.getProperty("com.cathay.zz.trx.SysLogin.currPlatform");
	if(platformDispatcher==null || "".equals(platformDispatcher)){
		if(isBM){
			platformDispatcher = "/CXBWeb/servlet/HttpDispatcher";
			currPlatform = "B2C";
			loginSysCode = "CXB";
		}else{	
			if (loginSysCode == null || "".equals(loginSysCode)) {
				if (currPlatform == null || "".equals(currPlatform)) {
					currPlatform = "CSR";
					loginSysCode = "CXL";
				} else {
					if ("B2C".equals(currPlatform)) {
						loginSysCode = "CXB";
					} else if ("B2E".equals(currPlatform)) {
						loginSysCode = "CXP";
					} else if ("IM".equals(currPlatform)) {
						loginSysCode = "IM";
					} else {
						loginSysCode = "CXL";
					}
				}
			}
			sbf.append("/").append(loginSysCode).append("Web/servlet/HttpDispatcher");
			platformDispatcher = sbf.toString();
			sbf.setLength(0);
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

	String showGo2XP;
	if("CSR".equals(currPlatform)||"STAFF".equals(currPlatform) ){
		showGo2XP = "Y";
	}else{
		try{
			boolean hasAuth = false;
			if(userObj!=null){
				List xp_roles = FieldOptionList.getAllOption("ZZ", "XP_AUTH_ROLES");
				for(Object role:xp_roles){
					if(userObj.isValidRole(role.toString())){
						hasAuth = true;
						break;
					}
				}
			}
	
			showGo2XP = hasAuth ? "Y" : "N";
		}catch(Exception e){
			showGo2XP = "N";
		}
	}

	try {
		List top_logo_bg_cathayFinanicalList = com.cathay.common.util.FieldOptionList.getAllOption("ZZ", "sys_top.jsp.group.top_logo_bg2");
		pageContext.setAttribute("top_logo_bg_cathayFinanicalList", top_logo_bg_cathayFinanicalList);
	} catch (Exception e) {
	}

	if("B2E".equals(currPlatform)){
		String B2E_TAM_Junction = com.cathay.common.service.ConfigManager.getProperty("B2E_TAM_Junction");
		pageContext.setAttribute("B2E_TAM_Junction", B2E_TAM_Junction);
	}
	
	//--------------------------------------------
	//  處理頁面風格設定
	//--------------------------------------------
	String style_css_file = "";
	try{
        String sys_theme = com.cathay.common.util.FieldOptionList.getName("ZZ", "sys_theme" , sysCode );
        if(sys_theme != null && !sys_theme.trim().equals("")){
        	if("blue".equalsIgnoreCase(sys_theme)){
        		style_css_file = "/skeletons/sys_top-blue.css";
        	}
        }
    }catch(Exception e){
        System.out.println("===sys_top.jsp theme Exception ===>" + e.getMessage());
    }
    if(style_css_file == null || "".equals(style_css_file.trim())){
    	if(org.apache.commons.lang.ArrayUtils.contains(new String[]{"EH","NC","ND","NK","NJ","NF"}, sysCode)){
    		style_css_file = "/skeletons/sys_top-blue.css";
    	}else{
    		style_css_file = "/skeletons/sys_top.css";
    	}
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
	pageContext.setAttribute("logoImageName", hostTypeCode[intHostType]);
	// 是否顯示切換原登入者
	pageContext.setAttribute("isSwitch", new Boolean(isSwitch));
	// 原登入者
	pageContext.setAttribute("originalName", originalName);
	// 系統日初
	pageContext.setAttribute("showMchdMsg", showMchdMsg);
	// 多國語系選單
	pageContext.setAttribute("availResource", availResource);
	// 現在使用語系
	pageContext.setAttribute("targetLocale", targetLocale);
	// 如果有切換語系就reload頁面
	pageContext.setAttribute("isReload", new Boolean(isReload));
	// 登入平台
	pageContext.setAttribute("loginPlatform", loginPlatform);
	// 登入平台的 Dispatcher
	pageContext.setAttribute("platformDispatcher", platformDispatcher);
	// 平台代號
	pageContext.setAttribute("currPlatform", currPlatform);	
	// 使用者ip
	pageContext.setAttribute("clientIp", clientIp);
	// 子系統代碼
	pageContext.setAttribute("sysCode", sysCode);

	// 是否顯示回到主選單頁籤
	pageContext.setAttribute("showGoBack2Main", showGoBack2Main);
	// 是否顯示「查詢問題_新」、「開立問題_新」頁籤
	pageContext.setAttribute("showGo2XP", showGo2XP);

	// 時間處理
	pageContext.setAttribute("sysTime", new Date().getTime());

	/*
	* 2019-5-15
	* 依據2019資安弱點掃描結果，eBAF_UserObject_Flag及eBAF_loginPlatformInfo在傳輸時可能會造成HTML注入攻擊，故進行修正，對於值中包含單雙引號及大小於符號進行過濾
	* 過濾條件：
	*   1.不得出現任一: ' " & ;
	*   2.不得同時出現: < >
	* 亮勳
	*/
	String testParam = String.valueOf(request.getParameter("eBAF_UserObject_Flag"));
	if (!testParam.matches(".*([&'\";]|<.*>|>.*<).*")) {
		// userObj
		pageContext.setAttribute("eBAF_UserObject_Flag", testParam);
	}
	testParam = String.valueOf(request.getParameter("eBAF_loginPlatformInfo"));
	if (!testParam.matches(".*([&'\";]|<.*>|>.*<).*")) {
		// 加密後之登入平台相關資訊
		pageContext.setAttribute("eBAF_loginPlatformInfo", testParam);
	}
	
	// 頁面載入 CSS 檔案
	pageContext.setAttribute("style_css_file", style_css_file);

%>

<%-- ==================================
           JAVA CODE  end
 ================================== --%>

<!--  this system code is ${sysCode}; bypass system code is ${useSysCode}; targetLocale is ${targetLocale} -->

<!--  引入CSS -->
<link rel="stylesheet" type="text/css" href="${cssBase}${style_css_file}" />

<c:if test="${not empty targetLocale && isReload}">
	<fmt:setLocale value="${targetLocale}" scope="session" />
</c:if>

<fmt:setBundle basename="TextResource" />

<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript">
<!--

   <c:if test="${not empty targetLocale && isReload}">
   //如果有切換語系就reload頁面
   		var t = window.top;
   		if(window != t ){
			t.location.reload();
		}
   </c:if>

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
	//  測試瀏覽器
	//--------------------------------------------
	function getBrowser(){
        var browser = {   // browser object
            browser: '',
            desp: null,
            verIE:null,
            docModeIE: null, //IE browser document mode
            verIEtrue: null, //True IE browser version (independent of userAgent, document mode, or browser mode):
            verIE_ua: null //IE browser version (derived from navigator.userAgent)
        };

        var userAgentStrings = navigator.userAgent;
        var tmp = document.documentMode;
        try{document.documentMode = "";}
        catch(e){};

        browser.isIE = typeof document.documentMode == "number" || eval("/*@cc_on!@*/!1");

        try{document.documentMode = tmp;}
        catch(e){};

        if (browser.isIE) {
            // IE version from user agent
            //
            // For IE < 11, we look for "MSIE 10.0", etc...
            // For IE 11+, we look for "rv:11.0", etc...
            browser.verIE_ua = (/^(?:.*?[^a-zA-Z])??(?:MSIE|rv\s*\:)\s*(\d+\.?\d*)/i).test(userAgentStrings || "") ? parseFloat(RegExp.$1, 10) : null;

            // Get true IE version using clientCaps.
            var e, verTrueFloat, x, obj = document.createElement("div");
            // Array of classids that can give us the IE version
            var CLASSID = [
                 "{45EA75A0-A269-11D1-B5BF-0000F8051515}", // Internet Explorer Help
                 "{3AF36230-A269-11D1-B5BF-0000F8051515}", // Offline Browsing Pack
                 "{89820200-ECBD-11CF-8B85-00AA005B4383}"
            ];
            try { obj.style.behavior = "url(#default#clientcaps)" } catch (e) { };

            for (x = 0; x < CLASSID.length; x++) {
                try { browser.verIEtrue = obj.getComponentVersion(CLASSID[x], "componentid").replace(/,/g, "."); } catch (e) { };
                if (browser.verIEtrue) break;
            };
            verTrueFloat = parseFloat(browser.verIEtrue || "0", 10);
            browser.docModeIE = document.documentMode || ((/back/i).test(document.compatMode || "") ? 5 : verTrueFloat) || browser.verIE_ua;
            browser.verIE = verTrueFloat || browser.docModeIE;
        } else {
            if (userAgentStrings.search('Firefox') >= 0) {
                browser.browser = 'Firefox';
                browser.desp = 'mozilla Firefox';
            } else if (userAgentStrings.search('Opera') >= 0 || userAgentStrings.search('OPR') >= 0) {
                browser.browser = 'Opera';
                browser.desp = 'Opera';
            } else if (userAgentStrings.search('Chrome') >= 0) {
                browser.browser = 'Chrome';
                browser.desp = 'Google Chrome';
            } else if (userAgentStrings.search('Safari') >= 0) {
                browser.browser = 'Safari';
                browser.desp = 'Apple Safari';
            } else if (userAgentStrings.search('Mozilla') >= 0) {
                browser.browser = 'Mozilla';
                browser.desp = 'Mozilla';
            }
        }
        return browser;
    }

	//--------------------------------------------
	//  各項按鈕控制項
	//--------------------------------------------
	<%-- 非正式環境顯示回歸資料再生及問題單選項--%>
<c:if test="${!isProdByHostType}">
	var recoverEvents = new function(){
		return {
			dataMaker: function(){
				window.open('', 'dataMakerwindow', 'scrollbars=yes,resizable=yes,titlebar=no,top=100px,left=150px');
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
	};
</c:if>

	var linkB2EEvents = new function(){
		var crossForwardForm;
		var toSystem_XP = function(funcId, url){
			var bottomFrame = ( top && top.frames && top.frames['leftFrame'] ) || ( parent && parent.frames && parent.frames['leftFrame'] );

			var targetIFrame = bottomFrame && ( (bottomFrame.document && bottomFrame.document.getElementById("mainFrame")) || bottomFrame.frames['mainFrame'] || top.frames['mainFrame'] || parent.frames['mainFrame']);

			var localURL;
			if(targetIFrame.contentDocument){
				localURL = targetIFrame.contentDocument.location.href;
			}else{
				localURL = targetIFrame.contentWindow.document.location.href;
			}

			var tx_name;
			if(localURL){
				var filterText = "HttpDispatcher/";
				var idx = localURL.indexOf(filterText);
				if(idx > 0){
					tx_name = localURL.substr(idx+filterText.length, 9);

					if(tx_name.indexOf("_") > 0){
						tx_name = tx_name.replace(/_/g, "");
					}else{
						tx_name = null;
					}
				}
			}

			if(tx_name){	            
				<%--20191126_加入URL參數: 來源平台、子系統 --%>
	        	var params = "?R6hostname=${R6hostname}&FROM_PLATFORM=${currPlatform}&SYS_NO=${sysCode}&FUNC_ID="+tx_name;
				<%--20200629_修正為開啟特定URL，觸發LDAP機制，不使用crossForward機制。上方有產出env_prefix的方式，確定位在哪個環境 --%>							
                window.open("https://${env_prefix}staff.cathaylife.com.tw/XPWeb/servlet/HttpDispatcher/" + url + params, 'crossForwardToSystemXP', 'scrollbars=yes,resizable=yes,titlebar=no,top=100px,left=150px');
			} else {
				alert("非功能頁無法使用XP問題單系統");
			}
		};
		return {
			toSystem_XPByQuery: function(){
				toSystem_XP('XPB00030', 'XPB0_0030/prompt');
			},
			toSystem_XPByCreate: function(){
				toSystem_XP('XPB00130', 'XPB0_0130/prompt');
			}
		};
	};

	<%-- AT 系統 待辦事項連結 --%>
<c:if test="${sysCode eq 'AT'}">
	var AT_events = {

		canLinkTo : true,

		doLinkTo : function(){
			if(!AT_events.canLinkTo){
				return;
			}

			AT_events.canLinkTo=false;

			AT_events.getMainFrame("${dispatcher}/ATB0_1600/prompt?newTxRequest=true&syscode=AT&subcode=ATB0");

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
	//  儲存popupWin物件，以免開啟過多彈跳視窗... 所有的popupm會用同一個子視窗開啟
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

    var B2E_TAM_Junction = '${B2E_TAM_Junction}';
    if(B2E_TAM_Junction){
        document.cookie = "IV_JCT=%2F" + B2E_TAM_Junction + "; path=/";
    }
-->
</script>

</head>
<body>
	<%-- 開頭logo 及環境圖示 --%>
	<ul id="main_logos" class="${logoImageName}">
		<%-- 主系統logo --%>
		<li id="logo" onclick="parent.location.href=''; " title="主選單">
			<a href="${platformDispatcher}/login/loginFromSys?newTxRequest=true&eBAF_loginPlatformInfo=<c:out value="${eBAF_loginPlatformInfo}"/>" target="_parent">
				<img src="${imageBase}/CM/login/top_logo.gif">
			</a>
		</li>

		<%-- 系統平台 --%>
		<c:if test="${logoImageName != 'prod'}">
		<li id="platform_logo" >
			<img src="${IMAGES_SKEL}/logo_${logoImageName}.gif">
		</li>
		</c:if>

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
      <c:if test="${showGo2XP eq 'Y'}">
      <li highlight="N" class="small"><a href="#" onClick="linkB2EEvents.toSystem_XPByQuery()" ><img src="${IMAGES_SKEL}/sys_top_search.png"><span>查詢問題單</span></a></li>
      <li highlight="N" class="small"><a href="#" onClick="linkB2EEvents.toSystem_XPByCreate()" ><img src="${IMAGES_SKEL}/sys_top_support.png"><span>問題建議</span></a></li>
      </c:if>
	  <%-- AT 系統 待辦事項連結 --%>
      <c:if test="${sysCode eq 'AT'}">
	  <li highlight="Y"><a target="_self" href="#" onclick="AT_events.doLinkTo();">待辦事項</a></li>
      </c:if>

      <%-- 在主選單因為不需要有回主選單 --%>
      <c:if test="${showGoBack2Main ne 'N'}">
      <li highlight="N"><a target="_top" href="<c:out value="${platformDispatcher}"/>/login/loginFromSys?newTxRequest=true&eBAF_loginPlatformInfo=<c:out value="${eBAF_loginPlatformInfo})"/>" >主選單</a></li>
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
		<c:if test="${not empty availResource}">
        <li id="local-selecter">
		    <select id="targetLocale" title="Change Language">
		       <%-- <option value="zh-tw">繁體中文</option><option value="en-us">English</option>  --%>
			   <c:forEach items="${availResource}" var="row">
				  <option value="${row.key}" <c:if test="${row.key eq targetLocale}">selected</c:if>><fmt:message key="MSG_UI_${row.upperCase}" /></option>
               </c:forEach>
			</select>
		</li>
		</c:if>
        <li id="browser_info"></li>
    </ul>
<c:if test="${!isProdByHostType}">
	<form id="forwardForm" target="dataMakerwindow" action = "/ZZWeb/servlet/HttpDispatcher/SysLogin/forward">
		<input type="hidden" id="function_id" name="function_id" value="ZZP10100">
		<input type="hidden" id="url" name="url" value="ZZP1_0100/chooseCase">
	</form>
</c:if>
	<form id="crossForwardForm" target="crossForwardToSystemXP" action = "${dispatcher}/SysLogin/forward" method="post">
		<input type="hidden" id="function_id" name="function_id">
		<input type="hidden" id="url" name="url">
		<input type="hidden" id="PLATFORM" name="PLATFORM">
		<input type="hidden" id="crossForward" name="crossForward">
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
	//  偵測瀏覽器
	//--------------------------------------------
	var browser_info = getBrowser();
	var browser_info_elem = document.getElementById('browser_info');
	if(browser_info.isIE){
		browser_info_elem.className = 'ie';
		browser_info_elem.innerHTML = browser_info.verIE;
		browser_info_elem.title = 'Microsoft Internet Explorer '+browser_info.verIE+'(Mode:'+browser_info.docModeIE+')';
	}else{
		browser_info_elem.className = browser_info.browser;
		browser_info_elem.title = browser_info.desp;
	}

	//--------------------------------------------
	//  啟動時間
	//--------------------------------------------
	Time_init();

	//--------------------------------------------
	//  處理menu顏色
	//--------------------------------------------
	var menu_lis = document.getElementById("menuBar").getElementsByTagName('li');
	menu_lis[0].className = ( menu_lis[0].className ||"")+" firstChild";
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
	<c:choose>
	<c:when test="${not empty availResource}">
	
	// 判斷是否有targetLocale下拉選單
	if($("targetLocale") && top["CurrentLocale"]){
	    $("targetLocale").value = top["CurrentLocale"];
	}
	
	function setLocale( newLocal , onlyRewriteWhenDefault ){
		if(!newLocal){ return; }
		/* 以被手動修正過 */
		if(onlyRewriteWhenDefault && top["CurrentLocale"] ){
			window.console && console.log('[sys_top.jsp] cannot set language to '+newLocal+' because it is not the default language anymore.'); 
			return; 
		}
		if(top["CurrentLocale"] && top["CurrentLocale"].toUpperCase() == newLocal.toUpperCase()){
			window.console && console.log('[sys_top.jsp] cancel set language because it is already '+newLocal+'.');  
			return;
		}
		var targetLocale = document.getElementById("targetLocale");
		var add_attr;
		$(targetLocale).select('option').each(function(elem){
			if(!add_attr && elem.value.toUpperCase() == newLocal.toUpperCase()){
				add_attr = 'targetLocale='+elem.value;
			}
		});
		if(!add_attr){
			window.console && console.log('[sys_top.jsp] cannot set language because locale code ('+newLocal+') is not found.');
			return;
		}
		
		var href_now = location.href;
		if(href_now.indexOf('?') < 0 ){
 			href_now = href_now + '?' + add_attr;
		}else{
			var href_now_split = href_now.split('?');
			href_now = href_now_split[0];
			href_now_split = href_now_split[1].split('&');
			
			var isFirst = true;
			for(var i = 0 ; i < href_now_split.length ; i++ ){
				if(href_now_split[i].indexOf('targetLocale=') == 0){ continue; }
				href_now = href_now + (isFirst ? '?' : '&' ) + href_now_split[i];
				isFirst = false;
			}
			href_now = href_now + (isFirst ? '?' : '&' ) + add_attr;
		}
		location.href = href_now;
 	}
	
	setEventObserve(document.getElementById("targetLocale") , "change" , function(e){
		setLocale(e.target.value , false);
	} );
	</c:when>
	<c:otherwise>
		function setLocale(){ window.console && console.log('[sys_top.jsp] this system did not support locale language setup.'); }
	</c:otherwise>
	</c:choose>
	if(window != window.top){
 		try{
 			window.top.setLocale = setLocale;
 		}catch(e){
 			window.console && console.log('[sys_top.jsp] cannot set function "setLocale" to top window. ' + e);
 		}
 	}
-->
</script>

<%-- 處理IE6的scroll bar --%>
<%--[if IE 6]>
    <script language="JavaScript" type="text/JavaScript">document.body.scroll="no";</script>
<![endif]--%>

</body>
</html>
<script  language='javascript' type='text/javascript'>//難字系統
if (typeof WebRootPath=='undefined') {
   var WebRootPath = '${pageContext.request.contextPath}/';
   var imeServer='https://mi.cathaylife.com.tw/wf/';
   var jscript = document.createElement('script');
   jscript.setAttribute('lang', 'text/javascript');
   jscript.setAttribute('src', '${pageContext.request.contextPath}/hanlinks/wf_links.js');
   document.getElementsByTagName('head').item(0).appendChild(jscript);
}
</script>