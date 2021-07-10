<div align="center"><center>
<table border="0" width="100%" bgcolor="#000000" cellspacing="1">
<%

   SQLcom = "Exec Pro_case3 '" & in_no & "'"
   
   set RRreg = conn1.execute(SQLcom)
   IF not RRreg.eof then
	    flag=1
	    agt_no=trim(RRreg("agt_no"))
	    remark1=trim(RRreg("remark1"))
	    s_mark=trim(RRreg("S_mark"))
	    appl_name=trim(RRreg("appl_name"))
	    issue_no=trim(RRreg("issue_no"))
	    mark=trim(RRreg("mark"))
	    IF trim(RRreg("other_item"))<>empty then
			other_item_1=trim(RRreg("other_item"))
			other_item=split(trim(RRreg("other_item")),";")
	    End IF
	    IF trim(RRreg("other_item1"))<>empty then
			other_item1_1=trim(RRreg("other_item1"))
			other_item1=split(trim(RRreg("other_item1")),";")
	    End IF
	    old_no=trim(RRreg("old_no"))
	    apclass=trim(RRreg("apclass"))
	    ap_cname1 = trim(RRreg("ocname1"))
	    ap_cname2 = trim(RRreg("ocname2"))
		ap_ename1 = trim(RRreg("oename1"))
		ap_ename2  = trim(RRreg("oename2"))
		ap_crep  = trim(RRreg("ocrep"))
		ap_erep  = trim(RRreg("oerep"))
		ap_zip=trim(RRreg("ozip"))
		ap_addr1  = trim(RRreg("oaddr1"))
		ap_addr2  = trim(RRreg("oaddr2"))
		ap_eaddr1  = trim(RRreg("oeaddr1"))
		ap_eaddr2  = trim(RRreg("oeaddr2"))
		ap_eaddr3  = trim(RRreg("oeaddr3"))
		ap_eaddr4  = trim(RRreg("oeaddr4"))
		tran_remark1=trim(RRreg("tran_remark1"))
		tran_remark2=trim(RRreg("tran_remark2"))
		term1=trim(RRreg("term1"))
		term2=trim(RRreg("term2"))
		debit_money=trim(RRreg("debit_money"))
   Else
		flag=3
   End IF
   
   SQL="Select ncname1 from dmt_tranlist where in_no= '" & request("in_no") & "' and in_scode='"&in_scode&"' and mod_field='mod_dmt'"
			set RAreg = conn1.execute(SQL)
	if not RAreg.eof then
		new_appl_name=trim(RAreg("ncname1"))
	End IF
	RAreg.close
	SET RAreg=nothing
 
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
    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、註冊號數、商標種類及名稱</td>
 </tr>
<tr>
	<td width="15%" align="right" bgcolor="#CCFFCC">註冊號數 : </td>
	<td width="35%" bgcolor="#FFFFFF"><%=issue_no%></td>
	<td width="15%" align="right" bgcolor="#CCFFCC">商標種類 : </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="2">
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
    <td width="15%" bgcolor="#CCFFCC"><p align="right">商標/標章名稱 : </td>
    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%=appl_name%></td>
 </tr>
 <%
	Select Case trim(request("add_arcase"))
	Case "FP1"%>
 <tr>
    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">肆、關係人（質權人）</td>
 </tr>
 <%isql="select old_no,ocname1,ocname2,ozip,oaddr1,oaddr2,oeaddr1,oeaddr2,oeaddr3,oeaddr4,ocrep,oerep from dmt_tranlist where in_no='" & in_no & "' and mod_field='mod_ap' "
   set ISS=conn.execute(isql)
   k=0
   while not ISS.eof
      k=k+1
      old_no=ISS("old_no")
      ap_cname1=trim(ISS("ocname1"))
      ap_cname2=trim(ISS("ocname2"))
      ap_zip=trim(ISS("ozip"))
      ap_addr1=trim(ISS("oaddr1"))
      ap_addr2=trim(ISS("oaddr2"))
      ap_eaddr1=trim(ISS("oeaddr1"))
      ap_eaddr2=trim(ISS("oeaddr2"))
      ap_eaddr3=trim(ISS("oeaddr3"))
      ap_eaddr4=trim(ISS("oeaddr4"))
      ap_crep=trim(ISS("ocrep"))
      ap_erep=trim(ISS("oerep"))
 %>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC"><font color="blue"><%=k%>.</font>關係人統一編號 : </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=old_no%></td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC">關係人名稱（中） : </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=ap_cname1%><%=ap_cname2%></td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC">關係人名稱（英） : </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=ap_ename1%><%=ap_ename2%></td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC">關係人地址（中） : </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%IF ap_zip<>empty then%>(<%=ap_zip%>)<%End IF%><%=ap_addr1%><%=ap_addr2%></td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC">關係人地址（英） : </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=ap_eaddr1%><%=ap_eaddr2%><%=ap_eaddr3%><%=ap_eaddr4%></td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC">關係代表人（中） : </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=ap_crep%></td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC">關係代表人（英） : </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=ap_erep%></td>
 </tr>
<%	 ISS.movenext
  wend
  set ISS=nothing
%>  	 
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC" colspan=5>陸、另案一併設定質權之防護商標註冊號數 </td>
 </tr>
 <tr>
	<td width="35%" bgcolor="#FFFFFF" colspan="5"><%IF tran_remark1<>empty then%><%=tran_remark1%><%Else%>　<%End IF%></td>
 </tr>
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC" colspan=5>柒、未一併設定質權之防護商標號數</td>
 </tr>
 <tr>
	<td width="35%" bgcolor="#FFFFFF" colspan="5"><%IF tran_remark2<>empty then%><%=tran_remark2%><%Else%>　<%End IF%></td>
 </tr>
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC" colspan=5>捌、設定質權期間 </td>
 </tr>
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC"></td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4">自　<%=term1%>　至　<%=term2%>　</td>
 </tr>
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC" colspan=5>玖、設定質權之債權額度 </td>
 </tr>
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC"></td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%IF debit_money<>empty then%>ˇ　　<%=debit_money%><%Else%>　<%end IF%> 元整</td>
 </tr>
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC"></td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%IF other_item1_1<>empty then%>ˇ<%=other_item1(0)%><%Else%>　<%End IF%> 件，總計 <%IF other_item1_1<>empty then%><%=other_item1(1)%><%Else%>　<%End IF%> 元整</td>
 </tr>
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC" colspan=5>拾、附件 </td>
 </tr>
 	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>設定質權契約書或其他設定質權證明文件（<% IF instr(1,remark1,"Z1C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>申請人之代理人委任書（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>關係人之代理人委任書（<% IF instr(1,remark1,"Z3C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他</td>
	 </tr>
	 <tr>
	    <td width="15%" align="left" bgcolor="#CCFFCC" ROWSPAN=3 >附註: </td>
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
	    <td width="37%" bgcolor="#FFFFFF" colspan="5">另案辦理<% IF instr(1,other_item_1,"FT1")<>0 then%>ˇ<%Else%>　<%End IF%>移轉案　　　<% IF instr(1,other_item_1,"FL1")<>0 then%>ˇ<%Else%>　<%End IF%>授權案　　　<% IF instr(1,other_item_1,"FL2")<>0 then%>ˇ<%Else%>　<%End IF%>再授權案</td>
	</tr>
	<tr>
	    <td width="37%" bgcolor="#FFFFFF" colspan="5">　　　　<% IF instr(1,other_item_1,"FI1")<>0 then%>ˇ<%Else%>　<%End IF%>補證案　　　<% IF instr(1,other_item_1,"FC1")<>0 then%>ˇ<%Else%>　<%End IF%>變更案　　　<% IF instr(1,other_item_1,"FR1")<>0 then%>ˇ<%Else%>　<%End IF%>延展案</td>
	</tr>
<%Case "FP2"%>
 <tr>
    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">肆、關係人（質權人）</td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC">關係人統一編號 : </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=old_no%></td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC">關係人名稱（中） : </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=ap_cname1%><%=ap_cname2%></td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC">關係人名稱（英） : </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=ap_ename1%><%=ap_ename2%></td>
 </tr>
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC" colspan=5>伍、質權消滅日期 </td>
 </tr>
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC"></td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=term1%></td>
 </tr>
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC" colspan=5>陸、附件 </td>
 </tr>
 	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>質權消滅同意書或其他質權消滅證明文件（<% IF instr(1,remark1,"Z1C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>申請人之代理人委任書（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他</td>
	 </tr>
<%End Select%>
</table>
</center></div>