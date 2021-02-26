<div align="center">
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
			<td bgcolor="#CCFFCC" colspan="8" valign="top" width="20%"><strong>壹、申請撤銷商標資料及爭議商標圖樣</td>
		</tr>
		<TR>
			<TD bgcolor="#CCFFCC" align=right width="20%">商標種類：</TD>
			<TD bgcolor="#FFFFFF"colspan=3>
			<%select case trim(RRreg("s_mark"))
			  case "S":response.write "服務"
			  case "L":response.write "證明"
			  case "M":response.write "團體"
			  case else:response.write "商標"
			  end select%>
			</TD>
			<td bgcolor="#CCFFCC" align=right width="20%">註冊/審定號數：</td>
			<td bgcolor="#FFFFFF"colspan=3><%=RRreg("issue_no")%></td>
		</TR>
		<tr>
			<td bgcolor="#CCFFCC" align=right>商標/標章名稱：</td>
			<td bgcolor="#FFFFFF"colspan=7><%=RRreg("Appl_name")%></td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" colspan="8" valign="top" width="20%">　　<strong>爭議商標圖樣之<small>(請勾選並填寫內容):</small></td>
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
			<td bgcolor="#CCFFCC" colspan="8" valign="top"><strong>貳、被申請撤銷人資料：(註冊/審定人)</td>
		</tr>
		<TR>
			<TD bgcolor="#CCFFCC" align=right>被申請人名稱：</TD>
			<TD bgcolor="#FFFFFF"colspan=7><%=mod_ap_ncname1 & mod_ap_ncname2%> 
		</TD>
		</TR>
		<TR>
			<TD bgcolor="#CCFFCC" align=right>被申請代理人：</TD>
			<TD bgcolor="#FFFFFF"colspan=7><%=mod_ap_ncrep%>
			</TD>
		</TR>
		<TR>
			<TD bgcolor="#CCFFCC" align=right>被申請人地址：</TD>
			<TD bgcolor="#FFFFFF"colspan=7><%=mod_ap_naddr1 & mod_ap_naddr2%>
			</TD>
		</TR>
<%
	SQLcom = "select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='"& in_no & "' and mod_field='mod_aprep'"			       
	Set RRreg = Conn.execute(sqlcom)
	if not RRreg.eof then
	   mod_aprep_new_no=RRreg("new_no")
	end if
	RRreg.close
%>
		<tr>
			<td bgcolor="#CCFFCC" colspan="8" valign="top"><strong>參、主張法條及據以撤銷商標/標章：</td>
		</tr>
		<tr>
			<td bgcolor="#FFFFFF"colspan="8" valign="top">一、商標法第<%=RSreg("other_item1")%></td>
		</tr>
		<tr>
			<td bgcolor="#FFFFFF"colspan="8" valign="top">二、據以撤銷商標:　商標法第三十一條第一項第一款/第四十二條第一項註冊<%=mod_aprep_new_no%>號商標/服務標章</td>
		</tr>
<%
	SQLcom = "select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='"& in_no & "' and mod_field='mod_apaddr'"			       
	Set RRreg = Conn.execute(sqlcom)
	if not RRreg.eof then
	   mod_apaddr_new_no=RRreg("new_no")
	end if
	RRreg.close	
%>
		<tr>
			<td bgcolor="#FFFFFF"colspan="8" valign="top">三、據以主張利害  <%select case RSreg("mod_apaddr")
																			   case "A":response.write "申請案號"
																			   case "I":response.write "審定"
																			   case "R":response.write "註冊"
																			  end select%>  第<%=mod_apaddr_new_no%>號商標/服務標章</td>
		</tr>
<%
	SQLcom = "select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='"& in_no & "' and mod_field='mod_agt'"			       
	Set RRreg = Conn.execute(sqlcom)
	if not RRreg.eof then
	   mod_agt_new_no=RRreg("new_no")
	   mod_agt_ncname1=RRreg("ncname1")
	end if
	RRreg.close	
%>
		<tr>
			<td bgcolor="#FFFFFF"colspan="8" valign="top">四、商標侵害他人之著作權...，經判決確定者，該判決號<%=mod_agt_new_no%>及確定判決證明文號<%=mod_agt_ncname1%></td>
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
			<td bgcolor="#CCFFCC" colspan="8" valign="top"><strong>肆、申請撤銷聲明：</td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" align=right valign=top>　<%if RSreg("mod_pul") = "Y" then response.write "ˇ"%>　</td>
			<td bgcolor="#FFFFFF"colspan=7>第<%=mod_pul_new_no%>號<%=mod_pul_ncname1%>商標/標章之專用權/審定，應予撤銷。</td>
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
			<td bgcolor="#FFFFFF"colspan=7>其聯合、防護<%=mod_tcnref_ncname1 & mod_tcnref_ncname2%>商標/標章之專用權/審定，應一併撤銷。</td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" colspan="8" valign="top">　<strong>【依商標法第三十一條第二項規定部分撤銷聲明】</td>
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
			<td bgcolor="#FFFFFF" colspan=7>第<%=mod_claim1_new_no%>號<%=mod_claim1_ncname1%>商標/標章指定使用之<%=mod_claim1_ncname2%>商品，應予撤銷。</td>
		</tr>
<%
	SQLcom = "select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='"& in_no & "' and mod_field='mod_claim2'"			       
	Set RRreg = Conn.execute(sqlcom)
	if not RRreg.eof then
	   mod_claim2_ncname1=RRreg("ncname1")
	   mod_claim2_ncname2=RRreg("ncname2")
	   mod_claim2_nename1=RRreg("nename1")
	end if
	RRreg.close	
%>
		<tr>
			<td bgcolor="#CCFFCC" align=right valign=top>　<%if RSreg("mod_claim2") = "Y" then response.write "ˇ"%>　</td>
			<td bgcolor="#FFFFFF" colspan=7>其聯合、防護<%=mod_claim2_ncname1 & mod_claim2_ncname2%>商標/標章指定使用之<%=mod_claim2_nename1%>商品，應予撤銷。</td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" colspan="8" valign="top"><strong>伍、事實及理由：【請首先論述有無具備商標法第八條規定之利害關係】</td>
		</tr>
		<tr>
			<td bgcolor="#FFFFFF" colspan="8" valign="top">
			<%
			  v_tran_remark1=RSreg("tran_remark1")
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
			<%v_tran_remark2=RSreg("tran_remark2")
			  if not isnull(RSreg("tran_remark2")) then 
			     response.write replace(v_tran_remark2,vbcrlf,"<br>")
  			  else
				 response.write "　"
			  end if%></td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" colspan="8" valign="top"><strong>柒、申請撤銷商標及據以撤銷商標圖樣：</td>
		</tr>
		<TR>
			<TD bgcolor="#CCFFCC" align=right>一、申請撤銷商標圖樣：</TD>
			<TD bgcolor="#FFFFFF"colspan=7>
        <%call showdrawfile(Draw_file="")%>
			</TD>
		</TR>	
		<TR>
			<TD bgcolor="#CCFFCC" align=right>二、變換使用商標圖樣：</TD>
			<TD bgcolor="#FFFFFF"colspan=7>
			<%call showfile("mod_class",in_scode,in_no)%>
			</TD>
		</TR>	
		<TR>
			<TD bgcolor="#CCFFCC" align=right>三、據以撤銷商標圖樣：</TD>
			<TD bgcolor="#FFFFFF"colspan=7>
			<%call showfile("mod_dmt",in_scode,in_no)%>
			</TD>
		</TR>				
		<tr>
			<td bgcolor="#CCFFCC" valign="top" width="20%"><strong>捌、代理人(代碼)</td>
			<td bgcolor="#FFFFFF" colspan="7" valign="top"><%=agt_no%> <%call tran_agt(agt_no)%></td>
		</tr>
		<tr>
			<td bgcolor="#CCFFCC" colspan="8" valign="top"><strong>玖、相關聯案件：</td>
		</tr>
		<TR>
			<TD bgcolor="#CCFFCC" align=right>本案與有關：</TD>
			<TD bgcolor="#FFFFFF"colspan=7><%=RSreg("other_item")%></TD>
		</TR>
	</table>	
</div>