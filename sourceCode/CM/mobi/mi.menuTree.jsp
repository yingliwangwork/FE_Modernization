<%@ page language="java" contentType="text/html; charset=big5" %>
<%@ page import="com.cathay.at.m0.module.AT_M0Z001"%>
<%@ page import="java.util.List"%>
<% 
        AT_M0Z001 m0_mod = new AT_M0Z001();
        String APPLY_NO = (String) pageContext.getAttribute("APPLY_NO");
        List treeList = m0_mod.getSubMenuTree("AT", APPLY_NO);
        pageContext.setAttribute("treeList",treeList);
%>
<ul data-role="listview" data-theme="c" >
	<li data-role="list-divider">空白要保書輸入</li> 
	<c:forEach var='bo' items='${treeList}' varStatus="status">
		<c:choose>
			<c:when test="${bo.pgid==PG_ID}">
				<li data-theme="b">
				</c:when>
			<c:otherwise>
				<li>
			</c:otherwise>
		</c:choose>
		<a id="${bo.pgid}" href="${dispatcher}${bo.route}" rel=external>
			<c:choose>
				<c:when test="${bo.font=='RED'}">
					<FONT COLOR='RED'>&#10004;</FONT>
				</c:when>
				<c:otherwise>
					&nbsp;&nbsp;&nbsp;&nbsp;
				</c:otherwise>
			</c:choose>
			${bo.Cname}
		</a>
		</li> 
	</c:forEach>
</ul> 