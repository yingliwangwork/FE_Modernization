<%
	com.igsapp.wibc.dataobj.html.HttpResponseContext msgResp = new com.igsapp.wibc.dataobj.html.HttpResponseContext(request);

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
<script type="text/javaScript">
<!--
(function(){

	var msgs = new Array(<%=msg.getLength()%>);
	<%
	int msglen = msg.getLength();
	int msgidx = 0;
	String[][] showmsg = new String[msglen][7];

	com.cathay.common.bo.ReturnMessage tmp=null;
	while(msg.hasNext()){
		tmp=msg.next();
		String displayMsgDescs = tmp.getDisplayMsgDescs();
		if(displayMsgDescs!=null){
			displayMsgDescs = displayMsgDescs.replaceAll("\\r\\n", "<br>").replaceAll("\\n", "<br>").replaceAll("\\r", "<br>");
		}else{
			displayMsgDescs = "";
		}
		String msgid = tmp.getMsgid();
		if(msgid!=null){
			msgid = msgid.replaceAll("\\r\\n", "<br>").replaceAll("\\n", "<br>").replaceAll("\\r", "<br>");
		}else{
			msgid = "";
		}
		String displayException = tmp.getDisplayException();
		if(displayException!=null){
			displayException = displayException.replaceAll("\\r\\n", "<br>").replaceAll("\\n", "<br>").replaceAll("\\r", "<br>");
		}else{
			displayException = "";
		}
		showmsg[msgidx][0] = displayMsgDescs;
		showmsg[msgidx][1] = msgid;
		showmsg[msgidx][2] = (tmp.getSysid()!=null)?tmp.getSysid():"";
		showmsg[msgidx][3] = (tmp.getType()!=null)?tmp.getType():"";
		showmsg[msgidx][4] = (tmp.getUrl()!=null)?tmp.getUrl():"";
		showmsg[msgidx][5] = tmp.getReturnCode()+"";
		showmsg[msgidx][6] = displayException;
	%>

	msgs[<%=msgidx%>] = new Array("<%=showmsg[msgidx][0]%>".replace(/<br>/gi, "\n"),"<%=showmsg[msgidx][1]%>".replace(/<br>/gi, "\n"),"<%=showmsg[msgidx][2]%>","<%=showmsg[msgidx][3]%>","<%=showmsg[msgidx][4]%>","<%=showmsg[msgidx][5]%>","<%=showmsg[msgidx][6]%>");

	<%
		msgidx++;
	}
	%>
	
	$.cathay.displayMessage= function(){
		var alertMsg = "";

		for( var index = 0, length = msgs.length; index < length; index++ ){
			if (msgs[index][6] == ""){
				//when msgs[msgindex][5]==99 (that is the ReturnCode=99) then keep the return message to the message board under the web
				if ( msgs[index][5] != "0" && msgs[index][5] != "99" ){//new
					alertMsg += msgs[index][0] + "\n";
					
					if( msgs[index][1] ){
						alertMsg += '\n錯誤編號：\n';
						alertMsg += msgs[index][1];					
					}
				}
			}else{
				if ( msgs[index][6] || msgs[index][2] ){
					alertMsg+="異常原因: " + msgs[index][6] + "\n";
					alertMsg+="\n程式ID: " + msgs[index][2];
				}
			}
		}
		// 錯誤時才需 alert
		if ( alertMsg ){
			var msgWin = $.cathay.getMsgBoard();
			if( msgWin ){
				msgWin.show( alertMsg );
			}else{
				alert( alertMsg );
			}
		}
	};		
})();
//-->
</script>