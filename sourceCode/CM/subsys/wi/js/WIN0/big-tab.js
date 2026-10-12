this.BigTab = function() {
    var bigTabChange = function(){        
        $(".btn_big_tab").click(function(){
            $("#frame_big_tab").removeClass("error_tab");
            $(".btn_big_tab").removeClass("on");
            $(".content_big_tab").hide();
            $(this).toggleClass("on");

            if($(this).hasClass("has_content")){
                var numTab = $(this).parent().index();
                $(this).parents(".list_big_tab").next(".detail_big_tab").find(".content_big_tab").eq(numTab).fadeIn();
            }
        });
    }
    $(document).ready(function() {
        bigTabChange();
    })
};
var bigTab = new BigTab();