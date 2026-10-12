function InitButton() {
    var _diffX = 20;

    $("#abgne_float_ad").css({
        'top':$(document).height(),
        'left': $(document).width() - $("#abgne_float_ad").width() - _diffX
    }).show();

    $(window).scroll(function () {
        MoveButton();
    });

    $(window).resize(function () {
        MoveButton();
    });

    MoveButton();
}

function MoveButton() {
    var _diffX = 20;
    var _diffY = 20;
    
    $("#abgne_float_ad").stop().animate({
        top: $(document).scrollTop() + window.innerHeight - $("#abgne_float_ad").height() - _diffY,
        left: $(document).scrollLeft() + window.innerWidth - $("#abgne_float_ad").width() - _diffX
    },1000);
}