    <div align="center"><center>
    <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
<%
   Gsql="select agt_no1,tran_remark1,b.* from dmt_tran as a,dmt_temp as b " _
      & "where a.in_scode='" & in_scode &"' and a.in_no='"& in_no &"' and a.in_no=b.in_no and a.in_scode=b.in_scode"
'response.write Gsql
'response.end

   Set RRreg = Server.CreateObject("ADODB.RecordSet")
       RRreg.Open GSql,Conn,1,1,adcmdtext
	
   if not RRreg.eof then
      s_mark=trim(RRreg("s_mark"))
      agt_no=trim(RRreg("agt_no"))
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
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、承辦內容說明</td>
	 </tr>	  
	 <tr>
		<td bgcolor="#CCFFCC" align="right">交辦事項 : </td>
		<td bgcolor="#FFFFFF" colspan=4><%=tran_remark1%></TD>
	 </tr>
</table>
</center></div>