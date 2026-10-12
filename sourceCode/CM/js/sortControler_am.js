function setDataType(cValue, type) {
    // THIS FUNCTION CONVERTS DATES AND NUMBERS FOR PROPER ARRAY
    // SORTING WHEN IN THE SORT FUNCTION
    if (type == '0') {
            // THE VALUE IS A STRING, MAKE ALL CHARACTERS IN
            // STRING UPPER CASE TO ASSURE PROPER A-Z SORT
        cValue = cValue.toUpperCase();
        return cValue;
    }

    if (type == '1') {
        return cValue;
    }

    if (type == '2') {
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
        return myDate;
    }

    if (type == "3") {
        return cValue.replace(/\,/g, "");
    }

    return eval(type + "('" + cValue + "')");
}

//**********************
//對table的某些特定列做排序
//col -- 預排序第幾欄
//tableToSort -- 排序表格Id
//rowToSort   -- 排序 row ID
//dataType    -- 排序內容的型態(0: STRING; 1: NUM; 2: DATE; 3: CURRENCY)
//sortType    -- 排序方法(0:升冪;其它:降冪)
//reSortIndex -- 是否重新整理index(第0欄)
//oddBgColor  -- 偶數筆背景顏色
//evenBgColor -- 單數筆背景顏色
//colBgColor  -- 被排序欄位背景顏色
//compareFun -- 比對的方法,就用該數值來排序
//!! note :
//   a.排序資料必需連續在一塊區間;
//   b.資料單純(沒有分割或分行);
//   c.若index要重新整理, index不可加連結;
//   d.主頁面不可用sortCol變數
//***********************
var sortCol;

function sortTable(col, tableToSort, rowToSort, dataType, sortType, reSortIndex, oddBgColor, evenBgColor, colBgColor, lastSortCol,compareFun) {
    //與前次排序欄位一樣不做排序
    if ( lastSortCol  ) {
    	sortCol = lastSortCol;
    }
    if (col == sortCol) {
    	return;
    }

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

      		if (compareFun == null) {
      			colArray[x++] = setDataType(tableToSort.rows[i].cells[col].innerText, dataType);
      		} else {

      			alert( compareFun );

      			var value = compareFun(tableToSort.rows[i].cells[col]);

      			alert(value);

    			colArray[x++] = setDataType(value, dataType);
      		}

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
    if (dataType == 1 || dataType == 2 || dataType == 3) {
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

        if (colBgColor) {
            newRow.cells[col].style.backgroundColor = colBgColor;
        }
        if (sortCol && sortCol != -1) {
            newRow.cells[sortCol].style.backgroundColor = '';
  		}
        if (i % 2 == 0) {
            if (oddBgColor) {
                newRow.style.backgroundColor = oddBgColor;
            }
        } else {
            if (evenBgColor) {
                newRow.style.backgroundColor = evenBgColor;
            }
  		}

  }
  sortCol = col;
  //刪除舊的row
  for (i=0; i<x; i++)
    {
      tableToSort.deleteRow(firstRow+x);
    }
 }

function compareNum(aValue1, aValue2) {
    var f1 = parseFloat(aValue1.replace(/,/g, ''));
    var f2 = parseFloat(aValue2.replace(/,/g, ''));

    //都為數字
    if (!isNaN(f1) && isNaN(f2)) return 1;

    if (isNaN(f1) && !isNaN(f2)) return -1;

    if (isNaN(f1) && isNaN(f2)) return 0;

    if (f1 == f2) {
        return 0;
    }

    if (f1 > f2) {
        return 1;
    }

    if (f1 < f2) {
        return -1;
    }
}