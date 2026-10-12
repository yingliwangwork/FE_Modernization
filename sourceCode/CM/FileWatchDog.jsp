<%@ page language="java" contentType="text/html; charset=big5"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="org.apache.commons.lang.StringUtils"%>
<fmt:setBundle basename="TextResource" />
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<style>
#progressLoad{width:202px;height:21px;border:1px #DDDDDD solid;}
#progressLoading{position:absolute;z-index:2;height:13px;filter:progid:DXImageTransform.microsoft.gradient(gradienttype=1,startColorStr=#EEF5FC,endColorStr=#5399E3);background:#5399E3;}
#progressLoadText{color:'#8c8c8c'}
</style>

<script type="text/javascript" src="${pageContext.request.contextPath}/html/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/html/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/html/CM/js/RPTUtil.js"></script>
<script type="text/javascript">
<!--

	var timeUnitBySec = 1000;
	var times = [2, 3, 5, 10, 20, 30];		// 取得列印資料使用之時間間隔秒數
	var timesIndexMax = times.length-1;
	var StreamServeProcessInfo = {
		isGetPrintDataSuccess: false,
		isOccurError: false,
		occurErrorMsg: '',					// 錯誤訊息
		errorCount: 0,						// 錯誤件數
		executePrintRequestCount: 0,		// 列印資料請求次數
		executePrintRequestLimitCount: 16,	// 列印資料請求限制次數
		reportRequestCount: 0				// 報表請求數量
	};

	Event.observe(window, 'load', initApp);

	var getTime = function(timesIndex){
		if(timesIndexMax>timesIndex){
			timesIndex++;
		}
		return timesIndex;
	}

	function initApp(){
		executePrintData(0);
	}

	// 取得列印資料
	function getPrintData(){

		var encryptTempFileFullPath = '${encryptTempFileFullPath}';
		var enableWaterMark = '<c:out value="${enableWaterMark}" />';
		var params = {
			'checkStatus': '1',
			'encryptTempFileFullPath': encryptTempFileFullPath,
			'enableWaterMark': enableWaterMark
		};
		var url = '${pageContext.request.contextPath}/FileWatchDog';
		var isGetSuccess = false;
		new Ajax.Request( url,
			{
				parameters: params,
				asynchronous: false,
				onSuccess:function(XHR, resp){
					if(resp.checkStatus=='2'){
						isGetSuccess = true;
						StreamServeProcessInfo.isGetPrintDataSuccess = true;
						document.getElementById('memoBar').innerHTML = "已取得列印資料，等待ReportServer回應．．．";
						$('progressLoad').hide();
						$('progressLoadText').hide();
						var oForm = $('form1');
							oForm.action=url;
							oForm.insert(new Element('input', {'type':'hidden', 'name':'checkStatus', 'value': '2'}));
							oForm.insert(new Element('input', {'type':'hidden', 'name':'encryptTempFileFullPath', 'value': encryptTempFileFullPath}));
							oForm.insert(new Element('input', {'type':'hidden', 'name':'enableWaterMark', 'value': enableWaterMark}));
							oForm.submit();
					}
				}
			}
		);
		return isGetSuccess;
	}

	// 執行列印資料
	function executePrintData(timesIndex){

		if(timesIndex>0 && getPrintData()){
			return;
		}

		// 檢核是否超出取得列印資料請求限制次數
		if(StreamServeProcessInfo.executePrintRequestCount>=StreamServeProcessInfo.executePrintRequestLimitCount){
			StreamServeProcessInfo.isOccurError = true;
			document.getElementById('memoBar').innerHTML = "等待產生列印資料時間過長，請檢查系統Log";
			return;
		}

		var getWaitTime = times[timesIndex];
		var totleWaitTime = getWaitTime * timeUnitBySec;

		var memoBarMsg = (getWaitTime<10)?'0':'';
			memoBarMsg += getWaitTime +' '+"秒後將進行判斷列印資料是否產生，請稍候．．．";
		document.getElementById('memoBar').innerHTML = memoBarMsg;
		showProgressStatus(totleWaitTime);
		setTimeout(function(){executePrintData(getTime(timesIndex));}, totleWaitTime);

	}

	function showProgressStatus(totleWaitTime){
		var i=0;
		var titleLength = 200;

		function showProgressBar(){
			i++;
			var passSec = i*timeUnitBySec;
			var passPercentage = 1-((totleWaitTime-passSec)/totleWaitTime);
			$('progressLoading').style.width = titleLength * passPercentage + "px";
			var showLoadText = (i<10)?'0':'';
			showLoadText += i + ' sec';
			$('progressLoadText').innerHTML = showLoadText;
			if(passSec<totleWaitTime){setTimeout(showProgressBar, timeUnitBySec);}else{return;}
		}
		showProgressBar();
	}

//-->
</script>
</head>
<body>
	<html>
		<form id="form1" name="form1" method="post">
			<table width=100% height=100%>
				<tr><td align=center valign=middle>
				<span id='memoBar'></span><br>
				<div id="progressLoad" align='left'><div id="progressLoading"></div></div><div id="progressLoadText"></div>
			</td></tr></table>
		</form>
	</html>
</body>
</html>