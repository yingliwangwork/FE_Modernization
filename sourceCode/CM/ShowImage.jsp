<%@ page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%>
<%@ page import="java.io.*" %>
<%@ page import="org.apache.log4j.Logger" %>
<%! Logger log = Logger.getLogger("ShowImage");%>
<%
	request.setCharacterEncoding("Big5");
    String IMAGE_PATH = request.getParameter("IMAGE_PATH");
    if (IMAGE_PATH != null) {
        IMAGE_PATH = IMAGE_PATH.replaceAll(" ", "+");
        OutputStream outputStream = null;
        BufferedInputStream bufferedInputStream = null;
        try {
			IMAGE_PATH = com.cathay.rpt.RptUtils.decrypt(IMAGE_PATH);
			File imageFile = new File(IMAGE_PATH);
			boolean imgTypeMapping = true;
			int imgExtIndex = IMAGE_PATH.lastIndexOf('.');
			String imgExt = "";
			if (imgExtIndex > 0) {
				imgExt = IMAGE_PATH.substring(imgExtIndex + 1);
				if ("gif".equalsIgnoreCase(imgExt)) {
					response.setContentType("image/gif");
				} else if ("png".equalsIgnoreCase(imgExt)) {
					response.setContentType("image/png");
				} else if ("jpg".equalsIgnoreCase(imgExt) || "jpeg".equalsIgnoreCase(imgExt)) {
					response.setContentType("image/jpeg");
				} else if ("tiff".equalsIgnoreCase(imgExt) || "tif".equalsIgnoreCase(imgExt)) {
					response.setContentType("image/tiff");
				} else if ("svg".equalsIgnoreCase(imgExt)) {
					response.setContentType("image/svg+xml");
				} else if ("swf".equalsIgnoreCase(imgExt)) {
					response.setContentType("application/x-shockwave-flash");
				} else if ("bmp".equalsIgnoreCase(imgExt)) {
					response.setContentType("image/bmp");
				} else if ("ico".equalsIgnoreCase(imgExt) || "cur".equalsIgnoreCase(imgExt)) {
					response.setContentType("image/x-icon");
				} else {
					imgTypeMapping = false;
				}
			} else {
				imgTypeMapping = false;
			}
			if (!imgTypeMapping) {
				out.write("ShowImage.jsp 無法解析加密圖檔路徑:" + request.getParameter("IMAGE_PATH"));
				return;
			}
			response.setHeader("Content-disposition", "attachment; filename=showImage." + imgExt);

			outputStream = response.getOutputStream();
			bufferedInputStream = new BufferedInputStream(new FileInputStream(imageFile));
			byte[] bytes = new byte[1];
			while (bufferedInputStream.read(bytes) != -1) {
				outputStream.write(bytes);
			}
		} catch (Exception e) {
			log.fatal("顯示圖檔發生錯誤", e);
			e.printStackTrace();
			throw e;
		} finally {
			if (outputStream != null) {
				outputStream.close();
			}

			if (bufferedInputStream != null) {
				bufferedInputStream.close();
			}

		}
	}
%>