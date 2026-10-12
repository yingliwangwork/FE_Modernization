/**
 * 顯示作業流程視窗，排在右下方
 *
 * @param FLOW_NO 審批流程編號
 * @param openAtNewPopupWin 是否開啟新的popupWin實體
 */
var eventViewWin;
function viewBizEvent(FLOW_NO , openAtNewPopupWin){
    
    if (!window.popupWin || !window.popupWin.popup) {
        alert('使用commView 必須引用 ui/popupWin.js');
        return;
    }

    // 預設使用popupWin所產生的實例
	var openPopup = null;
	if (openAtNewPopupWin === true) {
	    if (!eventViewWin) {
	        eventViewWin = new PopupWinUI();
	    }
	    openPopup = eventViewWin;
	} else {
	    openPopup = popupWin;
	}

    // popupWin參數
	var clientWidth = document.body.clientWidth;
	var clientHeight = document.body.clientHeight;
    var view = document.viewport.getScrollOffsets();

    // 視窗大小 並  預設位置在右上角
	var width = 600;
	var height = 350;
	var left = 5;
	var top = 5;
	if(clientWidth < width){ 
		width = clientWidth - 10;
		left = left + view.left;
	}else{
		left = clientWidth + view.left - width - 10; //10 為右方留邊
	}
	if(clientHeight < height){ 
		height = clientHeight - 10;
		top = top + view.top;
	}else{
		top = clientHeight + view.top - height - 30; //30 為下方留邊
		if (top < 30) { top = 30; }
	}
	
	var wls = window.location.toString();
	var useSysId;
	if (wls.match(/\/J.*Web*/) != null) {
	    useSysId = 'JZ';
	} else if (wls.match(/\/D.*Web*/) != null) {
	    useSysId = 'DZ';
	} else {
	    useSysId = 'RZ';
	}

	var url = '/' + useSysId + 'Web/servlet/HttpDispatcher/' + useSysId + 'N0_0200/prompt?FLOW_NO=' + FLOW_NO;

	openPopup.popup({ 'src': url, 'fixed': true, 'width': width, 'height': height, 'left':left, 'top':top});
}

/**
 * 原核准被修改內容
 *
 * @param table 表格名稱
 * @param pk 查詢值
 * @param openAtNewPopupWin 是否開啟新的popupWin實體
 * @see LS_Z00100 模組
 */
var diffViewWin;
function viewDiffLog(table, pk, openAtNewPopupWin) {

    if (!window.popupWin || !window.popupWin.popup) {
        alert('使用commView 必須引用 ui/popupWin.js');
        return;
    }

    // 預設使用popupWin所產生的實例
    var openPopup = null;
    if (openAtNewPopupWin === true) {
        if (!diffViewWin) {
            diffViewWin = new PopupWinUI();
        }
        openPopup = diffViewWin;
    } else {
        openPopup = popupWin;
    }

    // popupWin參數
    var clientWidth = document.body.clientWidth;
    var clientHeight = document.body.clientHeight;
    var view = document.viewport.getScrollOffsets();

    // 視窗大小
    var width = 250;
    var height = 280;
    var left = 5;
    var top = 30 + view.top; //30 為上方留邊
	if(clientWidth < width){ 
		width = clientWidth - 10;
		left = left + view.left;
	}else{
		left = clientWidth + view.left - width - 10; //10 為右方留邊
	}
    
	var url = '/LSWeb/servlet/HttpDispatcher/BizEvent/viewDiff?table=' + table + '&pk=' + encodeURIComponent(pk);

	openPopup.popup({ 'src': url, 'fixed': true, 'width': width, 'height': height, 'left': left, 'top': top });

}
