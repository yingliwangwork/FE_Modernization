<!DOCTYPE>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<html>

<head>
	<%@ include file='/html/CM/header.jsp'%>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>案件查詢</title>
	<%-- 社區影像(清單) --%>
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
                            <label>縣市別</label>
                            <select id="CITY" name="CITY">
                            <c:forEach var="map" items="${CITY_LIST}">
								<option value="${map.CITY_NAME}" <c:if test="${map.CITY_NAME eq CITY}"> selected </c:if> >${map.CITY_NAME}</option>
							</c:forEach>
                            </select>
							<select id="DIST" name="DIST">
                            </select>
                        </div>
                        <div class="form-flex-filter">
							<label>正面路名</label>
                            <input id="ADDR_NO" name="ADDR_NO" value="${ADDR_NO}"></input>
                        </div>
                        <div class="form-flex-filter">
							<label>案名</label>
                            <input id="CASE_NAME" name="CASE_NAME" value="${CASE_NAME}"></input>
                        </div>
						<button id="btn_query" type="button">查詢</button>
                    </div>
                </form>
                <div class="apply-card-list">
					<c:forEach var="map" items="${mapList}">
                    <div class="apply-card" onClick="queryImg('${map.COMMUNITY_NO}', '${map.CASE_NAME}', '${map.ADDR_NO}')">
                        <div class="apply-card-text apply-no">${map.APPLY_ID}</div>
                        <div class="apply-card-text apply-address">${map.ADDR_NO}</div>
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
				<input id="iCOMMUNITY_NO" name="iCOMMUNITY_NO" type="hidden"></input>
				<input id="iCASE_NAME" name="iCASE_NAME" type="hidden"></input>
				<input id="iADDR_NO" name="iADDR_NO" type="hidden"></input>
				<input id="vCASE_NAME" name="vCASE_NAME" type="hidden"></input>
				<input id="vADDR_NO" name="vADDR_NO" type="hidden"></input>
			</form>
        </article>
    </main>
    <script>

        $(function () {			
			
			<%--  若有APPLY_ID,直接導頁至鑑價影像  --%>
			<%--  沒有ARRP_GROUP,代表從B畫面連回來  --%>
			if('${APPLY_ID}' && !'${APPR_GROUP}'){
				queryImg('${APPLY_ID}');
			}
			
			$('#CITY').bind("change", changeCITY);
			
			$('#btn_query').bind("click", queryForMapList);
			
			
			if('${APPR_GROUP}'){
				<%-- 有ARRP_GROUP,代表從B畫面連回來 --%>
				$('#APPR_GROUP').val('${APPR_GROUP}');<%-- 將下拉選單回填 --%>
				changeCITY('reQuery');<%-- 帶出鑑價人員下拉選單, 但不用重查(後端已經重查) --%>
				$('#APPR_ID').val('${USER_ID}');<%-- 將下拉選單回填 --%>
			}else{
				changeCITY();
			}
			
			var ErrMsg = '${ErrMsg.msgDesc}';
			
			if(ErrMsg){
				alert(ErrMsg);
			}
			
        });
		
		<%-- 連動下拉選單 --%>
		function changeCITY(type){
			var DIST = $('#DIST');
			DIST.empty();
			
			$.ajax({
				type: "POST",
				url:  "${dispatcher}/DSA3_3309/getTownList",
				data: {'CITY_NAME' : $('#CITY').val()},
				async: false,
				success:
					function(response){
						var TOWN_LIST = response.TOWN_LIST;
						TOWN_LIST.forEach(function(val, index){
							DIST.append($('<option>').attr('value', val.TOWN_NAME).text(val.TOWN_NAME));
						});
						if("${DIST}"){
							DIST.val("${DIST}");
						}
					}
			});
		}
		
		<%-- 頁面跳轉到B畫面(照片清單) --%>
		function queryImg(COMMUNITY_NO, CASE_NAME, ADDR_NO){
			$('#iCOMMUNITY_NO').val(COMMUNITY_NO);
			$('#iCASE_NAME').val($('#CASE_NAME').val());
			$('#iADDR_NO').val($('#ADDR_NO').val());
			$('#vCASE_NAME').val(CASE_NAME);
			$('#vADDR_NO').val(ADDR_NO);
			var linkForm = $('#linkForm')[0];
			$('<input>').attr({'id' : 'iCITY', 'name' : 'iCITY' , 'type' : 'hidden', 'value' : $('#CITY').val()}).appendTo(linkForm);
			$('<input>').attr({'id' : 'iDIST', 'name' : 'iDIST' , 'type' : 'hidden', 'value' : $('#DIST').val()}).appendTo(linkForm);
			linkForm.action = '${dispatcher}/DSA3_3309/queryImgByCOMMUNITY_NO';
			linkForm.submit();
		}
		
		<%-- 查詢該ID底下所有案件 --%>
		function queryForMapList(){
			$.ajax({
  			type: "POST",
  			url:  "${dispatcher}/DSA3_3309/queryForMapListByCOMMUNITY_NO",
  			data: {'CITY' : $('#CITY').val(), 'DIST' : $('#DIST').val(), 'CASE_NAME' : $('#CASE_NAME').val(), 'ADDR_NO' : $('#ADDR_NO').val()},
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
		
			var apply_card_node = $('<div>').attr({'class' : 'apply-card', onClick : 'queryImg("' + map.COMMUNITY_NO + '","' + map.CASE_NAME + '","' + map.ADDR_NO + '")'});
			
			$('<div>').attr({'class' : 'apply-card-text apply-no'}).append(map.APPLY_ID).appendTo(apply_card_node);
			$('<div>').attr({'class' : 'apply-card-text apply-address'}).append(map.ADDR_NO).appendTo(apply_card_node);
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