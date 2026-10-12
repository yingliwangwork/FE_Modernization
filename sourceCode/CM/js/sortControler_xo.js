function setDataType(cValue,type)
  {
    // THIS FUNCTION CONVERTS DATES AND NUMBERS FOR PROPER ARRAY
    // SORTING WHEN IN THE SORT FUNCTION
    
        if (type == '0' )
          {
            // THE VALUE IS A STRING, MAKE ALL CHARACTERS IN
            // STRING UPPER CASE TO ASSURE PROPER A-Z SORT
            cValue = cValue.toUpperCase();
            return cValue;
          }
        if ( type == '1')
          {
             return cValue.replace(",","").replace(",","").replace(",","").replace(",","");
          }
        
  		if ( type == '2') {
  		var isDate = new Date(cValue);
        // VALUE TO SORT IS A DATE, REMOVE ALL OF THE PUNCTUATION AND
        // AND RETURN THE STRING NUMBER
        //BUG - STRING AND NOT NUMERICAL SORT .....
        // ( 1 - 10 - 11 - 2 - 3 - 4 - 41 - 5  etc.)
        var myDate = new String();
        myDate = ((isDate.getFullYear()<10?"000":(isDate.getFullYear()<100?"00":"")))+isDate.getFullYear() + "" ;
        myDate = myDate + (isDate.getMonth()<10?"0":"")+isDate.getMonth();
        myDate = myDate + (isDate.getDate()<10?"0":"")+isDate.getDate();
        myDate = myDate + (isDate.getHours()<10?"0":"")+isDate.getHours();
        myDate = myDate + (isDate.getMinutes()<10?"0":"")+isDate.getMinutes(); 
        myDate = myDate + (isDate.getSeconds()<10?"0":"")+isDate.getSeconds();
        //myDate = String.fromCharCode(48 + myDate.length) + myDate;
        return myDate ;
      }
      return eval(type+"('"+cValue+"')");
      
  }
  
  function setDataType_1(cValue)
  {
    // THIS FUNCTION CONVERTS DATES AND NUMBERS FOR PROPER ARRAY
    // SORTING WHEN IN THE SORT FUNCTION
    var isDate = new Date(cValue);
    if (isDate == "NaN")
      {
        if (isNaN(cValue))
          {
            // THE VALUE IS A STRING, MAKE ALL CHARACTERS IN
            // STRING UPPER CASE TO ASSURE PROPER A-Z SORT
            cValue = cValue.toUpperCase();
            return cValue;
          }
        else
          {
            // VALUE IS A NUMBER, TO PREVENT STRING SORTING OF A NUMBER
            // ADD AN ADDITIONAL DIGIT THAT IS THE + TO THE LENGTH OF
            // THE NUMBER WHEN IT IS A STRING
            var myNum;
            myNum = String.fromCharCode(48 + cValue.length) + cValue;
            return myNum;
          }
        }
  else
      {
        // VALUE TO SORT IS A DATE, REMOVE ALL OF THE PUNCTUATION AND
        // AND RETURN THE STRING NUMBER
        //BUG - STRING AND NOT NUMERICAL SORT .....
        // ( 1 - 10 - 11 - 2 - 3 - 4 - 41 - 5  etc.)
        var myDate = new String();
        myDate = isDate.getFullYear() + " " ;
        myDate = myDate + isDate.getMonth() + " ";
        myDate = myDate + isDate.getDate(); + " ";
        myDate = myDate + isDate.getHours(); + " ";
        myDate = myDate + isDate.getMinutes(); + " ";
        myDate = myDate + isDate.getSeconds();
        //myDate = String.fromCharCode(48 + myDate.length) + myDate;
        return myDate ;
      }
  }
  
 
//**********************
//對table的某些特定列做排序
//col -- 預排序第幾欄
//tableToSort -- 排序表格Id
//rowToSort   -- 排序 row ID
//dataType    -- 排序內容的型態( 0: String ; 1: NUM ; 2: DATE)
//sortType    -- 排序方法(0:升冪;其它:降冪)
//reSortIndex -- 是否重新整理index(第0欄)
//oddBgColor  -- 偶數筆背景顏色 
//evenBgColor -- 單數筆背景顏色
//colBgColor  -- 被排序欄位背景顏色
//!! note : 
//   a.排序資料必需連續在一塊區間;
//   b.資料單純(沒有分割或分行);
//   c.若index要重新整理, index不可加連結;
//   d.主頁面不可用sortCol變數
//***********************
var sortCol  ;

function sortTable(col, tableToSort, rowToSort,dataType, sortType, reSortIndex,oddBgColor,evenBgColor,colBgColor)
  {

    
    var colArray = new Array();
    var oldIndex = new Array();
    var indexArray = new Array();
    var bArray = new Array();
    var hasFirst = false;
    var firstRow ; //由第幾列開始做排序
    var x=0;
    //找尋要排序的列, 並做資料轉換
    for (i=0; i < tableToSort.rows.length; i++)
      {
      if ( tableToSort.rows[i].id == rowToSort) {   
    	  	colArray[x++] = setDataType(tableToSort.rows[i].cells[col].innerHTML,dataType);
    	  	
        	if ( !hasFirst ) {
        		firstRow = i;
        		hasFirst = true;
        	}
        }    
      }
    //只有一列不必排序
    if ( colArray.length < 2 ) {
    	return;
    } 
    // ** COPY ARRAY FOR COMPARISON AFTER SORT
    for (i=0; i < colArray.length; i++)
      {
        bArray[i] = colArray[i];
      }
    // ** SORT THE COLUMN ITEMS
    if ( dataType == 1 || dataType == 2) {
        //數字的compare
        colArray.sort(compareNum);
    } else {
        colArray.sort();
    }
    //降冪的話就reverse
    if ( sortType != 0 ) {
    	colArray.reverse();
    }
    var bSort = 0;
    for (i=0; i < colArray.length; i++)
      { // LOOP THROUGH THE NEW SORTED ARRAY
      	indexArray[i] = (i+firstRow);
        for(j=0; j < bArray.length; j++)
          { // LOOP THROUGH THE OLD ARRAY
            if (colArray[i] == bArray[j])
              {  // WHEN THE ITEM IN THE OLD AND NEW MATCH, PLACE THE
                // CURRENT ROW NUMBER IN THE PROPER POSITION IN THE
                // NEW ORDER ARRAY SO ROWS CAN BE MOVED ....
                // MAKE SURE CURRENT ROW NUMBER IS NOT ALREADY IN THE
                // NEW ORDER ARRAY
                for (c=0; c<i; c++)
                  {
                    if ( oldIndex[c] == (j+firstRow) )
                    {
                      bSort = 1;
                    }
                      }
                      if (bSort == 0)
                        {
                          oldIndex[i] = (j+firstRow);
                          break;
                        }
                          bSort = 0;
                        }
          }
    }
  // ** SORTING COMPLETE, ADD NEW ROWS TO FIRST SORTED ROW OF TABLE ....
  theParent = tableToSort.rows[firstRow].parentNode;
  if ( !colBgColor) {
  	colBgColor = '';
  } 
   if ( !evenBgColor) {
  	evenBgColor = '';
  } 
   if ( !oddBgColor) {
  	oddBgColor = '';
  } 
  for (i=0; i<oldIndex.length; i++)
    {
      theParent.insertBefore(tableToSort.rows[oldIndex[i]+i].cloneNode(true),tableToSort.rows[firstRow+i]);
		
		newRow = tableToSort.rows[firstRow+i];
  		// 重新編排index
  		if ( reSortIndex ) {
  			newRow.cells[0].innerHTML = i+1;
  		}   
  		
  		newRow.cells[col].style.backgroundColor = colBgColor;
  		if ( sortCol && sortCol != -1) {
  			newRow.cells[sortCol].style.backgroundColor = '';
  		}
  		if ( i%2 == 0 ) {
  		  newRow.style.backgroundColor = oddBgColor;
  		} else {
  		  newRow.style.backgroundColor = evenBgColor;
  		}
  		
  }
  sortCol = col;
  //刪除舊的row
  for (i=0; i<x; i++)
    {
      tableToSort.deleteRow(firstRow+x);
    }
 }
 function compareNum(aValue1, aValue2)
   {
      	var f1 = parseFloat(aValue1);
      	var f2 = parseFloat(aValue2);
      	//都為數字
      	if (!isNaN(f1) && isNaN(f2)) return 1;
      	
      	if (isNaN(f1) && !isNaN(f1)) return -1;
      	
      	if ( isNaN(f1)  && isNaN(f1)  ) return 0 ;
      	
      	if(f1 == f2)
        {
          return 0;
        }
        if ( f1 > f2) {
           return 1;
        }
        if ( f1 < f2) {
           return -1;
        }
       
   }
   
   function sortTable_1(col,row,sub_rows, tableToSort,sortType)
  {
    var totalRows = tableToSort.rows.length;
    var colIndex = new Array();    
    var colArray = new Array();
    var resIndex = new Array();
    var bArray = new Array();
    var newRow;
    var newCell;
    var i;
    var c;
    var j;
    var x=0;
    var k=0;
    if (totalRows==row) return;
    
    // ** POPULATE THE ARRAY colArray WITH CONTENTS OF THE COLUMN SELECTED
    var group_cnt = 0;
    for (i=row; i < tableToSort.rows.length; i++){
    	if (sub_rows>0){
			if (group_cnt==0){
		        colIndex[x] = i +"-"+ setDataType_1(tableToSort.rows[i].cells[col].innerText);
		        colArray[x] = setDataType_1(tableToSort.rows[i].cells[col].innerText);
		        x = x + 1 ;
		    }
		    group_cnt = group_cnt +1;
		    if (group_cnt==4) group_cnt = 0;
		}else{
			colIndex[x] = i +"-"+ setDataType_1(tableToSort.rows[i].cells[col].innerText);
		    colArray[x] = setDataType_1(tableToSort.rows[i].cells[col].innerText);
		    x = x + 1 ;
		}
    }

    // ** SORT THE COLUMN ITEMS
    if (sortType=="1") colArray.sort(asc);
    if (sortType=="-1") colArray.sort(desc);

    for (i=0; i < colArray.length; i++){ // LOOP THROUGH THE NEW SORTED ARRAY
      for(j=0; j < colIndex.length; j++){ // LOOP THROUGH THE OLD ARRAY
			var valArray = colIndex[j].split("-");
			if (valArray[1] == colArray[i] && isNotRepli(bArray,valArray[0])){
				resIndex[k] = valArray[0];
				bArray[k] = valArray[0];
				k = k +1 ;
				break;
			}
       }
  	}

  	for(i=0; i < resIndex.length; i++)
  	{
        newRow = tableToSort.insertRow();
        var color_type="";
     	for (c=0; c<tableToSort.cols; c++)
        {
	          newCell = newRow.insertCell();
	          newCell.align="center";
	          newCell.innerHTML = tableToSort.rows[parseInt(resIndex[i])].cells[c].innerHTML;
        }
       	if ( i%2 == 0 ) {
  		  newRow.className="tbBlue3";
  		  color_type = "odd";
  		} else {
  		  newRow.className="tbYellow2";
  		  color_type = "even";
  		}

		if (sub_rows>0){
	  		for (q=1; q<4; q++){
		  		newRow = tableToSort.insertRow();
		  		var now_row = parseInt(resIndex[i])+q;
		  		for (var m=0;m<tableToSort.rows[now_row].cells.length;m++) {
			  		newCell = newRow.insertCell();
			  		if (m==0){
			  			newCell.colSpan= 2;
			  		}else{
			  			newCell.colSpan= 10;
			  		}
					newCell.innerHTML = tableToSort.rows[now_row].cells[m].innerHTML;
				}
				if ( color_type == "odd" ) {
		  		   	newRow.className="tbBlue3";
		  		} else if ( color_type == "even" ) {
					newRow.className="tbYellow2";
		  		}
			}
		}
  	}

	  //DELETE THE OLD ROWS FROM THE BOTTOM OF THE TABLE ....
	  for (i=row; i<totalRows; i++){
		tableToSort.deleteRow(row);
	  }

  }
  
  function isNotRepli(bArray,value){
  	 for(i=0; i < bArray.length; i++){ 
  	 	if (bArray[i] == value){
  	 		return false;
  	 	}
  	 }
  	 return true;
  }
  
  function desc(x,y){
  	if (x>y){
  		return -1;
  	}
  	if (x<y){
  		return 1;
  	}
  	 if (x==y){
  		return 0;
  	}
  }
  
   function asc(x,y){
  	if (x>y){
  		return 1;
  	}
  	if (x<y){
  		return -1;
  	}
  	if (x==y){
  		return 0;
  	}
  }
 
