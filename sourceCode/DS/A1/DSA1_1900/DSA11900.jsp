<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA11900.jsp
作者：林秉宏
功能：行動案件恢復
完成：2018/02/26
更新：
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css">
<title></title>

<%--共用定義的javaScript--%>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ImageUtil.js'></script>

<script type="text/JavaScript">

// 產生畫面物件
var DSA11900 = new DSA11900();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
Event.observe(window, 'load', DSA11900.initApp);

function DSA11900(){
	
	<%--建立 ajax request 物件--%>
    var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA1_1900/');
    
	var grid;
	var valid1;
	var valid2;
    
    <%--按鈕權限--%>
	function buttonAuth(){
		var authButtons = {
				//B0099:"BTN_resume",//恢復案件
		};
		<dz:grantButtons FUNC_ID="DSA11900" ignored="false"/>
	}
    
    <%--檢核--%>
	function initValidation(){	
		Validation.addAllThese([
			[ 'validateAPPLY_ID',  '受理編號長度不正確 需為14碼以上',
				function(v){				
					return (v.length < 14) ? false : true ;
				}
			]
		]);
		
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });
		valid1.define( "required" , [{ id : "query_APPLY_ID", errMsg:'請輸入受理編號!'}]);
		valid1.define( "validateAPPLY_ID" , { id: "query_APPLY_ID" } );
		
		valid2 = new Validation("form1", { focusOnError:true, immediate:false });
		valid2.define( "required" , [{ id : "REASON", errMsg:'請輸入異動原因!'}]);
	};
    
    var actions = {
    
    	<%--查詢--%>
		doQuery : function(){	
			
			valid2.reset();
			
			if(!valid1.validate()){ 
				return; 
			}
			
			ajaxRequest.post( 'query' , { APPLY_ID : $F('query_APPLY_ID') },
				function(resp){		
					var rtnMap = resp.A010Map ? resp.A010Map : {};
					$('APPLY_ID').innerHTML = rtnMap.APPLY_ID ? rtnMap.APPLY_ID : '';
					$('UPDATE_DATE').innerHTML = rtnMap.UPDATE_DATE ? Date.toROC(rtnMap.UPDATE_DATE) : '';
					$('BORROW_ID').innerHTML = rtnMap.BORROW_ID ? rtnMap.BORROW_ID : '';
					$('BORROW_NAME').innerHTML = rtnMap.BORROW_NAME ? rtnMap.BORROW_NAME : '';
					
					grid.load(resp.rtnList || []);
					grid1.load(resp.rtnDelList || []);
					grid2.load(resp.A010List || []);
				},
				function(resp){	
					
					$('APPLY_ID').innerHTML = '';
					$('UPDATE_DATE').innerHTML = '';
					$('BORROW_ID').innerHTML = '';
					$('BORROW_NAME').innerHTML = '';
					$('query_APPLY_ID').setValue('');
					grid.load([]);
					grid1.load([]);
					grid2.load([]);
				}
			);
		},
		
		<%--恢復案件--%>
		doResume : function(){	
		
			if(!$F('query_APPLY_ID')){
				alert("請先執行查詢!");
				return;
			}
			
			if($F('query_APPLY_ID') != $('APPLY_ID').innerHTML){
				alert("受理編號和查詢時不同，請重新執行查詢!");
				return;
			}
			
			valid1.reset();
			if(!valid2.validate()){ 
				return; 
			}
			
			ajaxRequest.post( 'resume' , { APPLY_ID : $('APPLY_ID').innerHTML, REASON : $F('REASON') },
				function(resp){		
					var rtnMap = resp.A010Map ? resp.A010Map : {};
					$('APPLY_ID').innerHTML = rtnMap.APPLY_ID ? rtnMap.APPLY_ID : '';
					$('UPDATE_DATE').innerHTML = rtnMap.UPDATE_DATE ? Date.toROC(rtnMap.UPDATE_DATE) : '';
					$('BORROW_ID').innerHTML = rtnMap.BORROW_ID ? rtnMap.BORROW_ID : '';
					$('BORROW_NAME').innerHTML = rtnMap.BORROW_NAME ? rtnMap.BORROW_NAME : '';
					
					grid.load(resp.rtnList || []);
					grid1.load(resp.rtnDelList || []);
					grid2.load(resp.A010List || []);
				}
			);
		}
    };
 
    return {
		
		initApp : function() {
		
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay"/>

			PageUI.createPageWithAllBodySubElement("DSA11900", "受理作業", "行動案件恢復");
			
			grid2 = new TableUI(
					{	
						table:$("grid2"), pageSize:0, allSortable:true, overDiv:true,
						column:[			

							{header:"暫存受理編號 ", key:"APPLY_ID",
								render:function(rec,val){
									var alink = document.createElement("a");
									alink.href = "#";
									alink.innerHTML = rec.APPLY_ID ? rec.APPLY_ID : '';
									alink.onclick = function(){
										$('query_APPLY_ID').setValue(rec.APPLY_ID ? rec.APPLY_ID : '');
										actions.doQuery();
									};
									return alink;
								}
							},
							{header:"借款人姓名", key:"BORROW_NAME"},
							{header:"借款人ID", key:"BORROW_ID"},
							{header:"進度", key:"APPLY_PROCESS"}
	
						]				
					}
				);
			
			grid = new TableUI(
				{	
					table:$("grid"), pageSize:0, allSortable:true, overDiv:true,
					column:[			

						{header:"文件代碼", key:"DOC_CODE"},
						{header:"序號", key:"SER_NO"},
						{header:"簽名人ID", key:"ID"},
						{header:"文件種類", key:"KIND"},
						{header:"圖檔內容", key:"ITEM_NAME"},
						{header:"輸入時間", key:"INPUT_DATE",
							render:function(rec,val){
							 	return val ? Date.toROC(val) : "";
							}},
						{header:"暫存ID", key:"IDENTIFY_ID"}

					]				
				}
			);
			
			grid1 = new TableUI(
					{	
						table:$("grid1"), pageSize:0, allSortable:true, overDiv:true,
						column:[			

							{header:"文件代碼", key:"DOC_CODE"},
							{header:"序號", key:"SER_NO"},
							{header:"簽名人ID", key:"ID"},
							{header:"文件種類", key:"KIND"},
							{header:"圖檔內容", key:"ITEM_NAME"},
							{header:"輸入時間", key:"INPUT_DATE",
								render:function(rec,val){
								 	return val ? Date.toROC(val) : "";
								}
							},
							{header:"恢復", key:"IDENTIFY_ID",
							  	render: function(record, value){

									var unique_id = record.APPLY_ID;
		                    		var div = document.createElement('div');
		                    		var input = document.createElement('input');
		                    		input.id = unique_id+'1';
		                    		input.name = unique_id;
		                    		input.value = '恢復';
		                    		input.type = 'button';
		                    		input.className = 'button';
		                    		input.onclick = function(){
		                    			//doConfirm(rec.APPLY_ID,rec.INPUT_ID);
										obj = record;
										obj.APPLY_ID = record.CASE_ID;
										ajaxRequest.post( 'move' , obj,
												function(resp){		
													var rtnMap = resp.A010Map ? resp.A010Map : {};
													$('APPLY_ID').innerHTML = rtnMap.APPLY_ID ? rtnMap.APPLY_ID : '';
													$('UPDATE_DATE').innerHTML = rtnMap.UPDATE_DATE ? Date.toROC(rtnMap.UPDATE_DATE) : '';
													$('BORROW_ID').innerHTML = rtnMap.BORROW_ID ? rtnMap.BORROW_ID : '';
													$('BORROW_NAME').innerHTML = rtnMap.BORROW_NAME ? rtnMap.BORROW_NAME : '';
													
													grid.load(resp.rtnList || []);
													grid1.load(resp.rtnDelList || []);
												}
											);
		                    		};
		                    		div.appendChild(input);
		                    		
		                    		return div;
							  	}}
	
						]				
					}
				);
			
			initValidation();						
							
			<%--查詢--%>
			$('BTN_query').observe('click', actions.doQuery );
			<%--恢復案件--%>
			$('BTN_resume').observe('click', actions.doResume );
			
			<%--監聽: 查詢方式(值) 轉大寫--%>
			$("query_APPLY_ID").observe('change', function() {$("query_APPLY_ID").setValue($F("query_APPLY_ID").toUpperCase());} );
			
			buttonAuth();
					
			PageUI.resize();
			displayMessage();
		}		
	};
}

</script>
</head>
<body>
<form id="form1" name="form1" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="10%">受理編號</td>
			<td class="tbYellow2" width="80%">
				<input id="query_APPLY_ID" type="text" class="textBox2" size="30" maxlength="27" value="">
			</td>
			<td class="tbYellow2" width="10%" align='center'>
				<input id="BTN_query" type="button" class="button" value="查詢">
			</td>
		</tr>
		<tr>
			<td align="center" colspan="3">
				<input id="BTN_resume" type="button" class="button" value="恢復案件">
			</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr><td class="tbYellow0" align="center"><span style="font-weight: bold;">清單</span></td></tr>
		<tr><td><table id='grid2' width="100%"></table></td></tr>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr><td class="tbYellow0" align="center" colspan="4"><span style="font-weight: bold;">案件資料</span></td></tr>
		<tr>
			<td class="tbYellow" width="15%">
				暫存受理編號
			</td>
			<td class="tbYellow2" width="25%">
				<span id="APPLY_ID"></span>
			</td>
			<td class="tbYellow" width="15%">
				同步時間
			</td>
			<td class="tbYellow2" width="45%">
				<span id="UPDATE_DATE"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="15%">
				借款人姓名
			</td>
			<td class="tbYellow2" width="25%">
				<span id="BORROW_NAME"></span>
			</td>
			<td class="tbYellow" width="15%">
				借款人ID
			</td>
			<td class="tbYellow2" width="45%">
				<span id="BORROW_ID"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="15%">
				異動原因
			</td>
			<td class="tbYellow2" width="85%" colspan="3">
				<input type="text" class="textBox2 checkInputLength" size="50" maxLength="200" value="" id="REASON"> 
			</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr><td class="tbYellow0" align="center"><span style="font-weight: bold;">應附文件</span></td></tr>
		<tr><td><table id='grid' width="100%"></table></td></tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr><td class="tbYellow0" align="center"><span style="font-weight: bold;">應附文件(已刪除)</span></td></tr>
		<tr><td><table id='grid1' width="100%"></table></td></tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbYellow2">
		<tr>
	     	<td align="center">
	      		<div id="showImage"></div>
	    	</td>
	    </tr>
	</table>
</form>
</body>
</html>
