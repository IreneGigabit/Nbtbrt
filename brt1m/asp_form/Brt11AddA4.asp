<% 
Sub doUpdateDB(tno,tscode)
log_table();

update_case_dmt();

upd_grconf_job_no();

update_dmt_temp();

insert_casedmt_good();

insert_casedmt_show("0");
	 
insert_dmt_temp_ap("0");

        //***������
        //dmt_tran�Jlog
		Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");
        //***������
        SQL = "UPDATE dmt_tran set ";
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //��1~4�X
            if (colkey.Left(4) == "tfgp") {
                ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
            }
        }

        //20161006�]�q�l�e��ק�Ƶ�.2�泣�i�s��(��|���j)
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

        //*****���ʩ���
        if ((Request["tfgp_mod_dmt"] ?? "") == "Y") {//�ܧ�ӼС��г��W��
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
