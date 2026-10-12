Ext.tree.TreeLoaderUI = function(config){
	this.root = config.root;
    Ext.tree.TreeLoaderUI.superclass.constructor.call(this, config);
};
 

Ext.extend(Ext.tree.TreeLoaderUI, Ext.tree.TreeLoader, {

   processResponse : function(response, node, callback){
        var json = response.responseText;
        try {
        
            var o = eval("("+json+")");
        	
        	if (this.root) {
            	o = o[this.root];
            } 
            
            node.beginUpdate();
            for(var i = 0, len = o.length; i < len; i++){
                var n = this.createNode(o[i]);
                if(n){
                    node.appendChild(n);
                }
            }
            node.endUpdate();
            if(typeof callback == "function"){
                callback(this, node);
            }
        }catch(e){
            this.handleFailure(response);
        }
    }
 
});
