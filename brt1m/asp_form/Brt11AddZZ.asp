<%
Sub doUpdateDB()
set cmd=Server.CreateObject("ADODB.command")
set cnn=Server.CreateObject("ADODB.connection")
set RSinfo=Server.CreateObject("ADODB.recordset")
cnn.Open session("btbrtdb")
cmd.ActiveConnection=cnn
cnn.BeginTrans	

//�g�JLog��
log_table(conn);

//strSQL = "delete from caseitem_dmt where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"'"
//conn.ExecuteNonQuery(SQL);

//stSQL = "delete from casedmt_good where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"'"
//conn.ExecuteNonQuery(SQL);

//stSQL = "delete from casedmt_show where in_no='"+Request["in_no"]+"' and case_sqlno='0'"
//conn.ExecuteNonQuery(SQL);

stSQL = "delete from dmt_tranlist where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"' and mod_field in('other_item','mod_client')"
conn.ExecuteNonQuery(SQL);

//�g�J�����O����(case_dmt)
update_case_dmt(conn);

//�g�J�����O���D��(dmt_temp)
update_dmt_temp(conn);

//�g�J�����O����(caseitem_dmt)
insert_caseitem_dmt(conn);

//�g�J�ӫ~���O��(casedmt_good)
insert_casedmt_good(conn);

//�g�J�i���|�u���v��(casedmt_show)
insert_casedmt_show(conn,"0");

//***������
'dmt_tran�Jlog
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

	//�s�W��ӷ�ƤH���
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

		//��2~4�X
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

'�ӽФH�Jlog_table
	 'call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";0")
//�g�J���ӽФH��(dmt_temp_ap)
insert_dmt_temp_ap(conn,"0");

//*****���W��
Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"]??""));

//��s�笢�x���T�{������(grconf_dmt.job_no)
upd_grconf_job_no(conn);

//��{�Ǧ��ק�_�שε��׵��O�ɳq���笢�H��
chk_end_back();

End sub '---- doUpdateDB() ----
%>