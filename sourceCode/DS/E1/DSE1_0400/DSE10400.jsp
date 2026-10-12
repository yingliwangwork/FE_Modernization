<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSE10400.jsp
作者：黃子玹 
功能：法務到案確認
完成：2013/6/7

[20240207]
難字調整
高強禾
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->
<fmt:setBundle basename="TextResource" />

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>        <%-- 投資共用 --%>
<%-- [20240207] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type="text/JavaScript">

// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSE10400().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSE10400(){

	var grid;
	var rtnList;

	//按扭權限
	function buttonAuth(){
		var authButtons = {		
			B0028:"btn_confirm" 			
		};
	
		<dz:grantButtons FUNC_ID="DSE10400" />
	}	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSE1_0400/" + actionName,
			{  
				parameters: params, 
				onSuccess:function(response){
					var resp = response.responseJSON
					if(CSRUtil.isSuccess(resp)){	
						if(successFunction){
							successFunction(resp);
						}
					}else{
						if(errorFunction){
							errorFunction(resp);
						}
					}
				}			
			});
	}

	var actions = {			
		
		//查詢
		doQuery : function(event) {			
			
			ajaxPost( 'query',{},
				function(resp){	
					rtnList = resp.rtnList;
					grid.load(rtnList);					
				},function(resp){					
					grid.load([]);			
				}					
			);		
		}
		//確認
		,doConfirm : function(event){
			
			var hasChkData1 = false;		
			var tmp = $$("input[id='COLL_RECO']:checked");			
			if(tmp.length > 0){
				hasChkData1 = true;			
			}
			
			var hasChkData2 = false;	
			var tmp1 = $$("input[id='PART_DIST']:checked");
			if(tmp1.length > 0){
				hasChkData2 = true;			
			}			
			
			if( hasChkData1 == false && hasChkData2 == false){		
				alert("請至少選取一筆資料");//催收紀錄&參與分配至少勾選其一才算有選取
				return;
			}	
						
			var chkData = []; //儲存選取的資料					
			var allData = grid.getAllRecords();	
			var chkREFFER = {};
			for(var i = 0;i < allData.length;i++){
				var REFER_ID = allData[i].REFER_ID;
				var COLL_RECO = allData[i].COLL_RECO ||'0';
				var PART_DIST = allData[i].PART_DIST ||'0';
			
				//申請書-修改放款契約效力：催收紀錄&參與分配僅能擇一
				if (COLL_RECO === "1" && PART_DIST === "1"){ 	
					alert('催收紀錄與參與分配僅能擇一勾選!');
					return;
				}
			
				if (COLL_RECO === "1" || PART_DIST === "1"){ 					
					if(chkREFFER[REFER_ID] && (chkREFFER[REFER_ID] != COLL_RECO+PART_DIST)){
						alert('同一原貸帳號移送原因不同，請勾選相同原因再進行確認!');
						return;
					}else{
						chkREFFER[REFER_ID] = COLL_RECO+PART_DIST;			
					}	
					chkData.push(allData[i]);				
				}								
			}	
		
			ajaxPost( 'confirm',{inputList : Object.toJSON(chkData)},
				function(resp){		
					grid.load(resp.rtnList);				
				}					
			);			
		}		
	};

	return{
	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSE10400" , "法務作業" , "法務到案確認");
			
			grid = new TableUI({
				table: $('grid'), pageSize: 20, allSortable: true,			
                <%-- [20240207] 難字調整 --%>
                afterLoad: function() {
                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
                },
                pageChange: function() {
                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
                },
				column: [
					{header:"催收紀錄", key:'COLL_RECO',sortable:false,
						render : function(rec, val) {
							var chk = new Element('input', {type : 'checkbox' ,id:'COLL_RECO'});								
							chk.observe('click', function(event){								
								var tr = this.up('tr')		
								var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
								/*
								var checkList = tr.select('input:checked[type = "checkbox"]');
								if(checkList.length > 0){
								
								}*/
								
								dataObj.COLL_RECO = this.checked ? '1' : '0';
							});
							return chk;
						}
					},	
					{header:"參與分配", key:'PART_DIST',sortable:false,
						render : function(rec, val) {
							var chk = new Element('input', {type : 'checkbox' ,id:'PART_DIST'});							
							chk.observe('click', function(event){								
								var tr = this.up('tr')		
								var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
								
								dataObj.PART_DIST = this.checked ? '1' : '0';
							});
							return chk;
						}
					},	
					{header:"貸款帳號", key:'LOAN_ID'},			
					<%-- [20240207] 難字調整：姓名 --%>
					{header:"姓名", key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},			
					{header:"信保貸款", key:'STATUS'},			
					{header:"921案件", key:'COL_921'},
					{header:"上次應繳日", key:'LAST_PAYDT',
						render : function (rec , val){
						return Date.toROC(val || '');									
						}
					},
					{header:"已繳期數", key:'PAID_TIMES'},	
					<%-- [20240207] 難字調整：承辦法務 --%>
					{header:"承辦法務", key:'INPUT_ID', attrs:{ style:"font-family:'EUDC'" },
							render : function (rec , val){					 
								return rec.INPUT_NM || '';
						    }						
					},
					{header:"收息單位", key:'GETINT_DEPT'},	
					<%-- [20240207] 難字調整：移送經辦 --%>
					{header:"移送經辦", key:'TRANS_ID', attrs:{ style:"font-family:'EUDC'" },
							render : function(rec,val){
								return rec.TRANS_NM || '';
							}					
					},
					{header:"移送日期", key:'TRANS_DATE',
						render : function (rec , val){
						return Date.toROC(val || '');									
						}					
					}
				]	
			});
				
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			
				
			$('btn_confirm').observe('click', function(event){
				actions.doConfirm(); 
			});

			
			actions.doQuery();
			buttonAuth();
			
			PageUI.resize();
			displayMessage();
			
		}//end init()--
	};//end return--	
}//end DSE10400
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>					
				<td class="tbYellow" width= "20%" align="left">作業單位</td>
				<td class="tbYellow2" width ="30%"><span id="INPUT_DATE">${DIV_NO}</span></td>				
									
				
				<td class="tbYellow" width= "20%" align="left">日期</td>
				<td class="tbYellow2" width ="30%"><span id="INPUT_DATE">${CURR_DT}</span><td>						
			</tr>
			<tr>
				<td  width="100%" colspan="4" align="center">					
					<input id="btn_confirm" type="button" class="button" value='確認'/>					
				</td>
			</tr>			
		</table>
	</form>
		<table id="grid" width="100%" class="grid" ></table>
</body>
</html>		