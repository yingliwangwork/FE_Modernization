<!DOCTYPE HTML>
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ page import="com.cathay.common.service.authenticate.*" %>
<%@ page import="com.cathay.common.trx.UCData" %>
<%@ page import="com.cathay.zz.f0.bo.ZZF0_0100_bo" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ taglib prefix="CXL" uri="/CXL" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>
<head>
<meta http-equiv="X-UA-Compatible" content="text/html; charset=big5; IE=edge"; />
<!-- <%-- csCommon會引入沒有用的js檔案，採用HTML註解使其失效 --%>
<CXL:csCommon trace="false" htmlBaseName="htmlBase" cssBaseName="cssBase" imageBaseName="imageBase" dispatcherName="dispatcher" /> -->
<%

	if(java.io.File.separator.equals("/")){
		imageBase = "/CXLDocs/images";
	}

	com.igsapp.wibc.dataobj.Context.ResponseContext resp = (com.igsapp.wibc.dataobj.Context.ResponseContext)request.getAttribute("$Attribute.responseContext");
	com.igsapp.wibc.dataobj.html.HttpSessionContext sessionCtx = new com.igsapp.wibc.dataobj.html.HttpSessionContext(session);
	UserObject uObj = (UserObject) sessionCtx.getValue(UCData.USER_OBJECT);
	String sEmpName = uObj.getEmpName();
	if (sEmpName==null) {
		sEmpName = "";
	}
	
	boolean hasNews = false;

	String todayMMDD = (new SimpleDateFormat("MM/dd")).format(new Date());
	
	List dataList = null;
	
	if(resp!=null){
		//舊版的最新消息
		if(resp.getOutputData("newsList")!=null){
			ZZF0_0100_bo newsList = (ZZF0_0100_bo)resp.getOutputData("newsList");
			if(newsList.hasNext()){
				dataList = new ArrayList();
				hasNews = true;
				while(newsList.hasNext()) {
					newsList = newsList.next();
					HashMap hmNews = new HashMap();
					String strDate = newsList.getSTART_DATE();
					if(strDate==null || strDate.length()<10){
						strDate = "";
					}else{
						strDate = strDate.substring(strDate.indexOf("-")+1, strDate.length()).replace('-', '/');
					}
					hmNews.put("START_DATE" , strDate );
					hmNews.put("isNew" , new Boolean(strDate.equals(todayMMDD)) );
					
					hmNews.put("LEVEL" , newsList.getLEVEL() );
					hmNews.put("TITLE" , newsList.getTITLE() );
					hmNews.put("DESCRIPTION" , newsList.getDESCRIPTION() );
					hmNews.put("URL_LINK" , newsList.getURL_LINK() );
					hmNews.put("MESSAGE_NO" , newsList.getMESSAGE_NO() );
					hmNews.put("DIV_SHORT_NAME" , newsList.getDIV_SHORT_NAME() );
					// [20200506]新增欄位LINK_TITLE/LINK_URL
					hmNews.put("LINK_TITLE" , newsList.getLINK_TITLE() );
					hmNews.put("LINK_URL" , newsList.getLINK_URL() );
                    dataList.add(hmNews);
				}
			}
		//新版的最新消息
		}else if(!hasNews && resp.getOutputData("newsList2")!=null && resp.getOutputData("newsList2") instanceof List){
			List newsList2 = (List) resp.getOutputData("newsList2");
			if(newsList2.size()>0)	{
				dataList = newsList2;
				hasNews = true;
				for( int i = 0 ; i < newsList2.size() ; i+=1 ) {
					HashMap hmNews = (HashMap) newsList2.get(i);
					String strDate = hmNews.get("START_DATE")!=null?hmNews.get("START_DATE").toString():"" ;
					if(strDate.length()<10){
						strDate = "";
					}else{
						strDate = strDate.substring(strDate.indexOf("-")+1, strDate.length()).replace('-', '/');
					}
					hmNews.put("START_DATE" , strDate );
					hmNews.put("isNew" , new Boolean(strDate.equals(todayMMDD)) );
				}
			}
		}
	}
	
	
    //--------------------------------------------
	//  處理頁面風格設定
	//--------------------------------------------
	String strSysCode = (String) pageContext.getAttribute("syscode");
	String style_css_file = "";
	try{
        String sys_theme = com.cathay.common.util.FieldOptionList.getName("ZZ", "sys_theme" , strSysCode );
        if(sys_theme != null && !sys_theme.trim().equals("")){
        	if("blue".equalsIgnoreCase(sys_theme)){
        		style_css_file = "/skeletons/sys_news-blue.css";
        	}
        }
    }catch(Exception e){
        System.out.println("===sys_news.jsp theme Exception ===>" + e.getMessage());
    }
    if(style_css_file == null || "".equals(style_css_file.trim())){
    	if(org.apache.commons.lang.ArrayUtils.contains(new String[]{"EH","NC","ND","NK","NJ","NF"}, strSysCode)){
    		style_css_file = "/skeletons/sys_news-blue.css";
    	}else{
    		style_css_file = "/skeletons/sys_news.css";
    	}
    }
    
    
    pageContext.setAttribute("hasNews", hasNews);
    pageContext.setAttribute("dataList", dataList);
    // 頁面載入 CSS 檔案
    pageContext.setAttribute("style_css_file", style_css_file);


    try {
        // 透過中文代碼設訂顯示代辦事項
        Map fieldOptions = com.cathay.common.util.FieldOptionList.getFieldOptions("ZZ", "sysNews_" + strSysCode);

        if (fieldOptions != null) {
            if (fieldOptions.containsKey("extendsListURL")) {

                Map<String, Integer> prepareMap = new HashMap<String, Integer>();

                Map<String, String[]> relationRoleMap = null;

                if (fieldOptions.containsKey("relationRoleGroup")) {
                    relationRoleMap = new HashMap<String, String[]>();
                    String relationRoleGroupsStr = (String) fieldOptions.get("relationRoleGroup");
                    String[] relationRoleGroups = relationRoleGroupsStr.split("><");

                    for (String relationRoleGroup : relationRoleGroups) {
                        String[] relationRoles = relationRoleGroup.split(",");
                        for (String relationRole : relationRoles) {
                            relationRoleMap.put(relationRole, relationRoles);
                        }
                    }
                }

                Iterator iter = uObj.getRoles().keySet().iterator();
                while (iter.hasNext()) {
                    String role = (String) iter.next();
                    if (fieldOptions.containsKey(role)) {
                        boolean isAppend = true;
                        if (relationRoleMap != null) {
                            if (relationRoleMap.containsKey(role)) {// 取得相關連的角色
                                String[] relationRoles = relationRoleMap.get(role);
                                for (String relationRole : relationRoles) {
                                    if (prepareMap.containsKey(relationRole)) {// 相關連的角色已進行設定寬度時，此角色高度不進行設定
                                        isAppend = false;
                                        break;
                                    }
                                }
                            }
                        }
                        if (isAppend) {
                            prepareMap.put(role, Integer.valueOf((String) fieldOptions.get(role)));
                        }
                    }
                }

                int extendsListShowHeight = 0;
                if (fieldOptions.containsKey("extendsBaseHeight")) {
                    extendsListShowHeight = Integer.valueOf((String) fieldOptions.get("extendsBaseHeight"));
                }
                Iterator<String> prepareIter = prepareMap.keySet().iterator();
                while (prepareIter.hasNext()) {
                    String key = prepareIter.next();
                    extendsListShowHeight += prepareMap.get(key);
                }

				pageContext.setAttribute("extendsTitle", fieldOptions.get("extendsTitle"));
				pageContext.setAttribute("extendsListURL", dispatcher+fieldOptions.get("extendsListURL"));
                pageContext.setAttribute("extendsListShowHeight", extendsListShowHeight);

            }
        }
    } catch (Exception e) {
    }

%>
<title></title>
<link rel="stylesheet" type="text/css" href="${cssBase}${style_css_file}" >

<script type="text/JavaScript">
	function openDetail(a, b){
		var win = window.open(a,b,"width=600,height=400,scrollbars=1");  
	}
</script>
</head>
<body>

    <div id="fixedDiv">
    	<div id="page_top">
    	  <div class="float_left">歡迎光臨<span><%=sEmpName%></span>使用本系統!</div>
    	</div>

<c:if test="${not empty extendsListURL && extendsListShowHeight>0}">
		<div id="contents_header" class="page_ui_contents"><span id="sub_title"><c:out value="${extendsTitle}"/><span></div>
		<div id="contents_scrollable" class="page_ui_contents" style="padding: 3px;">
			<div><iframe src="<c:out value="${extendsListURL}"/>" height="<c:out value="${extendsListShowHeight}"/>px" width="100%" name="center" frameborder="0" scrolling="no"></iframe></div>
		</div>
</c:if>

        <div id="contents_header" class="page_ui_contents"><span id="sub_title">業務通告訊息<span></div>
    	<ul  id="contents_fixed" class="page_ui_contents" ></ul>
    </div>
    
 	<div  id="contents_scrollable" class="page_ui_contents" >
    <!-- ------------------------------------------------------------------------------------------- --> 
    <c:choose>
    <c:when test='${not hasNews}'>
        <div class="no-news"><font>目前無最新消息!!</font><%-- 如果沒有最新消息的標題--%></div></c:when>
    <c:otherwise><c:forEach items='${dataList}' var='news_data'>
    <div class="content">
        <div class="news priority${news_data.LEVEL}<c:if test='${news_data.isNew == true}'> breaking_news</c:if>" Priority="${news_data.LEVEL}">
            <div class="news_date">${news_data.START_DATE}</div>
            
            <div class="new_tag">New</div>
            <div class="news_header">
                <span class="news_title">${news_data.TITLE}</span>
                <c:if test='${news_data.LINK_TITLE != null && news_data.LINK_TITLE != "" }'>
                	&ensp;<a href='${news_data.LINK_URL}' class="detail_link" target="_blank">${news_data.LINK_TITLE}</a>
                </c:if>
                <font class="news_div">&lt; ${news_data.DIV_SHORT_NAME} &gt;</font>
            </div>
            <div class="news_detail">
                ${news_data.DESCRIPTION}
                <c:if test='${news_data.URL_LINK != null && news_data.URL_LINK != "" }'><a href='javascript: openDetail("${news_data.URL_LINK}","${news_data.MESSAGE_NO}")' class="detail_link">詳細內容...</a></c:if>
            </div>
        </div>
    </div>
	</c:forEach></c:otherwise>
    </c:choose>
    <!-- ------------------------------------------------------------------------------------------- -->
    </div>
    
    <div class="border" id="border-top"></div>
    <div class="border" id="border-left"></div>
    <div class="border" id="border-right"></div>

<script type="text/javascript">   

	/*
		子系統別：<c:out value="${syscode}"/>
	*/
	setEventObserve(document , "dragstart" ,stopEventPop );	//關閉拖曳
	setEventObserve(document , "selectstart" , stopEventPop );	//關閉選取 

	var fixed_area = document.getElementById("contents_fixed");
	var datas_parent = document.getElementById("contents_scrollable");
	var test_child = datas_parent.firstChild;
	while(test_child){
		var current_child = test_child;
		test_child = test_child.nextSibling;
		if(current_child.tagName == "LI"){
			var table = current_child.firstChild;
			while(table && table.tagName != "TABLE"){
				table = table.nextSibling;
			}
			if(table && table.getAttribute("Priority") == "1"){
				fixed_area.appendChild(current_child);
			}
		}
	}
	if(!fixed_area.hasChildNodes){
		fixed_area.style.display = "none";
	}
	var fixedDivHeight = document.getElementById("fixedDiv").offsetHeight;
	var documentHeight = mainTableHeight = Math.max(document.body.scrollHeight, document.documentElement.scrollHeight);

	if (fixedDivHeight > documentHeight || datas_parent.offsetTop > 4 ) {
		document.getElementById("fixedDiv").style.position = "static";
		
	}else{
		datas_parent.style.paddingTop = fixedDivHeight + "px";
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
	function stopEventPop(e){
		 if ( e && e.preventDefault ) //(W3C) 
		 e.preventDefault(); 
		 else //for IE
		 window.event.returnValue = false; 
		 return false;
	 }
	
</script>
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