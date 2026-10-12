<!DOCTYPE>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<html>

<head>
	<%@ include file='/html/CM/header.jsp'%>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>案件查詢</title>
	<%-- 外框(控制iFrame) --%>
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
		
		.tab {
		  overflow: hidden;
		  border: 1px solid #ccc;
		  background-color: #f1f1f1;
		}

		.tab button {
		  background-color: #ADADAD;
		  float: left;
		  border: 1px solid #000000;
		  outline: none;
		  cursor: pointer;
		  padding: 14px 16px;
		  transition: 0.3s;
		  font-size: 17px;
		}

		.tab button:hover {
		  background-color: #FFAF60;
		}

		.tab button.active {
		  background-color: #F75000;
		}
    </style>
</head>

<body>
    <main>
        <article>
            <div>
                <form class="form-flex">
                    <div class="form-flex-filters apply-header">				
						<div class="tab">
							<button id="btn_toApplyId" type="button">鑑價影像</button>
							<button id="btn_toCommunityNo" type="button">社區影像</button>
						</div>
                    </div>
                </form>
				<iframe name="linkToiFrame" frameborder="1px" border="0" cellspacing="0" width="100%" height="100%"></iframe>
				<form id="linkForm" name="linkForm" target="linkToiFrame" style=" border:none" >
					<input id="APPLY_ID" name="APPLY_ID" type="hidden" value="${APPLY_ID}"></input>
				</form>
            </div>
        </article>
    </main>
    <script>

        $(function () {			
			$('#btn_toApplyId').on('click', toApplyId);
			$('#btn_toCommunityNo').on('click', toCommunityNo);
			
			toApplyId();
			
        });
		
		function toApplyId(){
			$("#btn_toApplyId").toggleClass('active', true);
			$("#btn_toCommunityNo").toggleClass('active', false);
			var linkForm = $('#linkForm')[0];
			linkForm.action = '${dispatcher}/DSA3_3309/applyIdPrompt';
			linkForm.submit();
		}
		
		function toCommunityNo(){
			$("#btn_toApplyId").toggleClass('active', false);
			$("#btn_toCommunityNo").toggleClass('active', true);
			var linkForm = $('#linkForm')[0];
			linkForm.action = '${dispatcher}/DSA3_3309/communityNoPrompt';
			linkForm.submit();
		}
		
		
    </script>
</body>

</html>