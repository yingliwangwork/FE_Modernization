<%@ page language="java" contentType="text/html; charset=big5" %>
<%@ page import="java.util.List"%>
<%

		Map systemInfo = com.cathay.common.service.login.LoginInfoHandler.getSystemInfo(request);
		String sysCode = (String)systemInfo.get("sysCode");
		String APPLY_NO = (String) pageContext.getAttribute("APPLY_NO");

		String className;
		String sysNo;
		String treeTitle;
		if("AT".equals(sysCode)){
			className = "com.cathay.at.m0.module.AT_M0Z001";
			sysNo = "AT";
			treeTitle = "空白要保書輸入";
		} else {
			className = "com.cathay.aa.a4.module.AA_A4Z003";
			sysNo = "AAA4";
			treeTitle = "MI申請書輸入";
		}

    	Class aClass = Class.forName(className);
		java.lang.reflect.Method aMethod = aClass.getMethod("getSubMenuTree", new Class[]{String.class, String.class});
		List treeList = (List)aMethod.invoke(aClass.newInstance(), new String[]{sysNo, APPLY_NO});
		pageContext.setAttribute("treeTitle",treeTitle);
		pageContext.setAttribute("treeList",treeList);

%>
<ul data-role="listview" data-theme="c" >
	<li data-role="list-divider">${treeTitle}</li> 
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