<% 
Sub doUpdateDB(tno,tscode)
log_table();

update_case_dmt();

upd_grconf_job_no();

update_dmt_temp();

insert_casedmt_good();

insert_casedmt_show("0");
	 
insert_dmt_temp_ap("0");

        //***異動檔
        //dmt_tran入log
		Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");
        //***異動檔
        SQL = "UPDATE dmt_tran set ";
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取1~4碼
            if (colkey.Left(4) == "tfgp") {
                ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
            }
        }

        //20161006因電子送件修改備註.2欄都可存檔(用|分隔)
        if ((Request["O_item"] ?? "") != "") {
            string sqlvalue = "";
            if ((Request["O_item"] ?? "").IndexOf("1") > -1) {
                if ((Request["O_item1"] ?? "") != "" || (Request["O_item2"] ?? "") != "") {
                    sqlvalue += "1," + Request["O_item1"] + ";" + Request["O_item2"];
                }
            }
            sqlvalue += "|";
            if ((Request["O_item"] ?? "").IndexOf("Z") > -1) {
                sqlvalue += "Z;ZZ," + Request["O_item2t"];
            }
            ColMap["other_item"] = Util.dbchar(sqlvalue);
        } else {
            ColMap["other_item"] = "null";
        }

        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
        conn.ExecuteNonQuery(SQL);

        //*****異動明細
        if ((Request["tfgp_mod_dmt"] ?? "") == "Y") {//變更商標／標章名稱
             SQL = "insert into dmt_tranlist ";
           ColMap.Clear();
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
            ColMap["in_no"] = Util.dbchar(Request["In_no"]);
            ColMap["mod_field"] = "'mod_dmt'";
            ColMap["ncname1"] = Util.dbchar(Request["new_appl_name"]);
            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }

Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

update_todo();

update_dmt();

update_in_scode();

insert_rec_log();

End sub '---- doUpdateDB() ----%>
