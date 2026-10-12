<%@page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%><!doctype HTML>
<%@taglib prefix='c' uri='http://java.sun.com/jsp/jstl/core'%>
<%@ taglib prefix = "fn" uri = "http://java.sun.com/jsp/jstl/functions" %>
<% pageContext.setAttribute("contextPath", request.getContextPath()); %>
<html>
<head>
    <meta charset="big5">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <meta name="google" content="notranslate">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>FILE VIEWER</title>
    <style>
        body{
            font-family: 'MingLiU', 'Microsoft JhengHei', 'Meiryo', 'Arial', 'Arial Unicode MS', 'Helvetica', 'sans-serif', 'Verdana', 'Trebuchet MS', 'PMingLiU';
            padding: 0px;
            margin: 0px;
            padding-top: 65px;
            user-select: none; 
            background-color: #525659;
            -webkit-user-select: none;
			-khtml-user-select: none;
			-moz-user-select: none;
			-o-user-select: none;
			user-select: none;
            overflow-y: scroll !important;
        }

		input[type="text"],
		input[type="number"],
		button{
			font-family: 'Microsoft JhengHei';
		} 

        header{
        	position: fixed;
		    top: 0px;
		    left: 0px;
		    width: 100%;
			height: 65px;
			z-index:3;

		    display: flex;
		    flex-direction: row;
		    flex-wrap: nowrap;
		    align-items: center;
		    
			background-color: #323639;
		    border-bottom: 1px solid #616161;
		    box-shadow: 0px 0px 2px #333333;
		    
		}
		
		header .crtls-group{
			height: 34px;
			margin: 0;
        	padding: 0;
        	display: inline-block;
        	background-color: transparent;
		    border: 2px solid #616161;
		    border-radius: 10px;
		    overflow: hidden;
		    color: #909090;
			
		}

		header input[type="text"],
		header input[type="number"]{
			height: 30px;
			margin: 0;
			padding: 0;
			color: white;
			border: none;
			outline : none;
			background-color: transparent;
		}

		header button{
			height: 34px;
			margin: 0;
			padding: 0 10px;
			color: #909090;
			display: inline-block;
			border: none;
			border-spacing: 0;
			border-collapse: collapse;
			outline : none;
			background-color: transparent;
			cursor: pointer;
			
		}

		header button.lborder{
			border-left: 2px solid #616161;
		}

		header button.rborder{
			border-right: 2px solid #616161;
		}

		header button:hover,
		header button:focus{
			background-color: #616161;
			color: #FFF;
			outline : none;
		}


        header div#file_name{
			flex-grow : 1;
        	text-align: left;
        	padding-left: 20px;
			color: white;
			font-size: 18px;
        }
		header div#line_ctrls{
			white-space: nowrap;
		}

		header div#float-right-ctrls{
			flex-grow : 1;
			text-align: right;
			padding-right: 10px;
		}
        
        header div#line_ctrls input#pageNoInput{
        	font-size: 18px;
			text-align: right;
			margin-right: 3px;
			max-width: 80px;
		}

		header div#line_ctrls button{
        	font-size: 18px;
		}

		header div#line_ctrls button#str,
		header div#line_ctrls button#end{
        	display:none;
		}

		header div#line_ctrls:hover button#str,
		header div#line_ctrls:hover button#end{
        	display:inline-block;
		}

		header div#fontSize{
			padding-left: 3px;
		}
		
		header div#fontSize button{
			display: none;
		}
		
		header div#fontSize button.active,
		header div#fontSize:hover button{
			display: inline;
		}
		
		header div#fontSize:hover button.active{
			color: #FFF;
			font-weight: bold;
		}

		header div#search{
			padding-left: 5px;
			margin-left: 5px;
		}
		
		header div#search input#searchString{
			width: 70px;
		}
		
		header div#search input#searchString:focus{
			width: 150px;
		}
		
		header div#search span#searchResult{
			background-color: yellow;
			color: #323639;
			padding: 2px 4px;
			border-radius: 3px;
			font-size: 12px;
		}
		
		article{
			position: relative;
			margin: 10px;
			padding-bottom: 40px;
			overflow-x : hidden;
			border: 1px solid #000;
			background: #FFF; 
			min-height: 700px;
		}
		
		article #waterMark{
		    text-align: center;
		    width: 100%;
		    height: 100%;
		    font-size: 70px;
		    color: rgba(200,200,255,0.7);
		    position: absolute;
		    z-index: 0;
		    overflow: hidden;
	    }
	    
	    article #waterMark div{
	    	white-space: nowrap;
	    	transform: rotate(-45deg);
	    	padding: 250px 10px;
	    }
		
		article #y-scroll{
			position: fixed;
			bottom: 10px;
			left: 0;
			text-align: center;
			width: 100%;
			z-index: 2;
		}
		
		article.no-y-scroll{
			padding-bottom: 0px;
		}
		
		article.no-y-scroll #y-scroll{
			display:none;
		}
		
		article input[type="range"]{
		  -webkit-appearance: none;
		  overflow:hidden;     /* 限定範圍 */
		  width:95%;
		  height:24px;
		  padding: 3px;
		  outline : none;      /* 避免點選會有藍線或虛線 */
		  border-radius: 15px;
		  background-color: rgba(0,0,0,0.5);
		}
		article input[type=range]:focus {
		  outline: none;
		}
		article input[type="range"]::-webkit-slider-thumb{
		  -webkit-appearance: none;
		  position: relative;    /* 設為相對位置，為了前後區塊的絕對位置而設定 */
		  width:52px;
		  height:24px;
		  background-color:rgba(255,255,255,0.7);
		  border-radius:12px;
		  border: 1px solid #FFF;
		  cursor: pointer;
		}
		article input[type=range]:focus::-webkit-slider-runnable-track {
  			background: transparent;
		}
        
		article input[type=range]::-moz-range-track {
			width: 100%;
			height:24px;
			cursor: pointer;
			box-shadow: none;
			background-color: rgba(0,0,0,0.5);
			border-radius: 15px;
			border: none;
		}
		article input[type=range]::-moz-range-thumb {
			box-shadow: none;
			border: 1px solid #FFF;
			width:52px;
		  	height:24px;
			border-radius: 12px;
			background-color:rgba(255,255,255,0.5);
			cursor: pointer;
		}

		article input[type=range]::-ms-fill-lower,
		article input[type=range]::-ms-fill-upper {
			background: transparent;
			border: none;
			border-radius: none;
			box-shadow: none;
		}

		article input[type=range]::-ms-thumb {
			margin-top: 1px;
			box-shadow: none;
			border: 1px solid #FFF;
			height: 22px;
			width: 52px;
			border-radius: 12px;
			background-color:rgba(255,255,255,0.5);
			cursor: pointer;
		}
		article input[type=range]::-ms-track,
		article input[type=range]::-ms-ticks-before,
        article input[type=range]::-ms-ticks-after{
			visibility: hidden;
			display: hidden;
		}

        .dataTable {
        	position: relative;
        	z-index: 1;
        	min-width: 100%;
			line-height: 1.1em;
        	font-size: 0.9rem;
        }
        
        .dataTable td{
        	vertical-align: middle;
        	white-space: nowrap;
        }
        
        .dataTable .lineNo{
        	width: 35px;
        	background-color: #DDD;
        	padding: 0 5px 0 10px;
        	text-align: right;
        }
        
        .dataTable .content{
        	overflow: hidden;
		}
		
		.dataTable .content p{
			display: inline;
		}
		
		.dataTable .content p.highlight{
        	background-color: rgba(255,255,0,.5);
		}
        
        .dataTable tr:hover td.lineNo{
        	color: #F60;
        }
        
        .dataTable tr.searchMatch td.lineNo{
        	background-color: #FF0;
        }
        
        .dataTable tr:hover td.content{
        	background: lightblue;
        }
        
        .dataTable tr.focus{
        	background-color: rgba( 255,0,0,0.15);
        }
        
        .dataTable tr.focus .lineNo{
        	color: red;
        	font-weight: bold;
        }
        
        @media only screen and (max-width: 700px ){
        	#file_name,
        	#fontSize,
        	#str, #end{
        		display:none !important;
        	}
        	header div#line_ctrls{
        		margin-left: 10px;
        		font-size:0.7em;
        		white-space: nowrap;
        	}
        	header div#search{
        		white-space: nowrap;
        	}
        	header div#search input#searchString,
        	header div#search input#searchString:focus{
        		width: 40px;
        	}
        	
        	article #waterMark div{
	    		transform: rotate(-75deg);
	    		padding: 350px 10px;
	    	}
	    	.dataTable{
	    		font-size: 1.2em;
	    	}
        }
        
	</style>
	
	<style type="text/css" id="thumb_style">
        
    </style>
    
    <style type="text/css" id="content_style">
        
    </style>
	
    <style type="text/css" media="print">
        BODY {display:none;visibility:hidden;}
    </style>
</head>

<body unselectable="on">
	<header>
		<div id="file_name">${file_name}</div>
		<div id="line_ctrls" class="crtls-group">
			<c:if test="${lineShift > 0 }">
			<button type="button" id="str"  class="rborder" data-goto="0"  title="move to start">&#8676;</button><button type="button" id="prev" class="rborder" data-goto="${lineShift < readLines ? 0 : lineShift-readLines}"  title="previous ${readLines} lines">&#8592;</button>
			</c:if>
			<input type="number" id="pageNoInput" min="1" max="${lineCounter + 1}" value="${lineShift+1}" data-dafault="${lineShift+1}">
			/&nbsp;&nbsp;${lineCounter + 1}&nbsp;&nbsp;
			<c:if test="${lineShift+readLines <= lineCounter }">
			<button type="button" id="next" class="lborder" data-goto="${lineShift+readLines}" title="next ${readLines} lines">&#8594;</button><button type="button" id="end"  class="lborder" data-goto="${lineCounter-readLines + 1}" title="move to end">&#8677;</button>
			</c:if>
		</div>
		<div id="float-right-ctrls">
			<div id="fontSize" class="crtls-group">
				&nbsp;size&nbsp;
				<button type="button" data-rate="0.9" class="active lborder">1X</button><button type="button" data-rate="1.2" class="lborder">1.5X</button><button type="button" data-rate="1.5" class="lborder">2X</button>
			</div>
			<div id="search" class="crtls-group">
				<input id="searchString" type="text" value="${searchString}"/>
				<c:if test="${not empty searchResult}">
					<span id="searchResult" title="${searchResult} result(s) in this file." data-searchString="${searchString}" data-searchResult="${searchResult}">${searchResult}</span>
				</c:if>
				<button type="button" id="searchBtn" class="lborder">搜尋</button>
			</div>
		</div>
	</header>
	<article>
		<div id="waterMark">
			<c:forEach begin="0" end="${readLines}" step="11" varStatus="stat"><div data-seq="${stat.index}">${waterMark}</div>
			</c:forEach>
		</div>
		<div id="y-scroll">
			<input id="y-slider" type="range" value="0">
			<!--  button id="totop" type="button">&#8679;</button>  -->
		</div>
		<table class="dataTable">
		<c:forEach items ="${dataList}" var="item" varStatus="status">
			<tr>
				<c:choose><c:when test="${onlyDisplaySearchResult}">
					<c:set var="lineLength" value="${fn:length(item)}" />
					<td class="lineNo">${fn:substring(item,0,fn:indexOf(item,"!"))}</td><td class="content"><div><c:out value='${fn:substring(item,fn:indexOf(item,"!")+1, lineLength)}' escapeXml="false" /></div></td>
				</c:when><c:otherwise>
					<td class="lineNo">${status.count + lineShift}</td><td class="content"><div><c:out value="${item}" escapeXml="false" /></div></td>
				</c:otherwise>
				</c:choose>
			</tr>
		</c:forEach>
		</table>
	</article>
	
	<script>

		document.onselectstart = function() { return false; };


		var slider = document.getElementById('y-slider');
		slider.addEventListener('change' , sliderChange);
		
		var container = document.getElementsByTagName('article')[0];
		var currentContainerWidth = 0;
		container.addEventListener('wheel' , function(e){ 
			if(hasClass( container , 'no-y-scroll' )){
				return;
			}
			if(!e.deltaX){
				return;
			}
			slider.value = Math.min( ( parseInt(slider.value) || 0 ) + e.deltaX , parseInt(slider.max) );
			sliderChange.call(slider);
		});
		
		
		var contents = document.getElementsByClassName('content');
		var testContent = null;
		if(contents && contents.length){
			testContent = contents[0].children[0];
			for(var i = 0 ; i < contents.length ; i++){
				if(contents[i].getElementsByTagName('p').length > 0 ){
					toggleClass( contents[i].parentNode , 'searchMatch' , true );
				}
			}
		}
		
		if(document.body.scrollTo){
			document.body.scrollTo( 0 , 0);
		}else{
			document.body.top = 0;
			document.body.left = 0;
		}
		
		history.replaceState && history.replaceState('', '', 'fileViewer');
		
		setInterval( function(){
			if( Math.abs( currentContainerWidth - container.clientWidth ) > 50 ){
				currentContainerWidth = container.clientWidth;
				thumbCounter();
			}
		} , 500);
		
		function reGetDatas( shiftTo , search , onlySearchResult ){
			var newURL = 'AppletServlet?encryptTempFileFullPath=${encryptTempFileFullPath}'
				+'&rl=${readLines}';
			if( shiftTo === null || shiftTo === undefined || (""+shiftTo).match(/[^0-9]/g) ){
				newURL = newURL +'&ls=${lineShift}';
			}else if( shiftTo >= parseInt('${lineCounter}')){
				newURL = newURL +'&ls=${lineCounter-readLines+1}'; 
			}else if(shiftTo > 0){
				newURL = newURL +'&ls='+shiftTo;
			}
			if( search !== null && search !== undefined && search !== ''){
				newURL = newURL +'&s='+search;
			}else{
				var searchResult = document.getElementById("searchResult");
				if(searchResult){
					newURL = newURL +'&s='+searchResult.getAttribute('data-searchString');
					newURL = newURL +'&sr='+searchResult.getAttribute('data-searchResult');
				}
			}
			if(onlySearchResult === true){
				newURL = newURL +'&or=y';
			}
			location.replace(newURL);
		}
		
		var pageCtrls = document.getElementById('line_ctrls').getElementsByTagName('button');
		if(pageCtrls.length){
			var action = function(e){ reGetDatas(this.getAttribute('data-goto')); };
			for(var i = 0 ; i < pageCtrls.length ; i++ ){
				pageCtrls[i].addEventListener('click', action);
			}
		}

		document.getElementById('pageNoInput').addEventListener('blur', function(e){ 
			if((""+this.value).match("[^0-9]")){
				( this.value="${lineShift+1}" );
				return;
			}
			var wishGoto = ( parseInt(this.value))||1;
			if(wishGoto == ${lineShift+1}){
				return;
			}
			wishGoto = Math.min( Math.max( wishGoto - 1 , 0) , '${lineCounter}');
			confirm('Are you sure move to line ' + ( wishGoto + 1) + ' ?' ) ? reGetDatas(wishGoto) : ( this.value="${lineShift+1}" );  
		});
		
		
		document.getElementById("searchString").addEventListener('change', function(e){ 
			var searchResult = document.getElementById("searchResult");
			if(searchResult){
				this.parentNode.removeChild(searchResult);
				var activeTrs = document.getElementsByClassName('searchMatch');
				while(activeTrs.length){
					var activePs = activeTrs[0].getElementsByTagName('p');
					for(var j = 0 ; j < activePs.length ; j++ ){
						toggleClass(activePs[j] , 'highlight' , false);
					}
					toggleClass(activeTrs[0] , 'searchMatch' , false);		
				}
			}
		});
		
		document.getElementById("searchBtn").addEventListener('click', function(e){
			var searchResult = document.getElementById("searchResult");
			if(searchResult){
				return;
			}
			var searchString = document.getElementById("searchString").value;
			if(searchString){
				reGetDatas( null , searchString , true);
			}
		});
		
		
		
		function sliderChange(e){
			document.getElementById('content_style').innerHTML = '.content>div{ margin-left: -'+this.value+'px; }';
		};
		
		function thumbCounter(){
			if(!testContent){ return; }
			var sliderWidth = slider.clientWidth;
			var contentWidth = testContent.clientWidth;
			var containerWidth = container.clientWidth;
			
			if(contentWidth < containerWidth ){
				toggleClass( container , 'no-y-scroll' , true );
				slider.setAttribute('value' , 0);
				document.getElementById('content_style').innerHTML = '';
			}else{
				toggleClass( container , 'no-y-scroll' , false );
			}
			
			var thumbWidth = Math.max( Math.ceil(sliderWidth * ( containerWidth / contentWidth )) , 12 );
			var sliderMax = Math.floor(contentWidth - containerWidth + (thumbWidth / 2));
			slider.setAttribute('max' , sliderMax);
			
			document.getElementById('thumb_style').innerHTML = 
				'article input[type="range"]::-webkit-slider-thumb{ width: '+thumbWidth+'px; } '+
				'article input[type=range]::-moz-range-thumb{ width: '+thumbWidth+'px; } '+
				'article input[type=range]::-ms-thumb{ width: '+thumbWidth+'px; }';
		}
		
		var btns = document.getElementById('fontSize').getElementsByTagName('button');
		for( var i = 0 ; i < btns.length ; i++ ){
			btns[i].addEventListener('click' , fontSizeChange );
		}
		function fontSizeChange(e){
			for( var i = 0 ; i < btns.length ; i++ ){
				toggleClass( btns[i] , 'active' , this == btns[i]);
			}
			var fontSizeRate = this.getAttribute('data-rate');
			var table =  container.getElementsByTagName('table')[0];
			var scrollLines = ((document.documentElement.scrollTop || document.body.scrollTop || 0) - container.offsetTop ) / testContent.clientHeight;
			table.style.fontSize = fontSizeRate + 'em';
			thumbCounter();
			this.blur();
			var newScrollTop = ( scrollLines * testContent.clientHeight ) + container.offsetTop;
			if(document.body.scrollTo){
				document.body.scrollTo(0, newScrollTop);
			}else{
				document.body.scrollTop = newScrollTop;
			}
			
			
		}
		
		var lineTds = document.getElementsByClassName('lineNo');
		for( var i = 0 ; i < lineTds.length ; i++ ){
			lineTds[i].addEventListener('click' , lineClick );
		}
		function lineClick(e){
			var tr = this.parentNode;
			toggleClass(tr , 'focus' );
		}
		
		function hasClass( elem , toggleClassName ){
			var className = (elem.className||'');
			var testRegExp = new RegExp('(^|\\s)'+toggleClassName+'(\\s|$)' , 'i');
			return !!testRegExp.test(className);
		}
		
		function toggleClass( elem , toggleClassName , isAdd ){
			var hadClass = hasClass(elem , toggleClassName);
			if(hadClass === isAdd){ return; } 
			
			var className = (elem.className||'');
			if( hadClass ){
				var testRegExp = new RegExp('(^|\\s)'+toggleClassName+'(\\s|$)' , 'i');
				className = className.replace(testRegExp , ' ');
			}else{
				className = className + ' '+ toggleClassName;
			}
			className = className.replace(/^\s*|\s*$/g , '');
			className = className.replace(/\s{2,}/g , ' ');
			elem.className = className;
		}
	</script>
</body>

</html>