    <div align="center"><center>
    <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
     <%
   Gsql="select * from dmt_temp where in_scode='" & in_scode & "' and in_no='"& in_no & "'"
   Set RRreg = Server.CreateObject("ADODB.RecordSet")
       RRreg.Open GSql,Conn,1,1,adcmdtext
   if RRreg.EOF then
      flag=2
   else
      flag=1
   end if     
if flag=2 then
   Gsql="select * from ndmt where seq=" & seq & " and seq1='"& seq1 & "'"
   Set RRreg = Server.CreateObject("ADODB.RecordSet")
       RRreg.Open GSql,Conn,1,1,adcmdtext
   if RRreg.EOF then
      flag=3
   else
      flag=2
   end if     
end if

if flag=1 or flag=2 then
   if flag=1 then
     class0=trim(RRreg("class"))
     pul=RRreg("pul")
     tcn_ref=RRreg("tcn_ref")
     tcn_class=RRreg("tcn_class")
     agt_no=RRreg("agt_no")
	 remark1=trim(RRreg("remark1"))
	 IF trim(RRreg("remark2"))<>empty or isnull(trim(RRreg("remark2")))=false then
		remark_2=trim(RRreg("remark2"))
		remark2=split(trim(RRreg("remark2")),"|")
     End IF
     remark3=trim(RRreg("remark3"))
     remark4=trim(RRreg("remark4"))
   end if
   
     appl_name=trim(RRreg("appl_name"))
     oappl_name=trim(RRreg("oappl_name"))
     cappl_name=trim(RRreg("cappl_name"))
     eappl_name=trim(RRreg("eappl_name"))
     eappl_name1=trim(RRreg("eappl_name1"))
     eappl_name2=trim(RRreg("eappl_name2"))
     jappl_name=trim(RRreg("jappl_name"))
     jappl_name1=trim(RRreg("jappl_name1"))
     jappl_name2=trim(RRreg("jappl_name2"))
     zname_type=trim(RRreg("zname_type"))
     zappl_name1=trim(RRreg("zappl_name1"))
     zappl_name2=trim(RRreg("zappl_name2"))
     draw=trim(RRreg("draw"))
     draw_file=trim(RRreg("draw_file"))
     symbol=trim(RRreg("symbol"))
     color=trim(RRreg("color"))
     prior_date=RRreg("prior_date")
     prior_country=trim(RRreg("prior_country"))
     prior_no=RRreg("prior_no")
     grp_code=trim(RRreg("grp_code"))
     good_name=trim(RRreg("good_name"))
end if
     RRreg.close
 set RRreg=nothing     
 
 if flag=3 then
    Response.Write "<script language='javascript' type='text/javascript'>" &chr(13)
    Response.Write " alert('請到案件主檔維護新增案件內容!');" &chr(13)
    Response.Write " window.parent.location='/Customers/Brt15.asp';" &chr(13)
    Response.Write "</script>" &chr(13)
 end if   
 %>
 <tr>
    <td width="15%" bgcolor="#CCFFCC"><p align="right">出名代理人 : </td>
    <td width="35%" bgcolor="#FFFFFF"><%=agt_no%> <%call tran_agt(agt_no)%></td>
    <td width="15%" align="right" bgcolor="#CCFFCC">案件編號 : </td>
    <td width="35%" bgcolor="#FFFFFF" colspan=2><%=session("se_branch")&"T"%><%=seq%><%IF trim(seq1)<>"_" then%>_<%=seq1%><%End IF%></td>
 </tr>
<tr>
        <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、
      <%
		select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA1","FA2","FA3","FA4","FA5","FA6","FA7","FA8"
				response.write "商標圖樣"
		case "FA9","FAA","FAB","FAC"
				response.write "團體標章圖樣"
		case "FAD","FAE","FAF","FAG"
				response.write "證明標章圖樣"
        end select
        %>: </td>
 </tr>	
 <%select case left(trim(Request.QueryString("add_arcase")),3)
   case "FA1","FA5","FA9","FAD"%>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">一、
      <%
		select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA1","FA5"
				response.write "商標名稱"
        case "FA9","FAD"
				response.write "標章名稱"
        end select
        %>: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%=appl_name%></td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">二、圖樣顏色 : </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%IF color="B" then%>ˇ<%else%>　<%End IF%>墨色　<%IF color="C" then%>ˇ<%else%>　<%End IF%>彩色</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">三、聲明不專用 : </td>
        <td width="85%" bgcolor="#FFFFFF" colspan="4"><%=oappl_name%></td>
      </tr>
     <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">四、圖樣分析 : </td>
        <td width="10%" align="right" bgcolor="#CCFFCC">中文 : </td>
        <td width="70%" bgcolor="#FFFFFF" colspan="3"><%=Cappl_name%></td>
      </tr>
      <tr>
		<td width="15%" align="right" bgcolor="#CCFFCC"></td>
        <td width="10%" align="right" bgcolor="#CCFFCC">外文 : </td>
        <td width="10%" bgcolor="#FFFFFF"><%=Eappl_name%></td>
        <td width="10%" bgcolor="#CCFFCC"><p align="right">語文別 : </td>
        <td width="25%" bgcolor="#FFFFFF"><%=Zname_type%></td>
      </tr>
      <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC"></td>
        <td width="10%" bgcolor="#CCFFCC"><p align="right">中文字義 : </td>
        <td width="24%" bgcolor="#FFFFFF"><%=Eappl_name1%></td>
        <td width="10%" bgcolor="#CCFFCC"><p align="right">讀音 : </td>
        <td width="25%" bgcolor="#FFFFFF"><%=Eappl_name2%></td>
      </tr>
      <tr>
		<td width="15%" align="right" bgcolor="#CCFFCC"></td>
        <td width="10%" align="right" bgcolor="#CCFFCC">圖形描述 : </td>
        <td width="70%" bgcolor="#FFFFFF" colspan="3"><%=draw%></td>
      </tr>
      <tr>
		<td width="15%" align="right" bgcolor="#CCFFCC"></td>
        <td width="10%" align="right" bgcolor="#CCFFCC">記號說明 : </td>
        <td width="70%" bgcolor="#FFFFFF" colspan="3"><%=symbol%></td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">貳、優先權聲明</td>
      </tr>
      <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">優先權申請日 : </td>
        <td width="80%" bgcolor="#FFFFFF" colspan="4"><%=prior_date%></td>
      </tr>
      <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">申請國家 : </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="2">
		<%SQL="SELECT coun_code, coun_c FROM country where coun_code='"&prior_country&"' and markb<>'X'"
		 SET RSS=cnn.execute(SQL)
         if not RSS.eof then
            Response.Write trim(RSS("coun_c"))
         else
            Response.Write prior_country
         end if         
         RSS.close
         set RSS=nothing
         %></td>
        <td width="10%" bgcolor="#CCFFCC"><p align="right">申請案號 : </td>
        <td width="25%" bgcolor="#FFFFFF"><%=prior_no%></td>
      </tr>
      <%IF left(trim(Request("add_arcase")),3)="FA1" or left(trim(Request("add_arcase")),3)="FA5" then 
		SQL="Select * from casedmt_good where in_no='"& in_no & "' order by cast(class as int)"
		Set RSS=Conn.execute(SQL)
	  %>
	  <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、指定使用商品／服務類別及名稱</td>
      </tr>
      <tr><td colspan=5>
      <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
      <tr>
        <td width="5%" align="center" bgcolor="#CCFFCC">類別 </td>
        <td width="15%" align="center" bgcolor="#CCFFCC" colspan=2>群組代號</td>
        <td width="80%" align="center" bgcolor="#CCFFCC" colspan=2>指定商品名稱</td>
      </tr>
      <%while not RSS.Eof %>
      <tr>
		<td width="5%" bgcolor="#FFFFFF" align="right"><%=trim(RSS("class"))%></td>
		<td width="15%" bgcolor="#FFFFFF" colspan=2 align="center"><%=trim(RSS("dmt_grp_code"))%></td>
		<td width="80%" bgcolor="#FFFFFF" colspan=2><%=trim(RSS("dmt_goodname"))%></td>
      </tr>
      <%
			RSS.movenext
		wend
		RSS.close
		set RSS=nothing
      %>
      </table></td></tr>
      <%Elseif left(trim(Request("add_arcase")),3)="FA9" then%>
		<tr>
		  <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、團體標章表彰之內容</td>
		</tr>
		<tr>
			<td width="15%" bgcolor="#CCFFCC"><p align="right">表彰內容 : </td>
			<td width="25%" bgcolor="#FFFFFF" colspan="4"><%=good_name%>　之組織或會員之會籍。（填寫申請人名稱）</td>
		</tr>
	<%Elseif left(trim(Request("add_arcase")),3)="FAD" then%>
		<tr>
		  <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、標章證明標的及內容</td>
		</tr>
		<tr>
			<td width="15%" bgcolor="#CCFFCC"><p align="right">證明標的 : </td>
			<td width="25%" bgcolor="#FFFFFF" colspan="4"><%IF pul="3" then%>ˇ<%Else%>　<%End IF%>商標　　<%IF pul="4" then%>ˇ<%Else%>　<%End IF%>服務</td>
		</tr>
		<tr>
			<td width="15%" bgcolor="#CCFFCC"><p align="right">證明內容 : </td>
			<td width="25%" bgcolor="#FFFFFF" colspan="4"><%=good_name%>
		</tr>
      <%End If%>
      <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">
        <%select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA1","FA5"
				response.write "商標圖樣"
        case "FA9","FAD"
        		response.write "標章圖樣"
        end select%> : </td>
        <td width="80%" bgcolor="#FFFFFF" colspan="4">
          <%call showdrawfile(Draw_file="")%>
           </td>
      </tr>
       <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">備註: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%IF remark_2<>empty then%><%IF remark2(0)="R1" then%>ˇ<%else%>　<%End IF%><%else%>　<%End IF%>本案需俟註冊第　<%IF remark_2<>empty then%><%IF remark2(0)="R1" and remark2(1)<>empty then%><%=remark2(1)%><%else%>　　　<%End IF%><%End IF%>　號商標爭議案確定後，再行審理。</td>
      </tr>
      
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%IF remark_2<>empty then%><%IF remark2(0)="R9" then%>ˇ<%else%>　<%End IF%><%else%>　<%End IF%>其他：<%IF remark_2<>empty then%><%IF remark2(0)="R9" and remark2(1)<>empty then%><%=remark2(1)%><%else%>　　　<%End IF%><%End IF%></td>
      </tr>
      <%select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA1","FA11","FA12"%>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>商標圖樣浮貼一式五張，彩色另加二張黑白圖。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>優先權證明文件（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>大陸地區之自然人或法人之身分證明文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>委任書(（<% IF instr(1,remark1,"Z4C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他證明文件。</td>
      </tr>
      <%case "FA5","FA51","FA52"%>
		<tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>商標圖樣浮貼一式五張，彩色另加二張黑白圖。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>優先權證明文件（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>法人資格證明文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>委任書(<% IF instr(1,remark1,"Z4C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z5")<>0 then%>ˇ<%Else%>　<%End IF%>載明申請人成員資格及控制團體商標使用方式之商標使用規範書。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他證明文件。</td>
      </tr>
      <%case "FA9"%>
		<tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>標章圖樣浮貼一式五張，彩色另加二張黑白圖。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>優先權證明文件（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>法人資格證明文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>委任書(（<% IF instr(1,remark1,"Z4C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z5")<>0 then%>ˇ<%Else%>　<%End IF%>載明申請人成員資格及控制團體標章使用方式之使用規範書。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他證明文件。</td>
      </tr>
       <%case "FAD"%>
		<tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>標章圖樣浮貼一式五張，彩色另加二張黑白圖。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>優先權證明文件（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>申請人身分證明文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>申請人得為證明之資格或能力之文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z5")<>0 then%>ˇ<%Else%>　<%End IF%>委任書(（<%IF remark_1<>empty then%><%IF remark1(0)="Z5C" then%>ˇ<%else%>　<%End IF%><%else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z6")<>0 then%>ˇ<%Else%>　<%End IF%>標章標示條件及控制標章使用方式。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z7")<>0 then%>ˇ<%Else%>　<%End IF%>申請人不以標章從事商品之製造、行銷或服務提供之聲明。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他證明文件。</td>
      </tr>
	  <%end Select%>
<%case "FA2","FA6","FAA","FAE"%>
		<tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">一、
      <%
		select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA2","FA6"
				response.write "商標名稱"
        case "FAA","FAE"
				response.write "標章名稱"
        end select
        %>: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%=appl_name%></td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">二、圖樣顏色 : </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4">彩色</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">三、聲明不專用 : </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%=oappl_name%></td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">四、圖樣描述（色彩種類、明度、漸層及顏色實際使用於商品、包裝、容器、營業相關物品之特殊方式、位置、內容等請詳細說明）：</td>
      </tr>
      <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">不屬<%
		select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA2","FA6"
				response.write "商標"
        case "FAA","FAE"
				response.write "標章"
        end select
        %>一部 : </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%IF remark3="商品" then%>ˇ<%else%>　<%End IF%>商品<%IF remark3="包裝" then%>ˇ<%else%>　<%End IF%>包裝<%IF remark3="容器" then%>ˇ<%else%>　<%End IF%>容器之形狀<%IF remark3="營業物" then%>ˇ<%else%>　<%End IF%>營業相關物品之形狀</td>
      </tr>
      <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">商標圖樣描述 : </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%=remark4%></td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">貳、優先權聲明</td>
      </tr>
      <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">優先權申請日 : </td>
        <td width="80%" bgcolor="#FFFFFF" colspan="4"><%=prior_date%></td>
      </tr>
      <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">申請國家 : </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="2">
		<%SQL="SELECT coun_code, coun_c FROM country where coun_code='"&prior_country&"'"
		 SET RSS=cnn.execute(SQL)
         if not RSS.eof then
            Response.Write trim(RSS("coun_c"))
         else
            Response.Write prior_country
         end if         
         RSS.close
         set RSS=nothing
         %></td>
        <td width="10%" bgcolor="#CCFFCC"><p align="right">申請案號 : </td>
        <td width="25%" bgcolor="#FFFFFF"><%=prior_no%></td>
      </tr>
      <%IF left(trim(Request("add_arcase")),3)="FA1" or left(trim(Request("add_arcase")),3)="FA2" or left(trim(Request("add_arcase")),3)="FA3" or left(trim(Request("add_arcase")),3)="FA4" or left(trim(Request("add_arcase")),3)="FA5" or left(trim(Request("add_arcase")),3)="FA6" or left(trim(Request("add_arcase")),3)="FA7" or left(trim(Request("add_arcase")),3)="FA8" then 
		SQL="Select * from casedmt_good where in_no='"& in_no & "' order by cast(class as int)"
		Set RSS=Conn.execute(SQL)
	  %>
	  <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、指定使用商品／服務類別及名稱</td>
      </tr>
      <tr><td colspan=5>
      <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
      <tr>
        <td width="5%" align="center" bgcolor="#CCFFCC">類別 </td>
        <td width="15%" align="center" bgcolor="#CCFFCC" colspan=2>群組代號 </td>
        <td width="80%" align="center" bgcolor="#CCFFCC" colspan=2>指定商品名稱</td>
      </tr>
      <%while not RSS.Eof %>
      <tr>
		<td width="5%" bgcolor="#FFFFFF" align="right"><%=trim(RSS("class"))%></td>
		<td width="15%" bgcolor="#FFFFFF" colspan=2 align="center"><%=trim(RSS("dmt_grp_code"))%></td>
		<td width="80%" bgcolor="#FFFFFF" colspan=2><%=trim(RSS("dmt_goodname"))%></td>
      </tr>
      <%
			RSS.movenext
		wend
		RSS.close
		set RSS=nothing
      %>
      </table></td></tr>
      <%Elseif left(trim(Request("add_arcase")),3)="FA9" or left(trim(Request("add_arcase")),3)="FAA" or left(trim(Request("add_arcase")),3)="FAB" or left(trim(Request("add_arcase")),3)="FAC" then%>
		<tr>
		  <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、團體標章表彰之內容</td>
		</tr>
		<tr>
			<td width="15%" bgcolor="#CCFFCC"><p align="right">表彰內容 : </td>
			<td width="25%" bgcolor="#FFFFFF" colspan="4"><%=good_name%>　之組織或會員之會籍。（填寫申請人名稱）</td>
		</tr>
	  <%Elseif left(trim(Request("add_arcase")),3)="FAD" or left(trim(Request("add_arcase")),3)="FAE" or left(trim(Request("add_arcase")),3)="FAF" or left(trim(Request("add_arcase")),3)="FAG" then%>
		<tr>
		  <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、標章證明標的及內容</td>
		</tr>
		<tr>
			<td width="15%" bgcolor="#CCFFCC"><p align="right">證明標的 : </td>
			<td width="25%" bgcolor="#FFFFFF" colspan="4"><%IF pul="3" then%>ˇ<%Else%>　<%End IF%>商標　　<%IF pul="4" then%>ˇ<%Else%>　<%End IF%>服務</td>
		</tr>
		<tr>
			<td width="15%" bgcolor="#CCFFCC"><p align="right">證明內容 : </td>
			<td width="25%" bgcolor="#FFFFFF" colspan="4"><%=good_name%>
		</tr>
      <%End If%>
      <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">
        <%select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA2","FA6"
				response.write "商標圖樣"
        case "FAA","FAE"
				response.write "標章圖樣"
        end select%> : </td>
        <td width="80%" bgcolor="#FFFFFF" colspan="4">
          <%call showdrawfile(Draw_file="")%>
           </td>
      </tr>
       <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">備註: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%IF remark_2<>empty then%><%IF remark2(0)="R1" then%>ˇ<%else%>　<%End IF%><%else%>　<%End IF%>本案需俟註冊第　<%IF remark_2<>empty then%><%IF remark2(0)="R1" and remark2(1)<>empty then%><%=remark2(1)%><%else%>　　　<%End IF%><%End IF%>　號商標爭議案確定後，再行審理。</td>
      </tr>
      
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%IF remark_2<>empty then%><%IF remark2(0)="R9" then%>ˇ<%else%>　<%End IF%><%else%>　<%End IF%>其他：<%IF remark_2<>empty then%><%IF remark2(0)="R9" and remark2(1)<>empty then%><%=remark2(1)%><%else%>　　　<%End IF%><%End IF%></td>
      </tr>
       <%select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA2","FA21","FA22"%>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>商標圖樣浮貼一式五張，彩色另加二張黑白圖。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>優先權證明文件（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>大陸地區之自然人或法人之身分證明文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>委任書(<% IF instr(1,remark1,"Z4C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z5")<>0 then%>ˇ<%Else%>　<%End IF%>已取得識別性之具體事證。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他證明文件。</td>
      </tr>
      <%case "FA6","FA61","FA62"%>
		<tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>商標圖樣浮貼一式五張，彩色另加二張黑白圖。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>優先權證明文件（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>法人資格證明文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>委任書(<% IF instr(1,remark1,"Z4C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z5")<>0 then%>ˇ<%Else%>　<%End IF%>載明申請人成員資格及控制團體商標使用方式之商標使用規範書。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z6")<>0 then%>ˇ<%Else%>　<%End IF%>已取得識別性之具體事證。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他證明文件。</td>
      </tr>
      <%case "FAA"%>
	  <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>標章圖樣浮貼一式五張，彩色另加二張黑白圖。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>優先權證明文件（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>法人資格證明文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>委任書(<% IF instr(1,remark1,"Z4C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z5")<>0 then%>ˇ<%Else%>　<%End IF%>載明申請人成員資格及控制團體標章使用方式之使用規範書。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z6")<>0 then%>ˇ<%Else%>　<%End IF%>已取得識別性之具體事證。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他證明文件。</td>
      </tr>
       <%case "FAE"%>
	  <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>標章圖樣浮貼一式五張，彩色另加二張黑白圖。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>優先權證明文件（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>申請人身分證明文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>申請人得為證明之資格或能力之文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z5")<>0 then%>ˇ<%Else%>　<%End IF%>委任書(<% IF instr(1,remark1,"Z5C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z6")<>0 then%>ˇ<%Else%>　<%End IF%>標章標示條件及控制標章使用方式。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z7")<>0 then%>ˇ<%Else%>　<%End IF%>申請人不以標章從事商品之製造、行銷或服務提供之聲明。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z8")<>0 then%>ˇ<%Else%>　<%End IF%>已取得識別性之具體事證。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他證明文件。</td>
      </tr>
	 <%end Select%>
<%case "FA3","FA7","FAB","FAF"%>
      <tr>
        <td width="20%" align="left" bgcolor="#CCFFCC">一、
      <%
		select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA3","FA7"
				response.write "商標名稱"
        case "FAB","FAF"
				response.write "標章名稱"
        end select
        %>: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%=appl_name%></td>
      </tr>
      <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC">二、
		<%
		select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA3","FA7"
				response.write "商標"
        case "FAB","FAF"
				response.write "標章"
        end select
        %>圖樣表示: </td>
        <td width="15%" align="left" bgcolor="#FFFFFF" colspan="4">
        <%IF remark3="Y" then%>ˇ<%else%>　<%End IF%>
        <%
		select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA3","FA7"
				response.write "商標"
        case "FAB","FAF"
				response.write "標章"
        end select
        %>圖樣以樂譜（五線譜或簡譜）表示</td>
	  </tr>
	   <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="15%" align="left" bgcolor="#FFFFFF" colspan="4">
        <%IF remark3="N" then%>ˇ<%else%>　<%End IF%>無法以樂譜表示其聲音者，得就聲音為描述說明</td>
	  </tr>
	  <tr>
        <td width="20%" align="left" bgcolor="#CCFFCC">三、
      <%
		select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA3","FA7"
				response.write "商標"
        case "FAB","FAF"
				response.write "標章"
        end select
        %>圖樣描述: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%=Remark4%></td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">貳、優先權聲明</td>
      </tr>
      <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">優先權申請日 : </td>
        <td width="80%" bgcolor="#FFFFFF" colspan="4"><%=prior_date%></td>
      </tr>
      <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">申請國家 : </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="2">
		<%SQL="SELECT coun_code, coun_c FROM country where coun_code='"&prior_country&"'"
		 SET RSS=cnn.execute(SQL)
         if not RSS.eof then
            Response.Write trim(RSS("coun_c"))
         else
            Response.Write prior_country
         end if         
         RSS.close
         set RSS=nothing
         %></td>
        <td width="10%" bgcolor="#CCFFCC"><p align="right">申請案號 : </td>
        <td width="25%" bgcolor="#FFFFFF"><%=prior_no%></td>
      </tr>
      <%IF left(trim(Request("add_arcase")),3)="FA1" or left(trim(Request("add_arcase")),3)="FA2" or left(trim(Request("add_arcase")),3)="FA3" or left(trim(Request("add_arcase")),3)="FA4" or left(trim(Request("add_arcase")),3)="FA5" or left(trim(Request("add_arcase")),3)="FA6" or left(trim(Request("add_arcase")),3)="FA7" or left(trim(Request("add_arcase")),3)="FA8" then 
		SQL="Select * from casedmt_good where in_no='"& in_no & "' order by cast(class as int)"
		Set RSS=Conn.execute(SQL)
	  %>
	  <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、指定使用商品／服務類別及名稱</td>
      </tr>
      <tr><td colspan=5>
      <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
      <tr>
        <td width="5%" align="center" bgcolor="#CCFFCC">類別 </td>
        <td width="15%" align="center" bgcolor="#CCFFCC" colspan=2>群組代號 </td>
        <td width="80%" align="center" bgcolor="#CCFFCC" colspan=2>指定商品名稱</td>
      </tr>
      <%while not RSS.Eof %>
      <tr>
		<td width="5%" bgcolor="#FFFFFF" align="right"><%=trim(RSS("class"))%></td>
		<td width="15%" bgcolor="#FFFFFF" colspan=2 align="center"><%=trim(RSS("dmt_grp_code"))%></td>
		<td width="80%" bgcolor="#FFFFFF" colspan=2><%=trim(RSS("dmt_goodname"))%></td>
      </tr>
      <%
			RSS.movenext
		wend
		RSS.close
		set RSS=nothing
      %>
      </table></td></tr>
      <%Elseif left(trim(Request("add_arcase")),3)="FA9" or left(trim(Request("add_arcase")),3)="FAA" or left(trim(Request("add_arcase")),3)="FAB" or left(trim(Request("add_arcase")),3)="FAC" then%>
		<tr>
		  <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、團體標章表彰之內容</td>
		</tr>
		<tr>
			<td width="15%" bgcolor="#CCFFCC"><p align="right">表彰內容 : </td>
			<td width="25%" bgcolor="#FFFFFF" colspan="4"><%=good_name%>　之組織或會員之會籍。（填寫申請人名稱）</td>
		</tr>
	  <%Elseif left(trim(Request("add_arcase")),3)="FAD" or left(trim(Request("add_arcase")),3)="FAE" or left(trim(Request("add_arcase")),3)="FAF" or left(trim(Request("add_arcase")),3)="FAG" then%>
		<tr>
		  <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、標章證明標的及內容</td>
		</tr>
		<tr>
			<td width="15%" bgcolor="#CCFFCC"><p align="right">證明標的 : </td>
			<td width="25%" bgcolor="#FFFFFF" colspan="4"><%IF pul="3" then%>ˇ<%Else%>　<%End IF%>商標　　<%IF pul="4" then%>ˇ<%Else%>　<%End IF%>服務</td>
		</tr>
		<tr>
			<td width="15%" bgcolor="#CCFFCC"><p align="right">證明內容 : </td>
			<td width="25%" bgcolor="#FFFFFF" colspan="4"><%=good_name%>
		</tr>
      <%End If%>
      <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">
        <%select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA3","FA7"
				response.write "商標圖樣"
        case "FAB","FAF"
				response.write "標章圖樣"
        end select%> : </td>
        <td width="80%" bgcolor="#FFFFFF" colspan="4">
          <%call showdrawfile(Draw_file="")%>
           </td>
      </tr>
       <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">備註: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%IF remark_2<>empty then%><%IF remark2(0)="R1" then%>ˇ<%else%>　<%End IF%><%else%>　<%End IF%>本案需俟註冊第　<%IF remark_2<>empty then%><%IF remark2(0)="R1" and remark2(1)<>empty then%><%=remark2(1)%><%else%>　　　<%End IF%><%End IF%>　號商標爭議案確定後，再行審理。</td>
      </tr>
      
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%IF remark_2<>empty then%><%IF remark2(0)="R9" then%>ˇ<%else%>　<%End IF%><%else%>　<%End IF%>其他：<%IF remark_2<>empty then%><%IF remark2(0)="R9" and remark2(1)<>empty then%><%=remark2(1)%><%else%>　　　<%End IF%><%End IF%></td>
      </tr>
      <%select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA3","FA31","FA32"%>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>商標圖樣浮貼一式五張。（商標圖樣非以五線譜、簡譜表示者，免貼圖）</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>優先權證明文件（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>大陸地區之自然人或法人之身分證明文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>委任書(<% IF instr(1,remark1,"Z4C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z5")<>0 then%>ˇ<%Else%>　<%End IF%>已取得識別性之具體事證。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z6")<>0 then%>ˇ<%Else%>　<%End IF%>載有本件聲音之wav檔光碟片。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他證明文件。</td>
      </tr>
      <%case "FA7","FA71","FA72"%>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>商標圖樣浮貼一式五張。（商標圖樣非以五線譜、簡譜表示者，免貼圖）</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>優先權證明文件（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>法人資格證明文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>委任書(<% IF instr(1,remark1,"Z4C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z5")<>0 then%>ˇ<%Else%>　<%End IF%>載明申請人成員資格及控制團體商標使用方式之商標使用規範書。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z6")<>0 then%>ˇ<%Else%>　<%End IF%>已取得識別性之具體事證。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z7")<>0 then%>ˇ<%Else%>　<%End IF%>載有本件聲音之wav檔光碟片。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他證明文件。</td>
      </tr>
      <%case "FAB"%>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>標章圖樣浮貼一式五張。（標章圖樣非以五線譜、簡譜表示者，免貼圖）</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>優先權證明文件（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>法人資格證明文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>委任書(<% IF instr(1,remark1,"Z4C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z5")<>0 then%>ˇ<%Else%>　<%End IF%>載明申請人成員資格及控制團體標章使用方式之標章使用規範書。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z6")<>0 then%>ˇ<%Else%>　<%End IF%>已取得識別性之具體事證。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z7")<>0 then%>ˇ<%Else%>　<%End IF%>載有本件聲音之wav檔光碟片。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他證明文件。</td>
      </tr>
      <%case "FAF"%>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>標章圖樣浮貼一式五張。（標章圖樣非以五線譜、簡譜表示者，免貼圖）</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>優先權證明文件（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>申請人身分證明文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>申請人得為證明之資格或能力之文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z5")<>0 then%>ˇ<%Else%>　<%End IF%>委任書(<% IF instr(1,remark1,"Z5C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z6")<>0 then%>ˇ<%Else%>　<%End IF%>標章標示條件及控制標章使用方式。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z7")<>0 then%>ˇ<%Else%>　<%End IF%>申請人不以標章從事商品之製造、行銷或服務提供之聲明。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z8")<>0 then%>ˇ<%Else%>　<%End IF%>已取得識別性之具體事證。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z10")<>0 then%>ˇ<%Else%>　<%End IF%>載有本件聲音之wav檔光碟片。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他證明文件。</td>
      </tr>
      <%End Select%>
      <%case "FA4","FA8","FAC","FAG"%>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">一、
      <%
		select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA4","FA8"
				response.write "商標名稱"
        case "FAC","FAG"
				response.write "標章名稱"
        end select
        %>: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%=appl_name%></td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">二、圖樣顏色 : </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%IF color="B" then%>ˇ<%else%>　<%End IF%>墨色　<%IF color="C" then%>ˇ<%else%>　<%End IF%>彩色</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">三、聲明不專用 : </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%=oappl_name%></td>
      </tr>
      <tr>
        <td width="20%" align="left" bgcolor="#CCFFCC">四、
        <%
		select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA4","FA8"
				response.write "商標"
        case "FAC","FAG"
				response.write "標章"
        end select
        %>圖樣表示 : </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark3,"M")<>0 then%>ˇ<%Else%>　<%End IF%>主要立體圖</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark3,"O")<>0 then%>ˇ<%Else%>　<%End IF%>其他角度圖</td>
      </tr>
       <tr>
        <td width="20%" align="left" bgcolor="#CCFFCC">三、
      <%
		select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA4","FA8"
				response.write "商標"
        case "FAC","FAG"
				response.write "標章"
        end select
        %>圖樣描述: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%=Remark4%></td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">貳、優先權聲明</td>
      </tr>
      <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">優先權申請日 : </td>
        <td width="80%" bgcolor="#FFFFFF" colspan="4"><%=prior_date%></td>
      </tr>
      <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">申請國家 : </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="2">
		<%SQL="SELECT coun_code, coun_c FROM country where coun_code='"&prior_country&"'"
		 SET RSS=cnn.execute(SQL)
         if not RSS.eof then
            Response.Write trim(RSS("coun_c"))
         else
            Response.Write prior_country
         end if         
         RSS.close
         set RSS=nothing
         %></td>
        <td width="10%" bgcolor="#CCFFCC"><p align="right">申請案號 : </td>
        <td width="25%" bgcolor="#FFFFFF"><%=prior_no%></td>
      </tr>
      <%IF left(trim(Request("add_arcase")),3)="FA1" or left(trim(Request("add_arcase")),3)="FA2" or left(trim(Request("add_arcase")),3)="FA3" or left(trim(Request("add_arcase")),3)="FA4" or left(trim(Request("add_arcase")),3)="FA5" or left(trim(Request("add_arcase")),3)="FA6" or left(trim(Request("add_arcase")),3)="FA7" or left(trim(Request("add_arcase")),3)="FA8" then 
		SQL="Select * from casedmt_good where in_no='"& in_no & "' order by cast(class as int)"
		Set RSS=Conn.execute(SQL)
	  %>
	  <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、指定使用商品／服務類別及名稱</td>
      </tr>
      <tr><td colspan=5>
      <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
      <tr>
        <td width="5%" align="center" bgcolor="#CCFFCC">類別 </td>
        <td width="15%" align="center" bgcolor="#CCFFCC" colspan=2>群組代號 </td>
        <td width="80%" align="center" bgcolor="#CCFFCC" colspan=2>指定商品名稱</td>
      </tr>
      <%while not RSS.Eof %>
      <tr>
		<td width="5%" bgcolor="#FFFFFF" align="right"><%=trim(RSS("class"))%></td>
		<td width="15%" bgcolor="#FFFFFF" colspan=2 align="center"><%=trim(RSS("dmt_grp_code"))%></td>
		<td width="80%" bgcolor="#FFFFFF" colspan=2 align="center"><%=trim(RSS("dmt_goodname"))%></td>
      </tr>
      <%
			RSS.movenext
		wend
		RSS.close
		set RSS=nothing
      %>
      </table></td></tr>
      <%Elseif left(trim(Request("add_arcase")),3)="FA9" or left(trim(Request("add_arcase")),3)="FAA" or left(trim(Request("add_arcase")),3)="FAB" or left(trim(Request("add_arcase")),3)="FAC" then%>
		<tr>
		  <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、團體標章表彰之內容</td>
		</tr>
		<tr>
			<td width="15%" bgcolor="#CCFFCC"><p align="right">表彰內容 : </td>
			<td width="25%" bgcolor="#FFFFFF" colspan="4"><%=good_name%>　之組織或會員之會籍。（填寫申請人名稱）</td>
		</tr>
	  <%Elseif left(trim(Request("add_arcase")),3)="FAD" or left(trim(Request("add_arcase")),3)="FAE" or left(trim(Request("add_arcase")),3)="FAF" or left(trim(Request("add_arcase")),3)="FAG" then%>
		<tr>
		  <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、標章證明標的及內容</td>
		</tr>
		<tr>
			<td width="15%" bgcolor="#CCFFCC"><p align="right">證明標的 : </td>
			<td width="25%" bgcolor="#FFFFFF" colspan="4"><%IF pul="3" then%>ˇ<%Else%>　<%End IF%>商標　　<%IF pul="4" then%>ˇ<%Else%>　<%End IF%>服務</td>
		</tr>
		<tr>
			<td width="15%" bgcolor="#CCFFCC"><p align="right">證明內容 : </td>
			<td width="25%" bgcolor="#FFFFFF" colspan="4"><%=good_name%>
		</tr>
      <%End If%>
      <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">
        <%select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA4","FA8"
				response.write "商標圖樣"
        case "FAC","FAG"
				response.write "標章圖樣"
        end select%> : </td>
        <td width="80%" bgcolor="#FFFFFF" colspan="4">
          <%call showdrawfile(Draw_file="")%>
           </td>
      </tr>
       <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">備註: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%IF remark_2<>empty then%><%IF remark2(0)="R1" then%>ˇ<%else%>　<%End IF%><%else%>　<%End IF%>本案需俟註冊第　<%IF remark_2<>empty then%><%IF remark2(0)="R1" and remark2(1)<>empty then%><%=remark2(1)%><%else%>　　　<%End IF%><%End IF%>　號商標爭議案確定後，再行審理。</td>
      </tr>
      
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%IF remark_2<>empty then%><%IF remark2(0)="R9" then%>ˇ<%else%>　<%End IF%><%else%>　<%End IF%>其他：<%IF remark_2<>empty then%><%IF remark2(0)="R9" and remark2(1)<>empty then%><%=remark2(1)%><%else%>　　　<%End IF%><%End IF%></td>
      </tr>
      <%select case left(trim(Request.QueryString("add_arcase")),3)
        case "FA4","FA41","FA42"%>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>每張立體圖各浮貼一式五張，彩色立體圖各另加二張黑白圖。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>優先權證明文件（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>大陸地區之自然人或法人之身分證明文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>委任書(<% IF instr(1,remark1,"Z4C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z5")<>0 then%>ˇ<%Else%>　<%End IF%>已取得識別性之具體事證。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z6")<>0 then%>ˇ<%Else%>　<%End IF%>不具功能性之證據資料。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他證明文件。</td>
      </tr>
      <%case "FA8","FA81","FA82"%>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>每張立體圖各浮貼一式五張，彩色立體圖各另加二張黑白圖。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>優先權證明文件（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>法人資格證明文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>委任書(<% IF instr(1,remark1,"Z4C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z5")<>0 then%>ˇ<%Else%>　<%End IF%>載明申請人成員資格及控制團體商標使用方式之商標使用規範書。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z6")<>0 then%>ˇ<%Else%>　<%End IF%>已取得識別性之具體事證。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z7")<>0 then%>ˇ<%Else%>　<%End IF%>不具功能性之證據資料。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他證明文件。</td>
      </tr>
      <%case "FAC"%>
       <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>每張立體圖各浮貼一式五張，彩色立體圖各另加二張黑白圖。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>優先權證明文件（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>法人資格證明文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>委任書(<% IF instr(1,remark1,"Z4C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z5")<>0 then%>ˇ<%Else%>　<%End IF%>載明申請人成員資格及控制團體標章使用方式之標章使用規範書。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z6")<>0 then%>ˇ<%Else%>　<%End IF%>已取得識別性之具體事證。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他證明文件。</td>
      </tr>
      <%case "FAG"%>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>每張立體圖各浮貼一式五張，彩色立體圖各另加二張黑白圖。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>優先權證明文件（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>申請人身分證明文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>申請人得為證明之資格或能力之文件。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z5")<>0 then%>ˇ<%Else%>　<%End IF%>委任書(<% IF instr(1,remark1,"Z5C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本)。</td>
      </tr>
       <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z6")<>0 then%>ˇ<%Else%>　<%End IF%>標章標示條件及控制標章使用方式。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z7")<>0 then%>ˇ<%Else%>　<%End IF%>申請人不以標章從事商品之製造、行銷或服務提供之聲明。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z8")<>0 then%>ˇ<%Else%>　<%End IF%>已取得識別性之具體事證。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他證明文件。</td>
      </tr>
      <%End Select%>
<%End Select%>
    </table>
    </center></div></td>
  </tr>
</table>
</center></div>