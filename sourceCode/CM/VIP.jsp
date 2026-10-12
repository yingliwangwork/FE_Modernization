<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ include file="/html/CM/header.jsp" %>
<%@ page import="com.cathay.common.util.ParsingCodeHelper" %>
<%
/**
	VIP.jsp
	VIP保戶身份辨識作業	
	--------------------------------------------------------------------
	使用方法：JSP在需要顯示VIP字樣位置，加入下面程式，範例：
	
	<c:set var="VIPBO" value="${VIP_APC}" scope="request"/>
	<jsp:include page="/html/CM/VIP.jsp" /> 
	
	VIPBO：固定變數名稱，請勿重複
	VIP_APC：AF_B0Z001回傳的結果，可自由設定此變數名稱
	--------------------------------------------------------------------
	使用方法for Ajax：
	
	JSP加入 <jsp:include page="/html/CM/VIP.jsp" />
	在Ajax中使用 setVIPforAjax
	--------------------------------------------------------------------
	
	@author 壽險程式設計科 謝志杰
	@modified 2011-06-07
	@author 00730755 涂琛琦
	@modify 07/28/2022
*/
%>

<c:if test="${empty VIPID}"><c:set var="VIPID" value="0" scope="request"/></c:if>
<c:set var="VIPID" value="${VIPID+1}" scope="request"/>
<c:choose>
	<c:when test="${VIPBO.VIPF}">
		<span id="vipf${VIPID}" style="font-family: '新細明體'; font-size: 12pt; font-weight: bold; color: blue;">VIP契約關係人</span>
	</c:when>
	<c:otherwise>
		<span id="vipInfo${VIPID}" onMouseOver="showVIPPage('${VIPID}')"
			style="font-family: '新細明體'; font-size: 12pt; font-weight: bold; color: #FF0000;">
			<c:if test="${VIPBO.VIP || VIPBO.VIPOF}">VIP</c:if>
		</span>
	</c:otherwise>
</c:choose>

<span id="vipPage${VIPID}" class="tbLayer" style="position:absolute; display:none; z-index:999; overflow: visible;"
	onMouseOver="if(ppcVTI${VIPID}){clearTimeout(ppcVTI${VIPID});ppcVTI${VIPID}=false;}" onMouseOut="ppcVTI${VIPID}=setTimeout('hideVIPPage(\'${VIPID}\')',500)"  >
<table id="vipTable${VIPID}" width="200" border="0" cellpadding="0" cellspacing="1" class="tbBox2">

	<tr align="center" bgcolor="#a5df00"> 
		<td width="100%" ><font color="#FF0000;" >貴賓別</td></font>
	</tr>
<!---------------------------------JSTL START 顯示boList中的每一筆資料-------------------------------------------------->
<c:set var="vipcount" value="0" />
<c:forEach var="kind" items="${VIPBO.VIP_KIND}" varStatus="status" >
	<tr id="ROWVIP${status.count}" class='tbBlue3' align="center" style="display:none">
		<td bgcolor="#a5df00" > <font color="#FF0000;" ><c:out value="${kind}"/></font>
		</td>
	</tr>
	<c:set var="vipcount" value="${status.count}" />
</c:forEach>
<input name="index" id="index" type="hidden" value="${vipcount}">
<!----------------------------------JSTL END------------------------------------------------------>
<tr bgcolor="#a5df00" <c:if test="${vipcount <=5}">style="display:none"</c:if>>
	<td colspan="2">
		<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1">
			<tr align="left">
				<td>
					<a href='javascript:vipPageController${VIPID}.gotoFirstPage();'><img src='<%=imageBase%>/CM/previous2.gif' border='0' ></a>
					<a href='javascript:vipPageController${VIPID}.gotoPrevPage();'><img src='<%=imageBase%>/CM/previous1.gif' border='0'></a>
					<a href='javascript:vipPageController${VIPID}.gotoNextPage();'><img src='<%=imageBase%>/CM/next1.gif' border='0'></a>
					<a href='javascript:vipPageController${VIPID}.gotoLastPage();'><img src='<%=imageBase%>/CM/next2.gif' border='0'></a>
				</td>
				<td align="right" id="pageControllerBoardVIP${VIPID}">&nbsp;</td>
			</tr>
		</table>
	</td>
</tr>

</table>
</span>

<c:if test="${VIPID eq 1}">
<script>
var ppcIE = ( navigator.appName == "Microsoft Internet Explorer" );
var ppcNN = ( navigator.appName == "Netscape" );

function showVIPPage(vipid) {
	//第一個參數是javaScript中的Form的物件
	//第二個參數是每一頁要顯示的資料筆數
	//第三個參數是每一行資料中的id名稱<TR ID="row">
	//第四個參數是要顯示分頁資訊的id名稱<td id="pageControlerBoard">&nbsp;</td>
		var isIndex = document.getElementById('index');
		if (isIndex) {
			var index = document.getElementById('index').value;
			for (var i=1; i<=index; i++){
				window['vipPageController' + vipid].page(document.getElementById('vipForm' + vipid), 5, 'ROWVIP'+i, 'pageControllerBoardVIP' + vipid);
			}
		}
   // if (ppcIE) {
        var obj = document.getElementById('vipPage' + vipid);
        obj.style.left = document.body.scrollLeft + event.clientX -125;

        if (obj.style.posLeft + obj.style.posWidth >= document.body.scrollWidth) {
            obj.style.left = obj.style.posLeft - (document.body.scrollWidth - (obj.style.posLeft + obj.style.posWidth) + 50);
        }

        obj.style.top  = document.body.scrollTop + event.clientY -5;
        obj.style.display = "block";
    //}

   // else if (ppcNN) {
    	//TODO
   // }
}

function hideVIPPage(vipid) {
	document.getElementById('vipPage' + vipid).style.display = "none";
}

function getVIP_KIND(kind) {
	var vipMap = {};
<%
Map vipMap = ParsingCodeHelper.getInstance().getFieldMap("AF", "VIP_KIND");
for (Iterator itr=vipMap.keySet().iterator(); itr.hasNext();) {
	String key = itr.next().toString();
%>	vipMap['<%=key%>'] = '<%=vipMap.get(key)%>';
<%}%>

	if (!kind) return '';
	return vipMap[kind] ? vipMap[kind] : kind;
}

/** 設定VIP區塊資料 for Ajax
@param vipid 畫面上第幾個顯示VIP區塊 (1, 2, ...)
@param vipBo resp回傳的VIP物件
*/
function setVIPforAjax(vipid, vipBo) {
	//先清除舊資料
	var vipInfo = $('vipInfo' + vipid);
	vipInfo.innerHTML = '';
	var vipTable = $('vipTable' + vipid);
	for (var i=vipTable.rows.length-2; i>0; i--) {
		vipTable.deleteRow(i);
	}
	if (!vipBo || (!vipBo.VIPF && !vipBo.VIP && !vipBo.VIPOF)) {
		return;
	} else if (vipBo.VIPF) {
		vipInfo.innerHTML = 'VIP契約關係人';
		vipInfo.style.color='blue';
		vipTable.style.display = 'none';
	} else {
		vipInfo.innerHTML = 'VIP';
		vipInfo.style.color='FF0000';
		for (i=0; i<vipBo.VIP_KIND.length; i++) {
			var vipRow = vipTable.insertRow(i+1);
			vipRow.id = 'ROWVIP'+(i+1);
			vipRow.className = 'tbBlue3';
			vipRow.style.textAlign = 'center';
			vipRow.style.display = 'none';
			
			var vipCell = vipRow.insertCell(0);
	//		vipCell.innerHTML = i+1;
	//		vipCell = vipRow.insertCell(1);
			vipCell.style.backgroundColor='#a5df00';
			vipCell.style.color='#FF0000';
			vipCell.innerHTML = getVIP_KIND(vipBo.VIP_KIND[i]);
		}
		var index_element = document.createElement("input");
		//設定這個index的屬性
		index_element.type = "hidden";
		index_element.name = "index";
		index_element.id = "index";
		index_element.value = vipBo.VIP_KIND.length;
		vipTable.show();
		vipTable.appendChild(index_element);
	}
}

function VIPPageController() {
	this.obj = obj;
	this.page = page;
	this.gotoFirstPage = gotoFirstPage;
	this.gotoLastPage = gotoLastPage;
	this.gotoNextPage = gotoNextPage;
	this.gotoPrevPage = gotoPrevPage;
	this.gotoPage = gotoPage;
	this.getShowCurPage = getShowCurPage;
	this.getShowTotalPage = getShowTotalPage;
	this.getShowTotalRecord = getShowTotalRecord;
	this.getPageNavInfo = getPageNavInfo;
	
	var obj = {
		rowElements: null,
		totalrecord: 0,
		totalpages: 0,
		pagesize: 10,
		curpage: 0,
		fetchRows: null,
		pageinfo: null
	};

	function page(form, size, rowid, infoid, fetchTR) {
		//IE11問題修改
		//obj.rowElements = form.all( rowid );	
		obj.rowElements = document.getElementById( rowid );	
		if (obj.rowElements && obj.rowElements.length) {
			if (fetchTR) {
				obj.fetchRows = fetchTR;
				obj.totalrecord = obj.rowElements.length / obj.fetchRows;
			}else{
				obj.totalrecord = obj.rowElements.length;		
			}
		}else{
			obj.totalrecord = 1;//只有一筆資料
		}
		obj.pagesize = size;
		obj.totalpages = parseInt(obj.totalrecord/obj.pagesize);
		if ((obj.totalrecord % obj.pagesize) != 0) {
			obj.totalpages++;
		}
		obj.pageinfo = document.getElementById(infoid);
	    
		gotoPage(0);
	};
	
	function gotoFirstPage() {
		gotoPage(0);
	};
	
	function gotoLastPage() {
		gotoPage(parseInt(obj.totalpages - 1));
	};
	
	function gotoNextPage() {
		gotoPage(parseInt(obj.curpage) + 1);
	};
	
	function gotoPrevPage() {
		gotoPage(parseInt(obj.curpage) - 1);
	};
	
	function gotoPage(n) {		
		/**檢查傳入頁數是否正確*/
		if (( n < 0) || (n >= obj.totalpages)) {
			return;
		}
		
		/**隱藏前一頁資料*/
		var bgn = obj.curpage * obj.pagesize;
		if (bgn < 0) {
			bgn = 0;
		}
		var end = obj.pagesize * (1 + obj.curpage);
		if (end > obj.totalrecord) {
			end = obj.totalrecord;
		}
	
		for (var i = bgn; i < end; i++) {
			if (!obj.rowElements) {
				return;
			}
			if (obj.rowElements[i]) {
				if (obj.fetchRows) {
					var j = i * obj.fetchRows;
					for (var k = 0; k < obj.fetchRows; k++) {
						obj.rowElements[j+k].style.display = 'none';	
					}
				} else {
					obj.rowElements[i].style.display = 'none';			
				}
			}else{
				//當資料只有一筆時e的型態不是陣列所以e[0]會是沒有定義
				obj.rowElements.style.display = 'none';
				break;
			}
		}
		
		/**顯示此頁資料*/
		var bgns = n * obj.pagesize;
		if (bgns<0) {
			bgns = 0;
		}
		var ends = obj.pagesize * (1 + n);
		if (ends > obj.totalrecord) {
			ends = obj.totalrecord;
		}
		for (var i = bgns; i < ends; i++) {
			if (obj.rowElements[i]) {
				if (obj.fetchRows) {
					var j = i * obj.fetchRows;
					for (var k = 0; k < obj.fetchRows; k++) {
						obj.rowElements[j + k].style.display = 'block';	
					}
				} else {
					obj.rowElements[i].style.display = 'block';			
				}
			}else{
				//當資料只有一筆時e的型態不是陣列所以e[0]會是沒有定義
				obj.rowElements.style.display = 'block';
				break;
			}
		}
		
		obj.curpage = n;
		//顯示分頁訊息
		if (obj.pageinfo) {
			obj.pageinfo.innerText = getPageNavInfo();
		}
	};
	
	/**回傳show在頁面上的目前頁*/
	function getShowCurPage() {
		return parseInt(obj.curpage) + 1;
	};
	
	/**回傳show在頁面上的總頁數*/
	function getShowTotalPage() {
		return obj.totalpages;
	};
	
	/**取得所有資料筆數*/
	function getShowTotalRecord() {
		return obj.totalrecord;
	};
	
	/**
	 * 回傳show在頁面上的分頁訊息預設值
	 * ex "第"+ showcurpage+ "/" +showtotalpage+ "頁  共"+totalrecord+"件";
	 */
	function getPageNavInfo() {
		var msg = "第" + getShowCurPage(obj) +"/" + getShowTotalPage(obj) + "頁,  共" + getShowTotalRecord(obj) + "件";
	    return msg;
	};
} //end VIPPageController
</script>
</c:if>

<script>
var ppcVTI${VIPID} = false;
var vipPageController${VIPID} = new VIPPageController();
var vipPage = document.getElementById('vipPage${VIPID}');
var vipForm = document.createElement('form');
vipForm.name = 'vipForm${VIPID}';
vipForm.id = 'vipForm${VIPID}';
vipForm.appendChild(vipPage);
document.body.appendChild(vipForm);
</script>