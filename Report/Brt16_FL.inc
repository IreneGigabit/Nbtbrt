<div align="center"><center>
<table border="0" width="100%" bgcolor="#000000" cellspacing="1">
<%

   SQLcom = "Exec Pro_case3 '" & in_no & "'"
   'response.write SQLcom
   set RRreg = conn1.execute(SQLcom)
   IF not RRreg.eof then
	    flag=1
	    agt_no=trim(RRreg("agt_no"))
	    remark1=trim(RRreg("remark1"))
	    s_mark=trim(RRreg("S_mark"))
	    appl_name=trim(RRreg("appl_name"))
	    issue_no=trim(RRreg("issue_no"))
	    mark=trim(RRreg("dmt_mark"))
	    IF trim(RRreg("other_item"))<>empty then
			other_item_1=trim(RRreg("other_item"))
			other_item=split(trim(RRreg("other_item")),";")
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
		new_no=trim(RRreg("new_no"))
		ncname1=trim(RRreg("ncname1"))
		ncname2=trim(RRreg("ncname2"))
		nename1=trim(RRreg("nename1"))
		nename2=trim(RRreg("nename2"))
   Else
		flag=3
   End IF
   
   SQL="Select ncname1 from dmt_tranlist where in_no= '" & in_no & "' and mod_field='mod_dmt'"
			set RAreg = conn1.execute(SQL)
	if not RAreg.eof then
		new_appl_name=trim(RAreg("ncname1"))
	End IF
	RAreg.close
	SET RAreg=nothing
	

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
 <tr>
    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、註冊號數、商標（標章）種類及名稱</td>
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
 <tr>
    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">貳、申請人</td>
 </tr>
 <tr>
	<td width="15%" align="right" bgcolor="#CCFFCC">申請人種類 : </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%IF mark="A" then%>ˇ<%Else%>　<%End IF%>授權人　　　　　　<%IF mark="B" then%>ˇ<%Else%>　<%End IF%>被授權人</td>
 </tr>
 <%IF mark="A" then
		ap_kind="被授權"
   ElseIF mark="B" then
		ap_kind="授權"
   End IF
	
 %>
 <tr>
    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、<%=ap_kind%>人</td>
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
	<td width="20%" align="right" bgcolor="#CCFFCC"><font color="blue"><%=k%>.</font><%=ap_kind%>人統一編號: </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=old_no%></td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC"><%=ap_kind%>人名稱（中）: </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=ap_cname1%><%=ap_cname2%></td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC"><%=ap_kind%>人名稱（英）: </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=ap_ename1%><%=ap_ename2%></td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC"><%=ap_kind%>人地址（中）: </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%IF ap_zip<>empty then%>(<%=ap_zip%>)<%End IF%><%=ap_addr1%><%=ap_addr2%></td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC"><%=ap_kind%>人地址（英）: </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=ap_eaddr1%><%=ap_eaddr2%><%=ap_eaddr3%><%=ap_eaddr4%></td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC"><%=ap_kind%>代表人（中）: </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=ap_crep%></td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC"><%=ap_kind%>代表人（英）: </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=ap_erep%></td>
 </tr>
 <%	 ISS.movenext
  wend
  set ISS=nothing
%>  
 <%IF trim(request("add_arcase"))="FL2" then%>
	<tr>
		<td width="15%" align="left" bgcolor="#CCFFCC" colspan=5>陸、商標權人 </td>
	</tr>
<%isql="select new_no,ncname1,ncname2,nename1,nename2 from dmt_tranlist where in_no='" & in_no & "' and mod_field='mod_tap' "
   set ISS=conn.execute(isql)
   k=0
   while not ISS.eof
      k=k+1
      new_no=ISS("new_no")
      ncname1=trim(ISS("ncname1"))
      ncname2=trim(ISS("ncname2"))
	  nename1=trim(ISS("nename1"))
      nename2=trim(ISS("nename2"))	
 %>	
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC"><font color="blue"><%=k%>.</font>商標權人統一編號: </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=new_no%></td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC">商標權人名稱（中）: </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=ncname1%><%=ncname2%></td>
 </tr>
 <tr>
	<td width="20%" align="right" bgcolor="#CCFFCC">商標權人名稱（英）: </td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=nename1%><%=nename2%></td>
 </tr>
 <%	 ISS.movenext
  wend
  set ISS=nothing
  End IF%>
 <%
	Select Case trim(request("add_arcase"))
	Case "FL1","FL2"%>
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC" colspan=5>柒、授權期間 </td>
 </tr>
 <tr>
	<td width="15%" align="right" bgcolor="#CCFFCC"></td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4">自　<%=term1%>　至　<%=term2%>　</td>
 </tr>
 
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC" colspan=5>捌、<%IF trim(request("add_arcase"))="FL2" then%>再<%End IF%>授權商品或服務 </td>
 </tr>
  <%SQL="select mod_type,new_no,list_remark from dmt_tranlist  where in_no= '" & in_no & "' and mod_field='mod_class'"
	Set RSS=Conn.execute(SQL)
  %>
  <%IF trim(request("add_arcase"))="FL1" then%>
 <tr>
	<td width="15%" align="right" bgcolor="#CCFFCC">一、</td>
	<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF RSS("mod_type")="All" then%>ˇ<%Else%>　<%End IF%>全部授權(毌傭填寫商品或服務)</td>
 </tr>
 <tr>
	<td width="15%" align="right" bgcolor="#CCFFCC">二、</td>
	<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF RSS("mod_type")="Part" then%>ˇ<%Else%>　<%End IF%>部份授權(請按商品/服務類別分別填寫商品/服務名稱類別)</td>
 </tr>
  <%End IF%>
  <tr><td colspan=5>
      <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
	  <tr>
        <td width="5%" align="center" bgcolor="#CCFFCC">類別 </td>
        <td width="80%" align="center" bgcolor="#CCFFCC" colspan=4>商品／服務名稱</td>
      </tr>
      <%while not RSS.Eof %>
      <tr>
		<td width="10%" bgcolor="#FFFFFF" align="center"><%=trim(RSS("new_no"))%></td>
		<td width="80%" bgcolor="#FFFFFF" colspan=4><%=trim(RSS("list_remark"))%></td>
      </tr>
      <%
			RSS.movenext
		wend
		RSS.close
		set RSS=nothing
      %>
      </table></td></tr>
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC" colspan=5>玖、附件 </td>
 </tr>
 <%IF trim(request("add_arcase"))="FL1" then%>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>授權契約書或其他授權證明文件（<% IF instr(1,remark1,"Z1C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>商標權人之代理人委任書（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>被授權人之代理人委任書（<% IF instr(1,remark1,"Z3C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他</td>
	 </tr>
	 <tr>
	    <td width="15%" align="right" bgcolor="#CCFFCC" ROWSPAN=3 >附註: </td>
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
	    <td width="37%" bgcolor="#FFFFFF" colspan="5">另案辦理<% IF instr(1,other_item_1,"FT1")<>0 then%>ˇ<%Else%>　<%End IF%>移轉案　　　<% IF instr(1,other_item_1,"FP1")<>0 then%>ˇ<%Else%>　<%End IF%>質權案　　　<% IF instr(1,other_item_1,"FI1")<>0 then%>ˇ<%Else%>　<%End IF%>補證案</td>
	</tr>
	<tr>
	    <td width="37%" bgcolor="#FFFFFF" colspan="5">　　　　<% IF instr(1,other_item_1,"FC1")<>0 then%>ˇ<%Else%>　<%End IF%>變更案　　　<% IF instr(1,other_item_1,"FR1")<>0 then%>ˇ<%Else%>　<%End IF%>延展案　　　<% IF instr(1,other_item_1,"FL2")<>0 then%>ˇ<%Else%>　<%End IF%>再授權案</td>
	</tr>
	<%elseIF trim(request("add_arcase"))="FL2" then%>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>再授權契約書或其他再授權證明文件（<% IF instr(1,remark1,"Z1C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>授權人之代理人委任書（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>被授權人之代理人委任書（<% IF instr(1,remark1,"Z3C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z4")<>0 then%>ˇ<%Else%>　<%End IF%>商標權人同意再授權證明文件</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他</td>
	 </tr>
	 <tr>
	    <td width="15%" align="right" bgcolor="#CCFFCC" ROWSPAN=3 >附註: </td>
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
	    <td width="37%" bgcolor="#FFFFFF" colspan="5">另案辦理<% IF instr(1,other_item_1,"FT1")<>0 then%>ˇ<%Else%>　<%End IF%>移轉案　　　<% IF instr(1,other_item_1,"FP1")<>0 then%>ˇ<%Else%>　<%End IF%>質權案　　　<% IF instr(1,other_item_1,"FI1")<>0 then%>ˇ<%Else%>　<%End IF%>補證案</td>
	</tr>
	<tr>
	    <td width="37%" bgcolor="#FFFFFF" colspan="5">　　　　<% IF instr(1,other_item_1,"FC1")<>0 then%>ˇ<%Else%>　<%End IF%>變更案　　　<% IF instr(1,other_item_1,"FR1")<>0 then%>ˇ<%Else%>　<%End IF%>延展案　　　<% IF instr(1,other_item_1,"FL1")<>0 then%>ˇ<%Else%>　<%End IF%>授權案</td>
	</tr>
	<%End IF%>
<%Case "FL3"%>
	<tr>
		<td width="15%" align="left" bgcolor="#CCFFCC">柒、終止授權日期 : </td>
		<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=term1%></td>
	</tr>
	<tr>
		<td width="15%" align="left" bgcolor="#CCFFCC" colspan=5>捌、附件 </td>
	</tr>
	<tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>終止授權同意書或其他終止授權證明文件（<% IF instr(1,remark1,"Z1C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>商標權人之代理人委任書（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>被授權人之代理人委任書（<% IF instr(1,remark1,"Z3C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他</td>
	 </tr>
<%Case "FL4"%>
	<tr>
		<td width="15%" align="left" bgcolor="#CCFFCC">柒、終止再授權日期 : </td>
		<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=term1%></td>
	</tr>
	<tr>
		<td width="15%" align="left" bgcolor="#CCFFCC" colspan=5>捌、附件 </td>
	</tr>
	<tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>終止再授權同意書或其他終止再授權證明文件（<% IF instr(1,remark1,"Z1C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>授權人之代理人委任書（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>被授權人之代理人委任書（<% IF instr(1,remark1,"Z3C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他</td>
	 </tr>
<%End Select%>
</table>
</center></div>