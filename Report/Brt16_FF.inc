<div align="center"><center>
<table border="0" width="100%" bgcolor="#000000" cellspacing="1">
<%
   Gsql="select s_mark,pul,apply_no,issue_no,class,tcn_ref,appl_name,cappl_name,eappl_name,agt_no,draw_file from dmt_temp where in_scode='" _
   & in_scode &"' and in_no='"& in_no &"'"
Set RRreg = Server.CreateObject("ADODB.RecordSet")
    RRreg.Open GSql,Conn,1,1,adcmdtext

if not RRreg.EOF then
     if isnull(RRreg("s_mark")) or trim(RRreg("s_mark")) = "" then
        s_mark=""
     else
        s_mark=trim(RRreg("s_mark"))
     end if 
     if trim(RRreg("pul"))= "" or isnull(RRreg("pul")) then
        pul=""
     else
        pul=trim(RRreg("pul"))
     end if
     apply_no=RRreg("apply_no")
     issue_no=RRreg("issue_no")
     class0=RRreg("class")
     appl_name =trim(RRreg("appl_name"))
     agt_no=trim(RRreg("agt_no"))

end if
    RRreg.close
set RRreg=nothing     
%>
      <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="left">出名代理人 : </td>
	    <td width="35%" bgcolor="#FFFFFF"><%=agt_no%> <%call tran_agt(agt_no)%></td>
	    <td width="15%" align="right" bgcolor="#CCFFCC">案件編號 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan=2><%=session("se_branch")&"T"%><%=seq%><%IF trim(seq1)<>"_" then%>_<%=seq1%><%End IF%></td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="left">繳費金額 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%if not isnull(fees) or trim(fees) <> ""  then Response.Write formatcurrency(fees,0)%></td>
	 </tr>
	 <tr>
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、號數</td>
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
	 <%Select Case trim(Request("add_arcase"))
	 Case "FF0","FF1"
	 %>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">申請號數 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan=4><%=apply_no%></td>
	</tr>
	<%Case "FF2","FF3"%>
	 <tr>	    
	    <td width="15%" align="right" bgcolor="#CCFFCC">註冊號數 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan=4><%=issue_no%></td>
	 </tr>
	<%End Select%>
	<tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">商標/標章名稱 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%=appl_name%>
	    </td>
	 </tr>
	<tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">類別 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%=class0%>
	    </td>
	 </tr>
</table>
</center></div>	 
     
     