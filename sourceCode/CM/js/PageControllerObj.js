/*
程式：pageController.js快速鍵。
作者：新契約小組
功能：提供送出畫面的各種檢核
完成：2004/02/05
說明：	
	用於多筆查詢需分頁時
	Main function: function page(form,size,rowid,infoid,fetchTR)
	parameter : 1. form >> form name
				2. size >> 每頁要秀之筆數
				3. 資料欄id
				4. 分頁訊息顯示欄之id
				5. 每幾個<tr>算是一筆資料(for會有 rowspan 的顯示處理)(optional parameter)
更新：
*/

function PageControllerObj() {
	this.rowElements;
	this.totalrecord = 0;
	this.totalpages = 0;
	this.pagesize = 10;
	this.curpage = 0;
	this.fetchRows = null;
	this.pageinfo;
}

function page(obj, form, size, rowid, infoid, fetchTR) {

	
	// 取得 form 內的要作用的列
	var getDataNodes = function( tagName ) { 
		
		var nodes = form.getElementsByTagName(tagName);
		
		var nodeElements;
		
		// 將符合 rowid 的元素放到 rowElements 陣列裡
		// 若 nodes 為 null 或長度為 0，則不產生 rowElements 陣列實體
		for(var i = 0; i < nodes.length; i ++) {
			
			if(!nodeElements) {
				nodeElements = [];
			}
			
			var node = nodes[i];
			
			if(node.id == rowid) {
				nodeElements.push(node);
			}
		}
		
		return nodeElements.length > 0 ? nodeElements : null;
	};

	obj.rowElements = getDataNodes('TR');

	if(!obj.rowElements) {
		// form 內符合 rowid 的元素不是 tr 時，就須改取 td
		obj.rowElements = getDataNodes('TD');
	}
	
	// rowElements 陣列有實體且長度大於 0，才表示有資料
	if (obj.rowElements && obj.rowElements.length > 0) {
		
		// 若有斷行，資料筆數 = rowElements.length / fetchRows( 每筆資料的折行數 )
		if (fetchTR && fetchTR > 1) {
			obj.fetchRows = fetchTR;
			obj.totalrecord = obj.rowElements.length / obj.fetchRows;
		}else{
			obj.totalrecord = obj.rowElements.length;		
		}
	}
	
	// 計算總頁數
	obj.pagesize = size;
	obj.totalpages = parseInt(obj.totalrecord/obj.pagesize);
	if ((obj.totalrecord % obj.pagesize) != 0){
		obj.totalpages++;
	}
	
	// 取得 bottom 分頁資訊區塊
	obj.pageinfo = document.getElementById(infoid);
    
	// 行資料顯示/隱藏 切換
	gotoPage(obj,0);
	//return obj;
}


function gotoFirstPage(obj) {
	obj = gotoPage(obj, 0);
	//return obj;
}

function gotoLastPage(obj) {
	obj = gotoPage(obj, parseInt(obj.totalpages - 1));
	//return obj;
}

function gotoNextPage(obj) {
	obj = gotoPage(obj, parseInt(obj.curpage) + 1);
	//return obj;
}

function gotoPrevPage(obj) {
	obj = gotoPage(obj, parseInt(obj.curpage) - 1);
	//return obj;
}

function gotoPage(obj, n) {
	
	/**檢查傳入頁數是否正確*/
	if (( n < 0) || (n >= obj.totalpages)){
		//return obj;
		return;
	}
	
	/**隱藏前一頁資料*/
	var bgn = obj.curpage * obj.pagesize;
	if (bgn < 0) {
		bgn = 0;
	}
	var end = obj.pagesize * (1 + obj.curpage);
	if (end > obj.totalrecord) {
		end = obj.totalrecord;
	}

	// 有資料時才作用
	var hasData = obj.rowElements && obj.rowElements.length > 0;

	if(hasData){
		
		// 隱藏前一頁的行資料
		for(var i = bgn; i < end; i ++) {
			if(obj.fetchRows){
				var j = i * obj.fetchRows;
				for(var k = 0; k < obj.fetchRows; k++){
					obj.rowElements[j + k].style.display = "none";
				}
			}else{
				obj.rowElements[i].style.display = "none";
			}
		}
	}
	
	/**顯示此頁資料*/
	var bgns = n * obj.pagesize;
	if (bgns<0){
		bgns = 0;
	}
	var ends = obj.pagesize * (1 + n);
	if (ends > obj.totalrecord) {
		ends = obj.totalrecord;
	}

	if(hasData){
	
		// 針對要顯示的資料清除 style.display 的內容
		// 在不同瀏覽器中都可以顯示資料
		for(var i = bgns; i < ends; i++ ){
				
			if(obj.fetchRows){
				var j = i * obj.fetchRows;
				
				for(var k = 0; k < obj.fetchRows; k++ ){
					obj.rowElements[j + k].style.display = "";
				}
			}else{
				obj.rowElements[i].style.display = "";
			}
		}
	}
	
	obj.curpage = n;
	//顯示分頁訊息
	if (obj.pageinfo){
		obj.pageinfo.innerText = getPageNavInfo(obj);
	}
	//return obj;
}

/**回傳show在頁面上的目前頁*/
function getShowCurPage(obj) {
	return parseInt(obj.curpage, 10) + 1;
}

/**回傳show在頁面上的總頁數*/
function getShowTotalPage(obj) {
	return obj.totalpages;
}

/**取得所有資料筆數*/
function getShowTotalRecord(obj) {
	return obj.totalrecord;
}

/**
 * 回傳show在頁面上的分頁訊息預設值
 * ex "第"+ showcurpage+ "/" +showtotalpage+ "頁  共"+totalrecord+"件";
 */
function getPageNavInfo(obj) {
	var msg = "第" + getShowCurPage(obj) +"/" + getShowTotalPage(obj) + "頁,  共" + getShowTotalRecord(obj) + "件";
    return msg;
}