<% 
com.igsapp.wibc.dataobj.html.HttpResponseContext msgResp 
    	= new com.igsapp.wibc.dataobj.html.HttpResponseContext(request);
    	
    com.cathay.common.bo.ReturnMessage msg;
  
     try{	
		 msg = (com.cathay.common.bo.ReturnMessage) msgResp.getOutputData(com.cathay.common.util.IConstantMap.ErrMsg);
	}catch(ClassCastException cce){
		msg = null;
	}	
	if(msg==null){
		 msg = new com.cathay.common.bo.ReturnMessage(0,"","","","","");
	}

 


%>
<script language="JavaScript">
<!--
msgs = new Array(<%=msg.getLength()%>);
<%
int msglen = msg.getLength();
int msgidx = 0;
String[][] showmsg = new String[msglen][7];

com.cathay.common.bo.ReturnMessage tmp=null;
while(msg.hasNext()){
	tmp=msg.next();
	
	showmsg[msgidx][0] = (tmp.getDisplayMsgDescs()!=null)?tmp.getDisplayMsgDescs():"";
	showmsg[msgidx][1] = (tmp.getMsgid()!=null)?tmp.getMsgid():"";
	showmsg[msgidx][2] = (tmp.getSysid()!=null)?tmp.getSysid():"";
	showmsg[msgidx][3] = (tmp.getType()!=null)?tmp.getType():"";
	showmsg[msgidx][4] = (tmp.getUrl()!=null)?tmp.getUrl():"";
	showmsg[msgidx][5] = tmp.getReturnCode()+"";
	showmsg[msgidx][6] = (tmp.getDisplayException()!=null)?tmp.getDisplayException():"";
%>

msgs[<%=msgidx%>] = new Array("<%=showmsg[msgidx][0]%>","<%=showmsg[msgidx][1]%>","<%=showmsg[msgidx][2]%>","<%=showmsg[msgidx][3]%>","<%=showmsg[msgidx][4]%>","<%=showmsg[msgidx][5]%>","<%=showmsg[msgidx][6]%>");

<%
	msgidx++;
}
%>
//?????Alert
function alertMessages(){
	var displayMessage = "";

	for( var varindex=0;varindex<msgs.length;varindex++){
		if (msgs[varindex][6] == ""){
			if (msgs[varindex][5] != "0"){//new
				displayMessage+="回傳碼:"+msgs[varindex][5]+"\n";	//new
				displayMessage+="訊息說明:\n"+msgs[varindex][0]+"\n\n";	//new
			}	//new		
//			if ((msgs[varindex][5] != "0") || (msgs[varindex][0] != "")){
//				displayMessage+="???:"+msgs[varindex][5]+"\n";	
//				displayMessage+="????:\n"+msgs[varindex][0]+"\n\n";	
//			}
		}else{
			if ((msgs[varindex][6] != "") || (msgs[varindex][2] != ""))
			{
				displayMessage+="異常原因:"+msgs[varindex][6]+"\n";
				displayMessage+="\n程式ID:"+msgs[varindex][2]+"\n\n";				
			}
		}
	}
	
	if (displayMessage != "")
		alert(displayMessage);
		
}

var msgindex = 0;

function nextMessage(){
		var idx = msgindex+1;
		if (idx >= msgs.length){
			msgindex = msgs.length-1;
		}else if(idx <= 0){
			msgindex = 0;
		}else{
			msgindex++;
		}
		displayMessage();
}

function prevMessage(){
		var idx = msgindex-1;
		if (idx >= msgs.length){
			msgindex = msgs.length-1;
		}else if(idx <= 0){
			msgindex = 0;
		}else{
			msgindex--;
		}
		displayMessage();
}

function displayMessage(){
    alertMessages();
}

//-->
</script>