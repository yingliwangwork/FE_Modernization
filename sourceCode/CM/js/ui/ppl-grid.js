	var store;
	var count;
	var pplGridPanel;
	var toolbar;

    function reloadGridData(data) {
    	store.loadData(data);
    }

    function clearGridData() {
    	store.removeAll();
    }

    function getPPLCount() {
    	return store.getCount();
    }

    function addToGrid(data) {
    	var records = [];
    	var PPL_NO;
    	var count_005 = 0;
    	var allData = store.data.items;
    	if(allData){   
    		for(i = 0; i< allData.length; i++) {
    			if('005' == allData[i].data.PPL_SUB_CLSF_CODE || '提解' == allData[i].data.PPL_SUB_CLSF){
    				PPL_NO = allData[i].data.PPL_NO;
    				count_005++;
        		}	
        	}
    	}	
    	for(i = 0; i< data.length; i++) {
    		if (store.getById(data[i].PPL_NO) == null) {
    			
    			if('005' == data[i].PPL_SUB_CLSF_CODE){
    				PPL_NO = data[i].PPL_NO;
    				count_005++;
        		}
    			
    			records.push(new Ext.data.Record(data[i], data[i].PPL_NO));
    		}
    	}
    	
    	if(count_005 > 1){
    		if($('PRE_TRD_NO')){
    			alert('提解件只能有一件');
    		}else{
    			store.add(records);
    		}	
    	}else{
    		store.add(records);
    		if($('PRE_TRD_NO')){
	    		if(count_005 == 1){
	    			//$('PRE_TRD_NO').show();
	    			
	    			ui.ajaxPost('pplNoQuery', { PPL_NO:PPL_NO,MCHD_CD:$F('MCHD_CD'), SOURCE:$F('SOURCE') }, 
						  	function(json) {			
	    								
										var PRE_TRD_NOList = json.PRE_TRD_NOList;
										$('PRE_TRD_NO').update().insert(new Element('option', {value:''}).update(''));
	    								for(var i=0;i<PRE_TRD_NOList.length;i++){
	    									
	    									$('PRE_TRD_NO').insert(new Element('option', {value:PRE_TRD_NOList[i].TRD_NO}).update(PRE_TRD_NOList[i].TRD_NO));
										}
										
						  	}
						);
	    			
	    			
	    		}else{
	    			$('PRE_TRD_NO').update().insert(new Element('option', {value:''}).update(''));
	    			//$('PRE_TRD_NO').hide();
	    		}
    		}
    	}
    }
    function getEncodedArray() {
		var isRBWeb = window.location.toString().match(/\/RBWeb*/)!=null;

    	var records = store.getRange();
		var ppls = [];
    	for(i = 0; i< records.length; i++) {
    		if(isRBWeb){
    			ppls.push({PPL_NO:records[i].data.PPL_NO , BUY_SALE:records[i].data.BUY_SALE });
    		}else{
    			ppls.push({PPL_NO:records[i].data.PPL_NO, TRD_KND:records[i].data.TRD_KND});
    		}
    	}
    	return Ext.encode(ppls);
    }

    function activeTBar() {
    	toolbar.addButton({
        	tooltip: '可點選多筆刪除',
        	iconCls: 'x-grid-del_icon',
        	handler: deleteConfirm
        });
        toolbar.addSeparator();
        toolbar.addButton({
        	text: '簽呈索引',
        	tooltip: '新增投資建議編號',
        	iconCls: 'x-grid-index_icon',
        	handler: openPPL
        });
    }

    function deleteConfirm() {
    	count = pplGridPanel.selModel.getCount();
    	if(count > 0) {
      		Ext.MessageBox.confirm('刪除確認','刪除所選建議書編號?', deletePPL);
    	} else {
      		Ext.MessageBox.alert('無法刪除','尚未選擇建議書編號');
    	}
    }

    function deletePPL(btn) {
    	var selections = pplGridPanel.selModel.getSelections();
    	
    	var ppl_no = 0; 
    	for(i = 0; i< count; i++) {
    		store.remove(store.getById(selections[i].data.PPL_NO));
    		
    		
    		if('005' == selections[i].data.PPL_SUB_CLSF_CODE || '提解' == selections[i].data.PPL_SUB_CLSF ){
    			ppl_no++;
    		}
    	}
    	if($('PRE_TRD_NO')){
    		if(ppl_no > 0){
		    	$('PRE_TRD_NO').update().insert(new Element('option', {value:''}).update(''));
				//$('PRE_TRD_NO').hide();
	    	}
    	}
    }

    function openPPL() {
    	UI.openIndex();
    }

Ext.onReady(function(){

    if (!$('PPL_GRID')) return;

	var isRBWeb = window.location.toString().match(/\/RBWeb*/)!=null;
	
	var inputFields;
	var inputColumns;
	var inputHeight;
	if(isRBWeb){
		inputFields = ['PPL_ID', 'PPL_NO', 'PPL_SUB_CLSF','PPL_SUB_CLSF_CODE','BUY_SALE'];
		inputColumns = [
							{header: "簽呈編號", width: 180, sortable: true, dataIndex: 'PPL_ID'},
							{header: "建議書編號", width: 100, sortable: true, dataIndex: 'PPL_NO'}, 
							{header: "建議書次分類", width: 100, sortable: true, dataIndex: 'PPL_SUB_CLSF'}
						];
		inputHeight = 69;
	}else{
		inputFields = ['PPL_NO', 'TRD_KND'];
		inputColumns = [
							{header: "建議書序號", width: 160, sortable: true, dataIndex: 'PPL_NO'},
							{header: "交易種類", width: 75, sortable: true, dataIndex: 'TRD_KND'}
						];
		inputHeight = 123;
	}

	// create the data store
	store = new Ext.data.JsonStore({
    	root: 'DTRBB050',
    	id: 'PPL_NO',
    	fields: inputFields,
        data: {"DTRBB050":[]}
	});

    // create the Grid
    pplGridPanel = new Ext.grid.GridPanel({
    	renderTo: 'PPL_GRID',
        store: store,
        columns: inputColumns,
    	viewConfig: {
        	forceFit: true
    	},
        stripeRows: true,
        autoExpandColumn: 'PPL_NO',
        height:inputHeight,
        width:380,
        tbar:new Ext.Toolbar({id:'ppltbar'})	
    });
	
	toolbar = pplGridPanel.getTopToolbar();
	
	Ext.QuickTips.init();
    
});