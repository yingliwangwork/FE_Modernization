function ErrorHandler(){

	var _registerOptions = {};
	var _uidKey = 'errorHandlerUid';
	var _registerIndex = 0;

	var _executeCheck = function(groupNode, checkNodes, checkRole){

		if(!groupNode){
			var checkNode = checkNodes.length?checkNodes[0]:checkNodes;
			checkNode = $(checkNode);
			groupNode = $(checkNode.parents('.checkGroup')[0]);
		}

		var checkFunc = checkRole['checkFunc'];
		var errorMessage = checkRole['errorMessage'];
		var checkSuccess = checkFunc(checkNodes);

		if(checkSuccess && typeof checkSuccess == 'boolean' ){
			groupNode.removeClass('error').find('div.error_prompt').remove();

		}else if(!groupNode.hasClass('error')){

			groupNode.append(
				$('<div/>').addClass('error_prompt')
					.append(
						$('<i/>').addClass('arrow_error_prompt')
					).append(
						$('<i/>').addClass('icon_error').addClass('mr_5')
					).append(
						$('<span/>').html(checkSuccess?checkSuccess:errorMessage)
					)
			).addClass('error');
		}
		return checkSuccess;
	};

	return {
		register: function(opt){
			if(!opt){
				return this;
			}
			var checkNodes = opt['checkNodes'];
			if(!checkNodes){
				return this;
			}

			var uid = opt['UID']||++_registerIndex;
			_registerOptions[uid]=opt;

			if(checkNodes.length){
				for(var i=0;i<checkNodes.length;i++){
					$(checkNodes[i]).attr(_uidKey, uid);
				}
			}else{
				checkNodes.attr(_uidKey, uid);
			}

			return this;
		},
		remove: function(checkNode){
			if(!checkNode){
				return this;
			}
			var uid = checkNode.attr(_uidKey);
			if(uid){
				delete _registerOptions[uid];
			}
			return this;
		},
		executeCheck: function(){
			this.clear();
			var passChecked = true;
			for(var uid in _registerOptions){
				var regOpt = _registerOptions[uid];
				var groupNode = regOpt['groupNode'];
				var checkNodes = regOpt['checkNodes'];
				var checkRoles = regOpt['checkRoles'];
				if(!checkNodes && !checkRoles){
					continue;
				}
				var checkSuccess = true;
				if(checkRoles.length){
					for(var j=0;j<checkRoles.length;j++){
						checkSuccess = _executeCheck(groupNode, checkNodes, checkRoles[j]);
						if(!checkSuccess){
							passChecked = false;
							continue;
						}
					}
				}else{
					checkSuccess = _executeCheck(groupNode, checkNodes, checkRoles);
				}

				if(!checkSuccess || typeof checkSuccess != 'boolean'){
					passChecked = false;
					continue;
				}
			}
			return passChecked;
		},
		clear: function(){
			for(var uid in _registerOptions){
				var regOpt = _registerOptions[uid];
				var groupNode = regOpt['groupNode'];
				var checkNodes = regOpt['checkNodes'];
				var checkRoles = regOpt['checkRoles'];
				if(!checkNodes && !checkRoles){
					continue;
				}
				var checkNode = checkNodes.length?checkNodes[0]:checkNodes;
				checkNode = $(checkNode);
				checkNode.parents('.checkGroup').removeClass('error').find('div.error_prompt').remove();
			}
		}
	};
}