


/**
　　* Construct a new FormUI class.
　　* @class This class represents an instance of a FormUI.
　　* @constructor 中文
　　* @param {definde} define of FormUI.
　　* @return A new instance of a Form
　　*/
function FormUI(define) {
	
	// 定義常數
	
	// 轉換的對象
	var target = define.target;
	
	// 維護的對象
	this.modify;
	
	// 定義用到的 template
	this.template = "form.template.default";
	
	// 呈現畫面
	this.render = function() {
		
		
	
	}
	
	return {
		init:function() {

		},
		buildTree:function() {
			
            
            
		},
		reset:function() {
			
			$(target).reset();
		},
		setStatus:function(v) {
			
			this.status = v;
		},
		getStatus:function() {
		
			return this.status;
		},
		getTarget:function() {
			
			return $(target);
		},
		setModify:function(obj) {
			
			this.modify = obj;
		},
		getModify:function() {
			
			return this.modify;
		}
	};



}  