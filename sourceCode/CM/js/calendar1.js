
<!--
/********************************************************************
時間：2004-01-01
作者：Smart
功能：日曆式日期選擇控件
 
參數：
說明：
1.輸入框直接調用用以下代碼
<Script>DateBox("InputName","DateValue")<\/Script>
其中:InputName 為輸入日期的文本框.注:不能為空.
       DateValue  為輸入日期的文本框默認日期值.格式為:YYYY-MM-DD.如2004-01-01
                       此值可以不填或為空.則默認值為當天日期.(客戶端)
2.其它"按鈕"調用用以下代碼
CallDate("InputName")
其中:InputName 為輸入日期的文本框.注:不能為空.

修改區

時間：
修改人：
原因：

********************************************************************/
/*基本參數*/
var Frw=145; //日曆寬度
var Frh=137; //日曆高度
var Frs=4;     //影子大小
var Hid=true;//日曆是否打開
/*創建框架*/
document.writeln('<Div id=Calendar Author=smart  scrolling="no" frameborder=0 style="border:0px solid #EEEEEE ;position: absolute; width: '+Frw+'; height: '+Frh+'; z-index: 0; filter :\'progid:DXImageTransform.Microsoft.Shadow(direction=135,color=#AAAAAA,strength='+Frs+')\' ;display: none"></Div>');
/*取得今日日期*/
function GetTodayDate()
{
   today= new Date();  
   //today = document.getElementById("TODAY").value;    // 讀PC時間
   y= today.getYear();
   m= (today.getMonth() + 1);
   if (m<10)
   {
     m='0'+m;
   }
   d= today.getDate();
   if (d<10)
   {
     d='0'+d;
   }
return y+'-'+m+'-'+d
}
/*輸入今天日期*/
function SetTodayDate(InputBox)
{
  HiddenCalendar();
  InputBox.value=GetTodayDate();
}
/*取某年某月第一天的星期值(月份-1)*/
function GetFirstWeek(The_Year,The_Month)
{
  return (new Date(The_Year,The_Month-1,1)).getDay()
}
/*取某年某月中總天數*/
function GetThisDays(The_Year,The_Month)
{
  return (new Date(The_Year,The_Month,0)).getDate()
}
/*取某年某月上個月中總天數*/
function GetLastDays(The_Year,The_Month)
{
  return (new Date(The_Year,The_Month-1,0)).getDate()
}
/*判斷是否是閏年*/
function RunNian(The_Year)
{
 if ((The_Year%400==0) || ((The_Year%4==0) && (The_Year%100!=0)))
  return true;
 else
  return false;
}
/* 判斷日期(YYYY-MM-DD)的日期是否正確 */
function DateIsTrue(asDate){
 var lsDate  = asDate + "";
 var loDate  = lsDate.split("-");
 if (loDate.length!=3) return false; 
 var liYear  = parseFloat(loDate[0]);
 var liMonth = parseFloat(loDate[1]);
 var liDay   = parseFloat(loDate[2]);
 if ((loDate[0].length>4)||(loDate[1].length>2)||(loDate[2].length>2)) return false;
 if (isNaN(liYear)||isNaN(liMonth)||isNaN(liDay)) return false;
 if ((liYear<1800)||(liYear>2500)) return false;
 if ((liMonth>12)||(liMonth<=0))   return false;
 if (GetThisDays(liYear,liMonth)<liDay) return false;
 return !isNaN(Date.UTC(liYear,liMonth,liDay));
}
/*取某年某月的周值*/
function GetCountWeeks(The_Year,The_Month)
{
 var Allday;
 Allday = 0;
 if (The_Year>2000)
 {
  
  for (i=2000 ;i<The_Year; i++) 
   if (RunNian(i)) 
    Allday += 366;
   else
    Allday += 365;
  for (i=2; i<=The_Month; i++)
  {
   switch (i)
   {
      case 2 : 
       if (RunNian(The_Year))
        Allday += 29;
       else
        Allday += 28;
       break;
      case 3 : Allday += 31; break;
      case 4 : Allday += 30; break;
      case 5 : Allday += 31; break;
      case 6 : Allday += 30; break;
      case 7 : Allday += 31; break;
      case 8 : Allday += 31; break;
      case 9 : Allday += 30; break;
      case 10 : Allday += 31; break;
      case 11 : Allday += 30; break;
      case 12 :  Allday += 31; break;
   }
  }
 }
return (Allday+6)%7;
}
/*輸入框顯示*/
function InputValue(InputBox,Year,Month,Day)
{
  Year = parseInt(Year)-1911;
  if (Month<10)
  {
    Month='0'+Month
  }
  if (Day<10)
  {
    Day='0'+Day
  }
  //InputBox.value=Year+"-"+Month+"-"+Day
  InputBox.value=Year+""+Month+""+Day
}
//上一月
function ForwardMonth(InputBox,Year,Month,Day)
{
	var posZ;
	posZ = document.body.scrollTop;
	
    Month=Month-1;
    if (Month<1)
    {
        Month=12;
        Year=Year-1;
        if (Year<1800)
            Year=2500;
    }
  Day=((GetThisDays(Year,Month)<Day)?GetThisDays(Year,Month):Day)
  Hid=false;
  ShowCalendar(InputBox,posZ,Year,Month,Day)
}
//下一月
function NextMonth(InputBox,Year,Month,Day)
{
	var posZ;
	posZ = document.body.scrollTop;
	
    Month=Month+1;
    if (Month>12)
    {
        Month=1;
        Year=Year+1;
        if (Year>2500)
            Year=1800;
    }
  Day=((GetThisDays(Year,Month)<Day)?GetThisDays(Year,Month):Day)
  Hid=false;
  ShowCalendar(InputBox,posZ,Year,Month,Day)
}
//上一年
function ForwardYear(InputBox,Year,Month,Day)
{
	var posZ;
	posZ = document.body.scrollTop;

    Year=Year-1;
    if (Year<1800)
        Year=2500;
  Day=((GetThisDays(Year,Month)<Day)?GetThisDays(Year,Month):Day)
  Hid=false;
  ShowCalendar(InputBox,posZ,Year,Month,Day)
}
//下一年
function NextYear(InputBox,Year,Month,Day)
{
	var posZ;
	posZ = document.body.scrollTop;

    Year=Year+1;
    if (Year>2500)
        Year=1800;
  Day=((GetThisDays(Year,Month)<Day)?GetThisDays(Year,Month):Day)
  Hid=false;
  ShowCalendar(InputBox,posZ,Year,Month,Day)
}
/*其它事件顯示日曆*/
//function OpenDate(where)
function getCalendarFor(where)
{
 var posZ;
 posZ = document.body.scrollTop;

 GetCalendar(where,posZ)
}

/*根據輸入框中的日期顯示日曆*/
function GetCalendar(where,posZ)
{
    Hid=false;
    var Box_Name=where.name;
    var Box_value=where.value;
    if (DateIsTrue(Box_value))
    {
    loDate  = Box_value.split("-");
    Y= parseFloat(loDate[0]);
    M= parseFloat(loDate[1]);
    D= parseFloat(loDate[2]);
    ShowCalendar(where,posZ,Y,M,D);
    }
  else
  {
    today= new Date();  
	//today = document.getElementById("TODAY").value;  //讀PC時間
    y= today.getYear();
    m= (today.getMonth() + 1);
    d=today.getDate();
    ShowCalendar(where,posZ,y,m,d);
  }
}

/*隱藏日曆*/
function HiddenCalendar()
{
    document.all.Calendar.style.display="none";
}
function CloseCalendar()
{
  if (Hid)
    document.all.Calendar.style.display="none";
  Hid=true;
}
/*顯示日曆*/
function ShowCalendar(InputBox,posZ,The_Year,The_Month,The_Day)
{
    var Now_Year=(The_Year==null?2004:The_Year);
    var Now_Month=(The_Month==null?1:The_Month);
    var Now_Day=(The_Day==null?1:The_Day);
    var Box_Name='window.document.all.'+InputBox.name;
    var fw=GetFirstWeek(Now_Year,Now_Month);
    var ld=GetLastDays(Now_Year,Now_Month);
    var td=GetThisDays(Now_Year,Now_Month);
    var isnd=false;//是否是下個月的日期
    var d=1,w=1;
    var FrameContent;
    var Frl,Frt,Winw,Winh;
/*顯示的位置*/
Winw=document.body.offsetWidth;
Winh=document.body.offsetHeight;
Frl=InputBox.getBoundingClientRect().left-2;
Frt=InputBox.getBoundingClientRect().top+InputBox.clientHeight;
//if (((Frl+Frw+Frs)>Winw)&&(Frw+Frs<Winw))
//  Frl=Winw-Frw-Frs;
//if ((Frt+Frh+Frs>Winh)&&(Frh+Frs<Winh))
//  Frt=Winh-Frh-Frs;
if ((Frt+Frh+Frs>Winh)&&(Frh+Frs<Winh))
  Frt=Frt-163;

document.all.Calendar.style.display="";
document.all.Calendar.style.left=Frl;
document.all.Calendar.style.top=Frt+posZ;

//顯示日曆內容
FrameContent="\n<table onselectstart=\"return false;\" border='0' cellpadding='0' cellspacing='0' bgcolor='#4682B4' width='100%' height='20' style=\"color:white;font-weight:bolder;border:0px solid\">"+"\n<tr>\n";
FrameContent+="<td class='tdcalendar' width=8>";
FrameContent+="<img src='../../../images/CM/prev_y.gif' width='16' height='16' border='0' alt='上一年' style='cursor:hand' onclick=\"ForwardYear (window.document.all."+InputBox.name+","+Now_Year+","+Now_Month+","+Now_Day+")\">";
FrameContent+="</td>\n";
FrameContent+="<td class='tdcalendar' vAlign=middle align='center'>";
FrameContent+=Now_Year-1911;
FrameContent+="年";
FrameContent+="</td>\n";
FrameContent+="<td class='tdcalendar' width=8>";
FrameContent+="<img src='../../../images/CM/next_y.gif' width='16' height='16' border='0' alt='下一年' style='cursor:hand' onclick=\"NextYear (window.document.all."+InputBox.name+","+Now_Year+","+Now_Month+","+Now_Day+")\">";
FrameContent+="</td>\n";
FrameContent+="<td class='tdcalendar' width=8>";
FrameContent+="<img src='../../../images/CM/prev.gif' width='16' height='16' border='0' alt='上一月' style='cursor:hand' onclick=\"ForwardMonth (window.document.all."+InputBox.name+","+Now_Year+","+Now_Month+","+Now_Day+")\">";
FrameContent+="</td>\n";
FrameContent+="<td class='tdcalendar' vAlign=middle align='center' width='16'>";
FrameContent+=Now_Month;
FrameContent+="</td>\n";
FrameContent+="<td class='tdcalendar' vAlign=middle align='center' width='13'>";
FrameContent+="月";
FrameContent+="</td>\n";
FrameContent+="<td class='tdcalendar' width=8>";
FrameContent+="<img src='../../../images/CM/next.gif' width='16' height='16' border='0' alt='下一月' style='cursor:hand' onclick=\"NextMonth (window.document.all."+InputBox.name+","+Now_Year+","+Now_Month+","+Now_Day+")\">";
FrameContent+="</td>"+"\n";
FrameContent+="</tr>"+"\n";
FrameContent+="</table>"+"\n";
FrameContent+="<table onselectstart=\"return false;\" border='0' cellpadding='0' cellspacing='1' width='100%' bgcolor='#CCCCCC'>"+"\n";
FrameContent+="<tr bgcolor='#F5F5F5'>"+"\n";
FrameContent+="<td class='tdcalendar'><center>一</center></td>"+"\n";
FrameContent+="<td class='tdcalendar'><center>二</center></td>"+"\n";
FrameContent+="<td class='tdcalendar'><center>三</center></td>"+"\n";
FrameContent+="<td class='tdcalendar'><center>四</center></td>"+"\n";
FrameContent+="<td class='tdcalendar'><center>五</center></td>"+"\n";
FrameContent+="<td class='tdcalendar'><center>六</center></td>"+"\n";
FrameContent+="<td class='tdcalendar'><center><font color='#FF0000'>日</font></center></td>"+"\n";
FrameContent+="</tr>"+"\n";
//如果本月第一天是星期一或星期天.應加上七.保證可以看到上個月的日期
    if (fw<2)
      tf=fw+7;
    else
      tf=fw;
      FrameContent+="<tr bgcolor='#FFFFFF'>"+"\n";
      //第一行上月日期
      for (l=(ld-tf+2);l<=ld;l++)
      {
        FrameContent+="<td class='tdcalendar'  onclick=\"ForwardMonth (window.document.all."+InputBox.name+","+Now_Year+","+Now_Month+","+l+")\" style='cursor:hand'><center><font color='#BBBBBB'>"+l+"</font></center></td>"+"\n";
        w++;
      }
      //第一行本月日期
      for (f=tf;f<=7;f++)
      {
         //星期天但非輸入日期
         if (((w%7)==0)&&(d!=Now_Day))
           FrameContent+="<td class='tdcalendar' onMouseOver=\"this.style.background=\'#E1E1E1\'\" onMouseOut=\"this.style.background=\'#FFFFFF\'\" onClick=\"InputValue(window.document.all."+InputBox.name+","+Now_Year+","+Now_Month+","+d+");HiddenCalendar()\" style='cursor:hand'><center><font color='#FF0000'>"+d+"</font></center></td>"+"\n";
         //日期為輸入日期
         else if (d==Now_Day)
           FrameContent+="<td class='tdcalendar' style=\"background:#420042;cursor:hand\" onClick=\"InputValue(window.document.all."+InputBox.name+","+Now_Year+","+Now_Month+","+d+");HiddenCalendar()\"><center><font color='#FFFFFF'>"+d+"</font></center></td>"+"\n";
         //其它
         else
           FrameContent+="<td class='tdcalendar' onMouseOver=\"this.style.background=\'#E1E1E1\'\" onMouseOut=\"this.style.background=\'#FFFFFF\'\" onClick=\"InputValue(window.document.all."+InputBox.name+","+Now_Year+","+Now_Month+","+d+");HiddenCalendar()\" style='cursor:hand'><center>"+d+"</center></td>"+"\n";
        d++;
        w++;
      }
      FrameContent+="</tr>"+"\n";
    w=1;
    for (i=2;i<7;i++)
    {
      FrameContent+="<tr bgcolor='#FFFFFF'>"+"\n";
      for (j=1;j<8;j++)
      {
         if (isnd)//下個月的日期
         FrameContent+="<td class='tdcalendar' style='cursor:hand' onclick=\"NextMonth (window.document.all."+InputBox.name+","+Now_Year+","+Now_Month+","+d+")\"><center><font color='#BBBBBB'>"+d+"</font></center></td>"+"\n";
         else//本月的日期
        {
           //星期天但非輸入日期
           if (((w%7)==0)&&(d!=Now_Day))
             FrameContent+="<td class='tdcalendar' onMouseOver=\"this.style.background=\'#E1E1E1\'\" onMouseOut=\"this.style.background=\'#FFFFFF\'\" onClick=\"InputValue(window.document.all."+InputBox.name+","+Now_Year+","+Now_Month+","+d+");HiddenCalendar()\" style='cursor:hand'><center><font color='#FF0000'>"+d+"</font></center></td>"+"\n";
           //日期為輸入日期
           else if (d==Now_Day)
             FrameContent+="<td class='tdcalendar' style=\"background:#420042;cursor:hand\" onClick=\"InputValue(window.document.all."+InputBox.name+","+Now_Year+","+Now_Month+","+d+");HiddenCalendar()\"><center><font color='#FFFFFF'>"+d+"</font></center></td>"+"\n";
           //其它
           else
             FrameContent+="<td class='tdcalendar' onMouseOver=\"this.style.background=\'#E1E1E1\'\" onMouseOut=\"this.style.background=\'#FFFFFF\'\" onClick=\"InputValue(window.document.all."+InputBox.name+","+Now_Year+","+Now_Month+","+d+");HiddenCalendar()\" style='cursor:hand'><center>"+d+"</center></td>"+"\n";
        }
        //判斷是否為本月的日期
        if (d==td)
        {
          isnd=true;
          d=0;
        }
        w++;
        d++;
      }
      FrameContent+="</tr>"+"\n";
    }
FrameContent+="</table>"+"\n";
FrameContent+="<table onselectstart=\"return false;\" cellpadding='0' cellspacing='0' bgcolor='#F5F5F5' width='100%' height='15'>"+"\n<tr>\n";
FrameContent+="<td class='tdcalendar' title=\"今日:"+GetTodayDate()+"\" style=\"cursor:hand\" onclick=\"SetTodayDate(window.document.all."+InputBox.name+")\">";
FrameContent+="<font color=red>今日:</font>"+GetTodayDate();
FrameContent+="</td>\n";
FrameContent+="<td class='tdcalendar'>";
FrameContent+="<img src='../../../images/CM/close.gif' width='13' height='13' border='0' alt='關閉' style='cursor:hand' onclick=\"HiddenCalendar()\">";
FrameContent+="</td>\n";
FrameContent+="</tr>\n";
document.all.Calendar.innerHTML=FrameContent;
document.all.Calendar.style.display="";
}
/*顯示輸入框*/
function DateBox(sBoxName, sDfltValue)
{
    if (sBoxName==null)
        sBoxName='Date_Box'
    if ((sDfltValue==null)||!(DateIsTrue(sDfltValue)))
        sDfltValue= GetTodayDate()
    else 
    {
      DateStr  = sDfltValue.split("-");
      Y= parseFloat(DateStr[0]);
      M= (parseFloat(DateStr[1])<10)?('0'+parseFloat(DateStr[1])):parseFloat(DateStr[1]);
      D= (parseFloat(DateStr[2])<10)?('0'+parseFloat(DateStr[2])):parseFloat(DateStr[2]);
      sDfltValue=Y+'-'+M+'-'+D
    }

    document.write("<input size='10' readonly class='inputdate' name='"+sBoxName+"' value='"+sDfltValue+"' onclick='GetCalendar(window.document.all."+sBoxName+")' >");
}
document.onclick = CloseCalendar;
//-->
