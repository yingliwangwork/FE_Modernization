var e;
var totalrecord = 0;
var totalpages = 0;
var pagesize = 10;
var curpage = 0;
var sizePerRecord = 1;

var pageinfo;

function page(size,recordSize,rowid,infoid){
    e = document.all(rowid);
    if (!e) {
    	try {
    		e = $$('tr.paging');
    	} catch (e1) {}
    	if (!e) {
			return;
		}
	}
    if (e.length){
		totalrecord = e.length;
	}else{
		totalrecord = 1;
	}
    pagesize = size;
    sizePerRecord = recordSize;
    totalpages = parseInt(totalrecord/sizePerRecord/pagesize);
    if (((totalrecord/sizePerRecord)%pagesize) != 0){
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

var tempTD = document.createElement("TD");
function gotoPage(n){

	if ( ( n < 0) || (n >= totalpages) ){
		return;
	}

	var bgn = curpage * pagesize * sizePerRecord;
	if (bgn<0){
		bgn = 0;
	}
	var end = pagesize * sizePerRecord * ( 1+curpage );
	if (end>totalrecord){
		end = totalrecord;
	}
    for(var i = bgn; i < end; i+=sizePerRecord ){
        if (e[i]){
            for (var j = 0; j < sizePerRecord; j++) {
                e[i + j].style.display = 'none';
            }
        }else{

			e.style.display = 'none';
            break;
		}
	}

	var bgns = n * pagesize * sizePerRecord;
	if (bgns<0){
		bgns = 0;
	}
	var ends = pagesize * sizePerRecord * ( 1+n );
	if (ends>totalrecord){
		ends = totalrecord;
	}
    for(var k = bgns; k < ends; k+=sizePerRecord ){
        if (e[k]){

            for (var m = 0; m < sizePerRecord; m++) {
                e[k + m].style.display = '';
            }
        }else{

			e.style.display = '';
			break;
		}
	}
	curpage = n;

    if (pageinfo){
        pageinfo.innerHTML = getPageNavInfo();
	}
}


function getShowCurPage(){
	return parseInt(curpage)+1;
}

function getShowTotalPage(){
	return totalpages;
}

function getShowTotalRecord(){
	return totalrecord / sizePerRecord;
}

function getPageNavInfo(){
	var msg = '第 ' + getShowCurPage() +"/" + getShowTotalPage() + "頁,  共" + getShowTotalRecord() + "件";
    return msg;
}

//table搜尋功能:--------------------------------------------------------------------------------------------
var tableSearch_flag=0;//remember current place 
var tableSearch_preKeyWord="";//pre keyWord

//onlys shows the relevant rows as determined by the search string
function tableSearch_runSearch() {    
    
    validator.errHandler.clear();
   	validator.clear();
   	validator.errHandler = new AlertHandler();
	validator.define('textBoxSearch', '搜尋', '請輸入','string');
	
	if(!validator.validate()){
		validator.errHandler.display();
		return false;
	}
	resetValidator();
    
    var Term; //curr keyWord
	var Rows = document.getElementById('data').getElementsByTagName('tr'); //table's row
	var RowsLength = Rows.length; //table's row.length
	var RowsText = [];//table's row.value
    
    //loop through the table and add the data to
    for (var i = 0; i < RowsLength; i++) {
        RowsText[i] = (Rows[i].innerText) ? Rows[i].innerText : Rows[i].textContent;
    }    
    
    //clear Table Color
    for (var i=0, row ; row = Rows[i], rowText = RowsText[i]; i++) {        
    row.style.color = 'black';
	}
   
    var searchFlag = false;        
    //get the search term
    Term = document.getElementById('textBoxSearch').value;
    
    //loop through the rows and hide rows that do not match the search query
    var i = 0;
    
    if(tableSearch_preKeyWord == Term){ 
		i=tableSearch_flag;
    }
    else{
    	tableSearch_preKeyWord = Term
    }
    
    for (var row ; row = Rows[i], rowText = RowsText[i]; i++) {        
           
       if (document.getElementById('checkBox').checked==true){
       	        		
       		var cells = row.cells;	       		
       		for(var j=0; j<cells.length;j++)
       		{   row.style.color = (cells[j].innerText==Term) ? '#0066CC' : 'black';
       			
       			if(cells[j].innerText==Term){
       				searchFlag=true;
       				break;       				 	
       			}       				       			
       		}
       		
       		if(searchFlag==true)
       		{	var nowPage = Math.floor(i/pagesize);
       	   		gotoPage(nowPage);
           		fix();
       			break;
       		}
       }
	   else{    
           row.style.color = ((rowText.indexOf(Term) != -1) && Term != '') ? '#0066CC' : 'black';
         
           if((rowText.indexOf(Term) != -1)||Term === '')
           {	var nowPage = Math.floor(i/pagesize);
       	   		gotoPage(nowPage);
           		fix();
           		searchFlag=true;
           		break;	
           }        
       }
    }
    
    tableSearch_flag=i+1;   
    if(searchFlag == false)
    {	alert("查無符合資料");
    	tableSearch_flag=0;
    }
}

