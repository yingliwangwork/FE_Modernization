
<!-- Begin
function setDataType(cValue)
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
function sortTable(col,row, tableToSort,sortType,oddBgColor,evenBgColor)
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
    for (i=row; i < tableToSort.rows.length; i++){
        colIndex[x] = i +"-"+ setDataType(tableToSort.rows[i].cells[col].innerHTML);
        colArray[x] = setDataType(tableToSort.rows[i].cells[col].innerHTML);
        x = x +1;
    }
    // ** SORT THE COLUMN ITEMS
    //alert ( colArray );
    if (sortType=="1") colArray.sort(asc);
    if (sortType=="-1") colArray.sort(desc);
    //alert ( colArray );
    
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
      	for (c=0; c<tableToSort.cols; c++)
        {
          newCell = newRow.insertCell();
          newCell.innerHTML = tableToSort.rows[parseInt(resIndex[i])].cells[c].innerHTML;
        }
       	if ( i%2 == 0 ) {
  		  newRow.style.backgroundColor = oddBgColor;
  		} else {
  		  newRow.style.backgroundColor = evenBgColor;
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
  
//  End -->