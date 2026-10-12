
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
var rowElements;
var totalrecord = 0;
var totalpages = 0;
var pagesize = 10;
var curpage = 0;
var fetchRows = null;
var pageinfo;

function page(form,size,rowid,infoid,fetchTR){

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
	
	rowElements = getDataNodes('TR');
	
	if(!rowElements) {
		// form 內符合 rowid 的元素不是 tr 時，就須改取 td
		rowElements = getDataNodes('TD');
	}
	
	// rowElements 陣列有實體且長度大於 0，才表示有資料
	if (rowElements && rowElements.length > 0){
		
		// 若有斷行，資料筆數 = rowElements.length / fetchRows( 每筆資料的折行數 )
		if(fetchTR && fetchTR > 1){
			fetchRows = fetchTR;
			totalrecord = rowElements.length / fetchRows;			
		}else{
			totalrecord = rowElements.length;		
		}
	}
	
	// 計算總頁數
	pagesize = size;
	totalpages = parseInt(totalrecord/pagesize, 10);
	
	if ((totalrecord % pagesize) != 0){
		totalpages++;
	}
	
	// 取得 bottom 分頁資訊區塊
	pageinfo = document.getElementById(infoid);
    
	// 行資料顯示/隱藏 切換
	gotoPage(0);
}


function gotoFirstPage(){
	gotoPage(0);
}

function gotoLastPage(){
	gotoPage(parseInt(totalpages-1));
}

function gotoNextPage(){
	gotoPage(parseInt(curpage)+1);
}

function gotoPrevPage(){
	gotoPage(parseInt(curpage)-1);
}

function gotoPage(n){
	
	/**檢查傳入頁數是否正確*/
	if ( ( n < 0) || (n >= totalpages) ){
		return;
	}
	
	/**隱藏前一頁資料*/
	var bgn = curpage * pagesize;
	if (bgn < 0){
		bgn = 0;
	}
	
	var end = pagesize * ( 1 + curpage );
	
	if (end > totalrecord){
		end = totalrecord;
	}
	
	// 有資料時才作用
	if(rowElements && rowElements.length > 0){
		
		// 隱藏前一頁的行資料
		for(var i = bgn; i < end; i ++) {
			
			if(fetchRows){
				var j = i * fetchRows;
				for(var k = 0; k < fetchRows; k++){
					rowElements[j + k].style.display = "none";
				}
			}else{
				rowElements[i].style.display = "none";
			}
		}
	}
		
	/**顯示此頁資料*/
	var bgns = n * pagesize;
	if (bgns<0){
		bgns = 0;
	}
	var ends = pagesize * ( 1+n );
	if (ends>totalrecord){
		ends = totalrecord;
	}

	// 有資料時才作用
	if(rowElements && rowElements.length > 0){
	
		// 針對要顯示的資料清除 style.display 的內容
		// 在不同瀏覽器中都可以顯示資料
		for(var i = bgns; i < ends; i++ ){
				
			if(fetchRows){
				var j = i * fetchRows;
				
				for(var k = 0; k < fetchRows; k++ ){
					rowElements[j + k].style.display = "";
				}
			}else{
				rowElements[i].style.display = "";
			}
		}
	}
		
	curpage = n;
	//顯示分頁訊息
	if (pageinfo){
		pageinfo.innerText = getPageNavInfo();
	}
}

/**回傳目前頁之 index*/
function getCurPage(){
	return parseInt(curpage);
}

/**回傳show在頁面上的目前頁*/
function getShowCurPage(){
	return getCurPage()+1;
}

/**回傳show在頁面上的總頁數*/
function getShowTotalPage(){
	return totalpages;
}

/**取得所有資料筆數*/
function getShowTotalRecord(){
	return totalrecord;
}

/**
 * 回傳show在頁面上的分頁訊息預設值
 * ex "第"+ showcurpage+ "/" +showtotalpage+ "頁  共"+totalrecord+"件";
 */
function getPageNavInfo(){
	var msg = "第" + getShowCurPage() +"/" + getShowTotalPage() + "頁,  共" + getShowTotalRecord() + "件";
    return msg;
}