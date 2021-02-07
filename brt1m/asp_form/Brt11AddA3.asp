<% 
Sub doUpdateDB1(tno,tscode)
//商品入log_table
Sys.insert_log_table(conn, "U", prgid, "casedmt_good", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");
SQL = "delete from casedmt_good where in_no='" + Request["in_no"] + "' and in_scode='" + Request["in_scode"] + "'";
conn.ExecuteNonQuery(SQL);

//展覽優先權入log_table
Sys.insert_log_table(conn, "U", prgid, "casedmt_show", "in_no;case_sqlno", Request["in_no"]+";0", "");
SQL = "delete from casedmt_show where in_no='" + Request["in_no"] + "' and case_sqlno=0";
conn.ExecuteNonQuery(SQL);

update_case_dmt();

update_dmt_temp();

insert_casedmt_good();

insert_casedmt_show("0");

//申請人入dmt_temp_ap_log
Sys.insert_log_table(conn, "U", prgid, "dmt_temp_ap", "in_no;case_sqlno", Request["in_no"]+";0", "");
SQL = "delete from dmt_temp_ap where in_no='" + Request["in_no"] + "' and case_sqlno=0";
conn.ExecuteNonQuery(SQL);
insert_dmt_temp_ap("0");

Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

upd_grconf_job_no();

End sub '---- doUpdateDB1() ----%>

