function OpenPDFLightBox(Url,Title, Width, Height) {
    Width = (typeof Width !== 'undefined') ? Width : window.innerWidth * 0.8;
    Height = (typeof Height !== 'undefined') ? Height : window.innerHeight * 0.8;
    Title = (typeof Title !== 'undefined') ? Title : "";

    var offsetW = (window.innerWidth - Width) / 2;
    var offsetH = (window.innerHeight - Height) / 2;


    $(".lightbox-outerbox").css({ 'left': offsetW, 'width': Width, 'top': offsetH, 'height': Height });
    $(".lightbox-box-content").css({ 'height': Height - 35 });

    $(".lightbox-mask,.lightbox-box-close").unbind("click").click(function () {
        ClosePDFLightBox();
    });

    $(".lightbox-box-ifrmae").attr("src", Url);

    $("html").addClass("overlay-lock");
    $(".lightbox-box-title").text(Title);
    $(".lightbox-mask,.lightbox-outerbox").fadeIn();
}

function ClosePDFLightBox() {
    $(".lightbox-mask,.lightbox-outerbox").fadeOut();
    $("html").removeClass("overlay-lock");
    $(".lightbox-box-title").text("");
}