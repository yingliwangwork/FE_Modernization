<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA31301.jsp
作者：謝雅筑
功能：特殊案件匯入
完成：2012/04/10
-->
<!--
[20200623]問題單(202006200074):
1. 上傳Xlsx檔案改成Csv
!-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/JavaScript' src="<%=htmlBase%>/CM/js/date.js"></script>
<script type='text/javascript' src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type='text/javascript'>

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSA31301().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA31301(){
	
	var valid;
	var grid;
	
	var buttonAuth = function (){
		var authButtons = {
			B0028:"btn_confirm"<%--確認--%>
		};
		<dz:grantButtons FUNC_ID="DSA31301" ignored="false"/>
	};	
					
	var actions = {
		// 匯入
		doImport:function(){
			valid.reset();
			if( !valid.validate() ) {
	    		return;
	    	}
			document.importForm.submit();
		},
		
		//確認
		doConfirm:function(){
			valid.reset();
			var recs = grid.getAllRecords();
			if(recs.length == 0 || $F('CSV_PATH') == ''){
				alert('請先匯入資料');
				return;
			}
			if(!confirm('確認畫面上資料無誤?')){
				return;
			}
			ajaxPost('confirm',{encryptStr:$F('CSV_PATH')},
				function(resp){
		           //[20200629] 確認後重查(顯示受理編號)
					var rtnList  = resp.rtnList || [];
				    grid.load(rtnList);
				}
			);
	    },
	    
	    //回上頁
	    doBack:function(){
	    	CSRUtil.linkBack();
	    }
	};

	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSA3_1301/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT,resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction(resp);
		 		}
	        }}
		);
	}
	

	return{                              
		initApp:function(){
			PageUI.createPageWithAllBodySubElement("DSA31301" , "鑑價作業" , "特殊案件匯入", 1);
			
			grid = new TableUI ( {
				table: $("grid"), pageSize: 10, allSortable:true,
					column:[
						{header: "受理編號",key: "APPLY_ID" },
						{header: "特殊案件類別",key: "APPR_TYPE_NM" },
						{header: "鑑價組",key: "APPR_GROUP_NM" },
						{header: "鑑價人員",key: "APPR_NM" },
						{header: "借款人或案名",key: "CASE_NAME" },
						{header: "縣市",key: "GAGE_ADDR" },
						{header: "郵遞區號",key: "GAGE_ZIP" },
						{header: "換算件數",key: "APPR_COUNT" },
						{header: "派件日期",key: "APPLY_DATE" ,
		               		render:function(record,value){
		               			if(value){
		               				value = Date.toROC(value);
		               			}
		               		 	return value ;
		               		}
		            	},
						{header: "作業人員",key: "INPUT_NM" },
						{header: "作業日期",key: "INPUT_DATE" ,
		               		render:function(record,value){
		               			if(value){
		               				value = Date.toROC(value);
		               			}
		               		 	return value ;
		               		}
		            	}
					]
				
			});	
			
			valid = new Validation("body", {useTitles:true,focusOnError:false,immediate:false});
		    <%--[20200623] 上傳xlsx檔案改成csv ， .CSV or csv都可以 --%>
			Validation.addAllThese(
				[		
					['validateFileType', '檔案格式錯誤，僅能匯入.csv檔案', function(v , node) { 	
						if(v.lastIndexOf('.csv') < 0 && v.lastIndexOf('.CSV') < 0){
							return false;
						}
						return true;
	 					
					}]
				]
			);
	

			//確認
			$('btn_confirm').observe('click',function(event){actions.doConfirm();});
			
			//匯入
			$('btn_import').observe('click',function(event){actions.doImport();});
			
			//回上頁
			$('btn_back').observe('click',function(event){actions.doBack();});	
			
			//匯入錯誤訊息顯示
			$('xxx').observe('load',function(event){
			     var errMsg = window.xxx.document.getElementById("ErrMsg");
			     if(!errMsg){
				 	  return;
				 } 
			     errMsg = errMsg.value.evalJSON();
				  $('CSV_PATH').value = ''; 
			     if(errMsg.returnCode < 0){
				      grid.load([]);
				      alert( errMsg.msgDescs[0] );    
			     }
			
			     if(window.xxx.document.getElementById("UploadResult")){
				      var result = window.xxx.document.getElementById("UploadResult").value;
				      result = result.evalJSON(); 
				      grid.load(result);
			     
				     if(window.xxx.document.getElementById("UploadResultPath")){
					      var resultPath = window.xxx.document.getElementById("UploadResultPath").value;
					      $('CSV_PATH').value = resultPath; 
				     }  
			     }
		    });
    
			buttonAuth();
			displayMessage();
		}                 
	}

}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body id="body">
<iframe id="xxx" name="xxx" style="display:none" /></iframe>
<form id="importForm" name="importForm" method="post" target="xxx" enctype="multipart/form-data" action="<%=dispatcher%>/DSA3_1301/import">
<!------------------------ A區--------------------->		
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
			<tr>
			<td class="tbYellow2">
				<input id="CSV_PATH" name="CSV_PATH" type="hidden">
				<input id="A_PATH" name="A_PATH" fieldName="來源檔案路徑" type="file" size="50" class="textBox2 required validateFileType">
				<input id="btn_import" type="button" class="button" value="匯入">
				<input id="btn_confirm" type="button" class="button" value="確認" />
				<input id="btn_back" type="button" class="button" value="上一頁" />
			</td>
			</tr>
		</table>
<!------------------------ B區--------------------->											
		<table id="grid" class="grid"></table>
</form>		
</body>
<!-- InstanceEnd -->
</html>