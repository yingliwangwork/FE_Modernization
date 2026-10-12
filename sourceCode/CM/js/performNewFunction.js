/**
2008-07-09 
以 契約編號 至 ATZ0_Z003 判斷 該契約的 CREATE_DIVNO 及 CREATE_DATE 於 DTATE040 是否有符合條件的資料 ,
若有符合的資料則回傳 true , 執行新功能 , 
false , 執行原功能 

parmValue 000000117625 .....

parmName 僅支援 CONTRACT_NO , APPLY_NO , POLICY_NO

dispatcher <%=dispatcher%>
Jimmy
*/
function isPerformNewFunction(parmValue ,parmName, dispatcher){
	 
	//若為 true 則執行新的功能
	var foo = false;
	//prototype.js
	new Ajax.Request(
		dispatcher + '/ATZ0_Z003/redirect',		
		{	encoding : 'Big5', 
			asynchronous : false,
			parameters:parmName+'='+parmValue,
			onSuccess :function (XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					var msg = CSRUtil.getReturnMessage(resp);
					if(msg.msgDesc == 'Y'){
						msg.displayMsgDescs='';
						foo = true;
					}
				}
			}
		}
	);			
	return foo;
	
}