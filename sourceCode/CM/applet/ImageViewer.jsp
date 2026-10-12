<%@page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%><!doctype html>
<%@taglib prefix='c' uri='http://java.sun.com/jsp/jstl/core'%>
<% 
pageContext.setAttribute("contextPath", request.getContextPath());
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);
%>
<html>
<head>
    <meta charset="big5">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <meta name="google" content="notranslate">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
    <title>IMAGE VIEWER</title>
    <style>
        body{
            font-family: 'Microsoft JhengHei', 'Meiryo', 'Arial', 'Arial Unicode MS', 'Helvetica', 'sans-serif', 'Verdana', 'Trebuchet MS','PMingLiU','MingLiU';
            padding: 0px;
            margin: 0px;
            padding-top: 65px;
            background-color: #525659;
            user-select: none; 
            -moz-user-select: none;  /* for Firefox */ 
            -webkit-user-select: none;   /* for Chrome */
        }

        input, button{
            font-family: 'Microsoft JhengHei', 'Meiryo', 'Arial', 'Arial Unicode MS', 'Helvetica', 'sans-serif', 'Verdana', 'Trebuchet MS','PMingLiU','MingLiU';
        }

        #size-dect {
            position: absolute;
            visibility: hidden;
            top: 0px;
            left: 0px;
            width: 100%;
            height: 100%;
            z-index: -1;
        }

        #size-dect.cover-active{
            position: fixed;
            visibility: visible;
            background-color: rgba( 0 , 0,0,0.3);
            font-size: 14pt;
            text-align: center;
            padding-top: 100px;
            color: White;
            z-index: 10;
        }

        #header-bar {
            position: fixed;
            top: 0px;
            left: 0px;
            width: 100%;
            padding: 0 20px;
            background-color: #323639;
            border-bottom: 1px solid #616161;
            text-align: center;
            color: white;
            line-height: 65px;
            box-shadow:  0px 0px 2px #333333;
        }

        #fileName{
            float: left;
        }

        #page_num{
            background-color: #323639;
            background-color: transparent;
            border: 2px solid #323639;
            border-radius: 3px;
            color: white;
            text-align: right;
            font-size: 20px;
            padding: 4px 2px;
            margin: -8px 2px -8px 2px;
            width: 50px;
        }

        #page_num:hover, #page_num:focus{
            border: 2px solid #616161;
        }
        
        .page_ctrl{
        	cursor: pointer;
        }
        
        .page_ctrl:hover{
        	color: #F90;
        }

        #download{
            float: right;
            margin-top: 19px;
            margin-right: 35px;
        }

        .btn{
            background-color: #323639;
            background-color: transparent;
            border: 2px solid #616161;
            border-radius: 3px;
            color: white;
            text-align: center;
            line-height: 25px;
            padding: 0px 10px;
            cursor: pointer;
        }

        #download:hover{
            background-color: #FFF;
            color: #616161;
        }

        #ctrls {
            position: fixed;
            bottom: 40px;
            right: 40px;
        }

        #ctrls button {
            margin-top: 10px;
            width: 36px;
            height: 36px;
            color: #616161;
            border-radius: 18px;
            border: none;
            background-color: #F2F2F2;
            line-height: 36px;
            box-shadow:  0px 1px 2px #B1B1B1;
            cursor: pointer;
            font-size: 30pt;
            padding: 0px;
        }

        #fit{
            position: relative;
            margin-bottom: 20px;
        }

        #fit span{
            position: absolute;
            font-size: 10pt;
            font-weight: 800;
            line-height: 18px;
        }

        #ctrls button:focus {
            border: none;
            background-color: #818181;
        }

        #pages-container{
            text-align: center;
        }

        .the-page {
            margin: 5px auto;
            border: 1px solid #000;
            display: block;
        }

        #msg {
            position: fixed;
            top: 0px;
            left: 0px;
            width: 100%;
            height: 100%;
            text-align: center;
            padding-top: 10%;
            z-index: 20;
            background-color: rgba( 0 , 0,0,0.3);
            display: none;
        }

        #msg-box {
            display: inline-block;
            min-width: 500px;
            max-width: 90%;
            background-color: #494949;
            border: 1px solid #000;
            border-radius: 3px;
            color: #FFF;
            box-shadow: 0px 0px 1px #FFF;
            padding: 5px;
        }

        #msg-box hr {
            border: 0px solid #000;
            border-width: 1px 0 0 0;
            box-shadow: 0px 0px 1px #FFF;
            margin: 10px 0;
        }

        #msg-box-title {
            font-size: 1.2em;
            font-weight: 150;
        }

        #msg-box-content {
            overflow: hidden;
            text-align: left;
        }
    </style>
    <style type="text/css" media="print">
        BODY {display:none;visibility:hidden;}
    </style>
</head>

<body unselectable="on">
	<div id="size-dect">Loading...<br>Please wait a moment.</div>
	
	<div id="header-bar">
		<c:if test="${ENABLE_DOWNLOAD}">
		<button type="button" id="download" class="btn">下載</button>
		</c:if>    
		<span id="fileName">${fileName}</span>
	</div>

    <div id="pages-container"></div>

    <div id="ctrls">
        <button type="button" id="fit" title="依頁面大小自動調整">
            <span style="top:3px; left:7px;">&#x2518;</span>
            <span style="top:3px; right:7px;">&#x2514;</span>
            <span style="bottom:3px; left:7px;">&#x2510;</span>
            <span style="bottom:3px; right:7px;">&#x250C;</span>
        </button><br>
        <button type="button" id="zoomin" title="放大">&#x002B;</button><br>
        <button type="button" id="zoomout" title="縮小">&#x2212;</button>
    </div>


    <div id="msg">
        <div id="msg-box">
            <div id="msg-box-title">Error</div>
            <hr>
            <div id="msg-box-content">Content</div>
            <hr>
            <div id="msg-box-buttons">
                <button type="button" class="btn" id="msg-box-confirm">確定</button>
            </div>
        </div>
    </div>

	<script>
        var url = '${contextPath}/FileDownload?downloadFileFullPath=${filePath}&downloadFileName=${encryptMarkedFileName}&lts=${lts}';
        
        var sizeDect = document.getElementById('size-dect');
        var container = document.getElementById('pages-container');

        var defaultWidth = Math.min(sizeDect.offsetWidth-20 , 800);

        var pdfDoc = null;
        var zoom = defaultWidth;

        var pageScrollTop = [];

        var loading_cnt = 0;

        var img = new Image();

         

    //drawing of the test image - img1
    img.onload = function () {

        var ppn = img.height / img.width;
        var _height = parseInt((zoom * ppn) * 100, 10) / 100;

        var canvas = document.createElement('canvas');
        canvas.className = 'the-page';
        canvas.setAttribute('data-ppn',ppn);
        canvas.oncontextmenu = function(e){ e.stopPropagation(); return false; };
        canvas.style.width = zoom + 'px';
        canvas.style.height = _height + 'px';
        canvas.width = img.width;
        canvas.height = img.height;
        container.appendChild(canvas);
        var ctx = canvas.getContext("2d");
        ctx.fillStyle = "rgba(255, 255, 255, 1)";
        ctx.fillRect(0, 0, img.width , img.height );
        ctx.drawImage(img, 0, 0, img.width , img.height );

        pageScrollTop[0] = canvas.offsetTop;

        sizeDect.className = "";
    };

    sizeDect.className = "cover-active";
    img.src = url;
        
        var fit_mood = false;
        function doFit(){
            var pages = document.getElementsByTagName('canvas');
            if(fit_mood == "height"){
                zoom = sizeDect.offsetWidth-20;
                fit_mood = "width";
            }else if(fit_mood == "width"){
                zoom = defaultWidth;
                fit_mood = false;
            }else{
                var max_ppn = 0;
                for(var i = 0 ; i < pages.length ; i++){
                    max_ppn = Math.max( max_ppn , parseFloat(pages[i].getAttribute('data-ppn')));
                }
                var _height = Math.max( 100 , sizeDect.offsetHeight - 75) ;
                zoom = parseInt((_height / max_ppn) * 100, 10) / 100;
                fit_mood = "height";
            }
            for(var i = 0 ; i < pages.length ; i++){
                var ppn = parseFloat(pages[i].getAttribute('data-ppn'));
                var _height = parseInt((zoom * ppn) * 100, 10) / 100;
                pages[i].style.height = _height + 'px';
                pages[i].style.width = zoom + 'px';
                pageScrollTop[i] = pages[i].offsetTop;
            }
        }
        document.getElementById('fit').addEventListener('click', doFit);

        function doZoom(x) {
            fit_mood = false;
            zoom = parseInt(zoom * x * 100)/100;
            var pages = document.getElementsByTagName('canvas');
            for(var i = 0 ; i < pages.length ; i++){
                var ppn = parseFloat(pages[i].getAttribute('data-ppn'));
                var _height = parseInt((zoom * ppn) * 100, 10) / 100;
                pages[i].style.height = _height + 'px';
                pages[i].style.width = zoom + 'px';
                pageScrollTop[i] = pages[i].offsetTop;
            }
        }
        document.getElementById('zoomin').addEventListener('click', function(e){ doZoom(1.1); });
        document.getElementById('zoomout').addEventListener('click', function(e){ doZoom(0.9); });

        var btns = document.getElementById('ctrls').getElementsByTagName('button');
        for(var i = 0 ; i < btns.length ; i++ ){
            btns[i].tabIndex = -1;
            btns[i].addEventListener('focus',function(e){ setTimeout( function(){ e.target.blur(); } , 250); });
        }


        document.body.addEventListener('resize' , function(){ fit_mood = false; });

        document.getElementById('msg-box-confirm').addEventListener('click',function(e){
        history.back();
        });

        document.body.oncontextmenu = function(e){ e.stopPropagation(); return false; };
         
       	
    </script>
    
    <c:if test="${ENABLE_DOWNLOAD}">
    <script type='text/javascript' src='${contextPath}/html/CM/js/ajax/prototype.js'></script>
    <script type='text/javascript' src="${contextPath}/html/CM/js/ajax/CSRUtil.js"></script>
	<script type='text/javascript' src="${contextPath}/html/CM/js/RPTUtil.js"></script>
    <script>	    	
		document.getElementById('download').addEventListener('click', function() {	
			<c:forEach items='${URL_LIST}' var='obj'>
			var isContinue = false;
			new Ajax.Request( '${obj.url}',
			{
				asynchronous : false,
				parameters: { actionParam : '${obj.parameters}'},
				onSuccess: function( response ) {
					var resp = response.responseJSON;
					if(CSRUtil.isSuccess(resp)){
						isContinue = true;									
					}
				}
			});
			if(!isContinue){ return; }		
			</c:forEach>
			RPTUtil.download({
				'downloadFileName': '${encryptMarkedFileName}',
				'downloadFileFullPath': '${encryptMarkedFileFullPath}'
			});
		});
	</script>
	</c:if>
</body>

</html>