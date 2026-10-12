<script>


<!--控制 div 隱藏顯示-->
function mask(szLayer){
	var szLayer = document.getElementById(szLayer);

	if(szLayer.style.visibility == "hidden"){
		szLayer.style.visibility = "visible";
		setErr_Layer();
	}else{
		szLayer.style.visibility = "hidden";
		setErr_Layer();
	}
}

function setErr_Layer(){

	var Err_Layer = document.getElementById('Err_Layer');

	if(Err_Layer.style.visibility == "visible"){
		Err_Layer.style.width = document.body.clientWidth + "px" ;
		Err_Layer.style.height = document.body.clientHeight + "px" ;
		Err_Layer.style.left = (document.body.clientWidth/2)-200 + "px" ;
		Err_Layer.style.top = document.body.scrollTop +100 + "px" ;
	}else{
		Err_Layer.style.width = "0px" ;
		Err_Layer.style.height = "0px" ;
		Err_Layer.style.left = "0px" ;
		Err_Layer.style.top = "0px" ;
	}
}

function doPopup(aMsg){
	var Err_Layer_MSG = document.getElementById('Err_Layer_MSG');
	Err_Layer_MSG.innerHTML = " <span class='err_layer'> " + aMsg + "</span> ";
	//Err_Layer_MSG.innerHTML = aMsg;
	mask('Err_Layer');
}

function popup(){

	<%
		com.igsapp.wibc.dataobj.html.HttpResponseContext messageResp
			= new com.igsapp.wibc.dataobj.html.HttpResponseContext(request);

		com.cathay.common.bo.ReturnMessage message;

		try{
			 message = (com.cathay.common.bo.ReturnMessage) messageResp.getOutputData(com.cathay.common.util.IConstantMap.ErrMsg);
		}catch(ClassCastException cce){
			message = null;
		}

		if(message!=null && message.getReturnCode() != com.cathay.util.ReturnCode.OK){
	%>
			var aMsg = "<%=message.getDisplayMsgDescs()%>";

			doPopup(aMsg);
	<%
		}
	%>

}

var linkUrl='';
var function_id='';

function setLinkUrl(aLinkUrl, aFunction_id){
	linkUrl = aLinkUrl;
	function_id = aFunction_id;
}

function completePopup(){
	//alert(linkUrl);
	//alert(function_id);
	//AB -> AJ Web
	if(linkUrl !=null && linkUrl != '' && function_id !=null && function_id != ''){
		var linkURL="<%=bcHost%><%=dispatcher%>/CustomerLogin/forward?function_id="+function_id+"&url="+encodeURIComponent(linkUrl);
		document.forms[0].action=linkURL;
		document.forms[0].submit();
		//AB -> AB Web
	}else if(linkUrl !=null && linkUrl != ''){
		document.forms[0].action=linkUrl;
		document.forms[0].submit();
	}
}

</script>

<div id="Err_Layer" style="position:absolute;visibility:hidden;z-index:1;" align="center">
	<table border="0" cellspacing="0" cellpadding="2" align="center" width="100%" height="100%" style="background-color: transparent; background-image: url(<%=bcHost%><%=imageBase%>/CM/B2C/pop_notice.jpg);background-repeat: no-repeat;">
		<tr height="60"><td></td></tr>
		<tr>
			<td>&nbsp;</td>
			<td valign="top" style="color:#333333" >
				<div id="Err_Layer_MSG" class="err_layer">&nbsp;</div>
				<br>
				<p>
					<div align="center" style="width:400px;">
						<input type="button" onclick="mask('Err_Layer'); completePopup()" class="button" value="確　定">
					</div>
				</p>
			</td>
		</tr>
	</table>
</div>