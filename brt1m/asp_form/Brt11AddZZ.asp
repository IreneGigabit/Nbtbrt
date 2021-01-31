<% 
Sub doUpdateDB(tno,tscode) 
dim RS
'SET inforcon = SERVER.CreateObject("ADODB.connecTION")	
Set RS = Server.Createobject("ADODB.recordset")
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

insert_dmt_temp_ap("0");
 
'改寫法	 
'dmt_tran入log
Sys.insert_log_table(conn, "U", prgid, "dmt_tran", "in_no;in_scode", Request["in_no"] + ";" + Request["in_scode"], "");

if ((Request["tfy_arcase"] ?? "").Left(3) == "AD7") {
	SQL = "UPDATE dmt_tran set ";
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
	SQL +=ColMap.GetUpdateSQL();
	SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
	conn.ExecuteNonQuery(SQL);

	//新增對照當事人資料
	for (int k = 1; k <= Convert.ToInt32("0" + Request["de1_apnum"]); k++) {
		SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,naddr1) values (";
		SQL += "'" + Request["in_scode"] + "'," + Util.dbchar(Request["in_no"]) + ",'mod_client'";
		SQL += "," + Util.dbchar(Request["tfr4_ncname1_" + k]);
		SQL += "," + Util.dbchar(Request["tfr4_naddr1_" + k]) + ")";
		conn.ExecuteNonQuery(SQL);
	}
        } else if ((Request["tfy_arcase"] ?? "").Left(3) == "AD8") {
			SQL = "UPDATE dmt_tran set ";
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
			SQL +=ColMap.GetUpdateSQL();
            SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
            conn.ExecuteNonQuery(SQL);
        } else if ((Request["tfy_arcase"] ?? "").Left(3) == "FOF") {
 			SQL = "UPDATE dmt_tran set ";
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
			SQL +=ColMap.GetUpdateSQL();
            SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
            conn.ExecuteNonQuery(SQL);
        } else if ((Request["tfy_arcase"] ?? "").Left(3) == "FB7") {
  			SQL = "UPDATE dmt_tran set ";
           ColMap.Clear();
            ColMap["agt_no1"] = Util.dbchar(Request["tfb7_agt_no1"]);
            ColMap["other_item"] = Util.dbchar(Request["tfb7_other_item"]);
            ColMap["tr_date"] = "getdate()";
            ColMap["tr_scode"] = "'" + Session["scode"] + "'";
            ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
            ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
			SQL +=ColMap.GetUpdateSQL();
            SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
            conn.ExecuteNonQuery(SQL);
        } else if ((Request["tfy_arcase"] ?? "").Left(3) == "FW1") {
  			SQL = "UPDATE dmt_tran set ";
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
			SQL +=ColMap.GetUpdateSQL();
            SQL += " where in_scode = '" + Request["in_scode"] + "' and in_no = '" + Request["In_no"] + "'";
            conn.ExecuteNonQuery(SQL);
        } else {
   			SQL = "UPDATE dmt_tran set ";
           ColMap.Clear();
            foreach (var key in Request.Form.Keys) {
                string colkey = key.ToString().ToLower();
                string colValue = Request[colkey];

                //取2~4碼
                if (colkey.Left(4).Substring(1) == "fg1") {
                    ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
                }
            }

            ColMap["tr_date"] = "getdate()";
            ColMap["tr_scode"] = "'" + Session["scode"] + "'";
            ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
			SQL +=ColMap.GetUpdateSQL();
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

Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

update_todo();

update_dmt();

update_in_scode();

insert_rec_log();
 	     
End sub '---- doUpdateDB() ----%>
