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

//SQL = "delete from caseitem_dmt where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"' ";
//conn.ExecuteNonQuery(SQL);

//SQL = "delete from casedmt_good where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"'  and case_sqlno=0";
//conn.ExecuteNonQuery(SQL);

//SQL = "delete from casedmt_show where in_no='"+Request["in_no"]+"' and case_sqlno=0";
//conn.ExecuteNonQuery(SQL);

/�R��case_dmt1
SQL="delete from case_dmt1 where in_no='"+Request["in_no"]+"'";
conn.ExecuteNonQuery(SQL);

//�R���l��dmt_temp
SQL="delete from dmt_temp where in_no='"+Request["in_no"]+"' and case_sqlno<>0";
conn.ExecuteNonQuery(SQL);

//�R���l��casedmt_good
SQL="delete from casedmt_good where in_no='"+Request["in_no"]+"' and case_sqlno<>0";
conn.ExecuteNonQuery(SQL);

//�R���l��casedmt_show
SQL="delete from casedmt_show where in_no='"+Request["in_no"]+"' and case_sqlno<>0";
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


//*****������	
'dmt_tran�Jlog
'call insert_log_table(cnn,"U",tprgid,"dmt_tran","in_no;in_scode",trim(request("in_no"))&";"&trim(request("in_scode"))) 
	ColMap.Clear();
	foreach (var key in Request.Form.Keys) {
		string colkey = key.ToString().ToLower();
		string colValue = Request[colkey];

		//��1~4�X
		if (colkey.Left(4) == "tfg1"||colkey.Left(4) == "tfzb") {
			ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
		}
	}

	if ((Request["O_item1"] ?? "") != "" || (Request["O_item2"] ?? "") != "") {//����
		ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);
	}

	ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
	ColMap["tr_scode"] = "'" + Session["scode"] + "'";
	ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
	SQL = "UPDATE dmt_tran set " + ColMap.GetUpdateSQL();
	SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
	conn.ExecuteNonQuery(SQL);

'*****�s�W�ץ󲧰ʩ����ɡA���Y�H���
	'dmt_tranlist�Jlog_table
	'call insert_log_table(cnn,"U",tprgid,"dmt_tranlist","in_no;in_scode",trim(request("in_no"))&";" & trim(request("in_scode")))	

	//*****�s�W�ץ󲧰ʩ����ɡA���Y�H���
	SQL="delete from dmt_tranlist where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "' and mod_field='mod_ap'";
	conn.ExecuteNonQuery(SQL);
	for (int i = 1; i <= Convert.ToInt32("0" + Request["ft_apnum"]); i++) {
		ColMap.Clear();
		ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
		ColMap["in_no"] = Util.dbchar(Request["in_no"]);
		ColMap["mod_field"] = "'mod_ap'";
		ColMap["old_no"] = Util.dbchar(Request["tfr_old_no_" + i]);
		ColMap["ocname1"] = Util.dbchar(Request["tfr_ocname1_" + i]);
		ColMap["ocname2"] = Util.dbchar(Request["tfr_ocname2_" + i]);
		ColMap["oename1"] = Util.dbchar(Request["tfr_oename1_" + i]);
		ColMap["oename2"] = Util.dbchar(Request["tfr_oename2_" + i]);
		ColMap["ocrep"] = Util.dbchar(Request["tfr_ocrep_" + i]);
		ColMap["oerep"] = Util.dbchar(Request["tfr_oerep_" + i]);
		ColMap["ozip"] = Util.dbchar(Request["tfr_ozip_" + i]);
		ColMap["oaddr1"] = Util.dbchar(Request["tfr_oaddr1_" + i]);
		ColMap["oaddr2"] = Util.dbchar(Request["tfr_oaddr2_" + i]);
		ColMap["oeaddr1"] = Util.dbchar(Request["tfr_oeaddr1_" + i]);
		ColMap["oeaddr2"] = Util.dbchar(Request["tfr_oeaddr2_" + i]);
		ColMap["oeaddr3"] = Util.dbchar(Request["tfr_oeaddr3_" + i]);
		ColMap["oeaddr4"] = Util.dbchar(Request["tfr_oeaddr4_" + i]);
		ColMap["otel0"] = Util.dbchar(Request["tfr_otel0_" + i]);
		ColMap["otel"] = Util.dbchar(Request["tfr_otel_" + i]);
		ColMap["otel1"] = Util.dbchar(Request["otel1_" + i]);
		ColMap["ofax"] = Util.dbchar(Request["ofax_" + i]);
		ColMap["tran_code"] = "'N'";

		SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
		conn.ExecuteNonQuery(SQL);
	}

  
'�ӽФH�Jlog_table
	 'call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";0")
//�g�J���ӽФH��(dmt_temp_ap)
insert_dmt_temp_ap(conn,"0");

//*****���W��
Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"]??""));

//����h��J��	
if ((Request["tfy_arcase"] ?? "") == "FT2") {
	for (int i = 2; i <= Convert.ToInt32("0" + Request["nfy_tot_num"]); i++) {
		ColMap.Clear();
		ColMap["in_no"] = Util.dbchar(Request["in_no"]);
		ColMap["seq"] = Util.dbnull(Request["dseqb_" + i]);
		ColMap["seq1"] = Util.dbnull(Request["dseq1b_" + i]);
		ColMap["Cseq"] = Util.dbnull(Request["dmseqb_" + i]);
		ColMap["Cseq1"] = Util.dbnull(Request["dmseq1b_" + i]);
		ColMap["case_stat1"] = ((Request["dseqb_" + i] ?? "") != "" ? "'OO'" : "'NN'");
		SQL = "insert into case_dmt1 " + ColMap.GetInsertSQL();
		conn.ExecuteNonQuery(SQL);

		//��insert�᪺�y����
		SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
		object objResult1 = conn.ExecuteScalar(SQL);
		string case_sqlno = objResult1.ToString();

		if ((Request["dseqb_" + i] ?? "") == "") {
			//�����
			SQL = "SELECT draw_file FROM dmt_temp_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and num='" + i + "' and mark='T'";
			object objResult2 = conn.ExecuteScalar(SQL);
			if (objResult2 != null) {
				string draw_file = objResult2.ToString();
				//�N�ɮק���ɦW
				string newfilename = move_file(draw_file, "-FT" + i,"");

				SQL = "insert into dmt_temp(s_mark,s_mark2,pul,apsqlno,ap_cname,ap_cname1,ap_cname2 ";
				SQL += ",ap_ename,ap_ename1,ap_ename2,appl_name,cappl_name,eappl_name";
				SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
				SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color,agt_no,prior_date,prior_no ";
				SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
				SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
				SQL += ",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
				SQL += ",in_scode,in_no,in_date,draw_file,tr_date,tr_scode,case_sqlno,seq1) ";
				SQL += "Select s_mark,s_mark2 as ts_mark,pul," + Util.dbnull(Request["tfzp_apsqlno"]) + " ";
				SQL += "," + Util.dbnull(Request["tfzp_ap_cname"]) + "," + Util.dbnull(Request["tfzp_ap_cname1"]) + " ";
				SQL += "," + Util.dbnull(Request["tfzp_ap_cname2"]) + "," + Util.dbnull(Request["tfzp_ap_ename"]) + " ";
				SQL += "," + Util.dbnull(Request["tfzp_ap_ename1"]) + "," + Util.dbnull(Request["tfzp_ap_ename2"]) + " ";
				SQL += ",appl_name,cappl_name,eappl_name ";
				SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
				SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color ";
				SQL += "," + Util.dbnull(Request["tfzd_agt_no"]) + ",prior_date,prior_no ";
				SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
				SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
				SQL += ",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
				SQL += ",'" + Request["in_scode"] + "'," + Util.dbchar(Request["in_no"]) + ",'" + DateTime.Today.ToShortDateString() + "','" + newfilename + "' ";
				SQL += ",'" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "'," + case_sqlno + ",'" + Request["dseq1b_" + i] + "' ";
				SQL += "from dmt_temp_change where in_scode='" + Request["F_tscode"] + "' ";
				SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
				SQL += "and num='" + i + "' and mark='T'";
				conn.ExecuteNonQuery(SQL);

				//�ӽФH��Ƶe��Apcust_FC_RE_form.inc
				//*****�ӽФH��
				insert_dmt_temp_ap(conn, case_sqlno);
			}

			//�ӫ~���O
			SQL = "INSERT INTO casedmt_good(in_scode,in_no,case_sqlno,class,dmt_grp_code,dmt_goodname,dmt_goodcount,tr_date,tr_scode) ";
			SQL += "select '" + Request["F_tscode"] + "'," + Util.dbchar(Request["in_no"]) + "," + case_sqlno + ",class,dmt_grp_code,dmt_goodname,dmt_goodcount";
			SQL += ",getdate()','" + Session["scode"] + "' ";
			SQL += "from casedmt_good_change where in_scode='" + Request["F_tscode"] + "' ";
			SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
			SQL += "and num='" + i + "' and mark='T' and (isnull(class,'')<>'' or isnull(dmt_goodname,'')<>'')";
			conn.ExecuteNonQuery(SQL);

			//�i���|�u���v
			SQL = "INSERT INTO casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) ";
			SQL += "select " + Util.dbchar(Request["in_no"]) + "," + case_sqlno + ",show_date,show_name,getdate()";
			SQL += "'" + Session["scode"] + "' ";
			SQL += "from casedmt_show_change where in_scode='" + Request["F_tscode"] + "' ";
			SQL += "and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' ";
			SQL += "and num='" + i + "' and mark='T' order by show_no";
			conn.ExecuteNonQuery(SQL);
		}
	}
	//�M�żȦs��
	SQL = "delete from dmt_temp_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='T'";
	conn.ExecuteNonQuery(SQL);
	SQL = "delete from casedmt_good_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='T'";
	conn.ExecuteNonQuery(SQL);
	SQL = "delete from casedmt_show_change where in_scode='" + Request["F_tscode"] + "' and cust_area='" + Request["F_cust_area"] + "' and cust_seq='" + Request["F_cust_seq"] + "' and mark='T'";
	conn.ExecuteNonQuery(SQL);
}

//��s�笢�x���T�{������(grconf_dmt.job_no)
upd_grconf_job_no(conn);

//��{�Ǧ��ק�_�שε��׵��O�ɳq���笢�H��
chk_end_back();

End sub '---- doUpdateDB() ----
%>