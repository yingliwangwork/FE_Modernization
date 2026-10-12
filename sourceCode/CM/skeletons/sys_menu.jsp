<!DOCTYPE html>
<html>
<head>
<meta charset="Big5" />
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
<meta name="viewport" content="width=1024" />
<%@ page contentType="text/html; charset=Big5" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="/CXL" prefix="CXL" %>
<!-- <%-- csCommon會引入沒有用的js檔案，採用HTML註解使其失效 --%>
<CXL:csCommon trace="false" htmlBaseName="htmlBase" cssBaseName="cssBase" imageBaseName="imageBase" dispatcherName="dispatcher" /> -->

<%
//傳入參數----------------------------------------------------
String strSysCode = (String) pageContext.getAttribute("syscode");

String openAllNode = (String)request.getAttribute("openAllNode");
openAllNode = openAllNode!=null ? openAllNode : "0" ;
//-----------------------------------------------------------

//自訂最新消息 --------------------------------------
/**
可設定指向 action 或 JSP
ex. ZZWeb 客制設定
   action -> /ZZWeb/servlet/HttpDispatcher/ZZH0_0200/prompt
   JSP    -> /ZZWeb/html/CM/skeletons/ZE_manual.jsp
*/
String newsPath;
try {
	newsPath = com.cathay.common.util.FieldOptionList.getName("ZZ", "SysNewsURL", strSysCode);
} catch (Exception e) {
	newsPath = null;
}

if(newsPath == null || "".equals(newsPath)){
	newsPath = dispatcher+"/SysNews/sys?syscode="+ strSysCode;
}

//操作手冊連結是否顯示 --------------------------------------
boolean isSetOperationManual = false;
try {
	String fieldValue = com.cathay.common.util.FieldOptionList.getName("ZZ", "OperationManual", strSysCode);
	isSetOperationManual = fieldValue != null && !fieldValue.equals("");
} catch (Exception e) {
}
ArrayList manualLink =  new ArrayList();
	manualLink.add("AA");
	manualLink.add("AB");
	manualLink.add("AC");
	manualLink.add("AK");
	manualLink.add("AT");
	manualLink.add("AV");
	manualLink.add("CB");
	manualLink.add("DC");
	manualLink.add("DE");
	manualLink.add("DJ");
	manualLink.add("DK");
	manualLink.add("DN");
	manualLink.add("EA");
	manualLink.add("EC");
	manualLink.add("GC");
	manualLink.add("ZE");

StringBuffer sb = new StringBuffer();
if (isSetOperationManual) {
	sb.append(htmlBase).append("/").append(strSysCode).append("/").append(strSysCode).append("_manual.jsp?a='");
} else if (!isSetOperationManual && manualLink.contains(strSysCode)) {
	sb.append(htmlBase).append("/CM/skeletons/").append(strSysCode).append("_manual.jsp");
}

String manualPath = sb.toString();
//---------------------------------------------------------

//影像系統（AV）壓力測試連結 --------------------------------------
if ("AV".equalsIgnoreCase(strSysCode)) {
	pageContext.setAttribute("stressTestingLink", htmlBase+"/scantest.jsp");
}
//---------------------------------------------------------

String currPlatform = com.cathay.common.service.ConfigManager.getProperty("com.cathay.zz.trx.SysLogin.currPlatform");
if("B2E".equals(currPlatform)){
	String B2E_TAM_Junction = com.cathay.common.service.ConfigManager.getProperty("B2E_TAM_Junction");
	pageContext.setAttribute("B2E_TAM_Junction", B2E_TAM_Junction);
}

//--------------------------------------------
//  處理頁面風格設定
//--------------------------------------------
String style_css_file = "";
String bottom_html_url = "";
try{
    String sys_theme = com.cathay.common.util.FieldOptionList.getName("ZZ", "sys_theme" , strSysCode );
    if(sys_theme != null && !sys_theme.trim().equals("")){
    	if("blue".equalsIgnoreCase(sys_theme)){
    		style_css_file = "/skeletons/sys_menu-blue.css";
    		bottom_html_url = "/CM/skeletons/bottom_css.htm"; 
    	}
    }
}catch(Exception e){
    System.out.println("===sys_menu.jsp theme Exception ===>" + e.getMessage());
}
if(style_css_file == null || "".equals(style_css_file.trim())){
	if(org.apache.commons.lang.ArrayUtils.contains(new String[]{"EH","NC","ND","NK","NJ","NF"}, strSysCode)){
		style_css_file = "/skeletons/sys_menu-blue.css";
		bottom_html_url = "/CM/skeletons/bottom_css.htm"; 
	}else{
		style_css_file = "/skeletons/sys_menu.css";
		bottom_html_url = "/CM/skeletons/bottom.htm";
	}
}

pageContext.setAttribute("openAllNode", openAllNode);
pageContext.setAttribute("newsPath", newsPath);
pageContext.setAttribute("manualPath", manualPath);

// 頁面載入 CSS 檔案
pageContext.setAttribute("style_css_file", style_css_file);

// 頁面載入 bottom 網址
pageContext.setAttribute("bottom_html_url", bottom_html_url);


%>

<title>國泰人壽 - <c:out value="${sysName}"/></title>

<script type="text/javascript">
	var eBAF_UserObject_Flag = top['eBAF_UserObject_Flag'];
	var eBAF_loginSystemInfo = top['eBAF_loginSystemInfo'];
<c:choose><c:when test="${empty subMenu}">
	alert('您無此系統作業權限!');
	top.location = '<%=dispatcher%>/SysLogout/logout?newTxRequest=true';
</c:when><c:otherwise>

	var menuDatas = [];
<c:forEach var="data" items="${subMenu}" varStatus="status">
		menuDatas.push({
			subSysCode:'<c:out value="${data.subSysFunction.SUB_SYS_CODE}"/>', name:'<c:out value="${data.subSysFunction.FUNC_NAME}" escapeXml="false"/>',
			subNode:[<c:forEach var="func" items="${data.functionList}" varStatus="funcStatus"><c:set target="${func}" property="isAppendRequestContextPath" value="${not empty func.INVK_URL && not fn:startsWith(func.INVK_URL, pageContext.servletContext.contextPath) && not fn:startsWith(func.INVK_URL, 'http')}" /><c:if test="${not funcStatus.first}">,</c:if>
				{'funcId':'<c:out value="${func.FUNC_ID}"/>', 'funcColor':'<c:out value="${func.FUNC_COLOR}"/>', 'name':'<c:out value="${func.FUNC_NAME}"  escapeXml="false"/>', 'desc':'<c:out value="${func.FUNC_DESC}"  escapeXml="false"/>', 'url':'<c:if test="${func.isAppendRequestContextPath}"><c:out value="${pageContext.servletContext.contextPath}" escapeXml="false"/></c:if><c:out value="${func.INVK_URL}" escapeXml="false"/>'}</c:forEach>
			]
		});
</c:forEach>
	<c:if test="${not empty manualPath}">menuDatas.push({'funcColor':'2', 'name':'操作手冊', 'url':'<c:out value="${manualPath}"/>'})</c:if>
	<c:if test="${not empty stressTestingLink}">menuDatas.push({'funcColor':'2', 'name':'壓力測試', 'url':'<c:out value="${stressTestingLink}"/>'})</c:if>
</c:otherwise></c:choose>

</script>

<!--  引入CSS -->
<link rel="stylesheet" type="text/css" href="${cssBase}${style_css_file}" />

</head>
<body>
<table id="mainTable">
<tbody>
<tr>
<td id="menuDiv">
    <div id="menutree"></div>
</td>
<td id="mainFrameDiv">
	<iframe id="mainFrame" name="mainFrame" frameborder="no" scrolling="yes" style="width:100%; -webkit-overflow-scrolling:touch;" src="${newsPath}"/>"  ></iframe>
</td>
</tr>
</tbody>
</table>
<button type="button" id="openMenuButton" class="show_hide" onclick="showMenu()" title="打開選單 - <c:out value="${sysName}"/>" style="display:none;"></button>
<button type="button" id="closeMenuButton" class="show_hide" onclick="hiddenMenu()" title="隱藏選單"><c:out value="${sysName}"/></button>
<div id="bottomFrameDiv">
	<iframe id="bottomFrame" name="bottomFrame" frameborder="no" scrolling="no" style="height:33px; width:100%;" src="${htmlBase}${bottom_html_url}" style="overflow:hidden;"></iframe>
</div>

<script type="text/javascript" >

	//判斷瀏覽器
	var ie_ver = false;
	/*@cc_on  ie_ver = (document.documentMode||( document.compatMode == "CSS1Compat" ? "XMLHttpRequest" in window ? @_jscript_version*10-50 : 6 : 5) ); @*/

	//判斷是否為行動裝置
	/*var mobiles = new Array(
			"midp", "j2me", "avant", "docomo", "novarra", "palmos", "palmsource",
			"240x320", "opwv", "chtml", "pda", "windows ce", "mmp/",
			"blackberry", "mib/", "symbian", "wireless", "nokia", "hand", "mobi",
			"phone", "cdm", "up.b", "audio", "sie-", "sec-", "samsung", "htc",
			"mot-", "mitsu", "sagem", "sony", "alcatel", "lg", "eric", " vx",
			"NEC", "philips", "mmm", "xx", "panasonic", "sharp", "wap", "sch",
			"rover", "pocket", "benq", "java", " pt", " pg", "vox", "amoi",
			"bird", "compal", " kg", "voda", "sany", "kdd", "dbt", "sendo",
			" sgh", "gradi", "jb", "dddi", "moto", "iphone", "android",
			"iPod", "incognito", "webmate", "dream", "cupcake", "webos",
			"s8000", "bada", "googlebot-mobile"
	)*/
	var mobiles = ["iphone","iPod","ipad"];

	var isMobile = false;
	if(!ie_ver){
		var ua = navigator.userAgent.toLowerCase();
		
		var versionStr = 'version/';
		var versionNumStr = "";
		var indexOfVersion = ua.indexOf(versionStr);
		if (indexOfVersion >= 0) {
			var versionSubStr = ua.substring(indexOfVersion + versionStr.length, ua.length -1);  // 版本號
  			versionNumStr = versionSubStr.substring(0, versionSubStr.indexOf("."));
		}
		
		for (var i = 0; i < mobiles.length; i++) {
			var mobileDeviceName = mobiles[i];
			if (ua.indexOf(mobileDeviceName) > 0 && parseInt(versionNumStr) < 13) {
				isMobile = true;
				break;
			}
		}
	}

	var closeMenuButton = document.getElementById('closeMenuButton');
	var openMenuButton = document.getElementById('openMenuButton');

	var mainTable = document.getElementById('mainTable');

	var menuTreeMainUL = null;
	var mainFrame = document.getElementById('mainFrame');
	var bottomFrame = document.getElementById('bottomFrame');

	var windowSizeDiv = document.getElementById("windowSizeDiv");
	var menuDiv=menutree.parentNode;
	var mainFrameDiv=mainFrame.parentNode;
	var bottomFrameDiv=bottomFrame.parentNode;

	var openAllNode = <c:out value="${openAllNode}" default="false"/>;

	init();

	function hiddenMenu(){
		document.getElementById('menuDiv').style.display = 'none';
		document.getElementById('closeMenuButton').style.display = 'none';
		document.getElementById('openMenuButton').style.display = '';
		resize();
	}

	function showMenu(){
		document.getElementById('menuDiv').style.display = '';
		document.getElementById('closeMenuButton').style.display = '';
		document.getElementById('openMenuButton').style.display = 'none';
		resize();
	}

	var isResizing = false;

	function resize(){

		//if(isResizing) { return; }
		isResizing = true;

		var mainFrameLeft = menuDiv.offsetWidth;
		mainFrame.style.width = "1px";
		bottomFrame.style.width = "1px";
		if(!isMobile){
			mainFrame.style.height = "1px";
			menutree.style.height = "1px";

			if(!mainFrameDiv.offsetWidth){
				setTimeout(resize,100);
				return;
			}

			var mainTableHeight = Math.max(
				Math.max(document.body.offsetHeight, document.documentElement.offsetHeight),
				Math.max(document.body.clientHeight, document.documentElement.clientHeight),
				0
			);

			if(mainFrameLeft){
				var save_scrollTop = menutree.scrollTop;
				menutree.style.height = (mainTableHeight-closeMenuButton.offsetHeight-2) + "px";
				menutree.scrollTop = save_scrollTop;
			}
			var mainFrameHeight = (mainTableHeight - bottomFrame.offsetHeight) + "px";

			mainFrame.style.height = mainFrameHeight;



			var mainFrameWidth = mainFrameDiv.offsetWidth + "px";
			mainFrame.style.width = mainFrameWidth;
			bottomFrame.style.width = mainFrameWidth;

		}else{
			var mainFrameWidth =(1024-menuDiv.offsetWidth) + "px";
			mainFrame.style.width = mainFrameWidth;
			bottomFrame.style.width = mainFrameWidth;
		}

		setTimeout("isResizing=false",500);

		return;
	}

	function getContentFrameHeight(){
		return mainFrame.style.height;
	}

	function stopEventPop(e){
		 if ( e && e.preventDefault ) //(W3C)
		 e.preventDefault();
		 else //for IE
		 window.event.returnValue = false;
		 return false;
	}

	function init(){
		menuTreeMainUL = createMenu( menuDatas );
		var firstDataNode = menuTreeMainUL.firstChild;

		var dom_li = document.createElement('LI');
		var dom_a = document.createElement('A');


		dom_li.className = "rootItem";
		setEventObserve(dom_a,"click",clickLink);
		dom_a.setAttribute("href","${newsPath}");
		dom_a.setAttribute("title",'<c:out value="${sysName}"/> - 最新消息');
		dom_a.setAttribute("target","mainFrame");
        dom_a.className = 'itemLink';

		dom_a.appendChild(document.createTextNode('<c:out value="${sysName}"/>'));
		dom_li.appendChild(dom_a);

		menuTreeMainUL.insertBefore(dom_li,firstDataNode);

		menutree.appendChild(menuTreeMainUL);

		var open_menu_lastChild = menuTreeMainUL.lastChild;
		open_menu_lastChild.style.backgroundPositionY = ((open_menu_lastChild.offsetHeight/2)-1)+"px";

		if(isMobile){
			mainTable.style.width = "1024px";
			mainTable.style.maxWidth = "1024px";
		}
		resize();
	}

	function createMenu( menuDatas ){
		if(!menuDatas || !menuDatas.length){ return false; }
		var dom_ul = document.createElement('UL');
		for(var i = 0 ; i < menuDatas.length ; i += 1){
			var menuData = menuDatas[i];
			var isFolder = createMenu( menuData.subNode );
			var dom_li = document.createElement('LI');
			

			/* 滑過連結顯示 */
			var title = "";

			if(isFolder){
                var dom_div = document.createElement('DIV');
			    dom_li.appendChild(dom_div);
				setEventObserve(dom_div,"click",clickFolder);
				dom_div.appendChild(document.createTextNode(menuData.name));
				dom_li.appendChild(isFolder);
				dom_li.className = "folder";
				if(!openAllNode){
					isFolder.style.display = "none";
				}else{
					dom_div.className = "open_folder";
				}
				title = (menuData.subSysCode||"")+menuData.name;

			}else{
				var url = menuData.url||"";
				if(!url){
					continue;
				}
				if(eBAF_UserObject_Flag){
					url +=url.indexOf('?')>0?'&':'?';
					url +='eBAF_UserObject_Flag='+eBAF_UserObject_Flag;
				}
				if(eBAF_loginSystemInfo){
					url +=url.indexOf('?')>0?'&':'?';
					url +='eBAF_loginSystemInfo='+eBAF_loginSystemInfo;
				}
				var dom_a = document.createElement('A');
                dom_a.className = 'itemLink';
				//setEventObserve(dom_div,"click",clickLink);
				dom_a.appendChild(document.createTextNode(menuData.name));
                setEventObserve(dom_a,"click",clickLink);
				//dom_div.appendChild(dom_a);
                dom_li.appendChild(dom_a);
				dom_li.className = "item funcColor"+ (menuData.funcColor||"0");
				dom_a.setAttribute("href",url);
				dom_a.setAttribute("target","mainFrame");
				var funcId = menuData.funcId || "";
				title = (funcId?""+funcId+"\n":"")+(menuData.desc || "");
			}
            
			if(title){
				dom_li.setAttribute("title", title);
			}
			dom_ul.appendChild(dom_li);
		}

		dom_ul.lastChild.className = (dom_ul.lastChild.className ? dom_ul.lastChild.className+" ": "")+"lastMeunChild";
		return dom_ul;
	}

	var previous_link = null;
	function clickLink(e){
		var target = (e&&(e.target||e.srcElement))||(event&&(event.srcElement||event.target))||this;
		if(!target){
			if(previous_link){
				previous_link.className = "";
				previous_link = null;
			}
			return;
		}
        if(target.tagName != "A"){
			return;
		}
		
		if(target.blur){
			target.blur();
		}
        
        updatePrevious_link(target);

        // 清除所有的 LP_JSON 記錄
        if(top.LP_JSON){
            top.LP_JSON = undefined;
        }

	}

	function updatePrevious_link(target_a){
		clearNotifyMsg();
     
     	//沒有連結(應該不會)
		if(!target_a || target_a.tagName != "A"){
            if(previous_link){
                previous_link.className = previous_link.className.replace(/\sactive/,'');
                previous_link = null;
            }
			return;
		}
		//無修改連結視窗
		if(target_a == previous_link){
			return;
		}
		//移除前面的資料
		if(previous_link){
			previous_link.className = previous_link.className.replace(/\sactive/,'');
			previous_link = null;
		}
        
		previous_link = target_a;
		previous_link.className =  previous_link.className  + " active";

		var B2E_TAM_Junction = '${B2E_TAM_Junction}';
		if(B2E_TAM_Junction){
			document.cookie = "IV_JCT=%2F" + B2E_TAM_Junction + "; path=/";
		}
	}

	var previous_Folder = null;
	function clickFolder(e){
		//srcElement for IE target for other browsers
		var target_div = (e&&(e.target||e.srcElement))||(event&&(event.srcElement||event.target))||this;
		//沒有連結(應該不會)
		if(!target_div || target_div.tagName != "DIV"){
			return;
		}
		var sub_menu = target_div.nextSibling;
		//沒有子選單
		if(!sub_menu || sub_menu.tagName != "UL"){
			return;
		}
		if(target_div.className == "open_folder"){
			target_div.className = "";
			sub_menu.style.display="none";
			if(previous_Folder && target_div == previous_Folder){
				previous_Folder = null;
			}
			return;
		}

		if(previous_Folder){
			previous_Folder.className = "";
			previous_Folder.nextSibling.style.display="none";
			previous_Folder = null;
		}

		target_div.className = "open_folder";
		sub_menu.style.display = "";
		if(!openAllNode){
			previous_Folder = target_div;
		}

		var targetOffsetHeight = target_div.offsetHeight;

		var target_div_height = target_div.offsetHeight;
		sub_menu.style.paddingTop = (target_div_height/2)+"px";
		sub_menu.style.marginTop = ((-1)*target_div_height/2)+"px";

		var open_subMenu_lastChild = sub_menu.lastChild;
		open_subMenu_lastChild.style.backgroundPositionY = ((open_subMenu_lastChild.offsetHeight/2)-1)+"px";

		menutree.scrollTop = target_div.offsetTop-(target_div_height*2);

		return;


		resize();
	}



	function showNotifyMsg(msgObj){
		if(bottomFrame.contentWindow && bottomFrame.contentWindow.showNotifyMsg){
			bottomFrame.contentWindow.showNotifyMsg(msgObj);
		}
	}
	function clearNotifyMsg(){
		if(bottomFrame.contentWindow && bottomFrame.contentWindow.clearNotifyMsg){
			bottomFrame.contentWindow.clearNotifyMsg();
		}
	}
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
	setEventObserve(document , "dragstart" ,stopEventPop );	//關閉拖曳
	setEventObserve(document , "selectstart" , stopEventPop );	//關閉選取
	setEventObserve(window , "resize" ,  resize );
	
	window.setInterval(function(){ if(document.body.scrollTop) { document.body.scrollTop = 0; }  } , 3000 );
	
</script>

</body>
</html>