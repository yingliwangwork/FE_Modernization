	var cbc_store;
	var cbc_count;
	var cbcGridPanel;
	var cbc_toolbar;
	var cbc_statusbar;
	var cbc_amtAmount =0;
	var Ext2 = Object.clone(Ext);
    function cbc_reloadGridData(data) {
    	cbc_store.loadData(data);
		cbc_reflashBBar();
    }

    function cbc_clearGridData() {
    	cbc_store.removeAll();
		cbc_reflashBBar();
    }

    function getCBCCount() {
    	return cbc_store.getCount();
    }

    function cbc_addToGrid(data) {
		var records = [];
    	for(i = 0; i< data.length; i++) {
			if (cbc_store.getById(data[i].CXL_NO) == null) {
				records.push(new Ext2.data.Record(data[i], data[i].CXL_NO));
    		}
    	}
    	cbc_store.add(records);
		cbc_reflashBBar();
    }

    function getAmtAmount() {
    	var records = cbc_store.getRange();
		cbc_amtAmount  = 0
    	for(i = 0; i< records.length; i++) {
			if(records[i].data.CBC_CHK_TP == "01"){
      			cbc_amtAmount  = parseFloat(cbc_amtAmount ) + parseFloat(records[i].data.AMT_NUM);
			} else if(records[i].data.CBC_CHK_TP == "02"){
      			cbc_amtAmount  = parseFloat(cbc_amtAmount ) - parseFloat(records[i].data.AMT_NUM);
			} 
    	}
    	return cbc_amtAmount ;
    }
	function cbc_getEncodedArray() {
    	var records = cbc_store.getRange();
		var cbcs = [];
    	for(i = 0; i< records.length; i++) {
      		cbcs.push({CXL_NO:records[i].data.CXL_NO ,  AMT:records[i].data.AMT , BUY_OR_SALE:records[i].data.CBC_CHK_TP});
    	}
    	return Ext2.encode(cbcs);
    }

    function cbc_activeTBar() {
    	cbc_toolbar.addButton({
        	tooltip: '可點選多筆刪除',
        	iconCls: 'x-grid-del_icon',
        	handler: cbc_deleteConfirm
        });
        cbc_toolbar.addSeparator();
        cbc_toolbar.addButton({
        	text: '央行專案索引',
        	tooltip: '新增央行專案核准函編號',
        	iconCls: 'x-grid-index_icon',
        	handler: openCXL
        });
		cbc_toolbar.addSeparator();
    }
	
	function cbc_activeBBar() {
		cbc_statusbar.addText( '專案合計金額' ); 
       cbc_statusbar.addSeparator();
	   cbc_statusbar.addText( CSRUtil.$fmt(getAmtAmount(), '#,###.##') ); 
   }
	function cbc_reflashBBar() {
		cbc_statusbar.items.each(function(item, index, length){
			item.destroy();
			return true;
   		}, cbc_statusbar);
		cbc_activeBBar();
    }

    function cbc_deleteConfirm() {
    	count = cbcGridPanel.selModel.getCount();
    	if(count > 0) {
      		Ext2.MessageBox.confirm('刪除確認','刪除所選國壽案件編號?', deleteCXL);
    	} else {
      		Ext2.MessageBox.alert('無法刪除','尚未選擇國壽案件編號');
    	}
    }

    function deleteCXL(btn) {
    	var selections = cbcGridPanel.selModel.getSelections();
    	for(i = 0; i< count; i++) {
    		cbc_store.remove(cbc_store.getById(selections[i].data.CXL_NO));
    	}
		cbc_reflashBBar();
    }

    function openCXL() {
    	UI.openCbcIndex();
    }

Ext2.onReady(function(){

    if (!$('CBC_GRID')) return;

    // create the data store
	cbc_store = new Ext2.data.JsonStore({
    	root: 'DTRBB051',
    	id: 'CXL_NO',
    	fields: ['CXL_NO', 'CBC_CHK_NO', 'CBC_CHK_CHNL','AMT','CBC_CHK_TP','AMT_NUM'],
        data: {"DTRBB051":[]}
	});

    // create the Grid
    cbcGridPanel = new Ext2.grid.GridPanel({
    	renderTo: 'CBC_GRID',
        store: cbc_store,
        columns: [
            {header: "國壽案件編號", width: 140, sortable: true, dataIndex: 'CXL_NO'},
            {header: "央行專案核准函編號", width: 180, sortable: true, dataIndex: 'CBC_CHK_NO'},
            {header: "資金管道", width: 100, sortable: true, dataIndex: 'CBC_CHK_CHNL' , renderer: function(_value, _this,_data){ return exchangeCHKCHNLcode(_value); }},
			{header: "執行金額(美元)", width: 120, sortable: true, dataIndex: 'AMT' ,align:'right'}
        ],
    	viewConfig: {
        	forceFit: true
    	},
        stripeRows: true,
        autoExpandColumn: 'CXL_NO',
        height:69,
        width:500,
        tbar:new Ext2.Toolbar({id:'cxltbar'})	,
		bbar:new Ext2.Toolbar({id:'cxlbbar',align:'right'})	
    });
	
	cbc_toolbar = cbcGridPanel.getTopToolbar();
	cbc_statusbar = cbcGridPanel.getBottomToolbar();
	Ext2.QuickTips.init();
    
});


