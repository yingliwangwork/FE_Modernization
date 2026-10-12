<%
try {
	List maintainPersonList = new com.cathay.am.z0.module.AM_Z0Z001().getFunctionMaintainPerson(function);
	pageContext.setAttribute("maintainPersonList", maintainPersonList);
} catch(Exception ex) {
}
%>

<table width="300" border="0" cellpadding="0" cellspacing="1"
	class="tbBox3" />
	<tr class="tbBlue" align=center>
		<td colspan=4>網頁維護人</td>
	</tr>
	<tr class="tbBlue2" align=center>
		<td>單位</td>
		<td>姓名</td>
		<td>分機</td>
	</tr>
	<c:forEach var="AM_A0Z001_bo" items="${maintainPersonList}"
		varStatus="status">
		<cathay:even>
			<TR ID='ROWID' align='center' class='tbBlue3'>
		</cathay:even>
		<cathay:odd>
			<TR ID='ROWID' align="center" class='tbYellow2'>
		</cathay:odd>
		<td><c:out value="${AM_A0Z001_bo.DIV_NAME}" /></td>
		<td><c:out value="${AM_A0Z001_bo.EMP_NAME}" /></td>
		<td><c:out value="${AM_A0Z001_bo.TEL}" /></td>
	</c:forEach>
<table>
<script>
function showMainPerPage(){
  layer = document.getElementById("mainPerPage");
  layer.style.top = event.clientY + document.body.scrollTop;
  layer.style.visibility='visible';
}
function hiddenMainPerPage(){
  document.getElementById("mainPerPage").style.visibility='hidden';
}
</script>