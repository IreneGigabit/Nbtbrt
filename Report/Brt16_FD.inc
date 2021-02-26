<!--#INCLUDE FILE="../inc/NumberConvert.inc" -->
<div align="center"><center>
<table border="0" width="100%" bgcolor="#000000" cellspacing="1">
<%

   SQLcom = "Exec Pro_case2 '" & in_no & "'"
   set RRreg = conn1.execute(SQLcom)
   IF not RRreg.eof then
	    flag=1
	    agt_no=trim(RRreg("agt_no"))
	    appl_name=trim(RRreg("appl_name"))
	    s_mark=trim(RRreg("s_mark"))
	    tot_num=trim(RRreg("tot_num"))
	    apply_no=trim(RRreg("apply_no"))
	    issue_no=trim(RRreg("issue_no"))
	    IF trim(RRreg("remark1"))<>empty then
			remark1=trim(RRreg("remark1"))
			remark_1=split(trim(RRreg("remark1")),"|")
			For x=0 to ubound(remark_1)-1
				IF left(remark_1(x),2)="Z2" then
					remark_2=split(remark_1(x),";")
					remark_2_detail=remark_2(1)
				ElseIF left(remark_1(x),2)="Z3" then
					remark_3=split(remark_1(x),";")
					remark_3_detail=remark_3(1)
				End IF
			Next
	    End IF
   Else
		flag=3
   End IF
 
 if flag=3 then
    Response.Write "<script language="javascript" type="text/javascript">" &chr(13)
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
<%Select Case trim(request("add_arcase"))
 case "FD1"%>
 <tr>
      <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、原註冊申請案號、商標／標章名稱、商標種類、分割件數、商標／標章圖樣</td>
 </tr>
 <tr>
      <td width="20%" align="left" bgcolor="#CCFFCC">一、原申請案號 : </td>
      <td width="80%" align="left" bgcolor="#FFFFFF" colspan=4><%=apply_no%></td>
 </tr>
  <tr>
      <td width="20%" align="left" bgcolor="#CCFFCC">二、商標／標章名稱 : </td>
      <td width="80%" align="left" bgcolor="#FFFFFF" colspan=4><%=appl_name%></td>
 </tr>
  <tr>
      <td width="20%" align="left" bgcolor="#CCFFCC">三、商標種類 : </td>
      <td width="80%" align="left" bgcolor="#FFFFFF" colspan=4>
      <%select case s_mark
	    case "S"%>
			92年修正前服務標章
	    <%case "N"%>
			團體商標
	    <%case "M"%>
			團體標章
	    <%case "L"%>
			證明標章
	    <%case else%>
			商標
	    <%end select%>
      
      </td>
 </tr>
  <tr>
      <td width="20%" align="left" bgcolor="#CCFFCC">四、分割件數 : </td>
      <td width="80%" align="left" bgcolor="#FFFFFF" colspan=4>分割為 <%=tot_num%> 件</td>
 </tr>
  <tr>
      <td width="15%" align="left" bgcolor="#CCFFCC" colspan=5>肆、分割後商品／服務類別、名稱、證明標的及內容（請依序填寫商品／服務類別、名稱）</td>
 </tr>
  <%
		SQL="Select * from dmt_temp where in_no='"&in_no&"' and case_sqlno<>0"
		Set RS=Conn.execute(SQL)
		i=1
		While not RS.EOF
      %>
 <tr><td colspan=5>
      <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
      <tr>
        <td width="15%" align="center" bgcolor="#CCFFCC">分割(<%=NumberToCh(i)%>)案件編號 </td>
        <td width="15%" align="center" bgcolor="#CCFFCC">(<%=NumberToCh(i)%>)商品／服務</td>
        <td width="15%" align="center" bgcolor="#CCFFCC">(<%=NumberToCh(i)%>)證明標的</td>
        <td width="55%" bgcolor="#CCFFCC" colspan=3>(<%=NumberToCh(i)%>)名稱或內容</td>
      </tr>
			<%
				SQL1="Select * from casedmt_good where case_sqlno='"&trim(RS("case_sqlno"))&"' and in_no='"&in_no&"' order by cast(class as int)"
				Set RSS=Conn.execute(SQL1)
				while not RSS.EOF
			%>
	 <tr>
        <td width="15%" align="center" bgcolor="#FFFFFF"><%=session("se_branch")&"T"%><%=trim(RS("seq"))%><%IF trim(RS("seq1"))<>"_" then%>_<%=trim(RS("seq1"))%><%End IF%></td>
		<td width="15%" align="center" bgcolor="#FFFFFF"><%IF trim(RS("mark"))="T" then%>ˇ<%else%>　<%End IF%></td>
		<td width="15%" align="center" bgcolor="#FFFFFF"><%IF trim(RS("mark"))="L" then%>ˇ<%else%>　<%End IF%></td>	
		<td width="55%" bgcolor="#FFFFFF" colspan=3><%=trim(RSS("dmt_goodname"))%></td></tr>
		  <%
			RSS.movenext
			wend
			RSS.close
			set RSS=nothing
		  %>
     </table>
 </td></tr>
  <%
		RS.movenext
		i=i+1
		wend
		RS.close
		set RS=nothing
      %>
 <tr>
    <td width="15%" align="left" bgcolor="#CCFFCC" ROWSPAN=3 >備註: </td>
    <%
    
		SQL1="Select  other_item  from dmt_tran where in_no='"&in_no&"' "
		Set RSS=Conn.execute(SQL1)
		IF not RSS.EOF then		
			IF trim(RSS("other_item"))<>empty then
				other_item_1=trim(RSS("other_item"))
				other_item=split(trim(RSS("other_item")),";")
			End IF
		End IF
		RSS.close
		SET RSS=nothing
    %>
    <td width="37%" bgcolor="#FFFFFF" colspan="4">本件商標（標章）於<%IF other_item_1<>empty then%><%IF other_item(0)<>empty then%>　<%=other_item(0)%><%Else%>　　　　<%End IF%><%Else%>　　　　<%End IF%>（年/月/日）</td>
</tr>
<tr>
    <td width="37%" bgcolor="#FFFFFF" colspan="5">另案辦理<% IF instr(1,other_item_1,"DO1")<>0 then%>ˇ<%Else%>　<%End IF%>異議案　　　<% IF instr(1,other_item_1,"DI1")<>0 then%>ˇ<%Else%>　<%End IF%>評定案　　　<% IF instr(1,other_item_1,"FT1")<>0 then%>ˇ<%Else%>　<%End IF%>移轉案　　　<% IF instr(1,other_item_1,"FC1")<>0 then%>ˇ<%Else%>　<%End IF%>變更案　　　<% IF instr(1,other_item_1,"FR1")<>0 then%>ˇ<%Else%>　<%End IF%>延展案　　　</td>
</tr>
<tr>
    <td width="37%" bgcolor="#FFFFFF" colspan="5">　　　　<% IF instr(1,other_item_1,"ZZ")<>0 then%>ˇ<%Else%>　<%End IF%>其他<%IF other_item_1<>empty then%><%IF other_item(2)<>empty then%>:　<%=other_item(2)%>　案<%Else%>　　　　<%End IF%><%End IF%></td>
</tr>
<tr>
	<td width="15%" align="left" bgcolor="#CCFFCC">附件 : </td>
	<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>委任書（<% IF instr(1,remark1,"Z1C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
</tr>
<tr>
    <td width="15%" align="left" bgcolor="#CCFFCC"></td>
    <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>按分割件數之分割申請書副本（<%IF remark_2_detail<>empty then%><%=remark_2_detail%><%Else%>　<%End IF%>）份。</td>
</tr>
<tr>
    <td width="15%" align="left" bgcolor="#CCFFCC"></td>
    <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>分割後之商標註冊申請書正本及其相關文件（<%IF remark_3_detail<>empty then%><%=remark_3_detail%><%Else%>　<%End IF%>）份。</td>
</tr>      
<%case "FD2","FD3"%>
<tr>
      <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、原註冊號數／原註冊申請案號、商標／標章名稱、商標種類、分割件數、商標／標章圖樣</td>
 </tr>
 <tr>
      <td width="20%" align="left" bgcolor="#CCFFCC">一、原註冊案號 : </td>
      <td width="80%" align="left" bgcolor="#FFFFFF" colspan=4><%=issue_no%></td>
 </tr>
  <tr>
      <td width="20%" align="left" bgcolor="#CCFFCC">二、商標／標章名稱 : </td>
      <td width="80%" align="left" bgcolor="#FFFFFF" colspan=4><%=appl_name%></td>
 </tr>
  <tr>
      <td width="20%" align="left" bgcolor="#CCFFCC">三、商標種類 : </td>
      <td width="80%" align="left" bgcolor="#FFFFFF" colspan=4>
      <%select case s_mark
	    case "S"%>
			92年修正前服務標章
	    <%case "N"%>
			團體商標
	    <%case "M"%>
			團體標章
	    <%case "L"%>
			證明標章
	    <%case else%>
			商標
	    <%end select%>
      </td>
 </tr>
  <tr>
      <td width="20%" align="left" bgcolor="#CCFFCC">四、分割件數 : </td>
      <td width="80%" align="left" bgcolor="#FFFFFF" colspan=4>分割為 <%=tot_num%> 件</td>
 </tr>
  <tr>
      <td width="15%" align="left" bgcolor="#CCFFCC" colspan=5>肆、分割後商品／服務類別、名稱、證明標的及內容（請依序填寫商品／服務類別、名稱）</td>
 </tr>
  <%
		SQL="Select * from dmt_temp where in_no='"&in_no&"' and case_sqlno<>0"
		Set RS=Conn.execute(SQL)
		i=1
		While not RS.EOF
      %>
 <tr><td colspan=5>
      <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
      <tr>
        <td width="15%" align="center" bgcolor="#CCFFCC">分割(<%=NumberToCh(i)%>)案件編號 </td>
        <td width="15%" align="center" bgcolor="#CCFFCC">(<%=NumberToCh(i)%>)商品／服務</td>
        <td width="15%" align="center" bgcolor="#CCFFCC">(<%=NumberToCh(i)%>)證明標的</td>
        <td width="55%" bgcolor="#CCFFCC" colspan=3>(<%=NumberToCh(i)%>)名稱或內容</td>
      </tr>
			<%
				SQL1="Select * from casedmt_good where case_sqlno='"&trim(RS("case_sqlno"))&"' and in_no='"&in_no&"' order by cast(class as int)"
				Set RSS=Conn.execute(SQL1)
				while not RSS.EOF
			%>
		  <tr>
        <td width="15%" align="center" bgcolor="#FFFFFF"><%=session("se_branch")&"T"%><%=trim(RS("seq"))%><%IF trim(RS("seq1"))<>"_" then%>_<%=trim(RS("seq1"))%><%End IF%></td>
		<td width="15%" align="center" bgcolor="#FFFFFF"><%IF trim(RS("mark"))="T" then%>ˇ<%else%>　<%End IF%></td>
		<td width="15%" align="center" bgcolor="#FFFFFF"><%IF trim(RS("mark"))="L" then%>ˇ<%else%>　<%End IF%></td>	
		  <td width="55%" bgcolor="#FFFFFF" colspan=3><%=trim(RSS("dmt_goodname"))%></td>
		  <%
			RSS.movenext
			wend
			RSS.close
			set RSS=nothing
		  %>
      </tr>
     
      </table>
 </td></tr>
  <%
		RS.movenext
		i=i+1
		wend
		RS.close
		set RS=nothing
      %>
 <tr>
    <td width="15%" align="left" bgcolor="#CCFFCC" ROWSPAN=3 >備註: </td>
    <%
    
		SQL1="Select  other_item  from dmt_tran where in_no='"&in_no&"' "
		Set RSS=Conn.execute(SQL1)
		IF not RSS.EOF then		
			IF trim(RSS("other_item"))<>empty then
				other_item_1=trim(RSS("other_item"))
				other_item=split(trim(RSS("other_item")),";")
			End IF
		End IF
		RSS.close
		SET RSS=nothing
    %>
    <td width="37%" bgcolor="#FFFFFF" colspan="4">本件商標（標章）於<%IF other_item_1<>empty then%><%IF other_item(0)<>empty then%>　<%=other_item(0)%><%Else%>　　　　<%End IF%><%Else%>　　　　<%End IF%>（年/月/日）</td>
</tr>
<tr>
    <td width="37%" bgcolor="#FFFFFF" colspan="5">另案辦理<% IF instr(1,other_item_1,"DO1")<>0 then%>ˇ<%Else%>　<%End IF%>異議案　　　<% IF instr(1,other_item_1,"DI1")<>0 then%>ˇ<%Else%>　<%End IF%>評定案　　　<% IF instr(1,other_item_1,"FT1")<>0 then%>ˇ<%Else%>　<%End IF%>移轉案　　　<% IF instr(1,other_item_1,"FC1")<>0 then%>ˇ<%Else%>　<%End IF%>變更案　　　<% IF instr(1,other_item_1,"FR1")<>0 then%>ˇ<%Else%>　<%End IF%>延展案　　　</td>
</tr>
<tr>
    <td width="37%" bgcolor="#FFFFFF" colspan="5">　　　　<% IF instr(1,other_item_1,"ZZ")<>0 then%>ˇ<%Else%>　<%End IF%>其他<%IF other_item_1<>empty then%><%IF other_item(2)<>empty then%>:　<%=other_item(2)%>　案<%Else%>　　　　<%End IF%><%End IF%></td>
</tr>
<tr>
	<td width="15%" align="left" bgcolor="#CCFFCC">附件 : </td>
	<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>委任書（<% IF instr(1,remark1,"Z1C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
</tr>
<tr>
    <td width="15%" align="left" bgcolor="#CCFFCC"></td>
    <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>按分割件數之分割申請書副本（<%IF remark_2_detail<>empty then%><%=remark_2_detail%><%Else%>　<%End IF%>）份。</td>
</tr>
<%End Select%>
</table>
</center></div>