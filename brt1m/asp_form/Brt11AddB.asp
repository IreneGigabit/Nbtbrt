<%
sub doUpdateDB()

set RS=Server.CreateObject("ADODB.recordset")
set RSinfo=Server.CreateObject("ADODB.recordset")
set cmd=Server.CreateObject("ADODB.command")
set cnn=Server.CreateObject("ADODB.connection")
cnn.Open session("btbrtdb")
cmd.ActiveConnection=cnn
cnn.BeginTrans	
	
'******************產生流水號

	SQLno="SELECT MAX(in_no) FROM case_dmt WHERE (LEFT(in_no, 4) = YEAR(GETDATE()))"

	//寫入case_dmt
	insert_case_dmt(conn, RSno);

	//寫入dmt_temp
	insert_dmt_temp(conn, RSno);
	
	//寫入接洽費用檔
	insert_caseitem_dmt(conn, RSno);

	//將檔案更改檔名
	select case left(Request("tfy_arcase"),3)
	case "DR1"
	   mod_class_ncname1=move_file(RSno,Request("ttg1_mod_class_ncname1"),"ttg1_mod_class_ncname1")
	   mod_class_ncname2=move_file(RSno,Request("ttg1_mod_class_ncname2"),"ttg1_mod_class_ncname2")
	   mod_class_nename1=move_file(RSno,Request("ttg1_mod_class_nename1"),"ttg1_mod_class_nename1")
	   mod_class_nename2=move_file(RSno,Request("ttg1_mod_class_nename2"),"ttg1_mod_class_nename2")
	   mod_class_ncrep=move_file(RSno,Request("ttg1_mod_class_ncrep"),"ttg1_mod_class_ncrep")
	   mod_class_nerep=move_file(RSno,Request("ttg1_mod_class_nerep"),"ttg1_mod_class_nerep")
	   mod_class_neaddr1=move_file(RSno,Request("ttg1_mod_class_neaddr1"),"ttg1_mod_class_neaddr1")
	   mod_class_neaddr2=move_file(RSno,Request("ttg1_mod_class_neaddr2"),"ttg1_mod_class_neaddr2")
	   mod_class_neaddr3=move_file(RSno,Request("ttg1_mod_class_neaddr3"),"ttg1_mod_class_neaddr3")
	   mod_class_neaddr4=move_file(RSno,Request("ttg1_mod_class_neaddr4"),"ttg1_mod_class_neaddr4")
	   '--據以異議
	   mod_dmt_ncname1=move_file(RSno,Request("ttg1_mod_dmt_ncname1"),"ttg1_mod_dmt_ncname1")
	   mod_dmt_ncname2=move_file(RSno,Request("ttg1_mod_dmt_ncname2"),"ttg1_mod_dmt_ncname2")
	   mod_dmt_nename1=move_file(RSno,Request("ttg1_mod_dmt_nename1"),"ttg1_mod_dmt_nename1")
	   mod_dmt_nename2=move_file(RSno,Request("ttg1_mod_dmt_nename2"),"ttg1_mod_dmt_nename2")
	   mod_dmt_ncrep=move_file(RSno,Request("ttg1_mod_dmt_ncrep"),"ttg1_mod_dmt_ncrep")
	   mod_dmt_nerep=move_file(RSno,Request("ttg1_mod_dmt_nerep"),"ttg1_mod_dmt_nerep")
	   mod_dmt_neaddr1=move_file(RSno,Request("ttg1_mod_dmt_neaddr1"),"ttg1_mod_dmt_neaddr1")
	   mod_dmt_neaddr2=move_file(RSno,Request("ttg1_mod_dmt_neaddr2"),"ttg1_mod_dmt_neaddr2")
	   mod_dmt_neaddr3=move_file(RSno,Request("ttg1_mod_dmt_neaddr3"),"ttg1_mod_dmt_neaddr3")
	   mod_dmt_neaddr4=move_file(RSno,Request("ttg1_mod_dmt_neaddr4"),"ttg1_mod_dmt_neaddr4")
	case "DO1"
	   mod_dmt_ncname1=move_file(RSno,Request("ttg2_mod_dmt_ncname1"),"ttg2_mod_dmt_ncname1")
	   mod_dmt_ncname2=move_file(RSno,Request("ttg2_mod_dmt_ncname2"),"ttg2_mod_dmt_ncname2")
	   mod_dmt_nename1=move_file(RSno,Request("ttg2_mod_dmt_nename1"),"ttg2_mod_dmt_nename1")
	   mod_dmt_nename2=move_file(RSno,Request("ttg2_mod_dmt_nename2"),"ttg2_mod_dmt_nename2")
	   mod_dmt_ncrep=move_file(RSno,Request("ttg2_mod_dmt_ncrep"),"ttg2_mod_dmt_ncrep")
	   mod_dmt_nerep=move_file(RSno,Request("ttg2_mod_dmt_nerep"),"ttg2_mod_dmt_nerep")
	   mod_dmt_neaddr1=move_file(RSno,Request("ttg2_mod_dmt_neaddr1"),"ttg2_mod_dmt_neaddr1")
	   mod_dmt_neaddr2=move_file(RSno,Request("ttg2_mod_dmt_neaddr2"),"ttg2_mod_dmt_neaddr2")
	   mod_dmt_neaddr3=move_file(RSno,Request("ttg2_mod_dmt_neaddr3"),"ttg2_mod_dmt_neaddr3")
	   mod_dmt_neaddr4=move_file(RSno,Request("ttg2_mod_dmt_neaddr4"),"ttg2_mod_dmt_neaddr4")
	case "DI1"
	   mod_dmt_ncname1=move_file(RSno,Request("ttg3_mod_dmt_ncname1"),"ttg3_mod_dmt_ncname1")
	   mod_dmt_ncname2=move_file(RSno,Request("ttg3_mod_dmt_ncname2"),"ttg3_mod_dmt_ncname2")
	   mod_dmt_nename1=move_file(RSno,Request("ttg3_mod_dmt_nename1"),"ttg3_mod_dmt_nename1")
	   mod_dmt_nename2=move_file(RSno,Request("ttg3_mod_dmt_nename2"),"ttg3_mod_dmt_nename2")
	   mod_dmt_ncrep=move_file(RSno,Request("ttg3_mod_dmt_ncrep"),"ttg3_mod_dmt_ncrep")
	   mod_dmt_nerep=move_file(RSno,Request("ttg3_mod_dmt_nerep"),"ttg3_mod_dmt_nerep")
	   mod_dmt_neaddr1=move_file(RSno,Request("ttg3_mod_dmt_neaddr1"),"ttg3_mod_dmt_neaddr1")
	   mod_dmt_neaddr2=move_file(RSno,Request("ttg3_mod_dmt_neaddr2"),"ttg3_mod_dmt_neaddr2")
	   mod_dmt_neaddr3=move_file(RSno,Request("ttg3_mod_dmt_neaddr3"),"ttg3_mod_dmt_neaddr3")
	   mod_dmt_neaddr4=move_file(RSno,Request("ttg32_mod_dmt_neaddr4"),"ttg3_mod_dmt_neaddr4")
	end select	

	'*****新增案件變更檔
	select case left (Request("tfy_arcase"),3)
	case "DR1":%><!--#include file="caseForm/AddDR1.inc"-->
	<%case "DO1":%><!--#include file="caseForm/AddDO1.inc"-->
	<%case "DI1":%><!--#include file="caseForm/AddDI1.inc"-->
    <%case else
	//寫入商品類別檔
	insert_casedmt_good(conn, RSno);

			if trim(Request("tfzb_seq")) = "" then
			   tfg1_seq="null"	
			else
			   tfg1_seq=Request("tfzb_seq")				
			end if
			IF left (Request("tfy_arcase"),3)="DE1" then
				SQL3= "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tran_mark,tr_date,tr_scode,seq,seq1)" & _
				    " values ('" & Request("F_tscode") & "','" & RSno & "','" & request("fr4_other_item") & "'," & _
				    "'" & request("fr4_other_item1") & "','" & request("fr4_other_item2") & "'," &_
				    "'" & request("fr4_tran_remark1") & "','" & request("fr4_tran_mark") & "','" & date() & "','" & session("se_scode") & "'," & _
					tfg1_seq &",'"& Request("tfzb_seq1")&"')"
				cmd.CommandText=SQL3
				If Trim(Request("chkTest"))<>Empty Then Response.Write "6=" & SQL3 & "<hr>"
				cmd.Execute(SQL3)
				'新增對照當事人資料
				for k=1 to request("de1_apnum")
				    sql3 = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,naddr1) values ("
				    sql3 = sql3 & "'" & request("F_tscode") & "','" & RSno & "','mod_client','" & trim(request("tfr4_ncname1_" & k)) & "','" & trim(request("tfr4_naddr1_" & k)) & "')"
				    cmd.CommandText=SQL3
				    If Trim(Request("chkTest"))<>Empty Then Response.Write "7=" & SQL3 & "<hr>"
					cmd.Execute(SQL3) 
				next 	
			ElseIF left (Request("tfy_arcase"),3)="DE2" then
				SQL3= "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tr_date,tr_scode,seq,seq1)" & _
				    " values ('" & Request("F_tscode") & "','" & RSno & "','" & request("fr4_other_item") & "'," & _
				    "'" & request("fr4_other_item1") & "','" & request("fr4_other_item2") & "'," &_
				    "'" & request("fr4_tran_remark1") & "','" & date() & "','" & session("se_scode") & "'," & _
					tfg1_seq &",'"& Request("tfzb_seq1")&"')"
				cmd.CommandText=SQL3
				If Trim(Request("chkTest"))<>Empty Then Response.Write "8=" & SQL3 & "<hr>"
				cmd.Execute(SQL3)	
			Else
				SQL3= "INSERT INTO dmt_tran(in_scode,in_no,tran_remark1,tr_date,tr_scode,seq,seq1,agt_no1)" & _
				    " values ('" & Request("F_tscode") & "','" & RSno & "','" & request("tfg1_tran_remark1") & "','" & date() & "','" & session("se_scode") & "'," & _
					tfg1_seq &",'"& Request("tfzb_seq1")&"',"& pkStr(Request("tfg1_agt_no1"),"") &")"
				cmd.CommandText=SQL3
				If Trim(Request("chkTest"))<>Empty Then Response.Write "9=" & SQL3 & "<hr>"
				cmd.Execute(SQL3)				
			End IF
	end select

	//寫入交辦申請人檔
	insert_dmt_temp_ap(conn, RSno,"0");	

	//*****新增文件上傳
	insert_dmt_attach(conn, RSno);

	//後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
	upd_grconf_job_no(conn, RSno);

	//更新客戶主檔最近立案日
	upd_dmt_date(conn, RSno);
	
	If Trim(Request.Form("chkTest"))<>Empty Then
		cnn.RollbackTrans
		Response.Write "cnn.RollbackTrans...<br>"
		Response.End
	End If
	cnn.CommitTrans
End sub
%>

<!--#include file="CaseForm/ShowDoneBox.inc"-->