<% 
Sub doUpdateDB1(tno,tscode)
//�ӫ~�Jlog_table
Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");
SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
conn.ExecuteNonQuery(SQL);

//�i���u���v�Jlog_table
Sys.insert_log_table(conn, "U", prgid, "casedmt_show", "in_no;case_sqlno", Request["in_no"]+";0", "");
SQL = "delete from casedmt_show where in_no='" + Request["in_no"] + "' and case_sqlno=0";
conn.ExecuteNonQuery(SQL);

//dmt_tran�Jlog_table
Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");

update_case_dmt();

update_dmt_temp();

insert_casedmt_good();

insert_casedmt_show("0");
		

        //***������
        SQL = "UPDATE dmt_tran set ";
        ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //��2~4�X
            if (colkey.Left(4).Substring(1) == "fgd" || colkey.Left(4).Substring(1) == "fg3" || colkey.Left(4).Substring(1) == "fg2") {
                if (colkey.Left(1) == "d") {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                } else {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                }
            }
        }
        if ((Request["O_item1"] ?? "") != "" || (Request["O_item2"] ?? "") != "" || (Request["O_item21"] ?? "") != "") {//����
            ColMap["other_item1"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"] + ";" + Request["O_item21"]);
        }
        if ((Request["O_item3"] ?? "") != "" || (Request["O_item31"] ?? "") != "") {//�ӽХ���
            ColMap["other_item2"] = Util.dbchar(Request["O_item3"] + ";" + Request["O_item31"]);
        }
        if ((Request["O_item4"] ?? "") != "" || (Request["O_item41"] ?? "") != "") {//���w���O
            ColMap["other_item"] = Util.dbchar(Request["O_item4"] + ";" + Request["O_item41"]);
        }
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetUpdateSQL();
        SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
        conn.ExecuteNonQuery(SQL);
	
//�ӽФH�Jdmt_temp_ap_log
Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no;case_sqlno", Request["in_no"]+";0", "");
SQL = "delete from dmt_temp_ap where in_no='" + Request["in_no"] + "' and case_sqlno=0";
conn.ExecuteNonQuery(SQL);
insert_dmt_temp_ap("0");	

Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

upd_grconf_job_no();

End sub '---- doUpdateDB1() ----%>
