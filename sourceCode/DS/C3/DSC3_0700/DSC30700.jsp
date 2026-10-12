<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSC30700.jsp
功能：轉帳重覆退匯查詢
作者：陳昊
完成：2013/05

[20200713] 問題單號：20200707143836 i9300636 周育民
選擇的檔案大小超過限制(10M)，點「確認」跳出錯誤訊息後還是會將該檔案列出，不應該列出有出錯的檔案。
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript'>

Event.observe(window, 'load', new DSC30700().initApp);


function DSC30700(){
	var grid_B,grid_C,grid_D;
	var grid_list=[];
	var grid_index=0;
	var valid1;
	
	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_0700/" + actionName,
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
	
	//按鈕授權
	function buttonAuth(){
		var authButtons = {
			B0064:'btn_upload'
		};
		<dz:grantButtons FUNC_ID="DSC30700" ignored='false'/>
	};
	
	// 畫面檢核
	function initValidation(){
		valid1 = new Validation('form',{focusOnError:true,immediate:false,mode:'validator'});	
		valid1.define('required',[{id:'TRANS_YM',errMsg:'請輸入抽件年月'}]);
		valid1.define('validate-number',[{id:'TRANS_YM',errMsg:'抽件年月須為數字格式'}]);
	};
	
	//儲存畫面
	function storeMap(){
		var reqMap={
			INPUT_FILE:$F('INPUT_FILE')||''
		};
		return reqMap;
	};
	
	//刪除檔案
	function remove_col(index){
		var tmp=[];
		for(var i=0;i<grid_list.length;i++){
			if(i!=index){
				tmp.push(grid_list[i]);
			}
		}
		grid_list=tmp;
		grid_index=0;
		grid_B.load(grid_list);
	};

	//取得nodeType 為1 的節點
	function getElementNode(n){
	    if(n.nodeType == 1){
			return n;
	    }	
        var x = n.nextSibling;
        while (x && x.nodeType!=1){
                x = x.nextSibling;
        }
        return x;
    }
	
	function set_rtnList(rtnList){
		$('table3').show();
		$('table4').show();
		$$('#table4 input','#table4 span','#table4 br','#table4 tr','#table4 td').each(function(ele){
			ele.remove();
		});
		for(var i=0;i<rtnList.length;i++){
			var tr=new Element('tr');
			var td=new Element('td',{className:"tbBox3 textBold",colspan:'6'});
			//td.insert(new Element('span',{innerHTML:rtnList[i]['TRANS_BANK_NM']||''}));
			td.insert(new Element('span').update(rtnList[i]['TRANS_BANK_NM']||''));
			tr.insert(td);
			var tBody = getElementNode($('table4').firstChild);		
			tBody.appendChild(tr);
		
			var tr=new Element('tr');
			var td=new Element('td',{className:"tbYellow",width:'13%'});
			//td.insert(new Element('span',{innerHTML:'轉帳年月'}));
			td.insert(new Element('span').update('轉帳年月'));
			tr.insert(td);
			var td=new Element('td',{className:'tbYellow2',width:'20%'});
			td.insert(new Element('input',{value:rtnList[i]['TRANS_YM']||'',className:'textBox2',type:'text',readonly:'true'}));
			tr.insert(td);
			var td=new Element('td',{className:"tbYellow",width:'13%'});
			//td.insert(new Element('span',{innerHTML:'轉帳銀行'}));
			td.insert(new Element('span').update('轉帳銀行'));
			tr.insert(td);
			var td=new Element('td',{className:'tbYellow2',width:'20%'});
			td.insert(new Element('input',{value:rtnList[i]['TRANS_BANK_NM']||'',className:'textBox2',type:'text',readonly:'true'}));
			tr.insert(td);
			var td=new Element('td',{className:"tbYellow",width:'13%'});
			//td.insert(new Element('span',{innerHTML:'轉帳組別'}));
			td.insert(new Element('span').update('轉帳組別'));			
			tr.insert(td);
			var td=new Element('td',{className:'tbYellow2'});
			//td.insert(new Element('span',{innerHTML:rtnList[i]['TRANS_GROUP']||''}));
			td.insert(new Element('span').update(rtnList[i]['TRANS_GROUP']||''));	
			tr.insert(td);
			tBody.appendChild(tr);
			
			var tr=new Element('tr');
			var td=new Element('td',{className:"tbYellow"});
			//td.insert(new Element('span',{innerHTML:'應繳起日'}));
			td.insert(new Element('span').update('應繳起日'));				
			tr.insert(td);
			var td=new Element('td',{className:'tbYellow2'});
			td.insert(new Element('input',{value:rtnList[i]['BEGIN_DATE']||'',className:'textBox2',type:'text',readonly:'true'}));
			tr.insert(td);
			var td=new Element('td',{className:"tbYellow"});
			//td.insert(new Element('span',{innerHTML:'應繳迄日'}));
			td.insert(new Element('span').update('應繳迄日'));	
			tr.insert(td);
			var td=new Element('td',{className:'tbYellow2'});
			td.insert(new Element('input',{value:rtnList[i]['END_DATE']||'',className:'textBox2',type:'text',readonly:'true'}));
			tr.insert(td);
			var td=new Element('td',{className:"tbYellow"});
			//td.insert(new Element('span',{innerHTML:'扣帳日期'}));
			td.insert(new Element('span').update('扣帳日期'));	
			tr.insert(td);
			var td=new Element('td',{className:'tbYellow2'});
			td.insert(new Element('input',{value:rtnList[i]['DEDUCT_DATE']||'',className:'textBox2',type:'text',readonly:'true'}));
			tr.insert(td);
			tBody.appendChild(tr);
			
			var tr=new Element('tr');
			var td=new Element('td',{className:"tbYellow"});
			//td.insert(new Element('span',{innerHTML:'轉帳狀態'}));
			td.insert(new Element('span').update('轉帳狀態'));	
			tr.insert(td);
			var td=new Element('td',{className:'tbYellow2',colspan:'6'});
			//td.insert(new Element('span',{innerHTML:rtnList[i]['TRANS_STATUS_NM']||''}));
			td.insert(new Element('span').update(rtnList[i]['TRANS_STATUS_NM']||''));				
			tr.insert(td);
			tBody.appendChild(tr);
			
			var tr=new Element('tr');
			var td=new Element('td',{className:"tbBlue",colspan:'6',align:'center'});
			//td.insert(new Element('span',{innerHTML:'扣帳'}));
			td.insert(new Element('span').update('扣帳'));	
			tr.insert(td);
			tBody.appendChild(tr);
			
			var tr=new Element('tr');
			var td=new Element('td',{className:"tbYellow"});
			//td.insert(new Element('span',{innerHTML:'送出件數金額'}));
			td.insert(new Element('span').update('送出件數金額'));	
			tr.insert(td);
			var td=new Element('td',{className:'tbYellow2'});
			td.insert(new Element('input',{value:rtnList[i]['TRANS_CNT']||'',className:'textBox2',type:'text',readonly:'true'}));
			td.insert(new Element('input',{value:formatNumber(rtnList[i]['TRANS_AMT'])||'',className:'textBox2',type:'text',readonly:'true'}));
			tr.insert(td);
			var td=new Element('td',{className:"tbYellow"});
			//td.insert(new Element('span',{innerHTML:'送回件數金額'}));
			td.insert(new Element('span').update('送回件數金額'));				
			tr.insert(td);
			var td=new Element('td',{className:'tbYellow2'});
			td.insert(new Element('input',{value:rtnList[i]['DEDUCT_CNT']||'',className:'textBox2',type:'text',readonly:'true'}));
			td.insert(new Element('input',{value:formatNumber(rtnList[i]['DEDUCT_AMT'])||'',className:'textBox2',type:'text',readonly:'true'}));
			tr.insert(td);
			var td=new Element('td',{className:"tbYellow"});
			//td.insert(new Element('span',{innerHTML:'未成件數金額'}));
			td.insert(new Element('span').update('送回未成件數金額'));				
			tr.insert(td);
			var td=new Element('td',{className:'tbYellow2'});
			td.insert(new Element('input',{value:rtnList[i]['NODE_CNT']||'',className:'textBox2',type:'text',readonly:'true'}));
			td.insert(new Element('input',{value:formatNumber(rtnList[i]['NODE_AMT'])||'',className:'textBox2',type:'text',readonly:'true'}));
			tr.insert(td);
			tBody.appendChild(tr);
			
		}
		
	};
	
	function formatNumber(value){
		 return (value||value===0) ? CSRUtil.$fmt(value,"#,###") : value ; 
	}
	
	var buttons ={
		//確認
		doConfirm : function(){
			if(!$F('INPUT_FILE')){
				alert('選取檔案不可空白');
				return;
			}
			var fileNM = $F('INPUT_FILE').split('.');
			var fileType = fileNM[fileNM.length - 1].toUpperCase();
			if(fileType!="TXT"){
				alert("檔案必須為txt檔");
				return;
			}
			auxiliary.createCoverPage();
			$(document.form).insert(new Element('input',{name:'INPUT_FILE',type:'hidden',value:$F('INPUT_FILE')}));
			document.form.submit();
			$('table1').show();
			$('div_B').show();
		},
		//扣款上傳
		doUpload:function(event){
			if(!valid1.validate()){
				return;
			}
			var datas=grid_B.getCheckedRecord();
			if(datas.length==0){
				alert('請選取要上傳的檔案');
				return;
			}
			if(checkFILE_NM(datas)){
				return;
			}
			ajaxPost('upload',{'datas':Object.toJSON(datas),'TRANS_YM':$F('TRANS_YM'),'TRANS_GROUP':$F('TRANS_GROUP'),'TRANS_BANK_T':$F('TRANS_BANK')}
				,function(resp){
					grid_C.load(resp.LAST_FILE||[]);
					grid_D.load(resp.rtnList||[]);
					$('table2').show();
					$('div_C').show();
					$('div_D').show();
			});
		},
		importEnd:function(){
			if(!window.importFrame.document.getElementById("filedata")){				
				return;
			}
			auxiliary.closeCoverPage();
			
			var resp = window.importFrame.document.getElementById("filedata").innerHTML.evalJSON();
			var Msg = resp.ErrMsg.msgDesc.replace("\\n","");
			if(Msg){
				alert(Msg);
				/* [20200713] 問題單號：20200707143836 i9300636 周育民
				選擇的檔案大小超過限制(10M)，點「確認」跳出錯誤訊息後還是會將該檔案列出，不應該列出有出錯的檔案。 */
				return;
			}
			
			var filePath_svr =resp.filePath;
			var file=$F('INPUT_FILE').split('\\');
			var FILE_NM=file[file.length-1].toUpperCase();
			var FILE_PATH='';
			for(var i=0;i<file.length-1;i++){
				if(i!=0){
					FILE_PATH=FILE_PATH+'\\'+file[i];
				}else{
					FILE_PATH=file[i];
				}
			}
			var tmp={};
			tmp['FILE_NM']=FILE_NM;
			tmp['FILE_PATH']=FILE_PATH;
			tmp['FILE_PATH_SERVER']=filePath_svr;
			grid_list.push(tmp);
			grid_index=0;
			grid_B.load(grid_list);
			
			/*$('import').update(new Element("input"
				,{ id:"INPUT_FILE", name:"INPUT_FILE", type:"file", 'class': "textBox2", size:"50"}));
			$('import').insert(new Element("input"
				,{id:"btn_confirm",type:"button","class":"button",value:"確認"}));
			$('btn_confirm').observe('click', buttons.doConfirm);*/
		},
		//刪除
		doDelete:function(index){
			ajaxPost('delete',{'data':Object.toJSON(grid_list[index]),'index':index}
				,function(resp){
					if(resp.index||resp.index==='0'){
						remove_col(resp.index);
					}
			});
		},
		//扣款確認查詢
		doAgree:function(event){
			if(!valid1.validate()){
				return;
			}
			ajaxPost('agree',{'TRANS_YM':$F('TRANS_YM'),'TRANS_GROUP':$F('TRANS_GROUP'),'TRANS_BANK_T':$F('TRANS_BANK')}
				,function(resp){
					if(resp.rtnList){
						set_rtnList(resp.rtnList);
					}
			});
		}
	}
	
	//檢查檔案名稱
	function checkFILE_NM(rec){
		var flag=false;
		var option=$F('TRANS_BANK');
		for(var i=0;i<rec.length;i++){
			var FILE_NM=rec[i]['FILE_NM'].toUpperCase();
			var length=FILE_NM.length;
			if(option==1){
				if(length<8||FILE_NM.substring(0,8)!='POSTBK01'){
					flag=true;
					break;
				}
			}else if(option==2){
				if(length<6||FILE_NM.substring(0,6)!='OBDDTA'){
					flag=true;
					break;
				}
			}else if(option==3){
				if(length<9||FILE_NM.substring(0,9)!='POSTBK01F'){
					flag=true;
					break;
				}
			}else if(option==4){
				if(length<7||FILE_NM.substring(0,7)!='OBDDTAF'){
					flag=true;
					break;
				}
			}else if(option==5){
				if(length<9||FILE_NM.substring(0,9)!='POSTBK01M'){
					flag=true;
					break;
				}
			}else if(option==6){
				if(length<7||FILE_NM.substring(0,7)!='OBDDTAM'){
					flag=true;
					break;
				}
			}
		}
		if(flag){
			alert("扣款銀行與上傳檔案名稱不符合");
			return true;
		}else{
			return false;
		}
	}
	
	var auxiliary = {
		createCoverPage:function(){
			var cover = CSRUtil.createCoverPage('_frontCover');
			cover.show();
		},
		closeCoverPage: function(){
			$('_frontCover').hide();
		}
	};
	
	return {
		initApp : function() {

			PageUI.createPageWithAllBodySubElement('DSC30700', '繳款方式', '銷帳媒體確認');
			
			grid_B = new TableUI({
				table:$("grid_B"),allSortable:false,overDiv:false,
				autoCheckBox:{isSelectAll:true},
				column:[
					{header:"檔名",key:"FILE_NM"},
					{header:"檔案路徑",key:"FILE_PATH"},
					//{header:"伺服器檔案路徑",key:"FILE_PATH_SERVER"},
					{header:"點選刪除",key:'xx',attrs:{width:'10%'},
						render:function(rec,val){
							var btn=new Element('input',{type:'button',className:'button',value:'刪除',index:grid_index});
							btn.observe("click",function(event){
									buttons.doDelete(btn.getAttribute('index'))
							});
							grid_index++;

							var span = new Element('span');
							span.insert(btn);							      			

							return span;  
						}
					}
				]
			});
			
			grid_C = new TableUI({
				table:$("grid_C"),allSortable:false,overDiv:false,
				split:['TOT_AMT'],
				column:[
					{header:"媒體總件數",key:"TOT_CNT",
						render:function(rec,val){
							return (val)?val+'件':'0件';
						}
					},
					{header:"媒體交易成功件數",key:"SUCC_CNT",
						render:function(rec,val){
							return (val)?val+'件':'0件';
						}
					},
					{header:"媒體交易失敗件數",key:"FAIL_CNT",
						render:function(rec,val){
							return (val)?val+'件':'0件';
						}
					},
					{header:"媒體總金額",key:"TOT_AMT",
						render:function(rec,val){
							return (val)?CSRUtil.$fmt(val,'#,###')+'元':'';
						}
					},
					{header:"媒體交易成功總金額",key:"SUCC_AMT",
						render:function(rec,val){
							return (val)?CSRUtil.$fmt(val,'#,###')+'元':'';
						}
					},
					{header:"媒體交易失敗總金額",key:"FAIL_AMT",
						render:function(rec,val){
							return (val)?CSRUtil.$fmt(val,'#,###')+'元':'';
						}
					}
					
				]
			});
			
			grid_D = new TableUI({
				table:$("grid_D"),allSortable:false,overDiv:false,
				split:['TOT_AMT1'],
				column:[
					{header:"上傳銀行",key:"BANK_NM",attrs:{rowSpan:2}},
					{header:"上傳總件數",key:"TOT_CNT1",
						render:function(rec,val){
							return (val)?val+'件':'0件';
						}
					},
					{header:"上傳交易成功件數",key:"SUCC_CNT1",
						render:function(rec,val){
							return (val)?val+'件':'0件';
						}
					},
					{header:"上傳交易失敗件數",key:"FAIL_CNT1",
						render:function(rec,val){
							return (val)?val+'件':'0件';
						}
					},
					{header:"上傳總金額",key:"TOT_AMT1",
						render:function(rec,val){
							return (val)?CSRUtil.$fmt(val,'#,###')+'元':'';
						}
					},
					{header:"上傳交易成功總金額",key:"SUCC_AMT1",
						render:function(rec,val){
							return (val)?CSRUtil.$fmt(val,'#,###')+'元':'';
						}
					},
					{header:"上傳交易失敗總金額",key:"FAIL_AMT1",
						render:function(rec,val){
							return (val)?CSRUtil.$fmt(val,'#,###')+'元':'';
						}
					}
				]
			});
			
			initValidation();
			buttonAuth();
			
			$('btn_confirm').observe('click', buttons.doConfirm);
			$('btn_upload').observe('click', buttons.doUpload);
			$('btn_agree').observe('click', buttons.doAgree);
			$("importFrame").observe('load', function(event){
				buttons.importEnd();
			});
			
			
			PageUI.resize();
			displayMessage();
		}
	}
	
	
}
</script>
</head>
<body>
<form id="form" name="form" method="post" target="importFrame" enctype="multipart/form-data" action="<%=dispatcher%>/DSC3_0700/confirm"  style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="12%" align="left" >抽件年月</td>
		<td class="tbYellow2" width='13%'>
			<input id="TRANS_YM" name="TRANS_YM" type="text" class="textBox2"  maxlength="5" value='${CURR_DATE}'/>
		</td>
		<td class="tbYellow" width="12%" align="left" >轉帳組別</td>
		<td class="tbYellow2" width="13%">
			<select id="TRANS_GROUP">
				<c:forEach var="map" items="${TRANS_GROUP_List}">
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select> 
		</td>
		<td class="tbYellow" width="12%" align="left" >轉帳銀行</td>
		<td class="tbYellow2" width="13%">
			<select id="TRANS_BANK">
				<c:forEach var="map" items="${TRANS_List}">
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select> 
		</td>
		<td class="tbYellow2" align='center'>
			<input id="btn_upload" type="button" class="button" value="扣款上傳"> 
			<input id="btn_agree" type="button" class="button" value="扣款確認查詢"> 
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			選取檔案
		</td>
		<td class="tbYellow2" id="import" colspan='6'>
			<input id="INPUT_FILE" name="INPUT_FILE" type="file" class="textBox2" size="50" />
			<input id="btn_confirm" type="button" class="button" value="確認" />
		</td>
	</tr>
</table>
<div id='table1' class="tbBox3 textBold" align='center' style="display:none">
	選取檔案結果--執行扣款上傳後，將選取檔案一次上傳
</div>
<div id='div_B' style="display:none">
	<table id="grid_B" class='grid' width="100%" style="display:none"></table>
</div>
<div id='table2' class="tbBox3 textBold" align='center' style="display:none">
	銷帳媒體上傳成功
</div>
<div id='div_C' style="display:none">
	<table id="grid_C" class='grid' width="100%" style="display:none"></table>
</div>
<div id='div_D' style="display:none">
	<table id="grid_D" class='grid' width="100%" style="display:none"></table>
</div>
<div id='table3' class="tbBox3 textBold" align='center' style="display:none">
	扣款確認查詢
</div>
<table id='table4' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" style="display:none">
	<tbody></tbody>
</table>
<iframe id="importFrame" name="importFrame" width="0" height="0" style="display:none"></iframe>
</form>
</body>
</html>