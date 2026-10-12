value=new Array(4);
value[0]=new Array(1);
value[1]=new Array(2);
value[2]=new Array(5);
value[3]=new Array(9);
key=new Array(4);
key[0]=new Array(1);
key[1]=new Array(2);
key[2]=new Array(5);
key[3]=new Array(9);

value[0][0]="請選擇事件類別";
key[0][0]="";

//行銷;
value[1][0]="TS";
value[1][1]="其他";
key[1][0]="B0102";
key[1][1]="B0103";

//增員;
value[2][0]="CIW";
value[2][1]="OPP";
value[2][2]="PA訓";
value[2][3]="3RC";
value[2][4]="其他";
key[2][0]="C0102";
key[2][1]="C0103";
key[2][2]="C0104";
key[2][3]="C0105";
key[2][4]="C0106";

//會議;
value[3][0]="早會";
value[3][1]="夕會";
value[3][2]="分級教育";
value[3][3]="研討檢核";
value[3][4]="培訓";
value[3][5]="經課會議";
value[3][6]="區處會議";
value[3][7]="諮詢人員";
value[3][8]="其他";
key[3][0]="D0102";
key[3][1]="D0103";
key[3][2]="D0104";
key[3][3]="D0105";
key[3][4]="D0106";
key[3][5]="D0107";
key[3][6]="D0108";
key[3][7]="D0109";
key[3][8]="D0110";

function Buildkey(num){
	document.form1.sub_cls_code.selectedIndex=0;
	
	for(ctr=0;ctr<value[num].length;ctr++){
		document.form1.sub_cls_code.options[ctr]=new Option(value[num][ctr],key[num][ctr]);
	}
	document.form1.sub_cls_code.length=value[num].length;
}
