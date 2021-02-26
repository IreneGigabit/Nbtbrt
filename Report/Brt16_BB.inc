    <div align="center"><center>
    <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
  <!--#include file="Brt16_Basic.inc"-->
<%
   Gsql="select a.tran_remark1, a.tran_remark2, c.old_no,a.agt_no1,a.agt_no2,c.ocname1,c.ocname2,c.oename1" _
      & ",c.oename2,c.ocrep,c.oerep,c.ozip,c.oaddr1,c.oaddr2,a.term1,a.term2,a.debit_money from dmt_tran a " _
      & "inner join dmt_tranlist c on a.in_scode=c.in_scode and a.in_no=c.in_no and c.mod_field='mod_ap' " _
      & "where a.in_scode='" & in_scode &"' and a.in_no='"& in_no &"'"

'   response.write Gsql
'   response.end
   Set RRreg = Server.CreateObject("ADODB.RecordSet")
       RRreg.Open GSql,Conn,1,1,adcmdtext

   if not RRreg.eof then
      tran_remark1=RRreg("tran_remark1")
      tran_remark2=RRreg("tran_remark2")
      old_no=RRreg("old_no")
      agt_no1=RRreg("agt_no1") 
      agt_no2=RRreg("agt_no2")
      ocname1=trim(RRreg("ocname1"))
      ocname2=trim(RRreg("ocname2"))
      oename1=trim(RRreg("oename1"))
      oename2=trim(RRreg("oename2"))
      ocrep=trim(RRreg("ocrep"))
      oerep=trim(RRreg("oerep")) 
      ozip=trim(RRreg("ozip"))
      oaddr1=trim(RRreg("oaddr1"))
      oaddr2=trim(RRreg("oaddr2"))
      term1=trim(RRreg("term1"))
      term2=trim(RRreg("term2"))
      debit_money=trim(RRreg("debit_money"))
   end if
   RRreg.close
   set RRreg=nothing
%>	  
   	  <tr>
		<td bgcolor="#CCFFCC" align="right">申請人代理人 : </td>
		<td bgcolor="#FFFFFF" colspan=3><%=agt_no1%><%call tran_agt(agt_no1)%></TD>
	  </tr>
      <tr>
		<td bgcolor="#CCFFCC" width="25%" align="right">一併移轉之聯/防號數 : </td>
		<td bgcolor="#FFFFFF" colspan=3><%=tran_remark1%></td>																			 
	  </tr>
      <tr>
		<td bgcolor="#CCFFCC" align="right">未一併移轉之聯/防號數 : </td>
		<td bgcolor="#FFFFFF" colspan=3><%=tran_remark2%></td>																			 
	  </tr>
      <tr>
		<td bgcolor="#CCFFCC" align="right">關係人統一編號 : </td>
		<td bgcolor="#FFFFFF" colspan=3><%=old_no%></td>																			 
	  </tr>
      <tr>
		<td bgcolor="#CCFFCC" align="right">關係人(中文) : </td>
		<td bgcolor="#FFFFFF" colspan=3><%=ocname1&ocname2%></td>																			 
	  </tr>
      <tr>
		<td bgcolor="#CCFFCC" align="right">關係人(英文) : </td>
		<td bgcolor="#FFFFFF" colspan=3><%=oename1&oename2%></td>																			 
	  </tr>
	  <tr>
        <td bgcolor="#CCFFCC" align="right">代表人(中文) : </td>
		<td bgcolor="#FFFFFF" width="30%"><%=ocrep%></TD>
		<td bgcolor="#CCFFCC" width="20%" align="right">代表人(英文) : </td>
		<td bgcolor="#FFFFFF"><%=oerep%></td>
      </tr>			
	  <tr>
		<td bgcolor="#CCFFCC" align="right">關係人地址 : </td>
		<td bgcolor="#FFFFFF"><%=oaddr1&oaddr2%></TD>	
		<td bgcolor="#CCFFCC" align="right">關係代理人 : </td>		
		<td bgcolor="#FFFFFF"><%=agt_no2%><%call tran_agt(agt_no2)%></TD>		
	  </tr>
	  <tr>
		<td bgcolor="#CCFFCC" align="right">設定質權起迄 : </td>
		<td bgcolor="#FFFFFF" colspan=3><%=term1&"~"&term2%></TD>
	  </tr>
	  <tr>
		<td bgcolor="#CCFFCC" align="right">債權額度 : </td>
		<td bgcolor="#FFFFFF" colspan=3><%=debit_money%></TD>
	  </tr>
</table>
</center></div>