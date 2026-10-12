<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSB10400.jsp
作者：謝雅筑
功能：特約代書資格查詢
完成：2012/06/21
-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%-- [20240607] 難字調整 --%>
<style type="text/css"> 
@font-face {
    font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSB10400().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB10400(){

	var grid;
	
	var valid;

    var buttonAuth = function (){
        var authButtons = {
            B0003:"btn_insert"<%--新增--%>,
			B0004:"btn_update"<%--修改--%>
        };
        <dz:grantButtons FUNC_ID="DSB10400" ignored="false"/>
    };   
		
	var actions = {
		
		//查詢
		doQuery:function(){
			$('QUERY_COND').value = $F('QUERY_COND').toUpperCase();
			 valid.clear();
			 valid.define( "validCondRequired" , [{ id : "QUERY_COND"}]);
			 valid.define( "validCondFormate" , [{ id : "QUERY_COND"}]);
            if( !valid.validate() ) {
                return;
            }    
			var QUERY_KIND = commonTools.getRadioValue('QUERY_KIND');

			ajaxPost('query',{QUERY_COND:$F('QUERY_COND'),QUERY_KIND:QUERY_KIND},
				function(resp){
					commonTools.loadData(resp.rtnMap);
					grid.load(resp.B031List);
					$('OldDivNo').value = resp.rtnMap.OldDivNo;
					
					
				},
				function(){
					commonTools.clearTableB();
					grid.load([]);
				}
			);
			
		},
		
		//新增
		doInsert:function(){
			$('SCRIVENER_ID').value = $F('SCRIVENER_ID').toUpperCase();//代書ID
			 valid.clear();
			 valid.define( "validROCID" , [{ id : "SCRIVENER_ID"}]);
			 valid.define( "required" , [{ id : "SCRIVENER_NAME"}]);
			 valid.define( "validHasHalfType" , [{ id : "SCRIVENER_NAME"}]);

            if( !valid.validate() ) {
                return;
            } 
            var rtnMap = {};
            $$('#tableB input[type=text]').each(function(o){//輸入欄位
				rtnMap[o.id] = o.value;
            }); 
            rtnMap.IS_AGENCY = commonTools.getRadioValue('IS_AGENCY');            
            <%-- [20240607] 難字調整 --%>
            rtnMap['INPUT_NAME'] = $F('SCRIVENER_NAME');
			ajaxPost('insert',{rtnMap:Object.toJSON(rtnMap),OldDivNo:$F('OldDivNo'),QUERY_COND:rtnMap.SCRIVENER_ID,QUERY_KIND:'1'},
				actions.successAction
			);
		},
		
		//修改
		doUpdate:function(){
			$('SCRIVENER_ID').value = $F('SCRIVENER_ID').toUpperCase();//代書ID
			$('QUERY_COND').value = $F('QUERY_COND').toUpperCase();
			
			var QUERY_KIND = commonTools.getRadioValue('QUERY_KIND');
			var QUERY_COND = $F('QUERY_COND');
			if(QUERY_KIND=='1'){ /*以代書ID查詢*/
				if(QUERY_COND != $F('SCRIVENER_ID')){
					alert('代書ID與原先查詢的資料不同，無法作業!');
					return;
				}
			}
			
			 valid.clear();
			 valid.define( "validROCID" , [{ id : "SCRIVENER_ID"}]);
			 valid.define( "required" , [{ id : "SCRIVENER_NAME"}]);
			 valid.define( "required" , [{ id : "UPDATE_REASON"}]);
			 valid.define( "validHasHalfType" , [{ id : "SCRIVENER_NAME"}]);
			 
            if( !valid.validate() ) {
                return;
            } 
		
			var rtnMap = commonTools.getParams();
			<%-- [20240607] 難字調整 --%>
			rtnMap['INPUT_NAME'] = $F('SCRIVENER_NAME');
			ajaxPost('update',{rtnMap:Object.toJSON(rtnMap),OldDivNo:$F('OldDivNo'),QUERY_COND:rtnMap.SCRIVENER_ID,QUERY_KIND:'1'},
				actions.successAction
			);			 
		},
		
		//成功顯示畫面資料
		successAction:function(resp){
			if(resp.B031List){
				grid.load(resp.B031List);
			}			
			commonTools.loadData(resp.rtnMap);
			commonTools.setRadioValue('QUERY_KIND','1'); 
			$('QUERY_COND').value = $F('SCRIVENER_ID'); 
			$('OldDivNo').value = resp.rtnMap.OldDivNo;  
		}
	};	
	
    //undefined,null 顯示''
    function noNull(v){
        if(v == null || v == undefined){
            v='';
        }
        return v; 
    }
    
	
	var commonTools = {
	    
        getRadioValue:function(name){
            var v = '';
            $$('#form1 input:checked[name='+name+']').each(function(o){
                 v = o.value;
            });
            return v;
        },
		
		setRadioValue:function(name,checkedValue){
            $$('#form1 input[name='+name+']').each(function(o){
                if(o.value==checkedValue){
					o.checked = true;
				}
            });		
		},
		
		//清空B區  
		clearTableB:function(){
            $$('#tableB span').each(function(o){
                o.update('');
            });	
			
            $$('#tableB input').each(function(o){//包含hidden欄位
                if(o.type != 'radio'){
					o.value='';
				}
            });				
		},
        
        //載入資料
        loadData:function(rtnMap){
            rtnMap = rtnMap?rtnMap:{};
            
            //清空B區    
            commonTools.clearTableB();
			
            //區塊B
            $$('#tableB span').each(function(o){
                var value = noNull(rtnMap[o.id]);
                value = (value==undefined ||value==null  )? '':value;
				if(o.getAttribute('datatype') == 'ROCDate'){
					value = Date.toROC(value,'');
				}
                o.update(value);
            });
			
            $$('#tableB input').each(function(o){//包含hidden欄位
				if(o.type!='radio'){
					 o.value = noNull(rtnMap[o.id]);
				}
            }); 
			
			commonTools.setRadioValue('IS_AGENCY',noNull(rtnMap.IS_AGENCY));           
        },
		
		//取得畫面B區輸入資料
		getParams:function(){
			var rtnMap = {};
			
            $$('#tableB input').each(function(o){//包含hidden欄位
				if(o.type!='radio'){
					 rtnMap[o.id] = o.value;
				}
            }); 
            $$('#tableB span').each(function(o){
            	var value = o.innerHTML;
                if(o.datatype == 'ROCDate'){
                    value = toY2K(value);
                }
				rtnMap[o.id] = value;
            });			
			
			rtnMap.IS_AGENCY = commonTools.getRadioValue('IS_AGENCY');
			return rtnMap;
		}

	};
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSB1_0400/" + actionName,
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
			PageUI.createPage("DSB10400" , "匯款維護" , "特約代書資格查詢", false);
			PageUI.loadin(["form1"] ,1);
			
            valid = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
            Validation.addAllThese(
                [        
                    ['validCondRequired', '請輸入代書ID或代書姓名查詢!!', function(v , node) { 
						if(v==''){
							return false;
						}else{
							return true;
						}
    
                    }],
					
                    ['validCondFormate', '請輸入正確ID查詢!!', function(v , node) { 
						var QUERY_KIND = commonTools.getRadioValue('QUERY_KIND');

						if(v!='' && QUERY_KIND == '1'){
							return validation.checkROCID(v);
						}else{
							return true;
						}
                    }],
                    
                    ['validROCID', '請輸入正確身分證號碼格式', function(v , node) { 
						return validation.checkROCID(v);
                    }],
                    
                    ['validHasHalfType', '請輸入全形中文', function(v , node) { 
						return !validation.hasHalfType(v);
                    }]            
        
                ]
            );
			
			grid = new TableUI ( {
					table: $("grid"), pageSize: 20, allSortable:true,
					<%-- [20240607] 難字調整 --%>
		            pageChange: function() {
		            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }
		            },
					column:[
						{header: "代書ID",key: "SCRIVENER_ID"},		
						<%-- [20240607] 難字調整 --%>
						{header: "代書姓名",key: "SCRIVENER_NAME", attrs:{ style:"font-family:'EUDC'" }},			
						{header: "修正原因",key: "UPDATE_REASON"},
						<%-- [20240607] 難字調整 --%>
						{header: "建檔人員",key: "INPUT_NAME", attrs:{ style:"font-family:'EUDC'" }},		
						{header: "建檔日期",key: "INPUT_DATE",
							render : function(rec ,val ){							
								return Date.toInputROC(val || '' , '/');	
							
							}
						},	
						<%-- [20240607] 難字調整 --%>
						{header: "刪除人員",key: "DELETE_NAME", attrs:{ style:"font-family:'EUDC'" }},	
						{header: "刪除日期",key: "DELETE_DATE",
							render : function(rec ,val ){							
								return Date.toInputROC(val || '' , '/');	
							
							}
						}					
					]
					
				});
			
			
			//查詢
			$('btn_query').observe('click',function(event){
					actions.doQuery();
				}
			);
			
			//新增
			$('btn_insert').observe('click',function(event){
					actions.doInsert();
				}
			);
			
			//修改
			$('btn_update').observe('click',function(event){
					actions.doUpdate();
				}
			);
			
			buttonAuth();
			displayMessage();

		}                 
	}

}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body>	
	<form id="form1" name="form1"  method="post">				
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">	
			<tr>
				<td class="tbYellow" width="35%" align="left" >
					<input type="radio" name="QUERY_KIND" value="1" class = "textBox2" checked />代書ID
					<input type="radio" name="QUERY_KIND" value="2" class = "textBox2" />代書姓名
					<input type="hidden" id="OldDivNo" value="${OldDivNo}"/>
				</td>			
				
				<td class="tbYellow2" width ="40%">
					<input id="QUERY_COND" name="QUERY_COND" type="text" class = "textBox2" size = "12"/>
				</td>	
				<td class="tbYellow2" align="center" >
					<input id = "btn_query" type = "button" class = "button" value = "查詢"/>
				</td>		
			</tr>
			<tr>
				<td colspan = "3" align = "center"> 
					<input id = "btn_insert" type = "button" class = "button" value = "新增"/>
					<input id = "btn_update" type = "button" class = "button" value = "修改"/>
				</td>
			</tr>
		</table>	
			
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB">
			<tr>
				<input type="hidden" id="DELETE_ID"/>
				<input type="hidden" id="DELETE_DATE"/>
				<td class="tbYellow" width="20%" >
					代書ID
				</td>	
				<td class="tbYellow2" width ="30%" >
					<input id = "SCRIVENER_ID" name = "SCRIVENER_ID" type = "text" class = "textBox2" size = "12" maxlength ="10" fieldName = "代書ID"/>	
				</td>	
				<td class="tbYellow" width="20%">
					代書姓名
				</td>							
				<%-- [20240607] 難字調整 --%>
				<td class="tbYellow2" width ="30%">
					<input id = "SCRIVENER_NAME" name = "SCRIVENER_NAME" type = "text" class = "textBox2" size = "8"  fieldName = "代書姓名" alt="ch"/>	
				</td>						
			</tr>
			<tr>
				<td class="tbYellow" >
					區域
				</td>	
				<td class="tbYellow2" >
					<span id ="INPUT_DEPT_NM"></span>
				</td>	
				<td class="tbYellow">
					是否為特約代書
				</td>	
				<td class="tbYellow2" >
					<input type="radio" name="IS_AGENCY"  value="N" checked />否
					<input type="radio" name="IS_AGENCY"  value="Y"/>是
				</td>						
			</tr>
			<tr>
				<td class="tbYellow">
					建檔人員
				</td>	
				<%-- [20240607] 難字調整 --%>
				<td class="tbYellow2" >
					<span id ="INPUT_NAME" style="font-family:'EUDC'"</span>
				</td>	
				<td class="tbYellow">
					建檔日期
				</td>	
				<td class="tbYellow2" >
					<span id ="INPUT_DATE" datatype="ROCDate"></span>
				</td>							
			</tr>			
			<tr>
				<td class="tbYellow" >
					修正原因
				</td>							
				<td class="tbYellow2" colspan="3">
					<input type = "text" class = "textBox2" id = "UPDATE_REASON" name ="UPDATE_REASON" size = "40"/>
				</td>		
			</tr>						
		</table>
		<table id='grid' width="100%"></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableC">
			<tr>				
				<td class="tbYellow" >	
					<b><font class = 'textBlue'>一、作業規定</font></b>
					<BR>1. 各種貸款規定請參照放款作業手冊及發文規定。
					<BR>2. 本作業提供代書資料查詢。
					<BR>3. 限消金審查科行政組人員才能異動資料。
					<BR><BR>
					<b><font class = 'textBlue'>二、操作方式</font></b>
					<BR>1. 查詢代書ID或姓名：輸入代書ID或姓名，按 <font class = 'textBlue'>[查詢]</font>即可。
					<BR>2. 新增代書資料：請先查詢，若尚無資料，請新增輸入各欄位後，按 <font class = 'textBlue'> [新增]</font>即可。
					<BR>3. 修改代書資料：請先查詢，修正欄位資料後，按<font class = 'textBlue'> [修改]</font>即可。
					<BR>4. 取消特約代書資格：請先查詢，點選非特約代書並輸入修正原因，按  <font class = 'textBlue'>[修改]</font>即可。		
				</td>								
			</tr>
		</table>	
	</form>	
</body>
<!-- InstanceEnd -->
</html>