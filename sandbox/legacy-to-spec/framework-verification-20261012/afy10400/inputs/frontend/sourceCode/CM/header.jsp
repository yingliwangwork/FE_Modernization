<%@ page import="java.util.*" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="com.igsapp.wibc.dataobj.Context.*" %>
<%@ page import="com.igsapp.wibc.dataobj.html.*" %>
<%@ page import="com.cathay.common.service.ConfigManager" %>
<%@ page import="com.cathay.common.service.authenticate.*" %>
<%@ page import="com.cathay.common.util.FieldOptionList"%>

<%@ page import="com.igsapp.db.DataSet"%>
<%@ page import="com.cathay.db.impl.DynamicDataSet"%>
<%@ page import="com.cathay.common.im.util.VOTool"%>
<%@ page import="com.cathay.zz.z0.module.ZZ_Z0Z001"%>

<%@ page import="org.apache.commons.lang.ObjectUtils"%>
<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="cathay" uri="/WEB-INF/tlds/cathay.tld" %>
<%@ taglib prefix="input" uri="/WEB-INF/tlds/taglibs-input.tld" %>
<%@ taglib uri="/CXL" prefix="CXL" %>

<CXL:csCommon trace="false" htmlBaseName="htmlBase" 
                            cssBaseName="cssBase" 
                            imageBaseName="imageBase" 
                            dispatcherName="dispatcher" />
                            
                            
<script type='text/javascript'>
	/* when counts chinese letter bytes, 1 letter counts 3 bytes  */
	window.charCountsByte = '<%=ConfigManager.getProperty("ebaf.JSP_CHAR_LENGTH","2") %>';
	if(!charCountsByte.match(/^[1-9][0-9]*$/)){
		window.charCountsByte = 2;
	}else{
		window.charCountsByte = parseInt(window.charCountsByte,10);
	}
	
	
	if(window.utility){
<c:if test="${not empty requestTimeHandleUUID}">
		if(utility.keepResponseTimeEndParameters){
			var headerRegisterOnloadFunction = function(){
				utility.keepResponseTimeEndParameters('${requestTimeHandleUUID}');
			};
			if (typeof window.addEventListener != "undefined") {
				window.addEventListener('load', headerRegisterOnloadFunction);
			}else{
				window.attachEvent('onload', headerRegisterOnloadFunction);
			}
		}
</c:if>
<c:if test="${not empty eBAF_loginPlatformInfo || not empty eBAF_loginSystemInfo || not empty eBAF_UserObject_Flag || not empty platformDispatcher}">
		if(utility.keep_eBAF_parameter){
			var opt = {};
			<c:if test="${not empty eBAF_loginPlatformInfo}">opt['eBAF_loginPlatformInfo']='<c:out value="${eBAF_loginPlatformInfo}"/>'</c:if>
			<c:if test="${not empty eBAF_loginSystemInfo}">opt['eBAF_loginSystemInfo']='<c:out value="${eBAF_loginSystemInfo}"/>'</c:if>
			<c:if test="${not empty eBAF_UserObject_Flag}">opt['eBAF_UserObject_Flag']='<c:out value="${eBAF_UserObject_Flag}"/>'</c:if>
			<c:if test="${not empty platformDispatcher}">opt['platformDispatcher']='<c:out value="${platformDispatcher}"/>'</c:if>
			utility.keep_eBAF_parameter(opt);
		}
</c:if>
	}
</script>
<%
       try {
       
    	HttpResponseContext responseContextRef = new HttpResponseContext(request);
   		String beanName = responseContextRef.getBeanName();
   		String headerRequestFuncId = "";
   		if(StringUtils.isNotBlank(beanName)) {
   			headerRequestFuncId =  StringUtils.remove(beanName, "_");
   		}
   		
   		if(StringUtils.isBlank(headerRequestFuncId)) {
   			String headerRequestUrl = request.getRequestURL().toString();
   			String[] headerUrls = headerRequestUrl.split("/");
   			for(String headeritStr : headerUrls) {
   				if(StringUtils.contains(headeritStr, ".jsp")) {
   					headerRequestFuncId =  StringUtils.remove(headeritStr, ".jsp");
   					break;
   				}
   			}
   		}

        if (StringUtils.isNotBlank(headerRequestFuncId)) {
            
			List<Map> headerFindList = new ZZ_Z0Z001().getFuncInfo(headerRequestFuncId);
			
			if (headerFindList!=null && !headerFindList.isEmpty()) {
				Map headerfMap = headerFindList.get(0);
				pageContext.setAttribute("headerRequestFuncId", headerRequestFuncId);
				pageContext.setAttribute("isWaterMark", "Y".equals(ObjectUtils.toString(headerfMap.get("IS_WATERMARK"))));
				String headerPdCtrl = ObjectUtils.toString(headerfMap.get("PD_CTRL"));
				
				if ("Y".equals(headerPdCtrl)) {
%>		

<style>
@media print {
	body>* {
		display: none !important;
	}
	body::after {
		content:
			'\4f9d\64da\8cc7\5b89\653f\7b56\ff0c\4e0d\958b\653e\5217\5370\529f\80fd';
		display: block !important;
	}
}
</style>

<script>
if (typeof fpcsAlertMsgs !== 'object') {

	var lastfpcsRecordText = '';
	
	var fpcsAlertMsgs = {
		print : '\u4f9d\u64da\u8cc7\u5b89\u653f\u7b56\uff0c\u4e0d\u958b\u653e\u5217\u5370\u529f\u80fd',
		beforeprint : '\u4f9d\u64da\u8cc7\u5b89\u653f\u7b56\uff0c\u4e0d\u958b\u653e\u5217\u5370\u529f\u80fd', 
		copy : '\u4f9d\u64da\u8cc7\u5b89\u653f\u7b56\uff0c\u9700\u7559\u5b58\u8907\u88fd\u8ecc\u8de1\uff0c\u8907\u88fd\u8acb\u6539\u7528Ctrl+Q', 
		cut : '\u4f9d\u64da\u8cc7\u5b89\u653f\u7b56\uff0c\u4e0d\u958b\u653e\u526a\u4e0b\u529f\u80fd',
		selectAll : '\u4f9d\u64da\u8cc7\u5b89\u653f\u7b56\uff0c\u4e0d\u958b\u653e\u5168\u9078\u529f\u80fd',
		save : '\u4f9d\u64da\u8cc7\u5b89\u653f\u7b56\uff0c\u4e0d\u958b\u653e\u9801\u9762\u5132\u5b58\u529f\u80fd',
	};
		
	fpcsDoAddEventListener( window , 'load' ,function(){
		fpcsDoAddEventListener(document.body , 'contextmenu' , fpcsStopEventActions  );
		fpcsDoAddEventListener(document.body , 'print' , fpcsStopEventActions  );
		fpcsDoAddEventListener(document.body , 'beforeprint' , fpcsStopEventActions  );
		fpcsDoAddEventListener(document.body , 'copy' , validateCopy  );
		fpcsDoAddEventListener(document.body , 'cut' , fpcsStopEventActions  );
		
		
		fpcsDoAddEventListener(window , 'keydown' , function(e){
			if(e.ctrlKey){
				if( e.keyCode == 65 || e.keyCode == 88 || e.keyCode == 	83 || e.keyCode == 80){
					stopEventActions(e);
					e.keyCode == 88 && fpcsAlertMsgs['cut'] && alert(fpcsAlertMsgs['cut']);
					e.keyCode == 65 && fpcsAlertMsgs['selectAll'] && alert(fpcsAlertMsgs['selectAll']);
					e.keyCode == 83 && fpcsAlertMsgs['save'] && alert(fpcsAlertMsgs['save']);
					e.keyCode == 80 && fpcsAlertMsgs['print'] && alert(fpcsAlertMsgs['print']);
					return false;
				} 
			} 
		});
		
		function validateCopy(e) { 
		
			var fpcsSelectedText = fpcsGetSelectionText();
			
			fpcsSelectedText = fpcsSelectedText.replace(/\s+/g, ' ');
			
			var fpcsRecordText = fpcsSelectedText;
			
			if(fpcsRecordText.length > 0 && lastfpcsRecordText !== fpcsRecordText) {<%-- write securitylog --%>
				
				setTimeout(function () {
					lastfpcsRecordText = "";
    			}, 60000);
				
				lastfpcsRecordText = fpcsRecordText;
				
				if (fpcsRecordText.length > 5000) {
					fpcsRecordText = fpcsRecordText.substr(0, 4997) + '...';
				}
				
				fpcsRecordText = fpcsRecordText.replace(/\%/g,"%25");
	            fpcsRecordText = fpcsRecordText.replace(/\#/g,"%23");
	            fpcsRecordText = fpcsRecordText.replace(/\&/g,"%26");
	            fpcsRecordText = fpcsRecordText.replace(/\ /g,"%20");
	            fpcsRecordText = fpcsRecordText.replace(/\+/g,"%2B");
	            fpcsRecordText = fpcsRecordText.replace(/\?/g,"%3F");
	            fpcsRecordText = fpcsRecordText.replace(/\=/g,"%3D");
				
				var fpcsImgReq = document.createElement("img");
				fpcsImgReq.setAttribute('src', 
					'/ZZWeb/servlet/HttpDispatcher/ZZM0_0105/ctrlMsavelog?COPY_CONTENT='
					+ fpcsRecordText + '&FUNC_ID=' + '<%=headerRequestFuncId%>' + '&COPY_LENGTH=' + fpcsSelectedText.length + '&TS=' + new Date().getTime()
				);
			}
		}
		
		function fpcsGetSelectionText() {
		
			var fpcsGetSelectText = '';
			
			if(window.getSelection) { // all browser, except IE before 9
				
				if(document.activeElement &&
					(document.activeElement.tagName.toLowerCase() == 'textarea' )){
					var fpcsText = document.activeElement.value;
					fpcsGetSelectText = fpcsText.substring(document.activeElement.selectionStart,
												document.activeElement.selectionEnd);
				} else {
					var fpcsRange = window.getSelection();
					fpcsGetSelectText = fpcsRange.toString();
				}
			
			} else {
			
				var fpcsRange = document.selection.createRange();
				fpcsGetSelectText = fpcsRange.text;
				
			}
				
			return fpcsGetSelectText;	
		
		}
		
		function stopEventActions(e){
			forceStopEvent(e);
			showStopAlertMessage(e);
			return false;
		}
		
		function forceStopEvent(e) {
			if(e && e.stopPropagation){
				e.stopPropagation();
				e.preventDefault();
			}else if( e && ( e.cancelBubble !== undefined || e.cancelBubble !== null )){
				e.cancelBubble = true;
				e.returnValue = false;
			}
		}
		
		function showStopAlertMessage(e) {
			if(e.type && fpcsAlertMsgs[e.type]){ alert(fpcsAlertMsgs[e.type]); }
		}		
	});
	function fpcsStopEventActions(e){
		if(e && e.stopPropagation){
			e.stopPropagation();
			e.preventDefault();
			if(e.type && fpcsAlertMsgs[e.type]){ alert(fpcsAlertMsgs[e.type]); }
		}else if( e && ( e.cancelBubble !== undefined || e.cancelBubble !== null )){
			e.cancelBubble = true;
			e.returnValue = false;
			if(e.type && fpcsAlertMsgs[e.type]){ alert(fpcsAlertMsgs[e.type]); }
		}
		return false;
	}
	
	function fpcsDoAddEventListener( element , eventName , func  ){
		if( !element || ( element != window && element != document && !element.tagName)) { return; }
		if(element.addEventListener){
			element.addEventListener(eventName , func , true );
		}else if(element.attachEvent){
			element.attachEvent('on'+(eventName.toLowerCase()) , func);
		}else{
			element['on'+(eventName.toLowerCase())] = func;
		}
	}
}
</script>
			<%
			    }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<%	
	try{
		String str_wm = null;
		if(session != null){
			UserObject userObj_wm = (UserObject)session.getAttribute("$Data.$coreSys$UserObject");
			if(userObj_wm!=null){
				str_wm = userObj_wm.getCATHAY_NO();
				if(str_wm == null){
					str_wm = userObj_wm.getEmpName();
				}
			}
		}
		
		if (str_wm == null) {
			str_wm = "";
		}
		
		pageContext.setAttribute("watermark_datetime", new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()));
		pageContext.setAttribute("watermark_escapeHtml_txt", StringEscapeUtils.escapeHtml(str_wm));
		pageContext.setAttribute("watermark_txt", str_wm);
    } catch (Exception e) {
        e.printStackTrace();
    }
	
	//如果是 w3.cathaylife.com.tw 站台，取得難字 CDN URL
	try {
		String clientheaderhost = request.getHeader("clientheaderhost");
		if(StringUtils.isNotBlank(clientheaderhost) && clientheaderhost.contains("w3.cathaylife.com.tw")){
			String internetFontUrl  = FieldOptionList.getName("PT", "STATIC_FILE_URL", "INTERNET_FONT");
			pageContext.setAttribute("internetFontUrl", internetFontUrl);
		}
	} catch (Exception e) {
		e.printStackTrace();
	}
	
%>

<script type='text/javascript' src='${htmlBase}/CM/js/ui/watermark-js-plus.js'></script>
<style>
@font-face{
	font-family: 'EUDC';
	src:  <c:if  test="${not empty internetFontUrl}">
		  url('${internetFontUrl}eudc.woff2') format("woff2"),
		  url('${internetFontUrl}eudc.ttf') format("truetype"),
		  </c:if>
	      url('${pageContext.request.contextPath}/hanlinks/eudc.woff2') format("woff2"),
	      url('${pageContext.request.contextPath}/hanlinks/eudc.ttf') format("truetype");
	font-weight:normal;
	font-style:normal;
}
</style>
<script type='text/javascript'>
	var is_same_origin = false;
	try{
		is_same_origin = window.top.document.domain == window.document.domain;
	}catch (err) {
		window.console && console.log('==is_same_origin==error==' + err.message);
	}
	if(is_same_origin && window.name == 'mainFrame'){
		window.top.watermark_funcIds = [];
		window.top.watermark_root = window;
	}
	<c:if test="${isWaterMark}">
	
	new function(){

		var root_wm = window;
		if(is_same_origin){
			if(window.top.watermark_root){
				root_wm = window.top.watermark_root;
			}else{
				window.top.watermark_root = window.top;
				root_wm = window.top;
			}
		}
		if(!root_wm.watermark){
			var _script = document.createElement('script');
			_script.setAttribute('type','text/javaScript');
			_script.setAttribute('src','${htmlBase}/CM/js/ui/watermark-js-plus.js');
			root_wm.document.head.appendChild(_script);
		}
		var headerWatermarkOnloadFunction = function(){

			try {
				if(!root_wm.watermark_funcIds){
					root_wm.watermark_funcIds = [];
				}
				
				root_wm.watermark_funcIds.push('<c:out value="${headerRequestFuncId}"/>');
				window.console && console.log(root_wm.watermark_funcIds);
				var watermark_personal_info_txt;
				if("function" === typeof(DOMParser)){
					watermark_personal_info_txt = new DOMParser().parseFromString('${watermark_escapeHtml_txt}', "text/html").documentElement.textContent;
				}else{
					watermark_personal_info_txt = '${watermark_txt}';
				}
				
				var watermarkPlus = new WatermarkPlus.Watermark({
					"contentType" : "multi-line-text",
					"content" : watermark_personal_info_txt + "\n${watermark_datetime}",
					"width" : 190,
					"height" : 85,
					"lineHeight": 20,
					"fontColor" : "#000",
					"fontWeight" : "normal",
					"fontSize" : "16px",
					"fontFamily" : "Microsoft JhengHei",
					"rotate" : 17,
					"globalAlpha" : 0.07,
					"mutationObserve" : true,
					"monitorProtection" : true,
					"layout" : "grid",
					"gridLayoutOptions" : { rows: 2, cols: 2, gap: [-18, -8], matrix: [[1, 0], [0, 1]] }
				});
				watermarkPlus.create();
				
			}catch(err) {
				window.console && console.log('==headerWatermark==onload==error==' + err.message);
			}
		};
		
		var headerWatermarkOnberforeunloadFunction = function(){
			try {
				if(!root_wm.watermark_funcIds ){
					return;
				}
				var wmfuncIndex = root_wm.watermark_funcIds.indexOf('<c:out value="${headerRequestFuncId}"/>');
				if(wmfuncIndex == -1){
					return;
				}
				root_wm.watermark_funcIds = root_wm.watermark_funcIds.splice(wmfuncIndex, 1);
				window.console && console.log(root_wm.watermark_funcIds);
			}catch(err) {
				window.console && console.log('==headerWatermark==onberforeunload==error==' + err.message);
			}
		};
		
		if (typeof window.addEventListener != "undefined") {
			window.addEventListener('load', headerWatermarkOnloadFunction);
			window.addEventListener('berforeunload', headerWatermarkOnloadFunction);
		}else{
			window.attachEvent('onload', headerWatermarkOnberforeunloadFunction);
			window.attachEvent('onberforeunload', headerWatermarkOnberforeunloadFunction);
		}
		
	}();
	</c:if>
</script>