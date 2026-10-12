<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA20700.jsp
作者：i9300623
功能：客戶資料照會表
完成：2011/10/20
更新：
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<title></title>
<%--共用定義的css--%>
<style>
	.starColor {
		color: red;
	}	
	.blueColor{
		color: blue;
	}
</style>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<%--[20240729]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<%--自行定義的javaScript--%>
<script type="text/JavaScript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function initApp(){
	PageUI.createPageWithAllBodySubElement( "DSA20700" , "核貸作業" ,"客戶資料照會表" , 0,'${titleNotDisplay}' == 'Y');
	displayMessage();
	
	new UI().init(); 
	
	var insideHeight = $('contentSpan').offsetHeight;
	$('contentDiv').style.height = insideHeight < 1000 ? insideHeight : 1000;
	

}
function UI(){   
	var valid;             
	//---------------------------------畫面產生---------------------------------
	var BuildUI = {
		createCellNode : function(tag,attrs){
			var cell = document.createElement( tag );
        	for( var attr in attrs ) { 
        		if(attr == 'class' || attr == 'className'){
        			$(cell).addClassName(attrs[attr]);
        		}else{
        			cell.setAttribute( attr, attrs[attr] );        			
        		}        		
        	}
        	return cell;
		}
		,createRedFont : function(RedVal,td){
			var font = this.createCellNode('FONT',{'class':'starColor'});
			font.appendChild(document.createTextNode(RedVal || ''));
			td.appendChild(font);
		}
		,clearTable : function(){
			$('form1').select('td[content]').each(
				function(ele){
					ele.parentNode.removeChild(ele);
				}
			);
			$('form1').select('span').each(
				function(ele){
					ele.innerHTML='';
				}
			);	
		}
		,appendChildNotNull : function(val,td){
			if(val){
				td.appendChild(BuildUI.createCellNode('br'));
				td.appendChild(document.createTextNode(val));
			}
		}
		,loadData : function(rtnList){
			var multiVal=['BUSS_NAME_NM1','BUSS_NAME_NM2','BUSS_NAME_NM3','BUSS_NAME_NM4','BUSS_NAME_NM5'];
			
			var inputs = $('gridB').select('tr[detail]');
			
			for(var i=0;i<rtnList.length;i++){
				var map=rtnList[i];
				inputs.each(function(it){
					var v = it.id;
					var data= map[v]|| '';
					var td=BuildUI.createCellNode('td',{'class':'tbYellow2',content:'true',noWrap:'true'});
					if(v=='OTHER_NM'){
						BuildUI.createRedFont(data,td);
					}else{
						td.appendChild(document.createTextNode(data));
						var middleVal;
						if(v=='BUSS_NAME_NM'){
							for(var k=0;k<multiVal.length;k++){
								var tmp=multiVal[k];
								BuildUI.appendChildNotNull(map[tmp],td);
							}
						}else if(v=='CHECK_JUDICIAL_NM'){
							BuildUI.appendChildNotNull(map['CHECK_JUDICIAL_NM1'],td);
						}else if(v=='OFFICE_NAME_NM'){
							BuildUI.appendChildNotNull(map['OFFICE_NAME_NM1'],td);
						}else if(v=='LOAN_POS_NM'){
							if(data){
								td.appendChild(BuildUI.createCellNode('br'));
							}
							td.appendChild(document.createTextNode(map['LOAN_POS_MEMO_FIX']|| ''));
							BuildUI.createRedFont(map['LOAN_POS_MEMO_RED'],td);
						}else if(v=='ID_SHOW'){<%--[20240729]難字調整 --%>
							td.setStyle({"font-family": 'EUDC'});
						}
					}
					it.appendChild(td);	
				});
			}
			<%-- [20240729]難字調整，動態產需呼叫 --%>
			parseEUDC();
		}
	};
	//---------------------------------按鈕功能---------------------------------
	var doAction = {
		//查詢
		doQuery : function(){
			valid.reset();
			if( !valid.validate() ) {return;}
			//受理編號轉大寫
			$('APPLY_ID').value=$F('APPLY_ID').toUpperCase();

			//保留參數管理-更新受理編號
			CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID').value});

			new Ajax.Request( '<%=dispatcher%>/DSA2_0700/query',
	    	{ 	
		    	parameters:  { 'APPLY_ID':$F('APPLY_ID')}, 	    	
		        onSuccess: function(XHT, resp){
		        	//將畫面清空
		        	BuildUI.clearTable();
					if(CSRUtil.isSuccess(resp)){
						$('showGridC').style.display='block';
						var rtnList=resp.rtnList||[];
						var rtnMap=rtnList[0];
						var A157Map=resp.A157Map;
						$('APPLY_ID_span').innerHTML=rtnMap.APPLY_ID || '';
						$('INPUT_NAME').innerHTML=rtnMap.INPUT_NAME || '';
						$('INPUT_DATE').innerHTML=resp.INPUT_DATE;
						
						BuildUI.loadData(rtnList);
						
						//若ID=0表示只寫買賣件查證事項
						if(rtnMap.ID=='0') {
							$('contentDiv').style.display='none';
						}
						if(isEmpty(A157Map)){//若A157Map為{},則C區隱藏
							$('showGridC').style.display='none';
						}else{//若A157Map不為{},則C區顯示資料
							CSRUtil.voToInputs('gridC', A157Map );
						}
			 			
			 			
					}else{
						$('showGridC').style.display='none';
			 			BuildUI.loadData([{},{}]);
			 		}
		        }
		    });
		}
		//清除
		,doClear : function(){
			valid.reset();
			form1.reset();	
			BuildUI.clearTable();
			//預設顯示空白欄位兩欄
			BuildUI.loadData([{},{}]);
			$('showGridC').style.display='none';
		}
	};
	var isEmpty = function( obj ) {   for ( var prop in obj ) {     return false;   }   return true; }; 
	return{

		init:function(){
			valid  = new Validation('form1',{useTitles:true} );
			
			//查詢                    
			$('btn_query').observe('click',function(event){
					doAction.doQuery();					
				}
			);
			
			//清除                  
			$('btn_clear').observe('click',function(event){                                        
					doAction.doClear();
				}                        
			);
			//預設顯示空白欄位兩欄
			BuildUI.loadData([{},{}]);
			
			//有傳入受理編號則帶入欄位，若無則取保留參數管理的受理編號
			$('APPLY_ID').value = '${APPLY_ID}' || CSRUtil.keepParamsManager.get('APPLY_ID');
			if($('APPLY_ID').value){
				doAction.doQuery();
			}
		}                 
	}
}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
	<span>
	<form id="form1" name="form1" method="post">

				<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
					<tr>
						<td class="tbYellow" width="15%">受理編號</td>
						<td class="tbYellow2" width="25%">
							<input type="text" class="textBox2 required" title="受理編號必須有值" fieldName="受理編號" size="13" maxlength="11" name="APPLY_ID" id="APPLY_ID" value="${APPLY_ID}"/>
						</td>
						<td class="tbYellow2" width="60%">
							<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
							<input id="btn_clear" name="btn_clear" type="button" class="button" value="清除">
						</td>
					</tr>
				</table>
				<table class="tbBox2" border="0" cellSpacing=1 cellPadding=0 width="100%" id="gridA">
					<tr>
						<td class="tbYellow" width="10%" nowrap>受理編號</td>
						<td class="tbYellow2" width="20%" nowrap><span id="APPLY_ID_span"></span></td>
						<td class="tbYellow"width="10%" nowrap>作業人員</td>
						<td class="tbYellow2" width="20%" nowrap><span id="INPUT_NAME" style="font-family:'EUDC'"></span><%--[20240729]難字調整 --%></td>
						<td class="tbYellow" width="10%" nowrap>處理日期</td>
						<td class="tbYellow2" width="30%" nowrap><span id="INPUT_DATE"></span></td>
					</tr>
				</table>
				<div style="width:100%;overflow:auto;" id = "contentDiv">
					<div id="contentSpan">
					<table id="gridB" class="tbBox2" cellSpacing="1" cellPadding="0" border="0" width="100%" style="text-Align:center;" >
						<tr id="ID_SHOW" detail="true">
							<td class="tbYellow" colspan="2" nowrap>照會對象/日期</td>
						</tr>
						<tr id="CASE_ORIGIN_NM" detail="true">
							<td class="tbYellow" colspan="2" nowrap>案件來源</td>
						</tr>
						<tr id="LOAN_POS_NM" detail="true">
							<td class="tbYellow" colspan="2" nowrap>資金用途</td>
						</tr>
						<tr id="HOME_TEL_NM" detail="true">
							<td class="tbYellow" rowspan="3" width="3%">基本資料</td>
							<td class="tbYellow" width="15%" nowrap>住家電話</td>
						</tr>
						<tr id="CON_ADDR_NM" detail="true">
							<td class="tbYellow" nowrap>通訊地址</td>
						</tr>
						<tr id="CON_STATUS_NM" detail="true">
							<td class="tbYellow" nowrap>通訊地址使用狀況</td>
						</tr>
						<tr id="OFFICE_TEL_NM" detail="true">
							<td class="tbYellow" rowspan="9">公司資料照會</td>
							<td class="tbYellow" nowrap>公司電話</td>
						</tr>
						<tr id="OFFICE_NAME_NM" detail="true">
							<td class="tbYellow" nowrap>公司名稱</td>
						</tr>
						<tr id="OFFICE_ITEM_NM" detail="true">
							<td class="tbYellow" nowrap>公司營業項目</td>
						</tr>
						<tr id="OFFICE_ADDR_NM" detail="true">
							<td class="tbYellow" nowrap>公司地址</td>
						</tr>
						<tr id="BUSS_NAME_NM" detail="true">
							<td class="tbYellow" nowrap>經營事業</td>
						</tr>
						<tr id="JOB_TITLE_NM" detail="true">
							<td class="tbYellow" nowrap>職稱</td>
						</tr>
						<tr id="SERV_YEAR_NM" detail="true">
							<td class="tbYellow" nowrap>年資</td>
						</tr>
						<tr id="YEAR_INCOME_NM" detail="true">
							<td class="tbYellow" nowrap>年收入</td>
						</tr>
						<tr id="COMPANY_DATA_NM" detail="true">
							<td class="tbYellow" nowrap>檢附相關資料</td>
						</tr>
						<tr id="CHK_NOTE_NM" detail="true">
							<td class="tbYellow" rowspan="2">信用照會</td>
							<td class="tbYellow" nowrap>支存照會</td>
						</tr>
						<tr id="JCIC_NOTE_NM" detail="true">
							<td class="tbYellow" nowrap>聯徵及其他信用照會</td>
						</tr>
						<tr id="USE_STATUS_NM" detail="true">
							<td class="tbYellow" rowspan="2">擔保品</td>
							<td class="tbYellow" nowrap>擔保品使用現況</td>
						</tr>
						<tr id="GAGE_OTHER_NM" detail="true">
							<td class="tbYellow" nowrap>擔保品其它特殊狀況</td>
						</tr>
						<tr id="IS_OTHER_GAGE_NM" detail="true">
							<td class="tbYellow" rowspan="4">其他</td>
							<td class="tbYellow" nowrap>除本擔外，另有其它擔保品</td>
						</tr>
						<tr id="IS_OTHER_LOAN_NM" detail="true">
							<td class="tbYellow" nowrap>其它擔保品是否有貸款</td>
						</tr>
						<tr id="CHECK_JUDICIAL_NM" detail="true">
							<td class="tbYellow" nowrap><font class="blueColor">監護∕輔助宣告查證</font></td>
						</tr>
						<tr id="OTHER_NM" detail="true">
							<td class="tbYellow" nowrap>其他特殊狀況</td>
						</tr>
					</table>
					</div>
				</div>
				<div id="showGridC" style="display: none">
				<table id="gridC" width="100%" id="gridC" class="tbBox2" cellSpacing="1" cellPadding="0" border="0">
					<tr>
						<td bgcolor="#FFFFFF" colspan="8">買賣件查證事項</td>
					</tr>
					<tr>
						<td class="tbYellow" rowspan="8">人</td>
						<td class="tbYellow" width="63%" nowrap>1.借款人職業收入、年齡與所購置擔保品金額不對稱</td>
						<td class="tbYellow2" width="37%" nowrap><span id="TRADE_DATA1_NM1_TXT"></span><span id="TRADE_DATA1_NM2_TXT" class="starColor"></span></td>
					</tr>
					<tr>
						<td class="tbYellow" nowrap>2.代書∕建商∕仲介等介紹件，加強介紹人與前後手間關係、買契真實性的查證</td>
						<td class="tbYellow2" nowrap><span id="TRADE_DATA2_NM1_TXT"></span><span id="TRADE_DATA2_NM2_TXT" class="starColor"></span></td>
					</tr>
					<tr>
						<td class="tbYellow" nowrap>3.借、保人與前手關係</td>
						<td class="tbYellow2" nowrap><span id="TRADE_DATA3_NM1_TXT"></span><span id="TRADE_DATA3_NM2_TXT" class="starColor"></span></td>
					</tr>
					<tr>
						<td class="tbYellow" nowrap>4.借款人或保證人為建設公司員工、股東或承包商等</td>
						<td class="tbYellow2" nowrap><span id="TRADE_DATA4_NM1_TXT"></span><span id="TRADE_DATA4_NM2_TXT" class="starColor"></span></td>
					</tr>
					<tr>
						<td class="tbYellow" nowrap>5.有不相干的人(如代書或借款親友)主動查詢貸款案件細節或催促案件甚急者</td>
						<td class="tbYellow2" nowrap><span id="TRADE_DATA5_NM1_TXT"></span><span id="TRADE_DATA5_NM2_TXT" class="starColor"></span></td>
					</tr>
					<tr>
						<td class="tbYellow" nowrap>6.借、保人職業與聯徵報送資料有不一致情形</td>
						<td class="tbYellow2" nowrap><span id="TRADE_DATA6_NM1_TXT"></span><span id="TRADE_DATA6_NM2_TXT" class="starColor"></span></td>
					</tr>
					<tr>
						<td class="tbYellow" nowrap>7.近三個月他行有非ｚ類查詢記錄(新業務尤須注意)</td>
						<td class="tbYellow2" nowrap><span id="TRADE_DATA7_NM1_TXT"></span><span id="TRADE_DATA7_NM2_TXT" class="starColor"></span></td>
					</tr>
					<tr>
						<td class="tbYellow" nowrap>8.客戶主動檢附完整的收入及職業證明</td>
						<td class="tbYellow2" nowrap><span id="TRADE_DATA8_NM1_TXT"></span><span id="TRADE_DATA8_NM2_TXT" class="starColor"></span></td>
					</tr>
					<tr>
						<td class="tbYellow" rowspan="5">物</td>
						<td class="tbYellow" nowrap>9.所購置房屋地點『無』地緣關係或合理性</td>
						<td class="tbYellow2" nowrap><span id="TRADE_DATA9_NM1_TXT"></span><span id="TRADE_DATA9_NM2_TXT" class="starColor"></span></td>
					</tr>
					<tr>
						<td class="tbYellow" nowrap>10.對所購房屋之買價、坪數、屋齡等不甚了解</td>
						<td class="tbYellow2" nowrap><span id="TRADE_DATA10_NM1_TXT"></span><span id="TRADE_DATA10_NM2_TXT" class="starColor"></span></td>
					</tr>
					<tr>
						<td class="tbYellow" nowrap>11.買價及鑑估價格差異過大</td>
						<td class="tbYellow2" nowrap><span id="TRADE_DATA11_NM1_TXT"></span><span id="TRADE_DATA11_NM2_TXT" class="starColor"></span></td>
					</tr>
					<tr>
						<td class="tbYellow" nowrap>12.前手取得時間在一年內或屋齡新，惟建物登記次序多筆(請調閱異動謄本)</td>
						<td class="tbYellow2" nowrap><span id="TRADE_DATA12_NM1_TXT"></span><span id="TRADE_DATA12_NM2_TXT" class="starColor"></span></td>
					</tr>
					<tr>
						<td class="tbYellow" nowrap>13.擔保品曾有送件記錄(請進行擔保品行情查詢)</td>
						<td class="tbYellow2" nowrap><span id="TRADE_DATA13_NM01_TXT"></span><span id="TRADE_DATA13_NM02_TXT" class="starColor"></span><span id="TRADE_DATA13_NM1_TXT"></span><span id="TRADE_DATA13_NM2_TXT" class="starColor"></span></td>
					</tr>
					<tr>
						<td class="tbYellow" colspan="2" nowrap>其他照會說明</td>
						<td class="tbYellow2" nowrap><span id="TRADE_DATA_DESC_NM_TXT"></span></td>
					</tr>
				</table>
				</div>
		</form>	
	</span>

</body>
</html>
