<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSE12000.jsp
作者：謝進修
功能：異常案件報表剔件覆核
完成：2013/03/13

[20240215]難字調整
 -->
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/RPTUtil.js'></script>

<%--[20240215]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>

<script type='text/javascript'>

    // 產生畫面物件
    var dse12000 = new DSE12000();
    // 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
    Event.observe(window, 'load', dse12000.initApp);
    Event.observe(window, 'resize', fix);
    Event.observe(window, 'scroll', fix);
    
    function DSE12000() {
    
        var grid;
        var valid;

        //共用AJAX
        var ajaxPost = function ( actionName, params, successAction){   
            new Ajax.Request( '<%=dispatcher%>/DSE1_2000/' + actionName,{  
                    parameters: params, 
                    onSuccess: function(response){ successAction(response.responseJSON);
                }
            });
        };
        
        // 檢核
        var initValidation = function(){
            valid = new Validation('form1', { focusOnError:true, immediate:false , mode : 'validator'});    
        };
    
        var actions = {
             
			 
			gridtable : function(v){
				grid = new TableUI(
					{table: $("grid"),autoCheckBox:{isSelectAll:true },pageSize: 10,	
						<%-- [20240215] 難字調整 --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:v
						
					}
				);
		    }, 
			 
            // 頁面資料
            getDataMap : function(){
                return  {
					//'CRED_DEPT' : $F('CRED_DEPT'), 
					'INPUT_ID' : $F('INPUT_ID'), 
					'DELETE_STATUS' : $F('DELETE_STATUS'),
					'CASE' :$F('CASE')
		        }	 				          
            }/*,
			
			// 連動產生承辦法務
			changeCRED_DEPT : function(){
			
				$('INPUT_ID').options.length = 1;
				
				if (!$('INPUT_ID')){
					return;
				}
				
				ajaxPost('changeCRED_DEPT', {CRED_DEPT : $F('CRED_DEPT')}, 
                    function(resp){
                        if(CSRUtil.isSuccess(resp)){
                            var INPUT_ID_LIST  = resp.INPUT_ID_LIST || [];
							for (var i = 0; i < INPUT_ID_LIST.length; i++){
								var optMap = INPUT_ID_LIST[i];
								if (optMap.ID){
									var oOption = new Element('option');
									oOption.innerText = optMap.NAME;
									oOption.value = optMap.ID;
									$('INPUT_ID').insert(oOption);
								}
							}
                        }
                    }
                );
			}*/
        }
        
        var buttons = {
            
            // 查詢
            doQuery : function(){
            
                if(!valid.validate()){ 
                    return; 
                }
                var gridList=[
                	[
					    {header:'貸款帳號', key:'LOAN_ID'},   
						{header:'原貸帳號', key:'REFER_ID'},
						{header:'借款人', key:'BORROW_NAME', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
						{header:'相對人', key:'BORROW_TYPE_NM', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
						{header:'法務受理日', key:'INPUT_DATE', 
							render: function(record, value) {
								return value ? Date.toROC(value) : ''; 
							} 
						},
						{header:'法務移轉日', key:'TRANS_DATE', 
							render: function(record, value) {
								return value ? Date.toROC(value) : ''; 
							} 
						},
						{header:'下次應繳日', key:'NEXT_PAYDT', 
							render: function(record, value) {
								return value ? Date.toROC(value) : ''; 
							} 
						},
						{header:'本金餘額歸戶', key:'REMAIN_AMT', sortRule:'number',
							render:gridFmtRender
						},
						{header:'法務進度', key:'LAW_PROCESS_NM'},
						{header:'法務進度日', key:'LAW_PROCESS_DATE', 
							render: function(record, value) {
								return value ? Date.toROC(value) : ''; 
							} 
						},
						{header:'最近管理費', key:'EXPENSE_ITEM_NM'},
						{header:'最近管理費發生日', key:'EFFECT_DATE', 
							render: function(record, value) {
								return value ? Date.toROC(value) : ''; 
							} 
						},			
						{header:'承辦法務', key:'INPUT_NM', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
						{header:'報表種類一', key:'REPORT_TYPE1_NM'},
						{header:'剔件原因', key:'DELETE_REASON_NM'},
						{header:'說明', key:'MEMO'},
						{header:'剔件狀態', key:'DELETE_STATUS_NM'},
						{header:'輸入人員', key:'LST_PROC_NM', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
						{header:'輸入日期', key:'LST_PROC_DATE', 
							render: function(record, value) {
								return value ? Date.toROC(value).split('.')[0] : ''; 
							} 
						},
						{header:'覆核人員', key:'CONFIRM_NM', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
						{header:'覆核日期', key:'CONFIRM_DATE', 
							render: function(record, value) {
								return value ? Date.toROC(value).split('.')[0] : ''; 
							} 
						}
					
					],
				    [
						{header:'貸款帳號', key:'LOAN_ID'},   
						{header:'原貸帳號', key:'REFER_ID'},
						{header:'借款人', key:'BORROW_NAME', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
						{header:'法務進度', key:'LAW_PROCESS_NM'},
						{header:'法務進度日', key:'LAW_PROCESS_DATE', 
							render: function(record, value) {
								return value ? Date.toROC(value) : ''; 
							} 
						},
						{header:'拍不足額歸戶', key:'BAD_AMT', sortRule:'number',
							render:gridFmtRender
						},
						{header:'中斷時效日', key:'BREAK_OFF_DATE', 
							render: function(record, value) {
								return value ? Date.toROC(value) : ''; 
							} 
						},
						{header:'調查財產報表日', key:'INVESTIGATE_DATE', 
							render: function(record, value) {
								return value ? Date.toROC(value) : ''; 
							} 
						},
						{header:'調查財產費用日', key:'INVESTIGATE_FEE_DATE', 
							render: function(record, value) {
								return value ? Date.toROC(value) : ''; 
							} 
						},
						{header:'有無實益', key:'IS_BENEFIT_NM'},
						{header:'追償作業聲請日', key:'DATE5', 
							render: function(record, value) {
								return value ? Date.toROC(value) : ''; 
							} 
						},
						{header:'債權憑證換發日', key:'DATE4', 
							render: function(record, value) {
								return value ? Date.toROC(value) : ''; 
							} 
						},
						{header:'備註', key:'MEMO'},
						{header:'債務人', key:'BORROW_TYPE_NM', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
						{header:'承辦法務', key:'INPUT_NM'},
						{header:'報表種類一', key:'REPORT_TYPE1_NM'},
						{header:'剔件原因', key:'DELETE_REASON_NM'},
						{header:'說明', key:'MEMO'},
						{header:'剔件狀態', key:'DELETE_STATUS_NM'},
						{header:'輸入人員', key:'LST_PROC_NM', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
						{header:'輸入日期', key:'LST_PROC_DATE', 
							render: function(record, value) {
								return value ? Date.toROC(value).split('.')[0] : ''; 
							} 
						},
						{header:'覆核人員', key:'CONFIRM_NM', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
						{header:'覆核日期', key:'CONFIRM_DATE', 
							render: function(record, value) {
								return value ? Date.toROC(value).split('.')[0] : ''; 
							} 
						}
                    ]
				];
				
				//條件式給table UI
				if($F('CASE')=='0'){
					actions.gridtable(gridList[0]);	
				}else{
					actions.gridtable(gridList[1]);
				}	
				
				
                ajaxPost('query', {reqMap : Object.toJSON(actions.getDataMap())}, 
                    function(resp){
                        if(CSRUtil.isSuccess(resp)){
                            var rtnList = resp.rtnList || [];
                            grid.load(rtnList);
                        } else {
                            grid.load([]);
                        }
                    }
                );
            },
            
            // 匯出
            doExport : function () {
            
                if(!valid.validate()){ 
                    return; 
                }

				var exportParams = {
				CONDITION : Object.toJSON(actions.getDataMap()),
				gridJSON : grid.getXlsSettingJSON("異常案件報表剔件")
			    }
				
				
                RPTUtil.executeCreateXlsFile('<%=dispatcher%>/DSE1_2000/export', exportParams); 
            },
			
			// 清除
			doClear : function () {
            
                valid.reset();

                //$('CRED_DEPT').value = '';
				$('INPUT_ID').value = '';
				$('DELETE_STATUS').value = $('DELETE_STATUS').options[0].value;
				if(grid){
					grid.load([]);
				}
            },
			
			// 覆核
			doConfirm : function(){
				
				var checkData = grid.getCheckedRecord(['LOAN_ID', 'BORROW_TYPE' , 'ID', 'REPORT_TYPE1', 'INPUT_ID']);
				
				if (checkData.length == 0){
					alert('請選取資料');
					return;
				}
				
				ajaxPost('confirm', {inputList : Object.toJSON(checkData), reqMap : Object.toJSON(actions.getDataMap())}, 
                    function(resp){
                        if(CSRUtil.isSuccess(resp)){
                            var rtnList = resp.rtnList || [];
                            grid.load(rtnList);
                        }
                    }
                );
			},
			
			// 取消剔件
			doCancel : function(){
				
				var checkData = grid.getCheckedRecord(['LOAN_ID', 'BORROW_TYPE' , 'ID', 'REPORT_TYPE1', 'INPUT_ID']);
				
				if (checkData.length == 0){
					alert('請選取資料');
					return;
				}
				
				ajaxPost('cancel', {inputList : Object.toJSON(checkData), reqMap : Object.toJSON(actions.getDataMap())}, 
                    function(resp){
                        if(CSRUtil.isSuccess(resp)){
                            var rtnList = resp.rtnList || [];
                            grid.load(rtnList);
                        }
                    }
                );
			}
        }
        
        // 金額格式化
        var gridFmtRender = function (record, value) {
            return (value || value === '0') ? CSRUtil.$fmt(value,'#,##0.####') : '';
        };
        

        return{
        
            initApp  : function(){
            
                PageUI.createPageWithAllBodySubElement( 
                    'DSE12000' , 
                    '法務作業' , 
                    '異常案件報表剔件覆核'  
                );


                // 查詢
                $('BTN_query').observe('click', buttons.doQuery );
                
                // 匯出
                $('BTN_export').observe('click', buttons.doExport );
                
                // 清除
                $('BTN_clear').observe('click', buttons.doClear );
                
                // 覆核
                $('BTN_confirm').observe('click', buttons.doConfirm );
                
                // 取消剔件
                $('BTN_cancel').observe('click', buttons.doCancel );
                
                // 行政中心連動
                //$('CRED_DEPT').observe('change', actions.changeCRED_DEPT );
                
                displayMessage();
                initValidation();
                
            }
        };
    }

</script>
</head>
<body>
    <form name="form1" id="form1" method="post" action="" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
        <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
            <tr>
                <td class="tbYellow" >異常案件</td>
                <td class="tbYellow2" >
                    <select name="CASE" id="CASE" class="textBox2">
                        <c:forEach items="${CASE_LIST}" var="map">
                            <option value="<c:out value='${map.key}'/>"><c:out value="${map.value}" /></option>
                        </c:forEach>
                    </select>
                </td>
                <td class="tbYellow" >承辦法務</td>
                <td class="tbYellow2" >
                    <select name="INPUT_ID" id="INPUT_ID" class="textBox2" alt="ch"> <%-- [20240215]難字調整 --%>
                        <option value="">全部</option>
						<c:forEach items="${INPUT_ID_LIST}" var="map">
                            <option value="${map.key}" >${map.value}</option>
                        </c:forEach>
                    </select>
                </td>
                <td class="tbYellow" >剔件狀態</td>
                <td class="tbYellow2" >
                    <select name="DELETE_STATUS" id="DELETE_STATUS" class="textBox2">
                        <c:forEach items="${DELETE_STATUS_LIST}" var="map">
                            <option value="<c:out value='${map.key}'/>"><c:out value="${map.value}" /></option>
                        </c:forEach>
                    </select>
                </td>
                <td class="tbYellow2">
                    <input id="BTN_query" type="button" class="button" value="查詢"/>
                    <input id="BTN_export" type="button" class="button" value="匯出"/>
			        <input id="BTN_clear" type="button" class="button" value="清除"/>
			    </td>
            </tr>
            <tr>
                <td align="center" class="tbYellow2" colspan="9">
                    <input id="BTN_confirm" type="button" class="button" value="覆核"/>
                    <input id="BTN_cancel" type="button" class="button" value="取消剔件"/>
                </td>
            </tr>
        </table>
        <table id="grid"></table>
    </form>
</body>
</html>