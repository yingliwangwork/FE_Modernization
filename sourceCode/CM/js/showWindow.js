/*
程式：showWindow.js顯示隱藏視窗
作者：新契約小組
功能：提供說明畫面的顯示隱藏
完成：2004/02/05
說明：需要先 <script language="JavaScript" type="text/javascript" src="../js/showWindow.js"></script> 進來。
	 　頁面上的說明文字。　
	　<a href="#" onmouseover="MM_showHideLayers('自定Layer名稱','','show')" onmouseout="MM_showHideLayers('自定Layer名稱','','hide')">作業說明</a>
	
	   頁面上有顯示的說明文字。
	   <div id="自定Layer名稱" style="position:absolute; width:200px; height:60px; z-index:1; left: 300px; top:  180px; visibility: hidden" class="backgroup-blue">
	    <table width="202" border="0" class="backgroup-blue" cellspacing="1" cellpadding="2">	      	
			<tr>
			　　<td>
					說明
			　 </td>
			</tr>
	    </table>
更新：2004/02/06林秉毅－hidden時將位置移開要不會擋到輸入畫面
*/

function MM_findObj(n, d) { //v4.0
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
	d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && document.getElementById) x=document.getElementById(n); return x;
}

function MM_showHideLayers() { //v3.0
  var i,p,v,obj,args=MM_showHideLayers.arguments;
  for (i=0; i<(args.length-2); i+=3) if ((obj=MM_findObj(args[i]))!=null) { v=args[i+2];
	 if (obj.style) { obj=obj.style; v=(v=='show')?'visible':(v='hide')?'hidden':v; }
		obj.visibility=v; 
		//2003/02/06 hidden時將位置移開要不會擋到輸入畫面
		obj.left=(v=="hidden" ? "-600":"100");
	}
}	