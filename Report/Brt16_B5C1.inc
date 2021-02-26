<div align="center"><center>
<table border="0" width="100%" bgcolor="#000000" cellspacing="1">
<%
   Gsql="select a.issue_no,a.s_mark,a.appl_name,a.agt_no,a.remark3,a.mark"_
   &",b.tran_mark,b.other_item,b.other_item1,b.other_item2,b.tran_remark1 "_
   &" from dmt_temp as a inner join dmt_tran as b on b.in_no=a.in_no and a.in_no=b.in_no where a.in_scode='" _
   & in_scode &"' and a.in_no='"& in_no &"'"
   'response.write gsql
Set RRreg = Server.CreateObject("ADODB.RecordSet")
    RRreg.Open GSql,Conn,1,1

if not RRreg.EOF then
 	 issue_no=RRreg("issue_no")
     if isnull(RRreg("s_mark")) or trim(RRreg("s_mark")) = "" then
        s_mark=""
     else
        s_mark=trim(RRreg("s_mark"))
     end if 
     appl_name =trim(RRreg("appl_name"))
     agt_no=trim(RRreg("agt_no"))
     remark3=trim(RRreg("remark3"))
     mark=trim(RRreg("mark"))
     tran_mark=trim(RRreg("tran_mark"))
     other_item=trim(RRreg("other_item"))
     other_item1=trim(RRreg("other_item1"))
     other_item2=trim(RRreg("other_item2"))
     tran_remark1=trim(RRreg("tran_remark1"))
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
    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">
    <%Select case trim(Request("add_arcase"))
    Case "DE1","AD7"
		Response.write "壹、申請舉行聽證的案件"
    Case "DE2","AD8"
		Response.write "壹、申請出席聽證的案件"
    End Select
    %>
    </td>
 </tr>
<tr>
	<td width="15%" align="right" bgcolor="#CCFFCC">註冊號數 : </td>
	<td width="35%" bgcolor="#FFFFFF"><%=issue_no%></td>
	   <td width="15%" bgcolor="#CCFFCC"><p align="right">商標/標章名稱 : </td>
	   <td width="35%" bgcolor="#FFFFFF" colspan="2"><%=appl_name%></td>
</tr>	   
<tr>	   
	<td width="15%" align="right" bgcolor="#CCFFCC">商標種類 :</td>
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
	<td width="15%" align="right" bgcolor="#CCFFCC">聽證案件 :</td>
	<td width="35%" bgcolor="#FFFFFF" colspan="4">
	<%select case remark3
	    case "DI1"%>
			評定案件
	    <%case "DO1"%>
			異議案件
	    <%case "DR1"%>
			廢止案件
	    <%end select%>
	</td>
</tr>
<tr>
    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">貳、申請人</td>
</tr>
<%Select case trim(Request("add_arcase"))
    Case "DE1","AD7"%>	   
	<tr>
			<td width="15%" align="right" bgcolor="#CCFFCC">申請人種類 :</td>
			<td width="35%" bgcolor="#FFFFFF" colspan="4">
				評定案件或異議案件或廢止案件之
				<%IF trim(mark)="A" then%>
					申請人
				<%elseIF trim(mark)="I" then%>	
					註冊人
				<%End IF%>
			</td>
	</tr>
	<tr>
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">肆、對照當事人</td>
	</tr>
	<tr>
		<td width="15%" align="right" bgcolor="#CCFFCC">種　　　　類 :</td>
		<td width="35%" bgcolor="#FFFFFF" colspan="4">
			評定案件或異議案件或廢止案件之
				<%IF trim(tran_mark)="A" then%>
					申請人
				<%elseIF trim(tran_mark)="I" then%>	
					註冊人
				<%End IF%>
		</td>
	</tr>
	<tr>
		<td width="15%" align="right" bgcolor="#CCFFCC">名　　　　稱 :</td>
		<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=other_item%></td>
	</tr>
	<tr>
		<td width="15%" align="right" bgcolor="#CCFFCC">地　　　　址 :</td>
		<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=other_item1%></td>
	</tr>
	<tr>
		<td width="15%" align="right" bgcolor="#CCFFCC">代　&nbsp;&nbsp;理&nbsp;&nbsp;　人&nbsp;:</td>
		<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=other_item2%></td>
	</tr>
	<tr>
		<td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、應舉行聽證之理由（請羅列聽證爭點要旨，逐項敘明理由，並檢附正副本各一份）</td>
	</tr>
	<tr>
		<td width="35%" bgcolor="#FFFFFF" colspan="5"><%=tran_remark1%></td>
	</tr>
<%Case "DE2","AD8"%>
	<tr> 
			<td width="15%" align="right" bgcolor="#CCFFCC">種  類 :</td>
			<td width="35%" bgcolor="#FFFFFF" colspan="4">
				<%IF trim(mark)="B" then%>
					爭議案申請人或異議人
				<%ElseIF trim(mark)="I" then%>
					系爭商標商標權人
				<%ElseIF trim(mark)="R" then%>
					利害關係人
				<%End IF%>
			</td>
	</tr>
	<tr>
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">參、出席代表姓名或代理姓名</td>
	</tr>
	<tr>
		<td width="15%" align="right" bgcolor="#CCFFCC">指定發言姓名 :</td>
		<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=other_item%></td>
	</tr>
	<tr>
		<td width="15%" align="right" bgcolor="#CCFFCC">職　　　　稱 :</td>
		<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=other_item1%></td>
	</tr>
	<tr>
		<td width="15%" align="right" bgcolor="#CCFFCC">聯&nbsp;&nbsp;&nbsp;絡&nbsp;&nbsp;&nbsp;電&nbsp;&nbsp;&nbsp;話:</td>
		<td width="35%" bgcolor="#FFFFFF" colspan="4"><%=other_item2%></td>
	</tr>
	<tr>
		<td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">附註：新事證及陳述意見書</td>
	</tr>
	<tr>
		<td width="35%" bgcolor="#FFFFFF" colspan="5"><%=tran_remark1%></td>
	</tr>
<%End Select%>
 
</table>
</center></div>	 
     
     