<%

String gaid = (com.cathay.common.util.LoginUtil.getHostType() == com.cathay.common.util.LoginUtil.PRODUCTION)
				? "UA-47155404-1" : "UA-47858788-1";

	String analyticDataStr_gatc = null;
	try {
		com.igsapp.wibc.dataobj.html.HttpResponseContext resp_gatc = new com.igsapp.wibc.dataobj.html.HttpResponseContext(request);

		java.util.Map<String, Object> analyticData = (java.util.Map<String, Object>)resp_gatc.getOutputData("$AnalyticData");

		if (analyticData != null) {
			StringBuilder sb_gatc = new StringBuilder();
			if (analyticData.containsKey("product")) {
				sb_gatc.append("var product = ").append(com.cathay.common.im.util.VOTool.toJSON(analyticData.get("product"))).append(";");
			} else {
				sb_gatc.append("var basket = ").append(com.cathay.common.im.util.VOTool.toJSON(analyticData)).append(";");
			}
			analyticDataStr_gatc = sb_gatc.toString();
		}
	} catch (Exception me) {
	}

%>
<!-- Google Analytics Tracking Code, GATC -->
<script type="text/javascript">
	(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)})(window,document,'script','//www.google-analytics.com/analytics.js','ga');
	ga('create', '<%=gaid%>', 'cathaylife.com.tw', {'allowLinker': true});
	ga('send', 'pageview');

<% if (analyticDataStr_gatc != null) { %>
	<%-- GOOGLE 聯播網 - 網路投保追蹤碼 --%>
	var gatc = new function(){
		return {
			windowAddEventListener:function(eventName, func){
				if(window.addEventListener){
					window.addEventListener(eventName, func, false);
				} else if (window.attachEvent){
					window.attachEvent("on"+eventName, func);
				} else {
					window[eventName] = func;
				}
			}
		};
	};

	<%=analyticDataStr_gatc%>

	gatc.windowAddEventListener('load', function(){
		var s = document.createElement('script');
			s.type = 'text/javascript';
			s.async = true;
			s.src = ('https:'==document.location.protocol?'https://':'http://') + 'ap-sonar.sociomantic.com/js/2010-07-01/adpan/mydress-tw';
		var x = document.getElementsByTagName('script')[0];
			x.parentNode.insertBefore( s, x );
	});

<% } %>
</script>