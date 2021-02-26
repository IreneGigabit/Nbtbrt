    <div align="center"><center>
    <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
  <!--#include file="Brt16_Basic.inc"-->
<%
   Gsql="select tran_remark1, tran_remark2, agt_no1,agt_no2," _
      & "term1,term2,other_item,tran_mark as mark from dmt_tran " _
      & "where in_scode='" & in_scode &"' and in_no='"& in_no &"'"

'   response.write Gsql
'   response.end
   Set RRreg = Server.CreateObject("ADODB.RecordSet")
       RRreg.Open GSql,Conn,1,1,adcmdtext

   if not RRreg.eof then
      tran_remark1=RRreg("tran_remark1")
      tran_remark2=RRreg("tran_remark2")
      agt_no1=RRreg("agt_no1") 
      agt_no2=RRreg("agt_no2")
      term1=trim(RRreg("term1"))
      term2=trim(RRreg("term2"))
      other_item=trim(RRreg("other_item"))
      mark=trim(RRreg("mark"))
   end if
   RRreg.close
   set RRreg=nothing
%>	  
            <tr>
		<td bgcolor="#CCFFCC" width="25%" align="right">證明書種類 : </td>
		<td bgcolor="#FFFFFF" colspan=3>
		<%if mark="C" then
		     response.write "中文"
          elseif mark="E" then
		     response.write "英文"
          end if 		
 		%></td>																			 
	  </tr>
      <tr>
		<td bgcolor="#CCFFCC" align="right">
      <%if trim(Request.QueryString("add_arcase"))="WE1" then
           response.write "專用期間 :"
        elseif trim(Request.QueryString("add_arcase"))="WE2" then
           response.write "申請註冊日期 :"
        end if%>
		</td>
		<td bgcolor="#FFFFFF" colspan=3>
		<%if trim(Request.QueryString("add_arcase"))="WE1" then 
		     response.write term1&"~"&term2 
		  elseif trim(Request.QueryString("add_arcase"))="WE2" then 
		     response.write term1 
		  end if
		  %></td>																			 
	  </tr>
	  <tr>
		<td bgcolor="#CCFFCC" align="right">商標法施行細則第/條 : </td>
		<td bgcolor="#FFFFFF" colspan=3><%=other_item%></TD>
	  </tr>
	  <tr>
		<td bgcolor="#CCFFCC" align="right">中文商品(服務)名稱 : </td>
		<td bgcolor="#FFFFFF" colspan=3><%=tran_remark1%></TD>
	  </tr>
	  <tr>
		<td bgcolor="#CCFFCC" align="right">英文商品(服務)名稱 : </td>
		<td bgcolor="#FFFFFF" colspan=3><%=tran_remark2%></TD>
	  </tr>
</table>
</center></div>