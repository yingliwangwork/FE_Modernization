<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!--
程式：DSA33308.jsp
功能：影像顯示
作者：i9400518 張晉瑋
Since： 2018-06-27
-->
<html> 
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<!--匯入外部Javascript 與 css-->

<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='${htmlBase}/CM/js/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/DS/js/DS_ImageUtil.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/utility.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<style>
	.thumb-bar img {
	  display: block;
	  width: 30%;
	  float: left;
	  cursor: pointer;
	  text-align:center;
	  margin-right: 1.5%;
	  margin-left: 1.5%;
	}
</style>
<script type='text/javascript'>
<%-- 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp --%>
Event.observe(window, 'load', new DSA33308().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA33308(){
	var length;
	var path = [];
	var MEMO = [];
	var KIND_TEXT = [];
	var beginIndex = 1;
	var endIndex = 3;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_3308/');	

	var buttons = {
		<%-- 前一筆--%>
		doForward : function(){
			endIndex -= 1;
			beginIndex -= 1;
			$('backward').enable();
			beginIndex == 1 ? $('forward').disable() : $('forward').enable();
			
			actions.doInsertImage(beginIndex - 1);		
		},
		<%-- 後一筆--%>
		doBackward : function(){
			beginIndex += 1;
			endIndex += 1;
			$('forward').enable();	
			endIndex == length ? $('backward').disable() : $('backward').enable();
			
			actions.doInsertImage(beginIndex - 1);
		},
		<%-- 顯示圖檔--%>
		doShowImage : function(){
			var ImgObj = $(this.id).select('img');
			var showObj = $('showImage').select('img');
			var index = beginIndex - 1;
			if ('preImage2' == this.id) {
				index += 1;
			}			
			if ('preImage3' == this.id) {
				index += 2;
			}
			if(ImgObj.length > 0 && showObj.length > 0){
				var Src = ImgObj[0].getAttribute('src');
				actions.checkImgLoaded(Src, path[index]);
				$('KIND_TEXT').update($F(this.id + '_KIND_TEXT'));	
				$('MEMO').update($F(this.id + '_MEMO'));	
			}
		},
		<%-- 顯示圖檔--%>
		doShowMainImage : function(id){
			var ImgObj = $(id).select('img');
			
			if(ImgObj.length > 0){
				var Src = ImgObj[0].getAttribute('src');
				actions.checkImgLoaded(Src, path[0]);
			}
		},
		<%-- 依照「相簿名稱」挑選不同相簿顯示 --%>
		doQueryAlbum : function(){
			
			ajaxRequest.post('queryAlbum', { 
				ALBUM_ID :  $F('ALBUM_ID'),
				COMMUNITY_NO : '${COMMUNITY_NO}'
			},
			function(resp){ 
				if(resp.albumList){

					<%-- 縮圖區塊顯示三張圖，若總張數小於三張，forward、backward disabled，初始forward disabled--%>
					length = resp.albumList.length;
					if(length <= 3){
						$('forward').disable();
						$('backward').disable();
					}else{
						$('forward').disable();
						$('backward').enable();
					}
					
					$('DataSize').setValue(length);
					path = [];
					MEMO = [];
					KIND_TEXT = [];
					
					<%-- 將第一張圖放置於顯示區，第一張到第三張放置於縮圖區 --%>
					actions.selectPath(resp.albumList);
					//顯示縮圖
					actions.doInsertImage(0);
					
					var showObj = resp.albumList[0];	//第一筆資料
					if(showObj){
						buttons.doShowMainImage('preImage1');
						$('KIND_TEXT').update(showObj.KIND_TEXT);
						$('MEMO').update(showObj.MEMO);
					}else{
						var showImage = $('showImage').select('[name="showImage"]')[0];
						showImage.src = '';
						showImage.height = 400;
						showImage.Width = 0;
						$('KIND_TEXT').update('');
						$('MEMO').update('');
					}
				}
			});
		}
	};
	
	var actions = {
		doInsertImage : function(index){
			$w('preImage1 preImage2 preImage3').each(function(eid){
				if(path[index]){
					<%-- [20191031] 因沒有實體檔案, 所以不用ImageUtil, 而直接用 src --%>
					$(eid).select('[name="showImage"]')[0].src = path[index];
					$(eid + '_KIND_TEXT').setValue(KIND_TEXT[index]);	
					$(eid + '_MEMO').setValue(MEMO[index]);	
				}else{
					<%-- [20191031] 因沒有實體檔案, 所以不用ImageUtil, 而直接用 src --%>
					$(eid).select('[name="showImage"]')[0].src = '';
					$(eid + '_KIND_TEXT').setValue('');	
					$(eid + '_MEMO').setValue('');					
				}
				index += 1;
			});
		},
		<%-- 取出物件放入陣列中 --%>
		selectPath : function(A356List){
			A356List.forEach(function(ele){
				var FILE_PATH = ele.FILE_PATH;
				var MEMO_DATA = ele.MEMO;
				var KIND_TEXT_DATA = ele.KIND_TEXT;
				
				path.push(FILE_PATH ? FILE_PATH : '');
				MEMO.push(MEMO_DATA ? MEMO_DATA : '');
				KIND_TEXT.push(KIND_TEXT_DATA ? KIND_TEXT_DATA : '');
			});
		},
		<%-- 確認圖檔是否以載入 --%>
		checkImgLoaded : function(Src, Path){
			var newImg = new Image();
		  	newImg.src = Src;
		
		  	if (newImg.complete) {
		  		// 圖片已經被載入
		  		actions.AfterLoad(newImg.naturalHeight, newImg.naturalWidth, Path);
		  	} else {
		  	 	 // 如果圖片未被載入，則設定載入時的回調
		   		newImg.onload = function () {
		   	   		actions.AfterLoad(newImg.naturalHeight, newImg.naturalWidth, Path);
		  	  	}
		  	}
		},
		<%-- 圖檔載入後再呼叫ImageUtil進行寫入動作 --%>
		AfterLoad : function(imgHeight, imgWidth, Path){
			var Height = 450;
			var Width = imgWidth * Height / imgHeight;
			
			<%-- [20191031] 因沒有實體檔案, 所以不用ImageUtil, 而直接用 src --%>
			var showImage = $('showImage').select('[name="showImage"]')[0];
			showImage.src = Path;
			showImage.height = Height;
			showImage.Width = Width;
		}
	};
	return {
		initApp : function() {
			var A356List = <c:out value = '${A356List}' default = '[]' escapeXml = "false"/>
			length = A356List.length;
			
			<%-- 設定資料長度以供parent page DSA33310抓取判斷--%>
			$('DataSize').setValue(length);

			<%-- 縮圖區塊顯示三張圖，若總張數小於三張，forward、backward disabled，初始forward disabled--%>
			if(length <= 3){
				$('forward').disable();
				$('backward').disable();
			}else{
				$('forward').disable();
			}
			
			<%-- 將第一張圖放置於顯示區，第一張到第三張放置於縮圖區 --%>
			/*if(length > 0){	
				actions.selectPath(A356List);
				//顯示縮圖				
				actions.doInsertImage(0);
				
				var showObj = A356List[0];	//第一筆資料
				if(showObj){
					buttons.doShowMainImage('preImage1');
					$('KIND_TEXT').update(showObj.KIND_TEXT);
					$('MEMO').update(showObj.MEMO);
				}
			}*/
			actions.selectPath(A356List);
			//顯示縮圖				
			actions.doInsertImage(0);
			
			var showObj = A356List[0];	//第一筆資料
			if(showObj){
				buttons.doShowMainImage('preImage1');
				$('KIND_TEXT').update(showObj.KIND_TEXT);
				$('MEMO').update(showObj.MEMO);
			}else{
				var showImage = $('showImage').select('[name="showImage"]')[0];
				showImage.src = '';
				showImage.height = 400;
				showImage.Width = 0;
				$('KIND_TEXT').update('');
				$('MEMO').update('');
			}

			<%-- 事件監聽區 --%>
			<c:if test="${hasCOMMUNITY_NO eq true}">
				$('ALBUM_ID').observe('change', buttons.doQueryAlbum);
			</c:if>
			$('forward').observe('click', buttons.doForward); <%-- 前一筆--%>
			$('backward').observe('click', buttons.doBackward); <%-- 後一筆--%>
			$('preImage1').observe('click', buttons.doShowImage); <%-- 縮圖1--%>
			$('preImage2').observe('click', buttons.doShowImage); <%-- 縮圖2--%>
			$('preImage3').observe('click', buttons.doShowImage); <%-- 縮圖3--%>
			
			displayMessage();
		}	
	};
}
</script>
</head>
<body>
<form id="form1" name="form1" method="post"> 
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbYellow2">
		<tr class=tbYellow align=middle>
			<td align="center">
			<strong>相簿日期：</strong>
			<select id="ALBUM_ID" name="ALBUM_ID">
				<c:forEach var="map" items="${idList}">
				<option value="${map.id}">${map.date}</option>
				</c:forEach>
			</select>
			</td>
	    </tr>
	    <tr>
          	<td align="center">
          		<strong><span id="KIND_TEXT"></span></strong><br>
        	</td>
        </tr>
        <tr>
          	<td align="center">
          		<span id="MEMO"></span><br>
        	</td>
        </tr>
        <input type="hidden" id="DataSize" name = "DataSize">
     </table>
     <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbYellow2">
    	<tr>
          	<td align="center">
          		<div id="showImage">
					<img name="showImage">
				</div>
        	</td>
        </tr>
    </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbYellow2">
        <tr align="center">  
        	<td width="35%" style="text-align : right">
            	<button type="button" class="button" id="forward">&#10094;</button>
          	</td>
          	<td width="30%">
            	<div id="preImage1" class="thumb-bar" >
					<img name="showImage">
            		<input type="hidden" id="preImage1_KIND_TEXT">
            		<input type="hidden" id="preImage1_MEMO">
              	</div>
              	<div id="preImage2" class="thumb-bar" >
					<img name="showImage">
              		<input type="hidden" id="preImage2_KIND_TEXT">
              		<input type="hidden" id="preImage2_MEMO">
              	</div>
              	<div id="preImage3" class="thumb-bar" >
					<img name="showImage">
              		<input type="hidden" id="preImage3_KIND_TEXT">
              		<input type="hidden" id="preImage3_MEMO">
              	</div>
          	</td>
          	<td width="35%" style="text-align : left">
	            <button type="button" class="button" id="backward">&#10095;</button>
	        </td>
        </tr>
    </table>
</form>
</body>
</html>