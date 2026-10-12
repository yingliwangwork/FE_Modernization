  function doPrint(reportid,whereStmt) {
    var w = 650;
    var h = 550;
    var l = (screen.availWidth-w)/2;
    var t = ((screen.availHeight-h)/2)-50;
    var attr="toolbar=no,";
    attr += "scrollbars=yes,";
    attr += "location=no,";
    attr += "directories=no,";
    attr += "status=no,";
    attr += "menubar=no,";
    attr += "resizable=yes,";
    attr += "width="+w+",";
    attr += "height="+h+",";
    attr += "left="+l+",";
    attr += "top="+t;
    window.open('http://localhost:9080/html/CM/applet/viewer.jsp?reportid='+reportid + '&wherestmt='+whereStmt, '_blank', attr);
  }