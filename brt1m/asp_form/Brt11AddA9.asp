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

        string save1 = "";
        if ((Request["tfy_arcase"] ?? "") == "FP1") {
            save1 = "tfg1";//欄位開頭
        } else if ((Request["tfy_arcase"] ?? "") == "FP2") {
            save1 = "tfg2";
        }

        //***異動檔
         SQL = "insert into dmt_tran " ;
		 ColMap.Clear();
        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            //取1~4碼
            if (colkey.Left(4) == save1) {
                ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
            }
        }
        ColMap["other_item"] = Util.dbchar(Request["O_item1"] + ";" + Request["O_item2"]);
        if ((Request["O_item3"] ?? "") != "") {
            ColMap["other_item1"] = Util.dbchar(Request["O_item3"] + ";" + Request["O_item4"]);
        }
        ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
        ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["in_no"] = Util.dbchar(Request["in_no"]);
        ColMap["tr_date"] = "getdate()";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        SQL += ColMap.GetInsertSQL();
        conn.ExecuteNonQuery(SQL);	 

        //*****新增案件異動明細檔,關係人
        for (int i = 1; i <= Convert.ToInt32("0" + Request["ft_apnum"]); i++) {
          SQL = "insert into dmt_tranlist " ;
           ColMap.Clear();
            ColMap["in_scode"] = Util.dbchar(Request["in_scode"]);
            ColMap["in_no"] = Util.dbchar(Request["in_no"]);
            ColMap["mod_field"] = "'mod_ap'";
            ColMap["old_no"] = Util.dbchar(Request["tfr1_apcust_no_" + i]);
            ColMap["ocname1"] = Util.dbchar(Request["tfr1_ap_cname1_" + i]);
            ColMap["ocname2"] = Util.dbchar(Request["tfr1_ap_cname2_" + i]);
            ColMap["oename1"] = Util.dbchar(Request["tfr1_ap_ename1_" + i]);
            ColMap["oename2"] = Util.dbchar(Request["tfr1_ap_ename2_" + i]);
            ColMap["ocrep"] = Util.dbchar(Request["tfr1_ap_crep_" + i]);
            ColMap["oerep"] = Util.dbchar(Request["tfr1_ap_erep_" + i]);
            ColMap["ozip"] = Util.dbchar(Request["tfr1_ap_zip_" + i]);
            ColMap["oaddr1"] = Util.dbchar(Request["tfr1_ap_addr1_" + i]);
            ColMap["oaddr2"] = Util.dbchar(Request["tfr1_ap_addr2_" + i]);
            ColMap["oeaddr1"] = Util.dbchar(Request["tfr1_ap_eaddr1_" + i]);
            ColMap["oeaddr2"] = Util.dbchar(Request["tfr1_ap_eaddr2_" + i]);
            ColMap["oeaddr3"] = Util.dbchar(Request["tfr1_ap_eaddr3_" + i]);
            ColMap["oeaddr4"] = Util.dbchar(Request["tfr1_ap_eaddr4_" + i]);
            ColMap["otel0"] = Util.dbchar(Request["tfr1_apatt_tel0_" + i]);
            ColMap["otel"] = Util.dbchar(Request["tfr1_apatt_tel_" + i]);
            ColMap["otel1"] = Util.dbchar(Request["tfr1_apatt_tel1_" + i]);
            ColMap["ofax"] = Util.dbchar(Request["tfr1_apatt_fax_" + i]);
            ColMap["oapclass"] = Util.dbchar(Request["tfr1_oapclass_" + i]);
            ColMap["oap_country"] = Util.dbchar(Request["tfr1_oap_country_" + i]);
            ColMap["tran_code"] = "'N'";

            SQL += ColMap.GetInsertSQL();
            conn.ExecuteNonQuery(SQL);
        }		
  
insert_dmt_temp_ap("0");

Sys.updmt_attach_forcase(Context, conn, prgid, (Request["in_no"] ?? ""));

update_todo();

update_dmt();

update_in_scode();

insert_rec_log();

End sub '---- doUpdateDB() ----%>
