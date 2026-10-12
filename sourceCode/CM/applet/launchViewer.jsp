<?xml version="1.0" encoding="utf-8"?><%
	String URL = request.getRequestURL().toString();
	URL = URL.replace("http:","https:");
	int idx = URL.lastIndexOf("/");
	String codebase = URL.substring(0, idx);
	response.setHeader("Content-Disposition", "filename=\"TiffViewer.jnlp\";");
	response.setContentType("application/x-java-jnlp-file");
%><jnlp spec="6.0+" codebase="<%=codebase%>">
  <information>
    <title>TiffViewerApp</title>
    <vendor>CathayLife Insurance.</vendor>
  </information>
  <security>
      <all-permissions/>
  </security>
  <resources>
  	<j2se version="1.8+"/>
    <jar href="TiffViewerApp.jar"/>
  </resources>
  <application-desc main-class="com.cathay.jaws.viewer.TiffViewerApp">
  	<argument>debug=true</argument>
	<argument>port=32002</argument>
	<argument>allowDomains=.cathaylife.com.tw</argument>
	<argument>contextUrl=https://<%=request.getHeader("Host")%>/ZRWeb/FileDownload</argument>
	<argument>width=800</argument>
	<argument>height=960</argument>
  </application-desc>
  <update check="always" policy="always"/>
</jnlp> 