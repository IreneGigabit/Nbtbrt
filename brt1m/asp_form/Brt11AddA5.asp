<%
Sub doUpdateDB()
set cmd=Server.CreateObject("ADODB.command")
set cnn=Server.CreateObject("ADODB.connection")
set RSinfo=Server.CreateObject("ADODB.recordset")
Set RSreg = Server.CreateObject("ADODB.Recordset")
cnn.Open session("btbrtdb")
cmd.ActiveConnection=cnn
cnn.BeginTrans	

//�g�JLog��
log_table(conn);

//SQL = "delete from caseitem_dmt where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"'";
//conn.ExecuteNonQuery(SQL);

//SQL = "delete from casedmt_good where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"'";
//conn.ExecuteNonQuery(SQL);

//SQL = "delete from casedmt_show where in_no='"+Request["in_no"]+"'";
//conn.ExecuteNonQuery(SQL);

SQL = "delete from dmt_temp where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"' and case_sqlno<>0";
conn.ExecuteNonQuery(SQL);

SQL = "delete from case_dmt1 where in_no='"+Request["in_no"]+"'";
conn.ExecuteNonQuery(SQL);

SQL = "delete from dmt_tran where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"'";
conn.ExecuteNonQuery(SQL);

//�ӽФH_���Τl��
SQL="Delete dmt_temp_ap where in_no='"+Request["in_no"]+"' and case_sqlno<>0";
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
ColMap.Clear();
switch ((Request["tfy_arcase"] ?? "").Left(3)) {
	case "FD1":
		ColMap["other_item"] = Util.dbchar(Request["O_item11"] + ";" + Request["O_item12"] + ";" + Request["O_item13"]);
		break;
	case "FD2":
	case "FD3":
		ColMap["other_item"] = Util.dbchar(Request["O_item21"] + ";" + Request["O_item22"] + ";" + Request["O_item23"]);
		break;
}
ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
ColMap["in_no"] = Util.dbchar(Request["In_no"]);
ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
ColMap["tr_scode"] = "'" + Session["scode"] + "'";
ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
ColMap["seq1"] = Util.dbnull(Request["tfzb_seq1"]);
SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
conn.ExecuteNonQuery(SQL);

//�ӽФH�Jlog_table
//call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";0")
//�g�J���ӽФH��(dmt_temp_ap)
insert_dmt_temp_ap(conn,"0");

//*****���W��
Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"]??""));


//���
for (int x = 1; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
	ColMap.Clear();
	ColMap["in_no"] = Util.dbchar(Request["In_no"]);
	ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
	ColMap["seq1"] = Util.dbnull(Request["tfzb_seq1"]);
	ColMap["Cseq"] = Util.dbnull(Request["tfzb_seq"]);
	ColMap["Cseq1"] = Util.dbnull(Request["tfzb_seq1"]);
	SQL = "insert into case_dmt1 " + ColMap.GetInsertSQL();
	conn.ExecuteNonQuery(SQL);

	//��insert�᪺�y����
	SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
	object objResult1 = conn.ExecuteScalar(SQL);
	string case_sqlno = objResult1.ToString();

	//*****�s�W�ܮץ���
	ColMap.Clear();
	if ((Request["tfzb_seq"] ?? "") != "") ColMap["seq"] = Util.dbchar(Request["tfzb_seq"]);
	if ((Request["tfzb_seq1"] ?? "") != "") ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
	if ((Request["tfzd_S_mark"] ?? "") != "") ColMap["s_mark"] = Util.dbchar(Request["tfzd_S_mark"]);
	if ((Request["tfzd_pul"] ?? "") != "") ColMap["pul"] = Util.dbchar(Request["tfzd_pul"]);
	if ((Request["tfzd_Appl_name"] ?? "") != "") ColMap["appl_name"] = Util.dbchar(Request["tfzd_Appl_name"]);
	if ((Request["tfzd_cappl_name"] ?? "") != "") ColMap["cappl_name"] = Util.dbchar(Request["tfzd_cappl_name"]);
	if ((Request["tfzd_eappl_name"] ?? "") != "") ColMap["eappl_name"] = Util.dbchar(Request["tfzd_eappl_name"]);
	if ((Request["tfzd_eappl_name1"] ?? "") != "") ColMap["eappl_name1"] = Util.dbchar(Request["tfzd_eappl_name1"]);
	if ((Request["tfzd_eappl_name2"] ?? "") != "") ColMap["eappl_name2"] = Util.dbchar(Request["tfzd_eappl_name2"]);
	if ((Request["tfzd_jappl_name"] ?? "") != "") ColMap["jappl_name"] = Util.dbchar(Request["tfzd_jappl_name"]);
	if ((Request["tfzd_jappl_name1"] ?? "") != "") ColMap["jappl_name1"] = Util.dbchar(Request["tfzd_jappl_name1"]);
	if ((Request["tfzd_jappl_name2"] ?? "") != "") ColMap["jappl_name2"] = Util.dbchar(Request["tfzd_jappl_name2"]);
	if ((Request["tfzd_zappl_name1"] ?? "") != "") ColMap["zappl_name1"] = Util.dbchar(Request["tfzd_zappl_name1"]);
	if ((Request["tfzd_zappl_name2"] ?? "") != "") ColMap["zappl_name2"] = Util.dbchar(Request["tfzd_zappl_name2"]);
	if ((Request["tfzd_zname_type"] ?? "") != "") ColMap["zname_type"] = Util.dbchar(Request["tfzd_zname_type"]);
	if ((Request["tfzd_oappl_name"] ?? "") != "") ColMap["oappl_name"] = Util.dbchar(Request["tfzd_oappl_name"]);
	if ((Request["tfzd_Draw"] ?? "") != "") ColMap["Draw"] = Util.dbchar(Request["tfzd_Draw"]);
	if ((Request["tfzd_symbol"] ?? "") != "") ColMap["symbol"] = Util.dbchar(Request["tfzd_symbol"]);
	if ((Request["tfzd_color"] ?? "") != "") ColMap["color"] = Util.dbchar(Request["tfzd_color"]);
	if ((Request["tfzd_agt_no"] ?? "") != "") ColMap["agt_no"] = Util.dbchar(Request["tfzd_agt_no"]);
	if ((Request["pfzd_prior_date"] ?? "") != "") ColMap["prior_date"] = Util.dbchar(Request["pfzd_prior_date"]);
	if ((Request["tfzd_prior_no"] ?? "") != "") ColMap["prior_no"] = Util.dbchar(Request["tfzd_prior_no"]);
	if ((Request["tfzd_prior_country"] ?? "") != "") ColMap["tfzd_prior_country"] = Util.dbchar(Request["tfzd_prior_country"]);
	if ((Request["tfzd_ref_no"] ?? "") != "") ColMap["ref_no"] = Util.dbchar(Request["tfzd_ref_no"]);
	if ((Request["tfzd_ref_no1"] ?? "") != "") ColMap["ref_no1"] = Util.dbchar(Request["tfzd_ref_no1"]);
	if ((Request["tfzb_seq"] ?? "") != "") ColMap["Mseq"] = Util.dbchar(Request["tfzb_seq"]);
	if ((Request["tfzb_seq1"] ?? "") != "") ColMap["Mseq1"] = Util.dbchar(Request["tfzb_seq1"]);
	//2014/4/15�W�[�g�J�ӽФ�A�]���Τl�ץӽФ�P���׬ۦP
	if ((Request["tfzd_apply_date"] ?? "") != "") ColMap["apply_date"] = Util.dbchar(Request["tfzd_apply_date"]);
	switch ((Request["tfy_arcase"] ?? "").Left(3)) {
		case "FD1":
			if ((Request["FD1_class_count_" + x] ?? "") != "") {
				ColMap["class_type"] = Util.dbchar(Request["FD1_class_type_" + x]);
				ColMap["class_count"] = Util.dbchar(Request["FD1_class_count_" + x]);
				ColMap["class"] = Util.dbchar(Request["FD1_class_" + x]);
			}
			if ((Request["FD1_Marka_" + x] ?? "") != "") {
				ColMap["mark"] = Util.dbchar(Request["FD1_Marka_" + x]);
			}
			//���Ϋ�l�פ��Ӽк���2
			string s_mark2 = "";
			if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("1,5,H")) s_mark2 = "A";
			else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("4,8,C,G")) s_mark2 = "B";
			else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("3,7,B,F")) s_mark2 = "C";
			else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("2,6,A,E")) s_mark2 = "D";
			else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("I")) s_mark2 = "E";
			else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("J")) s_mark2 = "F";
			else if ((Request["tfy_div_arcase"] ?? "").Substring(2, 1).IN("K")) s_mark2 = "G";
			else s_mark2 = "A";
			
			ColMap["s_mark2"] = Util.dbchar(s_mark2);
			break;
		case "FD2":
		case "FD3":
			if ((Request["FD2_class_count_" + x] ?? "") != "") {
				ColMap["class_type"] = Util.dbchar(Request["FD2_class_type_" + x]);
				ColMap["class_count"] = Util.dbchar(Request["FD2_class_count_" + x]);
				ColMap["class"] = Util.dbchar(Request["FD2_class_" + x]);
			}
			if ((Request["FD2_Markb_" + x] ?? "") != "") {
				ColMap["mark"] = Util.dbchar(Request["FD2_Markb_" + x]);
			}
			if ((Request["tfzd_s_mark2" + x] ?? "") != "") {
				ColMap["s_mark2"] = Util.dbchar(Request["tfzd_s_mark2"]);
			}
			break;
	}
	ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
	ColMap["in_no"] = Util.dbchar(Request["In_no"]);
	ColMap["in_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
	ColMap["draw_file"] = Util.dbchar(Sys.Path2Btbrt(drawFilename));
	ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
	ColMap["tr_scode"] = "'" + Session["scode"] + "'";
	ColMap["case_sqlno"] = case_sqlno;

	SQL = "insert into dmt_temp " + ColMap.GetInsertSQL();
	conn.ExecuteNonQuery(SQL);

	switch ((Request["tfy_arcase"] ?? "").Left(3)) {
		case "FD1":
			//���Τl�װӫ~���O�J��
			for (int p = 1; p <= Convert.ToInt32("0" + Request["FD1_class_count_" + x]); p++) {
				if ((Request["classa_" + x + "_" + p] ?? "") != "" || (Request["FD1_good_namea_" + x + "_" + p] ?? "") != "") {
					ColMap.Clear();
					ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
					ColMap["in_no"] = Util.dbchar(Request["In_no"]);
					ColMap["case_sqlno"] = "'" + case_sqlno + "'";
					ColMap["class"] = Util.dbchar(Request["classa_" + x + "_" + p]);
					ColMap["dmt_goodname"] = Util.dbchar(Request["FD1_good_namea_" + x + "_" + p]);
					ColMap["dmt_goodcount"] = Util.dbchar(Request["FD1_good_counta_" + x + "_" + p]);
					ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
					ColMap["tr_scode"] = "'" + Session["scode"] + "'";

					SQL = "insert into casedmt_good " + ColMap.GetInsertSQL();
					//Response.Write(SQL + "<HR>");
					conn.ExecuteNonQuery(SQL);
				}
			}
			//���Τl�׮i���u���v�J��
			//���Ϋ�שʰ�FA9,FAA,FAB,FAC�~(�]�ҦC�שʵL�i���u���v)�A�A�̥��׮i���u���v��ƤJ��
			if ((Request["tfy_div_arcase"] ?? "").Left(3) != "FA9" && (Request["tfy_div_arcase"] ?? "").Left(3) != "FAA"
			&& (Request["tfy_div_arcase"] ?? "").Left(3) != "FAB" && (Request["tfy_div_arcase"] ?? "").Left(3) != "FAC") {
				//���Τl�׮i���u���v�J��
				insert_casedmt_show(conn, case_sqlno);
			}
			break;
		case "FD2":
		case "FD3":
			//���Τl�װӫ~���O�J��
			for (int p = 1; p <= Convert.ToInt32("0" + Request["FD2_class_count_" + x]); p++) {
				if ((Request["classb_" + x + "_" + p] ?? "") != "" || (Request["FD2_good_nameb_" + x + "_" + p] ?? "") != "") {
					ColMap.Clear();
					ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
					ColMap["in_no"] = Util.dbchar(Request["In_no"]);
					ColMap["case_sqlno"] = "'" + case_sqlno + "'";
					ColMap["class"] = Util.dbchar(Request["classb_" + x + "_" + p]);
					ColMap["dmt_goodname"] = Util.dbchar(Request["FD2_good_nameb_" + x + "_" + p]);
					ColMap["dmt_goodcount"] = Util.dbchar(Request["FD2_good_countb_" + x + "_" + p]);
					ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
					ColMap["tr_scode"] = "'" + Session["scode"] + "'";

					SQL = "insert into casedmt_good " + ColMap.GetInsertSQL();
					//Response.Write(SQL + "<HR>");
					conn.ExecuteNonQuery(SQL);
				}
			}
			//���Τl�׮i���u���v�J��
			insert_casedmt_show(conn, case_sqlno);
			break;
	}
	//���Τl�ץӽФH�J��	
	insert_dmt_temp_ap(conn, case_sqlno);
}

//��s�笢�x���T�{������(grconf_dmt.job_no)
upd_grconf_job_no(conn);

//��{�Ǧ��ק�_�שε��׵��O�ɳq���笢�H��
chk_end_back();

End sub '---- doUpdateDB() ----
%>