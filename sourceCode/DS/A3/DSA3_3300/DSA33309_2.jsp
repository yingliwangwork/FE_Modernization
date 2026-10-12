<!DOCTYPE>
<%@ page language="java" contentType="text/html; charset=BIG5" %>

<!--
[20200831]問題單號:20200828163231
1.避免上傳的圖片翻轉
[20200907]問題單號:20200903093411
1.新增整批照片上傳功能
2.上傳照片若無相簿時新增一個相簿名稱(民國年當天)  
[20201126] 
1.上傳照片若無相簿時新增一個相簿名稱(由當天改為畫面上相簿日期)
-->
<html>

<head>
    <%@ include file='/html/CM/header.jsp'%>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>受理編號</title>
	<%-- 鑑價影像(單筆) --%>
	<script type="text/javascript" src="${htmlBase}/CM/js/date.js"></script>
	<script src="${htmlBase}/CM/js/jquery/jquery-3.6.0.js"></script>
    <style>
        body {
            font-size: 1em;
            font-family: 'Microsoft JhengHei', 'Meiryo', 'PMingLiU', 'MingLiU', 'Arial', 'Arial Unicode MS', 'Helvetica', 'sans-serif', 'Verdana', 'Trebuchet MS';
            padding: 0;
            margin: 0;
            display: flex;
            flex-direction: row;
            flex-wrap: nowrap;
            justify-content: flex-start;
            align-items: top;
			background-color : #FFF8D7;
        }

        main {
            top: 0px;
            left: 0px;
            width: 100%;
        }

        article .form-flex {
           /* position: absolute;*/
            top: 0;
            margin: 0;

        }

        article .form-flex-filters {
            display: flex;
            flex-wrap: wrap;
            flex-direction: row;
        }

        article .form-flex-filter {
            margin: 0px 15px;
            align-items: center;
            min-width: 200px;
            font-size: 1em;
            line-height: 2;
        }



        article .form-flex-filter label:first-child {
            flex-grow: 0;
            flex-shrink: 0;
            width: 35%;
            text-align: right;
            white-space: nowrap;
        }

        article .form-flex-filter label:first-child::after {
            content: "：";
            padding: 0 5px;
        }

        article .apply-card-list {
            display: flex;
            flex-direction: row;
            flex-wrap: wrap;
            justify-content: flex-start;
            /*space-around;*/
        }

        article .apply-card-list .apply-card {
            width: 320px;
            height: 350px;
            margin: 5px 8px;
            padding-bottom: 15px;
            /*border: 1.5px #9e9e9e solid;
            border-radius: 4px;*/
            border: 1px solid #eaf0ea;
            border-radius: 6px;
            box-shadow: 0px 0px 10px #f4f4f4 inset;
        }

        article .apply-card-list .apply-card:hover {
            background-color: #9e9e9e1f;
            border: 1.5px #55c349 solid;
            cursor: pointer;
        }

        article .apply-photo-types {
            position: relative;
            display: flex;
            justify-content: space-around;
            margin: 5px;

        }

        article select,
        article input,
        article button {
            cursor: pointer;
            font-family: 'Microsoft JhengHei', 'Meiryo', 'PMingLiU', 'MingLiU', 'Arial', 'Arial Unicode MS', 'Helvetica', 'sans-serif', 'Verdana', 'Trebuchet MS';
            padding: 3px;
            border-radius: 3px;
        }

        article .apply-photo-types select {
            width: 44%;
            font-size: 1em;
        }

        article .apply-photo {
            display: flex;
            position: relative;
            flex-wrap: nowrap;

            flex-direction: column;
            align-items: center;

            left: 5px;
            height: calc(320px - 1em - 15px);
            width: calc(320px - 10px);
        }



        article .apply-photo div {
            font-size: 1.15em;
            text-align: center;
        }

        article .apply-photo:hover {
            /* color: #2a40b9;*/
            cursor: pointer;
        }

        article .apply-photo input {
            position: absolute;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
            height: 100%;
            width: 100%;
            opacity: 0;
            cursor: pointer;
            z-index: 15;
        }



        article .apply-header {
            /*margin-top: 0.5em;*/
            padding-top: 0.5em;
            /*position: fixed;
            background-color: #fff;#2eab2f; 
            width: 100%;
            z-index:25;*/
        }


        article .apply-card-list .photo-upload-preview {
            position: relative;
            height: 100%;
            width: 100%;
        }


        article .apply-photo .photo-upload-preview {
            position: relative;
        }

        article .photo-upload-render,
        article .photo-upload-infos {
            position: absolute;
            width: 100%;
            height: 100%;
            left: 0;
            top: 0;
        }

        article .photo-upload-infos {
            display: none;
            z-index: 3;
        }

        article .photo-upload-preview:hover .photo-upload-infos,
        article .photo-upload-preview.active .photo-upload-infos {
            display: block;
            background-color: rgba(62, 69, 81, 0.1);
            z-index: 10;
        }

        article .photo-upload-preview .photo-upload-infos .photo-upload-infos-inner {
            white-space: nowrap;
            margin-top: 20%;

        }

        article .photo-upload-preview .photo-upload-infos .photo-upload-filename-inner {
            color: #fff;
            font-weight: 700;
            font-size: 1.2em;
            -webkit-text-stroke: 1px #fff;
        }

        article .photo-upload-preview .photo-upload-infos .photo-upload-infos-message {
            color: #2eab2f;

            font-weight: 600;
            font-size: 1.1em;
            -webkit-text-stroke: 1px #3ebb47;
            -webkit-text-fill-color: #2eab2f;

        }

        article .apply-photo:hover .delete-photo {
            display: block;
            z-index: 20;
        }

        article .apply-photo .photo-upload-preview img {
            width: 100%;
            height: 100%;
            box-shadow: 0 2px 5px 0 rgba(0, 0, 0, .16), 0 2px 10px 0 rgba(0, 0, 0, .12);
        }

        article .apply-photo .delete-photo {
            display: none;
            position: absolute;
            top: 5;
            right: 5;
            color: #fff;
            border: 1px #63c858 solid;
            background: #44ac39;
            box-shadow: 0px 0px 5px #1D4F09 inset;
            border-radius: 3px;
            padding: 5px;
        }

        .delete-photo i {
            margin: 3px;
        }

        article .apply-photo .storage-photo {
            position: absolute;
            width: 100%;
            font-size: 1.8em;
            margin-top: 40%;
            left: 0;
        }

        article .apply-photo:hover .storage-photo {
            color: #198C25
        }

        article .apply-body {
            margin-top: 1em;
        }

        article .apply-footer {
            text-align: center;
            margin-top: 0.5em;
        }


        button {
            /*border: 1.5px #9e9e9e solid;*/
            border-radius: 4px;
            background-color: #198C25;
            padding: 3px 10px;
            color: #fff;
            font-size: 1.2em;
            border-radius: 3px;
            text-shadow: 0 0px 6px #fff;
            box-shadow: 0 1px 0 #207921;
        }

        button:hover {
            background-color: #116219;
        }

        select:focus {
            border-color: #116219;
        }
    </style>
</head>

<body>
    <main>
        <article>
            <div>
                <form class="form-flex">
                    <div class="form-flex-filters apply-header">
                        <div class="form-flex-filter">
                            <label>受理編號</label>
                            <span id="apply_no">${APPLY_ID}</span>
                        </div>
                        <div class="form-flex-filter">
                            <label>日期</label>
                            <input id="apply_dt" name="apply_dt" type="text"/>
                        </div>
                        <div class="form-flex-filter">
                            <label>地址</label>
                            <span id="apply_address">${ADDRESS}</span>
                        </div>
                    </div>
                </form>
                <div class="form-flex-filter">
                	<label>影像上傳</label>
                	<input name="import_file" id="import_file" type="file" class="file" size="50" multiple>
                	<button type="button" id="btn_upload">上傳</button>
                </div>
                <div class="apply-body">
					<c:if test="${empty mapList}">
					<div id="noneMessage" name="noneMessage">目前無資料。</div>
					</c:if>					
                    <form enctype="multipart/form-data">
                        <div class="apply-card-list">
							
							<c:forEach var="map" items="${mapList}">
                            <div class="apply-card">
								<%-- 隱藏欄位 --%>
								<input name="APPLY_ID" type="hidden" value="${map.APPLY_ID}"><%-- 受理編號 --%>
								<input name="SEQ_NO" type="hidden" value="${map.SEQ_NO}"><%-- 序號 --%>
								<input name="PIC_ALBUM_ID" type="hidden" value="${map.PIC_ALBUM_ID}"><%-- 相簿 ID --%>
								<input name="UPDATE_PIC_DATE" type="hidden" value="${map.UPDATE_PIC_DATE}"><%-- 影像更新日期 --%>
                                <div class="apply-photo-types">
                                    <select name="ATTRIBUTE">
										<c:forEach var="ATTRIBUTE_SEL" items="${ATTRIBUTE_LIST}">
										<option value="${ATTRIBUTE_SEL.key}" <c:if test="${map.ATTRIBUTE == ATTRIBUTE_SEL.key}">selected</c:if> >${ATTRIBUTE_SEL.value}</option>
										</c:forEach>
                                    </select>
                                    <select name="KIND">
										<c:forEach var="KIND_SEL" items="${KIND_LIST}">
										<option value="${KIND_SEL.key}" <c:if test="${map.KIND == KIND_SEL.key}">selected</c:if> >${KIND_SEL.value}</option>
										</c:forEach>
                                    </select>
                                </div>
                                <div class="apply-photo">
									<input name="GUID" type="hidden" value="${map.GUID}"><%-- 序號 --%>
									<input name="PIC_ID" type="hidden" value="${map.PIC_ID}"><%-- 照片 ID --%>
                                    <div class="storage-photo">照片圖庫
                                        <i class="icon ion-md-images"></i>
                                    </div>
                                    <div class="delete-photo file-operator">刪除
                                        <i class="icon ion-md-trash"></i>
                                    </div>

                                    <div class="photo-upload-preview file-operator">
                                        <span class="photo-upload-render">
                                            <img class="photo-upload-preview-img" src="${map.FILE_PATH}">
                                        </span>
                                        <div class="photo-upload-infos">
                                            <div class="photo-upload-infos-inner">
                                                <p class="photo-upload-filename">
                                                    <span class="photo-upload-filename-inner">${map.APPLY_ID}_${map.KIND}_${map.SEQ_NO}</span>
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
								<div align="center" style="margin:5px"><input name="MEMO" type="text" size="35" placeholder="填寫備註" value="${map.MEMO}"/></div>
                            </div>
							</c:forEach>
                        </div>
                    </form>
                </div>

                <div class="apply-footer">
                    <button id="btn_insert" class="apply-more-card" type="button">新增照片</button>
                    <button id="btn_finish" type="button">儲存編輯</button>
                    <button id="btn_back" type="button">回案件選擇</button>
                </div>

            </div>
			<form id="linkForm" name="linkForm"></form>
        </article>
    </main>
    <script>
		
		var case_type = <c:out value="${ATTRIBUTE_LIST_JSON}" default="[]" escapeXml="false" />;
        var photo_type = <c:out value="${KIND_LIST_JSON}" default="[]" escapeXml="false" />;
        
        <%-- 批次上傳檔案 --%> <%-- [20200907]新增程式碼:新增方法doUploadFiles --%>
		function doUploadFiles(obj){
			var _this = $(obj);
			if (!_this.val()) {
				alert("請先選擇檔案");
				return;
			}
			<%-- 確認有上傳檔案 --%>
			_this = _this[0];
			if (!_this.files || !_this.files.length) {
				alert("無法取得檔案");
				return;
			}
			<%-- 檢查圖片格式 --%>
			var extArr = []; 
			for(var i=0; i<_this.files.length; i++){
				var fName = _this.files[i].name;
				var ext = fName.split('.').pop().toLowerCase();
				if ($.inArray(ext, ['png', 'jpg', 'jpeg']) == -1) {
					alert('請上傳正確的圖片格式');
					$('#import_file').val('');
					return;
				}
				extArr.push(ext);
			}
			<%-- 檔案名稱 --%>
			var fileI = 0;
			var reader = new FileReader();
			var _frontCover = $('#_frontCover');
   			_frontCover.show();
			reader.onload = function (e) {
				var compressBase64 = e.target.result;
				var base64 = compressBase64.replace(/^data:image\/(png|jpg|jpeg);base64,/, "");
				var imgMap = {
					'PIC_ALBUM_ID' : '${albumId}',
					'KIND' : "0",
					'MEMO' : "",
					'ATTRIBUTE' : "0",
					'base64' : base64,
					'filetype' : '.' + extArr[fileI]
				};
				var isLast = (fileI == _this.files.length-1);
				var dataObj = {
					'APPLY_ID':'${APPLY_ID}',
					'imgMap':JSON.stringify(imgMap),
					'USER_ID':'${USER_ID}',
					'isMultiple':'Y',
					'isLast':isLast ? 'Y':'N',
					'albumName':$('#apply_dt').val()
				};
				var isMsg = false; <%-- 是否回傳失敗訊息及最後一筆的成功訊息 --%>
				$.ajax({
					type: "POST",
					url:  "${dispatcher}/DSA3_3309/upload",
					data: dataObj,
					async: false,
					success:
						function(response){
							var ErrMsg = response.ErrMsg;
							if(ErrMsg.returnCode != '0'){
								_frontCover.hide();
								alert(ErrMsg.msgDesc);
								isMsg = true;
							}else if(isLast){
								_frontCover.hide();
								alert(ErrMsg.msgDesc);
								$('#import_file').val('');
								var apply_card_list_node = $('.apply-card-list');
								apply_card_list_node.empty();
								var mapList = $(response.mapList);
								mapList.each(function(i,v){
									$(apply_card_list_node).append(buildNewApplyCard("reQuery", v));
								});
							}
						}
				});
				fileI++;
				if(fileI < _this.files.length && !isMsg){
					reader.readAsDataURL(_this.files[fileI]);
				}
			}
			reader.readAsDataURL(_this.files[fileI]);
		}
		
		<%-- 上傳檔案 --%>
		function doUpload(obj){
			var _this = $(obj);

			if (!_this.val()) {
				return;
			}
			
			<%-- 檢查圖片格式 --%>
			var ext = _this.val().split('.').pop().toLowerCase();
			if ($.inArray(ext, ['png', 'jpg', 'jpeg']) == -1) {
				alert('請上傳正確的圖片格式');
				_this.val('');
				return;
			}
			<%-- 確認有上傳檔案 --%>
			_this = _this[0];
			if (!_this.files || !_this.files.length) {
				alert("無法取得檔案");
				return;
			}

			<%-- 檔案名稱 --%>
			var fName = _this.files[0].name;
			var parent_target = $(_this).parent('.apply-photo');
			
			<%-- 檔案刪除區塊 --%>
			
			var previewFile = $('<div class="file-operator photo-upload-preview">').appendTo(parent_target);
			var previewFile_render = $('<span class="photo-upload-render">').appendTo(previewFile);
			var previewFile_infos = $('<div class="photo-upload-infos">').appendTo(previewFile);
			var previewFile_infos_inner = $('<div class="photo-upload-infos-inner">').appendTo(previewFile_infos);
			$('<p class="photo-upload-filename"><span class="photo-upload-filename-inner">' + fName + '</span></p>').appendTo(previewFile_infos_inner);
			$('<p class="photo-upload-infos-message">click to replace</p>').appendTo(previewFile_infos_inner);
			
			var reader = new FileReader();
			reader.onload = function (e) {
				
				var result = e.target.result;
				uploadCompress( ext, _this, result, obj); <%-- [20200831]新增程式碼: 上傳圖片 --%>
				<%-- 透過canvase壓縮檔案 --%>
				<%-- canvasDataURL(result, ext, _this, uploadCompress, obj); // [20200831]註解程式碼: 上傳圖片，不使用canvas，避免圖片失去EXIF --%>
				
			}
			reader.readAsDataURL(_this.files[0]);
		}
		
		<%-- 透過canvase壓縮檔案   // [20200831]註解程式碼: 上傳圖片，不使用canvas壓縮，避免圖片失去EXIF
		function canvasDataURL(result, ext, _this, uploadCompress, obj){
			
			var img = new Image();
			img.src = result;
			img.onload = function(){
				// <%--[20200824][問題單20200819110904]請協助移除上傳時透過canvase壓縮檔案
				var quality = 1;
				var canvas = $('<canvas>')[0];
                var ctx = canvas.getContext('2d');
                ctx.canvas.width = this.width;
                ctx.canvas.height = this.height;
                ctx.drawImage(this, 0, 0, this.width, this.height);
				var data = canvas.toDataURL('image/jpeg', {'quality':1});
				uploadCompress(ext, _this, data, obj);
			}
		} --%>
		
		<%-- 壓縮完之後上傳 --%>
		function uploadCompress( ext, _this, compressBase64, obj){
			var parent_target = $(_this).parent('.apply-photo');
			var apply_card_node = $(_this).parents('.apply-card');
			var SEQ_NO = apply_card_node.children('input[name="SEQ_NO"]').val();
			var PIC_ALBUM_ID = apply_card_node.children('input[name="PIC_ALBUM_ID"]').val();
			var PIC_ID = apply_card_node.children('input[name="PIC_ID"]').val();
			var UPDATE_PIC_DATE = $('#apply_dt').val();
			var base64 = compressBase64.replace(/^data:image\/(png|jpg|jpeg);base64,/, "");
			var MEMO = apply_card_node.find('input[name="MEMO"]').val();
			var ATTRIBUTE = apply_card_node.find('select[name="ATTRIBUTE"]').val();
			var KIND = apply_card_node.find('select[name="KIND"]').val();
			
			if(!ATTRIBUTE || (ATTRIBUTE == 0) || (KIND == 0) || !KIND){
				alert('請選擇影像屬性跟影像種類');
				parent_target.find('.file-operator').remove();
				$(obj).val(null);
				return;
			}
			
			var imgMap = {
				'SEQ_NO' : SEQ_NO,
				'PIC_ALBUM_ID' : '${albumId}',
				'PIC_ID' : PIC_ID,
				'UPDATE_PIC_DATE' : UPDATE_PIC_DATE,
				'KIND' : KIND,
				'MEMO' : MEMO,
				'ATTRIBUTE' : ATTRIBUTE,
				'base64' : base64,
				'filetype' : '.' + ext
			};
			$('#_frontCover').show();
			$.ajax({
				type: "POST",
				url:  "${dispatcher}/DSA3_3309/upload",
				data: {'APPLY_ID' : '${APPLY_ID}', 'imgMap' : JSON.stringify(imgMap), 'USER_ID' : '${USER_ID}', 'albumName' : $('#apply_dt').val()},
				async: false,
				success:
					function(response){
						
						var ErrMsg = response.ErrMsg;
						alert(ErrMsg.msgDesc);
						if(ErrMsg.returnCode != '0'){
							parent_target.find('.file-operator').remove();
							return;
						}
						
						var apply_card_list_node = $('.apply-card-list');
						apply_card_list_node.empty();
						
						var mapList = $(response.mapList);
						
						mapList.each(function(i,v){
							$(apply_card_list_node).append(buildNewApplyCard("reQuery", v));
						});
					}
			});
			$('#_frontCover').hide();
		}
			
		
		<%-- 刪除照片 --%>
		function doDelete(obj){
			if(!confirm("確認刪除?")){
				return;
			}
			var apply_photo_node = $(obj).parent('.apply-photo');
			apply_photo_node.find('.file-operator').remove();
			var GUID = apply_photo_node.find('input[name="GUID"]').val();
			var PIC_ID = apply_photo_node.find('input[name="PIC_ID"]').val();
			
			$.ajax({
				type: "POST",
				url:  "${dispatcher}/DSA3_3309/delete",
				data: {'APPLY_ID' : '${APPLY_ID}', 'GUID' : GUID, 'USER_ID' : '${USER_ID}', 'PIC_ID' : PIC_ID},
				success:
					function(response){
						var apply_card_list_node = $('.apply-card-list');
						apply_card_list_node.empty();
						
						var ErrMsg = response.ErrMsg;
						if(ErrMsg.returnCode != '0'){
							alert(ErrMsg.msgDesc);
						}
						
						var mapList = $(response.mapList);
						
						if(mapList.length == 0){
							$('#noneMessage').show();
						}
						
						mapList.each(function(i,v){
							$(apply_card_list_node).append(buildNewApplyCard("reQuery", v));
						});
						
						if(ErrMsg.returnCode == '0'){
							alert(ErrMsg.msgDesc);
						}
					}
			});
		}
		
		<%-- 儲存編輯 --%>
		function doFinish(){
			
			if(!confirm("確認儲存編輯?")){
				return;
			}
			
			var updList = [];
			
			$(".apply-card").each(function(i,v){
				var apply_card_node = $(v);
				var GUID = apply_card_node.find('input[name="GUID"]').val();
				if(!GUID){
					return;
				}
				
				var PIC_ID = apply_card_node.find('input[name="PIC_ID"]').val();
				var MEMO = apply_card_node.find('input[name="MEMO"]').val();
				var ATTRIBUTE = apply_card_node.find('select[name="ATTRIBUTE"]').val();
				var KIND = apply_card_node.find('select[name="KIND"]').val();
				var map = {
					'PIC_ALBUM_ID' : '${albumId}',
					'PIC_ID' : PIC_ID,
					'GUID' : GUID,
					'MEMO' : MEMO,
					'ATTRIBUTE' : ATTRIBUTE,
					'KIND' : KIND,
					'APPLY_ID' : '${APPLY_ID}'
				};
				updList.push(map);
			})
			
			$.ajax({
				type: "POST",
				url:  "${dispatcher}/DSA3_3309/finish",
				data: {'APPLY_ID' : '${APPLY_ID}', 'USER_ID' : '${USER_ID}', 'albumId' : '${albumId}', 'albumName' : $('#apply_dt').val(), 'updList' : JSON.stringify(updList)},
				success:
					function(response){
						var apply_card_list_node = $('.apply-card-list');
						apply_card_list_node.empty();
						
						var ErrMsg = response.ErrMsg;
						if(ErrMsg.returnCode != '0'){
							alert(ErrMsg.msgDesc);
						}
						
						var mapList = $(response.mapList);
						
						if(mapList.length == 0){
							$('#noneMessage').show();
						}
						
						mapList.each(function(i,v){
							$(apply_card_list_node).append(buildNewApplyCard("reQuery", v));
						});
						
						if(ErrMsg.returnCode == '0'){
							alert(ErrMsg.msgDesc);
						}
						
					}
			});
			
			
		}
		
		<%-- 回現勘照片集 --%>
		function doBack(){
			
			var updList = [];
			
			$(".apply-card").each(function(i,v){
				var apply_card_node = $(v);
				var GUID = apply_card_node.find('input[name="GUID"]').val();
				if(!GUID){
					return;
				}
				
				var PIC_ID = apply_card_node.find('input[name="PIC_ID"]').val();
				var MEMO = apply_card_node.find('input[name="MEMO"]').val();
				var ATTRIBUTE = apply_card_node.find('select[name="ATTRIBUTE"]').val();
				var KIND = apply_card_node.find('select[name="KIND"]').val();
				var map = {
					'PIC_ALBUM_ID' : '${albumId}',
					'PIC_ID' : PIC_ID,
					'GUID' : GUID,
					'MEMO' : MEMO,
					'ATTRIBUTE' : ATTRIBUTE,
					'KIND' : KIND,
					'APPLY_ID' : '${APPLY_ID}'
				};
				updList.push(map);
			})
			
			
			var linkForm = $('#linkForm')[0];
			$('<input>').attr({'id' : 'APPLY_ID', 'name' : 'APPLY_ID' ,  'type' : 'hidden', 'value' : '${APPLY_ID}'}).appendTo(linkForm);
			$('<input>').attr({'id' : 'APPR_GROUP', 'name' : 'APPR_GROUP' ,  'type' : 'hidden', 'value' : '${APPR_GROUP}'}).appendTo(linkForm);
			$('<input>').attr({'id' : 'USER_ID', 'name' : 'USER_ID' ,  'type' : 'hidden', 'value' : '${USER_ID}'}).appendTo(linkForm);
			$('<input>').attr({'id' : 'updList', 'name' : 'updList' , 'type' : 'hidden', 'value' : JSON.stringify(updList)}).appendTo(linkForm);
			$('<input>').attr({'id' : 'albumId', 'name' : 'albumId' , 'type' : 'hidden', 'value' : '${albumId}'}).appendTo(linkForm);
			$('<input>').attr({'id' : 'albumName', 'name' : 'albumName' , 'type' : 'hidden', 'value' : $('#apply_dt').val()}).appendTo(linkForm);
			linkForm.action = '${dispatcher}/DSA3_3309/backToApplyId';
			linkForm.submit();
		}
		
		
		<%-- new出一個新ApplyCard --%>
		function buildNewApplyCard(type, map) {
			
			$('#noneMessage').hide();
			
			var item = $('<div>').attr('class','apply-card');
			
			<%-- 下拉選單主體 --%>
			var photo_types = $('<div>').attr('class','apply-photo-types');
			item.append(photo_types);
			
			<%-- 影像屬性下拉選單 --%>
			var elem_case_type = $('<select>').attr('name','ATTRIBUTE');
			photo_types.append(elem_case_type);
			
			$.each(case_type, function (key, val) {					
				var option = $('<option>').attr('value',key).append(val);
				elem_case_type.append(option);
			});
			
			<%-- 影像種類下拉選單 --%>
			var elem_photo_type = $('<select>').attr('name','KIND');
			photo_types.append(elem_photo_type);
			$.each(photo_type, function (key, val) {
				var option = $('<option>').attr('value',key).append(val);
				elem_photo_type.append(option);
			});
			
			var memo_node = $('<div>').attr({'style' : 'margin:5px; text-align: center;'}).append($('<input>').attr({'name' : 'MEMO', 'type' : 'text', 'size' : '35', 'placeholder' : '填寫備註'}));
			
			if(type == 'reQuery'){
				elem_case_type.val(map.ATTRIBUTE);
				elem_photo_type.val(map.KIND);
				<%-- 重查畫面新增 --%>
				var apply_photo_node = $('<div>').attr('class', 'apply-photo');
				$('<input>').attr({'name' : 'GUID', 'type' : 'hidden', 'value' : map.GUID}).appendTo(apply_photo_node);
				$('<input>').attr({'name' : 'PIC_ID', 'type' : 'hidden', 'value' : map.PIC_ID}).appendTo(apply_photo_node);
				$('<div>').attr('class', 'storage-photo').append('照片圖庫').append($('<i>').attr('class', 'icon ion-md-images')).appendTo(apply_photo_node);
				$('<div>').attr('class', 'delete-photo file-operator').append('刪除').append($('<i>').attr('class', 'icon ion-md-trash')).click(function () {
					doDelete(this);
				}).appendTo(apply_photo_node);
				
				var preview_node = $('<div>').attr('class', 'photo-upload-preview file-operator');
				$('<span>').attr('class', 'photo-upload-render').append($('<img>').attr({'class' : 'photo-upload-preview-img', 'src' : map.FILE_PATH})).appendTo(preview_node);
				
				var infos_node = $('<div>').attr('class', 'photo-upload-infos');
				var infos_inner_node = $('<div>').attr('class', 'photo-upload-infos-inner');
				var filename_node = $('<p>').attr('class', 'photo-upload-filename');
				$('<span>').attr('class', 'photo-upload-filename-inner').append(map.APPLY_ID + '_' + map.KIND + '_' + map.SEQ_NO).appendTo(filename_node);
				filename_node.appendTo(infos_inner_node);
				infos_inner_node.appendTo(infos_node);
				infos_node.appendTo(preview_node);
				preview_node.appendTo(apply_photo_node);
				apply_photo_node.appendTo(item);
				memo_node.find('input[name="MEMO"]').val(map.MEMO);
				
				apply_photo_node.hover(function (event) {
					apply_photo_node.find('.photo-upload-preview').addClass('active');
				}, function (event) {
					apply_photo_node.find('.photo-upload-preview').removeClass('active');
				});
				
			}else if( type == 'new'){
				<%-- 畫面新增照片 --%>
				var apply_photo_node = $('<div>').attr('class', 'apply-photo');
				$('<input>').attr({'type' : 'file', 'name' : 'upload_photo', 'class' : 'file-upload', 'onChange' : 'doUpload(this)'}).appendTo(apply_photo_node);
				$('<div>').attr('class', 'storage-photo').append('照片圖庫').append($('<i>').attr('class', 'icon ion-md-images')).appendTo(apply_photo_node);
				apply_photo_node.appendTo(item);
			}
			
			item.append(memo_node);
			
			return item;
		}
		
		
	
        $(document).ready(function () {
            $('div.delete-photo').click(function () {
				doDelete(this);
            });

            $('div.apply-photo').hover(function (event) {
                $(this).find('.photo-upload-preview').addClass('active');
            }, function (event) {
                $(this).find('.photo-upload-preview').removeClass('active');
            });			
			
			<%-- 新增照片 --%>
            $('#btn_insert').click(function () {
				var item = buildNewApplyCard('new');
                $('.apply-card-list').last().append(item);
            });
			
            $('#btn_finish').click(function () {
				doFinish();
            });
            
            $('#btn_back').click(function () {
				doBack();
            });
            
            $('#btn_upload').click(function () { <%-- [20200907]新增程式碼 --%>
            	doUploadFiles('#import_file');
            });
			
			<c:if test="${not empty albumName}">
				$('#apply_dt').val('${albumName}');
			</c:if>
			<c:if test="${empty albumName}">
				$('#apply_dt').val(getToday());
			</c:if>
			
			var ErrMsg = '${ErrMsg.msgDesc}';
			
			if(ErrMsg){
				alert(ErrMsg);
			}
			
			$('#_frontCover').hide();
			
        });
		
		
		
    </script>
	<div id="_frontCover" style="width: 100%; height: 100%; position: fixed; left: 0px; top: 0px; padding: 0px; margin: 0px auto; z-index: 150; cursor: progress; background: url('${imageBase}/CM/ui/CSRUtil.coverPage.bg.png');">
		<div style="width: 100%; height: 100%; position: absolute; left: 0px; top: 0px; background: url('${imageBase}/CM/ui/CSRUtil.loading.gif') center center no-repeat;"></div>
	</div>
</body>

</html>