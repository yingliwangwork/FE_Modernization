/**
目的: 固定表頭於表格上方
用法: 
1. include此js檔
2. 在table前面加上
<div style="height: 300px; overflow: auto;" onscroll="rpt_head_adjust(this.scrollTop,'rpt_head')">
                            ^^^^^^表格長度           ^^^^^^^捲動捲軸的方法
                                                                                                      						^^^^^^^^^^欲固定td區塊的id
3. 在表頭的td tag加上id 名稱
上面的rpt_head_adjust Function帶入的是rpt_head
則表頭td要加上 id="rpt_head"
如 <td rowspan=2 id="rpt_head">
                                                                                                      						
*/
function rpm_head_setvalue(oName,iValue){
 		          oName.style.top=iValue;
		          oName.style.position="relative";
		          oName.style.zIndex=1;
		          oName.className = oName.parentNode.className;
 	}
 
	function rpt_head_adjust(iTop,idName)  
	{ 
	oName = document.all(idName);
	 //判斷上下間距
     	if (typeof(oName) == 'object'){                                //是否為兩層以上 
	var iScrolling=iTop-document.body.scrollTop;
	if (typeof(oName.length)=="number"){
		if (iScrolling>=0){
			for (var j=oName.length-1;j>=0;j--){
				rpm_head_setvalue(oName[j],iScrolling);
			}
		 }else{
		      for (var j=oName.length-1;j>=0;j--){
		      	rpm_head_setvalue(oName[j],0)
		      }
		   }
        }else{
	       if (iScrolling>=0) {
				rpm_head_setvalue(oName,iScrolling)
	       }else{
				rpm_head_setvalue(oName,0)
	       }
        }
     }
     } 
