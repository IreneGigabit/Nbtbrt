<div align="center"><center>
<table border="0" width="100%" bgcolor="#000000" cellspacing="1">
<%
   Gsql="select s_mark,apply_no,issue_no,appl_name,agt_no,mark,remark1,rej_no from dmt_temp where in_scode='" _
   & in_scode &"' and in_no='"& in_no &"'"
Set RRreg = Server.CreateObject("ADODB.RecordSet")
    RRreg.Open GSql,Conn,1,1,adcmdtext

if not RRreg.EOF then
     if isnull(RRreg("s_mark")) or trim(RRreg("s_mark")) = "" then
        s_mark=""
     else
        s_mark=trim(RRreg("s_mark"))
     end if 
     issue_no=trim(RRreg("issue_no"))
     apply_no=trim(RRreg("apply_no"))
     rej_no=trim(RRreg("rej_no"))
     appl_name =trim(RRreg("appl_name"))
     agt_no=trim(RRreg("agt_no"))
     remark1=trim(RRreg("remark1"))
     mark=trim(RRreg("mark"))

end if
    RRreg.close
set RRreg=nothing     
%>
      <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">出名代理人 : </td>
	    <td width="35%" bgcolor="#FFFFFF"><%=agt_no%> <%call tran_agt(agt_no)%></td>
	    <td width="15%" align="right" bgcolor="#CCFFCC">案件編號 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan=2><%=session("se_branch")&"T"%><%=seq%><%IF trim(seq1)<>"_" then%>_<%=seq1%><%End IF%></td>
	 </tr>
	 <tr>
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、號數（前商標局核准註冊【係於大陸註冊之商標】，請於號數前加註「前商標局」字樣）</td>
	 </tr>
	 <tr>	    
	    <td width="15%" align="right" bgcolor="#CCFFCC">程序種類 : </td>
	    <td width="35%" bgcolor="#FFFFFF">
	    <%Select Case mark
	    Case "A"%>
			申請
	    <%Case "I"%>
			註冊
	    <%Case "R"%>
			核駁
		<%End Select%>	
	    </td>
	    <td width="15%" align="right" bgcolor="#CCFFCC">
			<%Select Case mark
			Case "A"%>
				申請
			<%Case "I"%>
				註冊
			<%Case "R"%>
				核駁
			<%End Select%>	
		號數 : </td>
	    <td width="35%" bgcolor="#FFFFFF">
	    <%Select Case mark
			Case "A"%>
			　	<%=apply_no%>
			<%Case "I"%>
				<%=issue_no%>
			<%Case "R"%>
				<%=rej_no%>
			<%End Select%>	
	    </td>
	 </tr>
 	<tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">商標/標章名稱 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%=appl_name%>
	    </td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">商標種類 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4">
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
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">肆、閱卷理由</td>
	 </tr>
	 <%
		SQL="Select tran_remark1 from dmt_tran where in_no='"&in_no&"'"
		Set RSS=Conn.execute(SQL)
		IF NOT RSS.EOF then
			tran_remark1=trim(RSS("tran_remark1"))
		End IF
		RSS.close
		Set RSS=nothing
	 %>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%=tran_remark1%></td>
	 </tr>
	 <tr>
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、附件</td>
	 </tr>
	 <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>申請人證明文件（<% IF instr(1,remark1,"Z1C")<>0 then%>ˇ<%Else%>　<%End IF%>外文者應附中譯本）。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>申請人之代理人委任書（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他。</td>
      </tr>
</table>
</center></div>	 
