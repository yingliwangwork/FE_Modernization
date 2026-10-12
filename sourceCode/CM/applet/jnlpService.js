$.noConflict();
(function ($) {
	var jnlpService = function (jnlpName, jnlpRoot, port, closeOnExit, msgBox) {
		// 指定 jnlp 目錄的位置，及 local 服務的 port 號
		var _port = (port && parseInt(port, 10) > 30000) ? parseInt(port, 10) : 32002;
		var _service = 'https://localhost:' + _port + '/api';
		if(!jnlpRoot){
			throw 'jnlpRoot cant not be null.';
		}
		var _jnlpRoot = jnlpRoot; // || window.location.protocol + '//' + window.location.host + '/AVWeb/html/AV/E0/AVE0_5600';

		if(jnlpRoot.indexOf(window.location.protocol) != 0){
			jnlpRoot = jnlpRoot.replace(/^.+?:/ , window.location.protocol);
		}
		
		var status_msg = [
			"等待JNLP服務啟動",
			"等待JNLP服務啟動...請開啟系統通知下載之TiffViewer.jnlp檔案...",
			"JNLP服務視窗已啟動...等待讀取圖片...",
			"讀取圖片完成",
			"服務正在嘗試啟動中，請稍後再試",
			"主機已開啟其他JNLP程式，請關閉其他程式後再試",
			"JNLP服務無法啟動，請重新啟動服務",
			"JNLP服務無法在時限內啟動，請嘗試重新啟動服務"
		];

		var viewService = null;

		// 檢查服務 10 次，每次間隔 2 秒
		var _testRetryTimes = 90;
		var _testRetryTimeout = 2000;
		var _testJNLPTimeout = 500;
		
		var closeJnlp = function(){
			$.ajax(_service + '/close', { timeout: _testJNLPTimeout });
		};
		
		if(closeOnExit!== false){
			$(window).on('unload', closeJnlp).on('beforeunload',closeJnlp);
		}
		
		if(!msgBox){
			msgBox = $('<h3 style="text-align: center;">').html(status_msg[0]);
			$('body').children().first().before(msgBox);
		}else{
			msgBox = $(msgBox);
		}

		return {
			setErrMsg: function (msg) {
				status_msg[6] = msg;
			},
			close: closeJnlp,
			run: function (apiName, data, done_handler, fail_handler) {

				if (viewService && viewService.state() == 'pending') {
					msgBox.html(status_msg[4]);
					return;
				}

				var jnlpCheckCnt = 0;
				var jnlpCallerWindow = null;
				var jnlpCalled = false;
				viewService = $.Deferred();
				
				var checkPrintService = function(){
				$.ajax( _service + '/ping', { timeout: _testJNLPTimeout })
					.then(function (resp) {
						if(!jnlpName || resp == jnlpName){
							window.console && console.log('open jnlp app : ' + resp);
							msgBox.html(status_msg[2]);
							viewService.resolve();
						}else{
							window.console && console.log('aonther jnlp app opened : ' + resp);
							viewService.reject(status_msg[5]);
						}
						
					}, function (xhr, status, error) {
						window.console && console.log('jnlp ping error: ' + status +' / '+ error);
						if (!jnlpCalled && 'timeout' == status) {
							jnlpCallerWindow = $('#jnlpFrame');
							if(jnlpCallerWindow.length){ jnlpCallerWindow.remove(); }
							var jnlpCallerWindow = $('<iframe>').attr('id','jnlpFrame').hide().appendTo(document.body);
							jnlpCallerWindow.attr('src' , _jnlpRoot + '/launchViewer.jsp' );
							jnlpCalled = true;
							msgBox.html(status_msg[1]);
							setTimeout(checkPrintService, _testRetryTimeout);
						} else if ('error' == status) {
							viewService.reject(status_msg[6]+' ( '+ error + ')');
						} else if (jnlpCheckCnt++ > _testRetryTimes) {
							viewService.reject(status_msg[7]);
						} else {
							msgBox.html(status_msg[1]+"("+jnlpCheckCnt+")");
							setTimeout(checkPrintService, _testRetryTimeout);
						}
					});
				};
				
				checkPrintService();

				var dfd = $.Deferred();
				dfd.done( function(){
					msgBox.html(status_msg[3]);
					if ($.isFunction(done_handler)) {
						done_handler();
					}
					
				}).fail(function (resp) { 
					msgBox.html(resp);
					if ($.isFunction(fail_handler)) {
						fail_handler(resp);
					} else {
						alert(resp);
					}
				});
				
				viewService.done(function () {
					if (jnlpCallerWindow) {
						try {
							jnlpCallerWindow.close();
							jnlpCallerWindow = null;
						} catch (e) {
							window.console && console.log(e);
						}
					}
					$.get(_service + '/'+ apiName, data)
						.done(function (resp) {
							if (resp) { // resp is error msg
								dfd.reject(resp);
							} else {
								dfd.resolve();
							}
						});

				}).fail(function (errMsg) {
					dfd.reject(errMsg);
				});
			}
		};
	};

	// export jnlpService to window jnlpService
	if (!window.jnlpService) {
		window.jnlpService = jnlpService;
	}

})(jQuery);