// Synthetic empty message sequence; source does not establish real backend messages.
var msgs=[];
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

