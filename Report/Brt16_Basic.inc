<%
'if case_stat <> "O" then
   Gsql="select s_mark,pul,apply_no,issue_no,class,tcn_ref,appl_name,cappl_name,eappl_name,agt_no,draw_file from dmt_temp where in_scode='" _
   & in_scode &"' and in_no='"& in_no &"'"
'else
'   Gsql="select s_mark,pul,issue_no,class,tcn_ref,cappl_name,eappl_name from dmt where seq="& seq &" and seq1='"& seq1 &"'"
'end if
'response.write case_stat&","
'response.write Gsql
'response.end 
Set RRreg = Server.CreateObject("ADODB.RecordSet")
    RRreg.Open GSql,Conn,1,1,adcmdtext

if not RRreg.EOF then
     if isnull(RRreg("s_mark")) or trim(RRreg("s_mark")) = "" then
        s_mark=""
     else
        s_mark=trim(RRreg("s_mark"))
     end if 
     if trim(RRreg("pul"))= "" or isnull(RRreg("pul")) then
        pul=""
     else
        pul=trim(RRreg("pul"))
     end if
     apply_no=RRreg("apply_no")
     issue_no=RRreg("issue_no")
     class0=RRreg("class")
     tcn_ref=RRreg("tcn_ref")
     Draw_file=trim(RRreg("draw_file"))
'  if case_stat <> "O" then
     appl_name =trim(RRreg("appl_name"))
     cappl_name=trim(RRreg("cappl_name"))
     eappl_name=trim(RRreg("eappl_name"))
     agt_no=trim(RRreg("agt_no"))
'  else
'     appl_name =trim(RRreg("cappl_name"))
'     cappl_name=trim(RRreg("cappl_name"))
'     eappl_name=trim(RRreg("eappl_name"))
'  end if   
end if
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
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、案件基本資料</td>
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
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">申請號數 : </td>
	    <td width="35%" bgcolor="#FFFFFF"><%=apply_no%></td>
	    <td width="15%" align="right" bgcolor="#CCFFCC">註冊號數 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan=2><%=issue_no%></td>
	 </tr>
	 <tr>
	    <td width="15%" bgcolor="#CCFFCC"><p align="right">商標/標章名稱 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan="4"><%=appl_name%>
	    </td>
	 </tr>
	  <%
		SQL="Select * from casedmt_good where in_no='"& in_no & "' order by cast(class as int)"
		Set RSS=Conn.execute(SQL)
	  %>
      <tr><td colspan=5>
      <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
      <tr>
        <td width="5%" align="center" bgcolor="#CCFFCC">類別 </td>
        <td width="15%" align="center" bgcolor="#CCFFCC" colspan=2>群組代號</td>
        <td width="80%" align="center" bgcolor="#CCFFCC" colspan=2>指定商品名稱</td>
      </tr>
      <%while not RSS.Eof %>
      <tr>
		<td width="5%" bgcolor="#FFFFFF" align="right"><%=trim(RSS("class"))%></td>
		<td width="15%" bgcolor="#FFFFFF" colspan=2 align="left"><%=trim(RSS("dmt_grp_code"))%></td>
		<td width="80%" bgcolor="#FFFFFF" colspan=2 align="left"><%=trim(RSS("dmt_goodname"))%></td>
      </tr>
      <%
			RSS.movenext
		wend
		RSS.close
		set RSS=nothing
      %>
      </table></td></tr>
      <tr>
        <td width="15%" align="right" bgcolor="#CCFFCC">商標圖樣 : </td>
        <td width="80%" bgcolor="#FFFFFF" colspan="4">
        <%call showdrawfile(Draw_file)%>
           </td>
      </tr>