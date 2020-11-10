<%
Sub doUpdateDB()

set RS=Server.CreateObject("ADODB.recordset")
set RSinfo=Server.CreateObject("ADODB.recordset")
set cmd=Server.CreateObject("ADODB.command")
set cnn=Server.CreateObject("ADODB.connection")
cnn.Open session("btbrtdb")
cmd.ActiveConnection=cnn
cnn.BeginTrans	
	
'******************產生流水號

	SQLno="SELECT MAX(in_no) FROM case_dmt WHERE (LEFT(in_no, 4) = YEAR(GETDATE()))"

	//寫入case_dmt
	insert_case_dmt(conn, RSno);

	//寫入dmt_temp
	insert_dmt_temp(conn, RSno);

	//寫入接洽費用檔
	insert_caseitem_dmt(conn, RSno);

	//***異動檔
	if ((Request["ar_form"] ?? "") == "A5") {//分割
		ColMap.Clear();
		switch ((Request["tfy_arcase"] ?? "").Left(3)) {
			case "FD1":
				ColMap["other_item"] = Util.dbchar(Request["O_item11"]+";"+ Request["O_item12"] + ";" + Request["O_item13"]);
				break;
			case "FD2":case "FD3": 
				ColMap["other_item"] = Util.dbchar(Request["O_item21"]+";"+ Request["O_item22"] + ";" + Request["O_item23"]);
				break;
		}
		ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
		ColMap["in_no"] = "'" + RSno + "'";
		ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
		ColMap["tr_scode"] = "'" + Session["scode"] + "'";
		ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
		ColMap["seq1"] = Util.dbnull(Request["tfzb_seq1"]);
		SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
		conn.ExecuteNonQuery(SQL);
	}
  
	//寫入商品類別檔
	insert_casedmt_good(conn, RSno);

	//****新增展覽優先權資料
	insert_casedmt_show(conn, RSno,"0");

	//寫入交辦申請人檔
	insert_dmt_temp_ap(conn, RSno,"0");	

	//*****新增文件上傳
	insert_dmt_attach(conn, RSno);

	//件數
	for (int x = 1; x <= Convert.ToInt32("0" + Request["nfy_tot_num"]); x++) {
		ColMap.Clear();
		ColMap["in_no"] = Util.dbchar(RSno);
		ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
		ColMap["seq1"] = Util.dbnull(Request["tfzb_seq1"]);
		ColMap["Cseq"] = Util.dbnull(Request["tfzb_seq"]);
		ColMap["Cseq1"] = Util.dbnull(Request["tfzb_seq1"]);
		SQL = "insert into case_dmt1 " + ColMap.GetInsertSQL();
		conn.ExecuteNonQuery(SQL);

		//抓insert後的流水號
		SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
		object objResult1 = conn.ExecuteScalar(SQL);
		string case_sqlno = objResult1.ToString();
			
        //*****新增至案件檔
        ColMap.Clear();
		if((Request["tfzb_seq"]??"")!="") ColMap["seq"] = Util.dbchar(Request["tfzb_seq"]);
		if((Request["tfzb_seq1"]??"")!="") ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
		if((Request["tfzd_S_mark"]??"")!="") ColMap["s_mark"] = Util.dbchar(Request["tfzd_S_mark"]);
		if((Request["tfzd_pul"]??"")!="") ColMap["pul"] = Util.dbchar(Request["tfzd_pul"]);
		if((Request["tfzd_Appl_name"]??"")!="") ColMap["appl_name"] = Util.dbchar(Request["tfzd_Appl_name"]);
		if((Request["tfzd_cappl_name"]??"")!="") ColMap["cappl_name"] = Util.dbchar(Request["tfzd_cappl_name"]);
		if((Request["tfzd_eappl_name"]??"")!="") ColMap["eappl_name"] = Util.dbchar(Request["tfzd_eappl_name"]);
		if((Request["tfzd_eappl_name1"]??"")!="") ColMap["eappl_name1"] = Util.dbchar(Request["tfzd_eappl_name1"]);
		if((Request["tfzd_eappl_name2"]??"")!="") ColMap["eappl_name2"] = Util.dbchar(Request["tfzd_eappl_name2"]);
		if((Request["tfzd_jappl_name"]??"")!="") ColMap["jappl_name"] = Util.dbchar(Request["tfzd_jappl_name"]);
		if((Request["tfzd_jappl_name1"]??"")!="") ColMap["jappl_name1"] = Util.dbchar(Request["tfzd_jappl_name1"]);
		if((Request["tfzd_jappl_name2"]??"")!="") ColMap["jappl_name2"] = Util.dbchar(Request["tfzd_jappl_name2"]);
		if((Request["tfzd_zappl_name1"]??"")!="") ColMap["zappl_name1"] = Util.dbchar(Request["tfzd_zappl_name1"]);
		if((Request["tfzd_zappl_name2"]??"")!="") ColMap["zappl_name2"] = Util.dbchar(Request["tfzd_zappl_name2"]);
		if((Request["tfzd_zname_type"]??"")!="") ColMap["zname_type"] = Util.dbchar(Request["tfzd_zname_type"]);
		if((Request["tfzd_oappl_name"]??"")!="") ColMap["oappl_name"] = Util.dbchar(Request["tfzd_oappl_name"]);
		if((Request["tfzd_Draw"]??"")!="") ColMap["Draw"] = Util.dbchar(Request["tfzd_Draw"]);
		if((Request["tfzd_symbol"]??"")!="") ColMap["symbol"] = Util.dbchar(Request["tfzd_symbol"]);
		if((Request["tfzd_color"]??"")!="") ColMap["color"] = Util.dbchar(Request["tfzd_color"]);
		if((Request["tfzd_agt_no"]??"")!="") ColMap["agt_no"] = Util.dbchar(Request["tfzd_agt_no"]);
		if((Request["pfzd_prior_date"]??"")!="") ColMap["prior_date"] = Util.dbchar(Request["pfzd_prior_date"]);
		if((Request["tfzd_prior_no"]??"")!="") ColMap["prior_no"] = Util.dbchar(Request["tfzd_prior_no"]);
		if((Request["tfzd_prior_country"]??"")!="") ColMap["tfzd_prior_country"] = Util.dbchar(Request["tfzd_prior_country"]);
		if((Request["tfzd_ref_no"]??"")!="") ColMap["ref_no"] = Util.dbchar(Request["tfzd_ref_no"]);
		if((Request["tfzd_ref_no1"]??"")!="") ColMap["ref_no1"] = Util.dbchar(Request["tfzd_ref_no1"]);
		if((Request["tfzb_seq"]??"")!="") ColMap["Mseq"] = Util.dbchar(Request["tfzb_seq"]);
		if((Request["tfzb_seq1"]??"")!="") ColMap["Mseq1"] = Util.dbchar(Request["tfzb_seq1"]);
 		//2014/4/15增加寫入申請日，因分割子案申請日與母案相同
		if((Request["tfzd_apply_date"]??"")!="") ColMap["apply_date"] = Util.dbchar(Request["tfzd_apply_date"]);
		switch ((Request["tfy_arcase"] ?? "").Left(3)) {
			case "FD1": 
				if((Request["FD1_class_count_"+x]??"")!=""){
					ColMap["class_type"] = Util.dbchar(Request["FD1_class_type_"+x]);
					ColMap["class_count"] = Util.dbchar(Request["FD1_class_count_"+x]);
					ColMap["class"] = Util.dbchar(Request["FD1_class_"+x]);
				}
				if((Request["FD1_Marka_"+x]??"")!=""){
					ColMap["mark"] = Util.dbchar(Request["FD1_Marka_"+x]);
				}
				//分割後子案之商標種類2
				string s_mark2="";
				switch ((Request["tfy_arcase"] ?? "").Substring(2,1)) {
					case "1":"5":"H": s_mark2="A"; break;
					case "4":"8":"C":"G": s_mark2="B"; break;
					case "3":"7":"B":"F": s_mark2="C"; break;
					case "2":"6":"A":"E": s_mark2="D"; break;
					case "I": s_mark2="E"; break;
					case "J": s_mark2="F"; break;
					case "K": s_mark2="G"; break;
					default:s_mark2="A"; break;
				}
				ColMap["s_mark2"] = Util.dbchar(s_mark2);
				break;
			case "FD2": "FD3":
				if((Request["FD2_class_count"+x]??"")!=""){
					ColMap["class_type"] = Util.dbchar(Request["FD2_class_type_"+x]);
					ColMap["class_count"] = Util.dbchar(Request["FD2_class_count_"+x]);
					ColMap["class"] = Util.dbchar(Request["FD2_class_"+x]);
				}
				if((Request["FD2_Marka_"+x]??"")!=""){
					ColMap["mark"] = Util.dbchar(Request["FD2_Marka_"+x]);
				}
				if((Request["tfzd_s_mark2"+x]??"")!=""){
					ColMap["s_mark2"] = Util.dbchar(Request["tfzd_s_mark2"]);	
				}
				break;
		}
        ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
        ColMap["in_no"] = "'" + RSno + "'";
        ColMap["in_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
        ColMap["draw_file"] = Util.dbchar(Sys.Path2Btbrt(drawFilename));
        ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
        ColMap["tr_scode"] = "'" + Session["scode"] + "'";
        ColMap["case_sqlno"] = case_sqlno;

        SQL = "insert into dmt_temp " + ColMap.GetInsertSQL();
        //Response.Write(SQL + "<HR>");
        conn.ExecuteNonQuery(SQL);

		switch ((Request["tfy_arcase"] ?? "").Left(3)) {
			case "FD1": 
				//分割子案商品類別入檔
				for (int p = 1; p <= Convert.ToInt32("0" + Request["FD1_class_count_"+x]); p++) {
					if ((Request["classa_"+x+"_" + p] ?? "") != "" || (Request["FD1_good_namea_" +x+"_" + p] ?? "") != "") {
							ColMap.Clear();
							ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
							ColMap["in_no"] = "'" + RSno + "'";
							ColMap["case_sqlno"] = "'" + case_sqlno + "'";
							ColMap["class"] = Util.dbchar(Request["classa_"+x+"_" + p]);
							ColMap["dmt_goodname"] = Util.dbchar(Request["FD1_good_namea_" +x+"_" + p]);
							ColMap["dmt_goodcount"] = Util.dbchar(Request["FD1_good_counta_" +x+"_" + p]);
							ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
							ColMap["tr_scode"] = "'" + Session["scode"] + "'";

							SQL = "insert into casedmt_good " + ColMap.GetInsertSQL();
							//Response.Write(SQL + "<HR>");
							conn.ExecuteNonQuery(SQL);
					}
				}
				//分割子案展覽優先權入檔
				//分割後案性除FA9,FAA,FAB,FAC外(因所列案性無展覽優先權)，再依母案展覽優先權資料入檔
				if((Request["tfy_div_arcase"] ?? "").Left(3)!="FA9"&&Request["tfy_div_arcase"] ?? "").Left(3)!="FAA"
				&&Request["tfy_div_arcase"] ?? "").Left(3)!="FAB"&&Request["tfy_div_arcase"] ?? "").Left(3)!="FAC"){
					insert_casedmt_show(conn, RSno,case_sqlno);
				}
				break;
			case "FD2": "FD3":
				//分割子案商品類別入檔
				for (int p = 1; p <= Convert.ToInt32("0" + Request["FD2_class_count_"+x]); p++) {
					if ((Request["classb_"+x+"_" + p] ?? "") != "" || (Request["FD2_good_nameb_" +x+"_" + p] ?? "") != "") {
							ColMap.Clear();
							ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
							ColMap["in_no"] = "'" + RSno + "'";
							ColMap["case_sqlno"] = "'" + case_sqlno + "'";
							ColMap["class"] = Util.dbchar(Request["classb_"+x+"_" + p]);
							ColMap["dmt_goodname"] = Util.dbchar(Request["FD2_good_nameb_" +x+"_" + p]);
							ColMap["dmt_goodcount"] = Util.dbchar(Request["FD2_good_countb_" +x+"_" + p]);
							ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
							ColMap["tr_scode"] = "'" + Session["scode"] + "'";

							SQL = "insert into casedmt_good " + ColMap.GetInsertSQL();
							//Response.Write(SQL + "<HR>");
							conn.ExecuteNonQuery(SQL);
					}
				}
				//分割子案展覽優先權入檔
				insert_casedmt_show(conn, RSno,case_sqlno);

				break;
		}
			//分割子案申請人入檔	
			insert_dmt_temp_ap(conn, RSno,case_sqlno);
	}

	//後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
	upd_grconf_job_no(conn, RSno);

	//更新客戶主檔最近立案日
	upd_dmt_date(conn, RSno);

	If Trim(Request.Form("chkTest"))<>Empty Then
		cnn.RollbackTrans
		Response.Write "cnn.RollbackTrans...<br>"
		Response.End
	End If
	cnn.CommitTrans
	
End sub
%>

<!--#include file="CaseForm/ShowDoneBox.inc"-->