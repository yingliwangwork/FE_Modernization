
var e;
var theform = document.forms[0];

var totalrecord = 0;
var totalpages = 0;
var pagesize = 10;
var curpage = 0;

var pageinfo;

function init(f,size,rowid,infoid){
	if (f!=null){
		theform = f;
	}
//ie11 不支援  e = theform.all( rowid );

	//修改 參照 pageController.js
	// 取得 form 內的要作用的列
	var getDataNodes = function( tagName ) { 
		
		var nodes = theform.getElementsByTagName(tagName);
		
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
	
	e = getDataNodes('TR');
	
	if(!e) {
		// form 內符合 rowid 的元素不是 tr 時，就須改取 td
		e = getDataNodes('TD');
	}
	
	
	
	if (e ==null){
		return;
	}
	
	if (e.length){
		totalrecord = e.length;
	}else{
		totalrecord = 1;//只有一筆資料
	}
	
	pagesize = size;
	
	totalpages = parseInt(totalrecord/pagesize);
	if ((totalrecord%pagesize) != 0){
		totalpages++;
	}
	
	pageinfo = document.getElementById(infoid);
    
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
	if (bgn<0){
		bgn = 0;
	}
	var end = pagesize * ( 1+curpage );
	if (end>totalrecord){
		end = totalrecord;
	}
	for( i = bgn; i < end; i++ ){
		if (e[i]){
			e[i].style.display = 'none';
		}else{
			//當資料只有一筆時e的型態不是陣列所以e[0]會是沒有定義
			e.style.display = 'none';
			break;
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
	for( i = bgns; i < ends; i++ ){
		if (e[i]){
			e[i].style.display = '';
		}else{
			//當資料只有一筆時e的型態不是陣列所以e[0]會是沒有定義
			e.style.display = '';
			break;
		}
	}
	
	curpage = n;
	//顯示分頁訊息
	if (pageinfo){
	pageinfo.innerText = getPageNavInfo();
	}
}

/**回傳show在頁面上的目前頁*/
function getShowCurPage(){
	return parseInt(curpage)+1;
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
 * ex "第"+ showcurpage+"頁/共"+showtotalpage+"頁  共"+totalrecord+"件";
 */
function getPageNavInfo(){
	var msg = "第"+ getShowCurPage() + "頁/共" + getShowTotalPage() + "頁  共" + getShowTotalRecord() + "件";
    return msg;
}

