<% 
Sub doUpdateDB(tno,tscode) 
'SET inforcon = SERVER.CreateObject("ADODB.connecTION")	
'inforcon.Open session("sinbrt")
conn.BeginTrans
'inforcon.BeginTrans	
tran_sqlno = ""
ixi = 0
intflg="N"

log_table();

update_case_dmt();

upd_grconf_job_no();

update_dmt_temp();

insert_casedmt_good();

insert_casedmt_show("0");

        string Num = "";
        if ((Request["tfy_arcase"] ?? "").Left(3).IN("FC9,FC1,FC5,FC7,FCA,FCB,FCF,FCH")) {
            Num = "1";
        } else if ((Request["tfy_arcase"] ?? "").Left(3).IN("FC2,FC0,FC6,FC8,FCC,FCD,FCG,FCI")) {
            Num = "2";
        } else if ((Request["tfy_arcase"] ?? "").Left(3).IN("FC3")) {
            Num = "3";
        } else if ((Request["tfy_arcase"] ?? "").Left(3).IN("FC4")) {
            Num = "4";
        }

//商標案件異動檔	  
	//dmt_tran入log
	Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], ""); 	  

SQL = "UPDATE dmt_tran set ";
	        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取2~5碼(直接用substr若欄位名稱太短會壞掉)
            if (colkey.Left(4).Substring(1) == "fg" + Num) {
                if (colkey.Left(1) == "d") {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                } else if (colkey.Left(1) == "n") {
                    ColMap[colkey.Substring(5)] = Util.dbzero(colValue);
                } else {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                }
            }
        }

          if ((Request["tfy_arcase"] ?? "").IN("FC21,FC6,FC8,FCI")) {
            if ((Request["O_item211"] ?? "") != "" || (Request["O_item221"] ?? "") != "") {
                ColMap["other_item"] = Util.dbchar(Request["O_item211"] + ";" + Request["O_item221"] + ";" + Request["O_item231"]);
            }
            if ((Request["tfop1_oitem1"] ?? "") == "Y") {
                ColMap["other_item1"] = Util.dbchar("Y," + Request["tfop1_oitem1c"]);
            }
            if ((Request["tfop1_oitem2"] ?? "") == "Y") {
                ColMap["other_item2"] = Util.dbchar("Y," + Request["tfop1_oitem2c"]);
            }
        } else if ((Request["tfy_arcase"] ?? "").IN("FC2,FC20,FC0,FCC,FCD,FCG")) {
            if ((Request["O_item21"] ?? "") != "" || (Request["O_item22"] ?? "") != "") {
                ColMap["other_item"] = Util.dbchar(Request["O_item21"] + ";" + Request["O_item22"] + ";" + Request["O_item23"]);
            }
            if ((Request["tfop_oitem1"] ?? "") == "Y") {
                ColMap["other_item1"] = Util.dbchar("Y," + Request["tfop_oitem1c"]);
            }
            if ((Request["tfop_oitem2"] ?? "") == "Y") {
                ColMap["other_item2"] = Util.dbchar("Y," + Request["tfop_oitem2c"]);
            } else {
                ColMap["other_item2"] = "null";
            }
        } else if ((Request["tfy_arcase"] ?? "").IN("FC3")) {
            if ((Request["O_item31"] ?? "") != "" || (Request["O_item32"] ?? "") != "") {
                ColMap["other_item"] = Util.dbchar(Request["O_item31"] + ";" + Request["O_item32"] + ";" + Request["O_item33"]);
            }
        }
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        SQL += ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
        conn.ExecuteNonQuery(SQL);

        string in_scode = Request["F_tscode"] ?? "";

        if ((Request["tfy_arcase"] ?? "").IN("FC1,FC10,FC11,FC5,FC7,FC9,FCA,FCB,FCF,FCH")) {
            //*****變更申請人(原申請人)(apcust_FC_RE1_form)
            if ((Request["tfg1_mod_ap"] ?? "") == "Y") {
                for (int k = 1; k <= Convert.ToInt32("0" + Request["FC1_apnum"]); k++) {
                    SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,old_no,ocname1,ocname2,oename1,oename2) values (";
                    SQL += "'" + in_scode + "'," + Util.dbchar(Request["In_no"]) + ",'mod_ap'";
                    SQL += "," + Util.dbchar(Request["tft1_old_no_" + k]) + "," + Util.dbchar(Request["tft1_ocname1_" + k]) + "";
                    SQL += "," + Util.dbchar(Request["tft1_ocname2_" + k]) + "," + Util.dbchar(Request["tft1_oename1_" + k]) + "";
                    SQL += "," + Util.dbchar(Request["tft1_oename2_" + k]) + ")";
                    conn.ExecuteNonQuery(SQL);
                }
            }
            //*****變更註冊申請案號數
            if ((Request["tfy_arcase"] ?? "").IN("FC1,FC10,FC9,FCA,FCB,FCF")) {
                for (int k = 1; k <= Convert.ToInt32("0" + Request["tft1_mod_count11"]); k++) {
                    SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,mod_count,new_no,ncname1) values (";
                    SQL += "'" + in_scode + "'," + Util.dbchar(Request["In_no"]) + ",'mod_tcnref'";
                    SQL += "," + Util.dbchar(Request["tft1_mod_count11"]) + "," + Util.dbchar(Request["new_no1" + k]) + "";
                    SQL += "," + Util.dbchar(Request["ncname11" + k]) + ")";
                    conn.ExecuteNonQuery(SQL);
                }
            }
            //*****增加代理人	 
            if ((Request["tfy_arcase"] ?? "") == "FCA") {
                SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,new_no) values (";
                SQL += "'" + in_scode + "'," + Util.dbchar(Request["In_no"]) + ",'mod_agt'";
                SQL += "," + Util.dbchar(Request["FC1_add_agt_no"]) + ")";
                conn.ExecuteNonQuery(SQL);
            }
        } else if ((Request["tfy_arcase"] ?? "").IN("FC2,FC20,FC21,FC0,FC6,FC8,FCC,FCD,FCG,FCI")) {
            //*****變更申請人
            if ((Request["tfg2_mod_ap"] ?? "") != "NNN") {
                for (int i = 1; i <= Convert.ToInt32("0" + Request["FC0_apnum"]); i++) {
					SQL = "insert into dmt_tranlist ";
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                    ColMap["mod_field"] = "'mod_ap'";
                    ColMap["new_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
                    if ((Request["tfg2_mod_ap"] ?? "").Substring(1, 1) == "Y") {
                        ColMap["ncname1"] = Util.dbchar(Request["dbmn_ncname1_" + i]);
                        ColMap["ncname2"] = Util.dbchar(Request["dbmn_ncname2_" + i]);
                    }
                    if ((Request["tfg2_mod_ap"] ?? "").Substring(2, 1) == "Y") {
                        ColMap["nename1"] = Util.dbchar(Request["dbmn_nename1_" + i]);
                        ColMap["nename2"] = Util.dbchar(Request["dbmn_nename2_" + i]);
                    }
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }

            //*****變更申請人地址
            if ((Request["tfg2_mod_apaddr"] ?? "") != "NN") {
                for (int i = 1; i <= Convert.ToInt32("0" + Request["FC0_apnum"]); i++) {
 					SQL = "insert into dmt_tranlist ";
                   ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                    ColMap["mod_field"] = "'mod_apaddr'";
                    ColMap["new_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
                    if ((Request["tfg2_mod_apaddr"] ?? "").Substring(0, 1) == "Y") {
                        ColMap["nzip"] = Util.dbchar(Request["dbmn_nzip_" + i]);
                        ColMap["naddr1"] = Util.dbchar(Request["dbmn_naddr1_" + i]);
                        ColMap["naddr2"] = Util.dbchar(Request["dbmn_naddr2_" + i]);
                    }
                    if ((Request["tfg2_mod_apaddr"] ?? "").Substring(1, 1) == "Y") {
                        ColMap["neaddr1"] = Util.dbchar(Request["dbmn_neaddr1_" + i]);
                        ColMap["neaddr2"] = Util.dbchar(Request["dbmn_neaddr2_" + i]);
                        ColMap["neaddr3"] = Util.dbchar(Request["dbmn_neaddr3_" + i]);
                        ColMap["neaddr4"] = Util.dbchar(Request["dbmn_neaddr4_" + i]);
                    }
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }
            //*****變更代表人
            if ((Request["tfg2_mod_aprep"] ?? "") != "NN") {
                for (int i = 1; i <= Convert.ToInt32("0" + Request["FC0_apnum"]); i++) {
 					SQL = "insert into dmt_tranlist ";
                    ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                    ColMap["mod_field"] = "'mod_aprep'";
                    ColMap["new_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
                    if ((Request["tfg2_mod_aprep"] ?? "").Substring(0, 1) == "Y") {
                        ColMap["ncrep"] = Util.dbchar(Request["dbmn_ncrep_" + i]);
                    }
                    if ((Request["tfg2_mod_aprep"] ?? "").Substring(1, 1) == "Y") {
                        ColMap["nerep"] = Util.dbchar(Request["dbmn_nerep_" + i]);
                    }
                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }
		
			//*****其他變更事項1
            if ((Request["tfg2_mod_dmt"] ?? "") == "Y") {
  					SQL = "insert into dmt_tranlist ";
               ColMap.Clear();
                ColMap["in_scode"] = Util.dbchar(in_scode);
                ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                ColMap["mod_field"] = "'mod_dmt'";
                if ((Request["tfy_arcase"] ?? "").IN("FC21,FC6,FC8,FCI")) {
                    ColMap["ncname1"] = Util.dbchar(Request["ttg21_ncname1"]);
                } else {
                    ColMap["ncname1"] = Util.dbchar(Request["ttg2_ncname1"]);
                }
                    SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }

            //*****其他變更事項2
            if ((Request["tfg2_mod_claim1"] ?? "") == "Y") {
   					SQL = "insert into dmt_tranlist ";
               ColMap.Clear();
                ColMap["in_scode"] = Util.dbchar(in_scode);
                ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                ColMap["mod_field"] = "'mod_claim1'";
                if ((Request["tfy_arcase"] ?? "").IN("FC21,FC6,FC8,FCI")) {
                    ColMap["ncname1"] = Util.dbchar(Request["ttg21_ncname2"]);
                } else {
                    ColMap["ncname1"] = Util.dbchar(Request["ttg2_ncname2"]);
                }
                    SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }

            //*****變更註冊申請案號數
            if ((Request["tfy_arcase"] ?? "").IN("FC2,FC20,FC0,FCC,FCD,FCG")) {
                if ((Request["tft2_mod_count2"] ?? "") != "") {
    					SQL = "insert into dmt_tranlist ";
                   ColMap.Clear();
                    ColMap["in_scode"] = Util.dbchar(in_scode);
                    ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                    ColMap["mod_field"] = "'mod_tcnref'";
                    ColMap["mod_count"] = Util.dbchar(Request["tft2_mod_count2"]);
                    ColMap["new_no"] = Util.dbchar(Request["new_no21"]);
                    ColMap["ncname1"] = Util.dbchar(Request["ncname121"]);

                    SQL += ColMap.GetInsertSQL();
                    conn.ExecuteNonQuery(SQL);
                }
            }

			            //'*****變更註冊申請案號數
            for (int j = 1; j <= 5; j++) {
                if ((Request["tft2_mod_count2" + j] ?? "") != "") {
                    for (int i = 1; i <= Convert.ToInt32("0" + Request["tft2_mod_count2" + j]); i++) {
      					SQL = "insert into dmt_tranlist ";
                      ColMap.Clear();
                        ColMap["in_scode"] = Util.dbchar(in_scode);
                        ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                        ColMap["mod_field"] = "'mod_tcnref'";
                        ColMap["mod_type"] = Util.dbchar(Request["tft2_mod_type_" + j]);
                        ColMap["mod_count"] = Util.dbchar(Request["tft2_mod_count2_" + j]);
                        ColMap["new_no"] = Util.dbchar(Request["new_no2_" + j + "_" + i]);
                        ColMap["ncname1"] = Util.dbchar(Request["ncname12_" + j + "_" + i]);
                    SQL += ColMap.GetInsertSQL();
                        conn.ExecuteNonQuery(SQL);
                    }
                }
            }

			            //*****新增代理人
            if ((Request["tfy_arcase"] ?? "") == "FCC") {
      					SQL = "insert into dmt_tranlist ";
                ColMap.Clear();
                ColMap["in_scode"] = Util.dbchar(in_scode);
                ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                ColMap["mod_field"] = "'mod_agt'";
                ColMap["new_no"] = Util.dbchar(Request["FC2_add_agt_no"]);
                    SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        } else if ((Request["tfy_arcase"] ?? "").IN("FC3")) {

			            //*****擬減縮商品(服務名稱)
            if ((Request["tfg3_mod_class"] ?? "") == "Y") {
                for (int i = 1; i <= Convert.ToInt32("0" + Request["tft3_class_count1"]); i++) {
                    if ((Request["class31_" + i] ?? "") != "") {
       					SQL = "insert into dmt_tranlist ";
                       ColMap.Clear();
                        ColMap["in_scode"] = Util.dbchar(in_scode);
                        ColMap["in_no"] = Util.dbchar(Request["In_no"]);
                        ColMap["mod_field"] = "'mod_class'";
                        ColMap["mod_type"] = Util.dbchar(Request["tft3_mod_type"]);
                        ColMap["mod_dclass"] = Util.dbchar(Request["tft3_class1"]);
                        ColMap["mod_count"] = Util.dbchar(Request["tft3_class_count1"]);
                        ColMap["new_no"] = Util.dbchar(Request["class31_" + i]);
                        ColMap["list_remark"] = Util.dbchar(Request["good_name31_" + i]);
                    SQL += ColMap.GetInsertSQL();
                        conn.ExecuteNonQuery(SQL);
                    }
                }
            }
        } else if ((Request["tfy_arcase"] ?? "").IN("FC4")) {
            //*****變更註冊申請案號數
            for (int k = 1; k <= Convert.ToInt32("0" + Request["tft4_mod_count41"]); k++) {
                SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_count,new_no,ncname1) values (";
                SQL += "'" + in_scode + "','" + Request["in_no"] + "','mod_tcnref'";
                SQL += "," + Util.dbchar(Request["tft4_mod_type"]) + "," + Util.dbchar(Request["tft4_mod_count41"]) + "";
                SQL += "," + Util.dbchar(Request["new_no41_" + k]) + "," + Util.dbchar(Request["ncname141_" + k]) + ")";
                conn.ExecuteNonQuery(SQL);
            }
	}

Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));
	   
update_todo();

update_dmt();

update_in_scode();

insert_rec_log();

End sub '---- doUpdateDB() ----%>
