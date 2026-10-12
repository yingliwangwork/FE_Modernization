var IconPath, TreeFile, TreeLeft, TreeTop, openAllNode, openMutiNode 
var TmpStr_0, TmpStr_1, LastIndex
var RootItem, RootLink
var NodeItem, VertLine, NodeIcon, ItemIcon, NodeLink, NodeEvent, SwapEvent, ChildNode, TempHTML
var LastPos = 0
var LastIcon
var FontColor = ["black","red","blue"];
//開啟所有 節點的參數
	var tempPara = new Array(5);
	tempPara[0] = new Array(); 
	tempPara[1] = new Array(); 
	tempPara[2] = new Array(); 
	tempPara[3] = new Array(); 
	tempPara[4] = new Array(); 
//

function onDownloadDone(scriptText){
	
	TmpStr_0 = scriptText.replace(/^[\s]+/g,"").replace(/[\s]+$/g,"").split("\n")
	RootItem = TmpStr_0[0].replace(/^[\s]+/g,"").replace(/[\s]+$/g,"").split(",")
	RootLink = (RootItem[2])?	" href=\""
							+	RootItem[2]
							+	"\" target=\""
							+	RootItem[3]
							+	"\" onMouseOver=\"Hilight('Over','Link_0');top.status='"
							+	RootItem[0]
							+	"';return true\" onMouseOut=\"Hilight('Out','Link_0');top.status=''\"onMouseUp=\"Hilight('Down','Link_0');top.status=''\""
							:	" href=\"javascript:void(0)\" onMouseOut=\"Hilight('Out','Link_0');top.status=''\" onMouseOver=\"Hilight('Over','Link_0');top.status='"
							+	RootItem[0]
							+	"';return true\" onMouseUp=\"Hilight('Down','Link_0');top.status=''\""
	TreeRoot.innerHTML = "<table border=\"0\" cellpadding=\"0\" cellspacing=\"1\"><tr><td width=\"16\" height=\"16\"><a"
							+	RootLink
							+	" hidefocus=\"true\"><img height=\"16\" width=\"16\" align=\"texttop\" src=\""
							+	IconPath
							+	RootItem[1].replace(/^[\s]+/g,"").replace(/[\s]+$/g,"")
							+	".gif\" border=0></a></td><td height=\"16\"><div class=\"TreeLink\"><a"
							+	RootLink
							+	" id=\"Link_0\" class=\"Tree_Out\" hidefocus=\"true\">"
							+	RootItem[0]
							+	"</a></div></td></tr></table>"

	//自動載入圖示
	var IconTemper = new Array()
	var IconReader = new Array()
	var IconLoader = new Array()
	
	for(p=0;p<TmpStr_0.length;p++){
		IconTemper[p] = TmpStr_0[p].split(",")
		IconReader[p] = IconTemper[p][1].replace(/^[\s]+/g,"").replace(/[\s]+$/g,"")
	}
	
	IconTemper = IconReader.join()
	IconLoader[0] = "tree_node_e_0"
	IconLoader[1] = "tree_node_e_1"
	IconLoader[2] = "tree_node_e_2"
	IconLoader[3] = "tree_node_n_0"
	IconLoader[4] = "tree_node_n_1"
	IconLoader[5] = "tree_node_n_2"
	IconLoader[6] = "tree_vert"
	IconLoader[7] = "folder_on"		//資料夾開啟圖示，若有必要請自行更改。
	IconLoader[8] = "folder_off"	//資料夾關閉圖示，若有必要請自行更改。
	Collection = IconLoader.join()
	
	n = IconLoader.length
	
	for(l=0;l<IconReader.length;l++){
		if(!Collection.match(IconReader[l])){
			if(IconTemper.match(IconReader[l])){
				IconLoader[n] = IconReader[l]
				Collection = IconLoader.join()
			}
			n++
		}
	}

	var PreloadIcons = new Array()
	
	for(c=0;c<IconLoader.length;c++){
		PreloadIcons[c] = new Image()
		PreloadIcons[c].src = eval('IconPath+IconLoader[c]+".gif"')
	}

	BuildTree(0,0,0,TmpStr_0.length,false)
}

//建立樹狀目錄
function BuildTree(Step,ToPos,Tree_S,Tree_E,Icon){
	if(eval('TreeTemp_'+ToPos).innerHTML){
		eval('TreeTemp_'+ToPos).style.display = (eval('TreeTemp_'+ToPos).style.display=="block")?"none":"block"
		eval('TreeIcon_'+ToPos).src = (eval('TreeTemp_'+ToPos).style.display=="block")?IconPath+Icon+"_on.gif":IconPath+Icon+"_off.gif"
		eval('TreeNode_'+ToPos).src = (eval('TreeTemp_'+ToPos).style.display=="block")?eval('TreeNode_'+ToPos).src.replace("_1","_2"):eval('TreeNode_'+ToPos).src.replace("_2","_1")		
	}else{
		TmpStr_1 = new Array
		var j = 0, k = 0
		for(i=Tree_S;i<Tree_E;i++){
			TmpStr_0[i] = TmpStr_0[i].replace(/^[\s]+/g,"").replace(/[\s]+$/g,"")
		
			if(TmpStr_0[i].search("├")==Step||TmpStr_0[i].search("└")==Step){
				TmpStr_1[j] = new Array
				TmpStr_1[j][0] = TmpStr_0[i]
				TmpStr_1[j][1] = k
				j++
			}else if(TmpStr_0[i].search("├")>Step||TmpStr_0[i].search("└")>Step){
				k++
				TmpStr_1[j-1][1] = TmpStr_1[j-1][1]+1
			}
			k=0
		}
		var v = (Tree_S)?Tree_S:Tree_S+1
		var tempColor = 0;
		var tempCount = 0;

		for(i=0;i<TmpStr_1.length;i++){
			NodeItem = TmpStr_1[i][0].replace(/[├└│　]/g,"").split(",")
			VertLine = (i==TmpStr_1.length-1)?"":"background=\""+IconPath+"tree_vert.gif\""
			NodeIcon = (i==TmpStr_1.length-1)?"e":"n"
			NodeIcon = (TmpStr_1[i][1])?NodeIcon+"_1":NodeIcon+"_0"
			ItemIcon = (TmpStr_1[i][1])?NodeItem[1]+"_off":NodeItem[1].replace(/^[\s]+/g,"").replace(/[\s]+$/g,"")
			
			//設定開啟所有node會用到的參數
			if(openAllNode && TmpStr_1[i][1] ){
				tempPara[0][tempCount] = (Step+1);
				tempPara[1][tempCount] = ToPos+"_"+(i+1);
				tempPara[2][tempCount] = (v+1);
				tempPara[3][tempCount] = (v+TmpStr_1[i][1]+1);
				tempPara[4][tempCount] = NodeItem[1];
				tempCount++;
			}
			//
			
			NodeLink = (NodeItem[2])?	" href=\""
									+	NodeItem[2]
									+	"\" target=\""
									+	"mainFrame"//NodeItem[3]
									+	"\" onMouseOver=\"Hilight('Over','Link_"+v
									+	"');top.status='"
									+	NodeItem[0]
									+	"';return true\" onMouseOut=\"Hilight('Out','Link_"+v
									+	"');top.status=''\" onMouseUp=\"Hilight('Down','Link_"+v
									+	"');top.status=''\""
									:	" onMouseOut=\"Hilight('Out','Link_"+v
//									:	" href=\"javascript:void(0)\" onMouseOut=\"Hilight('Out','Link_"+v									
									+	"');top.status=''\" onMouseOver=\"Hilight('Over','Link_"+v
									+	"');top.status='"
									+	NodeItem[0]
									+	"';return true\" onMouseUp=\"Hilight('Down','Link_"+v
									+	"');top.status=''\""
	
			NodeEvent = (TmpStr_1[i][1])?" onClick=\"BuildTree("
									+	(Step+1)
									+	",'"
									+	ToPos
									+	"_"
									+	(i+1)
									+	"',"
									+	(v+1)
									+	","
									+	(v+TmpStr_1[i][1]+1)+",'"
									+	NodeItem[1]
									+	"')\" style=\"cursor:hand\""
									:	""
			SwapEvent = (TmpStr_1[i][1])?" onClick=\"TreeNode_"
									+	ToPos
									+	"_"
									+	(i+1)
									+	".click()\""
									:	""
			ChildNode = (TmpStr_1[i][1])?"<div id=\"TreeTemp_"
									+	ToPos
									+	"_"
									+	(i+1)
									+	"\" style=\"display:none\"></div>"
									:	""
			//*********************************
			if (NodeItem[4]!=''&&NodeItem[4]<FontColor.length){
				tempColor=NodeItem[4];
			}else{
				tempColor = 0;
			}
			//**************************************
			TempHTML = 	"<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">"
					+ 		"<tr>"
					+			"<td width=\"19\" height=\"16\" valign=\"top\" "+VertLine+">"
					+				"<img id=\"TreeNode_"+ToPos+"_"+(i+1)+"\" width=\"19\" height=\"16\" align=\"texttop\" src=\""+IconPath+"tree_node_"+NodeIcon+".gif\""+NodeEvent+">"
					+			"</td>"
					+			"<td height=\"16\">" 
					+				"<table border=\"0\" cellpadding=\"0\" cellspacing=\"1\">"
					+					"<tr>"
					+						"<td width=\"16\" height=\"16\">"
					+							"<div "+SwapEvent+">"
					+								"<a"+NodeLink+" hidefocus=\"true\">"
					+									"<img border=\"0\" height=\"16\" width=\"16\" id=\"TreeIcon_"+ToPos+"_"+(i+1)+"\" src=\""+IconPath+ItemIcon+".gif\">"
					+								"</a>"
					+							"</div>"
					+						"</td>"
					+						"<td height=\"16\">"
					+							"<div"+SwapEvent+" nowrap class=\"TreeLink\">"
					+								"<a"+NodeLink+" id=\"Link_"+v+"\" class=\"Tree_Out\" hidefocus=\"true\" onClick=\"removeBPM_MemoFrame();\"><font color=\""+FontColor[tempColor]+"\">"
					+									NodeItem[0]
					+								"</font></a>"
					+							"</div>"
					+						"</td>"
					+					"</tr>"
					+				"</table>"
					+				ChildNode
					+			"</td>"
					+		"</tr>"
					+	"</table>"
			eval('TreeTemp_'+ToPos).insertAdjacentHTML("beforeEnd",TempHTML)
			if(ToPos){
				eval('TreeNode_'+ToPos).src = eval('TreeNode_'+ToPos).src.replace("_1","_2")
				eval('TreeIcon_'+ToPos).src = ""+IconPath+Icon+"_on.gif"
				eval('TreeTemp_'+ToPos).style.display = "block"
			}
			v+=TmpStr_1[i][1]
			v++
		}
	}
	
	if(!openAllNode && !openMutiNode){	//當不打開所有選單的前提下由openMutiNode控制是否只開一個子選單
		if(ToPos != 0){
			if(LastPos == 0) {
				LastPos = ToPos
	 			LastIcon = Icon
			} else if (ToPos != LastPos){
				eval('TreeTemp_'+LastPos).style.display = "none"
				eval('TreeIcon_'+LastPos).src = IconPath+LastIcon+"_off.gif"
				eval('TreeNode_'+LastPos).src = eval('TreeNode_'+LastPos).src.replace("_2","_1")
				LastPos = ToPos
	 			LastIcon = Icon
	 		}
	 	}
	 }
}

function Hilight(s,n){
	if(s=="Down"){
		if(LastIndex)
			eval(LastIndex).className = "Tree_Out"
		LastIndex = n
			eval(LastIndex).className = "Tree_Down"
		}else{
			eval(n).className=(eval(n).id==LastIndex)?"Tree_Down":eval("'Tree_'+s")
		}
}

function DrawTree(){
	IconPath=(IconPath)?IconPath:"./"
	if(TreeTop>=0)
		document.body.style.marginTop = TreeTop
	if(TreeLeft>=0)
		document.body.style.marginLeft = TreeLeft
	
	onDownloadDone(st)
	
	//---如果openAllNode為 true, 開啟所有節點
	if (openAllNode){
		for (var i=0; i<tempPara[0].length; i++){
			BuildTree(tempPara[0][i],tempPara[1][i],tempPara[2][i],tempPara[3][i],tempPara[4][i])
		}
	}
	//----
	
}

document.ondragstart 	= new Function("return false")	//關閉拖曳
document.onselectstart 	= new Function("return false")	//關閉選取
//document.oncontextmenu 	= new Function("return false")	//關閉右鍵
window.onload=DrawTree

function removeBPM_MemoFrame(){
	var f = document.getElementById('bpmMemoFrame');
	if(f){
		var mf = document.getElementById('mainFrame');
		mf.height = '95%';		
		f.parentNode.removeChild(f);
	}	
}