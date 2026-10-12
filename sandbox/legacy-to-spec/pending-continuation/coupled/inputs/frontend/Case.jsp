<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="example.Ledger" %>
<%
String reviewerLabel = (String) session.getAttribute("reviewerLabel");
if ("commit".equals(request.getParameter("mode"))) {
    int quantity = Integer.parseInt(request.getParameter("quantity"));
    int charge = quantity >= 4 ? quantity * 8 : quantity * 10;
    Ledger.store((String) session.getAttribute("unitId"), quantity, charge);
}
%>
<!doctype html>
<html lang="zh-Hant">
<head>
  <meta charset="UTF-8">
  <title>項目查閱</title>
  <link rel="stylesheet" href="styles/base.css">
  <script src="legacy-bridge.js"></script>
  <script>
  function searchRows() {
    document.getElementById('status').textContent = '';
    LegacyBridge.searchRows({search_word: document.getElementById('filter').value.trim()}, function(result) {
      const body = document.getElementById('rows');
      body.textContent = '';
      if (result.businessResult === 'DONE') {
        result.itemList.forEach(function(item) {
          const row = body.insertRow();
          row.insertCell().textContent = item.itemKey;
          row.insertCell().textContent = item.itemText;
          row.insertCell().textContent = item.rankHint;
        });
      } else if (result.businessResult === 'NONE') {
        document.getElementById('status').textContent = '沒有項目';
      } else if (result.businessResult === 'BLOCK') {
        document.getElementById('status').textContent = '不允許查閱';
      }
    });
  }
  function submitQuantity() {
    if (document.getElementById('quantity').value === '') {
      alert('數量不得為空');
      return false;
    }
    return true;
  }
  </script>
</head>
<body>
  <h1>項目查閱</h1>
  <p>審閱者：<%= reviewerLabel %></p>
  <label for="filter">關鍵字</label><input id="filter" type="text" maxlength="12">
  <%@ include file="components/action-bar.jspf" %>
  <p id="status"></p>
  <table><thead><tr><th>項目代碼</th><th>名稱</th><th>排序提示</th></tr></thead><tbody id="rows"></tbody></table>
  <form method="post" onsubmit="return submitQuantity()">
    <input type="hidden" name="mode" value="commit">
    <label for="quantity">數量</label><input id="quantity" name="quantity" type="text">
    <button type="submit">送出數量</button>
  </form>
</body>
</html>
