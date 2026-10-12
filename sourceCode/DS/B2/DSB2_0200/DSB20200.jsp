
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB20200.jsp
作者：張智翔
功能：地政資料輸入作業。
完成：2012/06/06
-->

<fmt:setBundle basename='TextResource' />

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

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

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			<%-- 日期用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>			<%-- 地址用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript'>

// 產生畫面物件
var DSB20200 = new DSB20200();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB20200.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB20200(){
	//查詢的檢核
	var valid1;
	//派件的檢核
	var valid2;
	//土地事務所
	var addressOfiice;
	//土地座落
	var landLocation;
	//土地明細
	var grid;
	//預帶輸入資料
	var grid1;		
	//前次查詢條件
	var queryInputMap = {} ;
	
	var NODATA_SW;
				
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0003:"btn_insert"<%--新增--%> ,
				B0005:"btn_delete"<%--刪除--%> 
		};
		
		<dz:grantButtons FUNC_ID="DSB20200" ignored="false"/>
	}
	//畫面檢核
	function initValidation(){
	
	 Validation.addAllThese([	
		[ 'IDLength',  '所有人ID需為10碼或8碼', 
			function(v){		
				return (v!=="" && v.length != 10 && v.length != 8) ? false : true ;   
			} 
		],
		['validate-OWNER_ID', '所有權人身份證號或法人統一編號有誤，請檢查後重新輸入!', function(value) {
				if(value!=""){
				 if(value.length!=10&&value.length!=8){
				    return false;
				 }else if(value.length==10){
				 	return validation.checkROCID(value);	//一般人
				 }else{
					return validation.checkUniSN(value);	
				 }
				 return true;
				}
				 return true;
			}
		],
		['validate-HalfType', '請輸入全形文字!', function(value) {
			if(validation.hasHalfType(value)){
			    return false;
			}
			return true;
		  }
		],
		['validate-Date', '請輸入正確日期格式!', function(value) {
			if(value!=""){
			   
			   if(!isROCdate(value, false)){
			    return false; 
			   }
			   return true;
			}
			return true;
		  }
		]
	]);
		//查詢用檢核
		valid1 = new Validation("form", { focusOnError:true, immediate:false });	
		valid1.define( "required" , { id: "INPUT" } );	
		//新增用檢核
		valid2 = new Validation("form1", { focusOnError:true, immediate:false });	
		
	}
    
    
	//新增時, 設定地政事務所 , 土地座落 專用檢核
	function validInsert(){
			valid2.clear(); // 清define
			valid2.reset(); // 清背景色
			//---所有權人ID轉大寫
             $('OWNER_ID').value=$('OWNER_ID').value.toUpperCase();
            //---
            //---權利到期日為設定日期加30年
            if($('END_DATE').value==""){
               var end_y2k=toY2K($('SET_DATE').value);
                   end_y2k=addDate(end_y2k, 30, 0, 0);
              $('END_DATE').value=toROC(end_y2k);            
            }
            //---
            
		    valid2.define( "validate-OWNER_ID" , { id: "OWNER_ID" , errMsg : '所有權人身份證號有誤，請檢查後重新輸入!'} );	
			valid2.define( "validate-digits" , { id: "YEAR" , errMsg : '收件字號-年，須為數字'} );	
			valid2.define( "required" , { id: "YEAR" , errMsg : '請輸入收件字號-年再執行新作業'} );	
			valid2.define( "required" , { id: "WORD" , errMsg : '請輸入收件字號-登記字再執行新作業'} );	
			valid2.define( "validate-HalfType" , { id: "WORD" , errMsg : '請輸入全形的收件字號-登記字!!'} );
			valid2.define( "required" , { id: "NO" , errMsg : '請輸入收件字號-登記號再執行新作業'} );
			valid2.define( "validate-Date" , { id: "APPR_DATE" , errMsg : '鑑估日期格式錯誤!!'} );
			valid2.define( "validate-Date" , { id: "END_DATE" , errMsg : '權利到期日格式錯誤!!'} );

			//addressOfiice.checkData(valid2);
			landLocation.checkData(valid2);

	}
	
	
	//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSB2_0200/" + actionName,
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
		//查詢資料
		doQuery : function(event){			
			
			if(!valid1.validate()){ 
				return; 
			}		
			$('INPUT').value = $('INPUT').value.toUpperCase();
			//選取的值
			var checkType = $$('#SELECT_TYPE input:checked[type = radio]')[0].value;
						
			var sendRecord = {};
			if(checkType ==="1"){
				sendRecord.APPLY_ID = $('INPUT').value;
				CSRUtil.keepParamsManager.put({'APPLY_ID': $('INPUT').value });
			}else if(checkType ==="2"){
				sendRecord.REFER_ID = $('INPUT').value;				
			}else if(checkType ==="3"){
				sendRecord.LOAN_ID = $('INPUT').value;				
			}else{
				alert("請先選擇查詢種類！");
				return;			
			}		

			sendRecord.QUERY_TYPE = checkType;
		
			//確定可查詢 將查詢條件代入 方便重查
			queryInputMap = sendRecord;
		
			ajaxPost( 'query' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){	
					actions.doClear();
					wiriteFields(resp);				
				},
				function(resp){
					//清空table ui
					grid.load([]);
					grid1.load([]);
					actions.doClear();
				}
			);		
		},	
		
		//新增第一段
		doInsert : function(event){			
			//做所有新增的檢核
			validInsert();
			//將設定地政事務所設定
		    var land_OFFICE_NAME= addressOfiice.getOFFICE_NAME();	
		    if(land_OFFICE_NAME==""){
		       alert("請選擇設定地政事務所 !!");
		       return;
		    }
			
			var rtnList = grid.getAllRecords();
			var inputList = grid1.getAllRecords();
			var insertMap = grid1.getCheckedRecord();			
			
			
			//if(insertMap.length == 0){
			//	alert('請先選取一筆預帶輸入資料再執行新增作業！');
			//	return;
			
			//}			
			
			
			if(!valid2.validate()){ 
				return; 
			}	

			//將畫面存成List
			var dataList = makeInsertRecord(insertMap[0]);	
			
			//if(NODATA_SW=='N'){
			//	if(dataList[0].APPLY_ID==""){
			//		alert('請先選取一筆預帶輸入資料或已輸入的地政資料再執行新增作業！');
			//		return; 
			//	}
			//}

			ajaxPost( 'checkData' , 
				{
					dataList : Object.toJSON(dataList)					
				},
				function(resp){	
					var confirmMsg = resp.errInputMsg;		
					//如果有錯誤訊息,代表檢核有錯,需等user按確定,才會繼續做下去
					if(confirmMsg && !confirm(confirmMsg)){						
						return;
					}
					insert(dataList);	
				}
			);	
		},
		
		//刪除
		doDelete : function(event){
			var deleteRecord = grid.getCheckedRecord();	
			if(deleteRecord.length == 0){
				alert('請先選取地政資料再執行刪除作業');
				return;			
			}
		
			ajaxPost( 'delete' , 
				{
					deleteRecord : Object.toJSON(deleteRecord[0]),
					sendRecord : Object.toJSON(queryInputMap)
				},
				function(resp){	
					//清除畫面 再重查
					actions.doClear();
					wiriteFields(resp);				
				}				
			);	
		},
		
		//回上一頁
		doBack : function(event){
			CSRUtil.linkBack();	
		}
	}
	
	//新增的第二段 , 新增資料
	function insert(dataList){
		
		ajaxPost( 'insert' , 
			{
				dataList : Object.toJSON(dataList),
				sendRecord : Object.toJSON(queryInputMap)
			},
			function(resp){	
				//清除畫面 再重查
				actions.doClear();
				wiriteFields(resp);				
			}
		);		
	}
	
	//將日期判斷是否為空值,轉成西元格式
	function turnToY2KDate(formatDate){
		if(formatDate !== ''){
			return toY2K(formatDate);
		}
		return '';
	}
	
	//將畫面資料存成list
	function makeInsertRecord(insertMap){
		var dataList = [];
		
		//將畫面資料存成Map		
		var dataMap = CSRUtil.inputsToVo('form1');
		
		//設定相關資料
		dataMap.APPLY_ID = $('APPLY_ID_TXT').innerHTML;
		dataMap.LOAN_ID = $('LOAN_ID_TXT').innerHTML;
		
		dataMap.YEAR =  makeAreaNo(dataMap.YEAR,3);
		dataMap.NO = makeAreaNo(dataMap.NO,6);
		
		dataMap.END_DATE = turnToY2KDate($('END_DATE').value);	
		dataMap.SET_DATE = turnToY2KDate($('SET_DATE').value);	
		dataMap.APPR_DATE = turnToY2KDate($('APPR_DATE').value);		
		
		//將設定地政事務所設定
		dataMap.LAND_OFFICE_CITY = addressOfiice.getCITY_NAME();
		dataMap.LAND_OFFICE_NM = addressOfiice.getOFFICE_NAME();		
	
		//土地座落資料設定
		dataMap.LOCATION1 = landLocation.getTOWN_NAME();
		dataMap.LOCATION2 = landLocation.getLAND_NAME1();
		dataMap.LOCATION3 = landLocation.getLAND_NAME2();		
		dataMap.LAND_CODE = landLocation.getLAND_CODE();
		dataMap.OFFICE_CODE = landLocation.getOFFICE_CODE();
		
		if ($('SET_AMT').value == ''){
			dataMap.SET_AMT = '';
		}
		if ($('PRE_SET_AMT').value == ''){
			dataMap.PRE_SET_AMT = '';
		}
		if ($('LIMIT_AMT').value == ''){
			dataMap.LIMIT_AMT = '';
		}
		if ($('APPR_REALVALUE').value == ''){
			dataMap.APPR_REALVALUE = '';
		}
		
		//取得地號建號筆數
		var LAND_CNT = dataMap.LAND_CNT;
		
		//根據地號建號筆數,取得對應的欄位數,並生成n筆資料, 除了地號建號不同,其他欄位都相同
		for(var i = 0 ; i < LAND_CNT ; i++){
			var sendMap = JsUtils.cloneObject(dataMap);
			var LAND_Row_Array = $$('.LAND'+i);
			var BUILD_Row_Array = $$('.BUILD'+i);
			
			sendMap.LAND_NO1 = makeAreaNo(LAND_Row_Array[0].value,4);
			sendMap.LAND_NO2 = makeAreaNo(LAND_Row_Array[1].value,4);	
			sendMap.BUILD_NO1 = makeAreaNo(BUILD_Row_Array[0].value,5);	
			sendMap.BUILD_NO2 = makeAreaNo(BUILD_Row_Array[1].value,3);				
				
			sendMap.SECOND = $('SECOND').checked == true ? '1' : '0';		
			
			dataList.push(sendMap);	
		}		
		return dataList;
	
	}
	
	//判斷是否滿指定位數,如果不滿就前面補剩下的0 , ex : 欄位長度必須要5碼, 但user只輸入120,就把它補成 00120
	function makeAreaNo(ANo , checkSize){
		var ANo_length = ANo.length;
		if(ANo === ''){
			return '';
		}else if(ANo_length == checkSize){
			return ANo;		
		}
		
		var appendZero = '';
		for( var i = 0 ; i < checkSize-ANo_length; i++){
			appendZero +=0;		
		}
		return appendZero +ANo ; 
	}
	
	var actions = {
		//將資料寫入畫面上
		writeRecord : function(record){	
			//先清空C區
			actions.doClear();
			//將record寫入C區
			CSRUtil.voToInputs('form1' , record);
			//客制化日期成 民國 YY/MM/DD
			$('END_DATE').value = toROC(record.END_DATE || "");	
			$('SET_DATE').value = toROC(record.SET_DATE || "");	
			$('APPR_DATE').value = toROC(record.APPR_DATE || "");	
			//是否為二順位			
			$('SECOND').checked = record.SECOND === '1' ? true : false;	
			
			//問題單編號 20200422-0074 BY余凱鈞 
			//E030008991清償審核作業無法覆核，但查附件一二三都已確認完成，訊息【附件三尚未完成】
			//該件在2018年曾匯入過清償附件三資料，本次因地政資料他項權利部分有誤，故資管二人員到地政資料輸入將原受理編號DE400040027(貸款帳號掛原貸E030008991)資料刪除，但因清償帳號須掛原貸帳號，
			//地政資料重新入了一筆DE400030023(若選受理編號DE400040027，貸款帳號會變A040041815，後續清償作業會對應不到)，導致附件三確認時新增了一筆(DE400030023、E030008991資料)，
			//原DE400040027、E030008991資料變成附件三畫面上查不到，也無法刪除，而被檢核附件三與地政資料檔筆數不符。
			//後續調整地政資料新增時，貸款帳號一率掛原貸帳號(DS_B20200)
			if(record.REFER_ID){
				
				$('LOAN_ID_TXT').innerHTML = record.REFER_ID;
			}

		    //if(NODATA_SW=='N'){
		    	
				//設定土地座落位子			
				landLocation.setCITY_NAME(record.CITY);
				landLocation.setTOWN_NAME(record.LOCATION1);	
				landLocation.setLAND_NAME1(record.LOCATION2);
				landLocation.setLAND_NAME2(record.LOCATION3);
				
				//設定事務所位子,有可能是從預帶資料代入的,可能會沒值,避面出現undefine
		  
		   		if(record.LAND_OFFICE_CITY){
					addressOfiice.setCITY_NAME(record.LAND_OFFICE_CITY);
					addressOfiice.setTOWN_NAME(record.LAND_OFFICE_LOCATION1);
					addressOfiice.setOFFICE_NAME(record.LAND_OFFICE_NM);	
				}else{
					
					addressOfiice.setCITY_NAME(record.CITY);
					addressOfiice.setTOWN_NAME(record.LOCATION1);
					
				}
			//}			
		},
		
		//地號或建號筆數 連動新增欄位
		doMakeLocation : function(value){	
			//數字檢核,不為數字一律給1,回到初始狀況
			if(!JsUtils.isNumeric(value)){
				alert('請輸入1-20間整數');
				$('LAND_CNT').value = 1;
				actions.doMakeLocation($('LAND_CNT').value);
				return;			
			}
			
			//轉成int
			var countNumb = parseInt(value);
			//只能在1~20之間
			if(countNumb < 1 || countNumb > 20){
				alert('地號或建號筆數必須介於1-20間整數');
				$('LAND_CNT').value = 1;
				actions.doMakeLocation($('LAND_CNT').value);
				return;
			}
			
			
			var LAND_Dom = $('LAND_NOs');
			var BUILD_Dom = $('BUILD_NOs');
			
			//先清掉舊的
			LAND_Dom.update();
			BUILD_Dom.update();		
			var v1 = 1;
			var v2 = 2;
			//依照給定的大小生成等量的input欄位,並加入id,name , class等屬性
			for(var i = 0 ; i < countNumb ; i++){						
				var input1 = InputElement('5','4','LAND_NO'+v1,'LAND_NO'+v1,'設定地號-1','LAND'+i);
				input1.observe('keyup', function(event){
				    var v=parseInt(this.id.substring(7));
				    v +=1;				    
					jump(this,document.getElementById('LAND_NO'+v),4);
				});				
				var input2 = InputElement('5','4','LAND_NO'+v2,'LAND_NO'+v2,'設定地號-2','LAND'+i);
				input2.observe('keyup', function(event){
				    var v=parseInt(this.id.substring(7));
				    v -=1;
					jump(this,document.getElementById('BUILD_NO'+v),4);
				});		
				var input3 = InputElement('6','5','BUILD_NO'+v1,'BUILD_NO'+v1,'設定建號-1','BUILD'+i);
				input3.observe('keyup', function(event){
				    var v=parseInt(this.id.substring(8));
				    v +=1;
					jump(this,document.getElementById('BUILD_NO'+v),5);
				});	
				var input4 = InputElement('4','3','BUILD_NO'+v2,'BUILD_NO'+v2,'設定建號-2','BUILD'+i);
				input4.observe('keyup', function(event){
				    var v=parseInt(this.id.substring(8));
				    v +=1;
				    var limit=parseInt(document.getElementById('LAND_CNT').value)*2;
				    if(v<limit){
					 jump(this,document.getElementById('LAND_NO'+v),3);
					}
				});	
				LAND_Dom.insert(input1).insert('─');
				LAND_Dom.insert(input2).insert('<br>');				
				BUILD_Dom.insert(input3).insert('─');
				BUILD_Dom.insert(input4).insert('<br>');
				v1 += 2;			
				v2 += 2;
				//input4.observe('keyup', function(event){
				//	jump(this,document.getElementById('LAND_NO'+v1),5);
				//});
			}
			
			
		},
		
		//清除畫面 回到初始狀況
		doClear : function(){		
			//將地號建號變成一行,	
			var LAND_Dom = $('LAND_NOs');			
			LAND_Dom.update();
			var input1 = InputElement('5','4','LAND_NO1','LAND_NO1','設定地號-1','LAND0');
			input1.observe('keyup', function(event){		    
					jump(this,document.getElementById('LAND_NO2'),4);
				});	
			LAND_Dom.insert(input1).insert('─');
			var input2 = InputElement('5','4','LAND_NO2','LAND_NO2','設定地號-2','LAND0');
			LAND_Dom.insert(input2);	
			input2.observe('keyup', function(event){		    
					jump(this,document.getElementById('BUILD_NO1'),4);
			});			
			
			var BUILD_Dom = $('BUILD_NOs');	
			BUILD_Dom.update();
			var input3=	InputElement('6','5','BUILD_NO1','BUILD_NO1','設定建號-1','BUILD0');
			input3.observe('keyup', function(event){		    
					jump(this,document.getElementById('BUILD_NO2'),5);
				});	
			BUILD_Dom.insert(input3).insert('─');
			BUILD_Dom.insert(InputElement('4','3','BUILD_NO2','BUILD_NO2','設定建號-2','BUILD0'));
			
			//清空C區
			$('form1').reset();	
			$('APPLY_ID_TXT').innerHTML = "";
			$('LOAN_ID_TXT').innerHTML = "";
			
			//將兩個include的下拉選初始化
			landLocation.setCITY_NAME('');
			addressOfiice.setCITY_NAME('');
		}	
	};
	
	//將每次更新查詢完的資料,載入C區
	function wiriteFields(resp){
		//兩個TableUI載入
		grid.load(resp.rtnList);
		grid1.load(resp.forInsertList);
		
		NODATA_SW = resp.NODATA_SW;
		
		var landList = resp.landList;
		//先把C區的 土地謄本 建物謄本清空,再把新的list加進去
		$('LAND_List').update();	
		$('BUILD_List').update();			
		if(landList && landList.length > 0 ){
			for(var i = 0 ; i < landList.length ; i++){				
				$('LAND_List').insert(new Element('span').update(landList[i].LAND_NO + '<br>'));
				$('BUILD_List').insert(new Element('span').update(landList[i].BUILD_NO + '<br>'));
			}
		}
	}
	
	//動態生成input欄位,並設定屬性
	function InputElement(size , maxlength , id , name , fieldName , rowName){
		var attributes = { 
			type  : "text"  , 
			className : 'textBox2 validate-digits required ' + rowName, 
			size : size , maxlength : maxlength , 
			id : id , 
			name : name , 
			fieldName : fieldName
		};  
		return new Element('input', attributes);	
	}
	
	return {

			initApp : function() {

				PageUI.createPageWithAllBodySubElement("DSB20200", "匯款文件", "地政資料輸入作業");

				//地政資料 TableUI
				grid = new TableUI ( {
					table: $("grid"), pageSize: 10, allSortable:true, split:['LOAN_ID'],title :'地政資料',
					autoCheckBox:{					
						type:'radio',						
						action: function(checkbox , boxStatus , records) {
							actions.writeRecord(records[0]);
						}
					},
					column:[
						{header: "受理編號",key: "APPLY_ID"},						
						{header: "地政事務所 ",key: "LAND_OFFICE"},
						{header: "設定金額(元)",key: "SET_AMT", attrs:{ rowSpan : 2 },
							render : function(rec , val){
								return val ? MoneyFormat(val) : 0;
							}						
						},
						{header: "設定日期",key: "SET_DATE", attrs:{ rowSpan : 2 },
							render : function(rec ,val ){
								return Date.toInputROC(val || '' , '/');			
							}
						},
						{header: "段名",key: "LOCATION2", attrs:{ rowSpan : 2 }},						
						{header: "小段名",key: "LOCATION3", attrs:{ rowSpan : 2 }},
						{header: "地號",key: "LAND_NO", attrs:{ rowSpan : 2 }},	
						{header: "建號",key: "BUILD_NO", attrs:{ rowSpan : 2 }},
						{header: "貸款帳號",key: "LOAN_ID"},
						{header: "收件字號",key: "RECEIVE_ID"}

					]
					
				});
				
				//預帶輸入資料(新增時請選擇) TableUI
				grid1 = new TableUI ( {
					table: $("grid1"), pageSize: 10, allSortable:true, title :'預帶輸入資料(新增時請選擇)',
					autoCheckBox:{					
						type:'radio',
						action: function(checkbox , boxStatus , records) {
							actions.writeRecord(records[0]);
						}
					},
					column:[
						{header: "受理編號",key: "APPLY_ID"},			
						{header: "貸款帳號",key: "LOAN_ID"},	
						{header: "原貸帳號",key: "REFER_ID"},	
						{header: "縣市別 ",key: "CITY"},
						{header: "鄉鎮市區別 ",key: "LOCATION1"},
						{header: "段名 ",key: "LOCATION2"},
						{header: "小段名 ",key: "LOCATION3"},
						<%-- [20240607] 難字調整 --%>
						{header: "所有權人姓名 ",key: "OWNER_NAME", render:function(record, value, sn){
							var span = new Element('span',{style:"font-family:'EUDC'"}).update(value);
							return span;
						}},
						{header: "所有權人ID ",key: "OWNER_ID"},
						{header: "鑑估日期 ",key: "APPR_DATE",
							render : function(rec ,val ){
								return Date.toInputROC(val || '' , '/');			
							}
						},
						{header: "鑑估總值(元) ",key: "APPR_REALVALUE"},
						{header: "放款值(元) ",key: "LIMIT_AMT"}
					]
				});
				
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );	
				$("btn_delete").observe("click", buttons.doDelete );	
				$("btn_insert").observe("click", buttons.doInsert );
				$("btn_back").observe("click", buttons.doBack );
				
				//change事件
				$("LAND_CNT").observe("change", function(event){
						actions.doMakeLocation(event.target.value)
					}
				);							
				
				initValidation();	
				
				fix();

				//產生土地事務所下拉選單群
				addressOfiice = new DSZ01000($('addressOfiice'), '4');
				//土地座落
				landLocation = new DSZ01000($('landLocation'), '3');
				
				displayMessage();				
						
				autoFormatToNumber();	
				
				buttonAuth();
				if ($('INPUT').value == '') {
					// 保留參數管理-取得受理編號
					$('INPUT').value = CSRUtil.keepParamsManager.get('APPLY_ID');			
				}
				//前方有接值就查詢
				<c:if test = "${ not empty ACTION_TYPE and not empty INPUT}">
					$('INPUT').value = '${INPUT}';				
					buttons.doQuery();
				</c:if>
			}
	};	
};

</script>
</head>
<body>		
	<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">		
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbYellow" width="35%" align="left" id = "SELECT_TYPE">
					<input type = "radio" name  ="QUERY_TYPE" value ="1" checked />受理編號
					<input type = "radio" name  ="QUERY_TYPE" value ="2"/>原貸帳號
					<input type = "radio" name  ="QUERY_TYPE" value ="3"/>貸款帳號
				</td>			
				
				<td class="tbYellow2" width ="40%">
					<input id = "INPUT" name = "INPUT" type = "text" class = "textBox2" size = "13" maxlength ="11" fieldName = "查詢條件" />
				</td>	
				<td class="tbYellow2" align="center" >
					<input id = "btn_query" type = "button" class = "button" value = "查詢"/>
				</td>		
			</tr>
			<tr>
				<td colspan = "3" align = "center"> 
					<input id = "btn_insert" type = "button" class = "button" value = "新增"/>
					<input id = "btn_delete" type = "button" class = "button" value = "刪除"/>
					<input id = "btn_back" type = "button" class = "button" value = "回上一頁"/>
				</td>
			</tr>
		</table>		
		<table id='grid' width="100%"></table>	
	</form>
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">		
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow" width="16%" align="left" >
					受理編號
				</td>			
				
				<td class="tbYellow2" width ="60%" colspan ="3">
					<span id = "APPLY_ID_TXT" name = "APPLY_ID_TXT" ></span>
				</td>	
				<td class="tbYellow" width="10%" align="left" >
					貸款帳號
				</td>			
				
				<td class="tbYellow2" >
					<span id = "LOAN_ID_TXT" name = "LOAN_ID_TXT" ></span>
				</td>						
			</tr>
			<tr>
				<td class="tbYellow"  align="left" >
					設定地政事務所
				</td>	
				<td class="tbYellow2" id = "addressOfiice" colspan ="3">
					
				</td>	
				<td class="tbYellow"  align="left" >
					設定金額(元)
				</td>			
				
				<td class="tbYellow2" >
					<input type = "text" class = "textBox2" id = "SET_AMT" name ="SET_AMT"  datatype = "number"/>
				</td>						
			</tr>
			<tr>
				<td class="tbYellow"  align="left" >
					收件字號
				</td>	
				<td class="tbYellow2" colspan ="3">
					民國
					<input type = "text" class = "textBox2" id = "YEAR" name ="YEAR" size = "4" maxlength = "3"  />
					年
					<input type = "text" class = "textBox2" id = "WORD" name ="WORD" size = "28" >
					字第
					<input type = "text" class = "textBox2" id = "NO" name ="NO" size = "7" >
					號
				</td>	
				<td class="tbYellow"  align="left" >
					設定日期
				</td>							
				<td class="tbYellow2" >
					<input type = "text" class = "textBox2 required" id = "SET_DATE" name ="SET_DATE" size = "8" maxlength = "7" datatype="ROCDate" fieldName = "設定日期"/>
					<img src="<%=imageBase%>/CM/calendar.gif"  alt="Date" onclick="getCalendarFor($('SET_DATE'))">	
				</td>						
			</tr>			
			<tr>
				<td class="tbYellow"  align="left" >
					權利到期日
				</td>							
				<td class="tbYellow2" colspan = "5">
					<input type = "text" class = "textBox2" id = "END_DATE" name ="END_DATE" size = "8" maxlength = "7" datatype="ROCDate" fieldName = "權利到期日"/>
					<img src="<%=imageBase%>/CM/calendar.gif"  alt="Date" onclick="getCalendarFor($('END_DATE'))">	
				</td>						
			</tr>
			<tr>
				<td class="tbYellow"  align="left" >
					土地座落
				</td>	
				<td class="tbYellow2" id = "landLocation" colspan = "5">
					
					
				</td>						
			</tr>
			<tr>
				<td class="tbYellow"  align="left" >
					地號或建號筆數
				</td>	
				<td class="tbYellow2" >
					<input type = "text" class = "textBox2" id = "LAND_CNT" name ="LAND_CNT" maxlength = "2" size = "3" value = "1" >					
				</td>
				<td class="tbYellow"  align="left" >
					設定地號
				</td>	
				<td class="tbYellow2" id = 'LAND_NOs'>
					<input type = "text" class = "textBox2 validate-digits LAND0" id = "LAND_NO1" name ="LAND_NO1" size = "5" maxlength = "4" 
					onKeyUP="jump(this,document.getElementById('LAND_NO2'),4)"> ─	
					<input type = "text" class = "textBox2 validate-digits LAND0" id = "LAND_NO2" name ="LAND_NO2" size = "5" maxlength = "4" 
					onKeyUP="jump(this,document.getElementById('BUILD_NO1'),4)"><br>												
				</td>	
				<td class="tbYellow"  align="left" >
					設定建號
				</td>	
				<td class="tbYellow2" id = 'BUILD_NOs'>
					<input type = "text" class = "textBox2 validate-digits BUILD0" id = "BUILD_NO1" name ="BUILD_NO1" size = "6" maxlength = "5"
					onKeyUP="jump(this,document.getElementById('BUILD_NO2'),5)"> ─	
					<input type = "text" class = "textBox2 validate-digits BUILD0" id = "BUILD_NO2" name ="BUILD_NO2" size = "4" maxlength = "3" 
					><br>										
				</td>						
			</tr>
			<tr>				
				<td class="tbYellow2" colspan ="2">
									
				</td>
				<td class="tbYellow"  align="left" width = "23%">
					土地謄本上註記之地號
				</td>	
				<td class="tbYellow2" id = "LAND_List">
										
				</td>	
				<td class="tbYellow"  align="left" width = "23%">
					建物謄本上註記之建號
				</td>	
				<td class="tbYellow2" id = "BUILD_List">
										
				</td>						
			</tr>
			<tr>
				<td class="tbYellow"  align="left" >
					是否為二順位
				</td>	
				<td class="tbYellow2" colspan ="3">					
					<input type = "checkbox"  id = "SECOND" name ="SECOND" />	為二進位			
				</td>	
				<td class="tbYellow"  align="left" >
					前順位設定金額(元)
				</td>							
				<td class="tbYellow2" >
					<input type = "text" class = "textBox2" id = "PRE_SET_AMT" name ="PRE_SET_AMT"  dataType = "number">
				</td>						
			</tr>	
			<tr>
				<td class="tbYellow"  align="left" >
					所有權人姓名
				</td>	
				<td class="tbYellow2" colspan ="3">			
				<%-- [20240607] 難字調整 --%>		
				<input type = "text" class = "textBox2" id = "OWNER_NAME" name ="OWNER_NAME" alt="ch">		
				</td>	
				<td class="tbYellow"  align="left" >
					所有權人ID
				</td>							
				<td class="tbYellow2" >
					<input type = "text" class = "textBox2 IDLength" id = "OWNER_ID" name ="OWNER_ID" size = "11" maxlength ="10">
				</td>						
			</tr>	
			<tr>
				<td class="tbYellow"  align="left" >
					鑑估日期
				</td>							
				<td class="tbYellow2" colspan = "5">
					<input type = "text" class = "textBox2" id = "APPR_DATE" name ="APPR_DATE" size = "8" maxlength = "7" datatype="ROCDate" fieldName = "鑑估日期"/>
					<img src="<%=imageBase%>/CM/calendar.gif"  alt="Date" onclick="getCalendarFor($('APPR_DATE'))">	
				</td>						
			</tr>	
			<tr>
				<td class="tbYellow"  align="left" >
					可放款值(元)
				</td>	
				<td class="tbYellow2" colspan ="3">					
				<input type = "text" class = "textBox2" id = "LIMIT_AMT" name ="LIMIT_AMT"  dataType = "number">		
				</td>	
				<td class="tbYellow"  align="left" >
					鑑估值(元)
				</td>							
				<td class="tbYellow2" >
					<input type = "text" class = "textBox2" id = "APPR_REALVALUE" name ="APPR_REALVALUE" dataType = "number">
				</td>						
			</tr>	
		</table>
	</form>		
		<table id='grid1' width="100%"></table>		
		
</body>
</html>