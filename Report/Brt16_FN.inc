<div align="center"><center>
<table border="0" width="100%" bgcolor="#000000" cellspacing="1">
<%
   SQLcom = "Exec Pro_case4 '" & in_no & "'"
   set RRreg = conn1.execute(SQLcom)
   IF not RRreg.eof then
	    flag=1
	    agt_no=trim(RRreg("agt_no"))
	    mod_ap=trim(RRreg("mod_ap"))
	    mod_aprep=trim(RRreg("mod_aprep"))
	    mod_agt=trim(RRreg("mod_agt"))
	    mod_apaddr=trim(RRreg("mod_apaddr"))
	    mod_agtaddr=trim(RRreg("mod_agtaddr"))
	    mod_oth=trim(RRreg("mod_oth"))
	    mod_oth1=trim(RRreg("mod_oth1"))
	    mod_oth2=trim(RRreg("mod_oth2"))
	    mod_dmt=trim(RRreg("mod_dmt"))
	    mod_pul=trim(RRreg("mod_pul"))
	    term1=trim(RRreg("term1"))
	    term2=trim(RRreg("term2"))
	    term1=trim(RRreg("term1"))
	    term2=trim(RRreg("term2"))
	    remark1=trim(RRreg("remark1"))
	    s_mark=trim(RRreg("S_mark"))
	    apply_no=trim(RRreg("apply_no"))
	    appl_name=trim(RRreg("appl_name"))
	    issue_no=trim(RRreg("issue_no"))
	    mark=trim(RRreg("dmt_mark"))
	    tran_mark=trim(RRreg("tran_mark"))
	    tran_remark1=trim(RRreg("tran_remark1"))
	    tran_remark2=trim(RRreg("tran_remark2"))
	    mod_claim1=trim(RRreg("mod_claim1"))
	    IF trim(RRreg("other_item"))<>empty then
			other_item_1=trim(RRreg("other_item"))
			other_item=split(trim(RRreg("other_item")),";")
	    End IF
	    IF trim(RRreg("other_item2"))<>empty then
			other_item2_1=trim(RRreg("other_item2"))
			other_item2=split(trim(RRreg("other_item2")),";")
	    End IF
	    pul=trim(RRreg("pul"))
   Else
		flag=3
   End IF
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
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">證明書種類 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%IF tran_mark="C" then%>中文證明書<%End IF%><%IF tran_mark="E" then%>英文證明書<%End IF%></td>
	 </tr>
	 <tr>
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、號數、商標（標章）種類及名稱</td>
	 </tr>
	 <tr>	    
	    <td width="15%" align="right" bgcolor="#CCFFCC">程序種類 : </td>
	    <td width="35%" bgcolor="#FFFFFF">
	    <%Select Case mark
	    Case "A"%>
			申請
	    <%Case "I"%>
			註冊
		<%End Select%>	
	    </td>
	    <td width="15%" align="right" bgcolor="#CCFFCC">
			<%Select Case mark
			Case "A"%>
				申請
			<%Case "I"%>
				註冊
			<%End Select%>	
			號數 : </td>
	    <td width="35%" bgcolor="#FFFFFF">
	    <%Select Case mark
		  Case "A"%>
		　	<%=apply_no%>
	     <%Case "I"%>
			<%=issue_no%>
		<%End Select%>	
	    </td>
	 </tr>
	<tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">商標/標章名稱 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%=appl_name%>
	    </td>
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
	  <tr>
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">肆、商標權期間／申請註冊日期（申請中文證明書者英文部份免填）</td>
	 </tr>
	 <%IF mod_claim1="I" then%>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">商標權期間 :<br>（已註冊者）</td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4">自　<%=term1%>　至　<%=term2%>　</td>
	 </tr>
	 <%ElseIF mod_claim1="A" then%>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">申請註冊日期 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%=term1%>　</td>
	 </tr>
	 <%End IF%>
	  <tr>
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、指定使用商品（服務）（申請中文證明書者英文部份免填）</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">類別 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4">商標法施行細則第<%IF other_item_1<>empty then%><%IF other_item(0)<>empty then%>　<%=other_item(0)%><%Else%>　　　　<%End IF%><%Else%>　<%End IF%>條第<%IF other_item_1<>empty then%><%IF other_item(1)<>empty then%>　<%=other_item(1)%><%Else%>　　　　<%End IF%><%Else%>　<%End IF%>類</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">商品（服務）名稱 :<br>（中文） </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%IF tran_remark1<>empty then%><%=tran_remark1%><%Else%>　<%End IF%></td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">商品（服務）名稱 :<br>（英文） </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%IF tran_remark2<>empty then%><%=tran_remark2%><%Else%>　<%End IF%></td>
	 </tr>
	  <tr>
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">陸、浮貼圖樣（申請已註冊之中文註冊證明者免浮貼）</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">申請份數 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%IF other_item2_1<>empty then%><%IF other_item2(0)<>empty then%>　<%=other_item2(0)%><%Else%>　　　　<%End IF%><%Else%>　<%End IF%>份，商標（標章）圖樣 : <%IF other_item2_1<>empty then%><%IF other_item2(1)<>empty then%>　<%=other_item2(1)%><%Else%>　　　　<%End IF%><%Else%>　<%End IF%>張</td>
	 </tr>
	  <tr>
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">柒、附件 : </td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>中文註冊證影本(已註冊者)/原商標註冊申請書影本(申請中者)，另申中文註冊證明者，請檢附與申請份數相同之影本。</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>貿易局廠商登記資料或其他英文名稱證明文件(申請中文證明書者免檢附)。</td>
	 </tr>
	  <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC"></td>
		<td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z3")<>0 then%>ˇ<%Else%>　<%End IF%>申請人之代理人委任書（<% IF instr(1,remark1,"Z3C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right"></td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他</td>
	 </tr>
	 <tr>
    <td width="15%" align="left" bgcolor="#CCFFCC" ROWSPAN=3 >附註: </td>
    <%
    
		SQL1="Select  other_item1  from dmt_tran where in_no='"&in_no&"' "
		Set RSS=Conn.execute(SQL1)
		IF not RSS.EOF then		
			IF trim(RSS("other_item1"))<>empty then
				other_item1_1=trim(RSS("other_item1"))
				other_item1=split(trim(RSS("other_item1")),";")
			End IF
		End IF
		RSS.close
		SET RSS=nothing
    %>
    <td width="37%" bgcolor="#FFFFFF" colspan="4">本件商標（標章）於<%IF other_item1_1<>empty then%><%IF other_item1(0)<>empty then%>　<%=other_item1(0)%><%Else%>　　　　<%End IF%><%Else%>　　　　<%End IF%>（年/月/日）</td>
</tr>
<tr>
    <td width="37%" bgcolor="#FFFFFF" colspan="5">另案辦理<% IF instr(1,other_item1_1,"FT1")<>0 then%>ˇ<%Else%>　<%End IF%>移轉案　　　<% IF instr(1,other_item1_1,"FL1")<>0 then%>ˇ<%Else%>　<%End IF%>授權案　　　<% IF instr(1,other_item1_1,"FC1")<>0 then%>ˇ<%Else%>　<%End IF%>變更案　　　<% IF instr(1,other_item1_1,"FR1")<>0 then%>ˇ<%Else%>　<%End IF%>延展案　　　</td>
</tr>
<tr>
    <td width="37%" bgcolor="#FFFFFF" colspan="5">　　　　<% IF instr(1,other_item1_1,"ZZ")<>0 then%>ˇ<%Else%>　<%End IF%>其他<%IF other_item1_1<>empty then%><%IF other_item1(2)<>empty then%>:　<%=other_item1(2)%>　案<%Else%>　　　　<%End IF%><%End IF%></td>
</tr>
</table>
</center></div>	 
     
     