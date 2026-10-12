
function TreeUI(define) {
	
	// private 
	var Tree = Ext.tree;
	var tree;
	var root;
	var loader;
	
	// public 
	var listeners = [];
	
	if (define.listeners != null) {
		listeners = define.listeners;
	}	
	
	
	return {
		init:function() {
			this.buildTree();
		},
		load:function() {
			tree.getLoader().load( root );
		},
		getRoot:function() {
			return tree.root;
		},
		getLoader:function() {
			return loader;
		},
		destroy:function() {
			 tree.destroy();
		},
		expandAll:function() {
			tree.expandAll();
		},
		getTopParent:function(node) { 	
			if (node.parentNode == null || node.parentNode.id == tree.root.id) {
				return node;
			} else {
				return this.getTopParent(node.parentNode);
			}
		},
		buildTree:function() {

			// override
			if (define.isLeaf != null) {

				/**
				Ext.override(Ext.tree.TreeNode,{
				      isLeaf(): function(args) {
				      		//if (this.
				            return this.leaf === true;
				      }
				});*/

			}

			loader = new Tree.TreeLoaderUI({dataUrl:define.url,root:define.root});
			
			tree = new Tree.TreePanel({
                el:define.target,
                rootVisible:define.rootVisible,
                animate:true, 
                autoScroll:true,
                loader: loader,
                enableDD:true,
                ddGroup:define.dragGroup,
                containerScroll: true,
                ddAppendOnly:true
            });
            
            // add listen
			for (var i=0;i<listeners.length;i++) {
				var listener = listeners[i];
				
				if ( listener.name == 'beforeload' ) {
					tree.getLoader().addListener( listener.name, listener.handler);

				} else if ( listener.name == 'loaderLoad') {
					tree.getLoader().addListener( 'load', listener.handler);

				} else  if (listener.name == 'click' ) {
					tree.addListener( listener.name, listener.handler);

				} else  if (listener.name == 'beforerender' || listener.name == 'expand' ) {	
					tree.addListener( listener.name, listener.handler);

				} else {
					tree.addListener( listener.name, listener.handler);

				}
			}
            
            // add a tree sorter in folder mode
            new Tree.TreeSorter(tree, {folderSort:true});
            
            // set the root node
            root = new Tree.AsyncTreeNode({
	            	id:define.rootId,
	                text: define.rootTitle, 
	                draggable:false,
	                leaf:false 
            	});
            
            tree.setRootNode(root);
            
            // render the tree
            tree.render();
            
            root.expand(define.deep, /*no anim*/ false);
            
			
            
		}
		
			
	};
};

// }();
//Ext.onReady(MyTree.init,MyTree,true);  
