<%@ page import="java.util.*" %>
<%@ page import="com.igsapp.wibc.dataobj.Context.*" %>
<%@ page import="com.igsapp.wibc.dataobj.html.*" %>
<%

	ResponseContext respCtxt = (ResponseContext)request.getAttribute(HttpResponseContext.RESPONSE_CONTEXT_LOCATION);

	if(respCtxt == null) return;

	//取出自 trx putValue 中的值
	HttpTxContext txCxt = new HttpTxContext(session);  	

	Enumeration names = txCxt.getValueNames();
	Map txValues = new HashMap();

	while(names.hasMoreElements()){
		String name = (String)names.nextElement();
		txValues.put(name, txCxt.getValue(name));
	}

	respCtxt.addOutputData("_tx_context", txValues);

	//reset again (ref to AjaxFilter ext, the Data copy from ResponseContxt to Ajax output only
	//happens when invoking request.setAttribute(). So after we add more data to ResponseContext,
	//we need to trigger the copy action again.
	request.setAttribute(HttpResponseContext.RESPONSE_CONTEXT_LOCATION, respCtxt);

%>