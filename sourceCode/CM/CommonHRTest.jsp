<html>
<head><title>CommonHR Test</title></head>
<body>
CommonHR Test....<br />
<%
java.text.SimpleDateFormat format = new java.text.SimpleDateFormat("yyyy/MM/dd HH:mm:ss:SS");

java.util.Calendar begin = java.util.Calendar.getInstance();
%>
begin at: <%=format.format(begin.getTime())%><br />
<%
cathay.common.hr.CommonHR commonhr = com.cathay.common.hr.CommonHRFactory.getCommonHR();

String tmp = null;

try {
    tmp = commonhr.checkAuthority4Emp("A222416229", "9003300", "A121165927", "FAA02401");
} catch (Exception ex) {
    ex.printStackTrace();
}
%>
<%=tmp%>
<%
java.util.Calendar end = java.util.Calendar.getInstance();
%>
end at: <%=format.format(end.getTime())%>
</body>
</html>