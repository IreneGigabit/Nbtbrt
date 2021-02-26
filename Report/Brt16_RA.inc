    <div align="center"><center>
    <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
  <!--#include file="Brt16_Basic.inc"-->
<%
   Gsql="select agt_no1,term1 from dmt_tran " _
      & "where in_scode='" & in_scode &"' and in_no='"& in_no &"'"

'   response.write Gsql
'   response.end
   Set RRreg = Server.CreateObject("ADODB.RecordSet")
       RRreg.Open GSql,Conn,1,1,adcmdtext

   if not RRreg.eof then
      agt_no1=trim(RRreg("agt_no1"))
      term1=trim(RRreg("term1"))
   end if
   RRreg.close
   set RRreg=nothing
%>	  
	  <tr>
		<td bgcolor="#CCFFCC" align="right">
		<%if trim(Request.QueryString("add_arcase")) = "RAG" then
		     response.write "終止(再)授權日期 : "
		  else
		     response.write "塗銷設定質權日期 : "
		  end if%>
		</td>
		<td bgcolor="#FFFFFF" colspan=3><%=term1%></TD>
	  </tr>
</table>
</center></div>