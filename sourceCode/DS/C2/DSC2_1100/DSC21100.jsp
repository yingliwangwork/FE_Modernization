<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC21100.jsp
作者：卓達瑋
功能：帳務轉出作業
完成：2013/05/07
220628問題單20220628-0098 E848236496要帳務轉出，但畫面上繳息紀錄序號只能輸入兩碼，無法轉出144期序號126~128 BY余凱鈞
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/JavaScript">

Event.observe(window, 'load', new DSC21100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC21100(){
	var tempMap={};
	var grid;
	//檢核
	var valid1;	
    var valid2;
    //按鈕權限紀錄	
	var legal2;
	//檢核欄位
	function initValidation(){
		valid1 = new Validation("form1", { focusOnError:true, immediate:false});				
 	    valid1.define('required' , [{ id : "LOAN_ID" , errMsg:'請輸入貸款帳號查詢!!'}] );
		valid1.define('required' , [{ id : "PAY_TERM" , errMsg:'請輸入繳款期數查詢!!'}] );		
		//valid1.define('required' , [{ id : "SEQ_NO" , errMsg:'請輸入序號查詢!!'}] ); //目前未用到
		valid2 = new Validation("form1", { focusOnError:true, immediate:false});	
        valid2.define('validate-number' , [{ id : "PAY_TERM" , errMsg:'繳款期數有誤，無法作業!!!'}] );
		//valid2.define('validate-number' , [{ id : "SEQ_NO" , errMsg:'序號有誤，無法作業!!!'}] ); //未用到先保留
		
	}		
    //按鈕授權
		
		function buttonAuth() {
			var authButtons = { 
				B0171 : 'BTN'    <%--轉出--%>
			};
			<dz:grantButtons FUNC_ID="DSC21100"  ignored='false'/>
	        legal2=legal;
		}
	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_1100/" + actionName,
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
	};
	var actions= {
        //將畫面寫入Map	
	    queryMap : function(){
			return  {
				'LOAN_ID' : $F('LOAN_ID'), 
				'PAY_TERM' : $F('PAY_TERM'), 
				'PAY_KIND' : $F('PAY_KIND'),
                'SEQ_NO' : $F('SEQ_NO') 				
			}		
	    }
		
	}	
	// 功能按鈕
	var button = {
			
		// 查詢
		doQuery: function() {	
		    
			valid2.reset();
			//檢核
			if(!valid1.validate()){				
				return; 
			}
			ajaxPost( 'query', {'reqMap' :Object.toJSON(actions.queryMap())}
				,function(resp){
				    grid.load(resp.rtnList);	
				}
				,function(resp){
                    grid.load([]);
				}
			);
		},
        //轉出
        ActionExport :function(dataObj){

			valid1.reset();
			//檢核
			if(!valid2.validate()){				
				return; 
			}	
            if( $F('LOAN_ID')!=dataObj.OLD_LOAN_ID){
			    alert("欲轉出的貸款帳號與原先查詢的資料不同，無法作業!");
				return;
			}		
			dataObj.EXPORT_DEPT=$F('EXPORT_DEPT');
			ajaxPost( 'actionExport', {'ExportMap' :Object.toJSON(dataObj),'reqMap':Object.toJSON(actions.queryMap())}
				,function(resp){
				    grid.load(resp.rtnList);	
				}
			);	
		}	
		
	};
	
	return {
		initApp : function() {
		    <c:forEach var="map" items="${EXPORT_REASON_Map}">
				tempMap["${map.key}"]="${map.value}";
			</c:forEach>

			PageUI.createPageWithAllBodySubElement( "DSC21100" , "收息帳務", "帳務轉出作業" );
            grid = new TableUI(
				{table: $("grid"), allSortable: true, pageSize: 20,allSortable:false,split:['RETAIN_INT'],		
				column:[					
					{header:"期數",key:"PAY_TERM",
					    render : function (rec , val){
							return "<span class = 'textRed'>" + val+ "</span>";									
						}  
					},	
					{header:"繳別",key:"PAY_KIND_NM"},	
					{header:"序號",key:"SEQ_NO"},
					{header:"計息起日",key:"INT_BEGDT",
					    render : function (rec , val){
							if(rec.PAY_KIND!='5'){
							return Date.toROC(val ||"");									
						    }
						    return '';
						}
					},
					{header:"計息終日",key:"INT_ENDDT",
					    render : function (rec , val){
							if(rec.PAY_KIND!='5'){
							return Date.toROC(val || "");									
						    }
						    return '';
						}
					},
					{header:"實繳日",key:"REAL_PAYDT",
					    render: function (rec,val){
							return Date.toROC(val || "");	
						}
					
					},
					{header:"繳前本金",key:"LAST_PRINCIPAL",
					    render: function (rec,value){
							if(rec.PAY_KIND!='5'&&(value != null && value != "") ){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"利率",key:"RATE",
					    render: function (rec,value){
							if(rec.PAY_KIND!='5'&&(value != null && value != "") ){
								return value;
							}
							return "";
						}
					    
					
					},
					{header:"本金",key:"PRINCIPAL",
					    render: function (rec,value){
							if( rec.PAY_KIND!='5'&&(value != null && value != "") ){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"利息",key:"INTEREST",
					    render: function (rec,value){
							if( rec.PAY_KIND!='5'&&(value != null && value != "")){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"轉出",key:"",attrs:{rowSpan:2},
					    render : function( rec , val){							
									var check = new Element("input" , {type : 'button' , value : '轉出' , className : 'button',id:'BTN_EXPORT'} );
									check.observe("click", function(event){
										var tr=this.up('tr');
										dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
										if(dataObj.EXPORT_REASON==null){
										dataObj.EXPORT_REASON='1';
										}
										button.ActionExport(dataObj);										
									});  
									//按鈕控制
                                    if(legal2!='B0171'){
									   check.disable();
									}           							
									var span = new Element('span');
									span.insert(check);
									
									
									
									return span;  
								}	
					
					},

					{header:"應利",key:"RETAIN_INT",
					    render: function (rec,value){
							if( rec.PAY_KIND!='5'&&(value != null && value != "") ){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"延滯息",key:"DELAY_INT",
					    render: function (rec,value){
							if( rec.PAY_KIND!='5'&&(value != null && value != "") ){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"違約金",key:"RENEGE",
					    render: function (rec,value){
							if( rec.PAY_KIND!='5'&&(value != null && value != "") ){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"訴訟管理費",key:"LAWSUIT_FEE",
					    render: function (rec,value){
							if( rec.PAY_KIND!='5'&&(value != null && value != "")){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"代扣稅款",key:"TAX",
					    render: function (rec,value){
							if( rec.PAY_KIND!='5'&&(value != null && value != "") ){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"上期結餘",key:"LAST_BALANCE",
					    render: function (rec,value){
							if( rec.PAY_KIND!='5'&&(value != null && value != "") ){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"繳款方式",key:"PAY_TYPE_NM"},
					{header:"票據狀態",key:"CHECK_STATUS_NM"},
					{header:"入帳單位",key:"ACNT_DEPT"},
					{header:"轉出原因",key:"EXPORT_REASON",	    
						render : function( rec , val){								
									var input1 = new Element("select", {id:"EXPORT_REASON"});
									for(key in tempMap){
										input1.add(new Option(tempMap[key],key));
									}
                                    						
									input1.observe('change', function(event){
									    var tr=this.up('tr');
										dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
										
										dataObj.EXPORT_REASON=event.target.value;
									    }   
									);
									var input2 = new Element("input" , {type : 'TEXT',size:35,maxlength:30 ,id:'EXPORT_MEMO'} );										
									
									input2.observe('change', function(event){
									    var tr=this.up('tr');
										dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									    dataObj.EXPORT_MEMO=event.target.value;
									    }

									);
									var span = new Element('span');
									span.insert(input1);
									span.insert(input2);
									return span;  
						}
					}	
				]
			});
			
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
				
			//畫面檢核
			initValidation();
			// 監聽
			$("BTN_QUERY").observe('click', button.doQuery);
            //Input欄位自動轉大寫
			$('LOAN_ID').observe('change',function(){
				$('LOAN_ID').value = $F('LOAN_ID').toUpperCase();
			});	

			//按鈕權限
            buttonAuth()			
			PageUI.resize();	
			displayMessage();
		}
	}
}
</script>
</head>
<body>
<form name="form1" id="form1"  style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" >

<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
	<tr>
	    <input type="hidden" id="EXPORT_DEPT" value="${EXPORT_DEPT}" />
		<td class='tbYellow' width='15%'>
			貸款帳號
		</td>
		<td class='tbYellow2' width='10%'>
			<input id='LOAN_ID' type='text' class= 'textBox2'   size='12' maxlength='10' value="${LOAN_ID}"/> 
		</td>
		<td class='tbYellow' width='15%'>
			繳款期數
		</td>
		<td class='tbYellow2' width='10%'>
			<input id='PAY_TERM' type='text' class= 'textBox2'   size='6' maxlength='3' value="${PAY_TERM}"/> 
		</td>
		<td class='tbYellow' width='15%'>
			序號
		</td>
		<td class='tbYellow2' width='10%'>
			<input id='SEQ_NO' type='text' class= 'textBox2'   size='5' maxlength='4' value="${SEQ_NO}"/> 
		</td>
		<td class='tbYellow' width='15%'>
			繳款別
		</td>
		<td class='tbYellow2' width='10%'>
			<select id="PAY_KIND" class="textBox2">
				<c:forEach items="${PAY_KIND_LIST}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		
		<td class="tbYellow2" width="10%" align="center">
			<input type="button" class="button" id="BTN_QUERY" value="查詢"<%-- 查詢 --%> />	
				
		</td>
	</tr>
</table>
<table id='grid' width='100%'></table>
</form>

</body>
</html>	