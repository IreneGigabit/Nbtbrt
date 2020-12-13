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

//SQL = "delete from caseitem_dmt where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"'";
//conn.ExecuteNonQuery(SQL);

//SQL = "delete from casedmt_good where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"'";
//conn.ExecuteNonQuery(SQL);

SQL = "delete from dmt_tran where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"'";
conn.ExecuteNonQuery(SQL);

SQL = "delete from dmt_tranlist where in_no='"+Request["in_no"]+"' and in_scode='"+Request["in_scode"]+"' and mod_field in('mod_pul','mod_ap','mod_claim1','mod_dmt','mod_class','mod_aprep','mod_client')";
conn.ExecuteNonQuery(SQL);

//寫入接洽記錄檔(case_dmt)
update_case_dmt(conn);
	
//寫入接洽記錄主檔(dmt_temp)
update_dmt_temp(conn);

//寫入接洽費用檔(caseitem_dmt)
insert_caseitem_dmt(conn);

	string in_scode=Request["F_tscode"]??"";
	if (prgid=="brt52"){
		in_scode =Request["in_scode"]??"";
	}

	//*****新增案件變更檔
	switch ((Request["tfy_arcase"] ?? "").Left(3)) {
	case "DR1":
		//--變換加附記使用後之商標/標章圖樣
		string DR1_mod_class_ncname1 = move_file( Request["ttg1_mod_class_ncname1"], "-C1",Request["old_file_ttg1c_1"]);
		string DR1_mod_class_ncname2 = move_file( Request["ttg1_mod_class_ncname2"], "-C2",Request["old_file_ttg1c_2"]);
		string DR1_mod_class_nename1 = move_file( Request["ttg1_mod_class_nename1"], "-C3",Request["old_file_ttg1c_3"]);
		string DR1_mod_class_nename2 = move_file( Request["ttg1_mod_class_nename2"], "-C4",Request["old_file_ttg1c_4"]);
		string DR1_mod_class_ncrep = move_file( Request["ttg1_mod_class_ncrep"], "-C5",Request["old_file_ttg1c_5"]);
		string DR1_mod_class_nerep = move_file( Request["ttg1_mod_class_nerep"], "-C6",Request["old_file_ttg1c_6"]);
		string DR1_mod_class_neaddr1 = move_file( Request["ttg1_mod_class_neaddr1"], "-C7",Request["old_file_ttg1c_7"]);
		string DR1_mod_class_neaddr2 = move_file( Request["ttg1_mod_class_neaddr2"], "-C8",Request["old_file_ttg1c_8"]);
		string DR1_mod_class_neaddr3 = move_file( Request["ttg1_mod_class_neaddr3"], "-C9",Request["old_file_ttg1c_9"]);
		string DR1_mod_class_neaddr4 = move_file( Request["ttg1_mod_class_neaddr4"], "-C10",Request["old_file_ttg1c_10"]);
		//--據以異議
		string DR1_mod_dmt_ncname1 = move_file( Request["ttg1_mod_dmt_ncname1"], "-O1",Request["old_file_ttg1_1"]);
		string DR1_mod_dmt_ncname2 = move_file( Request["ttg1_mod_dmt_ncname2"], "-O2",Request["old_file_ttg1_2"]);
		string DR1_mod_dmt_nename1 = move_file( Request["ttg1_mod_dmt_nename1"], "-O3",Request["old_file_ttg1_3"]);
		string DR1_mod_dmt_nename2 = move_file( Request["ttg1_mod_dmt_nename2"], "-O4",Request["old_file_ttg1_4"]);
		string DR1_mod_dmt_ncrep = move_file( Request["ttg1_mod_dmt_ncrep"], "-O5",Request["old_file_ttg1_5"]);
		string DR1_mod_dmt_nerep = move_file( Request["ttg1_mod_dmt_nerep"], "-O6",Request["old_file_ttg1_6"]);
		string DR1_mod_dmt_neaddr1 = move_file( Request["ttg1_mod_dmt_neaddr1"], "-O7",Request["old_file_ttg1_7"]);
		string DR1_mod_dmt_neaddr2 = move_file( Request["ttg1_mod_dmt_neaddr2"], "-O8",Request["old_file_ttg1_8"]);
		string DR1_mod_dmt_neaddr3 = move_file( Request["ttg1_mod_dmt_neaddr3"], "-O9",Request["old_file_ttg1_9"]);
		string DR1_mod_dmt_neaddr4 = move_file( Request["ttg1_mod_dmt_neaddr4"], "-O10",Request["old_file_ttg1_10"]);

                ColMap.Clear();
                foreach (var key in Request.Form.Keys) {
                    string colkey = key.ToString().ToLower();
                    string colValue = Request[colkey];

                    //取1~4碼
                    if (colkey.Left(4) == "tfz1") {
                        ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                    }
                }
                ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
                ColMap["in_scode"] = Util.dbchar(in_scode);
                ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
                ColMap["tr_scode"] = "'" + Session["scode"] + "'";
                ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
                SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);


                //*****變更被申請撤銷人資料
                if (Convert.ToInt32("0" + Request["DR1_apnum"]) > 0) {
                    for (int k = 1; k <= Convert.ToInt32("0" + Request["DR1_apnum"]); k++) {
                        SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,ncrep,nzip,naddr1,naddr2) values (";
                        SQL += "'" + in_scode + "'," + Util.dbchar(Request["in_no"]) + ",'mod_ap'";
                        SQL += "," + Util.dbchar(Request["ttg1_mod_ap_ncname1_" + k]) + "," + Util.dbchar(Request["ttg1_mod_ap_ncname2_" + k]) + "";
                        SQL += "," + Util.dbchar(Request["ttg1_mod_ap_ncrep_" + k]) + "," + Util.dbchar(Request["ttg1_mod_ap_nzip_" + k]) + "";
                        SQL += "," + Util.dbchar(Request["ttg1_mod_ap_naddr1_" + k]) + "," + Util.dbchar(Request["ttg1_mod_ap_naddr2_" + k]) + ")";
                        conn.ExecuteNonQuery(SQL);
                    }
                    SQL = "update dmt_tran set mod_ap='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }		

                //*****廢止聲明
                if ((Request["ttg11_mod_pul_new_no"] ?? "") != "" || (Request["ttg11_mod_pul_ncname1"] ?? "") != ""
                || (Request["ttg11_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg11_mod_pul_" + f]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg12_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg12_mod_pul_" + f]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg13_mod_pul_new_no"] ?? "") != "" || (Request["ttg13_mod_pul_mod_dclass"] ?? "") != ""
                || (Request["ttg13_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type", "new_no", "mod_dclass" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg13_mod_pul_" + f]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                if ((Request["ttg14_mod_pul_new_no"] ?? "") != "" || (Request["ttg14_mod_pul_mod_dclass"] ?? "") != ""
                || (Request["ttg14_mod_pul_ncname1"] ?? "") != "" || (Request["ttg14_mod_pul_mod_type"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_pul'";

                    string[] field = { "mod_type","new_no", "mod_dclass", "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg14_mod_pul_" + f]);
                    }

                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //據以異議商標/標章
                if ((Request["ttg1_mod_claim1_ncname1"] ?? "") != "") {
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                    ColMap["mod_field"] = "'mod_claim1'";

                    string[] field = { "ncname1" };
                    foreach (string f in field) {
                        ColMap[f] = Util.dbnull(Request["ttg1_mod_claim1_" + f]);
                    }
                    SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_claim1='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"]  + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //變換使用商標圖樣
                if ((Request["ttg1_mod_class_ncname1"] ?? "") != "" || (Request["ttg1_mod_class_ncname2"] ?? "") != ""
                || (Request["ttg1_mod_class_nename1"] ?? "") != "" || (Request["ttg1_mod_class_nename2"] ?? "") != ""
                || (Request["ttg1_mod_class_ncrep"] ?? "") != "" || (Request["ttg1_mod_class_nerep"] ?? "") != ""
                || (Request["ttg1_mod_class_neaddr1"] ?? "") != "" || (Request["ttg1_mod_class_neaddr2"] ?? "") != ""
                || (Request["ttg1_mod_class_neaddr3"] ?? "") != "" || (Request["ttg1_mod_class_neaddr4"] ?? "") != ""
                ) {
                    SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4)";
                    SQL += "VALUES('" +in_scode+ "'," + Util.dbchar(Request["in_no"]) + ",'mod_class'";
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_ncname1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_ncname2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_nename1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_nename2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_ncrep)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_nerep));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_neaddr1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_neaddr2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_neaddr3)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_class_neaddr4)) + ")";
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_class='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

                //變換撤銷商標圖樣
                if ((Request["ttg1_mod_dmt_ncname1"] ?? "") != "" || (Request["ttg1_mod_dmt_ncname2"] ?? "") != ""
                || (Request["ttg1_mod_dmt_nename1"] ?? "") != "" || (Request["ttg1_mod_dmt_nename2"] ?? "") != ""
                || (Request["ttg1_mod_dmt_ncrep"] ?? "") != "" || (Request["ttg1_mod_dmt_nerep"] ?? "") != ""
                || (Request["ttg1_mod_dmt_neaddr1"] ?? "") != "" || (Request["ttg1_mod_dmt_neaddr2"] ?? "") != ""
                || (Request["ttg1_mod_dmt_neaddr3"] ?? "") != "" || (Request["ttg1_mod_dmt_neaddr4"] ?? "") != ""
                ) {
                    SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4)";
                    SQL += "VALUES('" + in_scode + "'," + Util.dbchar(Request["in_no"]) + ",'mod_dmt'";
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_ncname1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_ncname2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_nename1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_nename2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_ncrep)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_nerep));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_neaddr1)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_neaddr2));
                    SQL += "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_neaddr3)) + "," + Util.dbnull(Sys.Path2Btbrt(DR1_mod_dmt_neaddr4)) + ")";
                    conn.ExecuteNonQuery(SQL);

                    SQL = "update dmt_tran set mod_dmt='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
                    conn.ExecuteNonQuery(SQL);
                }

		break;
	case "DO1":
		string DO1_mod_dmt_ncname1 = move_file( Request["ttg2_mod_dmt_ncname1"], "-O1",Request["old_file_ttg2_1"]);
		string DO1_mod_dmt_ncname2 = move_file( Request["ttg2_mod_dmt_ncname2"], "-O2",Request["old_file_ttg2_2"]);
		string DO1_mod_dmt_nename1 = move_file( Request["ttg2_mod_dmt_nename1"], "-O3",Request["old_file_ttg2_3"]);
		string DO1_mod_dmt_nename2 = move_file( Request["ttg2_mod_dmt_nename2"], "-O4",Request["old_file_ttg2_4"]);
		string DO1_mod_dmt_ncrep = move_file( Request["ttg2_mod_dmt_ncrep"], "-O5",Request["old_file_ttg2_5"]);
		string DO1_mod_dmt_nerep = move_file( Request["ttg2_mod_dmt_nerep"], "-O6",Request["old_file_ttg2_6"]);
		string DO1_mod_dmt_neaddr1 = move_file( Request["ttg2_mod_dmt_neaddr1"], "-O7",Request["old_file_ttg2_7"]);
		string DO1_mod_dmt_neaddr2 = move_file( Request["ttg2_mod_dmt_neaddr2"], "-O8",Request["old_file_ttg2_8"]);
		string DO1_mod_dmt_neaddr3 = move_file( Request["ttg2_mod_dmt_neaddr3"], "-O9",Request["old_file_ttg2_9"]);
		string DO1_mod_dmt_neaddr4 = move_file( Request["ttg2_mod_dmt_neaddr4"], "-O10",Request["old_file_ttg2_10"]);

		ColMap.Clear();
		foreach (var key in Request.Form.Keys) {
			string colkey = key.ToString().ToLower();
			string colValue = Request[colkey];

			//取1~4碼
			if (colkey.Left(4) == "tfz2") {
				ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
			}
		}
		ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
		ColMap["in_scode"] = Util.dbchar(in_scode);
		ColMap["in_no"] = Util.dbchar(Request["in_no"]);
		ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
		ColMap["tr_scode"] = "'" + Session["scode"] + "'";
		ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
		SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
		conn.ExecuteNonQuery(SQL);

		//*****變更被申請撤銷人資料
		if (Convert.ToInt32("0" + Request["DO1_apnum"]) > 0) {
			for (int k = 1; k <= Convert.ToInt32("0" + Request["DO1_apnum"]); k++) {
				SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,ncrep,nzip,naddr1,naddr2) values (";
				SQL += "'" + in_scode + "'," + Util.dbchar(Request["in_no"]) + ",'mod_ap'";
				SQL += "," + Util.dbchar(Request["ttg2_mod_ap_ncname1_" + k]) + "," + Util.dbchar(Request["ttg2_mod_ap_ncname2_" + k]) + "";
				SQL += "," + Util.dbchar(Request["ttg2_mod_ap_ncrep_" + k]) + "," + Util.dbchar(Request["ttg2_mod_ap_nzip_" + k]) + "";
				SQL += "," + Util.dbchar(Request["ttg2_mod_ap_naddr1_" + k]) + "," + Util.dbchar(Request["ttg2_mod_ap_naddr2_" + k]) + ")";
				conn.ExecuteNonQuery(SQL);
			}
			SQL = "update dmt_tran set mod_ap='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
			conn.ExecuteNonQuery(SQL);
		}		

		//*****廢止聲明
		if ((Request["ttg21_mod_pul_new_no"] ?? "") != "" || (Request["ttg21_mod_pul_ncname1"] ?? "") != ""
		|| (Request["ttg21_mod_pul_mod_type"] ?? "") != "") {
			ColMap.Clear();
			ColMap["in_scode"] = Util.dbchar(in_scode);
			ColMap["in_no"] = Util.dbchar(Request["in_no"]);
			ColMap["mod_field"] = "'mod_pul'";

			string[] field = { "mod_type", "new_no", "ncname1" };
			foreach (string f in field) {
				ColMap[f] = Util.dbnull(Request["ttg21_mod_pul_" + f]);
			}
			SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);

			SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
			conn.ExecuteNonQuery(SQL);
		}

		if ((Request["ttg22_mod_pul_mod_type"] ?? "") != "") {
			ColMap.Clear();
			ColMap["in_scode"] = Util.dbchar(in_scode);
			ColMap["in_no"] = Util.dbchar(Request["in_no"]);
			ColMap["mod_field"] = "'mod_pul'";

			string[] field = { "mod_type" };
			foreach (string f in field) {
				ColMap[f] = Util.dbnull(Request["ttg22_mod_pul_" + f]);
			}
			SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);

			SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
			conn.ExecuteNonQuery(SQL);
		}

		if ((Request["ttg23_mod_pul_new_no"] ?? "") != "" || (Request["ttg23_mod_pul_mod_dclass"] ?? "") != ""
		|| (Request["ttg23_mod_pul_mod_type"] ?? "") != "") {
			ColMap.Clear();
			ColMap["in_scode"] = Util.dbchar(in_scode);
			ColMap["in_no"] = Util.dbchar(Request["in_no"]);
			ColMap["mod_field"] = "'mod_pul'";

			string[] field = { "mod_type", "new_no", "mod_dclass" };
			foreach (string f in field) {
				ColMap[f] = Util.dbnull(Request["ttg23_mod_pul_" + f]);
			}

			SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);

			SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
			conn.ExecuteNonQuery(SQL);
		}

		if ((Request["ttg24_mod_pul_new_no"] ?? "") != "" || (Request["ttg24_mod_pul_mod_dclass"] ?? "") != ""
		|| (Request["ttg24_mod_pul_ncname1"] ?? "") != "" || (Request["ttg24_mod_pul_mod_type"] ?? "") != "") {
			ColMap.Clear();
			ColMap["in_scode"] = Util.dbchar(in_scode);
			ColMap["in_no"] = Util.dbchar(Request["in_no"]);
			ColMap["mod_field"] = "'mod_pul'";

			string[] field = { "mod_type", "new_no", "mod_dclass", "ncname1" };
			foreach (string f in field) {
				ColMap[f] = Util.dbnull(Request["ttg24_mod_pul_" + f]);
			}

			SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);

			SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
			conn.ExecuteNonQuery(SQL);
		}

		//據以異議商標/標章
		if (Convert.ToInt32("0" + Request["ttg2_mod_aprep_mod_count"]) > 0) {
			for (int i = 1; i <= Convert.ToInt32("0" + Request["ttg2_mod_aprep_mod_count"]); i++) {
				SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,mod_count,ncname1,new_no) values (";
				SQL += "'" + in_scode + "','" + Request["in_no"] + "','mod_aprep'";
				SQL += "," + Util.dbnull(Request["ttg2_mod_aprep_mod_count"]) + "," + Util.dbchar(Request["ttg2_mod_aprep_ncname1_" + i]) + "";
				SQL += "," + Util.dbchar(Request["ttg2_mod_aprep_new_no_" + i]) + ")";
				conn.ExecuteNonQuery(SQL);
			}
			SQL = "update dmt_tran set mod_aprep='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
			conn.ExecuteNonQuery(SQL);
		}

		//變換撤銷商標圖樣
		if ((Request["ttg2_mod_dmt_ncname1"] ?? "") != "" || (Request["ttg2_mod_dmt_ncname2"] ?? "") != ""
		|| (Request["ttg2_mod_dmt_nename1"] ?? "") != "" || (Request["ttg2_mod_dmt_nename2"] ?? "") != ""
		|| (Request["ttg2_mod_dmt_ncrep"] ?? "") != "" || (Request["ttg2_mod_dmt_nerep"] ?? "") != ""
		|| (Request["ttg2_mod_dmt_neaddr1"] ?? "") != "" || (Request["ttg2_mod_dmt_neaddr2"] ?? "") != ""
		|| (Request["ttg2_mod_dmt_neaddr3"] ?? "") != "" || (Request["ttg2_mod_dmt_neaddr4"] ?? "") != ""
		) {
			SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4)";
			SQL += "VALUES('" + Request["in_scode"] + "'," + Util.dbchar(Request["in_no"]) + ",'mod_dmt'";
			SQL += "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_ncname1)) + "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_ncname2));
			SQL += "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_nename1)) + "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_nename2));
			SQL += "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_ncrep)) + "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_nerep));
			SQL += "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_neaddr1)) + "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_neaddr2));
			SQL += "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_neaddr3)) + "," + Util.dbnull(Sys.Path2Btbrt(DO1_mod_dmt_neaddr4)) + ")";
			conn.ExecuteNonQuery(SQL);

			SQL = "update dmt_tran set mod_dmt='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
			conn.ExecuteNonQuery(SQL);
		}

		break;
	case "DI1":
		string DI1_mod_dmt_ncname1 = move_file( Request["ttg3_mod_dmt_ncname1"], "-O1",Request["old_file_ttg3_1"]);
		string DI1_mod_dmt_ncname2 = move_file( Request["ttg3_mod_dmt_ncname2"], "-O2",Request["old_file_ttg3_2"]);
		string DI1_mod_dmt_nename1 = move_file( Request["ttg3_mod_dmt_nename1"], "-O3",Request["old_file_ttg3_3"]);
		string DI1_mod_dmt_nename2 = move_file( Request["ttg3_mod_dmt_nename2"], "-O4",Request["old_file_ttg3_4"]);
		string DI1_mod_dmt_ncrep = move_file( Request["ttg3_mod_dmt_ncrep"], "-O5",Request["old_file_ttg3_5"]);
		string DI1_mod_dmt_nerep = move_file( Request["ttg3_mod_dmt_nerep"], "-O6",Request["old_file_ttg3_6"]);
		string DI1_mod_dmt_neaddr1 = move_file( Request["ttg3_mod_dmt_neaddr1"], "-O7",Request["old_file_ttg3_7"]);
		string DI1_mod_dmt_neaddr2 = move_file( Request["ttg3_mod_dmt_neaddr2"], "-O8",Request["old_file_ttg3_8"]);
		string DI1_mod_dmt_neaddr3 = move_file( Request["ttg3_mod_dmt_neaddr3"], "-O9",Request["old_file_ttg3_9"]);
		string DI1_mod_dmt_neaddr4 = move_file( Request["ttg3_mod_dmt_neaddr4"], "-O10",Request["old_file_ttg3_10"]);

		ColMap.Clear();
		foreach (var key in Request.Form.Keys) {
			string colkey = key.ToString().ToLower();
			string colValue = Request[colkey];

			//取1~4碼
			if (colkey.Left(4) == "tfz3") {
				ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
			}
		}
		ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
		ColMap["in_scode"] = Util.dbchar(in_scode);
		ColMap["in_no"] = Util.dbchar(Request["in_no"]);
		ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
		ColMap["tr_scode"] = "'" + Session["scode"] + "'";
		ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
		SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
		conn.ExecuteNonQuery(SQL);

		//*****變更被申請撤銷人資料
		if (Convert.ToInt32("0" + Request["DI1_apnum"]) > 0) {
			for (int k = 1; k <= Convert.ToInt32("0" + Request["DI1_apnum"]); k++) {
				SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,ncrep,nzip,naddr1,naddr2) values (";
				SQL += "'" + in_scode + "'," + Util.dbchar(Request["in_no"]) + ",'mod_ap'";
				SQL += "," + Util.dbchar(Request["ttg3_mod_ap_ncname1_" + k]) + "," + Util.dbchar(Request["ttg3_mod_ap_ncname2_" + k]) + "";
				SQL += "," + Util.dbchar(Request["ttg3_mod_ap_ncrep_" + k]) + "," + Util.dbchar(Request["ttg3_mod_ap_nzip_" + k]) + "";
				SQL += "," + Util.dbchar(Request["ttg3_mod_ap_naddr1_" + k]) + "," + Util.dbchar(Request["ttg3_mod_ap_naddr2_" + k]) + ")";
				conn.ExecuteNonQuery(SQL);
			}
			SQL = "update dmt_tran set mod_ap='Y' where in_scode='" + in_scode + "' and in_no = '" + Request["in_no"] + "'";
			conn.ExecuteNonQuery(SQL);
		}

		//*****廢止聲明
		if ((Request["ttg31_mod_pul_new_no"] ?? "") != "" || (Request["ttg31_mod_pul_ncname1"] ?? "") != ""
		|| (Request["ttg31_mod_pul_mod_type"] ?? "") != "") {
			ColMap.Clear();
			ColMap["in_scode"] = Util.dbchar(in_scode);
			ColMap["in_no"] = Util.dbchar(Request["in_no"]);
			ColMap["mod_field"] = "'mod_pul'";

			string[] field = { "mod_type", "new_no", "ncname1" };
			foreach (string f in field) {
				ColMap[f] = Util.dbnull(Request["ttg31_mod_pul_" + f]);
			}

			SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);

			SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
			conn.ExecuteNonQuery(SQL);
		}

		if ((Request["ttg32_mod_pul_mod_type"] ?? "") != "") {
			ColMap.Clear();
			ColMap["in_scode"] = Util.dbchar(in_scode);
			ColMap["in_no"] = Util.dbchar(Request["in_no"]);
			ColMap["mod_field"] = "'mod_pul'";

			string[] field = { "mod_type" };
			foreach (string f in field) {
				ColMap[f] = Util.dbnull(Request["ttg32_mod_pul_" + f]);
			}
			SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);

			SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"]  + "'";
			conn.ExecuteNonQuery(SQL);
		}

		if ((Request["ttg33_mod_pul_new_no"] ?? "") != "" || (Request["ttg33_mod_pul_mod_dclass"] ?? "") != ""
		|| (Request["ttg33_mod_pul_mod_type"] ?? "") != "") {
			ColMap.Clear();
			ColMap["in_scode"] = Util.dbchar(in_scode);
			ColMap["in_no"] = Util.dbchar(Request["in_no"]);
			ColMap["mod_field"] = "'mod_pul'";

			string[] field = { "mod_type", "new_no", "mod_dclass" };
			foreach (string f in field) {
				ColMap[f] = Util.dbnull(Request["ttg33_mod_pul_" + f]);
			}

			SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);

			SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
			conn.ExecuteNonQuery(SQL);
		}

		if ((Request["ttg34_mod_pul_new_no"] ?? "") != "" || (Request["ttg34_mod_pul_mod_dclass"] ?? "") != ""
		|| (Request["ttg34_mod_pul_ncname1"] ?? "") != "" || (Request["ttg34_mod_pul_mod_type"] ?? "") != "") {
			ColMap.Clear();
			ColMap["in_scode"] = Util.dbchar(in_scode);
			ColMap["in_no"] = Util.dbchar(Request["in_no"]);
			ColMap["mod_field"] = "'mod_pul'";

			string[] field = { "mod_type", "new_no", "mod_dclass", "ncname1" };
			foreach (string f in field) {
				ColMap[f] = Util.dbnull(Request["ttg34_mod_pul_" + f]);
			}

			SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);

			SQL = "update dmt_tran set mod_pul='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
			conn.ExecuteNonQuery(SQL);
		}

		//據以異議商標/標章
		if (Convert.ToInt32("0" + Request["ttg3_mod_aprep_mod_count"]) > 0) {
			for (int i = 1; i <= Convert.ToInt32("0" + Request["ttg3_mod_aprep_mod_count"]); i++) {
				SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,mod_count,ncname1,new_no) values (";
				SQL += "'" + in_scode + "'," + Util.dbchar(Request["in_no"]) + ",'mod_aprep'";
				SQL += "," + Util.dbnull(Request["ttg3_mod_aprep_mod_count"]) + "," + Util.dbchar(Request["ttg3_mod_aprep_ncname1_" + i]) + "";
				SQL += "," + Util.dbchar(Request["ttg3_mod_aprep_new_no_" + i]) + ")";
				conn.ExecuteNonQuery(SQL);
			}
			SQL = "update dmt_tran set mod_aprep='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
			conn.ExecuteNonQuery(SQL);
		}

		//變換撤銷商標圖樣
		if ((Request["ttg3_mod_dmt_ncname1"] ?? "") != "" || (Request["ttg3_mod_dmt_ncname2"] ?? "") != ""
		|| (Request["ttg3_mod_dmt_nename1"] ?? "") != "" || (Request["ttg3_mod_dmt_nename2"] ?? "") != ""
		|| (Request["ttg3_mod_dmt_ncrep"] ?? "") != "" || (Request["ttg3_mod_dmt_nerep"] ?? "") != ""
		|| (Request["ttg3_mod_dmt_neaddr1"] ?? "") != "" || (Request["ttg3_mod_dmt_neaddr2"] ?? "") != ""
		|| (Request["ttg3_mod_dmt_neaddr3"] ?? "") != "" || (Request["ttg3_mod_dmt_neaddr4"] ?? "") != ""
		) {
			SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4)";
			SQL += "VALUES('" + Request["in_scode"] + "'," + Util.dbchar(Request["in_no"]) + ",'mod_dmt'";
			SQL += "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_ncname1)) + "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_ncname2));
			SQL += "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_nename1)) + "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_nename2));
			SQL += "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_ncrep)) + "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_nerep));
			SQL += "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_neaddr1)) + "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_neaddr2));
			SQL += "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_neaddr3)) + "," + Util.dbnull(Sys.Path2Btbrt(DI1_mod_dmt_neaddr4)) + ")";
			conn.ExecuteNonQuery(SQL);

			SQL = "update dmt_tran set mod_dmt='Y' where in_scode='" + Request["in_scode"] + "' and in_no = '" + Request["in_no"] + "'";
			conn.ExecuteNonQuery(SQL);
		}

		break;
	default:
		//寫入商品類別檔(casedmt_good)
		insert_casedmt_good(conn);

		if ((Request["tfy_arcase"] ?? "").Left(3) == "DE1") {
			SQL = "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tran_mark,tr_date,tr_scode,seq,seq1)";
			SQL += " values ('" + Request["F_tscode"] + "'," + Util.dbchar(Request["in_no"]) + "," + Util.dbchar(Request["fr4_other_item"]) + "";
			SQL += "," + Util.dbchar(Request["fr4_other_item1"]) + "," + Util.dbchar(Request["fr4_other_item2"]) + "";
			SQL += "," + Util.dbchar(Request["fr4_tran_remark1"]) + "," + Util.dbchar(Request["fr4_tran_mark"]) + "";
			SQL += ",'" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "'";
			SQL += Util.dbnull(Request["tfzb_seq"]) + "," + Util.dbchar(Request["tfzb_seq1"]) + ")";
			conn.ExecuteNonQuery(SQL);
			//新增對照當事人資料
			for (int k = 1; k <= Convert.ToInt32("0" + Request["de1_apnum"]); k++) {
				SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,naddr1) values (";
				SQL += "'" + Request["F_tscode"] + "'," + Util.dbchar(Request["in_no"]) + ",'mod_client'";
				SQL += "," + Util.dbchar(Request["tfr4_ncname1_" + k]) + "," + Util.dbchar(Request["tfr4_naddr1_" + k]) + ")";
				conn.ExecuteNonQuery(SQL);
			}
		} else if ((Request["tfy_arcase"] ?? "").Left(3) == "DE2") {
			SQL = "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tr_date,tr_scode,seq,seq1)";
			SQL += " values ('" + Request["F_tscode"] + "'," + Util.dbchar(Request["in_no"]) + "," + Util.dbchar(Request["fr4_other_item"]) + ",";
			SQL += "" + Util.dbchar(Request["fr4_other_item1"]) + "," + Util.dbchar(Request["fr4_other_item2"]) + ",";
			SQL += "" + Util.dbchar(Request["fr4_tran_remark1"]) + ",'" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "',";
			SQL += Util.dbnull(Request["tfzb_seq"]) + "," + Util.dbchar(Request["tfzb_seq1"]) + ")";
			conn.ExecuteNonQuery(SQL);
		} else {
			SQL = "INSERT INTO dmt_tran(in_scode,in_no,tran_remark1,tr_date,tr_scode,seq,seq1,agt_no1)";
			SQL += " values ('" + Request["F_tscode"] + "'," + Util.dbchar(Request["in_no"]) + "," + Util.dbchar(Request["tfg1_tran_remark1"]) + "";
			SQL += ",'" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "',";
			SQL += Util.dbnull(Request["tfzb_seq"]) + "," + Util.dbchar(Request["tfzb_seq1"]) + "," + Util.dbnull(Request["tfg1_agt_no1"]) + ")";
			conn.ExecuteNonQuery(SQL);
		}
	
		break;
	}

	'申請人入log_table
	'call insert_log_table(cnn,"U",tprgid,"dmt_temp_ap","in_no;case_sqlno",trim(request("in_no"))&";0")
//寫入交辦申請人檔(dmt_temp_ap)
insert_dmt_temp_ap(conn,"0");

//*****文件上傳
Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"]??""));

//更新營洽官收確認紀錄檔(grconf_dmt.job_no)
upd_grconf_job_no(conn);

//當程序有修改復案或結案註記時通知營洽人員
chk_end_back();

End sub '---- doUpdateDB() ----
%>