<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSA10700.jsp
作者：i9100606
功能：電子謄本系統轉址畫面
完成：2011/09/23
更新：
-->

<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">

<%--共用定義的css--%>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script language="JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>

<%--自行定義的javaScript--%>
<script type="text/JavaScript">
<!--
<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>

Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function initApp(){

	PageUI.createPage("DSA10700" , "受理作業" , "電子謄本系統轉址畫面");
	PageUI.loadin(["grid"] ,0);

	cleanMsgBoard();

	//TableUI的產生        
	new UI().init();                
   
    PageUI.resize(true);
}

//--------------------------------------------------------------------------  
<%--全域 函數 UI 與 畫面 公用 End----------------------------------------------------%>

<%--Define UI Class Start-------------------------------------------------------%>
function UI(){                
	//--------------------------------------------------------------------------          
	//UI() private variable        
	//--------------------------------------------------------------------------         
	var grid = {};
	var urlInfo = '';
	var index = 0;
	//--------------------------------------------------------------------------          
	//UI() private method        
	//--------------------------------------------------------------------------          
	//***
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ){	
		
		new Ajax.Request( "<%=dispatcher%>/DSA1_0700/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	    	onSuccess: successAction
		});
	}      
	
	//AJAX SuccessAction For Query
	function successActionForQuery(XHT, resp) {
		if(CSRUtil.isSuccess(resp)){
			index = 0;
			urlInfo = resp.urlInfo;
			grid.load(resp.authList || []);
			var allRec  = grid.getAllRecords();
			if(allRec.length==1){
				var rec = allRec[0];
           		if('ERR'!=rec.AUTH_TYPE){
           			$('CHOICE_0').click();
           		}
			}
		} else{
			grid.load([]);
		}
	}	
		
	//查詢Function       
	var doQuery = function(){
		
		ajaxPost('query', 
				$("form1").serialize( true ), 
				successActionForQuery
		);

	};
	
	var produceXML = function(XMLstr){				
		var data = 'https://'+urlInfo+'/ELAND/CLB?ENTID=C0001&XML='+XMLstr;		
		data = data.replace(/\%(?![0-9a-fA-F]{2})/g,"%25")
		data = data.replace(/\+/g, "%2B");				
		var info = {'windowName': 'DSA10700'};
		popupWin.windowOpen(data, info);
	};

	//--------------------------------------------------------------------------        
	//以下為UI() public method,放在 return 中        
	//--------------------------------------------------------------------------          
	return{                              
		//init Function for 初始整個UI Class                
		init:function(){
			
			grid = new TableUI(                         
				{                   				
					table: $('grid'),   //對應的table實體                   				
					allSortable:false,
					overDiv:false,
					column:[           
						{header: '選取',key: '',
	  	                 	render: function(rec,val){
	                    		var div = document.createElement('div');
	            				var input_radio = document.createElement("input");
								input_radio.type = 'radio';
								input_radio.name = 'CHOICE';
								input_radio.id = 'CHOICE_'+index;
								input_radio.value = '0';
								Event.observe( input_radio , 'click', function(event){		
		                            produceXML(rec.XMLstr);
								});
	                    		div.appendChild(input_radio);
	                    		if('ERR'==rec.AUTH_TYPE){
	                    			input_radio.disabled = true;
	                    		}
	                    		index++;
	                    		return div;
	  	                 	}
	  	                },
						{header: '承辦單位',key: 'DIV_NO_NM',
							render:function(rec,val){
							 	if(!val){ return ""; }
							 	if('ERR'==rec.AUTH_TYPE){
	                    			return '<font color="red">'+rec.DIV_NO+" "+rec.DIV_NO_NM+'</font>';
	                    		}
							 	return rec.DIV_NO+" "+rec.DIV_NO_NM;
							}
						},
						{header: '授權種類', key: 'AUTH_TYPE_NM',
							render:function(rec,val){
							 	if(!val){ return ""; }
							 	return rec.AUTH_TYPE+" "+rec.AUTH_TYPE_NM;

							}
						}
					]										
				}                 
			); 

			doQuery();

		}//end init()--                        
	}//end return--        /
	//-------------------------------------------------------------------------- 
}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >



									<form id="form1" name="form1" method="post">
									
									<table id="grid" class="grid"></table>
									
									</form>

							
</body>
<!-- InstanceEnd -->
</html>
