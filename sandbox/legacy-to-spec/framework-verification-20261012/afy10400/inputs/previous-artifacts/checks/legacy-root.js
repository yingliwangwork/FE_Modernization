

<!--取得唯一不重複的id-->
function get_unique_num(){
	unique_num++;
	return unique_num;
}

function initApp(){
	unique_num = 0;
	tb1 = document.getElementById("table1");
	displayMessage();
}

function doAdd(){
	var tempcount = get_unique_num();
	console.log(tempcount);
	var newRow = tb1.insertRow();
	newRow.id = "table1_row_" + tempcount;
	var newCell;
	var elemStr;
	newCell = newRow.insertCell();
	elemStr = '<input type="button" class="button" value="刪除此列" id="deleleBtn_' + tempcount +'" onclick="doDelete(\'' + tempcount + '\')" >';
	newCell.innerHTML = elemStr;
	newCell.align="center";
	
	newCell = newRow.insertCell();
	elemStr = '<input type="text" size="12" maxlength="10" name= "I_ID" id="I_ID_' + tempcount + '" class="textBox2" >';
	newCell.innerHTML = elemStr;	
	newCell.align="center";
	
	newCell = newRow.insertCell();
	elemStr = '<textarea rows="3" cols="30" name= "POLICY_NO" id="POLICY_NO_' + tempcount + '" class="textBox2" >';
	newCell.innerHTML = elemStr;	
	newCell.align="center";
	
	newCell = newRow.insertCell();
	elemStr = '';
	newCell.innerHTML = elemStr;	
	RowColor();
}

function doDelete(key){
	var temp = document.getElementById(("table1_row_" +key));	
	temp.remove();
	RowColor();
}

function doExport(){
	var param = {
		'insrType': $F('insrType'),
    	'prodType': $F('prodType'),
    	'table1_I_ID':[],
    	'table1_POLICY_NOs':[]
	}
	
	var table1_I_ID = document.getElementsByName("I_ID");
	var table1_POLICY_NOs = document.getElementsByName("POLICY_NO");
	for(var i =0; i< table1_I_ID.length ; i++){
		var I_ID = table1_I_ID[i].value;
		var POLICY_NOs = table1_POLICY_NOs[i].value;
		param.table1_I_ID[i]=I_ID;
		param.table1_POLICY_NOs[i]=POLICY_NOs;
		if(I_ID == "" || POLICY_NOs ==""){
			i=i+1;
			alert("第" + i + "列的被保人ID或保單號碼不得為空值，若不需要請刪除該列");
			return;
		}
		for(var j =i+1; j< table1_I_ID.length ; j++){
			var I_ID_2 = table1_I_ID[j].value;
			if(I_ID == I_ID_2){
				alert("被保人ID：" + I_ID + "有重覆出現，請合併在同一列處理");
				return;
			}
		}
	}
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/AFY1_0400/');
	
	ajaxRequest.post('export',Form.serialize('frm'),
	function(resp){
		var fileName = resp.fileName;
		const rtnMap = new Map(Object.entries(resp.rtnMap));
		for(var i =0; i< table1_I_ID.length ; i++){
			var I_ID = table1_I_ID[i].value;
			document.all.table1.rows[i+3].cells[3].innerHTML = rtnMap.get(I_ID);
		}
		console.log('doRPTUtil');
		RPTUtil.downloadFile('${dispatcher}/AFY1_0400/download', { fileName : fileName } , false);
	},function(resp){
		const rtnMap = new Map(Object.entries(resp.rtnMap));
		for(var i =0; i< table1_I_ID.length ; i++){
			var I_ID = table1_I_ID[i].value;
			document.all.table1.rows[i+3].cells[3].innerHTML = rtnMap.get(I_ID);
		}
	});
}

function RowColor(){
    for (i=3; i < document.all.table1.rows.length; i++) {
		if(i%2 == 0){
			document.all.table1.rows[i].bgColor = "#FAFBE1"; //tbYellow2
		}else{
			document.all.table1.rows[i].bgColor = "#EEF1A7"; //tbYellow
		}
    }
}

