/*
祘ΑcheckLoad.js

矗ㄑAjax 癳 request to Filter return ╰参琌Busy
ЧΘ2007/01/29
弧
穝
*/

var http_request;			//そノ跑计 xml http request ン
var status ;				//そノ跑计 ╰参篈 false: ╰参Γ窵, true ╰参タ盽
//-----------------------------------------------------------------------------
function checkLoad(form){

		status = false;		
		
		var isIE = /*@cc_on!@*/false || !!document.documentMode;
		if (isIE){
			http_request = new ActiveXObject("Microsoft.XMLHTTP");
		}else{
			http_request = new XMLHttpRequest();
		}
		
        if (!http_request) {
            alert('祇ネ岿粇 : [ Cannot create an XMLHTTP instance]');
            return false;
        }

        http_request.onreadystatechange = alertCheckLoadContents;

		//浪琩Form Action 琌 Τ? (肚把计)
		var tmpStr = form.action;			
		var strArr = tmpStr.split('?');
		var httpStr = '';
		if(strArr.length == 1){
			httpStr = form.action + '?CHKLOAD=Y';
		}else{
			httpStr = form.action + '&CHKLOAD=Y';
		}
		http_request.open("GET", 
							httpStr, 
							false);

        http_request.send(null);
     
        return status;

}
//-----------------------------------------------------------------------------
function alertCheckLoadContents() {
	
	if (http_request.readyState == 4) {

		if (http_request.status == 200) {
		

			if(http_request.responseText == 'SYS_NORMAL'){
				status = true;
			}else if(http_request.responseText == 'SYS_BUSY'){
				alert('╰参羉Γ叫祔刚');
				status = false;
			}
			
		} else {
			//ert('There was a problem with the request.');
			status = true;
		}
	}else{
	
		status = true;
		
	}
}
//-----------------------------------------------------------------------------