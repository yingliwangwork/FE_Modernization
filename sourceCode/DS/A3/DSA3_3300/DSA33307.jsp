<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA33307.jsp
作者：張晉瑋
功能：影像資料。
完成：2018/05/23
-->

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title>DSA33307</title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ImageUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>

<script type='text/javascript'>
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSA33307().initApp);

function DSA33307(){

	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_3307/');
	var grid1;
	var valid1;
	var valid2;
	var selectOption;

	<%--種類的下拉選單資訊--%>
	var KindObj = <c:out value="${PIC_KIND_LIST}" escapeXml="false" default="{}" />;
	
	<%--欄位檢核 Validation.js--%>
	function initValidation(){
	
		<%--影像資料檢核--%>
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });
		valid1.define('required',{id:'import_file',errMsg:"請選擇檔案後再上傳"});
		
		<%--影像資料清單檢核--%>
		valid2 = new Validation("form2", { focusOnError:true, immediate:false });
		Validation.addAllThese([
			['validKIND', '請選擇影像種類', function(v , node) { 
		    	<%--沒填寫或者選0都是錯誤--%>
		    	if(!v || v == '0'){
		    		return false;
		    	} else{
		    		return true;
		    	}
   			}],
			['validMEMO', '備註長度最多為200碼', function(v , node) { 
				<%--使用BLEN，判斷Big5 StringLength--%>
				if(commonTools.getChtLength(v) > 200 ){
					return false;
				}else{
					return true;
				}
			}]
		]);
	}

	<%--CoverPage(鎖定/開放畫面)--%>
	var auxiliary = {
		createCoverPage:function(){
			CSRUtil.createCoverPage('_frontCover');
			$('_frontCover').show();
		},
		closeCoverPage: function(){
			$('_frontCover').hide();
		}
	};

	var buttons = {	
		<%--上傳按鈕--%>
		doUpload : function(){
			valid1.reset();
			valid2.reset();
			if(!valid1.validate()){
				return;
			}
			
			auxiliary.createCoverPage();
			$('form1').action="${dispatcher}/DSA3_3307/upload";
			submitOnce($('form1'));
		},
		<%--上載結束的處理(回傳至頁面處理)--%>	
		doReloadImport : function(){		
			<%--關閉coverpage--%>
			auxiliary.closeCoverPage();
			
			var ele_filedata = window.importFrame.document.getElementById("filedata");
			if(!ele_filedata){
				return;
			}
			
		 	var obj = ele_filedata.innerHTML.evalJSON();
		  	var Msg = obj.ErrMsg.msgDesc.replace('\\n','');			
		  	if(Msg){
				alert(Msg);				
		  	}

			if(CSRUtil.isSuccess(obj)){	
				if(obj.A356List){
					grid1.load(obj.A356List);
					$('UPDATE_PIC_DATE').innerHTML = "最後上傳日期：" + obj.UPDATE_PIC_DATE;
				}	
				<%--於TableUI中顯示圖檔--%>
				actions.loadImage();
				<%--清空查詢條件--%>
				$('import_file').setValue('');
			}
		},
		<%--確認按鈕--%>
		doConfirm : function (){	
			valid1.reset();
			valid2.reset();
			if(!valid2.validate()){
				return;
			}
			
			var DATA_LIST = grid1.getAllRecords();
			
			<%--發送ajax--%>
			ajaxRequest.post('confirm', 
			{ 
				'DATA_LIST' : Object.toJSON(DATA_LIST),
				'COMMUNITY_NO' : '${COMMUNITY_NO}'
			},function(resp){ 
				grid1.load(resp.A356List || []);
				$('UPDATE_PIC_DATE').innerHTML = "最後上傳日期：" + resp.UPDATE_PIC_DATE;
				<%--於TableUI中顯示圖檔--%>
				actions.loadImage();
			},function(resp){
				grid1.load([]);
			});
		}
	}	
	
	var actions = {
		<%--起始畫面--%>
		initLayout : function() {
			<%--起始共用的下拉選單--%>
			selectOption = commonTools.createOptionsWithMap(new Element('select'), KindObj);
		},
		<%--顯示圖片--%>
		loadImage : function(){
			var recordList = grid1.getAllRecords();
			for(var i = 0; i < recordList.length; i++){
				var record = recordList[i];
				var FILE_PATH = record.FILE_PATH;
				if(FILE_PATH){
					ImageUtil.showImage({
						imagePath:FILE_PATH
						,showImageDivId: 'PIC_' + record._tableuiSerialNumber
						,imageWidth : '50%'
						,imageHeight : '30%'
					});	
				}
			}
		},
		<%--刪除資料--%>	
		doDelete : function(obj){
			<%--發送ajax--%>
			ajaxRequest.post('delete',
			{
				'COMMUNITY_NO' : $F('COMMUNITY_NO'),
				'SEQ_NO' : obj.SEQ_NO, 
				'FILE_PATH': obj.FILE_PATH
			},function(resp){
				grid1.load(resp.A356List || []);
				$('UPDATE_PIC_DATE').innerHTML = "最後上傳日期：" + resp.UPDATE_PIC_DATE;
				<%--於TableUI中顯示圖檔--%>
				actions.loadImage();
			},function(resp){
				grid1.load([]);
			});
		}
	};
	
	var commonTools = {
		<%--將Map資料轉為下拉選單--%>		
		createOptionsWithMap : function(selectElement, optMap){
			if(optMap){
				selectElement.length=0;
				for(var key in optMap){
					selectElement.insert(new Element('option',{value: key}).update(optMap[key]));					
				}
			}
			return selectElement;
		},
		<%--檢核中文長度--%>		
		getChtLength : function(str){
		    if(!str){
		    	return 0;
		    }
		    if(window.charCountsByte == '2'){
		    	<%--BIG5--%>
		    	var arr = str.match(/[^\x00-\xff]/ig);
		        return arr == null ? str.length : str.length + arr.length;
		    }
		    <%--UTF8--%>
		    var m = encodeURIComponent(str).match(/%[89ABab]/g);
		   	return str.length + (m ? m.length : 0);
		}
	};

	return {
		initApp : function() {		
			PageUI.createPageWithAllBodySubElement(
					'DSA33302',
					'鑑價作業',
					'影像資料',
					'',
					true
				);
			grid1 = new TableUI({                   				
				table: $('grid1'),
				pageSize : 0,
				column:[
					{header:"影像種類", key:'KIND', attrs : { Width : '10%'},
						render:function(rec, val, sn){
							<%--deep copy一份下拉選單--%>
							var copy = Element.clone(selectOption, true);
							if(val){
								copy.setValue(val);
							} 							
							
							copy.setAttribute('id','kindSelection_'+ sn);
							copy.setAttribute('class', 'validKIND');
							   
							<%--更動以後要更動getAllRows的資料--%>
							copy.observe('change' , function(event){
								var dataObj = grid1.getRecordsBySerialNo(sn)[0];
								dataObj.KIND = event.target.value;
							});							
							return copy;
						}	
					},
					{header:"備註", key:'MEMO', attrs : { Width : '40%'}, 
						input:{type:'TEXT', 'size':80, 'className':'validMEMO'}
					},
					{header:"影像檢視", key: 'PIC_VIEW', attrs : { Width : '35%'},	
						render: function( record , value , sn){
							return new Element('DIV', { width:'100%',id:'PIC_' + sn , name:'PIC'});
						}
					},
					{ header:"編輯", attrs : { Width : '15%'},
						input:{
							type:"button" ,
							text:"刪除",
	                        action:function( node , dataObj , value){ 	
	                        	actions.doDelete(dataObj[0]);
							}
						}
					}	
				]					
			});
			
			$("BTN_UPLOAD").observe("click", buttons.doUpload );
			$("BTN_COMFIRM").observe("click", buttons.doConfirm );
			$('importFrame').observe('load', buttons.doReloadImport);	<%--監視: iframe有匯入時啟動--%>

			displayMessage();
			actions.initLayout();
			initValidation();	
			<%--init時要顯示的資料list--%>
			grid1.load(<c:out value = '${A356List}' default = '[]' escapeXml = "false"/>);		
			<%--於TableUI中顯示圖檔--%>
			actions.loadImage();		
			PageUI.resize();	
		}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1"  method="post" target="importFrame" enctype="multipart/form-data" style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>
		<table id = "tableA" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow">
					影像上傳
				</td>
				<td class="tbYellow2">
					<span id="import">
						<input name="import_file" id="import_file" type="file" class="file" size="50" multiple>
					</span>
					<button type="button" class="button" id="BTN_UPLOAD">上傳</button>
				</td>
				<%-- 匯入檔案時，模擬Ajax的效果 --%>
				<iframe id="importFrame" name="importFrame" height="0" size="10" style="display:none"></iframe>
			</tr>
			<tr class=tbYellow0 align="center">
				<td colspan="2">
					<strong>影像資料清單</strong>
					<button id="BTN_COMFIRM" name="BTN_COMFIRM" type="button" class="button">確認</button>	
					<div id="UPDATE_PIC_DATE" datatype="ROCDate" style="float:right">最後上傳日期：${UPDATE_PIC_DATE}</div>
				</td>
			</tr>
		</table>
		<input type = "hidden" id = "COMMUNITY_NO" name = "COMMUNITY_NO" value = "${COMMUNITY_NO}">
	</form>	
	<form id="form2" name="form2">
		<table id="grid1" class="grid"></table>
	</form>	
</body>
</html>