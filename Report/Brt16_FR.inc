<div align="center"><center>
<table border="0" width="100%" bgcolor="#000000" cellspacing="1">
<%

   SQLcom = "Exec Pro_case4 '" & in_no & "'"
   'response.write sqlcom
   'response.end
   set RRreg = conn1.execute(SQLcom)
   IF not RRreg.eof then
	    flag=1
	    agt_no=trim(RRreg("agt_no"))
	    mod_ap=trim(RRreg("mod_ap"))
	    mod_aprep=trim(RRreg("mod_aprep"))
	    mod_agt=trim(RRreg("mod_agt"))
	    mod_apaddr=trim(RRreg("mod_apaddr"))
	    mod_agtaddr=trim(RRreg("mod_agtaddr"))
	    mod_oth=trim(RRreg("mod_oth"))
	    mod_oth1=trim(RRreg("mod_oth1"))
	    mod_oth2=trim(RRreg("mod_oth2"))
	    mod_dmt=trim(RRreg("mod_dmt"))
	    mod_pul=trim(RRreg("mod_pul"))
	    term1=trim(RRreg("term1"))
	    term2=trim(RRreg("term2"))
	    remark1=trim(RRreg("remark1"))
	    s_mark=trim(RRreg("S_mark"))
	    apply_no=trim(RRreg("apply_no"))
	    appl_name=trim(RRreg("appl_name"))
	    issue_no=trim(RRreg("issue_no"))
	    mark=trim(RRreg("mark"))
	    tran_remark2=trim(RRreg("tran_remark2"))
	    IF trim(RRreg("other_item"))<>empty then
			other_item_1=trim(RRreg("other_item"))
			other_item=split(trim(RRreg("other_item")),";")
	    End IF
	    pul=trim(RRreg("pul"))
	    mod_agttype=trim(RRreg("mod_agttype"))
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
    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、註冊申請案號、商標／標章名稱</td>
 </tr>
<tr>
	<td width="15%" align="left" bgcolor="#CCFFCC">註冊號數 : </td>
	<td width="35%" bgcolor="#FFFFFF"><%=issue_no%></td>
	<td width="15%" align="left" bgcolor="#CCFFCC">商標種類 : </td>
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
    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">肆、原註冊證核准專用期間</td>
 </tr>
<tr>
	<td width="15%" align="right" bgcolor="#CCFFCC">自</td>
	<td width="35%" bgcolor="#FFFFFF" ><%=term1%></td>
	<td width="15%" align="right" bgcolor="#CCFFCC">至</td>
	<td width="35%" bgcolor="#FFFFFF" colspan="2"><%=term2%></td>
 </tr>
 <tr>
    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、變更事項</td>
 </tr>
 <tr>
	<td width="10%" align="left" bgcolor="#CCFFCC"></td>
	<td width="15%" align="left" bgcolor="#FFFFFF" colspan="4"><%IF mod_ap="Y" then%>ˇ<%Else%>　<%End IF%>申請人名稱　　<%IF mod_aprep="Y" then%>ˇ<%Else%>　<%End IF%>代表人或負責人　　　　<%IF mod_agt="Y" then%>ˇ<%Else%>　<%End IF%>代理人      <%if mod_agttype<>empty then %>     代理人異動：<%if mod_agttype="C" then%>ˇ變更<%end if%><%if mod_agttype="A" then%>ˇ新增<%end if%><%if mod_agttype="D" then%>ˇ撤銷<%end if%><%end if%></td> 
 </tr>
 <tr>
	<td width="10%" align="left" bgcolor="#CCFFCC"></td>
	<td width="15%" align="left" bgcolor="#FFFFFF" colspan="4"><%IF mod_apaddr="Y" then%>ˇ<%Else%>　<%End IF%>申請人地址　　<%IF mod_agtaddr="Y" then%>ˇ<%Else%>　<%End IF%>代理人地址　　　　　　<%IF mod_pul="Y" then%>ˇ<%Else%>　<%End IF%>防護商標／標章變更為獨立商標</td>
 </tr>
 <tr>
	<td width="10%" align="left" bgcolor="#CCFFCC"></td>
	<td width="15%" align="left" bgcolor="#FFFFFF" colspan="4"><%IF mod_oth="Y" then%>ˇ<%Else%>　<%End IF%>申請人印鑑　　<%IF mod_oth1="Y" then%>ˇ<%Else%>　<%End IF%>代表人或負責人印鑑　　<%IF mod_oth2="Y" then%>ˇ<%Else%>　<%End IF%>代理人印鑑</td>
 </tr>
 <tr>
	<td width="10%" align="left" bgcolor="#CCFFCC"></td>
	<td width="15%" align="left" bgcolor="#FFFFFF" colspan="4"><%IF mod_dmt="Y" then%>ˇ<%Else%>　<%End IF%>商標／標章名稱<%IF new_appl_name<>empty then%> : <%=new_appl_name%><%End IF%></td>
 </tr>
	  <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">陸、延展商標權範圍及內容</td>
      </tr>
      
      <tr>
		<td width="15%" align="right" bgcolor="#CCFFCC">一、</td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF mark="N" then%>ˇ<%Else%>　<%End IF%>全部延展（毋庸填寫商品／服務、證明標的／內容、表章內容）</td>
	　</tr>
	　<tr>
		<td width="15%" align="right" bgcolor="#CCFFCC">二、</td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF mark="Y" then%>ˇ<%Else%>　<%End IF%>部份延展</td>
	　</tr>
	　<tr><td colspan=5>
      <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
      <tr>
        <td width="5%" align="center" bgcolor="#CCFFCC">類別 </td>
        <td width="15%" align="center" bgcolor="#CCFFCC">群組代號 </td>
        <td width="80%" align="center" bgcolor="#CCFFCC" colspan=2>商品／服務名稱</td>
      </tr>
      
      <%SQL="Select * from casedmt_good where in_no='"& in_no & "' order by cast(class as int)"
	Set RSS=Conn.execute(SQL)
	%>
      <%while not RSS.Eof %>
      <tr>
		<td width="5%" bgcolor="#FFFFFF" align="right"><%=trim(RSS("class"))%></td>
		<td width="15%" bgcolor="#FFFFFF" align="center"><%=trim(RSS("dmt_grp_code"))%></td>
		<td width="80%" bgcolor="#FFFFFF" colspan=2><%=trim(RSS("dmt_goodname"))%></td>
      </tr>
      <%
			RSS.movenext
		wend
		RSS.close
		set RSS=nothing
      %>
      </table>
		</td></tr>
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC" colspan=5>柒、附件 </td>
 </tr>
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC"></td>
	<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>大陸地區（含港、澳地區）之自然人或法人之身分證明文件。</td>
 </tr>
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC"></td>
	<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>委任書（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
 </tr>
 <tr>
	<td width="15%" align="left" bgcolor="#CCFFCC"></td>
	<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>變更證明文件</td>
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
    <td width="37%" bgcolor="#FFFFFF" colspan="5">另案辦理<% IF instr(1,other_item_1,"FI1")<>0 then%>ˇ<%Else%>　<%End IF%>補證案　　　<% IF instr(1,other_item_1,"FT1")<>0 then%>ˇ<%Else%>　<%End IF%>移轉案　　　<% IF instr(1,other_item_1,"FL1")<>0 then%>ˇ<%Else%>　<%End IF%>授權案　　　<% IF instr(1,other_item_1,"ZZ")<>0 then%>ˇ<%Else%>　<%End IF%>其他</td>
</tr>
</table>
</center></div>