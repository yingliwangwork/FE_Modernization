(function($){

	var dispatcher = $('#jqm-home').jqmData('mi-dispatcher'),
		sysindex    = $('#jqm-home').jqmData('mi-sysindex'),
		subcode      = $('#jqm-home').jqmData('mi-subcode'),
		index      = $('#jqm-home').jqmData('mi-sbindex'),
		menuTree;
//------------------------------------------------------------		
	$('#jqm-home').bind('pageshow', function(e){
		$('#hback').hide();
		doPageshow();
	});
//------------------------------------------------------------	
	$('#mBoard a').live('tap', function(event){

		var $this   = $(this),
			subMenu = menuTree[$this.attr('index')].sysSublist;		
		$('#hhome').hide();
		$('#hback').show();
		taskList($this.index('#mBoard a'), menuTree[$this.attr('index')].sysCname,subMenu);
		$('#mBoard').hide();
		$('#subBoard').fadeIn(500);
		event.preventDefault(); 
		return false;

	});
//------------------------------------------------------------		
	$('#hback').bind('tap',function(event){

		$(this).hide();
		$('#hhome').show();
		$('#subBoard').hide();
		$('#subBoard ul').html('').listview('refresh', true);
		$('#mBoard').fadeIn(500);
		event.preventDefault(); 
		return false;

	});
//------------------------------------------------------------	
	$('#subBoard a').live('tap', function(event){
		
		var $this   = $(this);
		var responseTimeEndParameters = $.mi.getResponseTimeEndParameters({});
		//return getSysList and getHotNews T4 parameters
		if(responseTimeEndParameters && responseTimeEndParameters.length>0){
			var t4Param = '';
			for(var i=0;i<responseTimeEndParameters.length;i++){
				var responseTimeEndParameter = responseTimeEndParameters[i];					
				t4Param += '&requestTimeEndUUID=' + responseTimeEndParameter['UUID'];
				t4Param += '&requestTimeEndField=' + responseTimeEndParameter['requestTimeField'];
			}
			$this.attr('href', $this.attr('href')+t4Param);
		}
		
	});		
//------------------------------------------------------------			
//  private methods
//------------------------------------------------------------		

	function isSessionTimeout (resp) {

		var errMsg = resp['ErrMsg'] || {},
		    msgDesc = errMsg['msgDesc'] || '';

		if(msgDesc.indexOf('TX00001') != -1) {
			return true;
		} else {
			return false;
		}

	}

	function doPageshow() {
		$.mi.ajax({
			url: dispatcher + '/MISysMenu/getSysList',
			loadingMsg : '功能選單載入中',
			success: function(resp){
				
				if(isSessionTimeout(resp)) {
					alert('使用者未簽入，請先登入');
					return;
				}
				
				step2();
				
				//主選單
				menuTree=resp.sysList;
				sysList(menuTree);
				//HotNews
				doReturn(sysindex,index);

			}
		});

		function step2() {
			$.mi.ajax({
				url: dispatcher + '/MISysMenu/getHotNews',
				loadingMsg : '最新消息載入中',
				success: function(resp){
					step3();
					hotNewsList(resp.HotNews);
				}
			});			
		}
		
		function step3() {
			//2013.10.28新增待補全通知
			$.mi.ajax({
				url: dispatcher + '/MISysMenu/getCompleteNote',
				loadingMsg : '待補全通知載入中',
				success: function(resp){   
					comList(resp.COM_COUNT);//2013.10.25
				}
			});			
		}
				
	}

	function sysList(dataJson) {

		var reString = '<li data-role="list-divider">入口專區</li>';
		
		$.each(dataJson, function(index, elem){
			reString += '<li><a href="" rel="external" id="' + elem.sysname + '" index='+elem.index+'>'
						+ elem.sysCname + '</a></li>';
		});
			
		$('#mBoard ul').html(reString).listview('refresh');
		
	}

	/*
	*HOT NEWS
	*/
	function hotNewsList(dataJson){
		var reString = '<li data-role="list-divider">Hot News</li>',
			$ul      = $('#hotNews ul');
			
		$ul.html(reString);			

		if(dataJson){
			$.each(dataJson, function(index, elem){
				if(elem.URL_LINK != undefined){
					reString += '<li><a href="' + elem.URL_LINK + '" rel="external">' + elem.TITLE + 
					            '<div>' + elem.DESCRIPTION + '</div>' + 
					            '</a></li>';
				}else{
					reString += '<li>'+elem.TITLE + '<div>' + elem.DESCRIPTION + '</div></li>';
				}
						
			});			
			
			$ul.html(reString).listview('refresh');
			$ul.find('li').find('.ui-btn-text').css({'padding-right': '4em'});	
			
		}	
		
	}
	
	/*
	 * 2013.10.25
	 * 待補全通知
	 */
	function comList(COM_COUNT){
		
		console.log('COM_COUNT-------------', COM_COUNT);
		
		if("0" != COM_COUNT && undefined != COM_COUNT){
			var reString = '<li data-role="list-divider">待補全通知</li>',
				$ul      = $('#com_notice ul');
//				reString += '<li>您好，您有'+COM_COUNT+'件新契約不全，請盡速處理( 請點選左側新契約 > 補全作業 )</li>';
				//2013.11.11 件數文字使用超連結導入ATM0_5100
				reString += '<li><a name="comList" href="/../ATWeb/servlet/HttpDispatcher/ATM0_5100/prompt?TxRequest=true&amp;syscode=AT&amp;subcode=ATM0&amp;sysindex=0&amp;index=4" rel="external" class="ui-link-inherit"><font color="red">您好，您有'+COM_COUNT+'件新契約不全，請盡速處理<br>(請直接點選”待補全通知內容”可直接連結至「補全及查詢作業」 <br>或點選 左側新契約>補全作業)。</font> </a></li>';
				
			$ul.html(reString);
	
			$ul.html(reString).listview('refresh');
			$ul.find('li').find('.ui-btn-text').css({'padding-right': '4em'});
		}
		
	}
//------------------------------------------------------------		
	function taskList(sIndex,sysCname,dataJson) {
		var reString='<li data-role="list-divider">'+sysCname+'</li>';
		$.each(dataJson, function(index, elem){
			reString += '<li><a name="subSystem" href="'+elem.href+'&sysindex='+sIndex+'&index='+index+'" rel="external">'+elem.taskCname + '</a></li>';
		});	
		$('#subBoard ul').html(reString).listview('refresh',true);
	}
//------------------------------------------------------------		
	function doReturn(sys,sbindex){

		if(parseInt(sys)>=0){
			$('#hhome').hide();
			$('#hback').show();
			var subMenu=menuTree[sys].sysSublist;
			var SysName=menuTree[sys].sysCname;
			taskList(sys,SysName,subMenu);
			$('#mBoard').hide();
			$('#subBoard').fadeIn(500);
		}

	}
//------------------------------------------------------------	
	//Page View start
	var initView = function(){
		$('#hotNews ul').html(hotNewsList());
		$('#com_notice ul').html(comList()); //2013.10.25 新增
		$('#mBoard').css({'margin':'0', 'padding':'0'});
		$('#subBoard').css({'margin':'0', 'padding':'0'});
		$('#toplink').css({'margin':'0', 'padding':'0'});		
	};
	
	initView();
		
})(jQuery);