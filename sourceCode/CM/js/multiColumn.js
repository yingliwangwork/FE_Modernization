/**
*自訂table columns 版本,將會在target form中放入hidden欄位組成 row data array
*@param sourceForm 資料來源form
*@param targetForm 資料目的form
*@param tableName 新增hidden欄位的name , 後端用此name來接這function所組的data array
*@param elementName 要組成table column的 element name, 如果沒有指定,則抓取source form裡所有element中name > 1的
*/
function doMultiColumn(sourceForm,targetForm,tableName){

	/*存column name的array*/
	var elementNamesArray = new Array();

	if(arguments.length > 3){
		/*因為前三個參數是formname,tablename, 所以element name 長度是arguments-3*/
		for(var i = 3 ; i < arguments.length ; i++){
			elementNamesArray.push(arguments[i]);
		}

	/*如果沒有指定column name,則抓這個form裡所有 length > 1的element*/
	}else{
		for(var i = 0 ; i < sourceForm.elements.length ; i++){
			if(!sourceForm.elements[i].length){
				//alert(sourceForm.elements[i].name);
				elementNamesArray.push(sourceForm.elements[i]);
			}
		}
	}



	/*存row datamap的array*/
	var rowMapArray = new Array();

	/*loop column names and get its value to row map*/
	/*跑兩次loop, 第一層loop跑column,第二層跑此column的data(即組二維陣列,但是每一個row的data存成map)*/
	for(var i = 0 ; i < elementNamesArray.length ; i++){
		var elementArray = sourceForm.ownerDocument.getElementsByName(elementNamesArray[i]);

		for(var j = 0 ; j < elementArray.length ; j++){
			if(!rowMapArray[j]){
				rowMapArray[j] = new JSHashMap();
			}
			rowMapArray[j].put(elementNamesArray[i] ,base64encode(elementArray[j].value));
		}
	}

	/*印出測試用*/
	// for(var i = 0 ; i < rowMapArray.length ; i++){
	// 	alert(rowMapArray[i]);
	// }

	/*寫入document中送出*/
	for(var i = 0; i< rowMapArray.length; i++){
		var doc = targetForm.ownerDocument;
		var e = doc.createElement("input");
		e.type = "hidden";
		e.name = tableName;
		e.value = rowMapArray[i].toString();
		targetForm.insertBefore(e, targetForm.firstChild);
		//alert(myEncode(rowMapArray[i].toString()));
		//f.a.value = myEncode(rowMapArray[i].toString());
	}

	targetForm.submit();
}

/**
*自訂table columns 版本,將會在target form中放入hidden欄位組成 row data array
*和第一個method不同的是, 將會依據checkbox 被checked的row才 submit出去
*@param sourceForm 資料來源form
*@param targetForm 資料目的form
*@param tableName 新增hidden欄位的name , 後端用此name來接這function所組的data array
*@param elementName 要組成table column的 element name, 如果沒有指定,則抓取source form裡所有element中name > 1的
*/
function doCheckBoxMultiColumn(sourceForm,targetForm,tableName,checkboxName){

	/*存column name的array*/
	var elementNamesArray = new Array();

	if(arguments.length > 4){
		/*因為前三個參數是formname,tablename, 所以element name 長度是arguments-3*/
		for(var i = 3 ; i < arguments.length ; i++){
			elementNamesArray.push(arguments[i]);
		}

	/*如果沒有指定column name,則抓這個form裡所有 length > 1的element*/
	}else{
		for(var i = 0 ; i < sourceForm.elements.length ; i++){
			if(!sourceForm.elements[i].length){
				//alert(sourceForm.elements[i].name);
				elementNamesArray.push(sourceForm.elements[i]);
			}
		}
	}



	/*存row datamap的array*/
	var rowMapArray = new Array();

	/*loop column names and get its value to row map*/
	/*跑兩次loop, 第一層loop跑column,第二層跑此column的data(即組二維陣列,但是每一個row的data存成map)*/
	var checkboxElement = sourceForm.ownerDocument.getElementsByName(checkboxName);
	for(var i = 0 ; i < elementNamesArray.length ; i++){
		var elementArray = sourceForm.ownerDocument.getElementsByName(elementNamesArray[i]);
		for(var j = 0 ; j < elementArray.length ; j++){
			if(checkboxElement[j] && checkboxElement[j].checked){
				if(!rowMapArray[j]){
					rowMapArray[j] = new JSHashMap();
				}
				rowMapArray[j].put(elementNamesArray[i] ,elementArray[j].value );
			}
		}
	}

	/*印出測試用*/
	// for(var i = 0 ; i < rowMapArray.length ; i++){
	// 	if(!rowMapArray){
	// 		alert(rowMapArray[i]);
	// 	}
	// }

	/*寫入document中送出*/
	for(var i = 0; i< rowMapArray.length; i++){
		if(rowMapArray[i]){
			var doc = targetForm.ownerDocument;
			var e = doc.createElement("input");
			e.type = "hidden";
			e.name = tableName;
			e.value = rowMapArray[i].toString();
			targetForm.insertBefore(e, targetForm.firstChild);
			//alert(myEncode(rowMapArray[i].toString()));
			//f.a.value = myEncode(rowMapArray[i].toString());
		}
	}

	targetForm.submit();
}
