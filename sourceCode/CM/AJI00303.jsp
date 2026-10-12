<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cathay.aj.i0.module.AJ_I0Z011"%>

<%

	//取出自 trx putValue 中的值
	HttpTxContext txCxt = new HttpTxContext(session);  
	
	Map mainMap = (Map) txCxt.getValue("outputDataMap");
	if(mainMap != null){
		pageContext.setAttribute("vo", mainMap); //設定 Attribute , JSTL 使用
	}
	
%>

<script>
	
	var show_policy_area = true;

	function showPolicy(){
		var obj = document.getElementById("POLICY_AREA");
	    if (show_policy_area) {
			obj.style.display = 'none';
			show_policy_area = false;
			
		}
		else {
			obj.style.display = 'block';
			show_policy_area = true;
		}
	}

</script>

<table width="97%" border="0" cellpadding="0" cellspacing="1">
  <tr>
    <td colspan="2"><span class="textContainTitle"><img src="<%=imageBase%>/CM/B2C/icon_1.gif" width="15" height="13">保單基本資料</span></td>
</tr>
<tr>
  <td colspan="2" align="right"><span class="textDate"><%=AJ_I0Z011.formatDate()%><!--民國98年11月19日 星期四 --> </span></td>
  </tr>
</table>

<table ID='POLICY_AREA' class="tbBox2" border="0" cellpadding="0" cellspacing="1" width="97%">
  <tr> 
    <td width="15%" align="left" class="tbGray" >保單號碼</td>								
    <td width="20%" align="left" class="tbWhite" ><c:out value="${vo.POLICY_NO}" /></td>
    <td width="15%" align="left" class="tbGray" >契約效力</td>
    <td width="16%" align="left" class="tbWhite" >       	
    	<cathay:conver sys="AB" field="EFT_CODE" value="${vo.EFT_CODE}"/>
   		<c:if test="${vo.is_double == 'Y'}">
      	、<cathay:conver sys="AB" field="EFT_CODE" value="${vo.EFT_CODE2}"/>
   		</c:if> 
   	</td>
    <td width="15%" align="left" class="tbGray" >險別</td>
    <td align="left" class="tbWhite" >
    	<c:out value="${vo.PROD_ID}" /> 
    	<c:out value="${vo.PROD_NAME}" /></td>
  </tr>
  <tr>
    <td align="left" class="tbGray" >
	<c:choose>
		<c:when test="${vo.is004 == 'Y'}">主被保人</c:when>
		<c:otherwise>要保人</c:otherwise>
	</c:choose>
    </td>
    <td align="left" class="tbWhite"><c:out value="${vo.APC_NAME}" /></td>
    <td align="left" class="tbGray" >主約保額</td>
    <td align="left" class="tbWhite" >
    	<fmt:formatNumber type="number" value="${vo.FACE_AMT}" pattern="###,###,###.##" /> 
    	<cathay:conver sys="AB" field="FACE_AMT_UNIT" value="${vo.FACE_AMT_UNIT}" /></td>
    <td align="left" class="tbGray" >投保始期</td>
    <td align="left" class="tbWhite" ><cathay:calendar type="ROC" isInput="false" value="${vo.ISSUE_DATE}" /></td>    	
  </tr>
  <tr>
    <td align="left" class="tbGray" >
    
	<c:choose>
		<c:when test="${vo.is004 == 'Y'}">次被保人</c:when>
		<c:otherwise>被保人</c:otherwise>
	</c:choose>
    </td>
    <td align="left" class="tbWhite"><c:out value="${vo.INSD_NAME}"/>
     <c:if test="${vo.is_double == 'Y'}">
             、<c:out value="${vo.INSD_NAME2}"/>
     </c:if></td>
    <td align="left" class="tbGray" >繳費年期</td>
    <td align="left" class="tbWhite" ><c:out value="${vo.PAY_PRD}" />&nbsp;&nbsp;<c:out value="${vo.PAY_PERIOD_MATUR_DESC}" /></td>
    <td align="left" class="tbGray" >下次應繳日</td>
    <td align="left" class="tbWhite" >
    	<c:if test="${vo.MNXT_PAY_DATE!='1911-01-01'}">
		    <cathay:calendar type="ROC" isInput="false" value="${vo.MNXT_PAY_DATE}" />
	    </c:if>
    </td>    
  </tr>
  <tr> 
    <td align="left" class="tbGray" >繳別∕繳次</td>
    <td align="left" class="tbWhite" colspan="5">
		<cathay:conver sys="AB" field="PAY_FREQ" value="${vo.PAY_FREQ}"/>∕<c:out value="${vo.PAY_TIMES}" /></td>
  </tr>  
</table>