<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB40300.jsp
作者：張智翔
功能：匯款檢核輸入
完成：2012/05/07


[20190822]問題單(20190821141307)：數入檢核部分，匯款金額欄位非TableUI元素，屬性設置className改成class
-->

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			<%-- 日期用 --%>

<script type='text/javascript'>

// 產生畫面物件
var DSB40300 = new DSB40300();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB40300.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB40300(){
	
	var grid;		
	
	var A010Map =  {};
	
	var rtnMap ={};
	
	var IntMap = {};

	//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0016:"btn_insert"<%--輸入--%>,
				B0068:"btn_reject"<%--退件--%>	
		};
		
		<dz:grantButtons FUNC_ID="DSB40300" ignored="false"/>
	}
	
	//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSB4_0300/" + actionName,
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
	
	//buttons對應的event function
	var buttons = {	
		//輸入
		doInsert : function(event){

			// 清空檢核
			validates.clear();
			
			//匯率檢核
			if(grid.validTable()){
				alert("匯率不可為空且需>0");
				return;
			}
			
			// 檢核設定
			validates.insertChecked();

			if(!validates.valid.validate()){
				return;			
			}	
					
			//取得畫面資料
			var sendRecord = grid.getAllRecords();
			
			if ($F('NEXT_PAYDT')){
				var Y2K_NEXT_PAYDT = toY2K($F('NEXT_PAYDT'));
				var DUTY_DAY = $('NEXT_PAYDT').options[$('NEXT_PAYDT').selectedIndex].DUTY_DAY; // 繳息日
			} else {
				var Y2K_NEXT_PAYDT = null;
				var DUTY_DAY = '';
			}
			
			for( var i = 0 ; i < sendRecord.length ; i++ ){
				var obj = sendRecord[i];
				obj['INT_DEPT'] = $F('INT_DEPT'); // 收息單位
				obj['SALARY_GROUP'] = $F('SALARY_GROUP'); //扣薪組別
				obj['IS_NPDT'] = IntMap.IS_NPDT; // 是否增貸件
				obj['NEXT_PAYDT'] = Y2K_NEXT_PAYDT; // 下次應繳日			
				obj['DUTY_DAY'] = DUTY_DAY; // 繳息日
			}
			
			//發送ajax
			ajaxPost( 'update' , 
			{	
				sendRecord : Object.toJSON(sendRecord),
				A010Map : Object.toJSON(A010Map),
				APPLY_ID : '${APPLY_ID}', 
				SER_NO : '${SER_NO}',
				REMIT_PROCESS : '${REMIT_PROCESS}'
			},
				function(resp){						
					afterAjaxShare(resp);					
				}
			);		
			
		},
		
		//退件
		doReject : function(event){
		
			// 清空檢核
			validates.clear();
			
			// 檢核設定
			validates.rejectChecked();
		
			if(!validates.valid.validate()){
				return;			
			}	
		
			//取得畫面資料
			var sendRecord = grid.getAllRecords();
			for( var i = 0 ; i < sendRecord.length ; i++ ){
				var obj = sendRecord[i];
				obj['CANCEL_REASON'] = $F('CANCEL_REASON'); // 退件原因
			}
		
			ajaxPost( 'reject' , {sendRecord : Object.toJSON(sendRecord)},
				function(resp){						
					//退完件後 畫面清空
					grid.load([]);
					$$('#tableA span').each(
						function(elem){
							elem.update("");
						}
					);
					
					$$('#tableB span').each(
						function(elem){
							elem.update("");
						}
					);
					
					$('form1').reset();
					//輸入完後會查無資料,因此將下拉選單也清空
					clearSelection();		
					//讓兩個按鈕disabled不能按,因為沒資料
					$('btn_insert').disable();
					$('btn_reject').disable();						
				}
			);		
		},
		//更新匯率
		doUpdRate : function(){
			
			//取得畫面資料
			var sendRecord = grid.getAllRecords();
			
			
			ajaxPost( 'updRate' , {APPLY_ID : '${APPLY_ID}', sendRecord : Object.toJSON(sendRecord)},
				function(resp){						
					afterAjaxShare(resp);							
				}
			);		
		},
		
		//回上一頁
		doBack : function(event){
			CSRUtil.linkBack();			
		},
		
		//查詢資料
		doInitQuery : function(event){				
			//發送ajax
			ajaxPost( 'query' , {APPLY_ID : '${APPLY_ID}', SER_NO : '${SER_NO}', REMIT_PROCESS : '${REMIT_PROCESS}', A010Map : Object.toJSON(A010Map)},
				function(resp){		
					afterAjaxShare(resp);					
				},function(resp){
					//查無資料或失敗,清空所有下拉選單 讓表單呈現空白
					clearSelection();				
					
					//讓兩個按鈕disabled不能按,因為沒資料
					$('btn_insert').disable();
					$('btn_reject').disable();
				}
			);		
		}
	};
	
	// 檢核
	var validates = {
		initValidation : function() {
			
			// 欄位檢核
			validates.valid = new Validation("form1", { useTitles:true, focusOnError:true, immediate:false });	
						
			Validation.addAllThese([	
				['requireCANCEL_REASON', '請選擇退件原因!', function(v) {
					return v === "0" ? false : true;				
				}],
				['requireNEXT_PAYDT', '請選擇下次應繳日!', function(v) {
					if(!$('NEXT_PAYDT').disabled){
						return $('NEXT_PAYDT').value === "" ? false : true ;
					}
					return true;
				}],
				['validRemitAmt', '輸入金額與先前匯款金額不一致!', function(v,elm) {
					return v.replace(/,/g,'') == $(elm).readAttribute('remit_amt');
				}],
				['validINT_DEPT', '需輸入7碼!', function(v,elm) {
					return v.length == 7;
				}]
			]);
		},
		
		// 輸入檢核
		insertChecked: function(){
			validates.valid.define( "required" , { id: "INT_DEPT" , errMsg :"請輸入收息單位"} );	
			validates.valid.define( "requireNEXT_PAYDT" , { id: "NEXT_PAYDT" } );
			validates.valid.define( "validINT_DEPT" , { id: "INT_DEPT" } );
			
			//匯款金額檢核
			$$('td[name=INPUT_REMIT_AMT] input').each(
				function(elem){
					var id = elem.id.substring(0, elem.id.lastIndexOf('_'));
					if(id == 'INPUT_REMIT_AMT'){
					<%-- [20190822]問題單：非TableUI元素，className改成class --%>
						elem.setAttribute("class" , "validate-number validRemitAmt");
					}
				}
			);
			
		},

		// 退件檢核
		rejectChecked: function(){
			validates.valid.define( "requireCANCEL_REASON" , { id: "CANCEL_REASON" } );
		},
				
		// 清除檢核設定及記錄
		clear: function(){
			validates.valid.reset();
			validates.valid.clear();
			
			$$('td[name=INPUT_REMIT_AMT] input').each(
				function(elem){
					elem.setAttribute("className" , "");
					elem.style.backgroundColor = "";
				}
			);
		},
		//檢核匯率:不可為空或0
		chkEX_RATE:function(v){
			if(!v || v <= 0 ){
				return false;
	        }
			return true;
		}
	};
	
	//清空所有下拉選單
	function clearSelection(){		
		$$('#form1 select').each(
			function(elem){
				elem.update();						
			}		
		);	
	}
	
	//輸入與初始查詢共用的mehod
	function afterAjaxShare(resp){
		//將List增加到下拉選單中 
		var list = resp.NEXT_PAYDT_LIST;		
		var target = $('NEXT_PAYDT');
		//先清除
		target.update();
		grid.load([]);	
		
		//加入List
		if(list){
			for(var i = 0; i < list.length; i++){
				var opt = document.createElement("option");
				opt.text = list[i]['NEXT_PAYDT_NAME'] + ' ' + list[i]['NEXT_PAYDT_CODE'];
				opt.value = list[i]['NEXT_PAYDT_CODE'];
				opt.DUTY_DAY = list[i]['DUTY_DAY'];
				target.add(opt);
			}			
		}		
		//執行將值放入畫面當中
		doInit(resp , list);
	}
	
	//頁面初始
	function doInit(resp,list){	
	
		rtnList = resp.rtnList ? resp.rtnList : [];
		
		//將各個Map放入到對應的變數當中		
		rtnMap = rtnList[0];
		
		if(list && list.length == 1 && rtnMap['REMIT_PROCESS'] == 12){
			alert('請先補入舊件貸款帳號，以便自動帶出下次應繳日，否則系統將自動入新件之下次應繳日!');
		}		
		
		IntMap = resp.IntMap;
		A010Map = resp.A010Map;		
		
		//將A010Map 放入span當中		
		CSRUtil.voToInputs('form1' , A010Map);		
		//客制化各個欄位
		$('REMIT_DATE_TXT').update(Date.toInputROC(rtnMap['REMIT_DATE'] || "","/"));		
	
		$('INT_DEPT').value = A010Map['GETINT_DEPT'] ? A010Map['GETINT_DEPT'] : IntMap['INT_DEPT'];		
		
		//加入下拉選單
		var appendMap = resp.SALARY_GROUP_LIST;
		//先清空
		$('SALARY_GROUP').update();
		for(key in appendMap){		
			$('SALARY_GROUP').options.add(new Option(appendMap[key] ,key )); 
		}	
		
		if(IntMap){
			if(IntMap.NEXT_PAYDT_ERR){
				alert(IntMap.NEXT_PAYDT_ERR);
			}
			$('SALARY_GROUP').value = IntMap.SALARY_GROUP;
			$('PERSONNEL_TXT').update(IntMap.PERSONNEL);
			$('NDPT_MARK_NOTE_TXT').update(IntMap.NDPT_MARK_NOTE);
			
			//判別IS_NPDT控制下次應繳日 
			IntMap.IS_NPDT ==='Y' ? $('NEXT_PAYDT').show() : $('NEXT_PAYDT').hide();		
		}
		
		//tableUI載入
		grid.load(rtnList);	
	}
	
	return {

			initApp : function() {		
				PageUI.createPageWithAllBodySubElement("DSB40300", "匯款處理", "匯款檢核輸入");			
				grid = new TableUI ( {
						table: $("grid"), pageSize: 0, allSortable:true , split: ['BORROW_NAME'], title : "匯款資料",
						validateRecordCheckedOnly: false, 
						validateRecord:function( rec , sn ){
						console.log(rec.EX_RATE);
						console.log(validates.chkEX_RATE(rec.EX_RATE));
							return validates.chkEX_RATE(rec.EX_RATE);
						},
						column:	[		
							{header: "序號",key: "SER_NO"},
							{header: "匯款種類",key: "REMIT_TYPE_NM"},			
							{header: "匯款帳號",key: "REMIT_ACCOUNT_NM"},		
							{header: "戶名",key: "ACCOUNT_NAME"},		
							{header: "代償單位",key: "COMP_DIV_NM"},		
							{header: "備註",key: "COMP_NAME"},		
							{header: "匯款金額",key: "INPUT_REMIT_AMT",                       
								input:{type:'NUMBER', size:20 , maxlength:15 , width:30,
									genRule:function(rec , val){										
										return rec.REMIT_PROCESS === '12' ? true : false;
									},
			                        action:function( node , dataObj , textDiv, orgData , isOnChange ){ 	
										if(!isOnChange){ 											       
											node.id = 'INPUT_REMIT_AMT_' + dataObj[0]["SER_NO"];
											node.setAttribute("fieldName" , "匯款金額");
											node.setAttribute("datatype" , "number");
											//node.setAttribute("className" , "validate-number validRemitAmt");
											node.setAttribute("REMIT_AMT" , dataObj[0]["REMIT_AMT"]);
										}			
									}, actionWhenStart:true
								},
								render : function(rec , val){
									return val? JsUtils.isNumeric(val) ? MoneyFormat(val):val: 0 ;
								}
							},		
							{header: "幣別",key: "CURR"},		
							{header: "匯率",key: "EX_RATE",                       
								input:{type:'NUMBER', size:20 , maxlength:15 , width:30,
									genRule:function(rec , val){		
										if(rec.REMIT_PROCESS === '12'){//待匯款檢核輸入案件才可更新匯率
											return (!rec.CURR || rec.CURR === 'NTD') ? false : true;
										}
										return false;
									},
			                        action:function( node , dataObj , textDiv, orgData , isOnChange ){ 	
										if(!isOnChange){ 											
											node.id = 'INPUT_EX_RATE_' + dataObj[0]["SER_NO"];
										}	
									}, actionWhenStart:true
								},
								render : function(rec , val){//若為台幣,匯率為1
									return val? val:((!rec.CURR || rec.CURR === 'NTD') ? 1 : '');
								}
							}
							//,{header: "匯款金額(匯款檔)",key: "REMIT_AMT"}
						]
					});		
					
								
				//註冊DOM物件
				//click事件
				$("btn_insert").observe("click", buttons.doInsert );				
				$("btn_reject").observe("click", buttons.doReject );				
				$("btn_updRate").observe("click", buttons.doUpdRate );	
				$("btn_back").observe("click", buttons.doBack );	
				
				// 監聽: 收息單位轉大寫
				$("INT_DEPT").observe('change', function() {$("INT_DEPT").value = $F("INT_DEPT").toUpperCase();} );

				buttonAuth();
				
				validates.initValidation();	
				
				fix();

				displayMessage();		

				autoFormatToNumber();
				<c:choose>
					<c:when test = '${not empty errsMsg}'>
						alert('${errsMsg}');
					</c:when>
					<c:otherwise>
						buttons.doInitQuery();
					</c:otherwise>
				</c:choose>						
			}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table id = "tableA" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
		<tr>
			<td class="tbYellow" width="8%" align="left">
				受理編號
			</td>
			<td class="tbYellow2" >
				<span id="APPLY_ID_TXT" name="APPLY_ID_TXT" class = "textGreen"/></span>	
			</td>
			<td class="tbYellow" width="10%" align="left">
				匯款日期
			</td>
			<td class="tbYellow2" colspan = "3">
				<span id="REMIT_DATE_TXT" name="REMIT_DATE_TXT" class = "textGreen"/></span>	
			</td>			
		</tr>
		<tr>
			<td class="tbYellow"  align="left">
				借款人ID
			</td>
			<td class="tbYellow2">
				<span id="BORROW_ID_TXT" name="BORROW_ID_TXT" class = "textGreen" /></span>	
			</td>	
			<td class="tbYellow"   align="left">
				借款人姓名
			</td>
			<td class="tbYellow2">
				<span id="BORROW_NAME_TXT" name="BORROW_NAME_TXT" class = "textGreen"/></span>	
			</td>
			<td class="tbYellow"  align="left" width = "8%">
				火險狀況
			</td>
			<td class="tbYellow2">
				<span id="FILE_FIREINSU_TXT" name="FILE_FIREINSU_TXT" class = "textGreen"/></span>	
			</td>
		</tr>	
		<tr>
			<td class="tbYellow"  align="left">
				貸款類別
			</td>
			<td class="tbYellow2">
				<span id="LOAN_KIND_NM_TXT" name="LOAN_KIND_NM_TXT" class = "textGreen"/></span>	
			</td>	
			<td class="tbYellow"  align="left">
				定期期數
			</td>
			<td class="tbYellow2">
				<span id="FIX_PERIOD_TXT" name="FIX_PERIOD_TXT" class = "textGreen"/></span>	
			</td>
			<td class="tbYellow"  align="left" >
				分期期數
			</td>
			<td class="tbYellow2">
				<span id="SPR_PERIOD_TXT" name="SPR_PERIOD_TXT" class = "textGreen"/></span>	
			</td>
		</tr>	
		<%--[20221227]新增本金彈性還期間--%>
		<tr>
			<td class="tbYellow" align="left">本金彈性還期間 </td>
			<td class="tbYellow2">
				<span id="FLEX_PERIOD_NM_TXT" name="FLEX_PERIOD_NM_TXT" class = "textGreen"/></span>	
			</td>	
			<td class="tbYellow"></td>
			<td class="tbYellow2"></td>
			<td class="tbYellow"></td>
			<td class="tbYellow2"></td>
		</tr>	
		<tr>
			<td class="tbYellow2"  align = "center" colspan="6">
				<input id = "btn_insert" type = "button" class = "button" value = "輸入"/>	
				<input id = "btn_reject" type = "button" class = "button" value = "退件"/>	
				<input id = "btn_updRate" type = "button" class = "button" value = "更新匯率"/>								
			</td>
		</tr>
		<tr>
			<td bgcolor ="#F0FBC6"  align = "left" colspan="6">
				<b>退件原因 :</b> 
				<select  id="CANCEL_REASON" name = "CANCEL_REASON"  class = "select1" fieldName = "退件原因">							
					<c:forEach items="${CANCEL_REASON_LIST}" var="row">
						<option value="${row.key}"/>${row.value}</option>						
					</c:forEach>							
				</select>				
			</td>
		</tr>
		</table>	
		<table id='grid' width="100%"></table>	
		<table ID = "tableB" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
		<tr>
			<td class="tbYellow0"  align = "center" colspan="6">
				<b>匯款明細</b>					
			</td>
		</tr>
			<tr>
			<td class="tbYellow"  align="left" width = "10%">
				收息單位
			</td>
			<td class="tbYellow2">
				<input id="INT_DEPT" name="INT_DEPT" type="text" size="8" maxlength = "7"  class="text2" fieldName = "收息單位" />	
			</td>	
			<td class="tbYellow"  align="left" width = "10%">
				扣薪組別
			</td>
			<td class="tbYellow2" text = "">
				<select  id="SALARY_GROUP" name = "SALARY_GROUP"  class = "select1" fieldName = "扣薪組別">		
				</select><br>
				<span id = "PERSONNEL_TXT" name = "PERSONNEL_TXT" class = "textRed"/> </span>
			</td>
			<td class="tbYellow"  align="left" width = "12%">
				下次應繳日
			</td>
			<td class="tbYellow2 textGreen" width = "12%">
				<span id = "NDPT_MARK_NOTE_TXT" name = "NDPT_MARK_NOTE_TXT" class = "textGreen"></span><br>
				<select  id="NEXT_PAYDT" name = "NEXT_PAYDT"  class = "select1" fieldName = "下次應繳日">							
				</select>
			</td>			
		</tr>	
		<tr>
			<td class="tbYellow2"  align = "center" colspan="6">
				<input id = "btn_back" type = "button" class = "button" value = "回上一頁"/>									
			</td>					
		</tr>
		</table>
	</form>
</body>
</html>