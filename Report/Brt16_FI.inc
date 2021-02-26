<div align="center"><center>
<table border="0" width="100%" bgcolor="#000000" cellspacing="1">
<%
   Gsql="select s_mark,issue_no,appl_name,agt_no,remark1 from dmt_temp where in_scode='" _
   & in_scode &"' and in_no='"& in_no &"'"
Set RRreg = Server.CreateObject("ADODB.RecordSet")
    RRreg.Open GSql,Conn,1,1,adcmdtext

if not RRreg.EOF then
     if isnull(RRreg("s_mark")) or trim(RRreg("s_mark")) = "" then
        s_mark=""
     else
        s_mark=trim(RRreg("s_mark"))
     end if 
     issue_no=RRreg("issue_no")
     appl_name =trim(RRreg("appl_name"))
     agt_no=trim(RRreg("agt_no"))
     remark1=trim(RRreg("remark1"))
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
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">壹、註冊號數、商標（標章）種類及名稱</td>
	 </tr>
	 <tr>	    
	    <td width="15%" align="right" bgcolor="#CCFFCC">註冊號數 : </td>
	    <td width="35%" bgcolor="#FFFFFF" colspan=4><%=issue_no%></td>
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
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">伍、附件</td>
	 </tr>
	 <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z1")<>0 then%>ˇ<%Else%>　<%End IF%>原註冊證。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z2")<>0 then%>ˇ<%Else%>　<%End IF%>申請人之代理人委任書（<% IF instr(1,remark1,"Z2C")<>0 then%>ˇ<%Else%>　<%End IF%>附中譯本）。</td>
      </tr>
      <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF instr(1,remark1,"Z9")<>0 then%>ˇ<%Else%>　<%End IF%>其他。</td>
      </tr>
	  <tr>
	    <td width="15%" align="left" bgcolor="#CCFFCC" colspan="5">陸、簽章及具結</td>
	 </tr>
	  <%
	    
			SQL1="Select  *  from dmt_tran where in_no='"&in_no&"' "
			Set RSS=Conn.execute(SQL1)
			IF not RSS.EOF then		
				IF trim(RSS("other_item"))<>empty then
					other_item_1=trim(RSS("other_item"))
					other_item=split(trim(RSS("other_item")),";")
				End IF
				mod_claim1=trim(RSS("mod_claim1"))
			End IF
			RSS.close
			SET RSS=nothing
	    %>
	 <tr>
        <td width="15%" align="left" bgcolor="#CCFFCC"></td>
        <td width="37%" bgcolor="#FFFFFF" colspan="4"><% IF mod_claim1="Y" then%>ˇ<%Else%>　<%End IF%>一、註冊證遺失聲明：本件註冊商標／標章註冊證確實遺失。</td>
      </tr>
     <tr>
	    <td width="15%" align="left" bgcolor="#CCFFCC" ROWSPAN=3 >附註: </td>
	    <td width="37%" bgcolor="#FFFFFF" colspan="4">本件商標（標章）於<%IF other_item_1<>empty then%><%IF other_item(0)<>empty then%>　<%=other_item(0)%><%Else%>　　　　<%End IF%><%Else%>　　　　<%End IF%>（年/月/日）</td>
	</tr>
	<tr>
	    <td width="37%" bgcolor="#FFFFFF" colspan="5">另案辦理<% IF instr(1,other_item_1,"FT1")<>0 then%>ˇ<%Else%>　<%End IF%>移轉案　　　<% IF instr(1,other_item_1,"FL1")<>0 then%>ˇ<%Else%>　<%End IF%>授權案　　　<% IF instr(1,other_item_1,"FC1")<>0 then%>ˇ<%Else%>　<%End IF%>變更案　　　<% IF instr(1,other_item_1,"FR1")<>0 then%>ˇ<%Else%>　<%End IF%>延展案　　　</td>
	</tr>
</table>
</center></div>	
