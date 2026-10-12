
function MM_reloadPage(init) {  //reloads the window if Nav4 resized
  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
    document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}
  else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
}
MM_reloadPage(true);

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_nbGroup(event, grpName) { //v6.0
  var i,img,nbArr,args=MM_nbGroup.arguments;
  if (event == "init" && args.length > 2) {
    if ((img = MM_findObj(args[2])) != null && !img.MM_init) {
      img.MM_init = true; img.MM_up = args[3]; img.MM_dn = img.src;
      if ((nbArr = document[grpName]) == null) nbArr = document[grpName] = new Array();
      nbArr[nbArr.length] = img;
      for (i=4; i < args.length-1; i+=2) if ((img = MM_findObj(args[i])) != null) {
        if (!img.MM_up) img.MM_up = img.src;
        img.src = img.MM_dn = args[i+1];
        nbArr[nbArr.length] = img;
    } }
  } else if (event == "over") {
    document.MM_nbOver = nbArr = new Array();
    for (i=1; i < args.length-1; i+=3) if ((img = MM_findObj(args[i])) != null) {
      if (!img.MM_up) img.MM_up = img.src;
      img.src = (img.MM_dn && args[i+2]) ? args[i+2] : ((args[i+1])? args[i+1] : img.MM_up);
      nbArr[nbArr.length] = img;
    }
  } else if (event == "out" ) {
    for (i=0; i < document.MM_nbOver.length; i++) {
      img = document.MM_nbOver[i]; img.src = (img.MM_dn) ? img.MM_dn : img.MM_up; }
  } else if (event == "down") {
    nbArr = document[grpName];
    if (nbArr)
      for (i=0; i < nbArr.length; i++) { img=nbArr[i]; img.src = img.MM_up; img.MM_dn = 0; }
    document[grpName] = nbArr = new Array();
    for (i=2; i < args.length-1; i+=2) if ((img = MM_findObj(args[i])) != null) {
      if (!img.MM_up) img.MM_up = img.src;
      img.src = img.MM_dn = (args[i+1])? args[i+1] : img.MM_up;
      nbArr[nbArr.length] = img;
  } }
}

function MM_showHideLayers() { //v6.0
  var i,p,v,obj,args=MM_showHideLayers.arguments;
  for (i=0; i<(args.length-2); i+=3) if ((obj=MM_findObj(args[i]))!=null) { v=args[i+2];
    if (obj.style) { obj=obj.style; v=(v=='show')?'':(v=='hide')?'none':v; }
    obj.display=v; }
}

/**
 * 
 * @param tabImg										頁籤所使用之圖檔（2張圖為1組）
 * @param showSpanName							點選頁籤時所要顯示之對應span name
 * @param defultShowIndex						預設顯示之頁籤
 * @param showPageTabSpanName				顯示頁籤之span name
 * @param imageBase									圖檔路徑
 * @param tabStrIndex								頁籤起始之順序（第二層或以上之tab使用才需傳入）
 *
 * @author darkliu 
 * 
 * */
function writePageTag(tabImg,showSpanName,defultShowIndex,showPageTabSpanName,imageBase,tabStrIndex){
	

	// 2張圖為1組
	var tabImgIndex = 2;
	var writeTab = "";
	var tabIndex =1;
	var defultDownImg;
	var defultShowHideLayer;
	
	for(var i=0;i<tabImg.length;i+=tabImgIndex,tabIndex++){
		
		var upImg = tabImg[i];
		
		var downImg = tabImg[i+1];

		if(!tabStrIndex){
			tabStrIndex = tabIndex;
		}
		
		var paraShowHideLayers = "";
		
		// 判斷點選tab所要顯示之span
		for(var j=0;j<showSpanName.length;j++){
			var isShow = (j+1)==tabStrIndex?"show":"hide";
			
			if(paraShowHideLayers!=""){
				paraShowHideLayers += ",";
			}
			
			paraShowHideLayers += "'"+showSpanName[j]+"','','"+isShow+"'";
			
		}
		
		var method_onClick="\"MM_nbGroup('down','group1','tab_"+tabStrIndex+"','"+imageBase+downImg+"',1)\"";
		var mehtod_onMouseOver ="\"MM_nbGroup('over','tab_"+tabStrIndex+"','"+imageBase+downImg+"','',1)\"";
		var method_onMouseOut ="\"MM_nbGroup('out')\"";
		var method_onMouseDown = "\"MM_showHideLayers("+paraShowHideLayers+")\"";
		
		var imgWidth = (tabIndex==1)?"93":"78";
		var imgSrc = "<img src='"+imageBase+upImg+"' alt='' name='tab_"+tabStrIndex+"' width='"+imgWidth+"' height='22' border='0' onMouseDown="+method_onMouseDown+">";
		
		if(defultShowIndex==tabIndex){
			defultDownImg = downImg;
			defultShowHideLayer = "MM_showHideLayers("+paraShowHideLayers+")";
		}
		
		writeTab += "<a href='javascript:;' target='_top' onClick="+method_onClick+" onMouseOver="+mehtod_onMouseOver+" onMouseOut="+method_onMouseOut+">"+imgSrc+"</a>";
		
		tabStrIndex++;

	}
	document.getElementById(showPageTabSpanName).innerHTML = writeTab;
	
	// 將相對應的圖改變
	MM_nbGroup('down','group1','tab_'+defultShowIndex,imageBase+defultDownImg,1);
	
	// 將相對應的資料顯示
	eval(defultShowHideLayer);
	
}
