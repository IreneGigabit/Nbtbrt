<%
HTProgCap="商標接洽暨交辦單"
HTProgCode="Si04W04"
HTProgPrefix="Brt16"
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open Session("btbrtdb")
Set conn1 = Server.CreateObject("ADODB.Connection")
conn1.Open Session("btbrtdb")
Set cnn = Server.CreateObject("ADODB.Connection")
cnn.Open Session("sysctrl")

 Set RSreg = Server.CreateObject("ADODB.RecordSet")

 ASql = "SELECT a.In_no, b.cappl_name, b.eappl_name, b.jappl_name, " & _
        "a.seq,a.seq1,(SELECT Rs_detail FROM code_br WHERE Rs_code = a.Arcase and cr='Y' and no_code='N' and rs_type=a.arcase_type) AS nArcase, " & _
        "a.ar_mark,a.In_date, a.Source, a.Case_date, a.ar_chk1," & _
        "(select apcust_no from apcust where apsqlno=b.apsqlno) as apcust_no," & _
        "(select apclass from apcust where apsqlno=b.apsqlno) as apclass," & _
        "a.att_sql , b.class, a.Arcase, a.In_scode, a.stat_code , d.sc_name, " & _
        "a.cust_area, a.cust_seq,a.Service, a.Fees, a.Service + a.Fees AS aFee,a.discount,a.discount_chk,a.ar_chk,a.contract_no,a.remark,a.mark,c.tran_code,a.case_stat,c.id_no " & _
  	    "FROM Case_dmt a INNER JOIN dmt_temp b ON a.in_scode = b.in_scode AND a.in_no = b.in_no " & _
		"inner join custz c on a.cust_area=c.cust_area and a.cust_seq=c.cust_seq " & _
		"INNER JOIN sysctrl.dbo.scode d ON a.in_scode = d.scode " & _
		"WHERE 1=1 AND a.in_no="&Request.QueryString("in_no") 
 'Response.Write ASql
 'Response.End 
     RSreg.Open ASql,Conn,1,1,adcmdtext
%>

<html>

<head>
<meta http-equiv=Content-Type content="text/html; charset=utf-8">
<title><%=HTProgCap%></title>
<%
'cust_code代碼轉換
sub tran_code(a,b)
  sql001="select code_name from cust_code where code_type='"&trim(b)&"' and cust_code='"&trim(a)&"'"
'  Response.Write sql001
  set rs=conn.execute(sql001)
  if rs.eof then
     Response.Write ""
  else
     Response.Write "&nbsp;-&nbsp;"&rs(0)
  end if
  rs.close
  set rs=nothing
end sub

sub tran_agt(a)
  sql001="select agt_no,agt_name from agt where agt_no='"&trim(a)&"'"
'  Response.Write sql001
  set rs=Conn.execute(sql001)
  if rs.eof then
     Response.Write ""
  else
     Response.Write trim(rs(1))
  end if
  rs.close
  set rs=nothing
end sub

function tran_dmt(a)
  sql="select apcust_no from dmt_tran where in_no='"&trim(a)&"'"
  Response.Write sql001
  set rs=conn.execute(sql)
  if rs.eof then
     tran_dmt=""
  else
     tran_dmt=trim(rs(0))
  end if
  rs.close
  set rs=nothing
end function

function showfile(y,w,z)
    sqlx = "select ncname1,ncname2,nename1,nename2,ncrep from dmt_tranlist where in_scode = '" & _
	        w & "' and in_no = '" & z & "' and mod_field='" & y & "'"
    RRreg.open sqlx,conn,1,1
	if not RRreg.Eof then
	   for i=0 to 4	
			if RRreg(i) <> "" then
				aa=right(RRreg(i),len(RRreg(i))-InstrRev(RRreg(i),"\"))
 				if Instr(RRreg(i),"temp") = 0 then
				   
				   if instr(1,RRreg(i),":\") <> 0 then
				        dd=split(RBreg(i),"\")
						'response.write "<img src='/btbrt/" & session("se_branch") & "T/" & dd(4) &"/"& dd(5)&"/"& aa & "' width=""300"" height=""180"">"
						'response.write "<img src='/btbrt/" & session("se_branch") & "T/" & dd(4) &"/"& dd(5)&"/"& aa & "'>"
						response.write "<img src='/nbtbrt/" & session("se_branch") & "T/" & dd(4) &"/"& dd(5)&"/"& aa & "'>"
				   else
						response.write "<img src='" & replace(RRreg(i),"btbrt","nbtbrt",1,-1,1) & "'>"
				   end if		
				else           
				   'response.write "<img src='/btbrt/" & session("se_branch") & "t/temp/" & aa & "' width=""300"" height=""180"">"
				   'response.write "<img src='/btbrt/" & session("se_branch") & "t/temp/" & aa & "'>"
				   response.write "<img src='" & replace(RRreg(i),"btbrt","nbtbrt",1,-1,1) & "'>"
				end if
			end if
		next		
     end if
	 RRreg.Close      
end function

    function showdrawfile(pDraw_file)
            if trim(pDraw_file) <> "" or not isnull(pDraw_file) then
		  aa=right(pDraw_file,len(pDraw_file)-InstrRev(pDraw_file,"\"))
			if trim(pDraw_file) <> "" then
			   if not isnull(pDraw_file) then
					if Instr(pDraw_file,"temp") = 0 then
					   
					   if instr(1,pDraw_file,":\") <> 0 then
					      dd=split(pDraw_file,"\")
						  response.write "<img src=""/nbtbrt/" & session("se_branch") & "T/" & dd(4) &"/"& dd(5) &"/"& aa & """>"
					   else
					      response.write "<img src='" & replace(pDraw_file,"btbrt","nbtbrt",1,-1,1) & "' width=""300"" height=""180"">"
					   end if	  
					else           
					   'response.write "<img src=""/nbtbrt/" & session("se_branch") & "T/temp/" & aa & """>"
					   response.write "<img src='" & replace(pDraw_file,"btbrt","nbtbrt",1,-1,1) & "' width=""300"" height=""180"">"
					end if
				end if
			end if
          end if	
end function
%>
<script type="text/javascript">
    window.onload = function () {
        window.parent.tt.rows = "0%,100%";
    }
    function xx() {
        window.parent.tt.rows = "100%,0%";
    }
</script>
<body bgcolor="#ccffcc" lang=ZH-TW link=blue vlink=purple style="TEXT-JUSTIFY-TRIM:
 punctuation; tab-interval: 24.0pt">
<span onclick="javascript:xx();" style="color: darkblue; cursor: pointer;">[關閉]</span>
<div align="center"><center>
<table border="0" width="95%">
  <tr>
    <td width="100%"><p align="center"><b><span
    style="FONT-FAMILY: 新細明體; mso-ascii-font-family: 'Times New Roman'">商標接洽暨申請案交辦線上表單</span><span
    lang="EN-US"></span></b></p>
    <div align="center">
    <center>
    <table id="A" name="A" border="0" width="100%" bgcolor="#000000" cellspacing="1">
      <tr>
        <td width="20%" bgcolor="#CCFFCC" align="center"><font size="3"><b>營洽薪號</b></font></td>
        <td width="13%" bgcolor="#CCFFCC" align="center"><b>營洽姓名</b></td>
        <td width="13%" bgcolor="#CCFFCC" align="center"><strong>洽成日期</strong></td>
        <td width="17%" bgcolor="#CCFFCC" align="center"><strong>簽核流程</strong></td>
        <td width="15%" bgcolor="#CCFFCC" align="center"><strong>簽准日期</strong></td>
        <td width="13%" bgcolor="#CCFFCC" align="center"><strong>案件編號</strong></td>
        <td width="13%" bgcolor="#CCFFCC" align="center"><strong>狀態</strong></td>
      </tr>
      <tr>
        <td bgcolor="#FFFFFF" align="center"><%=RSreg("in_scode")%>-<%=RSreg("in_no")%></td>
        <td bgcolor="#FFFFFF" align="center"><%=trim(RSreg("sc_name"))%></td>
        <td bgcolor="#FFFFFF" align="center"><%=RSreg("in_date")%></td>
        <td bgcolor="#FFFFFF" align="center">
        <%
 BSql ="select * from todolist where in_no = '"_
       & Request.QueryString("in_no") & "' and in_scode='"& trim(RSreg("in_scode")) _
       & "' and left(job_status,1)='Y' and apcode='si04w02' order by sqlno"
' Response.Write Bsql
' Response.End 
 set RTreg = Server.CreateObject("ADODB.RecordSet")
     RTreg.Open BSql,Cnn,1,1,adcmdtext

 if not  RTreg.EOF then
    while not RTreg.EOF
       in_scode = RTreg("in_scode")
       ap_scode = ap_scode & "→" & RTreg("ap_scode")
       resp_date= RTreg("resp_date")
       RTreg.MoveNext 
    wend  
 end if
    RTreg.close
set RTreg=nothing 
Response.Write in_scode & ap_scode
%></td>
        <td bgcolor="#FFFFFF" align="center"><%=resp_date%></td>
        <td bgcolor="#FFFFFF" align="center"><%=session("se_branch")&"T"%><%=RSreg("seq")%></td>
        <td bgcolor="#FFFFFF" align="center">
      <%select case trim(RSreg("stat_code"))
        case "NN":Response.Write "未交辦"
        case "YN":Response.Write "已交辦"
        case "YY":Response.Write "簽准"
        case "NX":Response.Write "不准"
        case "YZ":Response.Write "程序簽准"
        end select
        %></td>
      </tr>
    </table>
    </center></div>
    <div align="center"><br><br>
    <b>一、<u>申請人與客戶基本 / 聯絡資料</u></b></p>
    <div align="center"><center><table border="0" width="100%">
      <tr>
        <td width="35%">
        <div align="center"><center>
        <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
          <tr>
            <td width="50%" align="center" bgcolor="#CCFFCC"><strong>新案</strong></td>
            <td width="50%" align="center" bgcolor="#CCFFCC"><strong>舊案</strong></td>
          </tr>
          <tr>
            <td width="50%" bgcolor="#FFFFFF" align="center"><%if left(trim(Rsreg("case_stat")),1) <> "O"  then Response.Write "ˇ"%></td>
            <td width="50%" bgcolor="#FFFFFF" align="center"><%if left(trim(Rsreg("case_stat")),1) = "O" then Response.Write "ˇ"%></td>
          </tr>
        </table>
        </center></div></td>
        <td width="5%"></td>
        <td width="95%"><div align="center"><center>
        <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
          <tr></tr>
         </table>
        </center></div></td> 
        <!--
        <td width="5%"></td>
        <td width="95%"><div align="center"><center>
        <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
          <tr>
            <td width="24%" align="center" bgcolor="#CCFFCC"><strong>新客戶</strong></td>
            <td width="29%" align="center" bgcolor="#CCFFCC"><strong>舊客戶</strong></td>
            <td width="47%" align="center" bgcolor="#CCFFCC"><strong>申請人是否同客戶</strong></td>
          </tr>
          <tr>
            <td width="24%" bgcolor="#FFFFFF" align="center"><%if left(RSreg("tran_code"),1) = "A" then Response.Write "ˇ"%></td>
            <td width="29%" bgcolor="#FFFFFF" align="center"><%if left(RSreg("tran_code"),1) <> "A" then Response.Write "ˇ"%></td>
            <td width="47%" bgcolor="#FFFFFF" align="center">
            <%
'            if trim(RSreg("mark")) = "B" then
'               apcust_no=tran_dmt(Request.QueryString("in_no"))                                          
'               Response.Write "T1"
'            else
'               apcust_no=trim(RSreg("apcust_no"))
'               Response.Write "T2"
'            end if
'               Response.Write apcust_no 
'               sql01="select id_no from custz where cust_area= '"&trim(RSreg("cust_area"))&"' and cust_seq=" & RSreg("cust_seq")
'               Set RSS = conn.Execute(sql01)

               if trim(Rsreg("apcust_no")) = trim(Rsreg("id_no")) then
                  Response.Write "是"               
               else
                  Response.Write "否"
               end if
'               RSS.Close
 '              set RSS=nothing   
            %>
            </td>
          </tr>
        </table>
        </center></div></td>-->
      </tr>
    </table>
    </center></div><p align="left"><strong>【申請人資料】</strong></p>
    <div align="center"><center>
    <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
    <%
    Dsql="select a.apcust_no,a.ap_cname,a.ap_ename,b.ap_crep,b.ap_erep,b.ap_addr1,b.ap_addr2,b.ap_eaddr1,"
    Dsql=Dsql & "b.ap_eaddr2,b.ap_eaddr3,b.ap_eaddr4,b.apclass,(select code_name from cust_code where code_type='apclass' and cust_code=b.apclass) as apclass_name"
    Dsql=Dsql & " from dmt_temp_ap a,apcust b where a.apsqlno=b.apsqlno and a.in_no='" & RSreg("in_no") & "' and a.case_sqlno=0"
'    Response.Write dsql&"<br>"
    set ISS=conn.execute(Dsql)
    if ISS.eof then
       ISS.Close
       Dsql="select b.apcust_no,a.ap_cname,a.ap_ename,b.ap_crep,b.ap_erep,b.ap_addr1,b.ap_addr2,b.ap_eaddr1,"
       Dsql=Dsql & "b.ap_eaddr2,b.ap_eaddr3,b.ap_eaddr4,b.apclass,(select code_name from cust_code where code_type='apclass' and cust_code=b.apclass) as apclass_name"
       Dsql=Dsql & " from dmt_temp a,apcust b where a.apsqlno=b.apsqlno and a.in_no='" & RSReg("in_no") & "' and a.case_sqlno=0"
       set ISS=conn.execute(Dsql)
    end if   
    if not ISS.eof then
      
    %>
      <tr>
        <td  bgcolor="#CCFFCC"  nowrap colspan=2></td>
        
        <td  bgcolor="#CCFFCC"><p align="center"><strong>申請人</strong></td>
        <td  bgcolor="#CCFFCC" align="center" nowrap><strong>代表人</strong></td>
        <td  bgcolor="#CCFFCC" align="center"><strong>申請人地址</strong></td>
        <td  bgcolor="#CCFFCC" align="center" nowrap><strong>申請人號</strong></td>
        <td  bgcolor="#CCFFCC" align="center"><strong>申請人<br>種類</strong></td>
      </tr>
    <%k=0
      while not ISS.eof
       k=k+1 
       ap_cname=trim(ISS("ap_cname"))
       ap_ename=trim(ISS("ap_ename"))
       ap_crep=trim(ISS("ap_crep"))
       ap_erep=trim(ISS("ap_erep"))
       ap_addr=trim(ISS("ap_addr1"))
       if trim(ISS("ap_addr2"))<>empty then ap_addr=ap_addr&"<br>"&trim(ISS("ap_addr2"))
       ap_eaddr=trim(ISS("ap_eaddr1"))
       if trim(ISS("ap_eaddr2"))<>empty then
          ap_eaddr=ap_eaddr&"<br>"&trim(ISS("ap_eaddr2"))
       end if
       if trim(ISS("ap_eaddr3"))<>empty then
          ap_eaddr=ap_eaddr&"<br>"&trim(ISS("ap_eaddr3"))
       end if
       if trim(ISS("ap_eaddr4"))<>empty then
          ap_eaddr=ap_eaddr&"<br>"&trim(ISS("ap_eaddr4"))
       end if   
       apclass_name=trim(ISS("apclass")) & "--" & trim(ISS("apclass_name"))
    %>  
      <tr>
		<td bgcolor="#CCFFCC" rowspan="2"><%=k%></td>
        <td  bgcolor="#CCFFCC"><p align="center">中</td>
        <td  bgcolor="#FFFFFF"><%=ap_cname%></td>
        <td bgcolor="#FFFFFF"><%=ap_crep%></td>
        <td  bgcolor="#FFFFFF"><%=ap_addr%></td>
        <td  bgcolor="#FFFFFF" rowspan="2" align="center"><%=trim(ISS("apcust_no"))%></td>
        <td  bgcolor="#FFFFFF" rowspan="2"><%=apclass_name%></td>
      </tr>
      <tr>
        <td  bgcolor="#CCFFCC"><p align="center">英</td>
        <td  bgcolor="#FFFFFF"><%=ap_ename%></td>
        <td  bgcolor="#FFFFFF"><%=ap_erep%></td>
        <td  bgcolor="#FFFFFF"><%=ap_eaddr%></td>
      </tr>
      <% ISS.movenext
       wend 
       end if    
       ISS.Close
	   set ISS=nothing
	  %> 
    </table>
    </center></div><p align="left"><strong>【客戶資料】</strong></p>
    <div align="center"><center>
    <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
    <%
        Esql="select ap_cname1,ap_cname2,ap_ename1,ap_ename2,ap_crep,id_no,con_code,con_term,tlevel,tdis_type,tpay_type,www,email,acc_zip,acc_addr1,acc_addr2,acc_tel0,acc_tel,acc_tel1 from custz a inner join apcust b on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq " _
           & "where b.cust_area= '"&trim(RSreg("cust_area"))&"' and b.cust_seq=" & RSreg("cust_seq")
    set ISS=conn.Execute(Esql)
'   if ISS.eof then
'      set ISS=Ionn.Execute(Esql)
'   end if
'    Response.Write Esql
'    Response.End 
    %>
      <tr>
        <td width="12%" bgcolor="#CCFFCC" align="center"><strong>客戶編號</strong></td>
        <td width="24%" bgcolor="#CCFFCC" align="center"><strong>客戶名稱</strong></td>
        <td width="12%" bgcolor="#CCFFCC" align="center"><strong>代表人</strong></td>
        <td width="13%" bgcolor="#CCFFCC" align="center"><strong>統一編號</strong></td>
        <td width="18%" bgcolor="#CCFFCC" align="center"><strong>顧問客戶</strong></td>
        <td width="8%" bgcolor="#CCFFCC"  align="center"><strong>等級</strong></td>
        <td width="13%" bgcolor="#CCFFCC" align="center"><strong>契約書號</strong></td>
      </tr>
      <tr>
        <td width="12%" bgcolor="#FFFFFF" align="center"><%=RSreg("cust_area")&RSreg("cust_seq")%></td>
        <td width="24%" bgcolor="#FFFFFF">
        <table border="0" width="100%" cellspacing="0" cellpadding="0">
           <tr><td width="100%"><%=trim(ISS("ap_cname1"))&trim(ISS("ap_cname2"))%></td></tr>
           <tr><td width="100%"><%=trim(ISS("ap_ename1"))&trim(ISS("ap_ename2"))%></td></tr>
        </table>
        </td>
        <td width="12%" bgcolor="#FFFFFF" align="center"><%=trim(ISS("ap_crep"))%></td>
        <td width="13%" bgcolor="#FFFFFF" align="center"><%=ISS("id_no")%></td>
        <td width="18%" bgcolor="#FFFFFF" align="center">
        <%=trim(ISS("con_code"))%>
        <%select case trim(ISS("con_code"))
          case "IP1":Response.Write "智慧財產權顧問"
          case "PT1":Response.Write "專利商標顧問"
          case "PP1":Response.Write "專利顧問"
          case "PP2":Response.Write "專利專案顧問"
          case "TT1":Response.Write "商標顧問"
          case "TT2":Response.Write "商標專案顧問"
          case "CC1":Response.Write "著作權顧問"
          end select%>
        <%=ISS("con_term")%></td>
        <td width="8%" bgcolor="#FFFFFF" align="center"><%=ISS("tlevel")%></td>
        <td width="13%" bgcolor="#FFFFFF" align="center"><%IF trim(RSreg("Contract_no"))="A" then%>後續案無契約書<%elseif trim(RSreg("Contract_no"))="B" then%>特案簽報<%elseif trim(RSreg("Contract_no"))="C" then%>其他契約書無編號<%ElseIF not isnull(trim(RSreg("contract_no"))) or trim(RSreg("contract_no")) <> "" then%><%=trim(RSreg("Contract_no"))%><%End IF%></td>
      </tr>
    </table>
    </center></div><br>
    <div align="center"><center>
    <table border="0" width="100%" bgcolor="#000000" cellspacing="1">
    <%
        Fsql="select attention,att_dept,att_zip,att_addr1,att_addr2,att_tel0,att_tel,att_tel1,att_fax,att_mobile,att_mag from custz_att where cust_area= '" _
             & trim(RSreg("cust_area")) &"' and cust_seq=" & RSreg("cust_seq") &" and att_sql = "& RSreg("att_sql")
    set ISS1=conn.Execute(Fsql)
'    Response.Write Fsql
'    Response.End 
    %>
      <tr>
        <td width="12%" bgcolor="#CCFFCC" align="center">聯絡人</td>
        <td width="19%" bgcolor="#FFFFFF"><%=ISS1("attention")%></td>
        <td width="13%" bgcolor="#CCFFCC"><p align="center">聯絡部門</td>
        <td width="20%" bgcolor="#FFFFFF"><%=ISS1("att_dept")%></td>
        <td width="14%" bgcolor="#CCFFCC" align="center">折扣代碼</td>
        <td width="22%" bgcolor="#FFFFFF"><%=ISS("tdis_type")%><%call tran_code(ISS("tdis_type"),"B")%></td>
      </tr>
      <tr>
        <td width="12%" bgcolor="#CCFFCC" align="center">聯絡地址</td>
        <td width="52%" bgcolor="#FFFFFF" colspan="3">(<%=trim(ISS1("att_zip"))%>)<%=trim(ISS1("att_addr1"))%><%=trim(ISS1("att_addr2"))%></td>
        <td width="14%" bgcolor="#CCFFCC" align="center">付款條件</td>
        <td width="22%" bgcolor="#FFFFFF"><%=ISS("tpay_type")%><%call tran_code(ISS("tpay_type"),"C")%></td>
      </tr>
      <tr>
        <td width="12%" bgcolor="#CCFFCC" align="center">聯絡電話</td>
        <td width="19%" bgcolor="#FFFFFF">(<%=trim(ISS1("att_tel0"))%>)<%=trim(ISS1("att_tel"))%><% if trim(ISS1("att_tel1")) <> "" then Response.Write "#"&trim(ISS1("att_tel1"))%></td>
        <td width="13%" bgcolor="#CCFFCC"><p align="center">傳　　真</td>
        <td width="20%" bgcolor="#FFFFFF"><%=ISS1("att_fax")%></td>
        <td width="14%" bgcolor="#CCFFCC" align="center">大哥大</td>
        <td width="22%" bgcolor="#FFFFFF"><%=ISS1("att_mobile")%></td>
      </tr>
      <tr>
        <td width="12%" bgcolor="#CCFFCC" align="center">WWW</td>
        <td width="19%" bgcolor="#FFFFFF"><%=trim(ISS("www"))%></td>
        <td width="13%" bgcolor="#CCFFCC"><p align="center">E-mail</td>
        <td width="20%" bgcolor="#FFFFFF"><%=trim(ISS("email"))%></td>
        <td width="14%" bgcolor="#CCFFCC" align="center">寄雜誌</td>
        <td width="22%" bgcolor="#FFFFFF">
        <%if trim(ISS1("att_mag")) ="Y" then 
             Response.Write "是"
          else
             Response.Write "否"
          end if   
             %></td>
      </tr>
      <tr>
        <td width="12%" bgcolor="#CCFFCC" align="center">對帳地址</td>
        <td width="52%" bgcolor="#FFFFFF" colspan="3">(<%=trim(ISS("acc_zip"))%>)<%=ISS("acc_addr1")%><%=ISS("acc_addr2")%></td>
        <td width="14%" bgcolor="#CCFFCC" align="center">會計電話</td>
        <td width="22%" bgcolor="#FFFFFF">(<%=trim(ISS("acc_tel0"))%>)<%=ISS("acc_tel")%><%if trim(ISS("acc_tel1")) <> "" then Response.Write "#"&trim(ISS("acc_tel1"))%></td>
      </tr>
          <%
       ISS.Close
   set ISS=nothing 
       ISS1.Close
   set ISS1=nothing 
    %>
    </table>
    </center></div><br><br>
    <p align="center"><strong>二、<u>成交案件暨收費資料</u></strong></p>
    <div align="center"><center><table border="0" width="100%" bgcolor="#000000"
    cellspacing="1">
      <tr>
        <td width="31%" bgcolor="#CCFFCC" align="center"><strong>案性</strong></td>
        <td width="10%" bgcolor="#CCFFCC" align="center"><strong>服務費</strong></td>
        <td width="10%" bgcolor="#CCFFCC" align="center"><strong>規費</strong></td>
        <td width="10%" bgcolor="#CCFFCC" align="center"><strong>合計</strong></td>
        <td width="10%" bgcolor="#CCFFCC" align="center"><strong>折扣率</strong></td>
        <td width="13%" bgcolor="#CCFFCC" align="center"><strong>特殊註記</strong></td>
        <td width="13%" bgcolor="#CCFFCC" align="center"><strong>案源</strong></td>
      </tr>
      <tr>
        <td bgcolor="#FFFFFF" align="center"><%=RSreg("nArcase")%></td>
        <td bgcolor="#FFFFFF" align="center"><%if not isnull(RSreg("service")) or trim(RSreg("service")) <> ""  then Response.Write formatcurrency(RSreg("service"),0)%></td>
        <td bgcolor="#FFFFFF" align="center"><%if not isnull(RSreg("fees")) or trim(RSreg("fees")) <> ""  then Response.Write formatcurrency(RSreg("fees"),0)%></td>
        <td bgcolor="#FFFFFF" align="center"><%if not isnull(RSreg("afee")) or trim(RSreg("afee")) <> ""  then Response.Write formatcurrency(RSreg("afee"),0)%></td>
        <td bgcolor="#FFFFFF" align="center"><%if not isnull(RSreg("discount")) or trim(RSreg("discount")) <> "" then  Response.Write RSreg("discount")&"%"%></td>
        <td bgcolor="#FFFFFF" align="center">
        <%select case RSreg("ar_mark")
          case "A":Response.Write "服務費實報實銷"
          case "B":Response.Write "規費實報實銷"
          case "C":Response.Write "扣收入"
          case "M":Response.Write "顧問及佣金(代收)"
          case "N":Response.Write "一般"
          end select
        %>
        </td>
        <td width="10%" bgcolor="#FFFFFF" align="center">
        <%
        Csql="select code_name from cust_code where code_type='D' and cust_code='" & trim(RSreg("source")) & "'"
        Set RSS = Server.CreateObject("ADODB.RecordSet")
        RSS.Open CSql,Conn,1,1,adcmdtext
        if RSS.EOF then
           Response.Write trim(RSreg("source"))
        else
           Response.Write trim(RSS("code_name"))
        end if
        RSS.Close
        set RSS=nothing   
        %>
        </td>
      </tr>
    </table>
    </center></div><br><br>
    <p align="center"><strong>三、<u>接洽事項記錄資料</u></strong></p>
    <div align="center"><center>
    <table border="0" width="100%" bgcolor="#000000" cellspacing="1" height="87">
      <tr>
        <td width="27%" bgcolor="#CCFFCC" align="center" colspan="2" height="18"><strong>檢附文件</strong></td>
        <td width="30%" bgcolor="#CCFFCC" align="center" colspan="2" height="18"><strong>函客戶附件</strong></td>
        <td width="43%" bgcolor="#CCFFCC" align="center" height="18"><strong>其他接洽事項記錄</strong></td>
      </tr>
      <tr>
        <td width="4%" bgcolor="#FFFFFF" height="17" align="center"><%if not isnull(trim(RSreg("contract_no"))) or trim(RSreg("contract_no")) <> "" then Response.Write "ˇ"%></td>
        <td width="23%" bgcolor="#CCFFCC" height="17">委辦契約書<%IF trim(RSreg("Contract_no"))="A" then%>：後續案無契約書<%elseif trim(RSreg("Contract_no"))="B" then%>：特案簽報<%elseif trim(RSreg("Contract_no"))="C" then%>：其他契約書無編號<%ElseIF not isnull(trim(RSreg("contract_no"))) or trim(RSreg("contract_no")) <> "" then%>號：<%=trim(RSreg("Contract_no"))%><%End IF%></td>
        <td width="4%" bgcolor="#FFFFFF" height="17"><%if trim(RSreg("ar_chk1")) = "Y" then Response.Write "ˇ"%></td>
        <td width="26%" bgcolor="#CCFFCC" height="17">即發請款單/收據</td>
        <td width="43%" bgcolor="#FFFFFF" height="53" rowspan="3"><%=trim(RSreg("remark"))%></td>
      </tr>
      <tr>
        <td width="4%" bgcolor="#FFFFFF" height="18" align="center"><%if trim(RSreg("discount_chk")) = "Y" then Response.Write "ˇ"%></td>
        <td width="23%" bgcolor="#CCFFCC" height="18">折扣請核單</td>
        <td width="4%" bgcolor="#FFFFFF" height="18" align="center"><%if trim(RSreg("ar_chk")) = "Y" then Response.Write "ˇ"%></td>
        <td width="26%" bgcolor="#CCFFCC" height="18">請款單收據/附本寄發</td>
      </tr>
      <tr>
        <td width="4%" bgcolor="#FFFFFF" height="18"></td>
        <td width="23%" bgcolor="#CCFFCC" height="18">申請書</td>
        <td width="4%" bgcolor="#FFFFFF" height="18"></td>
        <td width="26%" bgcolor="#CCFFCC" height="18">其他</td>
      </tr>
    </table>
    </center></div>
<%
in_scode=Rsreg("in_scode")
in_no=Rsreg("in_no")
seq=Rsreg("seq")
seq1=Rsreg("seq1")
case_stat=trim(Rsreg("case_stat"))
fees=RSreg("fees")
RSreg.close
set RSreg=nothing
%>
<p align="left">　</p><br>
<p align="center"><strong>四、<u>交辦內容</u></strong></p>
<%'依案性不同載入不同的檔案

  select case left(Request("add_arcase"),2)
case "FA":%><!--#include file="Brt16_FA.inc"-->
<%case "FC":%><!--#include file="Brt16_FC.inc"-->
<%case "FD":%><!--#include file="Brt16_FD.inc"-->
<%case "FF":%><!--#include file="Brt16_FF.inc"-->
<%case "FI":%><!--#include file="Brt16_FI.inc"-->
<%case "FV":%><!--#include file="Brt16_FV.inc"-->
<%case "FL":%><!--#include file="Brt16_FL.inc"-->
<%case "FN":%><!--#include file="Brt16_FN.inc"-->
<%case "FO":
	IF left(Request("add_arcase"),3)="FOB" then%>
		<!--#include file="Brt16_FOB.inc"-->
	<%else%>	
		<!--#include file="Brt16_ZZ.inc"-->
	<%End IF%>
<%case "FP":%><!--#include file="Brt16_FP.inc"-->
<%case "FR":%><!--#include file="Brt16_FR.inc"-->
<%case "FT":%><!--#include file="Brt16_FT.inc"-->
<%case "FS","MK","LA","SI","WA","WC","WR","XX","Z1":%><!--#include file="Brt16_ZZ1.inc"-->
<%case else:%>
	<%if Request("add_arcase") = "OG1" then%>
		 <!--#include file="Brt16_OG1.inc"-->
	<%elseif Request("add_arcase") = "OJ1" then%>
		 <!--#include file="Brt16_OJ1.inc"-->
	<%elseif Request("add_arcase") = "OO1" then%>
		 <!--#include file="Brt16_OO1.inc"-->
	<%elseif Request("add_arcase") = "DO1" then%>
		 <!--#include file="Brt16_DO1.inc"-->
	<%elseif Request("add_arcase") = "DI1" then%>
		 <!--#include file="Brt16_DI1.inc"-->
	<%elseif Request("add_arcase") = "DR1" then%>
		 <!--#include file="Brt16_DR1.inc"-->
	<%elseif Request("add_arcase") = "DE1" or Request("add_arcase") = "DE2" or Request("add_arcase") = "AD7" or Request("add_arcase") = "AD8"then%>
		 <!--#include file="Brt16_B5C1.inc"-->	 
	<%else%>
		 <!--#include file="Brt16_ZZ.inc"-->
	<%end if%>	 
<%end select%>
</body>

</html>
<%
conn.close()
set conn=nothing
conn1.close()
Set conn1=nothing
cnn.close()
Set cnn=nothing
%>