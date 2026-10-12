<!DOCTYPE html>
<html>
<head>
<meta charset="Big5">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<title>國泰金融集團 [MAIN TOP]</title>


<%-- ==================================
           JAVA CODE  start
 ================================== --%>
<%@ page contentType="text/html; charset=Big5" %>
<%@ page import="java.lang.StringBuffer" %>
<%@ page import="java.text.*" %>
<%@ page import="org.apache.commons.collections.MapUtils" %>
<%@ include file="/html/CM/header.jsp" %>
<%
    HttpResponseContext resp = new HttpResponseContext(request);
    String IMAGES_SKEL = imageBase + "/CM/skeletons";

    Map outputDataMap = (Map) resp.getOutputData("outputDataMap");

    int intHostType = MapUtils.getIntValue(outputDataMap, "hostType");
    String[] hostTypeImage = { "", "logo_stag.gif", "logo_test.gif", "logo_deve.gif" };

    /* 是否為正式環境之HostType */
    boolean isProdByHostType = com.cathay.common.util.LoginUtil.isProdByHostType(intHostType);

    // 圖檔路徑
    pageContext.setAttribute("IMAGES_SKEL", IMAGES_SKEL);
    // 環境圖檔logo
    pageContext.setAttribute("logoImageName", hostTypeImage[intHostType]);
    // 是否為正式環境
    pageContext.setAttribute("isProdByHostType", new Boolean(isProdByHostType));

    // 時間處理
    pageContext.setAttribute("sysTime", new Date().getTime());

    pageContext.setAttribute("compInfoList", (List<Map>) outputDataMap.get("compInfoList"));

    pageContext.setAttribute("compId", (String) outputDataMap.get("compId"));

	// 是否可主兼職切換
	boolean roleChange = MapUtils.getBoolean(outputDataMap, "roleChange", false);
	if(roleChange){
		 pageContext.setAttribute("PARTIME_JOB_DIV_NO", MapUtils.getString(outputDataMap, "PARTIME_JOB_DIV_NO", ""));
		 pageContext.setAttribute("PARTIME_JOB_DIV_NM", MapUtils.getString(outputDataMap, "PARTIME_JOB_DIV_NM", ""));
		 pageContext.setAttribute("DIV_NO", MapUtils.getString(outputDataMap, "DIV_NO", ""));
		 pageContext.setAttribute("DIV_SHORT_NAME", MapUtils.getString(outputDataMap, "DIV_SHORT_NAME", ""));
	}
	pageContext.setAttribute("roleChange", roleChange);
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
    background-image: url('<%=imageBase %>/CM/login/top_logo.gif');
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

ul#userInfo li#browser_info{
    background:left center no-repeat;
}

ul#userInfo li#browser_info.ie{
    background-image:url('${IMAGES_SKEL}/browsers/internetexplorer.png');
    height:14px;
    padding-left:13px;
    text-align: right;
    font-size: 9px;
    vertical-align:bottom;
}

ul#userInfo li#browser_info.Firefox{
    background-image:url('${IMAGES_SKEL}/browsers/firefox.png');
        width:14px;
    height:14px;
}

ul#userInfo li#browser_info.Opera{
    background-image:url('${IMAGES_SKEL}/browsers/opera.png');
        width:14px;
    height:14px;
}

ul#userInfo li#browser_info.Chrome{
    background-image:url('${IMAGES_SKEL}/browsers/chrome.png');
    width:14px;
    height:14px;
}

ul#userInfo li#browser_info.Safari{
    background-image:url('${IMAGES_SKEL}/browsers/safari.png');
    width:14px;
    height:14px;
}

ul#userInfo li#browser_info.Mozilla{
    background-image:url('${IMAGES_SKEL}/browsers/mozilla.png');
    width:14px;
    height:14px;
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

li.li_select{
    overflow: hidden;
    margin: 0px 3px 0px 1px;
}

select.select{
    position: relative;
    margin-top: -2px;
    margin-right: -20px;
    border: none;
    background-color: transparent;
    font-size: 12px;
    color: #009;
}
</style>


<script type="text/JavaScript">
<!--
    var MatchSystem = "${sysCode}";

    //--------------------------------------------
    //  時鐘控制項
    //--------------------------------------------

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
        var sysTime = new Date( new Date().getTime() + timeDiff );
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
        if(elem.removeEventListener) {                      //DOM2接口 with bubble
            elem.addEventListener(eventName, func, false);
        } else if(elem.detachEvent) {                   //IE DOM2接口  with bubble
            elem.attachEvent('on'+eventName, func);
        } else {                                            //DOM0接口 without bubble
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
    <%-- 非正式環境顯示問題單選項--%>
    <c:if test="${!isProdByHostType}">
    quest_Events = {
        //建立發送連結 &　發送資訊
        window_open:function (url_options){

            var url = "../../../html/CM/skeletons/forwardQuest.jsp?";
            if(url_options){
                for(var key in url_options) {
                    url = url + key + "=" + url_options[key] + "&";
                }
            }

            window.open(url.substring(0,url.length-1), 'QuestPage', 'width=1000,height=600,scrollbars=yes,resizable=yes,titlebar=no');
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

    setEventObserve(window, "load", function(){
    
    <c:choose>
	    <c:when test="${roleChange}">
	    	var oDivSelect = document.getElementById('divSelect');
	    	setEventObserve(oDivSelect, "change", function(){ 
	            var location_href = window.location.href;
	            var target = location_href.substring(0, location_href.indexOf("HttpDispatcher/")+"HttpDispatcher/".length);
	            top.window.location = target + "login/selectUnit?isChange=Y&DIV_NO=" + oDivSelect.value;
	        });
	    </c:when>
	    <c:otherwise>
		    <c:if test="${!isProdByHostType}">
		    <c:if test="${not empty compInfoList}">
		
		        var compId=document.getElementById('compId');
		        setEventObserve(compId, "change", function(){
		            var location_href = window.location.href;
		            var target = location_href.substring(0, location_href.indexOf("HttpDispatcher/")+"HttpDispatcher/".length);
		
		            top.window.location = target + "login/selectUnit?isTop=Y&compID=" + compId.value;
		        });
		
		    </c:if>
		    </c:if>
	    </c:otherwise>
    </c:choose>
    });
-->
</script>

</head>
<body class="cathayLife">
    <%-- 開頭logo 及環境圖示 --%>
    <ul id="main_logos">
        <%-- 主系統logo --%>
        <li id="logo"></li>

        <%-- 系統平台 --%>
        <c:if test="${!isProdByHostType && not empty logoImageName}"><li id="platform_logo"></li></c:if>

        <li id="messageArea"></li>
    </ul>

    <%-- !!!!!!!!!!!!!!!!!選單修改部分!!!!!!!!!!!!!!!!!!! --%>
    <ul id="menuBar">

      <%-- 非正式環境顯示問題單選項--%>
      <c:if test="${!isProdByHostType}">
      <li highlight="Y"><a href="#" onClick="quest_Events.doList()" >查詢問題單</a></li>
      <li highlight="Y"><a href="#" onClick="quest_Events.doOpen()" >開立問題單</a></li>
      </c:if>

      <%-- 登出 --%>
      <li highlight="N"><a target="_top" href="<%=dispatcher%>/logout/logout?newTxRequest=true&eBAF_loginPlatformInfo=<c:out value="${param.eBAF_loginPlatformInfo}"/>">登出</a></li>

      <%-- 時間顯示區--%>
      <li highlight="N" class="timer"><div id="timeText">00:00:00</div><div id="dateText">00/00/00 星期五</div></li>
    </ul>
    <%-- !!!!!!!!!!!!!!!!!選單修改部分!!!!!!!!!!!!!!!!!!! [END]--%>

    <%-- 使用者資訊 --%>
    <ul id="userInfo">
		<c:if test="${!roleChange}">
		<c:if test="${!isProdByHostType}">
        <c:if test="${not empty compInfoList}">
        <li class="li_select">
            <select id="compId" class="select">
            <c:forEach items="${compInfoList}" var="compInfoMap">
                <option value="${compInfoMap.compId}" <c:if test="${compId eq compInfoMap.compId}">selected</c:if>>
                    【&nbsp;<c:out value="${compInfoMap.compName}" default="${compInfoMap.compName}"/>&nbsp;】
                </option>
            </c:forEach>
            </select>
        </li>
        </c:if>
        </c:if>
        </c:if>
        
        <li>使用者：</li><li class="user_data">${outputDataMap.strEmpName}</li>
        <li>作業單位：</li>
	    <c:choose>
	    <c:when test="${roleChange}">
	    	<li class="li_select">
	            <select id="divSelect" class="select">
	            <option value="${COMP_ID},${DIV_NO}" selected>
	            	【&nbsp;<c:out value="${DIV_SHORT_NAME}"/>&nbsp;】
				</option>
	            <option value="${PARTIME_JOB_COMP_ID},${PARTIME_JOB_DIV_NO}">
	            	【&nbsp;<c:out value="${PARTIME_JOB_DIV_NM}"/>&nbsp;】
				</option>
	            </select>
	        </li>
		</c:when>
		<c:otherwise>
        	<li class="user_data">${outputDataMap.strOpUnitName}</li>
		</c:otherwise>
		</c:choose>

        <c:if test="${not empty outputDataMap.hostName}"><li>主機：</li><li class="user_data">${outputDataMap.hostName}</li></c:if>
        <li>使用者IP：</li><li class="user_data">${outputDataMap.clientIP}</li>
        <c:if test="${authType eq '2'}">
            <li class="user_data"><img src='${IMAGES_SKEL}/internet.gif' name='Image_circle' width='15' height='15' border='0' valign='botten' title='外部網路'></li>
        </c:if>
        <c:if test="${outputDataMap.originalID!=null&&outputDataMap.originalID!=''}">
            <li class="user_data">[ <a href="<%=dispatcher%>/login/return?newTxRequest=true&eBAF_loginPlatformInfo=<c:out value="${eBAF_loginPlatformInfo}"/>" target='_top' title='切回登入者' style="cursor:pointer;">原登入者：${outputDataMap.originalName}</a> ]</li>
        </c:if>
        <li id="browser_info"></li>
    </ul>


<script type="text/JavaScript">
<!--
    setEventObserve(document , "dragstart" ,stopEventPop ); //關閉拖曳
    setEventObserve(document , "selectstart" , stopEventPop );  //關閉選取

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