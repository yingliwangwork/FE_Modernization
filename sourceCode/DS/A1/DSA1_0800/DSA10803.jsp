<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSA10803.jsp
作者：i9300617 張恆勖
功能：退件輸入作業
完成：2014-09-04

[20210824]修改件:
新增1.4.2	借款人查調公務機關資料授權書補簽名欄位資料
 -->

<html>
<head>
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<fmt:setBundle basename="TextResource" />

<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css" />

<title></title>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script> 
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/javascript">

var DSA10803 = new DSA10803();

//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', DSA10803.initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSA10803(){
	
	var valid1;
	
	// 建立 ajax request 物件
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA1_0803/');  
	
	//畫面檢核
	function initValidation(){
		valid1 = new Validation('form1', {useTitles:false});		
		valid1.define( "required" , { id: "REJECT_NOTE" , errMsg :"退件說明不可為空白"  } );	
		//valid1.define( "required" , { id: "REJECT_ITEM_NAME" , errMsg :"應補文件至少選取一件"  } );
		
		//220126申請書-NAP新業務平台─通知(放款) BY余凱鈞，調整退件說明內容長度限制
		Validation.addAllThese([					
			[ 'checkLength',  '退件說明輸入長度超過最大長度(最多100字)',
				function(value,elem){  
					return value ? value.length < 101 : true;					
				}
			]			
		]);
	}
	
	//--------------------------------------------------------------------------
	// 功能按鈕
	//--------------------------------------------------------------------------		
	var buttons = {				
		
		<!--查詢-->
		doQuery: function(){														
			
			<!--發送AJAX-->
			ajaxRequest.post( 'query', {KIND : '${KIND}', APPLY_ID: '${APPLY_ID}'}
				,function(resp){
					var rtnList = resp.rtnList || [];
					var dataLength = rtnList.length;
					
					<!--動態產生checkBox-->
					for(var i=0;i<dataLength;i++){
						var rtnData = rtnList[i];
						var ITEM = rtnData['ITEM'];
						var checkbox = new Element('input', {'type' : 'checkbox', 'value' : ITEM, 'ITEM_NAME' : rtnData['ITEM_NAME'], 'KIND': rtnData['KIND'], 'GUAR_NAME':rtnData['NAME']||'', 'GUAR_ID':rtnData['ID']||'', 'SEQNO':i});
						
						var span = new Element('span', { 'id' : rtnData['ITEM'] + '_SPAN'})
						.insert(checkbox)
						.insert(ITEM == '02'&& rtnData['KIND'] == 'A'?rtnData['NAME']+ rtnData['ITEM_NAME']: rtnData['ITEM_NAME']);
						
						if('2' == '${KIND}'){
							var selectElement = new Element('select', {name:'PICTURE_TYPE'+i});
							selectElement.update().insert(new Element('option', {value: ""}).update("請選擇"));
							if('A' == rtnData['KIND'] && ('01' == ITEM || '02' == ITEM)){   
								<c:forEach var="map" items="${PICTURE_TYPE_A01}">
								selectElement.insert(new Element('option', {value: "${map.key}"}).update("${map.value}"));
								</c:forEach>
								span.insert(selectElement);
							} else if('03' == ITEM){   
								<c:forEach var="map" items="${PICTURE_TYPE_A03}">
								selectElement.insert(new Element('option', {value: "${map.key}"}).update("${map.value}"));
								</c:forEach>
								span.insert(selectElement);
							} else if('04' == ITEM){   
								<c:forEach var="map" items="${PICTURE_TYPE_A04}">
								selectElement.insert(new Element('option', {value: "${map.key}"}).update("${map.value}"));
								</c:forEach>
								span.insert(selectElement);
							} else if('05' == ITEM){   
								<c:forEach var="map" items="${PICTURE_TYPE_A05}">
								selectElement.insert(new Element('option', {value: "${map.key}"}).update("${map.value}"));
								</c:forEach>
								span.insert(selectElement);
							} else if('07' == ITEM){   
								<c:forEach var="map" items="${PICTURE_TYPE_A07}">
								selectElement.insert(new Element('option', {value: "${map.key}"}).update("${map.value}"));
								</c:forEach>
								span.insert(selectElement);
							} else if('12' == ITEM){   
								<c:forEach var="map" items="${PICTURE_TYPE_A12}">
								selectElement.insert(new Element('option', {value: "${map.key}"}).update("${map.value}"));
								</c:forEach>
								span.insert(selectElement);
							} 
						}
						
						$('ITEM_SPAN').insert(span).insert(new Element('br', {'id' : rtnData['ITEM'] + '_BR'}));	
						//[20210824]借款人達調公務機關資料授權書簽名連動checkbox
						if('20' == ITEM){
							$('ITEM_SPAN').insert(new Element('span')).insert(new Element('input', {'type' : 'checkbox', 'value' : 'jcic_t50s', 'name' : 'jcic', 'ITEM_NAME' : 'JCIC_T50', disabled:true})).insert('T50所得資料');
							$('ITEM_SPAN').insert(new Element('span')).insert(new Element('input', {'type' : 'checkbox', 'value' : 'jcic_t50s', 'name' : 'jcic', 'ITEM_NAME' : 'JCIC_T51', disabled:true})).insert('T51財產清單');
							$('ITEM_SPAN').insert(new Element('span')).insert(new Element('input', {'type' : 'checkbox', 'value' : 'jcic_t50s', 'name' : 'jcic', 'ITEM_NAME' : 'JCIC_T52', disabled:true})).insert('T52勞保資料').insert(new Element('br'));
						}
					}
					$$('#20_SPAN [type=checkbox]').each(function(elm){
						elm.observe('change', function(){
							if(this.checked){
								$$('input[name="jcic"]').each(function(ele){
									ele.disabled = false;
								}) 
							}else{
								$$('input[name="jcic"]').each(function(ele){
									ele.disabled = true;
								})
							}
						});	
					});	
				}				
			);
		},	
		
		<!--確認-->
		doReject: function(){	
			
			//[20210824]新增檢核:若勾選「借款人查調公務機關資料授權書簽名」T50~52需至少勾選其一
			var jcic_t50 = $$('input[name="jcic"]');
			var checkboxValidateYN = true;
			$$('#20_SPAN [type=checkbox]:checked').each(function(){
				checkboxValidateYN = false;
				for(var i=0; i<jcic_t50.length; i++){
					if(jcic_t50[i].checked){
						checkboxValidateYN = true;
						break;
					}
				}
			});
			if(!checkboxValidateYN){
				alert('若勾選「借款人查調公務機關資料授權書簽名」T50~52需至少勾選其一');
				return;
			}
			
			var REJECT_ITEMs = [];
			var index = 0;
			var jcic_t50s = [];//取得勾選連棟資料
			$$('input[type=checkbox]:checked').each(
				function(checkbox) {
					var ITEMs = checkbox.getValue();
					var KIND = checkbox.getAttribute('KIND');
					var SEQNO = checkbox.getAttribute('SEQNO');
					var PICTURE_TYPE = '';
					
					if('2' == '${KIND}'){
						if('A' == KIND && ('01' == ITEMs || '02' == ITEMs)){   
							PICTURE_TYPE = $('PICTURE_TYPE'+SEQNO).value;
						} else if('03' == ITEMs || '04' == ITEMs || '05' == ITEMs || '07' == ITEMs || '12' == ITEMs){   
							PICTURE_TYPE = $('PICTURE_TYPE'+SEQNO).value;
						//[20210824]1.4.2借款人查調公務機關資料授權書補簽名資料
						} else if('jcic_t50s' == ITEMs){
							var theItemName = checkbox.getAttribute('ITEM_NAME');
							jcic_t50s.push(theItemName);
							return;
						} else if('20' == ITEMs){
							var dataMap = {'ITEM': ITEMs, 'KIND':KIND, 'NAME':checkbox.getAttribute('GUAR_NAME'), 'ID':checkbox.getAttribute('GUAR_ID'), 
									'PICTURE_TYPE':PICTURE_TYPE, 'JCIC_T50' : 'N', 'JCIC_T51' : 'N', 'JCIC_T52' : 'N'};
							REJECT_ITEMs.push(dataMap);
							return;
						}
					}
					
					var dataMap = {'ITEM': ITEMs, 'KIND':KIND, 'NAME':checkbox.getAttribute('GUAR_NAME'), 'ID':checkbox.getAttribute('GUAR_ID'), 'PICTURE_TYPE':PICTURE_TYPE};
					REJECT_ITEMs.push(dataMap);
				}
			);
			
			//[20210824]連動勾選資料連同「借款人查調公務機關資料授權書補簽名」一起放入
			if(jcic_t50s != []){
				for(var i=0; i<REJECT_ITEMs.length; i++){
					if('20'==REJECT_ITEMs[i]['ITEM']){
						for(var j=0; j<jcic_t50s.length; j++){
							REJECT_ITEMs[i][jcic_t50s[j]] = "Y";
						}
					}
				}
			}
			
			if(!valid1.validate()){
				return;
			}
			var msg;
			if('1' == '${KIND}'){
				msg = '確定要將此件退回服務中心？';
			}else if('2' == '${KIND}'){
				msg = '確定要將此件退回經手人？';
			}
			if(!confirm(msg)){
				return;
			}
						
			var reqMap = {	APPLY_ID: '${APPLY_ID}',
							KIND	: '${KIND}',
							REJECT_NOTE : $F('REJECT_NOTE'),
							REJECT_ITEM : REJECT_ITEMs,
							SOURCE : '${SOURCE}'
			};
									
			<!--發送AJAX-->
			ajaxRequest.post( 'reject', {reqMap : Object.toJSON(reqMap)}
				,function(resp){
					if(window['callbackHandler']){
						callbackHandler({});
					}else if(parent.popupWin.callbackHandler){
						parent.popupWin.callbackHandler({});
					}
					alert('退回完成');
					parent.popupWin.close();
				}				
			);
		},
			
		<!--關閉-->			
		doClose: function(){															
			parent.popupWin.close();
		},
	
		<!--產生說明-->
		doMEMO: function(){	
			$('REJECT_NOTE').setValue("");//初始化
			valid1.reset();
			var REJECT_ITEM_NAME = '';
			$$('input[type=checkbox]:checked').each(
				function(checkbox) {
					//[20210824]調整「借款人查調公務機關資料授權書補簽名」名稱
					if(checkbox.name != 'jcic'){
						var item = checkbox.getValue();
						if(item == '20'){
							REJECT_ITEM_NAME += ('、' + "授權書");
							return;
						}
						
						var ITEMs = checkbox.getAttribute('ITEM_NAME');
						REJECT_ITEM_NAME += ('、' + (checkbox.getAttribute('GUAR_NAME')||'') + ITEMs);
					}
				}
			);					

			//if(REJECT_ITEM_NAME == ''){
			//	alert('應補文件至少選取一件');
			//	return;
			//}

			var reqMap = {	APPLY_ID: '${APPLY_ID}',
							KIND	: '${KIND}',
							REJECT_ITEM_NAME : REJECT_ITEM_NAME.substring(1)
			};
			
			<!--發送AJAX-->
			ajaxRequest.post( 'createNOTE', {reqMap : Object.toJSON(reqMap),REJECT_NOTE : $F('REJECT_NOTE')}
				,function(resp){
					$('REJECT_NOTE').value = resp.RETURN_REASON || '';				
				}				
			);
		}
	};
	
	return {			
		initApp : function() {
			
			PageUI.createPageWithAllBodySubElement("DSA10803","受理作業","退件輸入作業");					
		
			//定義畫面檢核
			initValidation();
			
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------													
			//註冊DOM物件 : 監聽				
			$('BTN_reject').observe('click', buttons.doReject);//退件
			$('BTN_close').observe('click', buttons.doClose);//關閉
			$('BTN_MEMO').observe('click', buttons.doMEMO);//產生說明
			
			//電子補全通知才要查應補文件，並打開「產生說明」button
			if(${KIND eq '2'}){
				buttons.doQuery();
				$('BTN_MEMO').show();
			}
			
			PageUI.resize();
			
			//初始頁面alert訊息用	
			displayMessage();							
		}// end initApp()		
	};// end return--
}	

</script>
</head>
<body>
<form name="form1" id="form1" method="post" target="importFrame" enctype="multipart/form-data" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
		<c:if test = "${KIND eq '2'}">
			<tr>					
				<td class="tbYellow" width="20%">應補文件</td>
				<td class="tbYellow2" width="80%">
					<span id="ITEM_SPAN"></span>
				</td>									
			</tr>
		</c:if>
		<tr>					
			<td class="tbYellow">退件說明<input id="BTN_MEMO" type="button" class="button" value="產生說明" style="display:none"/>					
			</td>	
			<td class="tbYellow2">
				<input id="REJECT_ITEM_NAME" type="hidden" class="button">
				<textarea id="REJECT_NOTE" class="checkLength" rows="3" cols="70" maxlength="100"></textarea>
			</td>
		</tr>
		<tr>
			<td colspan="5" align="center">				
				<input id="BTN_reject" type="button" class="button" value="確認"/>				
				<input id="BTN_close" type="button" class="button" value="關閉"/>							
			</td>
		</tr>					
	</table>	
</form>
</body>
</html>
