this.Main = function() {
    var init = function(){
	
		$("#container").css("padding-bottom",$(".sticky").height());
		
         // uniform
        $("select, input, textarea").uniform();

        $("input[type='date'], input[type='time']").bind("click",function(){
            $(this).removeClass('placeholderclass');
        });

        // input text yellow hint
        $(".has_hint").focus(function(){
            $(this).parent("label").parent("div").addClass("hint");
        });
        $(".has_hint").focusout(function(){
            $(this).parent("label").parent("div").removeClass("hint");
        });


        // lightbox
        $(".fancybox").fancybox({
            padding: 0,
            width       : '100%',
            height      : 'auto',
            autoSize    : false,
            scrolling: 'no',
            fitToView: false,

        });
                
        $(".btn_fancybox_close, .btn_lb_close").click(function(){
            $.fancybox.close(); 
            return false;
        });
    }
    init();
    $(document).ready(function() {
        init();
    })
};
var main = new Main();

$(function(){
    var o = $('#member_btn');
    if( !o[0] ) return;
    
    $('#member_content').hide();
    
    $('#member_btn').on('click', function(){
        var t = this;
        $('#member_content').fadeToggle(150);
    });
    if( $('html.ie8')[0] )
    $('#member_btn').css('overflow','visible').children('b').css('height','auto');
});

$(function(){
    var o = $('.collapse_title');
    if( !o[0] ) return;
    
    $('.collapse_content').hide();
    
    $('.collapse_title').on('click', function(){
		$(this).parent().find('.icon_collapse').toggleClass("close");
        var t = this;
        $(this).next('.collapse_content').slideToggle(150);
    });
    if( $('html.ie8')[0] )
        $('.collapse_title').css('overflow','visible').children('b').css('height','auto');
    
    $('.collapse_title_inside').on('click', function(){
        $(this).parent().prev('.collapse_title').trigger('click');
    });
});

$(document).ready(function(){
	//smooth scroll
	function scrollToAnchor(aid){
		var aTag = $("a[name='"+ aid +"']");
        if(aTag.length==0)
            return;
		$('html,body').animate({scrollTop: aTag.offset().top},'slow');
	}
	$("a").click(function() {
		var href = $(this).attr('href').replace('#', '');
        if(href!="javascript:;")
		  scrollToAnchor(href);
	});
});

$(window).load(function() {	
	$('.flexslider').flexslider({
        controlNav: true,
        directionNav: false,
		slideshowSpeed: 7000,
		animationSpeed: 600,
		animation: "fade",
	});
});