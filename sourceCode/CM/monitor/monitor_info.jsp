<%@ page contentType="text/html; charset=Big5"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="java.sql.Statement"%>
<%@ page import="java.sql.SQLException"%>
<%@ page import="javax.sql.DataSource"%>
<%@ page import="javax.naming.Context"%>
<%@ page import="javax.naming.InitialContext"%>
<%@ page import="org.apache.log4j.Logger"%>
<%
    Logger log = Logger.getLogger("monitor_info.jsp");
    String strSysCode = request.getParameter("syscode");
    String strSysName = request.getParameter("sysname");
    String strRefresh = request.getParameter("refresh");
    String contextPath = request.getContextPath();

    Date now = new Date();
    DecimalFormat df = new DecimalFormat("#,###");
    DecimalFormat df1 = new DecimalFormat("0.0%");
    DecimalFormat df2 = new DecimalFormat("0%");

    long memorry = Runtime.getRuntime().freeMemory();
    long totalmemo = Runtime.getRuntime().totalMemory();

    double percent = (totalmemo - memorry) * 1.00 / totalmemo;
    String[] colors = { "#0000FF", "#0000FF", "#0000FF", "#0000FF", "#0000FF", "#0000FF", "#006600", "#006600", "#FF6600",
            "#FF0000" };
    String color = colors[(int) (percent * colors.length)];

    Connection con = null;
    ResultSet rs = null;
    Statement stm = null;
    String db2url = ""; //測試業務連線
    if (strSysCode.equals("CM") || strSysCode.equals("IM")) {
        db2url = "jdbc/auth";
    } else {
        db2url = "jdbc/db" + strSysCode.toLowerCase();
    }

    String sql = "select 'isOK' from sysibm.sysdummy1 with ur";
    boolean isOK = true;

    try {

        Context ctx = new InitialContext();
        DataSource ds = (DataSource) ctx.lookup(db2url);
        con = ds.getConnection();

        if (con != null) {
            try {
                stm = con.createStatement();
                rs = stm.executeQuery(sql);
                rs.next();
            } catch (Exception e) {
                isOK = false;
                log.fatal("",e);
            } finally {
                if (rs != null) {
                    rs.close();
                    rs = null;
                }
            }
        } else {
            System.out.println("Connection is null : " + db2url);
            isOK = false;
        }

    } catch (Exception e) {
        isOK = false;
        System.out.println("Connection couldn't be established to (" + db2url + ")");
        log.fatal("",e);
    }

    if (con != null)
        try {
            con.close();
        } catch (SQLException e1) {
            log.fatal("",e1);
        }
    if (stm != null)
        try {
            stm.close();
        } catch (SQLException e1) {
            log.fatal("",e1);
        }
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<meta http-equiv="refresh" content="<%=strRefresh%>; url=monitor_info.jsp?syscode=<%=strSysCode%>&sysname=<%=strSysName%>&refresh=<%=strRefresh%>">
<title></title>
<%@ include file="/html/CM/header.jsp"%>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<center>
<table width="100%" height='100%' border="0" cellpadding="2" cellspacing="0" style='border-right: 1px solid #006600; border-bottom: 1px solid #006600'>
	<tr>
		<td width="5"></td>
		<td style='font-size: 12pt'>
			<div style='color: #000066;'><%=strSysCode%> 連線成功</div>
			<div style='color: #000066; font-size: 11pt'>記憶體使用 : <%=df.format((totalmemo - memorry) / 1000)%> / <%=df.format(totalmemo / 1000)%> KB
				<table width="100%" border=0>
					<tr>
						<td width=70%>
							<table width="100%" height=10 border=1 cellspacing=0 cellpadding=0 BORDERCOLOR="<%=color%>" BORDERCOLORLIGHT="<%=color%>" BORDERCOLORDARK="<%=color%>">
								<tr>
									<%
									    if (!df2.format(percent).equals("0%")) {
									%>
									<td width="<%=df2.format(percent)%>" BGCOLOR="<%=color%>"></td>
									<%
									    }
									    if (!df2.format(percent).equals("100%")) {
									%>
									<td></td>
									<%
									    }
									%>
								</tr>
							</table>
						</td>
						<td><font SIZE="3" COLOR="<%=color%>"> <%=df1.format(percent)%>&nbsp;</font></td>
					</tr>
					<tr>
						<td>DB連線( <%=db2url%>)是否正常 : <%=isOK%></td>
					</tr>
				</table>
			</div>
			<div style='font-size: 11pt; color: #000000;'>[ <%=new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").format(now)%> ]</div>
		</td>
	</tr>
</table>
<table>
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif">
			<img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12">
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif">
			<img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12">
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif">
			<img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12">
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif">
			<img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12">
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif">
			<img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12">
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif">
			<img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12">
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_03.gif">
			<img src="<%=imageBase%>/CM/border_03.gif" width="4" height="12">
		</td>
		<td width="5" class="tbBox">
			<img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1">
		</td>
		<td width="5" class="tbBox">
			<img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1">
		</td>
	</tr>
</table>
</center>
</body>
</html>