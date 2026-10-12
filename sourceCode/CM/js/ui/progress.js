    var post = 0;
    function progress( doing )
    {
    	/*
        if( doing ) {
            if( post++ == 0 ) { showProgress(); }
        }
        else {
            if( --post == 0 ) { stopProgress(); }
        }
        */
    }

	function showProgress() {
		/*
        Ext.MessageBox.show({
           title: '請稍候',
           msg: '遠端作業資料接收...',
           progressText: '處理中...',
           width:250,
           progress:true,
           closable:false
       	});
       	*/
       	//Ext.dd.DragDropMgr.lock();
       	//Ext.MessageBox.updateProgress(1);
	}

	function stopProgress() {
       	//Ext.dd.DragDropMgr.unlock();
		//Ext.MessageBox.hide();
	}