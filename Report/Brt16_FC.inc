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
	    remark1=trim(RRreg("remark1"))
	    s_mark=trim(RRreg("S_mark"))
	    apply_no=trim(RRreg("apply_no"))
	    appl_name=trim(RRreg("appl_name"))
	    issue_no=trim(RRreg("issue_no"))
	    mark=trim(RRreg("mark"))
	    IF trim(RRreg("other_item"))<>empty then
			other_item_1=trim(RRreg("other_item"))
			other_item=split(trim(RRreg("other_item")),";")
	    End IF
	    pul=trim(RRreg("pul"))
   Else
		flag=3
   End IF
 
 if flag=3 then
    Response.Write "<script language="javascript" type="text/javascript">" &chr(13)
    Response.Write " alert('請到案件主檔維護新增案件內容!');" &chr(13)
    Response.Write " window.parent.location='/Customers/Brt15.asp';" &chr(13)
    Response.Write "</script>" &chr(13)
 end if   
 %>
 <tr>
    <td width="10%" bgcolor="#CCFFCC"><p align="right">出名代理人 : </td>
    <td width="90%" bgcolor="#FFFFFF" colspan=4><%=agt_no%> <%call tran_agt(agt_no)%></td>
 </tr>
 <%Select Case trim(request("add_arcase"))
 case "FC1","FC10","FC11","FC9","FC5","FC7"%>
 <tr>
    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、註冊申請案號、商標／標章名稱</td>
 </tr>
     <%IF trim(Request("add_arcase"))="FC1" or trim(Request("add_arcase"))="FC10" or trim(Request("add_arcase"))="FC9"  then 
		SQL1="Select * from dmt_tranlist where in_no='"& in_no & "' and  mod_field='mod_tcnref' "
		Set RSS=Conn.execute(SQL1)
	  %>
      <tr><td colspan=5>
      <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
      <tr>
        <td width="10%" align="center" bgcolor="#CCFFCC">案件編號</td>
        <td width="20%" align="center" bgcolor="#CCFFCC">商標種類</td>
        <td width="10%" align="center" bgcolor="#CCFFCC">申請案號</td>
        <td width="70%" align="center" bgcolor="#CCFFCC" colspan=2>商標／標章名稱</td>
      </tr>
      <%while not RSS.Eof %>
      <tr>
		<td width="10%" bgcolor="#FFFFFF" align="center"><%=session("se_branch")&"T"%><%=seq%><%IF trim(seq1)<>"_" then%>_<%=seq1%><%End IF%></td>
		<td width="20%" bgcolor="#FFFFFF" align="center">
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
		<td width="20%" bgcolor="#FFFFFF" align="center"><%=trim(RSS("new_no"))%></td>
		<td width="70%" bgcolor="#FFFFFF" colspan=2 align="left"><%=trim(RSS("ncname1"))%></td>
      </tr>
      <%
			RSS.movenext
		wend
		RSS.close
		set RSS=nothing
      %>
      </table></td></tr>
      <%elseif Request("add_arcase")="FC11" or trim(Request("add_arcase"))="FC5" or trim(Request("add_arcase"))="FC7" then
		SQL1 = "select * from  case_dmt1 where in_no= '" & in_no & "' "
		Set RS=Conn.execute(SQL1)
		%>
	  <tr><td colspan=5>
      <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
      <tr>
        <td width="10%" align="center" bgcolor="#CCFFCC">案件編號</td>
        <td width="20%" align="center" bgcolor="#CCFFCC">商標種類</td>
        <td width="10%" align="center" bgcolor="#CCFFCC">申請案號</td>
        <td width="70%" align="center" bgcolor="#CCFFCC" colspan=2>商標／標章名稱</td>
      </tr>
       <tr>
		<td width="10%" bgcolor="#FFFFFF" align="center"><%=session("se_branch")&"T"%><%=Seq%><%IF trim(seq1)<>"_" then%>_<%=seq1%><%End IF%></td>
		<td width="20%" bgcolor="#FFFFFF" align="center">
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
		<td width="20%" bgcolor="#FFFFFF" align="center"><%=apply_no%></td>
		<td width="70%" bgcolor="#FFFFFF" colspan=2 align="left"><%=appl_name%></td>
      </tr>
      <%
      IF not RS.EOF then
      while not RS.Eof 
		IF TRIM(RS("case_stat1"))="NN" then
			SQL="Select * from dmt_temp where in_no='"&in_no&"' and case_sqlno='"&trim(RS("case_sqlno"))&"'"
		else
			SQL="Select * from dmt where seq='"&trim(RS("seq"))&"' and seq1='"&trim(RS("seq1"))&"'"
		End IF
		'response.write SQL&"<br><br>"
		Set RSS=Conn.execute(SQL)
		IF not RSS.eof then
			C_seq=trim(RSS("seq"))
			C_seq1=trim(RSS("seq1"))
			C_smark=trim(RSS("s_mark"))
			C_apply_no=trim(RSS("apply_no"))
			C_appl_name=trim(RSS("appl_name"))
		End IF
		RSS.close
		set RSS=nothing
      %>
      <tr>
		<td width="10%" bgcolor="#FFFFFF" align="center"><%=session("se_branch")&"T"%><%=C_Seq%><%IF trim(C_seq1)<>"_" then%>_<%=C_seq1%><%End IF%></td>
		<td width="20%" bgcolor="#FFFFFF" align="center">
		<%select case C_smark
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
		<td width="10%" bgcolor="#FFFFFF" align="center"><%=C_apply_no%></td>
		<td width="70%" bgcolor="#FFFFFF" colspan=2 align="left"><%=C_appl_name%></td>
      </tr>
      <%
			RS.movenext
		wend
		RS.close
		set RS=nothing
      %>
      </table></td></tr>
      <%End IF%>
	  <%End IF%>
    <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">貳、變更事項</td>
	</tr>
	<tr>
		<td width="10%" align="left" bgcolor="#CCFFCC"></td>
		<td width="15%" align="left" bgcolor="#FFFFFF" colspan="4"><%IF mod_ap="Y" then%>ˇ<%Else%>　<%End IF%>申請人名稱　　<%IF mod_aprep="Y" then%>ˇ<%Else%>　<%End IF%>代表人或負責人　　　　<%IF mod_agt="Y" then%>ˇ<%Else%>　<%End IF%>代理人</td>
	</tr>
	<tr>
		<td width="10%" align="left" bgcolor="#CCFFCC"></td>
		<td width="15%" align="left" bgcolor="#FFFFFF" colspan="4"><%IF mod_apaddr="Y" then%>ˇ<%Else%>　<%End IF%>申請人地址　　<%IF mod_agtaddr="Y" then%>ˇ<%Else%>　<%End IF%>代表人地址　　　　　　　　　</td>
	</tr>
	<tr>
		<td width="10%" align="left" bgcolor="#CCFFCC"></td>
		<td width="15%" align="left" bgcolor="#FFFFFF" colspan="4"><%IF mod_oth="Y" then%>ˇ<%Else%>　<%End IF%>申請人印鑑　　<%IF mod_oth1="Y" then%>ˇ<%Else%>　<%End IF%>代表人或負責人印鑑　　<%IF mod_oth2="Y" then%>ˇ<%Else%>　<%End IF%>代理人印鑑</td>
	</tr>
	<%
		SQL="select * from dmt_tranlist where in_no= '"& in_no & "' and mod_field='mod_ap'"
		'response.write SQL
		Set RSS=Conn.Execute(SQL)
		IF not RSS.EOF then
			old_no=trim(RSS("old_no"))
			ocname1=trim(RSS("ocname1"))
			ocname2=trim(RSS("ocname2"))
			oename1=trim(RSS("oename1"))
			oename2=trim(RSS("oename2"))
		End IF
	%>
	<tr>
		<td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、原申請人</td>
	</tr>
	<tr>
		<td width="20%" align="right" bgcolor="#CCFFCC">申請人統一編號 : </td>
		<td width="15%" align="left" bgcolor="#FFFFFF" colspan="4"><%=old_no%></td>
	</tr>
	<tr>
		<td width="20%" align="right" bgcolor="#CCFFCC">申請人名稱(中) : </td>
		<td width="15%" align="left" bgcolor="#FFFFFF" colspan="4"><%=ocname1%><%=ocname2%></td>
	</tr>
	<tr>
		<td width="20%" align="right" bgcolor="#CCFFCC">申請人名稱(英) : </td>
		<td width="15%" align="left" bgcolor="#FFFFFF" colspan="4"><%=oename1%><%=oename2%></td>
	</tr>
	<tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>變更證明文件</td>
    </tr>
    <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>委任書（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
    </tr>
<%case "FC2","FC20","FC21","FC6","FC8","FC0"%>    
<tr>
    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、註冊案號、商標（標章）種類及名稱</td>
 </tr>
     <%IF trim(Request("add_arcase"))="FC2" or trim(Request("add_arcase"))="FC20" or trim(Request("add_arcase"))="FC0" then 
		SQL1="select mod_type,mod_count,new_no,ncname1 from  dmt_tranlist where in_no= '" & in_no & "' and mod_field='mod_tcnref'"
		Set RSS=Conn.execute(SQL1)
	  %>
      <tr><td colspan=5>
      <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
      <tr>
        <td width="10%" align="center" bgcolor="#CCFFCC">案件編號</td>
        <td width="20%" align="center" bgcolor="#CCFFCC">商標種類</td>
        <td width="10%" align="center" bgcolor="#CCFFCC">註冊案號</td>
        <td width="70%" align="center" bgcolor="#CCFFCC" colspan=2>商標／標章名稱</td>
      </tr>
      <%while not RSS.Eof %>
      <tr>
		<td width="10%" bgcolor="#FFFFFF" align="center"><%=session("se_branch")&"T"%><%=seq%><%IF trim(seq1)<>"_" then%>_<%=seq1%><%End IF%></td>
		<td width="20%" bgcolor="#FFFFFF" align="center">
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
		<td width="10%" bgcolor="#FFFFFF" align="center"><%=trim(RSS("new_no"))%></td>
		<td width="70%" bgcolor="#FFFFFF" colspan=2 align="left"><%=trim(RSS("ncname1"))%></td>
      </tr>
      <%
			RSS.movenext
		wend
		RSS.close
		set RSS=nothing
      %>
      </table></td></tr>
      <%elseif Request("add_arcase")="FC21" or trim(Request("add_arcase"))="FC6" or trim(Request("add_arcase"))="FC8" then
		SQL1 = "select * from  case_dmt1 where in_no= '" & in_no & "' "
		Set RS=Conn.execute(SQL1)
		%>
	  <tr><td colspan=5>
      <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
      <tr>
        <td width="10%" align="center" bgcolor="#CCFFCC">案件編號</td>
        <td width="20%" align="center" bgcolor="#CCFFCC">商標種類</td>
        <td width="10%" align="center" bgcolor="#CCFFCC">註冊案號</td>
        <td width="70%" align="center" bgcolor="#CCFFCC" colspan=2>商標／標章名稱</td>
      </tr>
       <tr>
		<td width="10%" bgcolor="#FFFFFF" align="center"><%=session("se_branch")&"T"%><%=Seq%><%IF trim(seq1)<>"_" then%>_<%=seq1%><%End IF%></td>
		<td width="20%" bgcolor="#FFFFFF" align="center">
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
		<td width="10%" bgcolor="#FFFFFF" align="center"><%=issue_no%></td>
		<td width="70%" bgcolor="#FFFFFF" colspan=2 align="left"><%=appl_name%></td>
      </tr>
      <%
      IF not RS.EOF then
      while not RS.Eof 
		IF TRIM(RS("case_stat1"))="NN" then
			SQL="Select * from dmt_temp where in_no='"&in_no&"' and case_sqlno='"&trim(RS("case_sqlno"))&"'"
		else
			SQL="Select * from dmt where seq='"&trim(RS("seq"))&"' and seq1='"&trim(RS("seq1"))&"'"
		End IF
		'response.write SQL&"<br><br>"
		Set RSS=Conn.execute(SQL)
		IF not RSS.eof then
			C_seq=trim(RSS("seq"))
			C_seq1=trim(RSS("seq1"))
			C_smark=trim(RSS("s_mark"))
			C_issue_no=trim(RSS("issue_no"))
			C_appl_name=trim(RSS("appl_name"))
		End IF
		RSS.close
		set RSS=nothing
      %>
      <tr>
		<td width="10%" bgcolor="#FFFFFF" align="center"><%=session("se_branch")&"T"%><%=C_Seq%><%IF trim(C_seq1)<>"_" then%>_<%=C_seq1%><%End IF%></td>
		<td width="20%" bgcolor="#FFFFFF" align="center">
		<%select case C_smark
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
		<td width="10%" bgcolor="#FFFFFF" align="center"><%=C_issue_no%></td>
		<td width="70%" bgcolor="#FFFFFF" colspan=2 align="left"><%=C_appl_name%></td>
      </tr>
      <%
			RS.movenext
		wend
		RS.close
		set RS=nothing
      %>
      </table></td></tr>
      <%End IF%>
	  <%End IF%>
    <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">貳、申請人（變更後註冊事項）</td>
	</tr>
	<tr>
		<td width="15%" align="right" bgcolor="#CCFFCC">變更種類 : </td>
		<td width="15%" bgcolor="#FFFFFF" colspan="4"><%IF mark="I" then%>ˇ<%Else%>　<%End IF%>商標（標章）權人　　　　　　<%IF mark="A" then%>ˇ<%Else%>　<%End IF%>被授權人</td>
	</tr>
	<tr>
		<td width="15%" align="right" bgcolor="#CCFFCC"></td>
		<td width="15%" bgcolor="#FFFFFF" colspan="4"><%IF mark="B" then%>ˇ<%Else%>　<%End IF%>再被授權人　　　　　　　　　<%IF mark="C" then%>ˇ<%Else%>　<%End IF%>質權人</td>
	</tr>
	<tr>
		<td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">肆、變更事項</td>
	</tr>
	<tr>
		<td width="15%" align="right" bgcolor="#CCFFCC"></td>
		<td width="15%" bgcolor="#FFFFFF" colspan="4"><%IF mid(mod_ap,2,1)="Y" then%>ˇ<%Else%>　<%End IF%>申請人中文名稱　　　　　　　<%IF right(mod_ap,1)="Y" then%>ˇ<%Else%>　<%End IF%>申請人英文名稱　　　　　　　<%IF mod_oth="Y" then%>ˇ<%Else%>　<%End IF%>申請人印章</td>
	</tr>
	<tr>
		<td width="15%" align="right" bgcolor="#CCFFCC"></td>
		<td width="15%" bgcolor="#FFFFFF" colspan="4"><%IF left(mod_apaddr,1)="Y" then%>ˇ<%Else%>　<%End IF%>申請人中文地址　　　　　　　<%IF right(mod_apaddr,1)="Y" then%>ˇ<%Else%>　<%End IF%>申請人英文地址　　　　　　　<%IF mod_oth1="Y" then%>ˇ<%Else%>　<%End IF%>代表人印章</td>
	</tr>
	<tr>
		<td width="15%" align="right" bgcolor="#CCFFCC"></td>
		<td width="15%" bgcolor="#FFFFFF" colspan="4"><%IF left(mod_aprep,1)="Y" then%>ˇ<%Else%>　<%End IF%>代表人中文名稱　　　　　　　<%IF right(mod_aprep,1)="Y" then%>ˇ<%Else%>　<%End IF%>代表人英文名稱　　　　　　　<%IF mod_agt="Y" then%>ˇ<%Else%>　<%End IF%>代理人中文名稱</td>
	</tr>
	<tr>
		<td width="15%" align="right" bgcolor="#CCFFCC"></td>
		<td width="15%" bgcolor="#FFFFFF" colspan="4"><%IF mod_dmt="Y" then%>ˇ<%Else%>　<%End IF%>變更商標／標章名稱 :
		<%
			SQL="Select * from dmt_tranlist where in_no='"&in_no&"' and mod_field='mod_dmt'"
			set RSS=Conn.execute(SQL)
			IF not RSS.EOF then
				response.write trim(RSS("ncname1"))
			End IF
			RSS.close
			set RSS=nothing
		%>
		 </td>
	</tr>
	<tr>
        <td width="15%" align="left" bgcolor="#CCFFCC">附件: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>變更證明文件（<% IF instr(1,remark1,"Z1C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）</td>
    </tr>
    <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>申請人之代理人委任書（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
    </tr>
    <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他</td>
    </tr>
    <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC" ROWSPAN=2 >附註: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4">本件商標（標章）於<%IF other_item_1<>empty then%><%IF other_item(0)<>empty then%>　<%=other_item(0)%><%Else%>　　　　<%End IF%><%Else%>　　　　<%End IF%>（年/月/日）</td>
    </tr>
    <tr>
        <td width="37%" bgcolor="#FFFFFF" colspan="4">另案辦理<% IF instr(1,other_item_1,"FT1")<>0 then%>ˇ<%Else%>　<%End IF%>移轉案　　　<% IF instr(1,other_item_1,"FL1")<>0 then%>ˇ<%Else%>　<%End IF%>授權案　　　<% IF instr(1,other_item_1,"FI1")<>0 then%>ˇ<%Else%>　<%End IF%>補證案　　　<% IF instr(1,other_item_1,"FR1")<>0 then%>ˇ<%Else%>　<%End IF%>延展案　　　<% IF instr(1,other_item_1,"ZZ")<>0 then%>ˇ<%Else%>　<%End IF%>其他<%IF other_item_1<>empty then%><%IF other_item(2)<>empty then%>:　<%=other_item(2)%>　案<%Else%>　　　　<%End IF%><%End IF%></td>
    </tr>
    <%case "FC3"%>
    <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、註冊案號、商標（標章）種類及名稱</td>
	</tr>
      <tr><td colspan=5>
      <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
      <tr>
        <td width="20%" align="center" bgcolor="#CCFFCC">商標種類</td>
        <td width="10%" align="center" bgcolor="#CCFFCC">註冊案號</td>
        <td width="70%" align="center" bgcolor="#CCFFCC" colspan=3>商標／標章名稱</td>
      </tr>
       <tr>
		<td width="20%" bgcolor="#FFFFFF" align="center">
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
		<td width="10%" bgcolor="#FFFFFF" align="center"><%=issue_no%></td>
		<td width="70%" bgcolor="#FFFFFF" colspan=3 align="left"><%=appl_name%></td>
      </tr>
      </table></td></tr>
      <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">肆、擬減縮商品或服務名稱</td>
	  </tr>
	  <tr><td colspan=5>
      <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
      <tr>
        <td width="10%" align="center" bgcolor="#CCFFCC">類別</td>
        <td width="90%" align="center" bgcolor="#CCFFCC" colspan="4">商品／服務名稱</td>
      </tr>
	  <%
		SQL = "select * from  dmt_tranlist where in_no= '" & in_no & "' and mod_type='Dgood' and mod_field='mod_class'"
		set RS = conn.execute(SQL)
		while not RS.eof
	  %>
	  <tr>
        <td width="10%" align="center" bgcolor="#FFFFFF"><%=trim(RS("new_no"))%></td>
        <td width="90%" bgcolor="#FFFFFF" colspan="4"><%=trim(RS("list_remark"))%></td>
      </tr>
	  <%
		RS.movenext
		wend
		RS.close
		set RS=nothing
      %>
      </table></td></tr>
	  <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、減縮後指定商品（服務）名稱</td>
	  </tr>
	  <tr><td colspan=5>
	  <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
      <tr>
        <td width="10%" align="center" bgcolor="#CCFFCC">類別</td>
        <td width="90%" align="center" bgcolor="#CCFFCC" colspan="4">商品／服務名稱</td>
      </tr>
	  <%
		SQL = "select * from  casedmt_good  where in_no= '" & in_no & "' "
		set RS = conn.execute(SQL)
		while not RS.eof
	  %>
	  <tr>
        <td width="10%" align="center" bgcolor="#FFFFFF"><%=trim(RS("class"))%></td>
        <td width="90%" bgcolor="#FFFFFF" colspan="4"><%=trim(RS("dmt_goodname"))%></td>
      </tr>
	  <%
		RS.movenext
		wend
		RS.close
		set RS=nothing
      %>
      </table></td></tr>
	  <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">陸、附件</td>
	  </tr>
	   <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>申請人之代理人委任書（<% IF instr(1,remark1,"Z1C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
    </tr>
    <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他</td>
    </tr>
     <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC" ROWSPAN=2 >附註: </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4">本件商標（標章）於<%IF other_item_1<>empty then%><%IF other_item(0)<>empty then%>　<%=other_item(0)%><%Else%>　　　　<%End IF%><%Else%>　　　　<%End IF%>（年/月/日）</td>
    </tr>
    <tr>
        <td width="37%" bgcolor="#FFFFFF" colspan="4">另案辦理<% IF instr(1,other_item_1,"DO1")<>0 then%>ˇ<%Else%>　<%End IF%>異議案　　　<% IF instr(1,other_item_1,"DI1")<>0 then%>ˇ<%Else%>　<%End IF%>評定案　　　<% IF instr(1,other_item_1,"FI1")<>0 then%>ˇ<%Else%>　<%End IF%>補證案　　　<% IF instr(1,other_item_1,"FR1")<>0 then%>ˇ<%Else%>　<%End IF%>延展案　　　<% IF instr(1,other_item_1,"ZZ")<>0 then%>ˇ<%Else%>　<%End IF%>其他<%IF other_item_1<>empty then%><%IF other_item(2)<>empty then%>:　<%=other_item(2)%>　案<%Else%>　　　　<%End IF%><%End IF%></td>
    </tr>
    <%Case "FC4"%>
     <tr>
		<td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、註冊案號、商標（標章）種類及名稱</td>
	</tr>
	<tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">註冊案號 : </td>
        <td width="37%" bgcolor="#FFFFFF"><%=issue_no%></td>
        <td width="15%" align="right" bgcolor="#CCFFCC">商標種類 : </td>
        <td width="37%" bgcolor="#FFFFFF"  colspan="2">
        <%IF pul="2" and (s_mark=empty or isnull(s_mark) or s_mark="") then%>
	    		防護商標
	    <%elseif pul="2" and s_mark="S" then%>
				92年修正前防護服務標章
	    <%End IF%>
        </td>
    </tr>
    <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">商標/標章名稱 : </td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><%=appl_name%></td>
    </tr>
    <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>委任書（<% IF instr(1,remark1,"Z1C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
    </tr>
	<%End Select%>
</table>
</center></div>