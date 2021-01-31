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

//*****移轉檔	
	//dmt_tran入log
	Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], ""); 	
	SQL = "UPDATE dmt_tran set ";
	        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取1~4碼
            if (colkey.Left(4) == "tfg1"&&colkey!="tfg1_seq") {
                ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
            }
        }
        if ((Request["O_item1"] ?? "") != "" || (Request["O_item2"] ?? "") != "") {//附註
            ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);
        }
        if ((Request["other_item2"] ?? "") != "") {
            if ((Request["other_item2t"] ?? "") != "") {
                ColMap["other_item2"] = Util.dbchar(Request["other_item2"] + "," + Request["other_item2t"]);
            } else {
                ColMap["other_item2"] = Util.dbchar(Request["other_item2"]);
            }
        }
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        SQL += ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
        conn.ExecuteNonQuery(SQL);
	
'*****新增案件異動明細檔，關係人資料
        SQL = "delete from dmt_tranlist where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "' and mod_field='mod_ap'";
        conn.ExecuteNonQuery(SQL);
        for (int i = 1; i <= Convert.ToInt32("0" + Request["fl_apnum"]); i++) {
			SQL = "insert into dmt_tranlist ";
            ColMap.Clear();
            ColMap["in_scode"] = Util.dbchar(Request["in_scode"]);
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
            ColMap["oapclass"] = Util.dbchar(Request["tfr_oapclass_" + i]);
            ColMap["oap_country"] = Util.dbchar(Request["tfr_oap_country_" + i]);
            ColMap["tran_code"] = "'N'";
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

        //*****新增案件異動明細檔	
        if ((Request["tfy_arcase"] ?? "") == "FL1" || (Request["tfy_arcase"] ?? "") == "FL5") {
            for (int x = 1; x <= Convert.ToInt32("0" + Request["num2"]); x++) {
                SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_count,mod_dclass,new_no,list_remark)";
                SQL += "VALUES('" + Request["F_tscode"] + "','" + Request["in_no"] + "','mod_class'";
                SQL += "," + Util.dbchar(Request["tfl1_mod_type"]) + "," + Util.dbchar(Request["mod_count"]);
                SQL += "," + Util.dbchar(Request["mod_dclass"]) + "," + Util.dbchar(Request["new_no_" + x]);
                SQL += "," + Util.dbchar(Request["list_remark_" + x]) + ")";
                conn.ExecuteNonQuery(SQL);
            }
        } else if ((Request["tfy_arcase"] ?? "") == "FL2" || (Request["tfy_arcase"] ?? "") == "FL6") {
            for (int x = 1; x <= Convert.ToInt32("0" + Request["num2"]); x++) {
                SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_count,mod_dclass,new_no,list_remark)";
                SQL += "VALUES('" + Request["F_tscode"] + "','" + Request["in_no"] + "','mod_class'";
                SQL += "," + Util.dbchar(Request["tfl1_mod_type"]) + "," + Util.dbchar(Request["mod_count"]);
                SQL += "," + Util.dbchar(Request["mod_dclass"]) + "," + Util.dbchar(Request["new_no_" + x]);
                SQL += "," + Util.dbchar(Request["list_remark_" + x]) + ")";
                conn.ExecuteNonQuery(SQL);
            }
            //商標權人資料
            SQL = "delete from dmt_tranlist where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "' and mod_field='mod_tap'";
            conn.ExecuteNonQuery(SQL);
            for (int i = 1; i <= Convert.ToInt32("0" + Request["fl2_apnum"]); i++) {
				SQL = "insert into dmt_tranlist ";
                ColMap.Clear();
                ColMap["in_scode"] = Util.dbchar(Request["in_scode"]);
                ColMap["in_no"] = Util.dbchar(Request["in_no"]);
                ColMap["mod_field"] = "'mod_tap'";
                ColMap["new_no"] = Util.dbchar(Request["tfv_new_no_" + i]);
                ColMap["ncname1"] = Util.dbchar(Request["tfv_ncname1_" + i]);
                ColMap["ncname2"] = Util.dbchar(Request["tfv_ncname2_" + i]);
                ColMap["nename1"] = Util.dbchar(Request["tfv_nename1_" + i]);
                ColMap["nename2"] = Util.dbchar(Request["tfv_nename2_" + i]);
                ColMap["ncrep"] = Util.dbchar(Request["tfv_ncrep_" + i]);
                ColMap["nerep"] = Util.dbchar(Request["tfv_nerep_" + i]);
                ColMap["nzip"] = Util.dbchar(Request["tfv_nzip_" + i]);
                ColMap["naddr1"] = Util.dbchar(Request["tfv_naddr1_" + i]);
                ColMap["naddr2"] = Util.dbchar(Request["tfv_naddr2_" + i]);
                ColMap["neaddr1"] = Util.dbchar(Request["tfv_neaddr1_" + i]);
                ColMap["neaddr2"] = Util.dbchar(Request["tfv_neaddr2_" + i]);
                ColMap["neaddr3"] = Util.dbchar(Request["tfv_neaddr3_" + i]);
                ColMap["neaddr4"] = Util.dbchar(Request["tfv_neaddr4_" + i]);
                ColMap["ntel0"] = Util.dbchar(Request["tfv_ntel0_" + i]);
                ColMap["ntel"] = Util.dbchar(Request["tfv_ntel_" + i]);
                ColMap["ntel1"] = Util.dbchar(Request["tfv_ntel1_" + i]);
                ColMap["nfax"] = Util.dbchar(Request["tfv_nfax_" + i]);
                ColMap["napclass"] = Util.dbchar(Request["tfv_napclass_" + i]);
                ColMap["nap_country"] = Util.dbchar(Request["tfv_nap_country_" + i]);
                ColMap["tran_code"] = "'N'";
                SQL += ColMap.GetInsertSQL();
                conn.ExecuteNonQuery(SQL);
            }
        }

insert_dmt_temp_ap("0");

Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

update_todo();
   	
update_dmt();

update_in_scode();

insert_rec_log();

End sub '---- doUpdateDB() ----%>