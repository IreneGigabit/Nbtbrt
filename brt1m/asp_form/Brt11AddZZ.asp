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

stSQL = "delete from casedmt_show where in_no='"&request("In_no")&"' and case_sqlno='0'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "3=" & stSQL & "<hr>"
cmd.Execute(stSQL)

stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='other_item'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "4=" & stSQL & "<hr>"
cmd.Execute(stSQL)

stSQL = "delete from dmt_tranlist where in_no='"&request("In_no")&"' and in_scode='"&request("in_scode")&"' and mod_field='mod_client'"
cmd.CommandText=stSQL
If Trim(Request("chkTest"))<>Empty Then Response.Write "5=" & stSQL & "<hr>"
cmd.Execute(stSQL)

v=split(request("tfy_arcase"),"&")
arcase=v(0)
prt_code=v(1)

//寫入接洽記錄檔(case_dmt)
update_case_dmt(conn);

//寫入接洽記錄主檔(dmt_temp)
update_dmt_temp(conn);

//寫入接洽費用檔(caseitem_dmt)
insert_caseitem_dmt(conn);

//寫入商品類別檔(casedmt_good)
insert_casedmt_good(conn);

//寫入展覽會優先權檔(casedmt_show)
insert_casedmt_show(conn,"0");

//***異動檔
'dmt_tran入log
'call insert_log_table(cnn,"U",tprgid,"dmt_tran","in_no;in_scode",trim(request("in_no"))&";"&trim(request("in_scode"))) 
if ((Request["tfy_arcase"] ?? "").Left(3) == "AD7") {
	ColMap.Clear();
	ColMap["other_item"] = Util.dbchar(Request["fr4_other_item"]);
	ColMap["other_item1"] = Util.dbchar(Request["fr4_other_item1"]);
	ColMap["other_item2"] = Util.dbchar(Request["fr4_other_item2"]);
	ColMap["tran_remark1"] = Util.dbchar(Request["fr4_tran_remark1"]);
	ColMap["tran_mark"] = Util.dbchar(Request["fr4_tran_mark"]);
	ColMap["tr_date"] = "getdate()";
	ColMap["tr_scode"] = "'" + Session["scode"] + "'";
	ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
	ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
	ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
	SQL = "UPDATE dmt_tran set " + ColMap.GetUpdateSQL();
	SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
	conn.ExecuteNonQuery(SQL);

	//新增對照當事人資料
	for (int k = 1; k <= Convert.ToInt32("0" + Request["de1_apnum"]); k++) {
		SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,naddr1) values (";
		SQL += "'" + Request["in_scode"] + "'," + Util.dbchar(Request["in_no"]) + ",'mod_client'";
		SQL += "," + Util.dbchar(Request["tfr4_ncname1_" + k]);
		SQL += "," + Util.dbchar(Request["tfr4_naddr1_" + k]) + ")";
		conn.ExecuteNonQuery(SQL);
	}
} else if ((Request["tfy_arcase"] ?? "").Left(3) == "AD8") {
	ColMap.Clear();
	ColMap["other_item"] = Util.dbchar(Request["fr4_other_item"]);
	ColMap["other_item1"] = Util.dbchar(Request["fr4_other_item1"]);
	ColMap["other_item2"] = Util.dbchar(Request["fr4_other_item2"]);
	ColMap["tran_remark1"] = Util.dbchar(Request["fr4_tran_remark1"]);
	ColMap["tr_date"] = "getdate()";
	ColMap["tr_scode"] = "'" + Session["scode"] + "'";
	ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
	ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
	ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
	SQL = "UPDATE dmt_tran set " + ColMap.GetUpdateSQL();
	SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
	conn.ExecuteNonQuery(SQL);
} else if ((Request["tfy_arcase"] ?? "").Left(3) == "FOF") {
	ColMap.Clear();
	ColMap["other_item"] = Util.dbchar(Request["tfzf_other_item"]);
	ColMap["debit_money"] = Util.dbchar(Request["tfzf_debit_money"]);
	ColMap["other_item1"] = Util.dbchar(Request["tfzf_other_item1"]);
	ColMap["other_item2"] = Util.dbchar(Request["tfzf_other_item2"]);
	ColMap["tr_date"] = "getdate()";
	ColMap["tr_scode"] = "'" + Session["scode"] + "'";
	ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
	ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
	ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
	SQL = "UPDATE dmt_tran set " + ColMap.GetUpdateSQL();
	SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
	conn.ExecuteNonQuery(SQL);
} else if ((Request["tfy_arcase"] ?? "").Left(3) == "FB7") {
	ColMap.Clear();
	ColMap["agt_no1"] = Util.dbchar(Request["tfb7_agt_no1"]);
	ColMap["other_item"] = Util.dbchar(Request["tfb7_other_item"]);
	ColMap["tr_date"] = "getdate()";
	ColMap["tr_scode"] = "'" + Session["scode"] + "'";
	ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
	ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
	ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
	SQL = "UPDATE dmt_tran set " + ColMap.GetUpdateSQL();
	SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
	conn.ExecuteNonQuery(SQL);
} else if ((Request["tfy_arcase"] ?? "").Left(3) == "FW1") {
	ColMap.Clear();
	ColMap["agt_no1"] = Util.dbchar(Request["tfg1_agt_no1"]);
	ColMap["mod_claim1"] = Util.dbchar(Request["tfw1_mod_claim1"]);
	ColMap["tran_remark1"] = Util.dbchar(Request["tfw1_tran_remark1"]);
	ColMap["other_item"] = Util.dbchar(Request["tfw1_other_item"]);
	ColMap["tr_date"] = "getdate()";
	ColMap["tr_scode"] = "'" + Session["scode"] + "'";
	ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
	ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
	ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
	SQL = "UPDATE dmt_tran set " + ColMap.GetUpdateSQL();
	SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
	conn.ExecuteNonQuery(SQL);
} else {
	ColMap.Clear();
	foreach (var key in Request.Form.Keys) {
		string colkey = key.ToString().ToLower();
		string colValue = Request[colkey];

		//取2~4碼
		if (colkey.Left(4).Substring(1) == "fg1") {
			ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
		}
	}

	ColMap["tr_date"] = "getdate()";
	ColMap["tr_scode"] = "'" + Session["scode"] + "'";
	ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
	ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
	ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
	SQL = "UPDATE dmt_tran set " + ColMap.GetUpdateSQL();
	SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
	conn.ExecuteNonQuery(SQL);
}

if ((Request["tfg1_other_item"] ?? "") != "") {
	for (int i = 2; i <= 11; i++) {
		if ((Request["ttz1_P" + i] ?? "") != "") {
			SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_dclass,new_no) values (";
			SQL += " '" + Request["F_tscode"] + "'," + Util.dbchar(Request["in_no"]) + ",'other_item'," + Util.dbchar(Request["ttz1_P" + i]) + "";
			SQL += "," + Util.dbchar(Request["P" + i + "_mod_dclass"]) + "," + Util.dbchar(Request["P" + i + "_new_no"]) + ")";
			conn.ExecuteNonQuery(SQL);
		}
	}
}

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
		oback_flag=request("oback_flag")
		if request("oback_flag")=empty then oback_flag="N"
		nend_flag=request("tfy_end_flag")
		if request("tfy_end_flag")=empty then nend_flag="N"
		oend_flag=request("oend_flag")
		if request("oend_flag")=empty then oend_flag="N"
	   	'Response.Write "b1:"&request("oback_flag") & ",b2:"&nback_flag&",e1:"&request("oend_flag") & ",e2:"&nend_flag
	   	'Response.End
	   if trim(nback_flag)<>trim(oback_flag) or trim(nend_flag)<> trim(oend_flag) then
	      Call Sendmail(nback_flag,nend_flag)		        
	      DoSendMail subject,body	
	   end if
	end if
	
	If Trim(Request.Form("chkTest"))<>Empty Then
		cnn.RollbackTrans
		Response.Write "cnn.RollbackTrans...<br>"
		Response.End
	End If
	cnn.CommitTrans  
End sub '---- doUpdateDB() ----
%>