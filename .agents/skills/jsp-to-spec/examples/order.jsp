<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html lang="zh-Hant">
<head><meta charset="utf-8"><title>訂單查詢</title></head>
<body>
<jsp:include page="fragments/header.jsp" />
<h1>訂單查詢</h1>
<form method="get" action="orders/search" onsubmit="return validateSearch()">
  <label for="keyword">客戶名稱</label>
  <input id="keyword" name="keyword" value="<c:out value='${requestScope.keyword}'/>">
  <button type="submit">查詢</button>
</form>
<c:choose>
  <c:when test="${not empty requestScope.error}">
    <p role="alert"><c:out value="${requestScope.error}"/></p>
  </c:when>
  <c:when test="${empty requestScope.orders}">
    <p>查無訂單</p>
  </c:when>
  <c:otherwise>
    <table>
      <thead><tr><th>訂單編號</th><th>客戶名稱</th></tr></thead>
      <tbody>
        <c:forEach var="order" items="${requestScope.orders}">
          <tr><td><c:out value="${order.id}"/></td><td><c:out value="${order.customerName}"/></td></tr>
        </c:forEach>
      </tbody>
    </table>
  </c:otherwise>
</c:choose>
<script>
function validateSearch() {
  if (document.getElementById('keyword').value.trim() === '') {
    alert('請輸入客戶名稱');
    document.getElementById('keyword').focus();
    return false;
  }
  return true;
}
</script>
</body>
</html>
