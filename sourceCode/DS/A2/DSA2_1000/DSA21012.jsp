<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
    Date        Version Description Author
    2011/10/23          Created     林韋孝

    程式功能概要說明：
    程式功能　裁決層級切換
    程式名稱　DSA2_1012java
    作業方式　ONLINE
    概要說明　依據登入人員的角色，判斷可切換的批示層級
    按鈕授權　FUNC_ID=DSA21012

	@author 楊宗翰
	@since 2011-10-28
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/comm.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>

<script type="text/JavaScript">

<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

// 檢核
var validate4define;

var grid;



function initApp(){
	// 日期、數字輸入自動格式化
	autoFormatToDate();
	autoFormatToNumber();

	// 按鈕權限
	

	// 檢核物件
	validate4define = new Validation("form1", {useTitles:true, focusOnError:false, immediate:false});	//, mode:"validator"
	Validation.addAllThese([
		[ 'customize_returnFalse', '請自訂訊息',
			function(obj){
				return false;
			}
		]
	]);

	new UI().init();
}

function UI(){
	return {
		init:function() {
			displayMessage();

			//PageUI.createPageWithAllBodySubElement("DSA21012", "核貸作業", "高級主管裁決批示");

			var IS_ADV_INST = '${IS_ADV_INST}';

			layout.control(IS_ADV_INST);
		}
	};
}

//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 內容
	doLink:function(){
		if(!validates.checkInput("link")){
			return;
		}

		$('CRED_DEPT').value = "2";	// 徵信科別，預設為2（總公司）
		$('INST_LEVEL').value = $('ADV_LEVEL').value;
		$('SUP_CRED_DEPT').value = "N"; //支援徵信科別，預設為N
		
		hyperlinks.formSubmit("DSA2_1010", "prompt", "btn_content");
	}
};

//--------------------------------------------------------------------------
// 檢核
//--------------------------------------------------------------------------
var validates = {
	// 畫面欄位
	checkInput:function(action, type){
		validate4define.clear();

		// 查詢
		if(action == "link"){
			var key = "ADV_LEVEL";
			if(validates.isBlank(key, true)){
				var msg = "請選取高級主管批示層級";
				validate4define.define( "customize_returnFalse" , [{ id :key , errMsg : msg}] , { useTitle: false });
			}
		}
		
		return validate4define.validate();
	},
	// 檢查是否為空值
	isBlank:function(key_Value, isKey){
		if(isKey === null || isKey === undefined || isKey === ""){
			if($(key_Value)){
				isKey = true;
			}else{
				isKey = false;
			}
		}else if(!key_Value || !$(key_Value)){
			isKey = false;
		}

		// 取得value
		var value;
		if(isKey){
			if($(key_Value)){
				value = $(key_Value).value;
			}else{
				return false;
			}
		}else{
			value = key_Value;
		}

		if(value || !isNaN(parseInt(value, 10))){
			return false;
		}else{
			return true;
		}
	}
};

//--------------------------------------------------------------------------
// 畫面操作
//--------------------------------------------------------------------------
var layout = {
	control:function(IS_ADV_INST){
		if(IS_ADV_INST == "Y"){
			$('title').innerHTML = "高級主管裁決批示";
			$('block1').show();
			$('grid').hide();

			// 內容
			$("btn_content").observe('click',function(event){
				buttons.doLink(true);
			});

			// 「高級主管層級」下拉選單
			<c:if test="${not empty ADV_INSTList}">
				var ADV_INSTList = ${ADV_INSTList};

				$w('ADV_LEVEL').each(
					function(key){
						selection.createAll(key, ADV_INSTList, "", "", "");
					}
				);
			</c:if>
		}else{
			$('title').innerHTML = "主管裁決批示層級切換";
			$('block1').hide();
			$('grid').show();

			grid = new TableUI({
				table: $('grid'), pageSize: 10, allSortable: true,
				autoCheckBox:{type:'radio', text:'選取',
					valueKey:'SEQ_NO',
					action:function(checkbox , boxStatus , records){
						checkbox.checked = true;

						var length = records.length;
						var obj;
						
						for(var i = 0; i < length; i++){
							if(records[i]["SEQ_NO"] == checkbox.value){
								obj = records[i];
								break;
							}
						}
						
						
						if(obj){
							$('CRED_DEPT').value = obj.CRED_DEPT;	//徵信科別
							$('INST_LEVEL').value = obj.INST_LEVEL;	//批示層級
							$('SUP_CRED_DEPT').value = obj.SUP_CRED_DEPT;	//支援徵信科別
							
							hyperlinks.formSubmit("DSA2_1010", "prompt", "btn_content");
						}
					}
				},
				column:[
					{header:'徵信科別', key:'CRED_DEPT_NM'},
					{header:'批示層級', key:'INST_LEVEL_NM'}
				]
			});
			
			// 「高級主管層級」下拉選單
			<c:if test="${not empty INST_INFOList}">
				var INST_INFOList = ${INST_INFOList};

				if(INST_INFOList){
					var length = INST_INFOList.length;
					if(length == 1){
						$('CRED_DEPT').value = INST_INFOList[0].CRED_DEPT;		//徵信科別
						$('INST_LEVEL').value = INST_INFOList[0].INST_LEVEL;	//批示層級
						$('SUP_CRED_DEPT').value = INST_INFOList[0].SUP_CRED_DEPT;	//支援徵信科別
						
						hyperlinks.formSubmit("DSA2_1010", "prompt", "btn_content");
					}else if(length > 1){
						grid.load(INST_INFOList);
					}
				}
			</c:if>
		}
	}
};

//--------------------------------------------------------------------------
// 超連結
//--------------------------------------------------------------------------
var hyperlinks = {
	// formSubmit
	formSubmit:function(target, action, btn){
		var form = document.form1;

		form.action = "<%=dispatcher%>/" + target + "/" + action;
		//submitOnce($(btn));
		form.submit();
	}
};

//--------------------------------------------------------------------------
// 下拉選單
//--------------------------------------------------------------------------
var selection = {
	// 依照傳入資料與id，產生下拉選單
	createAll:function(tagID, optionList, initialText, key, value, choiceValue, isCode_CodeNM){
		if(!key){
			key = "CODE";
		}
		if(!value){
			value = "CODE_NM";
		}

		var target = $(tagID);
		if(target){
			if(initialText){
				selection.create(tagID, "", initialText, "");
			}
			if(optionList){
				for(var i = 0; i < optionList.length; i++){
					if(isCode_CodeNM){
						selection.create(tagID, optionList[i][key], optionList[i][key] + " " + optionList[i][value], choiceValue);
					}else{
						selection.create(tagID, optionList[i][key], optionList[i][value], choiceValue);
					}
				}
			}
		}
	},
	// 依照傳入資料與id，產生下拉選單(資料為Map)
	createAll4Map:function(tagID, optionMap, initialText, choiceValue, isCode_CodeNM){
		var target = $(tagID);
		if(target){
			if(initialText){
				selection.create(tagID, "", initialText, "");
			}
			if(optionMap){
				var dataKey = Object.keys(optionMap);
				dataKey.each(
					function(key){
						if(isCode_CodeNM){
							selection.create(tagID, key, key + " " + optionMap[key], choiceValue);
						}else{
							selection.create(tagID, key, optionMap[key], choiceValue);
						}
					}
				);
			}
		}
	},
	// 產生單一下拉選單(如果下拉選單的value == 資料的Value，則將該option選擇起來)
	create:function(tagID, optionValue, optionText, choiceValue){
		$(tagID).options.add(new Option(optionText, optionValue));

		if(choiceValue && optionValue == choiceValue){
			$(tagID).options[$(tagID).length - 1].selected = true;
		}
	},
	// 清空下拉選單
	clean:function(tagID){
		$(tagID).options.length = 0;
	}
};

//--------------------------------------------------------------------------
// 共用－Ajax
//--------------------------------------------------------------------------
function ajaxPost( actionName, params, successAction, errorAction, asynchronous){
	asynchronous = (asynchronous === false) ? asynchronous : true;
   	new Ajax.Request(
		"<%=dispatcher%>/DSA2_1012/" + actionName,
		{ parameters: params,
		  asynchronous: asynchronous,
          onSuccess: function(XHT, resp){
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

//-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<center>
<span id="bar1" style="position:absolute; left:0; top:0; width:100%; z-index:9; visibility: visible;" >
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
   	 	<td valign="top" bgcolor="#F0FBC6">
   	 	<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
	        <tr>
	          	<td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td>
	        </tr>
	  	</table>
		<!-- InstanceBeginEditable name="title" -->
		<table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
	  		<tr>
	          	<td width="20" height="24" align="center"><font size="-5">●</font></td>
	          	<td>核貸作業</td>
	          	<td align="right">畫面編號：DSA21012</td>
	        </tr>
		</table>
      	<!-- InstanceEndEditable -->
      	</td>
    	<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
   	 	<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
  	</tr>
</table>
</span>
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
  	<tr>
    	<td>&nbsp;</td>
  	</tr>
</table>
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr>
	    <td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
	    <td width="100%" valign="top" bgcolor="#F0FBC6"><!-- InstanceBeginEditable name="content" -->
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td valign="top">
				<table width=97% border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
					<tr>
						<td class="tbBox2">
							<img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">
							<span id="title">高級主管裁決批示</span>
						</td>
					</tr>
					<tr bgcolor=#FFFFFF>
						<td>
							<form name="form1" id="form1" method="post" action="">
							<input id="CRED_DEPT" name="CRED_DEPT" type="hidden" value=""/>
							<input id="INST_LEVEL" name="INST_LEVEL" type="hidden" value=""/>
							<input id="SUP_CRED_DEPT" name="SUP_CRED_DEPT" type="hidden" value=""/>
							<table id="block1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
								<tr>
									<td class="tbYellow" width="12%">
										高級主管層級
									</td>
									<td class="tbYellow2">
										<select id="ADV_LEVEL" name="ADV_LEVEL" class="textBox2"></select>
										<input id="btn_content" name="btn_content" type="button" class="button" value="內容">
									</td>
								</tr>
							</table>
							<table id="grid" class="grid" width="100%" style="display:none"></table>
							</form>
						</td>
					</tr>
				</table>
				</td>
			</tr>
		</table>
    	</td>
    	<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
  	</tr>
</table>
</center>
</body>
</html>