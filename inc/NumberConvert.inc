<!--==start=="inc\NumberConvert.inc"-->
<%
'數字轉成國字
Function NumberToChinese(SendNumber)
   Select Case SendNumber
          Case "1"
               NumberToChinese = "壹"
          Case "2"
               NumberToChinese = "貳"
          Case "3"
               NumberToChinese = "參"
          Case "4"
               NumberToChinese = "肆"
          Case "5"
               NumberToChinese = "伍"
          Case "6"
               NumberToChinese = "陸"
          Case "7"
               NumberToChinese = "柒"
          Case "8"
               NumberToChinese = "捌"
          Case "9"
               NumberToChinese = "玖"
          Case "0"
               NumberToChinese = "零"
   End Select
End Function
'數字轉大寫
Function NumberToCh(SendNumber)
   Select Case SendNumber
          Case "1"
               NumberToCh = "一"
          Case "2"
               NumberToCh = "二"
          Case "3"
               NumberToCh = "三"
          Case "4"
               NumberToCh = "四"
          Case "5"
               NumberToCh = "五"
          Case "6"
               NumberToCh = "六"
          Case "7"
               NumberToCh = "七"
          Case "8"
               NumberToCh = "八"
          Case "9"
               NumberToCh = "九"
          Case "10"
               NumberToCh = "十"
          Case "11"
               NumberToCh = "十一"
          Case "12"
               NumberToCh = "十二"
   End Select
End Function
function getchnumToCh(p1)
	select case len(p1)	
		case 1 '個數
			getchnumToCh = NumberToCh(p1)
		case 2 '十位數
			getchnumToCh = NumberToCh(mid(p1,1,1)) & "十" & NumberToCh(mid(p1,2,1))
		case 3 '百位數
		   	getchnumToCh = NumberToCh(mid(p1,1,1)) & "百" & NumberToCh(mid(p1,2,1)) & "十" & NumberToCh(mid(p1,3,1))
		case 4 '千位數
			getchnumToCh = NumberToCh(mid(p1,1,1)) & "仟" & NumberToCh(mid(p1,2,1)) & "百" & NumberToCh(mid(p1,3,1)) & "十" & NumberToCh(mid(p1,4,1))
	end select
end function
function getchnum(p1)
	select case len(p1)	
		case 1 '個數
			getchnum = p1
		case 2 '十位數
			getchnum = mid(p1,1,1) & "十" & mid(p1,2,1)
		case 3 '百位數
			getchnum = mid(p1,1,1) & "百" & mid(p1,2,1) & "十" & mid(p1,3,1)
		case 4 '千位數
			getchnum = mid(p1,1,1) & "仟" & mid(p1,2,1) & "百" & mid(p1,3,1) & "十" & mid(p1,4,1)
	end select
end function
'民國年度
function getchnumToCh_year(p1)
	select case len(p1)	
		case 1 '個數
			getchnumToCh_year = NumberToCh(p1)
		case 2 '十位數
			getchnumToCh_year = NumberToCh(mid(p1,1,1)) & "十" & NumberToCh(mid(p1,2,1))
		case 3 '百位數
		   	getchnumToCh_year = NumberToCh(mid(p1,1,1)) 
		   	if mid(p1,2,1)=0 then
		   	   getchnumToCh_year = getchnumToCh_year & "○"
		   	else
		   	   getchnumToCh_year = getchnumToCh_year & NumberToCh(mid(p1,2,1))
		   	end if
		   	if mid(p1,3,1)=0 then
		   	   getchnumToCh_year = getchnumToCh_year & "○"
		   	else   
		   	   getchnumToCh_year = getchnumToCh_year & NumberToCh(mid(p1,3,1))
		   	end if   
	end select
end function
%>
<!--==end=="inc\NumberConvert.inc"-->