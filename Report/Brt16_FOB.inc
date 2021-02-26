<div align="center"><center>
<form name=reg>
<table border="0" width="100%" bgcolor="#000000" cellspacing="1">
<%
   SQLcom = "Exec Pro_case4 '" & in_no & "'"
   'response.write SQLcom
   'response.end
   set RRreg = conn1.execute(SQLcom)
   IF not RRreg.eof then
	    flag=1
	    agt_no=trim(RRreg("agt_no"))
	    s_mark=trim(RRreg("S_mark"))
	    apply_no=trim(RRreg("apply_no"))
	    appl_name=trim(RRreg("appl_name"))
	    issue_no=trim(RRreg("issue_no"))
	    mark=trim(RRreg("dmt_mark"))
	    IF trim(RRreg("other_item"))<>empty then
			remark1=trim(RRreg("other_item"))
	    End IF
	    'response.write remark1
   Else
		flag=3
   End IF
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
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、號數</td>
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
		Case "A"
			Response.write apply_no
	    Case "I"
			Response.write issue_no
	    Case "R"
			Response.write rej_no
		End Select%>	
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
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">貳、影印內容</td>
	 </tr>
	 <%	SQL="Select * from dmt_tranlist where in_no= '"&in_no&"'  and mod_field='other_item'"
		Set RSS=Conn.execute(SQL)
		while not RSS.EOF
			Select Case trim(RSS("mod_type"))
			Case "P2"
				P2_mod_dclass=trim(RSS("mod_dclass"))
				P2_new_no= trim(RSS("new_no"))
			Case "P3"
				P3_mod_dclass= trim(RSS("mod_dclass")) 
				P3_new_no= trim(RSS("new_no")) 
			Case "P4"
				P4_mod_dclass= trim(RSS("mod_dclass")) 
				P4_new_no= trim(RSS("new_no")) 				
			Case "P5"
				P5_mod_dclass= trim(RSS("mod_dclass")) 
				P5_new_no= trim(RSS("new_no")) 	
			Case "P6"
				P6_new_no= trim(RSS("new_no")) 	
			Case "P7"
				P7_new_no= trim(RSS("new_no")) 	
			Case "P8"
				P8_new_no= trim(RSS("new_no")) 		
			Case "P9"
				P9_new_no= trim(RSS("new_no")) 		
			Case "P10"
				P10_new_no= trim(RSS("new_no")) 		
			Case "P11"
				P11_new_no= trim(RSS("new_no")) 	
			End Select
			RSS.moveNext
		wend
		RSS.close
		SET RSS=nothing
	 %>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"P1")<>0 then%>ˇ<%Else%>　<%End IF%>註冊簿</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"P2")<>0 then%>ˇ<%Else%>　<%End IF%>訴願決定書　經（<%=P2_mod_dclass%>）訴第 <%=P2_new_no%> 號</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"P3")<>0 then%>ˇ<%Else%>　<%End IF%>再訴願決定書　台（<%=P3_mod_dclass%>）訴第 <%=P3_new_no%> 號</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"P4")<>0 then%>ˇ<%Else%>　<%End IF%>行政法院判決書（<%=P4_mod_dclass%>）年度裁／判字第 <%=P4_new_no%> 號</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"P5")<>0 then%>ˇ<%Else%>　<%End IF%>臺北高等行政法院判決（<%=P5_mod_dclass%>）年度訴第 <%=P5_new_no%> 號</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"P6")<>0 then%>ˇ<%Else%>　<%End IF%>最高行政法院判決書第 <%=P6_new_no%> 號</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"P7")<>0 then%>ˇ<%Else%>　<%End IF%>異議審定書第 <%=P7_new_no%> 號</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"P8")<>0 then%>ˇ<%Else%>　<%End IF%>異議案附件第 <%=P8_new_no%> 號</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"P9")<>0 then%>ˇ<%Else%>　<%End IF%>評定書第 <%=P9_new_no%> 號</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"P10")<>0 then%>ˇ<%Else%>　<%End IF%>評定書附件第 <%=P10_new_no%> 號</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"P11")<>0 then%>ˇ<%Else%>　<%End IF%>廢止處分書第 <%=P11_new_no%> 號</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"P12")<>0 then%>ˇ<%Else%>　<%End IF%>其他</td>
	 </tr>
</table>
</form>
</center></div>	 
     
     