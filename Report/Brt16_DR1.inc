﻿<div align="center">
<%
    Set RRreg = Server.CreateObject("ADODB.RecordSet")
	SQLcom = "Exec Pro_case4 '" & request("in_no") & "'"	
	set RRreg = conn1.execute(SQLcom)
   IF not RRreg.eof then
	    flag=1
	    agt_no=trim(RRreg("agt_no"))
	    s_mark=trim(RRreg("S_mark"))
	    apply_no=trim(RRreg("apply_no"))
	    appl_name=trim(RRreg("appl_name"))
	    cappl_name=trim(RRreg("cappl_name"))
	    eappl_name=trim(RRreg("eappl_name"))
	    zappl_name1=trim(RRreg("zappl_name1"))
	    jappl_name=trim(RRreg("jappl_name"))
	    draw=trim(RRreg("draw"))
	    draw_file=trim(RRreg("draw_file"))
	    issue_no=trim(RRreg("issue_no"))
	    mark=trim(RRreg("dmt_mark"))
	    tran_remark1=trim(RRreg("tran_remark1"))
	    tran_remark2=trim(RRreg("tran_remark2"))
	    remark3=trim(RRreg("remark3"))
	    other_item1=trim(RRreg("other_item1"))
	    IF trim(RRreg("other_item"))<>empty then
			remark1=trim(RRreg("other_item"))
	    End IF
	    IF trim(RRreg("other_item"))<>empty then
				other_item_1=trim(RRreg("other_item"))
				other_item=split(trim(RRreg("other_item")),";")
			End IF
	    'response.write remark1
   Else
		flag=3
   End IF
   SQL="select ncname1, ncname2, ncrep, nzip, naddr1, naddr2 from dmt_tranlist where in_no='"&in_no&"' and mod_field='mod_ap'"
   Set RSS=Conn.execute(SQL)
   IF not RSS.EOF then
		ncname1=trim(RSS("ncname1"))
		ncname2=trim(RSS("ncname2"))
		ncrep=trim(RSS("ncrep"))
		nzip=trim(RSS("nzip"))
		naddr1=trim(RSS("naddr1"))
		naddr2=trim(RSS("naddr2"))
   End IF
   RSS.close
   Set RSS=nothing
   SQL1="select * from dmt_tranlist where in_no='"&in_no&"' and mod_field='mod_pul'"
   Set RSS=Conn.execute(SQL1)
   while not RSS.EOF
		Select Case trim(RSS("mod_type"))
		Case "Tmark","Lmark"
			mod_type=trim(RSS("mod_type"))
			mod_pul_ncname1=trim(RSS("ncname1"))
			new_no=trim(RSS("new_no"))
		Case "R1"
			R1_mod_type=trim(RSS("mod_type"))
		Case "R2"
			R2_mod_type=trim(RSS("mod_type"))
			R2_mod_dclass=trim(RSS("mod_dclass"))
			R2_new_no=trim(RSS("new_no"))
		Case "R3"
			R3_mod_type=trim(RSS("mod_type"))
			R3_mod_dclass=trim(RSS("mod_dclass"))
			R3_new_no=trim(RSS("new_no"))
			R3_ncname1=trim(RSS("ncname1"))
		End Select	
		RSS.MoveNext
   wend
   RSS.close
   Set RSS=nothing
   RRreg.close
   SQL="select ncname1 from dmt_tranlist where in_no='"&in_no&"' and mod_field='mod_claim1'"
   Set RSS=Conn.execute(SQL)
   IF not RSS.EOF then
		mod_claim1_ncname1=trim(RSS("ncname1"))
		
   End IF
   RSS.close
   Set RSS=nothing
%>	
	<table border="0" class="bluetable" cellspacing="1" cellpadding="2" bgcolor="#000000" width="100%">		
		<tr>
			<td bgcolor="#CCFFCC" colspan="5" valign="top" width="20%">壹、異議商標資料及爭議商標圖樣</td>
		</tr>
		<tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">商標種類 : </td>
	    <td width="35%" bgcolor="#FFFFFF">
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
	    <td width="15%" align="right" bgcolor="#CCFFCC">註冊/審定號數 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan=2><%=issue_no%></td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">商標/標章名稱 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%=appl_name%>
	    </td>
	 </tr>
	 <tr>
		<td bgcolor="#CCFFCC" colspan="5" valign="top" width="20%">貳、被申請廢止人資料（註冊人）</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">被申請人名稱 :</td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%=ncname1%><%=ncname2%>
	    </td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">被申請代理人 :</td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%=ncrep%>
	    </td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">被申請人地址 :</td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%IF nzip<>empty then%>(<%=nzip%>)<%End IF%><%=naddr1%><%=naddr2%>
	    </td>
	 </tr>
	 <tr>
		<td bgcolor="#CCFFCC" colspan="5" valign="top" width="20%">參、申請廢止聲明</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4">第　<%=new_no%>　號「　<%=mod_pul_ncname1%>　」<%IF mod_type="Tmark" then%>商標<%ElseIF mod_type="Lmark" then%>標章<%End IF%>
	 </td>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%IF R1_mod_type="R1" then%>ˇ<%Else%>　<%End IF%>之商標權，應予廢止。</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%IF R2_mod_type="R2" then%>ˇ<%Else%>　<%End IF%>指定使用於商標法施行細則第　<%=R2_new_no%>　條第　<%=R2_mod_dclass%>　類商品/服務之商標權應予廢止。</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%IF R3_mod_type="R3" then%>ˇ<%Else%>　<%End IF%>指定使用於商標法施行細則第　<%=R3_new_no%>　條第　<%=R3_mod_dclass%>　類　<%=R3_ncname1%>　商品/服務之商標權應予廢止。</td>
	 </tr>
	 <tr>
		<td bgcolor="#CCFFCC" colspan="5" valign="top" width="20%">肆、主張法條及據以廢止商標／標章</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC">一、主張條款 :</td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%IF other_item1<>empty then%>商標法<%=other_item1%><%End IF%></td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC">二、據以異議商標/標章</td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%=mod_claim1_ncname1%></td>
	 </tr>
     <tr>
		<td bgcolor="#CCFFCC" colspan="5" valign="top" width="20%">伍、事實及理由 : 【請首先論述有無具備商標法第八條規定之利害關係】</td>
	 </tr>
	 <tr>
		<td bgcolor="#ffFFff" colspan="5" valign="top" width="20%"><%IF tran_remark1<>empty then%><%=tran_remark1%><%Else%>　<%End IF%></td>
	 </tr>
	 <tr>
		<td bgcolor="#CCFFCC" colspan="5" valign="top" width="20%">陸、證據（附件）內容 : </td>
	 </tr>
	 <tr>
		<td bgcolor="#ffFFff" colspan="5" valign="top" width="20%"><%IF tran_remark2<>empty then%><%=tran_remark2%><%Else%>　<%End IF%></td>
	 </tr>
	 <tr>
		<td bgcolor="#CCFFCC"  valign="top" width="20%">柒、代理人(代碼) : </td>
		<td bgcolor="#ffFFff" colspan="4" ><%=agt_no%> <%call tran_agt(agt_no)%></td>
	 </tr>
	 <tr>
		<td bgcolor="#CCFFCC" colspan="5" valign="top" width="20%">捌、相關聯案件 : </td>
	 </tr>
	 <tr>
		<td bgcolor="#CCFFCC"  valign="top" width="20%"></td>
		<td bgcolor="#ffFFff" colspan="4" >本案與<%IF other_item_1<>empty then%><%IF other_item(0)<>empty then%>　<%=other_item(0)%><%Else%>　　　　<%End IF%><%Else%>　　　　<%End IF%>（年/月/日）註冊第　<%IF other_item_1<>empty then%><%IF other_item(1)<>empty then%>　<%=other_item(1)%><%Else%>　　　　<%End IF%><%Else%>　　　　<%End IF%>　號　<%IF other_item_1<>empty then%><%IF other_item(2)<>empty then%>　<%=other_item(2)%><%Else%>　　　　<%End IF%><%Else%>　　　　<%End IF%>　案有關</td>
	 </tr>
	 <tr>
		<td bgcolor="#CCFFCC" colspan="5" valign="top" width="20%">玖、申請廢止商標及據以廢止商標圖樣 : </td>
	 </tr>
	 <TR>
			<TD bgcolor="#CCFFCC" align=left　width=20%>一、申請廢止商標圖樣：</TD>
			<TD bgcolor="#FFFFFF" colspan=7>
        <%call showdrawfile(Draw_file="")%>
			</TD>
		</TR>
		<TR>
			<TD bgcolor="#CCFFCC" align=left>二、變換使用商標圖樣：</TD>
			<TD bgcolor="#FFFFFF" colspan=7><%call showfile("mod_class",in_scode,in_no)%></TD>
		</TR>	
		<TR>
			<TD bgcolor="#CCFFCC" align=left>三、據以廢止商標圖樣：</TD>
			<TD bgcolor="#FFFFFF" colspan=7><%call showfile("mod_dmt",in_scode,in_no)%></TD>
		</TR>		
	</table>	
</div>