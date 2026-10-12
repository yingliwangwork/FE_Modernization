var joblightbox = function() {

	var _jobContentCols = 4;
	var _breakLength = 7;
	var o;

	var _inited = false;
	var _eventInited = false;
	var data = [];

	$.fn.input_iCheck  = function(){
		return this.each(function(){
			$(this).iCheck({
				checkboxClass: 'icheckbox'
			});
		});
	};

	$.fn.input_iRadio  = function(){
		return this.each(function(){
			$(this).iCheck({
				checkboxClass: 'iradio',
				increaseArea: '20%'
			});
		});
	};

	$.fn.input_iSelect = function(){
		return this.each(function() {
			if( $(this).parent().is('.iselect') ) return true;
			
			var o = $(this),
				w = parseInt(o.css('width')) || 100,
				iselect, toggle;
			
			o.wrap('<span class="iselect" />');
			iselect = o.parent();
			
			iselect.css('width', w );
			o.css('width', w + 20);
			
			toggle = $('<i />').appendTo(iselect);
			
			// avoid text overlaps <i>
			iselect.on('mouseenter', function(){
				toggle.css('z-index', 1);
			}).on('mouseleave', function(){
				toggle.css('z-index', '');
			});
		});
	};

	return {
		windowFunctionRegister: function(){
			window['joblightbox']= new function(){
				var selected_cbFunc;
				var rtnKey;
				var rtnValue;

				var executeConfirm = function(){
					if(!rtnValue){
						return;
					}
					if(selected_cbFunc){
						selected_cbFunc({
							jobCode: rtnValue
							, jobName: rtnKey
						});
					}
					joblightbox.close();
				};

				return {
					loadCommonJobs: function(inputData){
						data=inputData;
						for(var i in data){
							var jobGroup = data[i];
							if(jobGroup.sort === undefined){
								for(var j in jobGroup.jobs){
									var job = jobGroup.jobs[j];
									job.space = Math.ceil(job.key.length/_breakLength);
								}
								jobGroup.jobs.sort(function(a,b) { return parseFloat(a.space) - parseFloat(b.space) } );
							}
						}
						return this;
					}
					, fancyboxSetting: {// fancybox @see http://fancyapps.com/fancybox/#docs
	
						//parent: '.costs-calculator',
						wrapCSS: 'infobox-fancybox',
						type: 'inline',
						padding: 0,
						margin: 0,
						closeClick: false,
						autoSize: true,
						width: 'auto',
						height: 'auto',
						helpers: {  title: null, overlay: { closeClick: true, locked: true, speedOut:0 } },
						closeSpeed: 0,
						closeEffect: 'none',
						fitToView : false, // so fancybox won't try to scale the content to the size of the browser window
			 			scrolling : "no",// so no scroll bars inside fancybox
						afterShow: function(){
							if( !$('.infobox-header', this.wrap)[0] )
								$('.fancybox-close', this.wrap).addClass('fancybox-close2');
						}
					}
					, init: function(opt) {
						if(_inited){
							return;
						}
						_inited = true;
						selected_cbFunc = opt['selected_cbFunc'];
						var optionsLv1 = opt['optionsLv1'];
						var cbFunc_optionsLv1 = opt['cbFunc_optionsLv1'];
						var cbFunc_optionsLv2 = opt['cbFunc_optionsLv2'];

						var initDefaultOption = function(dom_select){
							dom_select.empty();
							dom_select.append($('<option/>').val('').html('請選擇'))
						};

						var total = data.length;

						var dom_Tbody = $('<tbody/>');
						var idx = 0;

						for(var i=0;i<total;i++){
							var jobGroup = data[i];
							var jobs = jobGroup['jobs'];
							var dom_TdLabel = $('<td/>').addClass('first align-mc field').html(jobGroup['label']);

							var dom_Tr = $('<tr/>').append(dom_TdLabel);
							dom_Tbody.append(dom_Tr);

							var groupRows = 1;
							var currCols = 0;
							var jobsSize = jobs.length;
							var lastIndex = jobsSize-1;
							for(var j=0;j<jobsSize;j++){
								var job = jobs[j];
								var colSpan = job['colSpan']||1;
								var jobKey = job['key'];
								currCols+=colSpan;
								if(currCols>_jobContentCols){
									dom_Tr = $('<tr/>');
									dom_Tbody.append(dom_Tr);
									currCols=0;
									currCols+=colSpan;
									groupRows++;
								}

								if(j==lastIndex){
									colSpan += _jobContentCols-currCols;
								}
								dom_Tr.append(
									$('<td/>').addClass('align-ml').attr('colspan',colSpan)
									.append(
										$('<label/>')
											.append($('<input type="radio" name="job"/>').val(job['value']).attr('key',jobKey))
											.append($('<span/>').css('margin-left','5px').html(jobKey))

									)
								);
							}

							if(groupRows>1){
								dom_TdLabel.attr('rowspan',groupRows);
							}

						}

						var controlDisplayStyle_select = function(dom_select, isDisabled){
							if(isDisabled){
								dom_select.attr('disabled','disabled');
								dom_select.parent().addClass("disabled");
							}else{
								dom_select.removeAttr('disabled');
								dom_select.parent().removeClass("disabled");
							}
						};

						var dom_button_jobCommons = $('<button type="button" class="btn green mt10" id="q1_submit"><b>確定</b></button>').click(executeConfirm);
						var dom_spanDisplayJob = $('<span id="job_descr"></span>');

						var dom_body = $("body").append(
							$('<div id="joblightbox" class="infobox"/>')
								.append(
									$('<div class="infobox-header"><div class="infobox-title">請選擇您的職業類別：</div></div>')
								).append(
									$('<div class="infobox-body"/>')
										.append(
											$('<table/>').append('<colgroup><col width="155px"/><col/><col/><col/></colgroup>').append(dom_Tbody)
										).append(
											$('<div class="infobox-body-helper">找不到您的職業嗎？請點選此處<a href="javascript:;" id="findMoreOccup">查詢您的職業</a></div>')
										)
								).append(
									$('<div class="infobox-footer bgc_blue_light pt15 pb15"></div>')
										.append(
											$('<div class="text_24 color_green_dark">您選擇的職業是：</div>')
												.append(
													dom_spanDisplayJob
												)
										)
										.append(
											dom_button_jobCommons
										)
								)
						);

						var dom_selectLv1 = $('<select/>').css('width','240px');
						var dom_selectLv2 = $('<select/>').css('width','240px');
						var dom_selectLv3 = $('<select/>').css('width','240px');

						dom_selectLv1.change(function(){
							initDefaultOption(dom_selectLv3);
							controlDisplayStyle_select(dom_selectLv3, true);

							initDefaultOption(dom_selectLv2);

							var dom_selectLv1Value = dom_selectLv1.val();

							if(dom_selectLv1Value===''){
								controlDisplayStyle_select(dom_selectLv2, true);

							}else{
								if(cbFunc_optionsLv1){
									controlDisplayStyle_select(dom_selectLv2, false);
									var optionsLv2 = cbFunc_optionsLv1(dom_selectLv1Value);
									if(optionsLv2){
										for(var i=0;i<optionsLv2.length;i++){
											var optLv2 = optionsLv2[i];
											dom_selectLv2.append($('<option/>').val(optLv2.value).html(optLv2.key));
										}
									}
								}
							}
						});

						dom_selectLv2.change(function(){
							initDefaultOption(dom_selectLv3);
							var dom_selectLv2Value = dom_selectLv2.val();
							if(dom_selectLv2Value===''){
								controlDisplayStyle_select(dom_selectLv3, true);
							}else{
								controlDisplayStyle_select(dom_selectLv3, false);
								if(cbFunc_optionsLv2){
									var optionsLv3 = cbFunc_optionsLv2(dom_selectLv2Value);
									if(optionsLv3){
										for(var i=0;i<optionsLv3.length;i++){
											var optLv3 = optionsLv3[i];
											var jobKey = optLv3.key;
											dom_selectLv3.append($('<option/>').val(optLv3.value).html(jobKey));
										}
									}
								}
							}
						});

						dom_selectLv3.change(function(){
							rtnValue = this.value;
							rtnKey = this.options[this.selectedIndex].innerHTML;
						});

						initDefaultOption(dom_selectLv1);
						initDefaultOption(dom_selectLv2);
						initDefaultOption(dom_selectLv3);

						for(var i=0;i<optionsLv1.length;i++){
							var optLv1 = optionsLv1[i];
							dom_selectLv1.append($('<option/>').val(optLv1.value).html(optLv1.key));
						}

						var dom_button = $('<button type="button" class="btn green" id="q2_submit"><b>確定</b></button>').click(function(){
							dom_selectLv1.val('');
							initDefaultOption(dom_selectLv2);
							initDefaultOption(dom_selectLv3);
							controlDisplayStyle_select(dom_selectLv2, true);
							controlDisplayStyle_select(dom_selectLv3, true);
							executeConfirm();
						});

						dom_body.append(
							$('<div id="joblightboxAll" class="infobox"/>')
								.append('<div class="infobox-header"><diV class="infobox-title">請選擇您的職業類別：</div></div>')
								.append(
									$('<div class="infobox-body"/>')
										.append('<div class="infobox-body-top-helper color_orange text_al"><i class="color_orange rq">*</i>必填</div>')
										.append(
											$('<div class="stepWrap mt5"/>')
												.append(
													$('<div/>').addClass('step')
														.append('<label class="text_16 color_grey mb10"><i class="color_orange rq mr5">*</i>Step1:請選擇您的行業別</label>')
														.append(dom_selectLv1)
												)
												.append(
													$('<div/>').addClass('step')
														.append('<label class="text_16 color_grey mb10"><i class="color_orange rq mr5">*</i>Step2:請選擇您的職業種類</label>')
														.append(dom_selectLv2)
												)
												.append(
													$('<div/>').addClass('step')
														.append('<label class="text_16 color_grey mb10"><i class="color_orange rq mr5">*</i>Step3:請選擇您的職業內容</label>')
														.append(dom_selectLv3)
												)
										)
										.append(
											'<div class="result mt50 mcenter" id="joblightboxAll_result" style="display:none;"><div class="text_24 color_green_dark" id="joblightboxAll_title">您的職業類別為第一類一般內勤</div><div class="text_16 color_grey mt25 text_al">職業內容：</div><div class="text_16 color_grey text_al" id="joblightboxAll_detail">內勤人員、管理階層人員、諮詢人員...等從事文書處理工作且非以外務為主。</div></div>'
										)
										.append(
											$('<div class="actionWrap mt20"></div>')
												.append($('<div class="l"/>').append($('<a href="javascript:;" class="color_green" id="backToNormal"><i class="ico_back mr5"></i>常見職業列表</a>')))
												.append($('<div class="m"/>').append(dom_button))
										)
								)
								.append(
									'<div class="infobox-footer bgc_grey_light"><ul class="serviceline"><li><span class="general">一般客服專線 0800-036-599</span></li><li><span class="vip">VIP客服專線 0800-805-888</span></li><li><span class="oversea">海外諮詢專線 +886-2-5559-5110 #1</span></li></ul></div>'
								)
						)

						$(':radio',o).input_iRadio();
						$('select',o).input_iSelect();

						$(':radio',$("#joblightboxAll")).input_iRadio();
						$('select',$("#joblightboxAll")).input_iSelect();

						controlDisplayStyle_select(dom_selectLv2, true);
						controlDisplayStyle_select(dom_selectLv3, true);

						o = $("#joblightbox");

						$('[name="job"]', o).on('ifChecked', function(){
							var dom_radio = $('[name="job"]:checked', o);
							var jobKey = dom_radio.attr('key');
							var jobValue = dom_radio.val();
							rtnKey=jobKey;
							rtnValue=jobValue;
							dom_spanDisplayJob.html(jobKey);
						});
						return this;
					}
					, open: function() {
						rtnValue=undefined;
						rtnKey=undefined;
						$.fancybox.open(o, $.extend({
							beforeShow	: function() {

								if(_eventInited){
									return this;
								}
								_eventInited = true;

								$("#backToNormal").on("click",function(){
									joblightbox.close();
									$.fancybox.open($('#joblightbox'), joblightbox.fancyboxSetting);    
								})
								$("#findMoreOccup").on("click",function(){
									joblightbox.close();
									$.fancybox.open($('#joblightboxAll'), joblightbox.fancyboxSetting);    
								})

								$("#joblightboxAll_lv1").bind("change",function(){
									joblightbox.updatejoblightboxAll("lv1");
								})
								$("#joblightboxAll_lv2").bind("change",function(){
									joblightbox.updatejoblightboxAll("lv2");
									
								})
								$("#joblightboxAll_lv3").bind("change",function(){
									joblightbox.updatejoblightboxAll("lv3");
								})
		
								joblightbox.toggleSelectbox("#joblightboxAll_lv2",false);
								joblightbox.toggleSelectbox("#joblightboxAll_lv3",false);
								o.trigger('open');
								return this;
							}
							,afterClose	: joblightbox.onClose
						}, joblightbox.fancyboxSetting) );
					}
					, openForAT:function(opt){
						var rtnJobCat;//職業類別
						var rtnJobLV1;//大分類職業代碼
						var rtnLV1Name;//大分類職業中文
						var rtnJobName;//職業中文
						var rtnJobCode;//職業代碼
						
						var optionsLv1 = opt['optionsLv1'];
						var cbFunc_optionsLv1 = opt['cbFunc_optionsLv1'];
						var cbFunc_optionsLv2 = opt['cbFunc_optionsLv2'];
						var cbFunc = opt['cbFunc'];
						
						var controlDisplayStyle_select = function(dom_select, isDisabled){
							if(isDisabled){
								dom_select.attr('disabled','disabled');
								dom_select.parent().addClass("disabled");
							}else{
								dom_select.removeAttr('disabled');
								dom_select.parent().removeClass("disabled");
							}
						};
						
						var initDefaultOption = function(dom_select){
							dom_select.empty();
							dom_select.append($('<option/>').val('').html('請選擇'));
						};
						
						var completeBlock = function(){
							if(!rtnJobCat){
								alert('請回答必填項目');
								return;
							}
							if(cbFunc){
								cbFunc({
									'jobClassValue':rtnJobCat
									, 'jobClassName':WIUtil.jobInfoHandler.getJobClassName(rtnJobCat)
									, 'overprintValue':rtnJobLV1
									, 'overprintName':rtnLV1Name
									, 'description':rtnJobName
									, 'jobcode':rtnJobCode
								});
								rtnJobCat = '';//職業類別
								rtnJobLV1 = '';//大分類職業代碼
								rtnLV1Name = '';//大分類職業中文
								rtnJobName = '';//職業中文
								rtnJobCode = '';//職業代碼
							}
							$.fancybox.close();
						};
						
						var clearItem = function(){
							rtnJobCat = '';
							rtnJobName = '';
							rtnJobCode = '';
						};
						
						var dom_selectLv1 = $('<select/>').css('width','240px');
						var dom_selectLv2 = $('<select/>').css('width','240px');
						var dom_selectLv3 = $('<select/>').css('width','240px');
						var dom_jobCat = $('<select/>').attr('hidden', true).attr('id', 'JOB_CAT');

						dom_selectLv1.change(function(){

							rtnJobLV1 = this.value;//大分類職業代碼
							rtnLV1Name = this.options[this.selectedIndex].innerHTML;//大分類職業中文
							clearItem();
							
							initDefaultOption(dom_selectLv3);
							controlDisplayStyle_select(dom_selectLv3, true);

							initDefaultOption(dom_selectLv2);

							var dom_selectLv1Value = dom_selectLv1.val();

							if(dom_selectLv1Value===''){
								controlDisplayStyle_select(dom_selectLv2, true);
							}else{
								controlDisplayStyle_select(dom_selectLv2, false);
								if(cbFunc_optionsLv1){
									var optionsLv2 = cbFunc_optionsLv1(dom_selectLv1Value);
									if(optionsLv2){
										for(var i=0;i<optionsLv2.length;i++){
											var optLv2 = optionsLv2[i];
											dom_selectLv2.append($('<option/>').val(optLv2.value).html(optLv2.key));
										}
									}
								}
							}
						});

						dom_selectLv2.change(function(){
							clearItem();
							initDefaultOption(dom_selectLv3);
							initDefaultOption(dom_jobCat);
							var dom_selectLv2Value = dom_selectLv2.val();
							if(dom_selectLv2Value===''){
								controlDisplayStyle_select(dom_selectLv3, true);
							}else{
								controlDisplayStyle_select(dom_selectLv3, false);
								if(cbFunc_optionsLv2){
									var optionsLv3 = cbFunc_optionsLv2(dom_selectLv2Value);
									if(optionsLv3){
										for(var i=0;i<optionsLv3.length;i++){
											var optLv3 = optionsLv3[i];
											dom_selectLv3.append($('<option/>').val(optLv3.jobCode).html(optLv3.jobName));
											dom_jobCat.append($('<option/>').val(optLv3.jobCode).html(optLv3.jobCat));
										}
									}
								}
							}
						});

						dom_selectLv3.change(function(){
							if(this.value === '') {//選到請選擇
								clearItem();
								return;
							}
							rtnJobCat = dom_jobCat[0].options[this.selectedIndex].innerHTML;//職業類別
							rtnJobName = this.options[this.selectedIndex].innerHTML;//職業中文
							rtnJobCode = this.value;//職業代碼
						});

						initDefaultOption(dom_selectLv1);
						initDefaultOption(dom_selectLv2);
						initDefaultOption(dom_selectLv3);
						initDefaultOption(dom_jobCat);

						for(var i=0;i<optionsLv1.length;i++){
							var optLv1 = optionsLv1[i];
							dom_selectLv1.append($('<option/>').val(optLv1.value).html(optLv1.key));
						}

						var dom_button = $('<button type="button" class="greenbn" id="q2_submit"><b>確定</b></button>').click(function(){
							dom_selectLv1.val('');
							initDefaultOption(dom_selectLv2);
							initDefaultOption(dom_selectLv3);
							initDefaultOption(dom_jobCat);
							controlDisplayStyle_select(dom_selectLv2, true);
							controlDisplayStyle_select(dom_selectLv3, true);
							completeBlock();
						});
						
						var dom_body = $('body').append(
								$('<div id="joblightboxAll" class="infobox"/>')
									.append('<div class="infobox-header"><div class="infobox-title">請選擇您的職業類別：</div></div>')
									.append(
										$('<div class="infobox-body"/>')
											.append('<div class="infobox-body-top-helper color_orange text_al"><i class="color_orange rq">*</i>必填</div>')
											.append(
												$('<div class="stepWrap mt5"/>')
													.append(
														$('<div/>').addClass('step')
															.append('<label class="text_16 color_grey mb10"><i class="color_orange rq mr5">*</i>Step1:請選擇您的行業別</label>')
															.append(dom_selectLv1)
													)
													.append(
														$('<div/>').addClass('step')
															.append('<label class="text_16 color_grey mb10"><i class="color_orange rq mr5">*</i>Step2:請選擇您的職業種類</label>')
															.append(dom_selectLv2)
													)
													.append(
														$('<div/>').addClass('step')
															.append('<label class="text_16 color_grey mb10"><i class="color_orange rq mr5">*</i>Step3:請選擇您的職業內容</label>')
															.append(dom_selectLv3)
															.append(dom_jobCat)
													)
											)
											.append(
												'<div class="result mt50 mcenter" id="joblightboxAll_result" style="display:none;"><div class="text_24 color_green_dark" id="joblightboxAll_title">您的職業類別為第一類一般內勤</div><div class="text_16 color_grey mt25 text_al">職業內容：</div><div class="text_16 color_grey text_al" id="joblightboxAll_detail">內勤人員、管理階層人員、諮詢人員...等從事文書處理工作且非以外務為主。</div></div>'
											)
											.append(
												$('<div class="actionWrap mt20"></div>')
													.append($('<div class="m"/>').append(dom_button))
											)
									)
									.append(
										'<div class="infobox-footer bgc_grey_light"><ul class="serviceline"><li><span class="general">一般客服專線 0800-036-599</span></li><li><span class="vip">VIP客服專線 0800-805-888</span></li><li><span class="oversea">海外諮詢專線 +886-2-5559-5110 #1</span></li></ul></div>'
									));
						$(':radio',$("#joblightboxAll")).input_iRadio();
						
						$('select',$("#joblightboxAll")).each(function() {
							if(this.hidden === false) {
								$(this).input_iSelect();
							}
						});
						
						controlDisplayStyle_select(dom_selectLv2, true);
						controlDisplayStyle_select(dom_selectLv3, true);
						
						$.fancybox.open($('#joblightboxAll'), joblightbox.fancyboxSetting);
					}
					, toggleSelectbox:function(a_id,a_boolean){
			
						if(a_boolean){
							$(a_id).removeAttr('disabled');
							$(a_id).parent().removeClass("disabled");
						}else{
							$(a_id).attr('disabled','disabled');
							$(a_id).parent().addClass("disabled");
						}
					}
					, updatejoblightboxAll:function(a_lv){
						switch(a_lv){
							case "lv1":
								$("#joblightboxAll_lv2").val(0);
								$("#joblightboxAll_lv3").val(0);
								joblightbox.toggleSelectbox("#joblightboxAll_lv2",true);
			
								if($("#joblightboxAll_lv1").val() == 0){
									joblightbox.toggleSelectbox("#joblightboxAll_lv2",false);
								}
								joblightbox.toggleSelectbox("#joblightboxAll_lv3",false);
							break;
			
							case "lv2":
								$("#joblightboxAll_lv3").val(0);
								if($("#joblightboxAll_lv2").val() == 0){
									joblightbox.toggleSelectbox("#joblightboxAll_lv3",false);
								}
								else{
									joblightbox.toggleSelectbox("#joblightboxAll_lv3",true);
								}
							break;
			
							case "lv3":
							break;
						}
						if($("#joblightboxAll_lv1").val() != 0 && $("#joblightboxAll_lv2").val() != 0 && $("#joblightboxAll_lv3").val() != 0){
							$("#joblightboxAll_result").show();
							$("#joblightboxAll_title").html("您的職業類別為第"+$( "#joblightboxAll_lv1 option:selected" ).text()+"   "+$( "#joblightboxAll_lv2 option:selected" ).text());
							$("#joblightboxAll_detail").html($("#joblightboxAll_lv3 option:selected" ).text());
						}else{
							$("#joblightboxAll_result").hide();
						}
					}
					, close: function() {
						$.fancybox.close();
					}
					, onClose: function() {
						
						joblightbox.resetLayout();
						
						$.fancybox.close();
						
						o.trigger('close');
						
						return joblightbox;
					}
					, resetLayout: function() {			
					}
				};
			}
		}
	};

};