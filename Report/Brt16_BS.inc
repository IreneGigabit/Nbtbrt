    <div align="center"><center>
    <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
<!--#include file="Brt16_Basic.inc"-->
<%
   Gsql="select term1, term2, agt_no1, tran_remark1,tran_remark2, other_item from dmt_tran " _ 
   & "where in_scode='"  & in_scode &"' and in_no='"& in_no &"'"
   'response.write gsql
   
   Set RRreg = Server.CreateObject("ADODB.RecordSet")
       RRreg.Open GSql,Conn,1,1,adcmdtext
   if not RRreg.eof then
      term1=RRreg("term1")
      term2=RRreg("term2")
      agt_no1=trim(RRreg("agt_no1"))
      tran_remark1=RRreg("tran_remark1")
      tran_remark2=RRreg("tran_remark2")
      'response.write instr(1,trim(RRreg("other_item")),";") 
      'response.end
      if instr(1,trim(RRreg("other_item")),";") > 0 then
         if trim(RRreg("other_item")) <> "" or not isnull(RRreg("other_item")) then
            other_item=split(trim(RRreg("other_item")),";")
            other_item0=other_item(0)
            other_item1=other_item(1)
         end if
      end if   
      agt_no1=RRreg("agt_no1") 
   end if

%>	
      <tr>
		<td bgcolor="#CCFFCC" width="25%" align="right">專用期間 : </td>
		<td bgcolor="#FFFFFF" colspan=3><%=term1%>~<%=term2%></td>																			 
	  </tr>
      <tr>
		<td bgcolor="#CCFFCC" align="right">商標法施行細則第/條 : </td>
		<td bgcolor="#FFFFFF" colspan=3><%=tran_remark2%></td>
	  </tr>
      <tr>
		<td bgcolor="#CCFFCC" align="right">商品(營業)名稱 : </td>
		<td bgcolor="#FFFFFF" colspan=3><%=tran_remark1%></td>																			 
	  </tr>
      <tr>
		<td bgcolor="#CCFFCC" align="right">附註 : </td>
		<td bgcolor="#FFFFFF" colspan=3>
		<%if instr(1,trim(RRreg("other_item")),";") > 0 then response.write "本商標(標章)於" & other_item0 & "，另案辦理"
		sql="select rs_detail,case_name from code_brt where" _
		  & " dept='T' and cg='C' and rs='R' and rs_code='" & other_item1 & "'"
		set rs=conn.execute(sql)  
		if not rs.eof then 
		   response.write trim(rs(1))&"案"
		end if   
		rs.close
		set rs=nothing

RRreg.close
set RRreg=nothing
		%>
		</td></tr>
</table>
</center></div>