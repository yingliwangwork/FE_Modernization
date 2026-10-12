<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC30600.jsp
作者：卓達瑋
功能：銀行轉帳確認
完成：2013/05/15
[2019.06.18]修改
1.移除【抽件確認】與【扣款件匯檔】前後關連
2.註解按鈕【扣款件匯檔 5000筆自動分檔】
3.新增按鈕【扣款件預覽】
4.新增按鈕【抽件覆核】
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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>		<%-- 匯出檔案用 --%>
<script type="text/JavaScript">

Event.observe(window, 'load', new DSC30600().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC30600(){
	
	//檢核
	var valid1;	
    //紀錄筆數
	var z;
	//紀錄查詢條件
	var queryMap_rc;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC3_0600/');//[2019.06.18]
	
	//檢核欄位
	function initValidation(){
		valid1 = new Validation("form1", { focusOnError:true, immediate:false});				
 	    Validation.addAllThese( [
			[ 'valid_credit', '',
				function( value , elem ) {
                    
					if(value && value.length!=5){ return false; }

					return true;
				}
			]
			
		]);
		valid1.define('valid_credit' , [{ id : "TRANS_YM" , errMsg:'抽件年月格式錯誤(YYYMM)!!'}] );
		valid1.define('required' , [{ id : "TRANS_YM" , errMsg:'請輸入抽件年月!!'}] );
		valid1.define('required' , [{ id : "TRANS_GROUP" , errMsg:'請選擇轉帳組別!!'}] );
		valid1.define('required' , [{ id : "TRANS_BANK" , errMsg:'請選擇轉帳銀行!!'}] );
	}		
    //按鈕授權
		function buttonAuth() {
			var authButtons = { 
				B0028 : 'BTN_CONFIRM'   <%--抽件確認--%>,
				B0021 : 'BTN_EXPORT'    <%--扣款件匯檔--%>,
				B0021 : 'BTN_PREVIEW'	<%--扣款媒體檔預覽--%>,//[2019.06.18]
				B0070 : 'BTN_MANAGER_CONFIRM'	<%--抽件覆核--%>,//[2019.06.18]
			};
			<dz:grantButtons FUNC_ID="DSC30600"/>
		}
	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_0600/" + actionName,
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
				'TRANS_YM' : $F('TRANS_YM'), 
				'TRANS_GROUP' : $F('TRANS_GROUP'), 
                'TRANS_BANK' : $F('TRANS_BANK') 				
			}		
	    },
		//查詢後長欄位
		appendTable :function (j,rtnList){
            
			var tr = new Element('tr');
			var td1 = actions.makeTr({className : 'tbYellow',width:"10%" },rtnList[j].TRANS_BANK_NM+'抽件完成件數');
			var span = new Element('span' , {id :'TRANS_CNT_'+ j } );
			var span1 = new Element('span' , {id :'TRANS_CNT_NM_'+ j } ).update("件");
			var td2 = actions.makeTr({className : 'tbYellow2',width:"20%"},span);
			td2.insert(span1);
			var td3 = actions.makeTr({className : 'tbYellow',width:"10%"},'抽件完成金額');
			var span2 = new Element('span' , {id :'TRANS_AMT_'+ j } );	
			var span3 = new Element('span' , {id :'TRANS_AMT_NM_'+ j } ).update("元");
			var td4 = actions.makeTr({className : 'tbYellow2',width:"20%"},span2);
			td4.insert(span3);
			var input1 = new Element('input' , {type :'hidden' ,  id : 'TRANS_YM_OLD_'+ j } );	
			var input2 = new Element('input' , {type :'hidden' ,  id : 'TRANS_GROUP_OLD_'+ j } );	
			var input3 = new Element('input' , {type :'hidden' ,  id : 'TRANS_BANK_OLD_'+ j } );	
			var input4 = new Element('input' , {type :'hidden' ,  id : 'TRANS_STATUS_'+ j } );	
			tr.insert(td1).insert(td2).insert(td3).insert(td4).insert(input1).insert(input2).insert(input3).insert(input4);
			$('appendArea').insert(tr);
			z++;
	
        },
		//設定欄位屬性
		makeTr :function(status , obj){
			var td = new Element('td' , status );
			td.update(obj);
			return td;
		},	
	    // 數值顯示方式處理
	    numberFormat : function (value) {
			return value ? MoneyFormat(value) : '';
		},
        //取查詢後欄位值存入list
		getlist :function (){
			var list = [];
			for(var k = 0 ; k <z ; k ++){
				var tempMap = {};
				$w('TRANS_YM TRANS_GROUP TRANS_BANK').each(
					function(ele){
						tempMap[ele]=$(ele+'_OLD_'+k).getValue();
					}
			    )
				tempMap['TRANS_STATUS']=$('TRANS_STATUS_'+k).getValue();
				$w('TRANS_AMT TRANS_CNT').each(
					function(ele){
						tempMap[ele]=$(ele+'_'+k).innerHTML.replace(/,/g,"");
					}
			    )
				tempMap['INPUT_ID']=$F('INPUT_ID');
				list.push(tempMap);	
				
			}
			
			return list;
		},
        //查詢後成功共同方法
		dosuccessAction : function(resp){
		    var rtnList=resp.rtnList;
			$('appendArea').update('');	 //清空一次長出的欄位
            z=0;			
			for(var j=0;j<rtnList.length;j++){
				actions.appendTable(j,rtnList);
				$('TRANS_YM_OLD_'+j).setValue(rtnList[j].TRANS_YM); 
				$('TRANS_GROUP_OLD_'+j).setValue(rtnList[j].TRANS_GROUP); 
				$('TRANS_BANK_OLD_'+j).setValue(rtnList[j].TRANS_BANK);
				$('TRANS_STATUS_'+j).setValue(rtnList[j].TRANS_STATUS);
				$('TRANS_AMT_'+j).update(actions.numberFormat(rtnList[j].TRANS_AMT)); 
				$('TRANS_CNT_'+j).update(actions.numberFormat(rtnList[j].TRANS_CNT)); 				
			}
			
            if(rtnList[0].TRANS_STATUS=='1'){
			   $('BTN_CONFIRM').enable();
			   $("BTN_MANAGER_CONFIRM").enable();//[2019.06.18]新增
			   $('BTN_EXPORT').enable();//[2019.06.18]改為enable
			}
            if(rtnList[0].TRANS_STATUS=='2'){
			   $('BTN_CONFIRM').disable();
			   $("BTN_MANAGER_CONFIRM").disable();//[2019.06.18]新增
			   $('BTN_EXPORT').enable();
			}
            $('BTN_PREVIEW').enable();//[2019.06.18]新增		
		}
	}	
	// 功能按鈕
	var button = {
			
		// 查詢
		doQuery: function() {	
			//檢核

			if(!valid1.validate()){				
				return; 
			}
			//紀錄查詢條件
			queryMap_rc=actions.queryMap();
			ajaxPost( 'query', {'queryMap' : Object.toJSON(queryMap_rc)}
				,function(resp){  
				    $('titleA').update(''); //每次清除title欄位
					var tr = new Element('tr');
		         	var td1 = actions.makeTr({className : 'tbYellow0',width:"10%", align:"center",colspan:4 },"<b>銀行轉帳抽件結果</b>");
					tr.insert(td1);
					$('titleA').insert(tr);
					actions.dosuccessAction(resp);	
				}
				,function(resp){
                    $('appendArea').update('');
					$('BTN_CONFIRM').disable();//[2019.06.18]
					$('BTN_EXPORT').disable();//[2019.06.18]
					//$('BTN_PREVIEW').disable();//[2019.06.18]
					$("BTN_MANAGER_CONFIRM").disable();//[2019.06.18]
				}
			);
		},
		//抽取確認
        doconfirm :function(){		 	
            var queryMap_N=actions.queryMap();
			//[2019.06.18]TODO
			queryMap_N.AddfetchSize = 150000;			
		    for(key in queryMap_rc){
			   if(queryMap_rc[key]!=queryMap_N[key]){
			        alert("與查詢時的資訊不同,請先查詢後再作業!!");
			        return;
				}
			}
			ajaxPost( 'confirm', {'dataList' :Object.toJSON(actions.getlist()), 'exportMap' : Object.toJSON(queryMap_N)}//TODO
				,function(resp){
				    actions.dosuccessAction(resp);	
				}
			);	
		},
		//扣款件匯檔
        doexport :function(){
		 	var queryMap_N=actions.queryMap();  
		 	queryMap_N.AddfetchSize = 150000; //目前轉帳筆數先給15萬,若發生有再分檔的狀況,則再加大數字		
		    for(key in queryMap_rc){
			   if(queryMap_rc[key]!=queryMap_N[key]){
					alert("與查詢時的資訊不同,請先查詢後再作業!!");
					return;
			    }
			}	
			RPTUtil.downloadFile( '<%=dispatcher%>/DSC3_0600/exprotData', {'exportMap' : Object.toJSON(queryMap_N)});
		},
		//[2019.06.18]扣款媒體檔預覽
		dopreview : function(){
		 	var queryMap_N=actions.queryMap();  
		 	queryMap_N.AddfetchSize = 150000; //目前轉帳筆數先給15萬,若發生有再分檔的狀況,則再加大數字		
		    if(!valid1.validate()){				
				return; 
			}
		    <%--for(key in queryMap_rc){
			   if(queryMap_rc[key]!=queryMap_N[key]){
					alert("與查詢時的資訊不同,請先查詢後再作業!!");
					return;
			    }
			}--%>
			<%--發送AJAX--%>
			ajaxRequest.post('preview', {
					exportMap : Object.toJSON(queryMap_N)
				},
				function(resp){
					var isZIP = resp.isZIP;
					if (isZIP) {
						<%-- ZIP檔 --%>
						popupWin.popup({									
							src : '/ZZWeb/servlet/HttpDispatcher/ZZZR_0100/prompt' ,
							width : '95%',
							height : '95%',						
							scrolling : 'yes',	
							parameters : { 	
								fileFullPath : resp.fileFullPath
							}	
						});
					} else {
						<%-- 文字檔 --%>
						var dataMap = {
						 'encryptTempFileFullPath': resp.filePath
						};										
						RPTUtil.executeSecurityPrintHandler(dataMap);
					}
				}
			);
		},
		//抽件覆核 //[2019.06.18]
        doManagerConfirm :function(){		 	
            var queryMap_N=actions.queryMap();
			queryMap_N.AddfetchSize = 150000;			
		    for(key in queryMap_rc){
			   if(queryMap_rc[key]!=queryMap_N[key]){
			        alert("與查詢時的資訊不同,請先查詢後再作業!!");
			        return;
				}
			}
			ajaxPost( 'managerConfirm', {'dataList' :Object.toJSON(actions.getlist()), 'exportMap' : Object.toJSON(queryMap_N)}//TODO
				,function(resp){
				    actions.dosuccessAction(resp);	
				}
			);	
		},
		//扣款件匯檔5000(先預留,暫時不開放使用)
		//[2019.06.18]註解
		/*
        doexport_5000 :function(){
		 	var queryMap_N=actions.queryMap();  
		 	queryMap_N.AddfetchSize = 0;		
		    for(key in queryMap_rc){
			   if(queryMap_rc[key]!=queryMap_N[key]){
					alert("與查詢時的資訊不同,請先查詢後再作業!!");
					return;
			    }
			}	
			RPTUtil.downloadFile( '<%=dispatcher%>/DSC3_0600/exprotData', {'exportMap' : Object.toJSON(queryMap_N)});
		}
		*/
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSC30600" , "繳款方式", "銀行轉帳確認" );

			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			//按鈕權限
            buttonAuth();	
			//畫面檢核
			initValidation();
			// 監聽
			$("BTN_QUERY").observe('click', button.doQuery);
            $("BTN_CONFIRM").observe('click', button.doconfirm);
			$("BTN_EXPORT").observe('click', button.doexport);
			$("BTN_PREVIEW").observe('click', button.dopreview);//[2019.06.18]扣款媒體檔預覽
			$("BTN_MANAGER_CONFIRM").observe('click', button.doManagerConfirm);//[2019.06.18]抽件覆核
			//$("BTN_EXPORT_5000").observe('click', button.doexport_5000);
			$('BTN_CONFIRM').disable();
			$('BTN_EXPORT').disable();
			//$('BTN_PREVIEW').disable();
			$("BTN_MANAGER_CONFIRM").disable();
			
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
	    <input type="hidden"  id="INPUT_ID" value="${INPUT_ID}">
		<td class='tbYellow' width='15%'>
			抽件年月
		</td>
		<td class='tbYellow2' width='10%'>
			<input id='TRANS_YM'  type="text" class= 'textBox2'   size='8' maxlength='5' value="${SYS_DATE}"/> 
		</td>
	
	
		<td class='tbYellow' width='15%'>
			轉帳組別
		</td>
		<td class='tbYellow2' width='10%'>
			<select id="TRANS_GROUP" class="textBox2">
				<option value="">請選擇</option>
				<c:forEach items="${TRANS_GROUP_List}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class='tbYellow' width='15%'>
			轉帳銀行
		</td>
		<td class='tbYellow2' width='10%'>
			<select id="TRANS_BANK" class="textBox2">
				<option value="">請選擇</option>
				<c:forEach items="${TRANS_BANK_List}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow2" width="10%" align="center">
			<input type="button" class="button" id="BTN_QUERY" value="抽件查詢"/>					
		</td>
	</tr>
    <tr>
	    <td class="tbYellow2" width="10%" align="center" colspan='7'>
			<input type="button" class="button" id="BTN_EXPORT" value="扣款件匯檔"/>
			<input type="button" class="button" id="BTN_PREVIEW" value="扣款媒體檔預覽"/>
			<input type="button" class="button" id="BTN_CONFIRM" value="抽件確認"/>
			<input type="button" class="button" id="BTN_MANAGER_CONFIRM" value="抽件覆核"/>			
			<!--
		    <input type="button" class="button" id="BTN_EXPORT_5000" value="扣款件匯擋(5000筆自動分檔)" disabled/>
			-->
		</td>			
	</tr>

</table>
<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
	<tbody id = "titleA" >																	
	</tbody>
	<tbody id = "appendArea" >																	
	</tbody>
</table>
</form>

</body>
</html>	