<%@ page language="java" contentType="text/html; charset=BIG5"%>


function ButtonDefine() {
	
	/**
	功能細項定義	功能細項代號	授權項目編號	授權項目名稱
	BUTTON	B	B0001	查詢
	BUTTON	B	B0002	新增
	BUTTON	B	B0003	刪除
	BUTTON	B	B0004	修改
	BUTTON	B	B0005	列印
	BUTTON	B	B0006	測試
	BUTTON	B	B0007	提交
	BUTTON	B	B0008	清空
	BUTTON	B	B0009	上一頁
	BUTTON	B	B0010	同意
	BUTTON	B	B0011	退回
	BUTTON	B	B0012	明細匯總
	BUTTON	B	B0014	下一筆
	
	*/
	
	// 定義預設對應的畫面元件
	

}

function Authority(define) {

	var buttons = new Hash();
	var params = {};
	var _buttons = {
					B0001:'btn_query',
					B0002:'btn_add',
					B0003:'btn_remove',
					B0004:'btn_update',
					B0005:'btn_print',
					B0006:'btn_test',
					B0007:'btn_submit',
					B0008:'btn_clean',
					B0009:'btn_back',
					B0010:'btn_agree',
					B0011:'btn_rejection',
					B0012:'btn_together',
					B0014:'btn_next',
					B0016:'btn_B0016',
					B0017:'btn_cancal_agree',
					B0025:'btn_select',
					B0026:'btn_cancel',
					B0033:'btn_single_add',
					B0034:'btn_single_update',
					B0035:'btn_single_remove',
					B0036:'btn_B0036',
					B0049:'btn_add_update',
					B0052:'btn_index',
					B0065:'btn_swift'
				  };
	
	function override(buttons) {
		
		var keys = Object.keys(buttons);
		keys.each(
			function(key){
				_buttons[key] = buttons[key];
			});
		
		if (define.debug == true) {
			
			alert("buttons mapping :" + Object.toJSON(_buttons) )
		}	
	}
	
	function decideType() {
	
	}
	
	
	
	function checkButtons(legal) {		
		
		if (define.debug == true) {
			alert("server response:" + Object.toJSON(legal) );
		}
		
		for (var i=0;i<legal.length;i++) {
		
			var id = _buttons[ legal[i] ]
			var button = $(id);
			
			var obj = {code:legal[i],id:id};
			
			//alert(id.substring(4) + " - " + Object.toJSON(obj));
			
			
			
			if (button == null) {
				alert("can't find button [" + id + "]");
			} else {
			
				buttons.set( id.substring(4),obj);
				
				if (define.debug == true) {
			
					alert("buttons enable :" + id )
				}	
				
				button.disabled = false;
			}
		
		}
		
	}  
	
	  
	
	function init() {
		var contextPath = "<%=request.getContextPath()%>";
		var webIndex = contextPath.indexOf("Web");
		var sysId = webIndex<2?'RZ':contextPath.substring(webIndex-2, webIndex);
		var txBean = sysId.substring(0, 1)=='J'?'JZA0_0500':'RZA0_0500';
		new Ajax.Request(contextPath+"/servlet/HttpDispatcher/"+txBean+"/check",
								{
								method:'post',
							  	parameters:{FUNC_ID:define.FUNC_ID},
							  	onSuccess:function(transport){
							  		var json=transport.responseText.evalJSON();
							  		Sys.check(json,function(status){
							  			if(status){							  				
							  				checkButtons(json.resultObj);
							  				
							  				if (define.callback != null) {
							  					
							  					define.callback();
							  				}
							  			}
								  	}
							  		);
							  	},
							  	onFailure: Sys.SystemError
							  });
	}
	
	init();
	
	return {
			check:function(callback) {
			
				
			
			},
			buttons:function() {
				return buttons;
			},
			contains:function(key) {
				
				if (buttons.get(key) == null) {
					return false;
				} else {
					return true;		
				}
			}
		};

}


