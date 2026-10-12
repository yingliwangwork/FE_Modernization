var ltIE9 = (navigator.userAgent.replace(/^.*MSIE\s+(\d+\.\d+).*$/ig, '$1') * 1) < 9;
var isIE = (navigator.userAgent.replace(/^.*MSIE\s+(\d+\.\d+).*$/ig, '$1') * 1) <= 10;
var ieVer = navigator.userAgent.replace(/^.*MSIE\s+(\d+\.\d+).*$/ig, '$1') * 1;
var str = navigator.appVersion;

if(isIE){
    var ua = navigator.userAgent;
    var ie_compatibilityMode = false;

    // Detect whether or not the browser is IE
    var ieRegex = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
    if (ieRegex.exec(ua) == null)
        this.exception = "The user agent detected does not contai Internet Explorer.";

    // Get the current "emulated" version of IE
    var ie_renderVersion = parseFloat(RegExp.$1);
    var ie_version = ie_renderVersion;

    // Check the browser version with the rest of the agent string to detect compatibility mode
    if (ua.indexOf("Trident/6.0") > -1) {
        if (ua.indexOf("MSIE 7.0") > -1) {
            ie_compatibilityMode = true;
            ie_version = 10;                  // IE 10
        }
    } else if (ua.indexOf("Trident/5.0") > -1) {      
        if (ua.indexOf("MSIE 7.0") > -1) {
            ie_compatibilityMode = true;
            ie_version = 9;                   // IE 9
        }
    } else if (ua.indexOf("Trident/4.0") > -1) {
        if (ua.indexOf("MSIE 7.0") > -1) {
            ie_compatibilityMode = true;
            ie_version = 8;                   // IE 8
        }
    } else if (ua.indexOf("MSIE 7.0") > -1)
        ie_version = 7;                       // IE 7
    else
       ie_version = 6;                       // IE 6

    if(ie_version <8 && document.documentMode== undefined  || document.documentMode<8 ){
        ieVer = 7;
    }

    if(document.documentMode == undefined){
        ieVer = 7;
    }
}
//alert(document.documentMode+" "+ie_version);

if(!serviceHostName){var serviceHostName='https://www.cathaylife.com.tw';}//default value
if(!isIndexpage){var isIndexpage=($("#promotion-wrap").length>0 ? true : false);}

function loadCrossScript(scriptUrl){
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = scriptUrl;
    document.getElementsByTagName('head')[0].appendChild(script);
}

function doStscbb(type,name){
    setup_login_panel(type, name, isIndexpage);
}

function getServiceHostName(){
    //alert('1.serviceHostName:'+ serviceHostName);
    $.get('/life/wps/B2CWeb/hostName', function(data){
        //alert('data:'+ data);
        serviceHostName=$.trim(data);
        //alert('2.serviceHostName:'+ serviceHostName);
        getloginStatus();
    });

    //alert('3.serviceHostName:'+ serviceHostName);
    return false;
}

function buildLeftMenu(){

}
/************************/
/* setup login panel
/************************/
function getloginStatus(){
    var getScriptUrl = serviceHostName+'/bc/wps/B2CWeb/pages/login/loginSts.jsp?s='+Math.floor(Math.random()*12345678901234567890);
    loadCrossScript(getScriptUrl);

    //alert('4.serviceHostName:'+ serviceHostName);
    /*$.ajax({
         type: "get",
         //async: false,//default:true
         url: serviceHostName+'/life/wps/B2CWeb/loginStatus',
         dataType: "jsonp",
         jsonpCallback:'loginStatus',//"callback"變數的值，沒指定時，jQuery隨機產生
         success: function(res){
            setup_login_panel(res.identity[0],res.name[0], isIndexpage);
         },
         error: function(){
            //alert("fail! cant't get login status, use default status...");
            setup_login_panel('guest', '', isIndexpage);
         }
    });*/
}

function capLock(e){
    kc = e.keyCode?e.keyCode:e.which;
    sk = e.shiftKey?e.shiftKey:((kc == 16)?true:false);

    if(((kc >= 65 && kc <= 90) && !sk)||((kc >= 97 && kc <= 122) && sk))
        return true;
    else
        return false;
}

function setup_login_panel(a_type, a_name, a_isIndex){
    var html = '';
    switch(a_type){
        case 'guest':
            if(a_isIndex){
                html += '<section class="login"><h3>會員登入</h3>';
                html += '<form name="loginForm" id="loginForm" action="';
                html += serviceHostName;
                html += '/pkmslogin.form" method="post" target="_blank">';
                html += '<div class="input-prepend id">';
                html += '<span class="add-on"><i class="icon-user"></i></span>';
                html += '<input type="text" placeholder="請輸入身分證字號" name="username" id="username" class="i6_inptxt">';
                html += '</div>';

                html += '<div class="input-prepend password">';
                html += '<span class="add-on"><i class="icon-lock"></i></span>';
                html += '<input type="password" placeholder="請輸入密碼" id="password" name="password" value="" maxlength="12" class="i6_inppas" onkeypress="" >';
                //html += '<label id="info"></label>';

                html += '</div>';
                html += '<input type="hidden" name="login-form-type" value="pwd">';
                html += '<a class="login-btn" href="javascript:doLogin();">登入</a>';
                //html += '<input type="submit" value="登入">';

                html += '</form>';
                html += '<ul  class="help-link">';
                html += '<li style="float:left;"><a href="javascript:dispatch(\'forgetPwd\');">忘記密碼<i class="icon-caret-right"></i></a></li>';
                html += '<li style="float:right;"><a href="';
                html += serviceHostName;
                html += '/bc/wps/portal/B2C/Member/Register" target="_blank">會員註冊<i class="icon-caret-right"></i></a></li>';
                html += '</ul>';
                html += '</section>';

                html += '<form id="forgetpw" action="'
                html += serviceHostName;
                html += '/bc/wps/B2CWeb/stpServlet" method="post" target="_blank">';
                html += '<input type="hidden" name="type" id="type" value=""/>';
                html += '</form>';

                html += '<ul class="box-link">';
                html += '<li><a href="';
                html += serviceHostName;
                html += '/bc/CXBWeb/login?sys=BM_B2B" target="_blank"><i class="cathay-icon tools tools-10"></i>團險客戶網路服務</a></li>';
                html += '</ul>';           

            }else{
                  html += '<div class="block member login top">';
                html += '<dt class="active"><h3>會員登入</h3></dt>';
                html += '<dd style="display:none;">';
                html += '<form name="loginForm" id="loginForm" action="';
                html += serviceHostName;
                html += '/pkmslogin.form" method="post" target="_blank">';
                html += '<div class="input-prepend id">';
                html += '<span class="add-on"><i class="icon-user"></i></span>';

                html += '<input type="text" placeholder="請輸入身分證字號" name="username" id="username" class="i6_inptxt">';
                html += '</div>';
                html += '<div class="input-prepend password">';
                html += '<span class="add-on"><i class="icon-lock"></i></span>';
                html += '<input type="password" placeholder="請輸入密碼" id="password" name="password" value="" maxlength="12" class="i6_inppas" onkeypress="">';
                html += '</div>';

                html += '<input type="hidden" name="login-form-type" value="pwd">';
                html += '<a class="login-btn" href="javascript:doLogin();">登入</a>';

                html += '</form>';
                html += '<ul  class="help-link">';
                html += '<li style="float:left;" class="slvzr-first-child"><a href="javascript:dispatch(\'forgetPwd\');">忘記密碼<i class="icon-caret-right"></i></a></li>';
                html += '<li style="float:right;"><a href="';
                html += serviceHostName;
                html += '/bc/wps/portal/B2C/Member/Register" target="_blank">會員註冊<i class="icon-caret-right"></i></a></li>';
                html += '</ul>';

                html += '<form id="forgetpw" action="/wps/B2CWeb/stpServlet" method="post" target="_blank">';
                html += '<input type="hidden" name="type" id="type" value=""/>';
                html += '</form>';

                html += '</dd>';
                html += '</div>';
                if(ltIE9){
                    html += '<ul class="box box-link" style="float:left;width:178px;border-top:0px;">';
                }else{
                    html += '<ul class="box box-link" style="float:left;width:180px;border-top:0px;">';
                }

                html += '<li><a href="';
                html += serviceHostName;
                html += '/bc/CXBWeb/login?sys=BM_B2B" target="_blank"><i class="cathay-icon tools tools-10"></i>團險客戶網路服務</a></li>';
                html += '</ul>';        
            }
        break;
        case 'member':
            if(a_isIndex){
                html += '<section class="logout" >';
                html += '<h3>會員專區</h3>';
                html += '<div class="msg">親愛的';
                html += a_name;
                html += '  您好</div>';

                html += '<ul class="help-link">';
                html += '<li><a href="javascript:goMemberHome();"><i class="cathay-icon help-0"></i>個人重要通知<i class="icon-caret-right"></i></a></li>';

                html += '<li><a href="javascript:goMemberHome(\'Policy\');"><i class="cathay-icon help-1"></i>我的保單帳戶<i class="icon-caret-right"></i></a></li>';
                
                html += '<li><a href="/web/ext/pages/service/service/eservice/ser_epersonal.html"><i class="cathay-icon help-3"></i>更多網路會員服務<i class="icon-caret-right"></i></a></li>';
                html += '</ul>';
                
                html += '<a class="logout-btn" href="javascript:doLogout();">登出</a>';

                html += '</section>';
                
                html += '<ul class="box-link">';
                html += '<li><a href="';
                html += serviceHostName;
                html += '/bc/CXBWeb/login?sys=BM_B2B" target="_blank"><i class="cathay-icon tools tools-10"></i>團險客戶網路服務</a></li>';
                html += '</ul>';

            }else{
                html += '<div class="block member logout top">';
                html += '<dt>';
                html += '<h3>會員專區</h3>';
                html += '<div class="msg">';
                html += '<div>親愛的'
                html += a_name;
                html += '  您好</div>';
                html += '</div>';
                html += '</dt>';
                html += '<dd style="display:none;">';
                html += '<ul class="help-link">';
                html += '<li><a href="javascript:goMemberHome();"><i class="cathay-icon help-0"></i>個人重要通知<i class="icon-caret-right"></i></a></li>';
                html += '<li><a href="javascript:goMemberHome(\'Policy\');"><i class="cathay-icon help-1"></i>我的保單帳戶<i class="icon-caret-right"></i></a></li>';
                html += '<li><a href="/web/ext/pages/service/service/eservice/ser_epersonal.html"><i class="cathay-icon help-3"></i>更多網路會員服務<i class="icon-caret-right"></i></a></li>';
                html += '</ul>';

                html += '<a class="logout-btn" href="javascript:doLogout();">登出</a>';
                html += '</dd>';
                html += '<div class="func">';
                html += '<div class="more"><a href="javascript:" class="active">更多服務<i class="icon-caret-down"></i></a></div>';
                html += '<div class="less"><a href="javascript:">隱藏服務<i class="icon-caret-up"></i></a></div>';
                html += '</div>';
                html += '</div>';
            }
        break;
    }

    var password_hint = '您現在輸入的是 大寫模式!';
    if(a_isIndex && a_type=='guest'){
        html += '<div id="member-form-hint">'+password_hint+'</div>';
    }
    else{
        html += '<div id="member-form-hint">'+password_hint+'</div>';
    }

    $("#member_panel").html(html);
    $("#member_panel a").mouseover(function(){
        $(this).removeClass('slvzr-hover').addClass('slvzr-hover');
    })

    $("#member_panel a").mouseout(function(){
        $(this).removeClass('slvzr-hover');
    })

    $('#member_panel input[type=password]').keypress(function(e) { 
        if (capLock(e)){
            $("#member_panel #member-form-hint").show();
        }else{
            $("#member_panel #member-form-hint").hide();
        }
    });

    $('#member_panel input[type=password]').blur(function(e) { 
            $("#member_panel #member-form-hint").hide();
    });

    if($('.member dt').length>0){
     $('.member.login dt').click(function(){
        $(this).next('dd').slideToggle();
        $(this).toggleClass('active');
      })      

      $('.member.logout .func .more a').click(function(){
          $(this).parent().parent().find('a').addClass('active');
          $(this).removeClass('active');
        $(this).parent().parent().prev().slideDown("normal",function(){
            $(this).prev().addClass('active');
        });
      })

      $('.member.logout .func .less a').click(function(){
          $(this).parent().parent().find('a').addClass('active');
          $(this).removeClass('active');
            $(this).parent().parent().prev().slideUp("normal",function(){
                $(this).prev().removeClass('active');
            });
      })
    }

    $('form#loginForm input#password').keydown(function (e) {
        if (e.keyCode == 13) {
            doLogin();
            return false;
        }
    });
}

$(function(){

    /************************/
    /* setup main menu
    /************************/
    $("ul.first-level").addClass('column-' + $("ul.first-level>li").not('.border').length);
    $("ul.first-level>li").each(function () {
        if (!$(this).hasClass('.border')) {
            var len = Math.ceil($(this).find(".sf-sub li").length / 3);
            $(this).find(".sf-mega").addClass('column-' + len);
            if ($(this).find('figure.menu-banner').length > 0) {
                $(this).find(".sf-mega").addClass('hasBanner');
            }

            if ($(this).find(".sf-sub").length > 0) {
                var $ul = $(this).find(".sf-sub");
                var $lis = $(this).find(".sf-sub").find('li');
                var length = $lis.length;
                //pull them off

                //make your new ul, to put the dom elements in
                for (var i = 0; i < len - 1; i++) {
                    //console.log(i*3,3);
                    var $last6lis = $($lis.splice(0, 3)).remove();

                    // console.log($last6lis);
                    var $newUl = $('<ul class="sub column-' + i + '"></ul>');
                    $ul.before($newUl.html($last6lis));
                }

                $ul.addClass('column-' + len);
                $ul.removeClass('sf-sub');
                $ul.addClass('sub');
                //html+='</ul>';
            }
        }

        if ($(this).find('>a').length > 0) {
            var menu_w = $(this).outerWidth();
            var submenu_w = $(this).find(".sf-mega").outerWidth(true);
            var diff_menu_submenu_w = submenu_w - menu_w;
            var pos_x = $(this).offset().left - $(this).parent().offset().left;

            $(this).find(".sf-mega").css('left', -1);
            if (submenu_w + pos_x > $("#sub-menu .center").width()) {
                $(this).find(".sf-mega").css('right', -2).css('left', 'auto');
                if (diff_menu_submenu_w > pos_x) {
                    if (diff_menu_submenu_w / 2 + pos_x + menu_w > $("#sub-menu .center").width()) {
                        var add = diff_menu_submenu_w / 2 + pos_x + menu_w - $("#sub-menu .center").width();
                        $(this).find(".sf-mega").css('left', menu_w / 2 - submenu_w / 2 - add);
                    } else if (pos_x - diff_menu_submenu_w / 2 < 0) {
                        var add = diff_menu_submenu_w - pos_x;
                        $(this).find(".sf-mega").css('left', -pos_x + 1);
                    } else {
                        $(this).find(".sf-mega").css('left', menu_w / 2 - submenu_w / 2);
                    }
                }
            }
        }
    })

    $('#sub-menu').superfish({ speedOut: 0, delay: 300, speed: 'fast' });


    /************************/
    /* footer
    /************************/
    $(".back-to-top a").click(function () {
        TweenMax.to(window, .5, { scrollTo: { y: 0, ease: Sine.easeOut } });
    })

    $("#sitemap-open").click(function () {
        $(this).toggleClass('ed');
        if ($('.href-list').is(':not(:visible)')) {
            $('.href-list').slideDown(750);
        }else{
            $('.sitemap .href-list').slideUp(350);
        }
    });

    if (ltIE9) {
        $("html").removeClass('lt-ie9').addClass('lt-ie9');
        $("#sub-menu .first-level li .sf-mega").each(function (i, d) {
            d = $(d);
            var w = 1 + d.parent().width() + d.parent().css('padding-left').replace(/px|inherit|auto/, '') * 1 + d.parent().css('padding-right').replace(/px|inherit|auto/, '') * 1;
            var i = $("<i class='border-mask' />");
            i.width(w);
            i.appendTo(d.parent())
        });
    }

    /*if is index page*/
    if($("#promotion-wrap").length>0) {
        //add group banner
        var iframe_group_banner = '<div class="iframe-center"><iframe id="groupbanner" src="https://www.cathayholdings.com/holdings/Info/Default.aspx?caller=life" frameborder="0" style="margin: 0px;overflow:hidden;"  scrolling="no" width="940" height="200"></iframe></div>';
        $("#footer").prepend(iframe_group_banner);

        //close sitemap
        $("#footer .sitemap .index-tab .href-list").hide();
        $("#footer #sitemap-open").removeClass("ed");

        //set index page flag
        var isIndexpage = true;

    } else {
        $('body').addClass('width-1000');
        $('body').addClass('content');
        //set index page flag
        var isIndexpage = false;
    }

    /** for demo **/
    $('#member_panel a.member').click(function(){
        if($("#promotion-wrap").length>0) {
            //setup_login_panel('member',true);
            setup_login_panel('member', '會員', true);
        } else {
            //setup_login_panel('member',false);
            setup_login_panel('member', '會員', false);
        }
        //setup_login_panel('member', '會員', isIndexpage);
    })

    $('#member_panel a.guest').click(function(){
        if($("#promotion-wrap").length>0) {
            // setup_login_panel('guest',true);
            setup_login_panel('guest', '人客', true);
        } else {
            // setup_login_panel('guest',false);
            setup_login_panel('guest', '人客', false);
        }
        //setup_login_panel('guest', '人客', isIndexpage);
    })

    /** for demo end **/
    //getServiceHostName();
});