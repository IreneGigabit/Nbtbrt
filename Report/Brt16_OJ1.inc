<DIV align="center">
<%
    Set RRreg = Server.CreateObject("ADODB.RecordSet")

	SQLcom = "select * from dmt_tran where in_scode='" & in_scode & "' and in_no='"& in_no & "'"
	Set RSreg = Conn.execute(sqlcom)
   
	SQLcom = "select * from dmt_temp where in_scode='" & in_scode & "' and in_no='"& in_no & "'"			       
	Set RRreg = Conn.execute(sqlcom)	
	agt_no=RRreg("agt_no")
	Draw_file=RRreg("Draw_file")
%>	
	<table border="0" class="bluetable" cellspacing="1" cellpadding="2" bgcolor="#000000" width="100%">		
		<tr>
			<td bgcolor="#CCFFCC" colspan="8" valign="top"><strong>壹、評定商標資料及爭議商標圖樣</td>
		</tr>
		<TR>
			<TD bgcolor="#CCFFCC" align=right width="30%">商標種類：</TD>
			<TD bgcolor="#FFFFFF" colspan=3>
			<%select case trim(RRreg("s_mark"))
			  case "S":response.write "服務"
			  case "L":response.write "證明"
			  case "M":response.write "團體"
			  case else:response.write "商標"
			  end select%>
			</TD>
			<td bgcolor="#CCFFCC" align=right width="30%">註冊號數：</td>
			<td bgcolor="#FFFFFF" colspan=3><%=RRreg("issue_no")%></td>
		</TR>
		<tr>
			<td bgcolor="#CCFFCC" align=right>商標/標章名稱：</td>
			<td bgcolor="#FFFFFF" colspan=7><%=RRreg("Appl_name")%></td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" colspan="8" valign="top" width="30%">　　<strong>爭議商標圖樣之<small>(請勾選並填寫內容):</small></td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" align=right><%if trim(RRreg("cappl_name")) <> "" then response.write "ˇ"%>　中文：</td>
			<td bgcolor="#FFFFFF"colspan=3><%=RRreg("cappl_name")%></td>
			<td bgcolor="#CCFFCC" align=right><%if trim(RRreg("eappl_name")) <> "" then response.write "ˇ"%>　英文：</td>
			<td bgcolor="#FFFFFF"colspan=3><%=RRreg("eappl_name")%></td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" align=right><%if trim(RRreg("jappl_name")) <> "" then response.write "ˇ"%>　日文：</td>
			<td bgcolor="#FFFFFF"colspan=3><%=RRreg("jappl_name")%></td>
			<td bgcolor="#CCFFCC" align=right><%if trim(RRreg("symbol")) <> "" then response.write "ˇ"%>　記號：</td>
			<td bgcolor="#FFFFFF"colspan=3><%=RRreg("symbol")%></td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" align=right><%if trim(RRreg("zappl_name1")) <> "" then response.write "ˇ"%>　其他：</td>
			<td bgcolor="#FFFFFF"colspan=3><%=RRreg("zappl_name1")%></td>
			<td bgcolor="#CCFFCC" align=right><%if trim(RRreg("draw")) <> "" then response.write "ˇ"%>　圖形：</td>
			<td bgcolor="#FFFFFF"colspan=3></td>
		</tr>
<%  RRreg.close
	SQLcom = "select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='"& in_no & "' and mod_field='mod_ap'"			       
	Set RRreg = Conn.execute(sqlcom)
    if not RRreg.eof then 
		mod_ap_ncname1=trim(RRreg("ncname1"))
		mod_ap_ncname2=trim(RRreg("ncname2"))
		mod_ap_ncrep  =trim(RRreg("ncrep"))
		mod_ap_naddr1 =trim(RRreg("naddr1")) 
		mod_ap_naddr2 =trim(RRreg("naddr2"))
	end if	
	RRreg.close
%>		
		<tr>
			<td bgcolor="#CCFFCC" colspan="8" valign="top"><strong>貳、被評定人資料：</td>
		</tr>
		<TR>
			<TD bgcolor="#CCFFCC" align=right>被評定人名稱：</TD>
			<TD bgcolor="#FFFFFF"colspan=7><%=mod_ap_ncname1 & mod_ap_ncname2%> 
		</TD>
		</TR>
		<TR>
			<TD bgcolor="#CCFFCC" align=right>被評定代理人：</TD>
			<TD bgcolor="#FFFFFF"colspan=7><%=mod_ap_ncrep%>
			</TD>
		</TR>
		<TR>
			<TD bgcolor="#CCFFCC" align=right>被評定人地址：</TD>
			<TD bgcolor="#FFFFFF"colspan=7><%=mod_ap_naddr1 & mod_ap_naddr2%>
			</TD>
		</TR>
		<tr>
			<td bgcolor="#CCFFCC" colspan="8" valign="top"><strong>參、主張法條及據以評定商標/標章：</td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" valign="top" align=right>一、主張法條 : </td>
			<td bgcolor="#FFFFFF" colspan="7" valign="top"><%=RSreg("other_item1")%></td>
		</tr>
<%
	SQLcom = "select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='"& in_no & "' and mod_field='mod_aprep'"			       
	Set RRreg = Conn.execute(sqlcom)
	if not RRreg.eof then
	   mod_aprep_ncname1=RRreg("ncname1")
	end if
	RRreg.close
%>	
		<tr>
			<td bgcolor="#CCFFCC" valign="top" align=right>二、據以評定商標 : </td>
			<td bgcolor="#FFFFFF" colspan="3" valign="top">　<%if RSreg("mod_aprep") = "Y" then response.write "ˇ"%>　商標法第36條</td>
			<td bgcolor="#FFFFFF" colspan="4" valign="top"><%=mod_aprep_ncname1%></td>
		</tr>
<%
	SQLcom = "select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='"& in_no & "' and mod_field='mod_apaddr'"			       
	Set RRreg = Conn.execute(sqlcom)
	if not RRreg.eof then
	   mod_apaddr_ncname1=RRreg("ncname1")
	end if
	RRreg.close
%>	
		<tr>
			<td bgcolor="#CCFFCC" valign="top" align=right></td>
			<td bgcolor="#FFFFFF" colspan="3" valign="top">　<%if RSreg("mod_apaddr") = "Y" then response.write "ˇ"%>　商標法第37條第12款</td>
			<td bgcolor="#FFFFFF" colspan="4" valign="top"><%=mod_apaddr_ncname1%></td>
		</tr>
<%
	SQLcom = "select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='"& in_no & "' and mod_field='mod_agt'"			       
	Set RRreg = Conn.execute(sqlcom)
	if not RRreg.eof then
	   mod_agt_ncname1=RRreg("ncname1")
	end if
	RRreg.close
%>	
		<tr>
			<td bgcolor="#CCFFCC" valign="top" align=right></td>
			<td bgcolor="#FFFFFF" colspan="3" valign="top">　<%if RSreg("mod_agt") = "Y" then response.write "ˇ"%>　商標法第37條第13款</td>
			<td bgcolor="#FFFFFF" colspan="4" valign="top"><%=mod_agt_ncname1%></td>
		</tr>
<%
	SQLcom = "select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='"& in_no & "' and mod_field='mod_agtaddr'"			       
	Set RRreg = Conn.execute(sqlcom)
	if not RRreg.eof then
	   mod_agtaddr_ncname1=RRreg("ncname1")
	   mod_agtaddr_ncname2=RRreg("ncname2")
	   mod_agtaddr_nename1=RRreg("nename1")
	end if
	RRreg.close
%>	
		<tr>
			<td bgcolor="#CCFFCC" valign="top" align=right></td>
			<td bgcolor="#FFFFFF" colspan="3" valign="top">　<%if RSreg("mod_agtaddr") = "Y" then response.write "ˇ"%>　商標法第37條第7款</td>
			<td bgcolor="#FFFFFF" colspan="4" valign="top">　<%if mod_agtaddr_ncname1 <> "" then response.write "ˇ"%>　國內註冊 <%=mod_agtaddr_ncname1%></td>
			</td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" valign="top" align=right></td>
			<td bgcolor="#FFFFFF" colspan="3" valign="top"></td>
			<td bgcolor="#FFFFFF" colspan="4" valign="top">　<%if mod_agtaddr_ncname2 <> "" then response.write "ˇ"%>　先使用　 <%=mod_agtaddr_ncname2%></td>
			</td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" valign="top" align=right></td>
			<td bgcolor="#FFFFFF" colspan="3" valign="top"></td>
			<td bgcolor="#FFFFFF" colspan="4" valign="top">　<%if mod_agtaddr_nename1 <> "" then response.write "ˇ"%>　國外註冊  <%=mod_agtaddr_nename1%></td>
			</td>
		</tr>
<%
	SQLcom = "select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='"& in_no & "' and mod_field='mod_pul'"			       
	Set RRreg = Conn.execute(sqlcom)
	if not RRreg.eof then
	   mod_pul_new_no=RRreg("new_no")
	   mod_pul_ncname1=RRreg("ncname1")
	end if
	RRreg.close
%>	
		<tr>
			<td bgcolor="#CCFFCC" colspan="8" valign="top"><strong>肆、評定聲明：</td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" align=right valign=top>　<%if RSreg("mod_pul") = "Y" then response.write "ˇ"%>　</td>
			<td bgcolor="#FFFFFF" colspan=7>第<%=mod_pul_new_no%>號　<%=mod_pul_ncname1%>商標/標章之註冊應予撤銷。</td>
		</tr>
<%
	SQLcom = "select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='"& in_no & "' and mod_field='mod_tcnref'"			       
	Set RRreg = Conn.execute(sqlcom)
	if not RRreg.eof then
	   mod_tcnref_ncname1=RRreg("ncname1")
	   mod_tcnref_ncname2=RRreg("ncname2")
	end if
	RRreg.close
%>	
		<tr>
			<td bgcolor="#CCFFCC" align=right valign=top>　<%if RSreg("mod_tcnref") = "Y" then response.write "ˇ"%>　</td>
			<td bgcolor="#FFFFFF" colspan=7>其聯合、防護第<%=mod_tcnref_ncname1 & mod_tcnref_ncname2%>號商標/標章，應一併撤銷。</td>
		</tr>
<%
	SQLcom = "select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='"& in_no & "' and mod_field='mod_claim1'"			       
	Set RRreg = Conn.execute(sqlcom)
	if not RRreg.eof then
	   mod_claim1_new_no=RRreg("new_no")
	   mod_claim1_ncname1=RRreg("ncname1")
	   mod_claim1_ncname2=RRreg("ncname2")
	end if
	RRreg.close
%>	
		<tr>
			<td bgcolor="#CCFFCC" align=right valign=top>　<%if RSreg("mod_claim1") = "Y" then response.write "ˇ"%>　</td>
			<td bgcolor="#FFFFFF" colspan=7>註冊第<%=mod_claim1_new_no%>號　<%=mod_claim1_ncname1%>商標/標章之專用權範圍及於<%=mod_claim1_ncname2%>商品/服務</td>
		</tr>
<%
	SQLcom = "select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='"& in_no & "' and mod_field='mod_claim2'"			       
	Set RRreg = Conn.execute(sqlcom)
	if not RRreg.eof then
	   mod_claim2_new_no=RRreg("new_no")
	   mod_claim2_ncname1=RRreg("ncname1")
	   mod_claim2_ncname2=RRreg("ncname2")
	end if
	RRreg.close
%>	
		<tr>
			<td bgcolor="#CCFFCC" align=right valign=top>　<%if RSreg("mod_claim2") = "Y" then response.write "ˇ"%>　</td>
			<td bgcolor="#FFFFFF" colspan=7>註冊第<%=mod_claim2_new_no%>號　<%=mod_claim2_ncname1%>商標/標章之專用權範圍不及於<%=mod_claim2_ncname2%>商品/服務</td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" colspan="8" valign="top"><strong>伍、事實及理由：【請首先論述有無具備商標法第八條規定之利害關係】</td>
		</tr>
		<tr>
			<td bgcolor="#FFFFFF" colspan="8" valign="top">
			<%v_tran_remark1=RSreg("tran_remark1")
			  if not isnull(RSreg("tran_remark1")) then 
			     response.write replace(v_tran_remark1,vbcrlf,"<br>")
  			  else
				 response.write "　"
			  end if%></td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" colspan="8" valign="top"><strong>陸、證據(附件)內容：</td>
		</tr>
		<tr>
			<td bgcolor="#FFFFFF" colspan="8" valign="top">
			<%v_tran_remark2 = RSreg("tran_remark2")
			  if not isnull(RSreg("tran_remark2")) then 
			     response.write replace(v_tran_remark2,vbcrlf,"<br>")
  			  else
				 response.write "　"
			  end if%></td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" colspan="8" valign="top"><strong>柒、評定商標及據以評定商標圖樣：</td>
		</tr>
		<TR>
			<TD bgcolor="#CCFFCC" align=right>一、評定商標圖樣：</TD>
			<TD bgcolor="#FFFFFF" colspan=7>
        <%call showdrawfile(Draw_file="")%>
			</TD>
		</TR>	
		<TR>
			<TD bgcolor="#CCFFCC" align=right>二、據以評定商標圖樣：</TD>
			<TD bgcolor="#FFFFFF" colspan=7><%call showfile("mod_dmt",in_scode,in_no)%></TD>
		</TR>				
		<tr>
			<td bgcolor="#CCFFCC" valign="top" width="30%"><strong>捌、代理人(代碼)</td>
			<td bgcolor="#FFFFFF" colspan="7" valign="top"><%=agt_no%> <%call tran_agt(agt_no)%></td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" colspan="8" valign="top"><strong>玖、相關聯案件：</td>
		</tr>
		<TR>
			<TD bgcolor="#CCFFCC" align=right>本案與有關：</TD>
			<TD bgcolor="#FFFFFF" colspan=7><%=RSreg("other_item")%></TD>
		</TR>
	</table>	
</div>
