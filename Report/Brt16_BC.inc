    <div align="center"><center>
    <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
<!--#include file="Brt16_Basic.inc"-->
<%
   Gsql="select a.tran_remark1, a.tran_remark2, c.old_no,c.ocname1,c.ocname2,c.oename1,c.oename2,c.ocrep,c.oerep,c.oaddr1,c.oaddr2,a.agt_no1,a.agt_no2,b.agt_no,d.ap_cname1,d.ap_cname2,d.ap_ename1,d.ap_ename2,d.ap_crep,d.ap_erep,d.ap_addr1,d.ap_addr2 from dmt_tran a " _
      & "inner join dmt_temp b on a.in_scode=b.in_scode and a.in_no = b.in_no "_ 
      & "inner join dmt_tranlist c on a.in_scode=c.in_scode and a.in_no=c.in_no and c.mod_field='mod_ap' " _
      & "inner join apcust d on b.apsqlno=d.apsqlno "_ 
      & "where a.in_scode='" & in_scode &"' and a.in_no='"& in_no &"'"

'   response.write Gsql
'   response.end
   Set RRreg = Server.CreateObject("ADODB.RecordSet")
       RRreg.Open GSql,Conn,1,1,adcmdtext
   if not RRreg.eof then
      tran_remark1=RRreg("tran_remark1")
      tran_remark2=RRreg("tran_remark2")
      old_no=RRreg("old_no")
	  ocname1=RRreg("ocname1")	
	  ocname2=RRreg("ocname2")	
	  oename1=RRreg("oename1")	
	  oename2=RRreg("oename2")	
	  ocrep=RRreg("ocrep")	
	  oerep=RRreg("oerep")	
	  oaddr1=RRreg("oaddr1")	
	  oaddr2=RRreg("oaddr2")	
      agt_no1=RRreg("agt_no1")
      agt_no2=RRreg("agt_no2")
      agt_no=RRreg("agt_no") 
      ap_cname1=trim(RRreg("ap_cname1"))
      ap_cname2=trim(RRreg("ap_cname2"))
      ap_ename1=trim(RRreg("ap_ename1"))
      ap_ename2=trim(RRreg("ap_ename2"))
      ap_crep=trim(RRreg("ap_crep"))
      ap_erep=trim(RRreg("ap_erep")) 
      ap_addr1=trim(RRreg("ap_addr1"))
      ap_addr2=trim(RRreg("ap_addr2"))
   end if
   RRreg.close
   set RRreg=nothing
%>	  
	  <tr>
	    <td bgcolor="#CCFFCC" align="right">申請人代理人 : </td>
		<td bgcolor="#FFFFFF" colspan=3><%=agt_no1%> <%call tran_agt(agt_no1)%></td>
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
		<td bgcolor="#CCFFCC" align="right">關係人(讓與人)統一編號 : </td>
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
		<td bgcolor="#FFFFFF"><%=agt_no2%> <%call tran_agt(agt_no2)%></TD>		
	  </tr>
</table>
</center></div>