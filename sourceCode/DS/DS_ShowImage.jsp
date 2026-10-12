<%@ page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%>
<%@ page import="java.io.*"%>
<%@ page import="org.apache.log4j.Logger"%>
<%@ page import="java.awt.*"%>
<%@ page import="javax.imageio.ImageIO"%>
<%@ page import="java.awt.image.BufferedImage"%>
<%!Logger log = Logger.getLogger("ShowImage");%>
<%
    request.setCharacterEncoding("Big5");
    String IMAGE_PATH = request.getParameter("IMAGE_PATH");
    String STATUS = request.getParameter("STATUS");
    if (IMAGE_PATH != null) {
        IMAGE_PATH = IMAGE_PATH.replaceAll(" ", "+");
        OutputStream outputStream = null;
        BufferedInputStream bufferedInputStream = null;
        ByteArrayInputStream bais = null;
        ByteArrayOutputStream baos = null;
        try {
            IMAGE_PATH = com.cathay.rpt.RptUtils.decrypt(IMAGE_PATH);
            File imageFile = new File(IMAGE_PATH);
			outputStream = response.getOutputStream();
			
			if(!"ORIGINAL".equals(STATUS)){
	            Image img = ImageIO.read(imageFile); // 構造Image對象  
	            int width = img.getWidth(null); // 得到原圖寬  
	            int height = img.getHeight(null); // 得到原圖長
		
	            int w = 100; // 圖寬  
	            int h = (int) (height * w / width); //圖高
	            BufferedImage image = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);
	            image.getGraphics().drawImage(img, 0, 0, w, h, null); // 繪製縮小後的圖
	
				baos = new ByteArrayOutputStream();
	
	            ImageIO.write(image, "jpg", baos);
	            
	            bais = new ByteArrayInputStream(baos.toByteArray());
	            
	            bufferedInputStream = new BufferedInputStream(bais);
			}else{
				bufferedInputStream = new BufferedInputStream(new FileInputStream(imageFile));
			}
			
			byte[] bytes = new byte[1];
            while (bufferedInputStream.read(bytes) != -1) {
                outputStream.write(bytes);
            }

        } catch (Exception e) {
            log.fatal("顯示圖檔發生錯誤", e);
            throw e;
        } finally {
        	
            if (outputStream != null) {
                outputStream.close();
            }
            if (bufferedInputStream != null) {
                bufferedInputStream.close();
            }
            
            if (bais != null) {
                bais.close();
            }
            if (baos != null) {
                baos.close();
            }

        }
    }
%>