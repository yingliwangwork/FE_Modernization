<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSE12001.jsp
作者：謝進修
功能：異常案件報表剔件
完成：2013/03/13
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
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/popupWin.js'></script> 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/RPTUtil.js'></script>
<script type='text/javascript'>

    // 產生畫面物件
    var dse12001 = new DSE12001();
    // 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
    Event.observe(window, 'load', dse12001.initApp);
    Event.observe(window, 'resize', fix);
    Event.observe(window, 'scroll', fix);
    
    function DSE12001() {
	
        var valid;
		var inputMap;

        //共用AJAX
        var ajaxPost = function ( actionName, params, successAction){   
            new Ajax.Request( '<%=dispatcher%>/DSE1_2001/' + actionName,{  
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
        
            // 初始畫面
            prompt : function(){
            
				// 取得傳入 inputMap
                inputMap = <c:out value="${inputMap}" default="{}" escapeXml = "false"/>;
                
                var DELETE_REASON = inputMap['DELETE_REASON'] || '';
				
				// 剔件原因
				$('DELETE_REASON').value = DELETE_REASON;
				
				// 按鈕控制
				if (DELETE_REASON) {
					$('BTN_insert').disabled = true;
					$('BTN_update').disabled = false;
					$('BTN_delete').disabled = false;
				} else {
					$('BTN_insert').disabled = false;
					$('BTN_update').disabled = true;
					$('BTN_delete').disabled = true;
				}
            }
        }
        
        var buttons = {
            
            // 新增
            doInsert : function(){
			
				valid.reset();
				valid.clear();
				
				var DELETE_REASON = $F('DELETE_REASON');
				
				if ('16' == DELETE_REASON) { // 當 DELETE_REASON 的 value 為16 時，下拉選單選項為「其他」
					valid.define( 'required' , [{ id : 'MEMO'}] );
				}
            
                if(!valid.validate()){ 
                    return;
                }
            
                ajaxPost('insert', {inputMap : Object.toJSON(inputMap), DELETE_REASON : DELETE_REASON, MEMO : $F('MEMO')}, 
                    function(resp){
                        if(CSRUtil.isSuccess(resp)){
                            $('BTN_insert').disabled = true;
							$('BTN_update').disabled = false;
							$('BTN_delete').disabled = false;
                        }
                    }
                );
            },
            
            // 修改
            doUpdate : function () {
            
				valid.reset();
                valid.clear();
				
				var DELETE_REASON = $F('DELETE_REASON');
				
				if ('16' == DELETE_REASON) { // 當 DELETE_REASON 的 value 為16 時，下拉選單選項為「其他」
					valid.define( 'required' , [{ id : 'MEMO'}] );
				}
            
                if(!valid.validate()){ 
                    return;
                }
            
                ajaxPost('update', {inputMap : Object.toJSON(inputMap), DELETE_REASON : DELETE_REASON, MEMO : $F('MEMO')}, 
                    function(resp){
                        if(CSRUtil.isSuccess(resp)){
                            $('BTN_insert').disabled = true;
							$('BTN_update').disabled = false;
							$('BTN_delete').disabled = false;
                        }
                    }
                );
            },
			
			// 刪除
			doDelete : function () {

				valid.reset();
				
                ajaxPost('delete', {inputMap : Object.toJSON(inputMap), DELETE_REASON : $F('DELETE_REASON'), MEMO : $F('MEMO')}, 
                    function(resp){
                        if(CSRUtil.isSuccess(resp)){
                            $('BTN_insert').disabled = true;
							$('BTN_update').disabled = true;
							$('BTN_delete').disabled = true;
                        }
                    }
                );
            },
			
			// 關閉
			doClose : function(){
				if(window['callbackHandler']){
					callbackHandler('');
				} else if (parent.popupWin != null && parent.popupWin.callbackHandler) {
					parent.popupWin.callbackHandler('');
				}
				close();
			}
        }
        
        return{
        
            initApp  : function(){
            
                PageUI.createPageWithAllBodySubElement( 
                    'DSE12001' , 
                    '法務作業' , 
                    '異常案件報表剔件'  
                );

                // 新增
                $('BTN_insert').observe('click', buttons.doInsert );
                
                // 修改
                $('BTN_update').observe('click', buttons.doUpdate );
                
                // 刪除
                $('BTN_delete').observe('click', buttons.doDelete );
                
                // 關閉
                $('BTN_close').observe('click', buttons.doClose );
                
                displayMessage();
                initValidation();
				actions.prompt();
            }
        };
    }

</script>
</head>
<body>
    <form name="form1" id="form1" method="post" action="" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
        <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
            <tr>
                <td class="tbYellow" width="15%">貸款帳號</td>
                <td class="tbYellow2" width="85%">
                    ${LOAN_ID}
                </td>
			</tr>
			<tr>
                <td class="tbYellow">原貸帳號</td>
                <td class="tbYellow2">
                    ${REFER_ID}
                </td>
			</tr>
			<tr>
                <td class="tbYellow">報表種類一</td>
                <td class="tbYellow2">
                    ${REPORT_TYPE1}
                </td>
			</tr>
			<tr>
                <td class="tbYellow">剔件原因</td>
                <td class="tbYellow2">
                    <select name="DELETE_REASON" id="DELETE_REASON" class="textBox2 validate-selection"  fieldName="剔件原因">
						<option value="">請選擇</option>
                        <c:forEach items="${DELETE_REASON_LIST}" var="row">
                            <option value="${row.key}" />${row.value}</option>
                        </c:forEach>
                    </select>
                </td>
			</tr>
			<tr>
                <td class="tbYellow">說明</td>
                <td class="tbYellow2">
                    <input id="MEMO" name="MEMO" type="text" class="textBox2"  size = "80"  maxlength = "100" value="${MEMO}" fieldName="說明"/>
                </td>
			</tr>
            <tr>
                <td align="center" class="tbYellow2" colspan="2">
					<input id="BTN_insert" type="button" class="button" value="新增" disabled/>
			        <input id="BTN_update" type="button" class="button" value="修改" disabled/>
                    <input id="BTN_delete" type="button" class="button" value="刪除" disabled/>
                    <input id="BTN_close" type="button" class="button" value="關閉"/>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>