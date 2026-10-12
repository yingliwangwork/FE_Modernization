var subMenuTimeOutId;
var currentCategory="";
var cSlider=null;
$(document).ready(function(){
	/*begin 主選單*/
	$(document).find("ul[class='category']").each(function(){
		var jj=0;
		var id=$(this).attr("id").substring(8);
		
		$(this).find("li").each(function(){
			$(this).attr("onMouseOver","showSubMenu("+id+","+jj+");");
			
			jj+=1;
		});
	});
	/*end 主選單*/
	$('.bxslider').each(function() {
		  var $bxslider = $(this);
		  var childLength = $('li', $bxslider).length;
		  var maxSlides = 4;
		  $bxslider.bxSlider({
		     'minSlides': 3,
		     'maxSlides': maxSlides,
		     'slideWidth': 225,
		     'infiniteLoop': childLength > maxSlides
		});
	});
	if($('.localTime').length>0){
		$('.localTime').bxSlider({
		    minSlides: 10,
		    maxSlides: 11,
		    slideWidth: 84,
			infiniteLoop: false

		});
		if($('.localTime >li').index() >= 11){
			$('.localZone .bx-pager').show();
		}
		else{
			$('.localZone .bx-pager').hide();
		}
	}
	/*Begin 審批選單*/
	if($(".hmenu").length>0){
		$('.hmenu').bxSlider({				 
		  slideWidth: "auto",
		  pager:false,
		  infiniteLoop:false
		
		});
	}
	
	
	/*end 審批選單*/
	
	$(document).find("i[class='orderUp'],i[class='orderDown']").click(function(){
		if($(this).prop("class")=="orderUp"){
			$(this).prop("class","orderDown");
		}else if($(this).prop("class")=="orderDown"){
			$(this).prop("class","orderUp");
		}
	});
	/*begin custom radio checkbox */
	$('body').addClass('has-js');
	
	$('body').on('click', 'input:radio, input:checkbox', function(){
		var $elem = $(this);
		if($elem.is(':radio')) {
			$elem.prop('checked', true);	
		}
		setupLabel();
	});
	
	setupLabel();
	$( document ).ajaxComplete(function() {
		$('.label_check, .label_radio').click(function(){
			setupLabel();
		});
		setupLabel();
	});
	/*end custom radio checkbox */
	
	$(document).find("i[class='calender']").each(function(){
		var $dateInput = $(this).prev();
		
		$dateInput.datepicker({dateFormat:"yy-mm-dd"}).click(function(){
			$dateInput.datepicker('show');
		});
		
		$($dateInput.get(0)).mask('0000-00-00');
		
	});
	
	$(document).on('click', 'i.calender', function(event) {
		
		var $target = $(this).prev();
		if(!$target.data("datepicker")) {
			$target.datepicker({dateFormat:"yy-mm-dd"});
			$(this).click(function(){
				$target.datepicker('show');				   
			}).triggerHandler('click');
			$($target.get(0)).mask('0000-00-00');
		}
		
	});	
	
	$(document).on('click', '[type="text"]', function(event) {
		
		var $this = $(this);
		if($this.next(0).is('i.calender')) {
			
			if(!$this.data("datepicker")) {
				$this.datepicker({dateFormat:"yy-mm-dd"});
				$this.next().click(function(){
					$this.datepicker('show');				   
				}).triggerHandler('click');
				$this.mask('0000-00-00');
			}								
			
		}
		
	});	
	
	$(document).find("input[id='file1']").each(function(){
														
		$(this).change(function(){

			$("#"+$(this).attr("id")+"_label").find("span").html($(this).val());
			
		});							
	});
	
	
});

function setupLabel() {
	if ($('.label_check input').length) {
		$('.label_check').each(function(){ 
			$(this).removeClass('c_on');
		});
		$('.label_check input:checked').each(function(){ 
			$(this).parent('label').addClass('c_on');
		});                
	};
	if ($('.label_radio input').length) {
		$('.label_radio').each(function(){ 
			$(this).removeClass('r_on');
		});
		$('.label_radio input:checked').each(function(){ 
			$(this).parent('label').addClass('r_on');
		});
	};
};
function hideSubMenu(){
	subMenuTimeOutId=setTimeout(hideSubMenu_,300);
}

function hideSubMenu_(){
	clearTimeout(subMenuTimeOutId);
	$(".menu ul li").removeClass("current");
	if($("#subMenu").is(":visible")){
		//$("#subMenu").slideToggle();
		$("#subMenu").hide();
	}
}

function showSubMenu(){	
	clearTimeout(subMenuTimeOutId);
	if(!$(".menu ul li").hasClass("current")){
		$("#subMenu").stop();
		$("#subMenu").css("height","");
		$("#subMenu").hide();
	}
	if(arguments[0]!=undefined){
		//$("#subMenuLeft").hide();
  	   // $("#subMenuRight").hide();
		$(".pcategory").hide();
		$(".menu ul li").removeClass("current");
		$(".subCategory,.category").hide();		
		$(".category li").prop("class","");
		$(".bg"+(arguments[0]+1)).addClass("current");
		if(arguments[1]==undefined){			
			$("#pcategory"+arguments[0]).show();
			$("#category"+arguments[0]).show().find("li:first-child").prop("class","current");
			setMenuSlider(arguments[0]);
			$("#subCategory"+arguments[0]+"_0").show();
		}else{				
  		   	$("#pcategory"+arguments[0]).show();
			$("#category"+arguments[0]).show().find("li:nth-child("+(arguments[1]+1)+")").prop("class","current");
			setMenuSlider(arguments[0]);
			
			$("#subCategory"+arguments[0]+"_"+arguments[1]).show(); 
		}
	}
	if(!$("#subMenu").is(":visible")){
		$("#subMenu").slideToggle(function(){
				
		});
	}
	$("#subMenu").css("height","");
}

function setMenuSlider(id){
	if(currentCategory!==id){
		currentCategory=id;
		if(cSlider!=null){
			cSlider.destroySlider();	
			cSlider=null;
		}
		if($('#category'+id).length>0){
			  cSlider=$('#category'+id).bxSlider({
				  pager:false,
				  adaptiveHeight:true,
				  maxSlides: 4,
                  minSlides: 1,
				  infiniteLoop: false,
				  slideWidth: 885,
				  touchEnabled: false
				});
			$("#subMenuLeft").unbind("click");
			$("#subMenuRight").unbind("click");
			$("#subMenuLeft").show();
			$("#subMenuRight").show();
			if($('#category'+id).find("li").length>4){
				  $("#subMenuLeft").click(function(){
						cSlider.goToPrevSlide();					 
											 });
				  $("#subMenuRight").click(function(){
						cSlider.goToNextSlide();					 
											 });
			}else{
				  $("#subMenuLeft").hide();
				  $("#subMenuRight").hide();
			}
		}else{
				  $("#subMenuLeft").hide();
				  $("#subMenuRight").hide();
			
		}
	}
}

function hideDialog(id){
	$("#"+id).fadeOut();
}
jQuery.fn.center = function () {
    this.css("position","absolute");
    this.css("top", Math.max(0, (($(window).height() - $(this).outerHeight()) / 2) + 
                                                $(window).scrollTop()) + "px");
    this.css("left", Math.max(0, (($(window).width() - $(this).outerWidth()) / 2) + 
                                                $(window).scrollLeft()) + "px");
    return this;
};