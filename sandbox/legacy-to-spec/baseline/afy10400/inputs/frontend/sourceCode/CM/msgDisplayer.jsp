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
msgs = new Array(<%=msg.getLength()%>);
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

var msgDisplayer = {
	getBottomFrame: function(){
		if(top.frames['leftFrame'] && top.frames['leftFrame'].frames['bottomFrame']){
			return top.frames['leftFrame'].frames['bottomFrame'];
		}else if(parent.frames['leftFrame'] && parent.frames['leftFrame'].frames['bottomFrame']){
			return parent.frames['leftFrame'] && parent.frames['leftFrame'].frames['bottomFrame'];
		}else if(top.frames['bottomFrame']){
			return top.frames['bottomFrame'];
		}else if(parent.frames['bottomFrame']){
			return parent.frames['bottomFrame'];
		}
	},
	clearBottomMsg: function(){
		try{
			var bottomFrame = this.getBottomFrame();
			if(bottomFrame){
				var clearNotifyMsgFunc;
		        if(bottomFrame.contentWindow){
		            clearNotifyMsgFunc = bottomFrame.contentWindow.clearNotifyMsg;
		        }else{
		        	clearNotifyMsgFunc = bottomFrame.clearNotifyMsg;
		        }
		        if(typeof clearNotifyMsgFunc ==='function'){
		        	clearNotifyMsgFunc();
		        }
			}
		}catch(err){
		}
	}
};

<%-- 保留此方法，提供早期所開發之 JSP 利用該方法，取得下方訊息欄位進行訊息設定 --%>
function getMsgBoard(){
	var bottomFrame = msgDisplayer.getBottomFrame();
	if(bottomFrame){
		if(bottomFrame.contentWindow){
			return bottomFrame.contentWindow.cathay_common_msgBoard;
		}
		return bottomFrame.cathay_common_msgBoard;
	}
}

function alertMessages(){
	var alertMsg = "";

	for( var varindex=0;varindex<msgs.length;varindex++){
		if (msgs[varindex][6] == ""){
			//when msgs[msgindex][5]==99 (that is the ReturnCode=99) then keep the return message to the message board under the web
			if (msgs[varindex][5] != "0" && msgs[varindex][5] != "99"){//new
				//alertMsg+="回傳碼:"+msgs[varindex][5]+"\n";	//new
				//alertMsg+="訊息說明:\n"+msgs[varindex][0]+"\n\n";	//new
				alertMsg += "訊息說明:\n"+msgs[varindex][0]+"\n";
				
				if(msgs[varindex][1]){
					alertMsg += '\n錯誤編號：\n';
					alertMsg += msgs[varindex][1];					
				}
			}
		}else{
			if ((msgs[varindex][6] != "") || (msgs[varindex][2] != ""))
			{
				alertMsg+="異常原因:"+msgs[varindex][6]+"\n";
				alertMsg+="\n程式ID:"+msgs[varindex][2]+"\n\n";
			}
		}
	}
	// 錯誤時才需 alert
	if (alertMsg != ""){
		if(typeof window['WIUtil'] !== 'undefined' && typeof window['jQuery'] !== 'undefined'){
			WIUtil.displayMessage({msg:alertMsg});
		}else{
			alert(alertMsg);
		}
	}
}

function displayMessage(){

	try{

		var bottomFrame = msgDisplayer.getBottomFrame();
		if(bottomFrame){
			var showNotifyMsgFunc;
			if(bottomFrame.contentWindow){
				if(bottomFrame.contentWindow.txHasRollbackPage){
					bottomFrame.contentWindow.txHasRollbackPage = null; //Reset the txHasRollbackPage flag
					return ;//do nothing and return
				}
				showNotifyMsgFunc = bottomFrame.contentWindow.showNotifyMsg;
			}else{
				if(bottomFrame.txHasRollbackPage){
					bottomFrame.txHasRollbackPage = null; //Reset the txHasRollbackPage flag
					return ;//do nothing and return
				}
				showNotifyMsgFunc = bottomFrame.showNotifyMsg;
			}

			if(typeof showNotifyMsgFunc==='function'){
				var msgindex = 0;
				showNotifyMsgFunc({
					'returnCode': msgs[msgindex][5],
					'returnMessage': msgs[msgindex][0]
				});
			}
		}
	}catch(err){
	}

	alertMessages();

}

// a global event handle for clear notify msg on any submit
document.onclick = function (event){
	try{
		//for cross browser compatibility
		event = event || window.event;
		var target = event.target || event.srcElement;
	    var eType = target.type;
		if(eType && 'button,submit'.indexOf(eType) != -1){
			msgDisplayer.clearBottomMsg();
	    }
	}catch(err){
	}
};

//-->
</script>