<%@ page import="com.cathay.util.ReturnCode"%>
<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="java.io.File"%>
<%@ page import="java.io.OutputStream"%>
<%@ page import="java.net.URLDecoder"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.cathay.common.util.STRING"%>
<%@ page import="javax.servlet.ServletOutputStream"%>
<%@ page import="org.apache.log4j.Logger"%>
<%@ page import="org.apache.commons.collections.MapUtils"%>
<%@ page import="com.cathay.common.im.util.VOTool"%>
<%@ page import="org.apache.commons.lang.exception.ExceptionUtils"%>
<%@ page import="com.cathay.rpt.RptUtils"%>
<%@ page import="com.cathay.ds.a3.module.DS_A33005"%>
<%@ page import="com.cathay.ds.a3.module.DS_A3Z004"%>
<%@ page import="com.cathay.ds.a1.module.DS_A10700"%>
<%@ page import="java.util.List"%>


<%
    Logger log = Logger.getLogger("RengineJSP");
    Runtime runtime = Runtime.getRuntime();

    String ip = request.getRemoteAddr();

	long start_time = System.currentTimeMillis();
    log.fatal("[test start] =============================================================="+start_time);
    
    request.setCharacterEncoding("UTF-8");
    String strContextPath = request.getContextPath();
    strContextPath = (strContextPath == null ? "/" : strContextPath.trim());
    String strSysCode = (String) pageContext.getAttribute("syscode");
	
	String mode = request.getParameter("mode");
	DS_A33005 theDS_A33005 = new DS_A33005();
	DS_A3Z004 theDS_A3Z004 = new DS_A3Z004();
	Map resulMap = new HashMap();
	log.fatal("mode: " + mode);
	if("eval".equals(mode)){		
		String inputParams = request.getParameter("params");
		log.fatal("inputParams: " + inputParams);
		
		if(inputParams == null){
		     resulMap.put("returnCode", ReturnCode.ERROR);
		     resulMap.put("returnMessage", "Error input");
		     out.write(VOTool.toJSON(resulMap));
			 out.flush();
			 return;
		}
		
		try{
			//[20240904] 資訊部門內部專用申請書:240829006291放款科_(高風險)第三方套件安全檢測修正作業
			// 因無使用jDeployR，移除相關套件及程式碼
			resulMap = theDS_A33005.genApprPrice(inputParams);
			resulMap.put("returnCode", ReturnCode.OK);	
			
		}catch(Exception e){
			log.fatal("AVM batch error:",e);
			resulMap.put("returnCode", ReturnCode.ERROR);			
			String errMsg=e.getMessage();
			//判斷是否input已經 URLencode，若否主動encode
        	String errDecode = URLDecoder.decode(errMsg, "utf-8");
        	if(errMsg.equals(errDecode)){
        		errMsg = URLEncoder.encode(errMsg, "utf-8");
        	}
			resulMap.put("returnMessage", errMsg);
			resulMap.put("result", 0.0);				
			resulMap.put("stackTrace", ExceptionUtils.getRootCauseMessage(e));
		}
		response.setContentType("application/json");
		log.debug("resulMap:" + resulMap);
		out.write(VOTool.toJSON(resulMap));
		out.flush();
	
	}else if("geocode".equals(mode)){
		String inputParams = request.getParameter("params");
		log.fatal("inputParams: " + inputParams);
		
		if(inputParams == null){
		     resulMap.put("returnCode", ReturnCode.ERROR);
		     resulMap.put("returnMessage", "Error input");
		     out.write(VOTool.toJSON(resulMap));
			 out.flush();
			 return;
		}
		
		try{
		    Map rtnMap = theDS_A3Z004.getGeoCodeByAddr(inputParams);
			resulMap = VOTool.jsonToMap(URLDecoder.decode(STRING.objToStr(rtnMap.get("jsonStr")), "utf-8"));
			//resulMap.put("returnCode", ReturnCode.OK);	
			
		}catch(Exception e){
			log.fatal("geocode error:",e);
			resulMap.put("returnCode", ReturnCode.ERROR);			
			String errMsg=e.getMessage();
			//判斷是否input已經 URLencode，若否主動encode
        	String errDecode = URLDecoder.decode(errMsg, "utf-8");
        	if(errMsg.equals(errDecode)){
        		errMsg = URLEncoder.encode(errMsg, "utf-8");
        	}
			resulMap.put("returnMessage", errMsg);
			resulMap.put("result", 0.0);				
			resulMap.put("stackTrace", ExceptionUtils.getRootCauseMessage(e));
		}
		response.setContentType("application/json");
		log.debug("resulMap:" + resulMap);
		out.write(URLEncoder.encode(VOTool.toJSON(resulMap), "utf-8"));
		out.flush();
		
	}
	// 鑑價資料優化 修改 DSA3Z004 qryActualPriceDataByNo
	else if("ActualPriceDataByNo".equals(mode)){
		String COMMUNITY_NO = request.getParameter("COMMUNITY_NO");
		log.fatal("COMMUNITY_NO: " + COMMUNITY_NO);
		
		try{
		    Map rtnMap = theDS_A3Z004.qryActualPriceDataByNo(COMMUNITY_NO);
			resulMap = rtnMap;
			//resulMap.put("returnCode", ReturnCode.OK);	
			
		}catch(Exception e){
			log.fatal("geocode error:",e);
			resulMap.put("returnCode", ReturnCode.ERROR);			
			String errMsg=e.getMessage();
			//判斷是否input已經 URLencode，若否主動encode
        	String errDecode = URLDecoder.decode(errMsg, "utf-8");
        	if(errMsg.equals(errDecode)){
        		errMsg = URLEncoder.encode(errMsg, "utf-8");
        	}
			resulMap.put("returnMessage", errMsg);
			resulMap.put("result", 0.0);				
			resulMap.put("stackTrace", ExceptionUtils.getRootCauseMessage(e));
		}
		response.setContentType("application/json");
		log.debug("resulMap:" + resulMap);
		out.write(URLEncoder.encode(VOTool.toJSON(resulMap), "utf-8"));
		out.flush();
		
	}
	/*
	[20210630] 金控資訊作業申請書:21062200019A
	提供銀行查詢電騰資料
	【11.一年內曾有民間設定者】【31.擔保品近一年有限制登記、假扣押、查封、假處分、禁止處分登記】
	*/
	else if("getDPLandData".equals(mode)){
		String inputParams = request.getParameter("params");
		log.fatal("inputParams: " + inputParams);
		
		if(inputParams == null){
		     resulMap.put("returnCode", ReturnCode.ERROR);
		     resulMap.put("returnMessage", "Error input");
		     out.write(VOTool.toJSON(resulMap));
			 out.flush();
			 return;
		}
		
		try{
		    String jsonStr = new DS_A10700().getDPLandDataforBank(inputParams);
			resulMap = VOTool.jsonToMap(URLDecoder.decode(jsonStr, "utf-8"));
		}catch(Exception e){
			log.fatal("getDPLandData error:",e);
			resulMap.put("returnCode", ReturnCode.ERROR);			
			String errMsg=e.getMessage();
			//判斷是否input已經 URLencode，若否主動encode
        	String errDecode = URLDecoder.decode(errMsg, "utf-8");
        	if(errMsg.equals(errDecode)){
        		errMsg = URLEncoder.encode(errMsg, "utf-8");
        	}
			resulMap.put("returnMessage", errMsg);
			resulMap.put("result", 0.0);				
			resulMap.put("stackTrace", ExceptionUtils.getRootCauseMessage(e));
		}
		response.setContentType("application/json");
		log.debug("resulMap:" + resulMap);
		out.write(URLEncoder.encode(VOTool.toJSON(resulMap), "utf-8"));
		out.flush();
		
	}
	/*
	提供銀行查詢離擔保品地址最近的國泰世華分行與距離
	*/
	else if("getApprBranch".equals(mode)){
		String inputParams = request.getParameter("params");
		log.fatal("inputParams: " + inputParams);
		
		if(inputParams == null){
		     resulMap.put("returnCode", ReturnCode.ERROR);
		     resulMap.put("returnMessage", "Error input");
		     out.write(VOTool.toJSON(resulMap));
			 out.flush();
			 return;
		}
		
		try{
		    String rtnJsonStr = theDS_A3Z004.getApprBranch(inputParams);
		    //List<Map> branchList = VOTool.jsonAryToMaps(URLDecoder.decode(rtnJsonStr, "utf-8"));
			//resulMap.put("branchList", branchList);
			Map resMap = VOTool.jsonToMap(URLDecoder.decode(rtnJsonStr, "utf-8"));
			resulMap.put("branchList", MapUtils.getObject(resMap, "branchList"));
			resulMap.put("UID", MapUtils.getObject(resMap, "UID"));
		}catch(Exception e){
			log.fatal("getApprBranch error:",e);
			resulMap.put("returnCode", ReturnCode.ERROR);			
			String errMsg=e.getMessage();
			//判斷是否input已經 URLencode，若否主動encode
        	String errDecode = URLDecoder.decode(errMsg, "utf-8");
        	if(errMsg.equals(errDecode)){
        		errMsg = URLEncoder.encode(errMsg, "utf-8");
        	}
			resulMap.put("returnMessage", errMsg);
			resulMap.put("result", 0.0);				
			resulMap.put("stackTrace", ExceptionUtils.getRootCauseMessage(e));
		}
		
		response.setContentType("application/json");
		log.debug("resulMap:" + resulMap);
		out.write(URLEncoder.encode(VOTool.toJSON(resulMap), "utf-8"));
		out.flush();
	}
		/*查詢該座標位置坐落於哪個區塊
		*/
	else if("getSubmktId".equals(mode)){
		    
	    String inputParams = request.getParameter("params");
		log.fatal("inputParams: " + inputParams);
		
		if(inputParams == null){
		     resulMap.put("returnCode", ReturnCode.ERROR);
		     resulMap.put("returnMessage", "Error input");
		     out.write(VOTool.toJSON(resulMap));
			 out.flush();
			 return;
		}
				 
		try{
		    String rtnJsonStr = theDS_A3Z004.getSubmktId(inputParams);
		    Map submktIdMap = VOTool.jsonToMap(URLDecoder.decode(rtnJsonStr, "utf-8"));
			resulMap.put("submktIdMap", submktIdMap);
		}catch(Exception e){
			log.fatal("getSubmktId error:",e);
			resulMap.put("returnCode", ReturnCode.ERROR);			
			String errMsg=e.getMessage();
			//判斷是否input已經 URLencode，若否主動encode
        	String errDecode = URLDecoder.decode(errMsg, "utf-8");
        	if(errMsg.equals(errDecode)){
        		errMsg = URLEncoder.encode(errMsg, "utf-8");
        	}
			resulMap.put("returnMessage", errMsg);
			resulMap.put("result", 0.0);				
			resulMap.put("stackTrace", ExceptionUtils.getRootCauseMessage(e));
		}
		
		response.setContentType("application/json");
		log.debug("resulMap:" + resulMap);
		out.write(URLEncoder.encode(VOTool.toJSON(resulMap), "utf-8"));
		out.flush();
			
			
	}
	/*
	提供銀行查詢社區編號
	*/
	else if("queryCommunityNo".equals(mode)){
		String inputParams = request.getParameter("params");
		log.fatal("inputParams: " + inputParams);
		
		if(inputParams == null){
		     resulMap.put("returnCode", ReturnCode.ERROR);
		     resulMap.put("returnMessage", "Error input");
		     out.write(VOTool.toJSON(resulMap));
			 out.flush();
			 return;
		}
		
		//FIXME
		try{
		    String rtnJsonStr = theDS_A3Z004.queryCommunityNo(inputParams);
		    Map rtnMap = VOTool.jsonToMap(URLDecoder.decode(rtnJsonStr, "utf-8"));
		    
			resulMap.put("COMMUNITY_NO", rtnMap.get("COMMUNITY_NO"));
			resulMap.put("COMMUNITY_NAME", rtnMap.get("COMMUNITY_NAME"));
			resulMap.put("API_ReturnCode", rtnMap.get("API_ReturnCode"));
			resulMap.put("API_ReturnMsg", rtnMap.get("API_ReturnMsg"));
			resulMap.put("UID", rtnMap.get("UID"));
		}catch(Exception e){
			log.fatal("queryCommunityNo error:",e);
			resulMap.put("returnCode", ReturnCode.ERROR);			
			String errMsg=e.getMessage();
			//判斷是否input已經 URLencode，若否主動encode
        	String errDecode = URLDecoder.decode(errMsg, "utf-8");
        	if(errMsg.equals(errDecode)){
        		errMsg = URLEncoder.encode(errMsg, "utf-8");
        	}
			resulMap.put("returnMessage", errMsg);
			resulMap.put("result", 0.0);				
			resulMap.put("stackTrace", ExceptionUtils.getRootCauseMessage(e));
		}
		
		response.setContentType("application/json");
		log.debug("resulMap:" + resulMap);
		out.write(URLEncoder.encode(VOTool.toJSON(resulMap), "utf-8"));
		out.flush();
	}/*
	提供銀行以社區編號查詢社區公設比資料 [230309004745] 20230313
	*/
	else if("qryCommunityPubRate".equals(mode)){
		String inputParams = request.getParameter("params");
		log.fatal("inputParams: " + inputParams);
		
		if(inputParams == null){
		     resulMap.put("returnCode", ReturnCode.ERROR);
		     resulMap.put("returnMessage", "Error input");
		     out.write(VOTool.toJSON(resulMap));
			 out.flush();
			 return;
		}
		
		//FIXME
		try{
		    String rtnJsonStr = theDS_A3Z004.qryCommunityPubRate(inputParams);
		    Map rtnMap = VOTool.jsonToMap(URLDecoder.decode(rtnJsonStr, "utf-8"));
		    
			resulMap.put("AVG_PUB_RATE", rtnMap.get("AVG_PUB_RATE"));//社區公設比平均值
			resulMap.put("API_ReturnCode", rtnMap.get("API_ReturnCode"));
			resulMap.put("API_ReturnMsg", rtnMap.get("API_ReturnMsg"));
			resulMap.put("UID", rtnMap.get("UID"));
		}catch(Exception e){
			log.fatal("qryCommunityPubRate error:",e);
			resulMap.put("returnCode", ReturnCode.ERROR);			
			String errMsg=e.getMessage();
			//判斷是否input已經 URLencode，若否主動encode
        	String errDecode = URLDecoder.decode(errMsg, "utf-8");
        	if(errMsg.equals(errDecode)){
        		errMsg = URLEncoder.encode(errMsg, "utf-8");
        	}
			resulMap.put("returnMessage", errMsg);
			resulMap.put("result", 0.0);				
			resulMap.put("stackTrace", ExceptionUtils.getRootCauseMessage(e));
		}
		
		response.setContentType("application/json");
		log.debug("resulMap:" + resulMap);
		out.write(URLEncoder.encode(VOTool.toJSON(resulMap), "utf-8"));
		out.flush();
	}/*
	提供銀行以社區編號查詢社區車位資料 [230309004745] 20230314
	*/
	else if("qryCommunityParkInfo".equals(mode)){
		String inputParams = request.getParameter("params");
		log.fatal("inputParams: " + inputParams);
		
		if(inputParams == null){
		     resulMap.put("returnCode", ReturnCode.ERROR);
		     resulMap.put("returnMessage", "Error input");
		     out.write(VOTool.toJSON(resulMap));
			 out.flush();
			 return;
		}
		
		try{
		    Map rtnMap = theDS_A3Z004.qryCommunityParkInfo(inputParams);
		    
			resulMap.put("listParkInfo", rtnMap.get("listParkInfo"));//[list]社區之車位價格(萬/個)
			resulMap.put("API_ReturnCode", rtnMap.get("API_ReturnCode"));
			resulMap.put("API_ReturnMsg", rtnMap.get("API_ReturnMsg"));
			resulMap.put("UID", rtnMap.get("UID"));
		}catch(Exception e){
			log.fatal("qryCommunityPubRate error:",e);
			resulMap.put("returnCode", ReturnCode.ERROR);			
			String errMsg=e.getMessage();
			//判斷是否input已經 URLencode，若否主動encode
        	String errDecode = URLDecoder.decode(errMsg, "utf-8");
        	if(errMsg.equals(errDecode)){
        		errMsg = URLEncoder.encode(errMsg, "utf-8");
        	}
			resulMap.put("returnMessage", errMsg);
			resulMap.put("result", 0.0);				
			resulMap.put("stackTrace", ExceptionUtils.getRootCauseMessage(e));
		}
		
		response.setContentType("application/json");
		log.debug("resulMap:" + resulMap);
		out.write(URLEncoder.encode(VOTool.toJSON(resulMap), "utf-8"));
		out.flush();
	}/*
	提供以經緯度,地址查詢承作等級共用模組 [231206007597] 20231228
	*/
	else if("getAreaCode".equals(mode)){
	    String inputParams = request.getParameter("params");
		log.fatal("inputParams: " + inputParams);
		
		if(inputParams == null){
		     resulMap.put("returnCode", ReturnCode.ERROR);
		     resulMap.put("returnMessage", "Error input");
		     out.write(VOTool.toJSON(resulMap));
			 out.flush();
			 return;
		}
		
		try{
		    Map rtnMap = theDS_A3Z004.getAreaCode(inputParams);
		    
			resulMap.put("rtnMap", rtnMap);
		}catch(Exception e){
			log.fatal("getAreaCode error:",e);
			resulMap.put("returnCode", ReturnCode.ERROR);			
			String errMsg=e.getMessage();
			//判斷是否input已經 URLencode，若否主動encode
        	String errDecode = URLDecoder.decode(errMsg, "utf-8");
        	if(errMsg.equals(errDecode)){
        		errMsg = URLEncoder.encode(errMsg, "utf-8");
        	}
			resulMap.put("returnMessage", errMsg);
			resulMap.put("result", 0.0);				
			resulMap.put("stackTrace", ExceptionUtils.getRootCauseMessage(e));
		}
		
		response.setContentType("application/json");
		log.debug("resulMap:" + resulMap);
		out.write(URLEncoder.encode(VOTool.toJSON(resulMap), "utf-8"));
		out.flush();
	}
%>