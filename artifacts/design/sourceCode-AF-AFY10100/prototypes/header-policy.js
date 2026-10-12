// Conditional synthetic context; query policy=Y opts into the evidenced branch.
if(new URLSearchParams(location.search).get('policy')==='Y'){document.body.dataset.copyPolicy='Y';
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
			
			if(fpcsRecordText.length > 0 && lastfpcsRecordText !== fpcsRecordText) {
				
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
				reviewNote(JSON.stringify({reviewOnly:true,boundary:'BOUND-08',encodedCopyContent:fpcsRecordText,length:fpcsSelectedText.length,functionId:'DEMO_FUNC',timestamp:new Date().getTime()},null,2));
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
}
