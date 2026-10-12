

function StrToFullSize(targetInput){
	var halfSizeStr = targetInput;
	var fullSizeStr = "";
	var fullSizetargetChar = "";
	var halfSizetargetChar = "";
	for (i=0;i<halfSizeStr.length;i++){
		fullSizetargetChar = "";
		halfSizetargetChar = halfSizeStr.charAt(i);
		if(halfSizetargetChar=="1" || halfSizetargetChar=="¢°"){
			fullSizetargetChar = "¢°";
		}else if(halfSizetargetChar=="2"){
			fullSizetargetChar = "¢±";
		}else if(halfSizetargetChar=="3"){
			fullSizetargetChar = "¢²";
		}else if(halfSizetargetChar=="4"){
			fullSizetargetChar = "¢³";
		}else if(halfSizetargetChar=="5"){
			fullSizetargetChar = "¢´";
		}else if(halfSizetargetChar=="6"){
			fullSizetargetChar = "¢µ";
		}else if(halfSizetargetChar=="7"){
			fullSizetargetChar = "¢¶";
		}else if(halfSizetargetChar=="8"){
			fullSizetargetChar = "¢·";
		}else if(halfSizetargetChar=="9"){
			fullSizetargetChar = "¢¸";
		}else if(halfSizetargetChar=="0"){
			fullSizetargetChar = "¢¯";
		}else if(halfSizetargetChar=="A"){
			fullSizetargetChar = "¢Ï";
		}else if(halfSizetargetChar=="B"){
			fullSizetargetChar = "¢Ð";
		}else if(halfSizetargetChar=="C"){
			fullSizetargetChar = "¢Ñ";
		}else if(halfSizetargetChar=="D"){
			fullSizetargetChar = "¢Ò";
		}else if(halfSizetargetChar=="E"){
			fullSizetargetChar = "¢Ó";
		}else if(halfSizetargetChar=="F"){
			fullSizetargetChar = "¢Ô";
		}else if(halfSizetargetChar=="G"){
			fullSizetargetChar = "¢Õ";
		}else if(halfSizetargetChar=="H"){
			fullSizetargetChar = "¢Ö";
		}else if(halfSizetargetChar=="I"){
			fullSizetargetChar = "¢×";
		}else if(halfSizetargetChar=="J"){
			fullSizetargetChar = "¢Ø";
		}else if(halfSizetargetChar=="K"){
			fullSizetargetChar = "¢Ù";
		}else if(halfSizetargetChar=="L"){
			fullSizetargetChar = "¢Ú";
		}else if(halfSizetargetChar=="M"){
			fullSizetargetChar = "¢Û";
		}else if(halfSizetargetChar=="N"){
			fullSizetargetChar = "¢Ü";
		}else if(halfSizetargetChar=="O"){
			fullSizetargetChar = "¢Ý";
		}else if(halfSizetargetChar=="P"){
			fullSizetargetChar = "¢Þ";
		}else if(halfSizetargetChar=="Q"){
			fullSizetargetChar = "¢ß";
		}else if(halfSizetargetChar=="R"){
			fullSizetargetChar = "¢à";
		}else if(halfSizetargetChar=="S"){
			fullSizetargetChar = "¢á";
		}else if(halfSizetargetChar=="T"){
			fullSizetargetChar = "¢â";
		}else if(halfSizetargetChar=="U"){
			fullSizetargetChar = "¢ã";
		}else if(halfSizetargetChar=="V"){
			fullSizetargetChar = "¢ä";
		}else if(halfSizetargetChar=="W"){
			fullSizetargetChar = "¢å";
		}else if(halfSizetargetChar=="X"){
			fullSizetargetChar = "¢æ";
		}else if(halfSizetargetChar=="Y"){
			fullSizetargetChar = "¢ç";
		}else if(halfSizetargetChar=="Z"){
			fullSizetargetChar = "¢è";
		}else if(halfSizetargetChar=="a"){
			fullSizetargetChar = "¢é";
		}else if(halfSizetargetChar=="b"){
			fullSizetargetChar = "¢ê";
		}else if(halfSizetargetChar=="c"){
			fullSizetargetChar = "¢ë";
		}else if(halfSizetargetChar=="d"){
			fullSizetargetChar = "¢ì";
		}else if(halfSizetargetChar=="e"){
			fullSizetargetChar = "¢í";
		}else if(halfSizetargetChar=="f"){
			fullSizetargetChar = "¢î";
		}else if(halfSizetargetChar=="g"){
			fullSizetargetChar = "¢ï";
		}else if(halfSizetargetChar=="h"){
			fullSizetargetChar = "¢ð";
		}else if(halfSizetargetChar=="i"){
			fullSizetargetChar = "¢ñ";
		}else if(halfSizetargetChar=="j"){
			fullSizetargetChar = "¢ò";
		}else if(halfSizetargetChar=="k"){
			fullSizetargetChar = "¢ó";
		}else if(halfSizetargetChar=="l"){
			fullSizetargetChar = "¢ô";
		}else if(halfSizetargetChar=="m"){
			fullSizetargetChar = "¢õ";
		}else if(halfSizetargetChar=="n"){
			fullSizetargetChar = "¢ö";
		}else if(halfSizetargetChar=="o"){
			fullSizetargetChar = "¢÷";
		}else if(halfSizetargetChar=="p"){
			fullSizetargetChar = "¢ø";
		}else if(halfSizetargetChar=="q"){
			fullSizetargetChar = "¢ù";
		}else if(halfSizetargetChar=="r"){
			fullSizetargetChar = "¢ú";
		}else if(halfSizetargetChar=="s"){
			fullSizetargetChar = "¢û";
		}else if(halfSizetargetChar=="t"){
			fullSizetargetChar = "¢ü";
		}else if(halfSizetargetChar=="u"){
			fullSizetargetChar = "¢ý";
		}else if(halfSizetargetChar=="v"){
			fullSizetargetChar = "¢þ";
		}else if(halfSizetargetChar=="w"){
			fullSizetargetChar = "£@";
		}else if(halfSizetargetChar=="x"){
			fullSizetargetChar = "£A";
		}else if(halfSizetargetChar=="y"){
			fullSizetargetChar = "£B";
		}else if(halfSizetargetChar=="z"){
			fullSizetargetChar = "£C";
		}else if(halfSizetargetChar=="~"){
			fullSizetargetChar = "¡ã";
		}else if(halfSizetargetChar=="!"){
			fullSizetargetChar = "¡I";
		}else if(halfSizetargetChar=="@"){
			fullSizetargetChar = "¢I";
		}else if(halfSizetargetChar=="#"){
			fullSizetargetChar = "¡­";
		}else if(halfSizetargetChar=="$"){
			fullSizetargetChar = "¢C";
		}else if(halfSizetargetChar=="%"){
			fullSizetargetChar = "¢H";
		}else if(halfSizetargetChar=="^"){
			fullSizetargetChar = "¡s";
		}else if(halfSizetargetChar=="&"){
			fullSizetargetChar = "¡®";
		}else if(halfSizetargetChar=="*"){
			fullSizetargetChar = "¡¯";
		}else if(halfSizetargetChar=="("){
			fullSizetargetChar = "¡]";
		}else if(halfSizetargetChar==")"){
			fullSizetargetChar = "¡^";
		}else if(halfSizetargetChar=="_"){
			fullSizetargetChar = "¡Ä";
		}else if(halfSizetargetChar=="+"){
			fullSizetargetChar = "¡Ï";
		}else if(halfSizetargetChar=="-"){
			fullSizetargetChar = "¡Ð";
		}else if(halfSizetargetChar=="="){
			fullSizetargetChar = "¡×";
		}else if(halfSizetargetChar=="{"){
			fullSizetargetChar = "¡a";
		}else if(halfSizetargetChar=="}"){
			fullSizetargetChar = "¡b";
		}else if(halfSizetargetChar=="|"){
			fullSizetargetChar = "¡U";
		}else if(halfSizetargetChar==":"){
			fullSizetargetChar = "¡G";
		}else if(halfSizetargetChar=="\""){
			fullSizetargetChar = "¡¨";
		}else if(halfSizetargetChar=="<"){
			fullSizetargetChar = "¡Õ";
		}else if(halfSizetargetChar==">"){
			fullSizetargetChar = "¡Ö";
		}else if(halfSizetargetChar=="?"){
			fullSizetargetChar = "¡H";
		}else if(halfSizetargetChar=="["){
			fullSizetargetChar = "¡e";
		}else if(halfSizetargetChar=="]"){
			fullSizetargetChar = "¡f";
		}else if(halfSizetargetChar=="\\"){
			fullSizetargetChar = "¢@";
		}else if(halfSizetargetChar==";"){
			fullSizetargetChar = "¡F";
		}else if(halfSizetargetChar=="'"){
			fullSizetargetChar = "¡¦";
		}else if(halfSizetargetChar==","){
			fullSizetargetChar = "¡A";
		}else if(halfSizetargetChar=="."){
			fullSizetargetChar = "¡D";
		}else if(halfSizetargetChar=="/"){
			fullSizetargetChar = "¡þ";
		}else if(halfSizetargetChar=="`"){
			fullSizetargetChar = "¡«";
		}else if(halfSizetargetChar==" "){
			fullSizetargetChar = "";
		}else{
			fullSizetargetChar = halfSizetargetChar;
		}
		fullSizeStr = fullSizeStr + fullSizetargetChar;
	}
	return fullSizeStr;
}


