﻿    <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
<!--#include file="Brt16_Basic.inc"-->
<%
function coun(a)
   sql0="select coun_c from country where coun_code='" & trim(a) & "'"
   set rs=cnn.execute(sql0)
   if not rs.eof then
      coun=rs(0)
   else
	  coun=a
   end if
   rs.close
   set rs=nothing
end function

Gsql="select * from dmt_tran " _
   & "where in_scode='" & in_scode & "' and in_no='"& in_no &"'"

'   response.write Gsql
'   response.end
   Set RRreg = Server.CreateObject("ADODB.RecordSet")
       RRreg.Open GSql,Conn,1,1,adcmdtext

   if not RRreg.eof then
      mod_ap =RRreg("mod_ap")
      mod_aprep =RRreg("mod_aprep")
      mod_apaddr =RRreg("mod_apaddr")
      mod_agt =RRreg("mod_agt")
      mod_agtaddr =RRreg("mod_agtaddr")
      mod_dmt =RRreg("mod_dmt")
      mod_class =RRreg("mod_class")
      mod_pul =RRreg("mod_pul")
      mod_tcnref =RRreg("mod_tcnref")
      tran_remark1=RRreg("tran_remark1")
      tran_remark2=RRreg("tran_remark2")
      
   end if
   RRreg.close
   set RRreg=nothing


   Set RRreg = Server.CreateObject("ADODB.RecordSet")
if mod_ap="Y" then
   sql=" select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='" & in_no & "' and mod_field='mod_ap'"
else
   sql=" select (select apcust_no from apcust where apsqlno=dmt_temp.apsqlno) as apcust_no,ap_cname,ap_ename from dmt_temp where in_scode='" & in_scode & "' and in_no='" & in_no & "'"
end if
'response.write sql
   RRreg.Open Sql,Conn,1,1,adcmdtext
if not RRreg.EOF then
   if mod_ap="Y" then
      old_no =RRreg("old_no")
      ocname1=RRreg("ocname1")
      ocname2=RRreg("ocname2")
      oename1=RRreg("oename1")
      oename2=RRreg("oename2")
      new_no =RRreg("new_no")
      ncname1=RRreg("ncname1")
      ncname2=RRreg("ncname2")
      nename1=RRreg("nename1")
      nename2=RRreg("nename2")
   else
      apcust_no=RRreg("apcust_no")
      ap_cname =RRreg("ap_cname")
      ap_ename =RRreg("ap_ename")
   end if
end if
   RRreg.close
   set RRreg=nothing
%>
  <tr>
    <td width="28%" align="center" bgcolor="#CCFFCC"><strong><p align="right">原申請人統編 &nbsp; : </strong></td>
    <td width="72%" align="left" bgcolor="#FFFFFF" colspan="3">
    <%if mod_ap="Y" then
         response.write old_no    
      else
         response.write apcust_no
      end if%>
    </td>
  </tr>
  <tr>
    <td width="28%" align="center" bgcolor="#CCFFCC"><strong><p align="right">原申請人(中文) : </strong></td>
    <td width="72%" align="left" bgcolor="#FFFFFF" colspan="3">
    <%if mod_ap="Y" then
         response.write ocname1&ocname2    
      else
         response.write ap_cname
      end if%>
    </td>
  </tr>
  <tr>
    <td width="28%" align="center" bgcolor="#CCFFCC"><strong><p align="right">原申請人(英文) : </strong></td>
    <td width="72%" align="left" bgcolor="#FFFFFF" colspan="3">
    <%if mod_ap="Y" then
         response.write oename1&oename2    
      else
         response.write ap_ename
      end if%>
    </td>
  </tr>
  <tr>
    <td width="100%" align="center" bgcolor="#CCFFCC" colspan="4"><p align="left"><strong>變更事項:</strong></td>
  </tr>
  <tr>
    <td width="100%" bgcolor="#FFFFFF" colspan="4"><p align="left"><small><strong>
    <%if mod_ap="Y"     then response.write "1.申請人&nbsp;&nbsp;"%>
    <%if mod_aprep="Y"  then response.write "2.代表人&nbsp;&nbsp;"%>
    <%if mod_apaddr="Y" then response.write "3.申請人地址&nbsp;&nbsp;"%>
    <%if mod_agt="Y"    then response.write "5.代理人&nbsp;&nbsp;"%>
    <%if mod_agtaddr="Y"  then response.write "6.代理人地址&nbsp;&nbsp;"%>
    <%if mod_dmt="Y"  then response.write "7.商標圖樣&nbsp;&nbsp;"%>
    <%if mod_class="Y"  then response.write "8.類別商品&nbsp;&nbsp;"%>
    <%if mod_pul="Y"  then response.write "9.商標種類&nbsp;&nbsp;"%>
     </strong></small></td>
  </tr>
<%if mod_ap="Y" then%>
  <tr>
    <td width="100%" align="center" bgcolor="#CCFFCC" colspan="4"><p align="left"><strong>1.變更申請人:</strong></td>
  </tr>
  <tr>
    <td width="18%" align="center" bgcolor="#CCFFCC"><p align="right"><strong>統編 : </strong></td>
    <td width="82%" align="left" bgcolor="#FFFFFF" colspan="3"><%=new_no%></td>
  </tr>
  <tr>
    <td width="18%" align="center" bgcolor="#CCFFCC"><p align="right"><strong>申請人中文名稱 : </strong></td>
    <td width="29%" align="left" bgcolor="#FFFFFF" colspan="3"><%=ncname1&ncname2%></td>
  </tr>
  <tr>
    <td width="18%" align="center" bgcolor="#CCFFCC"><p align="right"><strong>申請人英文名稱 : </strong></td>
    <td width="29%" align="left" bgcolor="#FFFFFF" colspan="3"><%=nename1&nename2%></td>
  </tr>
<%end if
if mod_aprep="Y" then
   Set RRreg = Server.CreateObject("ADODB.RecordSet")
   sql = " select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='" & in_no & "' and mod_field='mod_aprep'"
   
   RRreg.Open Sql,Conn,1,1,adcmdtext
   if not RRreg.EOF then
      bm_ncrep=RRreg("ncrep")
      bm_nerep=RRreg("nerep")
   end if
   RRreg.close
   set RRreg=nothing

%>
  <tr>
    <td width="100%" align="center" bgcolor="#CCFFCC" colspan="4"><p align="left"><strong>2.變更代表人:</strong></td>
  </tr>
  <tr>
    <td width="23%" align="center" bgcolor="#CCFFCC"><p align="right"><strong>代表人(中文) : </strong></td>
    <td width="30%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_ncrep%></td>
  </tr>
  <tr>
    <td width="23%" align="center" bgcolor="#CCFFCC"><p align="right"><strong>代表人(英文) : </strong></td>
    <td width="30%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_nerep%></td>
  </tr>
<%end if
if mod_apaddr = "Y" then
   Set RRreg = Server.CreateObject("ADODB.RecordSet")
   sql = " select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='" & in_no & "' and mod_field='mod_apaddr'"
   
   RRreg.Open Sql,Conn,1,1,adcmdtext
   if not RRreg.EOF then
      bm_naddr1=trim(RRreg("naddr1"))
      bm_naddr2=trim(RRreg("naddr2"))
   end if
   RRreg.close
   set RRreg=nothing
   
%>
  <tr>
    <td width="100%" align="center" bgcolor="#CCFFCC" colspan="4"><p align="left"><strong>3.變更申請人地址:</strong></td>
  </tr>
  <tr>
    <td width="18%" align="center" bgcolor="#CCFFCC"><p align="right"><strong>申請人地址 : </strong></td>
    <td width="82%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_naddr1&bm_naddr2%></td>
  </tr>
<%end if
   Set RRreg = Server.CreateObject("ADODB.RecordSet")
   sql = " select * from dmt_temp where in_scode='" & in_scode & "' and in_no='" & in_no & "'"
   
   RRreg.Open Sql,Conn,1,1,adcmdtext
   if not RRreg.EOF then
      if mod_dmt="Y" then
		 bm_appl_name =RRreg("appl_name")
		 bm_cappl_name=RRreg("cappl_name")
		 bm_eappl_name=RRreg("eappl_name")
		 bm_eappl_name1=RRreg("eappl_name1")
		 bm_eappl_name2=RRreg("eappl_name2")
		 bm_jappl_name=RRreg("jappl_name")
		 bm_jappl_name1=RRreg("jappl_name1")
		 bm_jappl_name2=RRreg("jappl_name2")
		 bm_zappl_name1=RRreg("zappl_name1")
		 bm_zappl_name2=RRreg("zappl_name2")
		 bm_zname_type =coun(RRreg("zname_type"))
		 bm_oappl_name =RRreg("oappl_name")
		 bm_draw=RRreg("draw")
		 bm_symbol=RRreg("symbol")
		 bm_color=RRreg("color")
      end if
      if mod_class = "Y" then      
	     bm_class0=RRreg("class")
	     bm_grp_code=RRreg("grp_code")
	     bm_good_name=RRreg("good_name")
      end if 
   end if
   RRreg.close
   set RRreg=nothing
if mod_dmt="Y" then%>
  <tr>
    <td width="100%" align="center" bgcolor="#CCFFCC" colspan="4"><strong><p align="left">7.變更商標圖樣：</strong></td>
  </tr>
  <tr>
    <td width="18%" align="center" bgcolor="#CCFFCC"><p align="right"><strong>商標(標章)名稱 : </strong></td>
    <td width="29%" align="left" bgcolor="#FFFFFF"><%=bm_appl_name%></td>
    <td width="23%" align="center" bgcolor="#CCFFCC"><p align="right"><strong>不單獨主張專用權 : </strong></td>
    <td width="30%" align="left" bgcolor="#FFFFFF"><%=bm_oappl_name%></td>
  </tr>
  <tr>
    <td width="18%" align="center" bgcolor="#CCFFCC"><p align="center"><strong>圖樣中文 : </strong></td>
    <td width="82%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_cappl_name%></td>
  </tr>
  <tr>
    <td width="18%" align="center" bgcolor="#CCFFCC"><p align="center"><strong>圖樣英文 : </strong></td>
    <td width="82%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_eappl_name%></td>
  </tr>
  <tr>
    <td width="13%" align="center" bgcolor="#CCFFCC"><p align="right"><strong>中文字義 : </strong></td>
    <td width="87%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_eappl_name1%></td>
  </tr>
  <tr>
    <td width="13%" align="center" bgcolor="#CCFFCC"><p align="right"><strong>羅馬拼音 : </strong></td>
    <td width="87%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_eappl_name2%></td>
  </tr>
  <tr>
    <td width="18%" align="center" bgcolor="#CCFFCC"><p align="center"><strong>圖樣日文 : </strong></td>
    <td width="82%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_jappl_name%></td>
  </tr>
  <tr>
    <td width="13%" align="center" bgcolor="#CCFFCC"><p align="right"><strong>中文字義 : </strong></td>
    <td width="87%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_jappl_name1%></td>
  </tr>
  <tr>
    <td width="13%" align="center" bgcolor="#CCFFCC"><p align="right"><strong>羅馬拼音 : </strong></td>
    <td width="87%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_jappl_name2%></td>
  </tr>
  <tr>
    <td width="18%" align="right" bgcolor="#CCFFCC"><p align="center"><strong>圖樣其他外文 : </strong></td>
    <td width="82%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_zappl_name1%></td>
  </tr>
  <tr>
    <td width="13%" align="right" bgcolor="#CCFFCC"><strong>中文字義 : </strong></td>
    <td width="87%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_zappl_name1%></td>
  </tr>
  <tr>
    <td width="13%" align="right" bgcolor="#CCFFCC"><strong>羅馬拼音 : </strong></td>
    <td width="87%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_zappl_name2%></td>
  </tr>
  <tr>
    <td width="13%" align="right" bgcolor="#CCFFCC"><strong>語文別 : </strong></td>
    <td width="87%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_zname_type%></td>
  </tr>
  <tr>
    <td width="18%" align="center" bgcolor="#CCFFCC"><strong>圖形說明 : </strong></td>
    <td width="82%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_draw%></td>
  </tr>
  <tr>
    <td width="18%" align="center" bgcolor="#CCFFCC"><strong>記號說明 : </strong></td>
    <td width="82%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_symbol%></td>
  </tr>
  <tr>
    <td width="18%" align="center" bgcolor="#CCFFCC"><strong>圖樣顏色 : </strong></td>
    <td width="82%" align="left" bgcolor="#FFFFFF" colspan="3">
    <%select case bm_color
      case "B":response.write "墨色"
      case "C":response.write "彩色"
      case "M":response.write "顏色組合"
      end select
    %></td>
  </tr>
<%end if
if mod_class="Y" then%>
  <tr>
    <td width="100%" align="right" bgcolor="#CCFFCC" colspan="4"><strong><p align="left">8.變更類別與指定商品或服務：</strong></td>
  </tr>
  <tr>
    <td width="18%" align="right" bgcolor="#CCFFCC"><strong>變更後類別 : </strong></td>
    <td width="29%" align="left" bgcolor="#FFFFFF"><%=bm_class0%></td>
    <td width="23%" align="center" bgcolor="#CCFFCC"><p align="right"><strong>變更後組群代碼 
    : </strong></td>
    <td width="30%" align="left" bgcolor="#FFFFFF"><%=bm_grp_code%></td>
  </tr>
  <tr>
    <td width="18%" align="right" bgcolor="#CCFFCC"><strong>
    <%if Request.QueryString("add_arcase") ="BM5" then
         response.write "減縮後"
      else   
         response.write "變更後"
      end if%>指定商品/服務 : </strong></td>
    <td width="82%" align="left" bgcolor="#FFFFFF" colspan="3"><%=bm_good_name%></td>
  </tr>
<%end if%>
<%'變更商標種類
new_no=""
old_no=""
if mod_pul = "Y" then
   Set RRreg = Server.CreateObject("ADODB.RecordSet")
   sql = " select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='" & in_no & "' and mod_field='mod_pul'"
   
   RRreg.Open Sql,Conn,1,1,adcmdtext
   if not RRreg.EOF then
      new_no=trim(RRreg("new_no"))
      old_no=trim(RRreg("old_no"))
   end if
   RRreg.close
   set RRreg=nothing
end if   
%>
<%if mod_tcnref = "Y" then%>
  <tr>
    <td width="100%" align="right" bgcolor="#CCFFCC" colspan="4"><p align="left"><strong>9.變更商標種類：</strong></td>
  </tr>
  <tr>
    <td width="100%" bgcolor="#FFFFFF" colspan="4"><p align="left">

   ◎<%select case trim(old_no)
	 case ""   :response.write "正"
	 case "1"  :response.write "聯合"
	 case "2"  :response.write "防護"
	 case else :response.write "正"
	 end select%>商標/標章變更為 
    <%select case trim(new_no)
	 case ""   :response.write "正"
	 case "1"  :response.write "聯合"
	 case "2"  :response.write "防護"
	 case else :response.write "正"
	 end select%>商標/標章
<%end if%></td>
</tr>
<%'變更正商標號
new_no=""
old_no=""
if mod_tcnref = "Y" then
   Set RRreg = Server.CreateObject("ADODB.RecordSet")
   sql = " select * from dmt_tranlist where in_scode='" & in_scode & "' and in_no='" & in_no & "' and mod_field='mod_tcnref'"
   
   RRreg.Open Sql,Conn,1,1,adcmdtext
   if not RRreg.EOF then
      new_no =trim(RRreg("new_no"))
      ncname1=trim(RRreg("ncname1"))
      old_no =trim(RRreg("old_no"))
   end if
   RRreg.close
   set RRreg=nothing
  
%>  
<%if ncname1="A" then%>
  <tr>
    <td width="100%" bgcolor="#FFFFFF" colspan="4"><p align="left">◎變更聯合商標/標章之正商標/標章號數</td>
  </tr>
<%end if%>  
<%if ncname1="B" then%>
  <tr>
    <td width="100%" bgcolor="#FFFFFF" colspan="4"><p align="left">◎變更防護商標/標章之正商標/標章號數</td>
  </tr>
<%end if%>  
  <tr>
    <td width="18%" align="right" bgcolor="#CCFFCC"><strong>變更前正商標號數：</strong></td>
    <td width="31%" align="left" bgcolor="#FFFFFF"><%=old_no%></td>
    <td width="22%" align="right" bgcolor="#CCFFCC"><p align="right"><strong>變更後正商標號數：</strong></td>
    <td width="29%" align="left" bgcolor="#FFFFFF"><%=new_no%></td>
  </tr>
<%end if %>
  <%if Request.QueryString("add_arcase") ="BM5" then%>
   <tr>
    <td width="9%" align="right" bgcolor="#CCFFCC"><strong>原指定商品/服務：</strong></td>
    <td align="left" bgcolor="#FFFFFF"><%=tran_remark1%></td>
    <td align="right" bgcolor="#CCFFCC"><strong>擬減縮商品/服務：</strong></td>
    <td align="left" bgcolor="#FFFFFF"><%=tran_remark2%></td>
  </tr>
<%end if%>
  <tr>
    <td width="100%" align="right" bgcolor="#CCFFCC" colspan="4"><p align="left"><strong>10.其他：</strong></td>
  </tr>
  <tr>
    <td align="left" bgcolor="#FFFFFF" colspan="4">　</td>
  </tr>  
</table>
</center></div>