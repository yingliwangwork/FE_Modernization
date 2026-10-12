<!DOCTYPE>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<html>

<head>
	<%@ include file='/html/CM/header.jsp'%>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>案件查詢</title>
	<%-- 鑑價影像(清單) --%>
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
            min-width: 250px;
            font-size: 1em;
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

        article .form-flex-filter select {
            cursor: pointer;
            font-family: 'Microsoft JhengHei', 'Meiryo', 'PMingLiU', 'MingLiU', 'Arial', 'Arial Unicode MS', 'Helvetica', 'sans-serif', 'Verdana', 'Trebuchet MS';
            padding: 3px;
            border-radius: 3px;
        }

        article .apply-card-list {
            display: flex;
            flex-wrap: wrap;
            align-items: flex-start;
            justify-content: space-around;
        }

        article .apply-card-list .apply-card {
            width: 320px;
            height: 320px;
            margin: 5px 8px;
            padding-bottom: 10px;
            background-color: #a7d6ae;
            border: 1px #55c349 solid;
            border-radius: 6px;
            box-shadow: 0px 0px 10px #f4f4f4 inset;
        }

        article .apply-card-list .apply-card:hover {
            background-color: #9e9e9e1f;
            border: 1.5px #55c349 solid;
            cursor: pointer;
        }

        article .apply-card-list .apply-card .apply-card-text {
            margin: 5px;
        }

        article .apply-card-list .apply-card .apply-operator {
            text-align: center;
            width: 100%;
            color: #44ac39;
        }

        article .apply-card-list .apply-card .apply-address {
            flex-grow: 1;
            height: calc(100% - 170px - 1em);
        }

        article .apply-card-list .apply-card .apply-operator i {
            font-size: 3.5em;
        }

        article .apply-card-list .apply-card .apply-todo {
            color: #0000006b;
        }

        article .apply-header {
            margin-top: 0.5em;
        }
		
		button {
			border-radius: 4px;
			background-color: #198C25;
			padding: 3px 10px;
			color: #fff;
			font-size: 1.2em;
			border-radius: 3px;
			text-shadow: 0 0px 6px #fff;
			box-shadow: 0 1px 0 #207921;
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
                            <label>鑑價組別</label>
                            <select id="APPR_GROUP" name="APPR_GROUP">
							<option value="">全部</option>
                            <c:forEach var="map" items="${APPR_GROUP_LIST}">
								<option value="${map.key}">${map.value}</option>
							</c:forEach>
                            </select>
                        </div>
                        <div class="form-flex-filter">
                            <label>鑑價人員</label>
                            <select id="APPR_ID" name="APPR_ID">
                            </select>
                        </div>
						<div class="form-flex-filter">
                            <label>上傳狀態</label>
                            <select id="UPLOAD_TYPE" name="UPLOAD_TYPE">
							<c:forEach var="map" items="${UPLOAD_TYPE_MAP}">
								<option value="${map.key}">${map.value}</option>
							</c:forEach>
                            </select>
                        </div>
                    </div>
                </form>
                <div class="apply-card-list">
					<c:forEach var="map" items="${mapList}">
                    <div class="apply-card" onClick="queryImg('${map.APPLY_ID}', '${map.GAGE_ADDR}')">
                        <div class="apply-card-text apply-no">${map.APPLY_ID}</div>
                        <div class="apply-card-text apply-address">${map.GAGE_ADDR}</div>
						<div class="apply-card-text ">案號:${map.COMMUNITY_NO}</div>
						<div class="apply-card-text ">案名:${map.CASE_NAME}</div>
						<div class="apply-card-text ">近一次外觀照日期:${map.UPDATE_PIC_DATE}</div>
						<c:choose>
						<c:when test="${map.IS_UPLOAD == '0'}">
                        <div class="apply-operator apply-todo">
                            <i class="icon ion-md-camera"></i>
                            <br>待完成
						</div>
						</c:when>
						<c:when test="${map.IS_UPLOAD == '1'}">
						<div class="apply-operator apply-edit">
                            <i class="icon ion-md-camera"></i>
							<br>檢視/編輯
						</div>
						</c:when>
						</c:choose>
                    </div>
                    </c:forEach>
                </div>
            </div>
			<form id="linkForm" name="linkForm">
				<input id="APPLY_ID" name="APPLY_ID" type="hidden"></input>
				<input id="ADDRESS" name="ADDRESS" type="hidden"></input>
				<input id="iAPPR_ID" name="iAPPR_ID" type="hidden"></input>
				<input id="iAPPR_GROUP" name="iAPPR_GROUP" type="hidden"></input>
			</form>
        </article>
    </main>
    <script>

		var APPR_GROUP_ALL_MAP = <c:out value="${APPR_GROUP_ALL_MAP}" default="[]" escapeXml="false" />;

        $(function () {			
			
			<%--  若有APPLY_ID,直接導頁至鑑價影像  --%>
			<%--  沒有ARRP_GROUP,代表從B畫面連回來  --%>
			if('${APPLY_ID}' && !'${APPR_GROUP}'){
				queryImg('${APPLY_ID}');
			}
			
			$('#APPR_GROUP').change(function(){
				changeAPPR_GROUP_ID();
			});
			
			$('#APPR_ID').change(function(){
				queryForMapList();
			});
			
			
			if('${APPR_GROUP}'){
				<%-- 有ARRP_GROUP,代表從B畫面連回來 --%>
				$('#APPR_GROUP').val('${APPR_GROUP}');<%-- 將下拉選單回填 --%>
				changeAPPR_GROUP_ID('reQuery');<%-- 帶出鑑價人員下拉選單, 但不用重查(後端已經重查) --%>
				$('#APPR_ID').val('${USER_ID}');<%-- 將下拉選單回填 --%>
			}else{
				changeAPPR_GROUP_ID();
			}
			
			var ErrMsg = '${ErrMsg.msgDesc}';
			
			if(ErrMsg){
				alert(ErrMsg);
			}
			
        });
		
		<%-- 連動下拉選單 --%>
		function changeAPPR_GROUP_ID(type){
			var APPR_ID = $('#APPR_ID');
			APPR_ID.empty();
			<%-- 生成人員下拉選單 --%>
			var EMPList = APPR_GROUP_ALL_MAP[$('#APPR_GROUP').val()];
			if(EMPList) {
				for(var i=0; i<EMPList.length;i++ ) {
					var node = $('<option>').attr('value', EMPList[i].ID).text(EMPList[i].NAME)
							.appendTo(APPR_ID);
				}
			}
			<%-- 代表非重查，需要重查 --%>
			if(APPR_ID.val() && (type != 'reQuery')){
				queryForMapList();
			}
		}
		
		<%-- 頁面跳轉到B畫面(照片清單) --%>
		function queryImg(APPLY_ID, addr){
			$('#APPLY_ID').val(APPLY_ID);
			$('#ADDRESS').val(addr);
			$('#iAPPR_ID').val($('#APPR_ID').val());
			$('#iAPPR_GROUP').val($('#APPR_GROUP').val());
			var linkForm = $('#linkForm')[0];
			linkForm.action = '${dispatcher}/DSA3_3309/queryImgByAPPLY_ID';
			linkForm.submit();
		}
		
		<%-- 查詢該ID底下所有案件 --%>
		function queryForMapList(){
			$.ajax({
  			type: "POST",
  			url:  "${dispatcher}/DSA3_3309/queryForMapListByAPPLY_ID",
  			data: {'APPR_ID' : $('#APPR_ID').val(), 'APPLY_ID' : "${APPLY_ID}", 'UPLOAD_TYPE' : $('#UPLOAD_TYPE').val()},
  			async: false,
  			success:
	  			function(response){
					var apply_card_list_node = $('.apply-card-list');
					apply_card_list_node.empty();
					
					var ErrMsg = response.ErrMsg;
					if(ErrMsg.returnCode != '0'){
						alert(ErrMsg.msgDesc);
						return;
					}
					
	  				var mapList = $(response.mapList);
					
					mapList.each(function(i,v){
						newApplyCard(v, apply_card_list_node);
					});
	  			}
			});
		}
		
		<%-- 新建ApplyCard --%>
		function newApplyCard(map, startNode){
		
			var apply_card_node = $('<div>').attr({'class' : 'apply-card', onClick : 'queryImg("' + map.APPLY_ID + '","' + map.GAGE_ADDR + '")'});
			
			$('<div>').attr({'class' : 'apply-card-text apply-no'}).append(map.APPLY_ID).appendTo(apply_card_node);
			$('<div>').attr({'class' : 'apply-card-text apply-address'}).append(map.GAGE_ADDR).appendTo(apply_card_node);
			$('<div>').attr({'class' : 'apply-card-text'}).append('案號:' + (map.COMMUNITY_NO || '')).appendTo(apply_card_node);
			$('<div>').attr({'class' : 'apply-card-text'}).append('案名:' + (map.CASE_NAME || '')).appendTo(apply_card_node);
			$('<div>').attr({'class' : 'apply-card-text'}).append('近一次外觀照日期:' + (map.UPDATE_PIC_DATE || '')).appendTo(apply_card_node);
			
			var IS_UPLOAD = map.IS_UPLOAD;
			
			<%-- IS_UPLOAD為0,顯示"待完成" --%>
			if('0' == IS_UPLOAD){
				var todo_node = $('<div>').attr({'class' : 'apply-operator apply-todo'});
				$('<i>').attr({'class' : 'icon ion-md-camera'}).appendTo(todo_node);
				todo_node.append('<br>待完成');
				apply_card_node.append(todo_node);
			}else if('1' == IS_UPLOAD){
				<%-- IS_UPLOAD為1,顯示"檢視/編輯" --%>
				var edit_node = $('<div>').attr({'class' : 'apply-operator apply-edit'});
				$('<i>').attr({'class' : 'icon ion-md-camera'}).appendTo(edit_node);
				edit_node.append('<br>檢視/編輯');
				apply_card_node.append(edit_node);
			}
			
			apply_card_node.appendTo(startNode);
			
		}
		
    </script>
</body>

</html>