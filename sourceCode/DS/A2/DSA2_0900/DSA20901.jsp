<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSA20901.jsp
作者：i9100623
功能：放款綜合評分
完成：2011/11/03
更新：
-->

<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">

<%--共用定義的css--%>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>

<style type="text/css"> 
<!--
.style1 {font-size: 24px; color: #0000FF;}
.blueColor{
		color: blue;
		background-color: #F0F8FF;
		text-align:center;
	}
-->
</style>
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
<!--
<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>

Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function initApp(){
	
	PageUI.createPageWithAllBodySubElement("DSA20901","核貸作業","新進件評分" , 1,'${titleNotDisplay}' == 'Y');

	displayMessage();
	
	buttonAuth();

	//TableUI的產生        
	new UI().init();   
	             
   autoFormatToNumber();
   
	//初始查詢
	if('${LINK_FROM}'){
		$('APPLY_ID').value = '${APPLY_ID}';
	}    
}
<%--共用全域變數--------------------------------------------------%>
var commonObj = { 
	grid : {},
	valid:{},
	recJob:'',
	recPremium:''
}
<%--全域 函數 UI 與 畫面 公用 End----------------------------------------------------%>
//button控制
function buttonAuth(){
	var authButtons = {
		B0005:'btn_delete'<%--刪除--%>,
		B0078:'btn_score'<%--評分--%>
	};
	<dz:grantButtons FUNC_ID='DSA20901' ignored='false'/> 	
}

<%--全域 函數 UI 與 畫面 公用 End----------------------------------------------------%>

<%--Define UI Class Start-------------------------------------------------------%>
function UI(){                
	//--------------------------------------------------------------------------          
	//UI() private variable        
	//--------------------------------------------------------------------------         
	var grid = {};
	var valid;
	var previousJOB;//前一個職業類別的id
	var previousINCOME;//前一個年收入的id
	var previousPREMIUM;//前一個年繳保費的id
	//--------------------------------------------------------------------------          
	//UI() private method        
	//--------------------------------------------------------------------------   
	//***        
	var ButtonFunction = {
		//查詢
		doQuery : function(){
			$('APPLY_ID_input').className='textBox2 required';
			$('INCOME_TOTAL').className='textBox2';
			$('PREMIUM').className='textBox2';
			$('JOB_CODE11').className='';
			valid.reset();
			if( !valid.validate() ) {return;}
			//受理編號轉大寫
			UpperCase('APPLY_ID_input');
			new Ajax.Request( '<%=dispatcher%>/DSA2_0901/query',
	    	{ 	
		    	parameters:  { 'APPLY_ID':$F('APPLY_ID_input')}, 	    	
		        onSuccess: function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){
						var rtnList=resp.rtnList|| [];
						//預勾選第一筆
						rtnList[0].checkedFlag = 'Y';
						grid.load(rtnList,null,null,['Y']);	
						setValue.RadioOnClick(rtnList[0]);	
					}else{
			 			grid.load([]);
			 			//清空設定至初始狀態
			 			$('table1').select('td[detail]').each(
							function(ele){
								ele.className='tbYellow2';
							}
						);
						if(previousJOB){
							$(previousJOB).checked=false;
							previousJOB='';
						}
						$('table1').select('span').each(
							function(ele){
								ele.innerHTML='';
							}
						);
						$('table1').select('input[type="text"]').each(
							function(ele){
								ele.value='';
							}
						);
						previousINCOME='';
						previousPREMIUM='';
			 		}
		        }
		    });
		},
		//評分
		doScore : function(){
			//畫面程序檢核
			$('APPLY_ID_input').className='textBox2';
			$('INCOME_TOTAL').className='textBox2 required';
			$('PREMIUM').className='textBox2 required';
			$('JOB_CODE11').className='validChecked';
			valid.reset();
			if(Validation.get('validChecked').test($F('JOB_CODE11'))){//true:已選擇職業類別
				$$('#table1 input[type="radio"]').each( 
					function(ele){
						ele.removeClassName(Validation.mode.fail_css);
					}
				);
			}else{//false:未選擇職業類別
				$$('#table1 input[type="radio"]').each( 
					function(ele){
						ele.addClassName(Validation.mode.fail_css);
					}
				);
			}
			if( !valid.validate()) {
				return;
			}
			if($('APPLY_ID_input').value!=$('APPLY_ID').innerHTML){
				alert('畫面上受理編號'+$('APPLY_ID_input').value+'與原查詢受理編號'+$('APPLY_ID').innerHTML+'不一致，請重新查詢');
				return ;
			}
			
			var A150vo=setValue.setScoreVo();
			new Ajax.Request( '<%=dispatcher%>/DSA2_0901/score',
	    	{ 	
		    	parameters:  { 'A150vo':Object.toJSON(A150vo),'APPLY_PROCESS':$F('APPLY_PROCESS'),'CRED_ID':$F('CRED_ID'),'APPLY_ID':$F('APPLY_ID_input'),'AGENCY_ID':${AGENCY_ID}}, 	    	
		        onSuccess: function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){
						var rtnList=resp.rtnList|| [];
						//預勾選第一筆
						rtnList[0].checkedFlag = 'Y';
						grid.load(rtnList,null,null,['Y']);	
						setValue.RadioOnClick(rtnList[0]);
					}
		        }
		    });
		    $('APPLY_ID_input').className='textBox2 required';
			$('INCOME_TOTAL').className='textBox2';
			$('PREMIUM').className='textBox2';
			$('JOB_CODE11').className='';
		},
		//刪除
		doDelete : function(){
			new Ajax.Request( '<%=dispatcher%>/DSA2_0901/deletes',
	    	{ 	
		    	parameters:  { 'ID':$F('ID'), 'TYPE':$F('TYPE'),'APPLY_PROCESS':$F('APPLY_PROCESS'),'CRED_ID':$F('CRED_ID'),'APPLY_ID':$('APPLY_ID').innerHTML,'AGENCY_ID':${AGENCY_ID}}, 	    	
		        onSuccess: function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){
						var rtnList=resp.rtnList|| [];
						//預勾選第一筆
						rtnList[0].checkedFlag = 'Y';
						grid.load(rtnList,null,null,['Y']);	
						setValue.RadioOnClick(rtnList[0]);
					}
		        }
		    });
		}
	};
	var setValue = {
		//設定評分回傳值
		setScoreVo : function(){
			var A150vo=CSRUtil.inputsToVo('table1',true);
			inputs = $('table1').select('span');
			inputs.each(function(it){
				A150vo[it.id] = it.innerHTML;		
			});
			var jobCode=A150vo['JOB_CODE'];
			A150vo['JOB_CLASS']=jobCode.substr(0,1);
			A150vo['JOB_KIND']=jobCode.substr(1,1);
			A150vo['MARRY']=A150vo['MARRY'];
			A150vo['DEGREE']=A150vo['DEGREE'];
			A150vo['TOTAL_SCORE']=A150vo['TOTAL_SCORE2'];
			return A150vo;
		}
		,RadioOnClick : function(record){
			$('table1').select('td[detail]').each(
				function(ele){
					ele.className='tbYellow2';
				}
			);
			previousJOB='';
			previousINCOME='';
			previousPREMIUM='';
			$('APPLY_ID').innerHTML=record.APPLY_ID;
			$$('#table1 input[type="radio"]').each( 
				function(ele){
					ele.checked=false;
					if(record.JOB_CODE==ele.value){
						ele.checked=true;
						ele.parentNode.className='tbBlue';
						previousJOB=ele.id;
					}
				}
			);
			$('TYPE').value=record.TYPE;
			$('ID').value=record.ID;
			$('APPLY_PROCESS').value=record.APPLY_PROCESS;
			$('CRED_ID').value=record.CRED_ID;
			$('SCORE1').update(Classification.getScore1(record.JOB_CODE));
			Classification.YEARchecked(record.SERV_YEAR);
			Classification.IncomeChecked(record.INCOME_TOTAL);
			Classification.AgeChecked(record.AGE);
			Classification.MarryChecked(record.SCORE5);
			$('MARRY').value=record.MARRY;
			Classification.DegreeChecked(record.SCORE6);
			$('DEGREE').value=record.DEGREE;
			Classification.PremiumChecked(record.PREMIUM);
			$('DEBT_SCORE').innerHTML=record.DEBT_DEGREE ||'';
			$('OY_SCORE').innerHTML=record.OY_SCORE || '';
			$('GFS_SCORE').innerHTML=record.GFS_SCORE ||  '';
			$('TOTAL_SCORE1').innerHTML=record.TOTAL_SCORE || '';
			$('TOTAL_SCORE2').innerHTML=record.TOTAL_SCORE || '';
			$('APPLY_DATE').value=record.APPLY_DATE;
			if(diffDay('2017-01-01', $F('APPLY_DATE')) >= 0){
				$('GFICO_table1').style.display = 'none';
				$('GFICO_table2').style.display = 'block';
			} else {
				$('GFICO_table1').style.display = 'block';
				$('GFICO_table2').style.display = 'none';
			}
			Classification.countTotal();
		}
	};
	//計算得分&分類
	var Classification = {
		//年資
		YEARchecked : function(val){
			var year=parseInt(val,10);
			var THREE=parseInt(3,10);
			var FIVE=parseInt(5,10);
			var EIGHT=parseInt(8,10);
			var TEN=parseInt(10,10);
			if(year >=TEN){
				$('SCORE2').update(7);
				$('SERV_YEAR1').className='tbBlue';
			}else if(year >=EIGHT){
				$('SCORE2').update(6);
				$('SERV_YEAR2').className='tbBlue';
			}else if(year >=FIVE){
				$('SCORE2').update(5);
				$('SERV_YEAR3').className='tbBlue';
			}else if(year>=THREE){
				$('SCORE2').update(4);
				$('SERV_YEAR4').className='tbBlue';
			}else{
				$('SCORE2').update(3);
				$('SERV_YEAR5').className='tbBlue';
			}
			
			$('SERV_YEAR').innerHTML=(val || val==0)? val : '';
		}
		//年收入
		,IncomeChecked : function(val){
			var result=Classification.getScore3(val);
			if(previousINCOME){
				$(previousINCOME).className='tbYellow2';
			}
			var incomeID='INCOME_TOTAL'+result;
			$(incomeID).className='tbBlue';
			previousINCOME=incomeID;
			$('SCORE3').update(result);
			$('INCOME_TOTAL').value=(val || val==0)? val : '';
		}
		//年齡
		,AgeChecked : function(val){
			var age=parseInt(val,10);
			var TWENTY=parseInt(20,10);
			var THIRDTY=parseInt(30,10);
			var THIRDTY_FIFE=parseInt(35,10);
			var FIFETY_FIVE=parseInt(55,10);
			if(age>=FIFETY_FIVE){
				$('SCORE4').update(4);
				$('AGE3').className='tbBlue';
			}else if(age>=THIRDTY_FIFE){
				$('SCORE4').update(6);
				$('AGE1').className='tbBlue';
			}else if(age >= THIRDTY){
				$('SCORE4').update(5);
				$('AGE2').className='tbBlue';
			}else if(age>=TWENTY){
				$('SCORE4').update(3);
				$('AGE4').className='tbBlue';
			}else{
				$('SCORE4').update(0);
			}
			$('AGE').innerHTML=(val || val==0)? val : '';
		}
		//年繳保費
		,PremiumChecked : function(val){
			if(previousPREMIUM){
				$(previousPREMIUM).className='tbYellow2';
			}
			var id;
			var premium=parseFloat(val,10);
			var ZERO=parseInt(0,10);
			var FIVE=parseInt(5,10);
			var FIFTEEN=parseInt(15,10);
			var THIRDTY_SIX=parseInt(36,10);
			if(premium>=THIRDTY_SIX){
				$('SCORE11').update(7);
				id='SCORE11_7';
			}else if(premium >=FIFTEEN){
				$('SCORE11').update(5);
				id='SCORE11_5';
			}else if(premium>=FIVE){
				$('SCORE11').update(3);
				id='SCORE11_3';
			}else if(premium>ZERO){
				$('SCORE11').update(1);
				id='SCORE11_1';
			}else{
				$('SCORE11').update(0);
				id='SCORE11_0';
			}
			previousPREMIUM=id;
			$(id).className='tbBlue';
			$('PREMIUM').value=(val || val==0)? val : '';
		}
		//婚姻狀況
		,MarryChecked : function(val){
			var marry=parseInt(val,10);
			var TWO=parseInt(2,10);
			var THREE=parseInt(3,10);
			var FIVE=parseInt(5,10);
			if(marry==TWO){
				$('SCORE5').update(2);
				$('SCORE5_2').className='tbBlue';
			}else if(marry ==THREE){
				$('SCORE5').update(3);
				$('SCORE5_3').className='tbBlue';
			}else if(marry==FIVE){
				$('SCORE5').update(5);
				$('SCORE5_5').className='tbBlue';
			}else{
				$('SCORE5').update(0);
			}
		}
		//學歷
		,DegreeChecked : function(val){
			var degree=parseInt(val,10);
			var TEN=parseInt(10,10);
			var NINE=parseInt(9,10);
			var FIVE=parseInt(5,10);
			if(degree==FIVE){
				$('SCORE6').update(5);
				$('SCORE6_5').className='tbBlue';
			}else if(degree ==NINE){
				$('SCORE6').update(9);
				$('SCORE6_9').className='tbBlue';
			}else if(degree==TEN){
				$('SCORE6').update(10);
				$('SCORE6_10').className='tbBlue';
			}else{
				$('SCORE6').update(0);
			}
		}
		//取得職業得分
		,getScore1 : function(value){
			 switch( value )  
	        {
	            <c:forEach var='item' items='${COM_JOB_CODE_LIST}'>
	            case "${item.CODE}": return "${item.VALUE}";
	            </c:forEach>
	            default:return '0';
	        }
		}
		//取得年收入得分
		,getScore3 : function(value){
			var num=parseFloat(value,10);
		    if(!num){
		    	return '4';
		    }else{
			   	var SEVENTY=parseInt(70,10);
			   	var ONE_HURNDRED=parseInt(100,10);
			   	var ONE_HURNDRED_FIFTY=parseInt(150,10);
			   	var TWO_HURNDRED=parseInt(200,10);
			   	if(num>=TWO_HURNDRED){
			   		return '8';
			   	}else if(num>=ONE_HURNDRED_FIFTY){
			   		return '7';
			   	}else if(num>=ONE_HURNDRED){
			   		return '6';
			   	}else if(num>=SEVENTY){
			   		return '5';
			   	}else{
					return '4';
			   	}
		   	}
		}
		//計算合計分數
		,countTotal : function(){
			new Ajax.Request( '<%=dispatcher%>/DSA2_0901/countTotal',
	    	{ 	
		    	parameters:  { 'SCORE1':$('SCORE1').innerHTML,'SCORE2':$('SCORE2').innerHTML,'SCORE3':$('SCORE3').innerHTML
		    	,'SCORE4':$('SCORE4').innerHTML,'SCORE5':$('SCORE5').innerHTML, 'SCORE6':$('SCORE6').innerHTML
		    	,'SCORE11':$('SCORE11').innerHTML,'GFS_SCORE':$('GFS_SCORE').innerHTML,'APPLY_DATE':$F('APPLY_DATE')}, 	    	
		        onSuccess: function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){
						var totalScore=resp.TOTAL_SCORE;
						$('TOTAL_SCORE1').innerHTML=totalScore;	
						$('TOTAL_SCORE2').innerHTML=totalScore;		
						$('DEBT_SCORE').innerHTML=resp.DEBT_SCORE;			
					}
		        }
		    });
		}
	};
	
	var UpperCase=function(ids){
		$w(ids).each(
		function(id){
			$(id).value = $(id).value.toUpperCase();
		});
	};
	//--------------------------------------------------------------------------        
	//以下為UI() public method,放在 return 中        
	//--------------------------------------------------------------------------          
	return{                              
		//init Function for 初始整個UI Class                
		init:function(){                                        
			valid  = new Validation('body1',{useTitles:true} );
			Validation.addAllThese( [
				[ 'validChecked', '請選擇職業類別',
					function(v){ return previousJOB; }
				]
			] );
			
			//產生 Grid 物件                
			grid = new TableUI( {
				table: $('grid'), allSortable: false, overDiv:false,
				<%-- [20240729] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				autoCheckBox:{ type:'radio', valueKey:'checkedFlag',
					action:function(node , boxStatus , records ){
						setValue.RadioOnClick(records[0]);
					}
				},
				column:[
					{ header: '評估對象', key: 'ID_TYPE_NM'},
					{ header: '對象關係', key: 'NAME', attrs:{style:"font-family:'EUDC'"}},<%--[20240729] 難字調整 --%>
					{ header: '評估人員', key: 'CRED_NAME', attrs:{style:"font-family:'EUDC'"}},<%--[20240729] 難字調整 --%>
					{ header: '評估日期', key: 'CRED_DATE'},
					{ header: '查詢訊息', key: 'QRY_MESSAGE'}
				]
			} );
			
			//查詢 button click event                        
			$('btn_query').observe('click',function(event){                                        
					ButtonFunction.doQuery();					
				}                        
			); 
			//評分 button click event                        
			$('btn_score').observe('click',function(event){                                        
					ButtonFunction.doScore();					
				}                        
			); 
			//刪除 button click event                        
			$('btn_delete').observe('click',function(event){                                        
					ButtonFunction.doDelete();					
				}                        
			);
			
			$$('#table1 input[type="radio"]').each( 
				function(ele){
					ele.onclick = function(){
						//清空radio區的className至預設狀態
						if(previousJOB){
							$(previousJOB).parentNode.className='tbYellow2';
						}
						ele.parentNode.className='tbBlue';
						$('SCORE1').update(Classification.getScore1(ele.value));
						Classification.countTotal();
						previousJOB=ele.id;
					};
				}
			);
			//年收入輸入欄位連動年收入得分
			$('INCOME_TOTAL').observe('blur',function(event){ 
					Classification.IncomeChecked($F('INCOME_TOTAL'));
					Classification.countTotal();			
				}                        
			);
			//實際保費連動年繳保費得分 
			$('PREMIUM').observe('blur',function(event){   
					Classification.PremiumChecked($F('PREMIUM'));
					Classification.countTotal();			
				}                        
			);
					
			if('DSA2_1001'=='${LINK_FROM}'){
				$('APPLY_ID_input').value = '${ACCESS_APPLY_ID}';
			}else if ('${APPLY_ID}' != "") {
				$('APPLY_ID_input').value = '${APPLY_ID}';
			} else {
				$('APPLY_ID_input').value = CSRUtil.keepParamsManager.get('APPLY_ID');	
			}
			if($F('APPLY_ID_input')){
				ButtonFunction.doQuery();
			}
			
		}//end init()--                        
	}//end return--        /
	//-------------------------------------------------------------------------- 
}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body id="body1">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="10%">受理編號</td>
			<td class="tbYellow2">
				<input id="APPLY_ID_input" name="APPLY_ID_input" type="text" class="textBox2 required" size="15" maxlength="11" value="" fieldName="受理編號">
				<input id="APPLY_DATE" type="hidden" value=""/>
			</td>
			<td class="tbYellow2" align="left">
				<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
			</td>
			<td class="tbYellow2">
			  <font color="blue">※若借款資料、保人資料有異動，請重新查詢評分</font>
			</td>
		</tr>
	</table>
									
	<table id="grid" class="grid"></table>
	
   	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
      <tr class="tbYellow0" align=center>
        <td colspan="7">
        	<input id="btn_score" name="btn_score" type="button" class="button" value="評分">
        	<input id="btn_delete" name="btn_delete" type="button" class="button" value="刪除">
        	<input id="TYPE" name="TYPE" type="hidden">
        	<input id="ID" name="ID" type="hidden">
        	<input id="APPLY_PROCESS" name="APPLY_PROCESS" type="hidden">
        	<input id="CRED_ID" name="CRED_ID" type="hidden">
        </td>
      </tr>
      <tr class="tbYellow">
        <td align="center">受理編號</td>
        <td colspan="6" ><span id="APPLY_ID"></span></td>
      </tr>
      <tr class="tbYellow" align=center>
        <td width="6%" style="white-space: nowrap"><strong>項目</strong></td>
        <td style="white-space: nowrap"><strong>第一級</strong></td>
        <td style="white-space: nowrap"><strong>第二級</strong></td>
        <td style="white-space: nowrap"><strong>第三級</strong></td>
        <td style="white-space: nowrap"><strong>第四級</strong></td>
        <td style="white-space: nowrap"><strong>第五級</strong></td>
        <td style="white-space: nowrap"><strong>得分</strong></td>
      </tr>
      <tr>
        <td rowspan="6" class="tbYellow" width="3%" align=center><strong>職業</strong></td>
        <td class="tbYellow2" detail="true" width="18%" align=left><input name="JOB_CODE" id="JOB_CODE11" type="radio" value="11" fieldName="職業">1.公司組織之事業主(年淨利3000萬以上)</td>
        <td class="tbYellow2" detail="true" width="16%" align=left><input name="JOB_CODE" id="JOB_CODE21" type="radio" value="21">1.公司組織之事業主(年淨利500萬以上)</td>
        <td class="tbYellow2" detail="true" width="17%" align=left><input name="JOB_CODE" id="JOB_CODE31" type="radio" value="31">1.公司組織之事業主(年淨利500萬以下)</td>
        <td class="tbYellow2" detail="true" width="20%" align=left><input name="JOB_CODE" id="JOB_CODE41" type="radio" value="41">1.獨資、合夥之營利事業主</td>
        <td class="tbYellow2" detail="true" width="18%" align=left><input name="JOB_CODE" id="JOB_CODE51" type="radio" value="51">1.無固定職業者</td>
        <td class="tbYellow2" rowspan="6" align=center width="8%">
        	<strong><span class="style1" id="SCORE1"></span></strong>
        </td>
      </tr>
      <tr align=left>
        <td class="tbYellow2" detail="true"><input name="JOB_CODE" id="JOB_CODE12" type="radio" value="12">2.上市上櫃公司或大型企業經理級以上主管</td>
        <td class="tbYellow2" detail="true"><input name="JOB_CODE" id="JOB_CODE22" type="radio" value="22">2.上市公司或大型企業基層主管以上</td>
        <td class="tbYellow2" detail="true"><input name="JOB_CODE" id="JOB_CODE32" type="radio" value="32">2.大型企業之正式人員</td>
        <td class="tbYellow2" detail="true"><input name="JOB_CODE" id="JOB_CODE42" type="radio" value="42">2.中小型民營企業正式人員</td>
        <td class="tbYellow2"></td>
      </tr>
      <tr align=left>
        <td class="tbYellow2" detail="true"><input name="JOB_CODE" id="JOB_CODE13" type="radio" value="13">3.高級公教人員</td>
        <td class="tbYellow2" detail="true"><input name="JOB_CODE" id="JOB_CODE23" type="radio" value="23">3.一般軍公教機關之正式人員</td>
        <td class="tbYellow2" detail="true"><input name="JOB_CODE" id="JOB_CODE33" type="radio" value="33">3.中小型民營企業基層主管以上</td>
        <td class="tbYellow2" detail="true"><input name="JOB_CODE" id="JOB_CODE43" type="radio" value="43">3.公營事業之臨時人員</td>
        <td class="tbYellow2"></td>
      </tr>
      <tr align=left>
        <td class="tbYellow2" detail="true"><input name="JOB_CODE" id="JOB_CODE14" type="radio" value="14">4.大專院校講師以上人員</td>
        <td class="tbYellow2" detail="true"><input name="JOB_CODE" id="JOB_CODE24" type="radio" value="24">4.高級技術人員(工程師、程式設計師、藥劑師、獸醫師…等)</td>
        <td class="tbYellow2" detail="true"><input name="JOB_CODE" id="JOB_CODE34" type="radio" value="34">4.獨資、合夥之營利事業主(年淨利100萬以上且本息支出佔年收入比30%以下)</td>
        <td class="tbYellow2" detail="true"><input name="JOB_CODE" id="JOB_CODE44" type="radio" value="44">4.其他自由業人員</td>
        <td class="tbYellow2"></td>
      </tr>
      <tr align=left>
        <td class="tbYellow2" detail="true"><input name="JOB_CODE" id="JOB_CODE15" type="radio" value="15">5.律師、醫師(含中醫師、牙醫師)、會計師、建築師、引水人</td>
        <td class="tbYellow2"></td>
        <td class="tbYellow2"></td>
        <td class="tbYellow2" detail="true"><input name="JOB_CODE" id="JOB_CODE45" type="radio" value="45">5.一般技術人員(水泥工、木工、油漆工、水電工…等)</td>
        <td class="tbYellow2"></td>
      </tr>
      <tr align=left>
        <td class="tbYellow2"></td>
        <td class="tbYellow2"></td>
        <td class="tbYellow2"></td>
        <td class="tbYellow2" detail="true"><input name="JOB_CODE" id="JOB_CODE46" type="radio" value="46">6.靠租金收入者</td>
        <td class="tbYellow2"></td>
      </tr>
      <tr class="tbYellow" align=center>
        <td height="31" style="white-space: nowrap"><strong>年資<br>(含同行業<br>前職)</strong>
        </td>
        <td class="tbYellow2" id="SERV_YEAR1" detail="true" style="white-space: nowrap">10年以上<br>(7)</td>
        <td class="tbYellow2" id="SERV_YEAR2" detail="true" style="white-space: nowrap">8年以上<br>(6)</td>
        <td class="tbYellow2" id="SERV_YEAR3" detail="true" style="white-space: nowrap">5年以上<br>(5)</td>
        <td class="tbYellow2" id="SERV_YEAR4" detail="true" style="white-space: nowrap">3年以上<br>(4)</td>
        <td class="tbYellow2" id="SERV_YEAR5" detail="true" style="white-space: nowrap">未3年<br>(3)</td>
        <td class="tbYellow2" style="white-space: nowrap">
        	<p><strong><U>實際年資</U><br>&nbsp;&nbsp;<span id="SERV_YEAR"></span>年</strong></p>
          <p><strong><span class="style1" id="SCORE2"></span></strong></p></td>
      </tr>
      <tr class="tbYellow" align=center>
        <td height="29" style="white-space: nowrap"><strong>年收入<br>(含配偶)</strong></td>
        <td class="tbYellow2" id="INCOME_TOTAL8" detail="true" style="white-space: nowrap">200萬以上<br>(8)</td>
        <td class="tbYellow2" id="INCOME_TOTAL7" detail="true" style="white-space: nowrap">150萬以上<br>(7)</td>
        <td class="tbYellow2" id="INCOME_TOTAL6" detail="true" style="white-space: nowrap">100萬以上<br>(6)</td>
        <td class="tbYellow2" id="INCOME_TOTAL5" detail="true" style="white-space: nowrap">70萬以上<br>(5)</td>
        <td class="tbYellow2" id="INCOME_TOTAL4" detail="true" style="white-space: nowrap">未滿70萬<br>(4)</td>
        <td class="tbYellow2" style="white-space: nowrap">
        	<p><strong><U>實際收入</U><br><input type="text" class="textBox2" maxLength="10" size="8" value="" name="INCOME_TOTAL" id="INCOME_TOTAL" datatype="number" pattern="#.##" fieldName="實際收入">萬</strong></p>
          <p><strong><span class="style1" id="SCORE3"></span></strong></p>
        </td>
      </tr>
      <tr class="tbBlue3" align=center>
        <td height="27" class="tbYellow" style="white-space: nowrap"><strong>年齡</strong></td>
        <td class="tbYellow2" id="AGE1" detail="true" style="white-space: nowrap">35-54歲<br>(6)</td>
        <td class="tbYellow2" id="AGE2" detail="true" style="white-space: nowrap">30-34歲<br>(5)</td>
        <td class="tbYellow2" id="AGE3" detail="true" style="white-space: nowrap">55以上<br>(4)</td>
        <td class="tbYellow2" id="AGE4" detail="true" style="white-space: nowrap">20-29歲以上<br>(3)</td>
        <td class="tbYellow2"></td>
        <td class="tbYellow2" style="white-space: nowrap">
        	<p><strong><U>實際年齡</U><br>&nbsp;&nbsp;<span id="AGE"></span>歲</strong></p>
        	<p><strong><span class="style1" id="SCORE4"></span></strong></p>
        </td>
      </tr>
      <tr class="tbBlue3" align=center>
        <td height="30" class="tbYellow" style="white-space: nowrap"><strong>婚姻狀況</strong></td>
        <td class="tbYellow2" id="SCORE5_5" detail="true" style="white-space: nowrap">已婚<br>(5)</td>
        <td class="tbYellow2" id="SCORE5_3" detail="true" style="white-space: nowrap">單身<br>(3)</td>
        <td class="tbYellow2" id="SCORE5_2" detail="true" style="white-space: nowrap">離婚、分居或同居<br>(2)</td>
        <td class="tbYellow2"></td>
        <td class="tbYellow2"></td>
        <td class="tbYellow2">
        	<input type="hidden" name="MARRY" id="MARRY" value="" />
        	<strong><span class="style1" id="SCORE5"></span></strong>
        </td>
      </tr>
      <tr class="tbBlue3" align=center>
        <td height="32" class="tbYellow" style="white-space: nowrap"><strong>學歷</strong></td>
        <td class="tbYellow2" id="SCORE6_10" detail="true" style="white-space: nowrap">博士、碩士<br>(10)</td>
        <td class="tbYellow2" id="SCORE6_9" detail="true" style="white-space: nowrap">大(學)專、專科<br>(9)</td>
        <td class="tbYellow2" id="SCORE6_5" detail="true" style="white-space: nowrap">高中(職)以下<br>(5)</td>
        <td class="tbYellow2"></td>
        <td class="tbYellow2"></td>
        <td class="tbYellow2" >
        	<input type="hidden" name="DEGREE" id="DEGREE" value="" />
        	<strong><span class="style1" id="SCORE6"></span></strong>
        </td>
      </tr>
      <tr class="tbBlue3" align=center>
        <td height="30" class="tbYellow" style="white-space: nowrap"><strong>年繳保費<br>(含直系血親)</strong></td>
        <td class="tbYellow2" id="SCORE11_7" detail="true" style="white-space: nowrap">36萬以上<br>(7)</td>
        <td class="tbYellow2" id="SCORE11_5" detail="true" style="white-space: nowrap">15萬以上<br>(5)</td>
        <td class="tbYellow2" id="SCORE11_3" detail="true" style="white-space: nowrap">5萬以上<br>(3)</td>
        <td class="tbYellow2" id="SCORE11_1" detail="true" style="white-space: nowrap">未滿5萬<br>(1)</td>
        <td class="tbYellow2" id="SCORE11_0" detail="true" style="white-space: nowrap">其他<br>(0)</td>
        <td class="tbYellow2" style="white-space: nowrap">
        	<p><strong><U>實際保費</U><br><input type="text" value="" maxLength="9" size="7" class="textBox2" name="PREMIUM" id="PREMIUM" datatype="number" pattern="#.##" fieldName="實際保費">萬</strong></p>
        	<p><strong><span class="style1" id="SCORE11"></span></strong></p>
        </td>
      </tr>
      <tr class="tbYellow2">
        <td colspan="5" style="white-space: nowrap"><strong>進件評分:</strong><span class="style1" id="TOTAL_SCORE2"></span><strong>分</strong>
        	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        	<strong>G-FICO:</strong>&nbsp;&nbsp;<span class="style1" id="GFS_SCORE"></span>&nbsp;&nbsp;<strong>分</strong>
        	<strong>(近一年百分位點:</strong>&nbsp;&nbsp;<span class="style1" id="OY_SCORE"></span>&nbsp;&nbsp;<strong>%)</strong>
        	<p><strong>債信評等:</strong>&nbsp;&nbsp;<span class="style1" id="DEBT_SCORE"></span>&nbsp;&nbsp;<strong>級</strong></p>
        </td>
        <td align="center" style="white-space: nowrap"><strong>合計</strong></td>
        <td class="tbYellow2" align="center">
        	<strong><span class="style1" id="TOTAL_SCORE1"></span></strong>
        </td>
      </tr>
	</table>
	<div id="GFICO" align="canter" style="background:white; padding:10px;" >
	<table id="GFICO_table1" border="0" cellpadding="0" cellspacing="1" class="tbBlue" align="center" style="display:none;" >
		<tr>
			<td colspan="3" rowspan="3">&nbsp;</td>
			<td align="center" colspan="6">GFICO Score</td>
		</tr>
		<tr>
			<td class="blueColor">1</td>
			<td class="blueColor">2</td>
			<td class="blueColor">3</td>
			<td class="blueColor">4</td>
			<td class="blueColor">5</td>
			<td class="blueColor">6</td>
		</tr>
		<tr align="center">
			<td class="tbBlue3">771~</td>
			<td class="tbBlue3">731~770</td>
			<td class="tbBlue3">706~730<br>&0</td>
			<td class="tbBlue3">661~705</td>
			<td class="tbBlue3">631~660</td>
			<td class="tbBlue3">300~630</td>
		</tr>
		<tr align="center">
			<td class="tbBlue" rowspan="6" align="center">進<br>件</td>
			<td class="blueColor">1</td>
			<td class="tbBlue3">>=46分</td>
			<td class="tbYellow2">I</td>
			<td class="tbYellow2">I</td>
			<td class="tbYellow">II</td>
			<td class="tbYellow">II</td>
			<td class="tbYellow0">III</td>
			<td class="tbYellow0">III</td>
		</tr>
		<tr align="center">
			<td class="blueColor">2</td>
			<td class="tbBlue3">39(含)~45分</td>
			<td class="tbYellow2">I</td>
			<td class="tbYellow">II</td>
			<td class="tbYellow">II</td>
			<td class="tbYellow0">III</td>
			<td class="tbYellow0">III</td>
			<td class="tbBlue2">IV</td>
		</tr>
		<tr align="center">
			<td class="blueColor">3</td>
			<td class="tbBlue3">36(含)~38分</td>
			<td class="tbYellow">II</td>
			<td class="tbYellow">II</td>
			<td class="tbYellow0">III</td>
			<td class="tbYellow0">III</td>
			<td class="tbBlue2">IV</td>
			<td class="tbBlue">V</td>
		</tr>
		<tr align="center">
			<td class="blueColor">4</td>
			<td class="tbBlue3">33(含)~35分</td>
			<td class="tbYellow">II</td>
			<td class="tbYellow0">III</td>
			<td class="tbYellow0">III</td>
			<td class="tbBlue2">IV</td>
			<td class="tbBlue2">IV</td>
			<td class="tbBlue">V</td>
		</tr>
		<tr align="center">
			<td class="blueColor">5</td>
			<td class="tbBlue3">31(含)~32分</td>
			<td class="tbYellow0">III</td>
			<td class="tbYellow0">III</td>
			<td class="tbBlue2">IV</td>
			<td class="tbBlue2">IV</td>
			<td class="tbBlue">V</td>
			<td class="tbBlue3">VI</td>
		</tr>
		<tr align="center">
			<td class="blueColor">6</td>
			<td class="tbBlue3"> <31分 </td>
			<td class="tbYellow0">III</td>
			<td class="tbBlue2">IV</td>
			<td class="tbBlue2">IV</td>
			<td class="tbBlue">V</td>
			<td class="tbBlue3">VI</td>
			<td class="tbBlue3">VI</td>
		</tr>
	</table>

	<table id="GFICO_table2" border="0" cellpadding="0" cellspacing="1" class="tbBlue" align="center"  style="display:block;" >
		<tr>
			<td colspan="3" rowspan="3">&nbsp;</td>
			<td align="center" colspan="7">GFICO Score(106/1/1改版)</td>
		</tr>
		<tr>
			<td class="blueColor">1</td>
			<td class="blueColor">2</td>
			<td class="blueColor">3</td>
			<td class="blueColor">4</td>
			<td class="blueColor">5</td>
			<td class="blueColor">6</td>
			<td class="blueColor">7</td>
		</tr>
		<tr align="center">
			<td class="tbBlue3">771~</td>
			<td class="tbBlue3">731~770</td>
			<td class="tbBlue3">706~730</td>
			<td class="tbBlue3">661~705</td>
			<td class="tbBlue3">631~660<br>&0</td>
			<td class="tbBlue3">570~630</td>
			<td class="tbBlue3">~569</td>
		</tr>
		<tr align="center">
			<td class="tbBlue" rowspan="6" align="center">進<br>件</td>
			<td class="blueColor">1</td>
			<td class="tbBlue3">>=46分</td>
			<td class="tbYellow2">I</td>
			<td class="tbYellow2">I</td>
			<td class="tbYellow">II</td>
			<td class="tbYellow">II</td>
			<td class="tbYellow0">III</td>
			<td class="tbYellow0">III</td>
			<td class="tbBlue2">IV</td>
		</tr>
		<tr align="center">
			<td class="blueColor">2</td>
			<td class="tbBlue3">39(含)~45分</td>
			<td class="tbYellow2">I</td>
			<td class="tbYellow">II</td>
			<td class="tbYellow">II</td>
			<td class="tbYellow0">III</td>
			<td class="tbYellow0">III</td>
			<td class="tbBlue2">IV</td>
			<td class="tbBlue2">IV</td>
		</tr>
		<tr align="center">
			<td class="blueColor">3</td>
			<td class="tbBlue3">36(含)~38分</td>
			<td class="tbYellow">II</td>
			<td class="tbYellow">II</td>
			<td class="tbYellow0">III</td>
			<td class="tbYellow0">III</td>
			<td class="tbBlue2">IV</td>
			<td class="tbBlue">V</td>
			<td class="tbBlue">V</td>
		</tr>
		<tr align="center">
			<td class="blueColor">4</td>
			<td class="tbBlue3">33(含)~35分</td>
			<td class="tbYellow">II</td>
			<td class="tbYellow0">III</td>
			<td class="tbYellow0">III</td>
			<td class="tbBlue2">IV</td>
			<td class="tbBlue2">IV</td>
			<td class="tbBlue">V</td>
			<td class="tbBlue3">VI</td>
		</tr>
		<tr align="center">
			<td class="blueColor">5</td>
			<td class="tbBlue3">31(含)~32分</td>
			<td class="tbYellow0">III</td>
			<td class="tbYellow0">III</td>
			<td class="tbBlue2">IV</td>
			<td class="tbBlue2">IV</td>
			<td class="tbBlue">V</td>
			<td class="tbBlue3">VI</td>
			<td class="tbBlue3">VI</td>
		</tr>
		<tr align="center">
			<td class="blueColor">6</td>
			<td class="tbBlue3"> <31分 </td>
			<td class="tbYellow0">III</td>
			<td class="tbBlue2">IV</td>
			<td class="tbBlue2">IV</td>
			<td class="tbBlue">V</td>
			<td class="tbBlue3">VI</td>
			<td class="tbBlue3">VI</td>
			<td class="tbBlue3">VI</td>
		</tr>
	</table>
	</div>
</body>
<!-- InstanceEnd -->
</html>
