<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
Date	Version	Description	Author
2012/10/17	1.0	Created	宋少瑋

UCDSC3_1100_扣薪日期作業

一、	程式功能概要說明：
程式功能	扣薪日期作業
程式名稱	DSC3_1100
作業方式	ONLINE
概要說明	(1)	修改 ─ 使用者按下確認按鈕後，修改放款扣薪組別檔(DTDSC450)。
			(2) 查詢 ─ 使用者按下查詢按鈕後，查詢放款扣薪組別檔(DTDSC450)。
按鈕授權	FUNC_ID = DSC31100

@author 楊鈞傑
@since  2012/11/13

-->


<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%> <!--執行結果顯示-->
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type='text/javascript'>

// 產生畫面物件
var DSC31100 = new DSC31100();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSC31100.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC31100(){
	
	//查詢的檢核
	var valid1;
	
	//修改的檢核
	var valid2;
	var grid1;
	
	//前次查詢條件
	var queryInputMap = {} ;
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0004:"btn_update"<%--修改--%> 
		};
		
		<dz:grantButtons FUNC_ID="DSC31100" ignored="true"/>
	}
	//畫面檢核
	function initValidation(){
		
		//查詢用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });
		valid1.define( "required" , { id: "WORK_YEAR" ,errMsg : '該年度無扣薪日期資訊' } );
		
		//修改用檢核
		valid2 = new Validation("form1", { focusOnError:true, immediate:false });
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_1100/" + actionName,
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
	
	//button對應的event function
	var button = {
		//查詢資料
		doQuery : function(event){
			
			valid1.reset();
			if(!valid1.validate()){ 
				return; 
			}
			
			var  sendRecord = {
				SALARY_GROUP : $F('SALARY_GROUP'), 	
				WORK_YEAR : $F('WORK_YEAR')		
			}		
			queryInputMap = sendRecord;

			//發送ajax
			ajaxPost( 'query', {sendRecord : Object.toJSON(queryInputMap)},
				function(resp){	
					grid1.load(resp.rtnList);
					PageUI.resize(true);
				},
				function(resp){					
					//失敗把前次內容清掉 並把鑑價,支援人員list清掉
					grid1.load([]);
					PageUI.resize(true);
				}
			);		
		},		
		
		
		//修改
		doUpdate : function(event){	
			
			valid2.reset();
			if(!valid2.validate()){ 
				return; 
			}
			
			var data = grid1.getCheckedRecord();			
			if(!data.length >0){
				alert("請先選取欲修改資料，才能作業!!");
				return;
			}		
			//發送ajax
			ajaxPost( 'update' , 
				{
					'DATA_LIST' : Object.toJSON(data), //畫面勾選的records
					sendRecord : Object.toJSON(queryInputMap) //上次查詢的條件		
				},
				function(resp){			
					//重查,並紀錄新的List			
					grid1.load(resp.rtnList);
					PageUI.resize(true);
				},
				function(resp){					
					//失敗把前次內容清掉
					grid1.load([]);
					PageUI.resize(true);
				}
			);	
		}
	}

	return {

			initApp : function() {

				PageUI.createPageWithAllBodySubElement("DSC31100", "繳款方式", "扣薪日期作業");
				PageUI.resize(true);

				grid1 = new TableUI ( {
					table: $("grid1"), autoCheckBox:{isSelectAll:false,returnValue:['SALARY_DATE','SALARY_GROUP_NM','WORK_YM','SALARY_QC','SALARY_OK','SALARY_GROUP']
					,action: function( checkbox , boxStatus , records ) {    
								var node = checkbox;
								// node一開始是點選的cell，因為record會存在TR中，所以node要向上取到TR                             
								while( node.tagName != 'TR' ) { 
									node = node.parentNode;
								}
								
								//將該TR有設定input的欄位顯示/隱藏
								//node -整列TR obj, array-包含要換的key值
								if(records[0].SALARY_GROUP == 90 ){
									grid1.exchangeAutoInput( node, ['SALARY_DATE','SALARY_QC']);
								}else{
									grid1.exchangeAutoInput( node, ['SALARY_DATE']);
								}
                         } }, 
						pageSize: 20, allSortable:false,
					column:[					
					{header:"扣薪組別",key:"SALARY_GROUP_NM"},
					{header:"工作年月",key:"WORK_YM"},
					{header:"扣薪日期",key:"SALARY_DATE",
						input:{type:'TEXT',size:25 , width:25, maxlength:7,className :'required validate-ROCDate',attrs:{className:'required validate-ROCDate'}
						
						,action:function(node, dataObj , textDiv, orgData, isOnChange){
								dataObj = dataObj[0];							 
								dataObj.SALARY_DATE= dataObj.SALARY_DATE;
								if(dataObj.SALARY_GROUP == '00' || dataObj.SALARY_GROUP == '10' || dataObj.SALARY_GROUP == '40'){
									dataObj.SALARY_OK= dataObj.SALARY_DATE;
								}
					    }				    
						,genRule:function(record , value){
							 return false;
						}}
						
					},
					{header:"繳息起日",key:"PAY_BEGDT"},
					{header:"繳息迄日",key:"PAY_ENDDT"},
					{header:"扣薪QC日",key:"SALARY_QC",
						input:{type:'TEXT', size:25 , width:25, maxlength:7,className :'required validate-ROCDate',attrs:{className:'required validate-ROCDate'}
						,action:function(node, dataObj , textDiv, orgData, isOnChange){
								dataObj = dataObj[0];							 
								dataObj.SALARY_QC= dataObj.SALARY_QC;
								if(dataObj.SALARY_GROUP == '90'){
									dataObj.SALARY_OK= dataObj.SALARY_QC;
								}	
									
					    }
						,genRule:function(record , value){
							 return false;
						}}
						,render:function(record, value){
							 if(record.SALARY_GROUP == '00' || record.SALARY_GROUP == '10' || record.SALARY_GROUP == '40'){
								return record.SALARY_DATE;
							 }else{
								return value;
							 }							
						}
					},
					{header:"扣薪確認日",key:"SALARY_OK",
						render:function(record, value){							
							 if(record.SALARY_GROUP == '00' || record.SALARY_GROUP == '10' || record.SALARY_GROUP == '40'){
								return record.SALARY_DATE;
							 }else if(record.SALARY_GROUP == '90'){
								return record.SALARY_QC;
							}							
						}},
					{header:"車馬費QC日",key:"ALWC_QC"},
					
					{header:"車馬費確認日",key:"ALWC_OK"}					
				]
					
				});
				
				//註冊DOM物件
				//click事件
				$("Btn_query").observe("click", button.doQuery );		
				$("Btn_update").observe("click", button.doUpdate );
				
				initValidation();	
				
				fix(); // 可用 PageUI.resize() 替代

				buttonAuth();
				
				displayMessage();
				
			}
	};	
};

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 
	<form id="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>				
				<td class="tbYellow" width="15%">扣薪組別</td>					
				<td class="tbYellow2"  width="15%">
					<select id="SALARY_GROUP" >	
						<c:forEach var="map" items="${SALARY_LIST}" >
							<option value = "${map.key}" <c:if test="${map.key eq 00}" >selected</c:if>> ${map.value} </option>
						</c:forEach>					
					</select>
				</td>				
				<td class="tbYellow" width="20%" align="left" >
					工作年度
				</td>					
				<td class="tbYellow2" width = "20%">
					<input id="WORK_YEAR" type="text" class="text2" size="12" maxlength="3" class="textBox" value="<c:out value = "${WORK_YEAR}"/>"/>			
				</td>					
				<td class="tbYellow2" width="20%" align="center" >
					<input type="button" id="Btn_query" class="button" value="查詢" />
				</td>					
			</tr>
			
			<tr>
				<td colSpan="5" align="center">
					<input type="button" id="Btn_update" class="button" value="修改" />
				</td>
			</tr>
		</table>	
		<table id='grid1' width="100%"></table>
	</form>			
</body>
</html>