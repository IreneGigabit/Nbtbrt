<%
Sub doUpdateDB()
set cmd=Server.CreateObject("ADODB.command")
set cnn=Server.CreateObject("ADODB.connection")
set RSinfo=Server.CreateObject("ADODB.recordset")
cnn.Open session("btbrtdb")
cmd.ActiveConnection=cnn
cnn.BeginTrans	


//寫入Log檔
log_table(conn);


strSQL = "delete from caseitem_dmt where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"'"
cmd.CommandText=strSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "1=" & strSQL & "<hr>"
cmd.Execute(strSQL)

stSQL = "delete from casedmt_good where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "2=" & stSQL & "<hr>"
cmd.Execute(stSQL)

stSQL = "delete from dmt_tran where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"'"
'Response.Write StSQL&"<br><br>"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "3=" & stSQL & "<hr>"
cmd.Execute(stSQL)

stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_pul'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "4=" & stSQL & "<hr>"
cmd.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_ap'"
'Response.Write stSQL
'Response.End
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "5=" & stSQL & "<hr>"
cmd.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_claim1'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "6=" & stSQL & "<hr>"
cmd.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_dmt'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "7=" & stSQL & "<hr>"
cmd.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_class'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "8=" & stSQL & "<hr>"
cmd.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_aprep'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "9=" & stSQL & "<hr>"
cmd.Execute(stSQL)
stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_client'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "10=" & stSQL & "<hr>"
cmd.Execute(stSQL)

v=split(request("tfy_arcase"),"&")
arcase=v(0)
prt_code=v(1)

//寫入接洽記錄檔(case_dmt)
update_case_dmt(conn);

'據以異議商標圖樣	
select case left(Request("tfy_arcase"),3)
	case "DR1"
	   '--變換加附記使用後之商標/標章圖樣
	   mod_class_ncname1=move_file(filename,Request("ttg1_mod_class_ncname1"),"ttg1_mod_class_ncname1",request("old_file_ttg1c_1"))
	   mod_class_ncname2=move_file(filename,Request("ttg1_mod_class_ncname2"),"ttg1_mod_class_ncname2",request("old_file_ttg1c_2"))
	   mod_class_nename1=move_file(filename,Request("ttg1_mod_class_nename1"),"ttg1_mod_class_nename1",request("old_file_ttg1c_3"))
	   mod_class_nename2=move_file(filename,Request("ttg1_mod_class_nename2"),"ttg1_mod_class_nename2",request("old_file_ttg1c_4"))
	   mod_class_ncrep=move_file(filename,Request("ttg1_mod_class_ncrep"),"ttg1_mod_class_ncrep",request("old_file_ttg1c_5"))
	   mod_class_nerep=move_file(filename,Request("ttg1_mod_class_nerep"),"ttg1_mod_class_nerep",request("old_file_ttg1c_6"))
	   mod_class_neaddr1=move_file(filename,Request("ttg1_mod_class_neaddr1"),"ttg1_mod_class_neaddr1",request("old_file_ttg1c_7"))
	   mod_class_neaddr2=move_file(filename,Request("ttg1_mod_class_neaddr2"),"ttg1_mod_class_neaddr2",request("old_file_ttg1c_8"))
	   mod_class_neaddr3=move_file(filename,Request("ttg1_mod_class_neaddr3"),"ttg1_mod_class_neaddr3",request("old_file_ttg1c_9"))
	   mod_class_neaddr4=move_file(filename,Request("ttg1_mod_class_neaddr4"),"ttg1_mod_class_neaddr4",request("old_file_ttg1c_10"))
	   '--據以異議
	   mod_dmt_ncname1=move_file(filename,Request("ttg1_mod_dmt_ncname1"),"ttg1_mod_dmt_ncname1",request("old_file_ttg1_1"))
	   mod_dmt_ncname2=move_file(filename,Request("ttg1_mod_dmt_ncname2"),"ttg1_mod_dmt_ncname2",request("old_file_ttg1_2"))
	   mod_dmt_nename1=move_file(filename,Request("ttg1_mod_dmt_nename1"),"ttg1_mod_dmt_nename1",request("old_file_ttg1_3"))
	   mod_dmt_nename2=move_file(filename,Request("ttg1_mod_dmt_nename2"),"ttg1_mod_dmt_nename2",request("old_file_ttg1_4"))
	   mod_dmt_ncrep=move_file(filename,Request("ttg1_mod_dmt_ncrep"),"ttg1_mod_dmt_ncrep",request("old_file_ttg1_5"))
	   mod_dmt_nerep=move_file(filename,Request("ttg1_mod_dmt_nerep"),"ttg1_mod_dmt_nerep",request("old_file_ttg2_6"))
	   mod_dmt_neaddr1=move_file(filename,Request("ttg1_mod_dmt_neaddr1"),"ttg1_mod_dmt_neaddr1",request("old_file_ttg1_7"))
	   mod_dmt_neaddr2=move_file(filename,Request("ttg1_mod_dmt_neaddr2"),"ttg1_mod_dmt_neaddr2",request("old_file_ttg1_8"))
	   mod_dmt_neaddr3=move_file(filename,Request("ttg1_mod_dmt_neaddr3"),"ttg1_mod_dmt_neaddr3",request("old_file_ttg1_9"))
	   mod_dmt_neaddr4=move_file(filename,Request("ttg1_mod_dmt_neaddr4"),"ttg1_mod_dmt_neaddr4",request("old_file_ttg1_10"))
	case "DO1"
	   mod_dmt_ncname1=move_file(filename,Request("ttg2_mod_dmt_ncname1"),"ttg2_mod_dmt_ncname1",request("old_file_ttg2_1"))
	   mod_dmt_ncname2=move_file(filename,Request("ttg2_mod_dmt_ncname2"),"ttg2_mod_dmt_ncname2",request("old_file_ttg2_2"))
	   mod_dmt_nename1=move_file(filename,Request("ttg2_mod_dmt_nename1"),"ttg2_mod_dmt_nename1",request("old_file_ttg2_3"))
	   mod_dmt_nename2=move_file(filename,Request("ttg2_mod_dmt_nename2"),"ttg2_mod_dmt_nename2",request("old_file_ttg2_4"))
	   mod_dmt_ncrep=move_file(filename,Request("ttg2_mod_dmt_ncrep"),"ttg2_mod_dmt_ncrep",request("old_file_ttg2_5"))
	   mod_dmt_nerep=move_file(filename,Request("ttg2_mod_dmt_nerep"),"ttg2_mod_dmt_nerep",request("old_file_ttg2_6"))
	   mod_dmt_neaddr1=move_file(filename,Request("ttg2_mod_dmt_neaddr1"),"ttg2_mod_dmt_neaddr1",request("old_file_ttg2_7"))
	   mod_dmt_neaddr2=move_file(filename,Request("ttg2_mod_dmt_neaddr2"),"ttg2_mod_dmt_neaddr2",request("old_file_ttg2_8"))
	   mod_dmt_neaddr3=move_file(filename,Request("ttg2_mod_dmt_neaddr3"),"ttg2_mod_dmt_neaddr3",request("old_file_ttg2_9"))
	   mod_dmt_neaddr4=move_file(filename,Request("ttg2_mod_dmt_neaddr4"),"ttg2_mod_dmt_neaddr4",request("old_file_ttg2_10"))
	case "DI1"
	   mod_dmt_ncname1=move_file(filename,Request("ttg3_mod_dmt_ncname1"),"ttg3_mod_dmt_ncname1",request("old_file_ttg3_1"))
	   mod_dmt_ncname2=move_file(filename,Request("ttg3_mod_dmt_ncname2"),"ttg3_mod_dmt_ncname2",request("old_file_ttg3_2"))
	   mod_dmt_nename1=move_file(filename,Request("ttg3_mod_dmt_nename1"),"ttg3_mod_dmt_nename1",request("old_file_ttg3_3"))
	   mod_dmt_nename2=move_file(filename,Request("ttg3_mod_dmt_nename2"),"ttg3_mod_dmt_nename2",request("old_file_ttg3_4"))
	   mod_dmt_ncrep=move_file(filename,Request("ttg3_mod_dmt_ncrep"),"ttg3_mod_dmt_ncrep",request("old_file_ttg3_5"))
	   mod_dmt_nerep=move_file(filename,Request("ttg3_mod_dmt_nerep"),"ttg3_mod_dmt_nerep",request("old_file_ttg3_6"))
	   mod_dmt_neaddr1=move_file(filename,Request("ttg3_mod_dmt_neaddr1"),"ttg3_mod_dmt_neaddr1",request("old_file_ttg3_7"))
	   mod_dmt_neaddr2=move_file(filename,Request("ttg3_mod_dmt_neaddr2"),"ttg3_mod_dmt_neaddr2",request("old_file_ttg3_8"))
	   mod_dmt_neaddr3=move_file(filename,Request("ttg3_mod_dmt_neaddr3"),"ttg3_mod_dmt_neaddr3",request("old_file_ttg3_9"))
	   mod_dmt_neaddr4=move_file(filename,Request("ttg3_mod_dmt_neaddr4"),"ttg3_mod_dmt_neaddr4",request("old_file_ttg3_10"))
	end select	

	
//寫入接洽記錄主檔(dmt_temp)
update_dmt_temp(conn);

//寫入接洽費用檔(caseitem_dmt)
insert_caseitem_dmt(conn);

	'*****新增案件變更檔
	select case left(Request("tfy_arcase"),3)
	case "DR1":%><!--#include file="caseForm/UpdateDR1.inc"-->
	<%case "DO1":%><!--#include file="caseForm/UpdateDO1.inc"-->
	<%case "DI1":%><!--#include file="caseForm/UpdateDI1.inc"-->
    <%case else
//寫入商品類別檔(casedmt_good)
insert_casedmt_good(conn);

	
			if len(trim(Request("tfzb_seq"))) = 0 then
			   tfzb_seq="null"	
			else
			   tfzb_seq=Request("tfzb_seq")
			end if
			IF left (Request("tfy_arcase"),3)="DE1" then
				SQL3= "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tran_mark,tr_date,tr_scode,seq,seq1)" & _
				    " values ('" & Request("F_tscode") & "','" & request("In_no") & "','" & request("fr4_other_item") & "'," & _
				    "'" & request("fr4_other_item1") & "','" & request("fr4_other_item2") & "'," &_
				    "'" & request("fr4_tran_remark1") & "','" & request("fr4_tran_mark") & "','" & date() & "','" & session("se_scode") & "'," & _
					tfzb_seq &",'"& Request("tfzb_seq1")&"')"
				cmd.CommandText=SQL3
				If Trim(Request("chkTest"))<>Empty Then Response.Write "16=" & SQL3 & "<hr>"
				cmd.Execute(SQL3)	
				'新增對照當事人資料
				for k=1 to request("de1_apnum")
				    sql3 = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,naddr1) values ("
				    sql3 = sql3 & "'" & request("F_tscode") & "','" & request("in_no") & "','mod_client','" & trim(request("tfr4_ncname1_" & k)) & "','" & trim(request("tfr4_naddr1_" & k)) & "')"
				    cmd.CommandText=SQL3
				    If Trim(Request("chkTest"))<>Empty Then Response.Write "17=" & SQL3 & "<hr>"
					cmd.Execute(SQL3) 
				next 	
			ElseIF left (Request("tfy_arcase"),3)="DE2" then
				SQL3= "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tr_date,tr_scode,seq,seq1)" & _
				    " values ('" & Request("F_tscode") & "','" & request("In_no") & "','" & request("fr4_other_item") & "'," & _
				    "'" & request("fr4_other_item1") & "','" & request("fr4_other_item2") & "'," &_
				    "'" & request("fr4_tran_remark1") & "','" & date() & "','" & session("se_scode") & "'," & _
					tfzb_seq &",'"& Request("tfzb_seq1")&"')"
				cmd.CommandText=SQL3
				If Trim(Request("chkTest"))<>Empty Then Response.Write "18=" & SQL3 & "<hr>"
				cmd.Execute(SQL3)	
			Else
				SQL3= "INSERT INTO dmt_tran(in_scode,in_no,tran_remark1,tr_date,tr_scode,seq,seq1,agt_no1)" & _
					    " values ('" & Request("F_tscode") & "','" & Request("in_no") & "','" & request("tfg1_tran_remark1") & "','" & date() & "','" & session("se_scode") & "'," & _
						tfzb_seq &",'"& Request("tfzb_seq1")&"',"& pkStr(Request("tfg1_agt_no1"),"") &")"	  	 		
				cmd.CommandText=SQL3
				If Trim(Request("chkTest"))<>Empty Then Response.Write "19=" & SQL3 & "<hr>"
				cmd.Execute(SQL3)	
			End IF	
	end select
	'申請人入log_table
	'call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";0")
//寫入交辦申請人檔(dmt_temp_ap)
insert_dmt_temp_ap(conn,"0");

//*****文件上傳
Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"]??""));

//更新營洽官收確認紀錄檔(grconf_dmt.job_no)
upd_grconf_job_no(conn);

	'當程序有修改復案或結案註記時通知營洽人員
	if ucase(prgid)="BRT51" then
	    nback_flag=request("tfy_back_flag")
		if request("tfy_back_flag")=empty then nback_flag="N"
		nend_flag=request("tfy_end_flag")
		if request("tfy_end_flag")=empty then nend_flag="N"
		oback_flag=request("oback_flag")
		if request("oback_flag")=empty then oback_flag="N"
		oend_flag=request("oend_flag")
		if request("oend_flag")=empty then oend_flag="N"
	   	'Response.Write "b1:"&request("oback_flag") & ",b2:"&nback_flag&",e1:"&request("oend_flag") & ",e2:"&nend_flag
	   	'Response.End
	   if trim(nback_flag)<>trim(oback_flag) or trim(nend_flag)<> trim(oend_flag) then
	      Call Sendmail(nback_flag,nend_flag)		        
	      DoSendMail subject,body	
	   end if
	end if
'Response.end	
	If Trim(Request.Form("chkTest"))<>Empty Then
		cnn.RollbackTrans
		Response.Write "cnn.RollbackTrans...<br>"
		Response.End
	End If
	cnn.CommitTrans  
End sub '---- doUpdateDB() ----
%>