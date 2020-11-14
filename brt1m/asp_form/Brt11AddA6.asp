<%
sub doUpdateDB()

set RS=Server.CreateObject("ADODB.recordset")
set RSinfo=Server.CreateObject("ADODB.recordset")
set RSreg=Server.CreateObject("ADODB.recordset")
set RCreg=Server.CreateObject("ADODB.recordset")
set RBreg=Server.CreateObject("ADODB.recordset")

conn.BeginTrans	
'******************產生流水號

	SQLno="SELECT MAX(in_no) FROM case_dmt WHERE (LEFT(in_no, 4) = YEAR(GETDATE()))"

	//寫入case_dmt
	insert_case_dmt(conn, RSno);

	//重建暫存檔
	using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST")) {
		SQL="delete from dmt_temp_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and (mark is null or mark='C')";
		conn.ExecuteNonQuery(SQL);
		SQL="delete from casedmt_good_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and (mark is null or mark='C')";
		conn.ExecuteNonQuery(SQL);
		SQL="delete from casedmt_show_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and (mark is null or mark='C')";
		conn.ExecuteNonQuery(SQL);

		Datatable dt=new Datatable();
		SQL="select * from case_dmt1 where in_no= '"+RSno+"' and case_sqlno<>0 order by case_sqlno";
		conn.DataTable(SQL, dt);
		for (int i = 0; i < dt.Rows.Count; i++) {
			SQL="insert into dmt_temp_change(s_mark,s_mark2,pul,appl_name,cappl_name,eappl_name";
			SQL+=",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
			SQL+=",zappl_name2,zname_type,oappl_name,Draw,symbol,color,prior_date,prior_no ";
			SQL+=",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
			SQL+=",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
			SQL+=",end_code,dmt_term1,dmt_term2,renewal,seq,seq1,draw_file,class_type ";
			SQL+=",class_count,class ";
			SQL+=",in_scode,cust_area,cust_seq,num,tr_date,tr_scode) ";
			SQL+="Select s_mark,s_mark2 as ts_mark,pul,appl_name,cappl_name,eappl_name ";
			SQL+=",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
			SQL+=",zappl_name2,zname_type,oappl_name,Draw,symbol,color,prior_date,prior_no ";
			SQL+=",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
			SQL+=",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
			SQL+=",end_code,dmt_term1,dmt_term2,renewal,seq,seq1,draw_file,class_type ";
			SQL+=",class_count,class ";
			SQL+=",'"+Request["F_tscode"]+"','"+Request["F_cust_area"]+"','"+Request["F_cust_seq"]+"','"+(i+1)+"' ";
			SQL+=",getdate(),'" + Session["scode"] + "' ";
			SQL+="from dmt_temp where in_no='"+RSno+"' and case_sqlno="+dt.Rows[i]["case_sqlno"]+"";
			conn.ExecuteNonQuery(SQL);

			SQL = "INSERT INTO casedmt_good_change(in_scode,cust_area,cust_seq,num,class,dmt_grp_code";
			SQL+=",dmt_goodname,dmt_goodcount,tr_date,tr_scode) ";
			SQL+="select '"+Request["F_tscode"]+"','"+Request["F_cust_area"]+"','"+Request["F_cust_seq"]+"','"+(i+1)+"'";
			SQL+=",class,dmt_grp_code,dmt_goodname,dmt_goodcount,getdate(),'" + Session["scode"] + "' "
			SQL+="from casedmt_good where in_no='"+RSno+"' and case_sqlno="+dt.Rows[i]["case_sqlno"]+"";
			conn.ExecuteNonQuery(SQL);

			SQL = "INSERT INTO casedmt_show_change(in_scode,cust_area,cust_seq,num,show_no,show_date";
			SQL+=",show_name,tr_date,tr_scode) ";
			SQL+="select '"+Request["F_tscode"]+"','"+Request["F_cust_area"]+"','"+Request["F_cust_seq"]+"','"+(i+1)+"'";
			SQL+=",ROW_NUMBER() OVER(ORDER BY show_sqlno),show_date,show_name,getdate()";
			SQL+=",'" + Session["scode"] + "' "
			SQL+="from casedmt_show where in_no='"+RSno+"' and case_sqlno="+dt.Rows[i]["case_sqlno"]+" order by show_sqlno";
			conn.ExecuteNonQuery(SQL);
		}
		conn.Commit();
	}



if((Request["tfy_arcase"] ?? "")=="FC11"||(Request["tfy_arcase"] ?? "")=="FC5"||(Request["tfy_arcase"] ?? "")=="FC7"||(Request["tfy_arcase"] ?? "")=="FCH"){
		for (int i = 2; i <= Convert.ToInt32("0" + Request["nfy_tot_num"]); i++) {
			ColMap.Clear();
			ColMap["in_no"] = Util.dbchar(RSno);
			ColMap["seq"] = Util.dbnull(Request["dseqa_"+i]);
			ColMap["seq1"] = Util.dbnull(Request["dseq1a_"+i]);
			ColMap["Cseq"] = Util.dbnull(Request["dmseqa_"+i]);
			ColMap["Cseq1"] = Util.dbnull(Request["dmseq1a_"+i]);
			ColMap["case_stat1"] = ((Request["dseqa_"+i]??"")!=""?"OO":"NN");
			SQL = "insert into case_dmt1 " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);

			//抓insert後的流水號
			SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
			object objResult1 = conn.ExecuteScalar(SQL);
			string case_sqlno = objResult1.ToString();

			if((Request["dseqa_"+i]??"")==""){
				//抓圖檔
				SQL="SELECT draw_file FROM dmt_temp_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and num='"+i+"' ";
				object objResult2 = conn.ExecuteScalar(SQL);
				if (objResult2!=null){
					string draw_file = objResult2.ToString();
					//將檔案更改檔名
					string newfilename = move_file(RSno, draw_file,"-FC"+i);

					SQL="insert into dmt_temp(s_mark,s_mark2,pul,apsqlno,ap_cname,ap_cname1,ap_cname2 ";
					SQL+=",ap_ename,ap_ename1,ap_ename2,appl_name,cappl_name,eappl_name";
					SQL+=",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
					SQL+=",zappl_name2,zname_type,oappl_name,Draw,symbol,color,agt_no,prior_date,prior_no ";
					SQL+=",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
					SQL+=",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
					SQL+=",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
					SQL+=",in_scode,in_no,in_date,draw_file,tr_date,tr_scode,case_sqlno,seq1) ";
					SQL+="Select s_mark,s_mark2 as ts_mark,pul,"+Util.dbnull(Request["tfzp_apsqlno"])+" ";
					SQL+=","+Util.dbnull(Request["tfzp_ap_cname"])+","+Util.dbnull(Request["tfzp_ap_cname1"])+" ";
					SQL+=","+Util.dbnull(Request["tfzp_ap_cname2"])+","+Util.dbnull(Request["tfzp_ap_ename"])+" ";
					SQL+=","+Util.dbnull(Request["tfzp_ap_ename1"])+","+Util.dbnull(Request["tfzp_ap_ename2"])+" ";
					SQL+=",appl_name,cappl_name,eappl_name ";
					SQL+=",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
					SQL+=",zappl_name2,zname_type,oappl_name,Draw,symbol,color ";
					SQL+=","+Util.dbnull(Request["tfzd_agt_no"])+",prior_date,prior_no ";
					SQL+=",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
					SQL+=",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
					SQL+=",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
					SQL+=",'"+Request["F_tscode"]+"','"+RSno+"','"+DateTime.Today.ToShortDateString()+"','"+newfilename+"' ";
					SQL+=",'" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "',"+case_sqlno+",'"+Request["dseq1a_"+i])+"' ";
					SQL+="from dmt_temp_change where in_scode='"+Request["F_tscode"]+"' ";
					SQL+="and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' ";
					SQL+="and num='"+i+"' and mark='T'";
					conn.ExecuteNonQuery(SQL);

					//*****新增申請人檔
           			insert_dmt_temp_ap_FC2(conn, RSno, case_sqlno);
				}

				//商品類別
				SQL = "INSERT INTO casedmt_good(in_scode,in_no,case_sqlno,class,dmt_grp_code";
				SQL+=",dmt_goodname,dmt_goodcount,tr_date,tr_scode) ";
				SQL+="select '"+Request["F_tscode"]+"','"+RSno+"',"+case_sqlno+",class,dmt_grp_code,dmt_goodname,dmt_goodcount";
				SQL+=",getdate(),'" + Session["scode"] + "' "
				SQL+="from casedmt_good_change where in_scode='"+Request["F_tscode"]+"' ";
				SQL+="and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' ";
				SQL+="and num='"+i+"' and (isnull(class,'')<>'' or isnull(dmt_goodname,'')<>'')";
				conn.ExecuteNonQuery(SQL);

				//展覽會優先權
				SQL = "INSERT INTO casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) ";
				SQL+="select '"+RSno+"',"+case_sqlno+",show_date,show_name,getdate()'";
				SQL+=",'" + Session["scode"] + "' "
				SQL+="from casedmt_show_change where in_scode='"+Request["F_tscode"]+"' ";
				SQL+="and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' ";
				SQL+="and num='"+i+"' order by show_no ";
				conn.ExecuteNonQuery(SQL);
			}
		}

		//清空暫存檔
		SQL="delete from dmt_temp_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and mark is null";
		conn.ExecuteNonQuery(SQL);
		SQL="delete from casedmt_good_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and mark is null";
		conn.ExecuteNonQuery(SQL);
		SQL="delete from casedmt_show_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and mark is null";
		conn.ExecuteNonQuery(SQL);
	}else if((Request["tfy_arcase"] ?? "")=="FC21")||(Request["tfy_arcase"] ?? "")=="FC6"||(Request["tfy_arcase"] ?? "")=="FC8"||(Request["tfy_arcase"] ?? "")=="FCI"){
		for (int i = 2; i <= Convert.ToInt32("0" + Request["nfy_tot_num"]); i++) {
			ColMap.Clear();
			ColMap["in_no"] = Util.dbchar(RSno);
			ColMap["seq"] = Util.dbnull(Request["dseqb_"+i]);
			ColMap["seq1"] = Util.dbnull(Request["dseq1b_"+i]);
			ColMap["Cseq"] = Util.dbnull(Request["dseqb_"+i]);
			ColMap["Cseq1"] = Util.dbnull(Request["dseq1b_"+i]);
			ColMap["case_stat1"] = ((Request["dseqb_"+i]??"")!=""?"OO":"NN");
			SQL = "insert into case_dmt1 " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);

			//抓insert後的流水號
			SQL = "SELECT SCOPE_IDENTITY() AS Current_Identity";
			object objResult1 = conn.ExecuteScalar(SQL);
			string case_sqlno = objResult1.ToString();

			if((Request["dseqb_"+i]??"")==""){
				//抓圖檔
				SQL="SELECT draw_file FROM dmt_temp_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and num='"+i+"'";
				object objResult2 = conn.ExecuteScalar(SQL);

				if (objResult2!=null){
					string draw_file = objResult2.ToString();
					//將檔案更改檔名
					string newfilename = move_file(RSno, draw_file,"-FC"+i);

					SQL="insert into dmt_temp(s_mark,s_mark2,pul,apsqlno,ap_cname,ap_cname1,ap_cname2 ";
					SQL+=",ap_ename,ap_ename1,ap_ename2,appl_name,cappl_name,eappl_name";
					SQL+=",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
					SQL+=",zappl_name2,zname_type,oappl_name,Draw,symbol,color,agt_no,prior_date,prior_no ";
					SQL+=",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
					SQL+=",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
					SQL+=",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
					SQL+=",in_scode,in_no,in_date,draw_file,tr_date,tr_scode,case_sqlno,seq1) ";
					SQL+="Select s_mark,s_mark2 as ts_mark,pul,"+Util.dbnull(Request["tfzp_apsqlno"])+" ";
					SQL+=","+Util.dbnull(Request["tfzp_ap_cname"])+","+Util.dbnull(Request["tfzp_ap_cname1"])+" ";
					SQL+=","+Util.dbnull(Request["tfzp_ap_cname2"])+","+Util.dbnull(Request["tfzp_ap_ename"])+" ";
					SQL+=","+Util.dbnull(Request["tfzp_ap_ename1"])+","+Util.dbnull(Request["tfzp_ap_ename2"])+" ";
					SQL+=",appl_name,cappl_name,eappl_name ";
					SQL+=",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
					SQL+=",zappl_name2,zname_type,oappl_name,Draw,symbol,color ";
					SQL+=","+Util.dbnull(Request["tfzd_agt_no"])+",prior_date,prior_no ";
					SQL+=",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
					SQL+=",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
					SQL+=",end_code,dmt_term1,dmt_term2,renewal,class_type,class_count,class ";
					SQL+=",'"+Request["F_tscode"]+"','"+RSno+"','"+DateTime.Today.ToShortDateString()+"','"+newfilename+"' ";
					SQL+=",'" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "',"+case_sqlno+",'"+Request["dseq1b_"+i])+"' ";
					SQL+="from dmt_temp_change where in_scode='"+Request["F_tscode"]+"' ";
					SQL+="and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' ";
					SQL+="and num='"+i+"' ";
					conn.ExecuteNonQuery(SQL);

					//寫入交辦申請人檔
					insert_dmt_temp_ap_FC0(conn, RSno,case_sqlno);	
				}

				//商品類別
				SQL = "INSERT INTO casedmt_good(in_scode,in_no,case_sqlno,class,dmt_grp_code";
				SQL+=",dmt_goodname,dmt_goodcount,tr_date,tr_scode) ";
				SQL+="select '"+Request["F_tscode"]+"','"+RSno+"',"+case_sqlno+",class,dmt_grp_code,dmt_goodname,dmt_goodcount";
				SQL+=",getdate(),'" + Session["scode"] + "' "
				SQL+="from casedmt_good_change where in_scode='"+Request["F_tscode"]+"' ";
				SQL+="and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' ";
				SQL+="and num='"+i+"' and (isnull(class,'')<>'' or isnull(dmt_goodname,'')<>'')";
				conn.ExecuteNonQuery(SQL);

				//展覽會優先權
				SQL = "INSERT INTO casedmt_show(in_no,case_sqlno,show_date,show_name,tr_date,tr_scode) ";
				SQL+="select '"+RSno+"',"+case_sqlno+",show_date,show_name,getdate()'";
				SQL+=",'" + Session["scode"] + "' "
				SQL+="from casedmt_show_change where in_scode='"+Request["F_tscode"]+"' ";
				SQL+="and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' ";
				SQL+="and num='"+i+"' order by show_no ";
				conn.ExecuteNonQuery(SQL);
			}
		}

		//清空暫存檔
		SQL="delete from dmt_temp_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and mark is null";
		conn.ExecuteNonQuery(SQL);
		SQL="delete from casedmt_good_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and mark is null";
		conn.ExecuteNonQuery(SQL);
		SQL="delete from casedmt_show_change where in_scode='"+Request["F_tscode"]+"' and cust_area='"+Request["F_cust_area"]+"' and cust_seq='"+Request["F_cust_seq"]+"' and mark is null";
		conn.ExecuteNonQuery(SQL);
	}
	
	//寫入接洽費用檔
	insert_caseitem_dmt(conn, RSno);

	//寫入dmt_temp
	insert_dmt_temp(conn, RSno);
			
	//寫入商品類別檔
	insert_casedmt_good(conn, RSno);

	//****新增展覽優先權資料
	insert_casedmt_show(conn, RSno,"0");

	//*****新增案件變更檔
	switch ((Request["tfy_arcase"] ?? "")) {
		case "FC1":case"FC10":case"FC11":case"FC5":case"FC7":case"FC9":case"FCA":case"FCB":case"FCF":case"FCH":
			ColMap.Clear();
			foreach (var key in Request.Form.Keys) {
				string colkey = key.ToString().ToLower();
				string colValue = Request[colkey];

				//取1~4碼
				if (colkey.Left(4) == "tfg1") {
					ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
				}
			}
			ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
			ColMap["in_no"] = "'" + RSno + "'";
			ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
			ColMap["tr_scode"] = "'" + Session["scode"] + "'";
			ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
			ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
			SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);
	 
			//*****變更申請人(原申請人)(apcust_FC_RE1_form)
			if((Request["tfg1_mod_ap"]??"")=="Y"){
				for (int k = 1; k <= Convert.ToInt32("0" + Request["FC1_apnum"]); k++) {
					SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,old_no,ocname1,ocname2,oename1,oename2) values (";
					SQL+= "'" + Request["F_tscode"] + "','" + RSno + "','mod_ap'";
					SQL+= "," + Util.dbchar(Request["tft1_old_no_" + k]) + "," + Util.dbchar(Request("tft1_ocname1_"+k])  + "";
					SQL+= "," + Util.dbchar(Request["tft1_ocname2_" + k])  + "," + Util.dbchar(Request("tft1_oename1_" + k]) + "";
					SQL+= "," + Util.dbchar(Request["tft1_oename2_" + k]) + ")";
					conn.ExecuteNonQuery(SQL);
				}
				SQL="update dmt_tran set mod_ap='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}
	 
			//*****變更註冊申請案號數
            if (Array.IndexOf(new []{"FC1","FC10","FC9","FCA","FCB","FCF" },(Request["tfy_arcase"] ?? ""))>-1) {//Array.Contains
				for (int k = 1; k <= Convert.ToInt32("0" + Request["tft1_mod_count11"]); k++) {
					SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,mod_count,new_no,ncname1) values (";
					SQL+= "'" + Request["F_tscode"] + "','" + RSno + "','mod_tcnref'";
					SQL+= "," + Util.dbchar(Request["tft1_mod_count11"]) + "," + Util.dbchar(Request("new_no1"+k])  + "";
					SQL+= "," + Util.dbchar(Request["ncname11" + k])  + ")";
					conn.ExecuteNonQuery(SQL);
				}
			}
			
			//*****增加代理人	 
			if((Request["tfy_arcase"]??"")=="FCA"){
					SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,new_no) values (";
					SQL+= "'" + Request["F_tscode"] + "','" + RSno + "','mod_agt'";
					SQL+= "," + Util.dbchar(Request["FC1_add_agt_no"]) + ")";
					conn.ExecuteNonQuery(SQL);
			}

			//*****新增申請人檔
			insert_dmt_temp_ap_FC2(conn, RSno, case_sqlno);
			break;
		case "FC2":case"FC20":case"FC21":case"FC0":case"FC6":case"FC8":case"FCC":case"FCD":case"FCG":case"FCI":
			ColMap.Clear();
			foreach (var key in Request.Form.Keys) {
				string colkey = key.ToString().ToLower();
				string colValue = Request[colkey];

				//取1~4碼
				if (colkey.Left(4) == "tfg2") {
					ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
				}
			}

            if (Array.IndexOf(new []{"FC21","FC6","FCI" },(Request["tfy_arcase"] ?? ""))>-1) {//Array.Contains
				if ((Request["O_item211"] ?? "") != ""||(Request["O_item221"] ?? "") != "") {
					ColMap["other_item"] = Util.dbchar(Request["O_item211"] + ";" + Request["O_item221"]+ ";" + Request["O_item231"]);
				}
			}else{
				if ((Request["O_item21"] ?? "") != ""||(Request["O_item22"] ?? "") != "") {
					ColMap["other_item"] = Util.dbchar(Request["O_item21"] + ";" + Request["O_item22"]+ ";" + Request["O_item23"]);
				}				
			}
			//2012/7/1新申請書增加修正使用規費書及質權移轉原因
			if ((Request["tfy_arcase"] ?? "") == "FC2"){
				if ((Request["tfop_oitem1"] ?? "") == "Y"){
					ColMap["other_item1"] = Util.dbchar("Y," + Request["tfop_oitem1c"]);
				}
				if ((Request["tfop_oitem2"] ?? "") == "Y"){
					ColMap["other_item2"] = Util.dbchar("Y," + Request["tfop_oitem2c"]);
				}
			}else{
				if ((Request["tfop1_oitem1"] ?? "") == "Y"){
					ColMap["other_item1"] = Util.dbchar("Y," + Request["tfop1_oitem1c"]);
				}
				if ((Request["tfop1_oitem2"] ?? "") == "Y"){
					ColMap["other_item2"] = Util.dbchar("Y," + Request["tfop1_oitem2c"]);
				}
			}
			ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
			ColMap["in_no"] = "'" + RSno + "'";
			ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
			ColMap["tr_scode"] = "'" + Session["scode"] + "'";
			ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
			ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
			SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);

			//*****變更申請人
			if ((Request["tfg2_mod_ap"] ?? "") != ""){
				for (int i = 1; i <= Convert.ToInt32("0" + Request["FC0_apnum"]); i++) {
					ColMap.Clear();
					ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
					ColMap["in_no"] = "'" + RSno + "'";
					ColMap["mod_field"] = "'mod_ap'";
					ColMap["new_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
					if ((Request["tfg2_mod_ap"]??"").Substring(1,1) == "Y"){
						ColMap["ncname1"] = Util.dbchar(Request["dbmn_ncname1_" + i]);
						ColMap["ncname2"] = Util.dbchar(Request["dbmn_ncname2_" + i]);
					}
					if ((Request["tfg2_mod_ap"]??"").Substring(2,1) == "Y"){
						ColMap["nename1"] = Util.dbchar(Request["dbmn_nename1_" + i]);
						ColMap["nename2"] = Util.dbchar(Request["dbmn_nename2_" + i]);
					}

					SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
					conn.ExecuteNonQuery(SQL);
				}
			}

			//*****變更申請人地址
			if ((Request["tfg2_mod_apaddr"] ?? "") != ""){
				for (int i = 1; i <= Convert.ToInt32("0" + Request["FC0_apnum"]); i++) {
					ColMap.Clear();
					ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
					ColMap["in_no"] = "'" + RSno + "'";
					ColMap["mod_field"] = "'mod_apaddr'";
					ColMap["new_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
					if ((Request["tfg2_mod_apaddr"]??"").Substring(0,1) == "Y"){
						ColMap["nzip"] = Util.dbchar(Request["dbmn_nzip_" + i]);
						ColMap["naddr1"] = Util.dbchar(Request["dbmn_naddr1_" + i]);
						ColMap["naddr2"] = Util.dbchar(Request["dbmn_naddr2_" + i]);
					}
					if ((Request["tfg2_mod_apaddr"]??"").Substring(1,1) == "Y"){
						ColMap["neaddr1"] = Util.dbchar(Request["dbmn_neaddr1_" + i]);
						ColMap["neaddr2"] = Util.dbchar(Request["dbmn_neaddr2_" + i]);
						ColMap["neaddr3"] = Util.dbchar(Request["dbmn_neaddr3_" + i]);
						ColMap["neaddr4"] = Util.dbchar(Request["dbmn_neaddr4_" + i]);
					}

					SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
					conn.ExecuteNonQuery(SQL);
				}
			}

			//*****變更代表人
			if ((Request["tfg2_mod_aprep"] ?? "") != ""){
				for (int i = 1; i <= Convert.ToInt32("0" + Request["FC0_apnum"]); i++) {
					ColMap.Clear();
					ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
					ColMap["in_no"] = "'" + RSno + "'";
					ColMap["mod_field"] = "'mod_aprep'";
					ColMap["new_no"] = Util.dbchar(Request["dbmn_new_no_" + i]);
					if ((Request["tfg2_mod_aprep"]??"").Substring(0,1) == "Y"){
						ColMap["ncrep"] = Util.dbchar(Request["dbmn_ncrep_" + i]);
					}
					if ((Request["tfg2_mod_aprep"]??"").Substring(1,1) == "Y"){
						ColMap["nerep"] = Util.dbchar(Request["dbmn_nerep_" + i]);
					}

					SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
					conn.ExecuteNonQuery(SQL);
				}
			}
	
			//*****其他變更事項1
			if ((Request["tfg2_mod_dmt"] ?? "") == "Y"){
				ColMap.Clear();
				ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
				ColMap["in_no"] = "'" + RSno + "'";
				ColMap["mod_field"] = "'mod_dmt'";
				if (Array.IndexOf(new []{"FC21","FC6","FC8","FCI" },(Request["tfy_arcase"] ?? ""))>-1) {//Array.Contains
					ColMap["ncname1"] = Util.dbchar(Request["ttg21_ncname1"]);
				else{
					ColMap["ncname1"] = Util.dbchar(Request["ttg2_ncname1"]);
				}
				SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
				conn.ExecuteNonQuery(SQL);
			}


			//*****其他變更事項2
			if ((Request["tfg2_mod_claim1"] ?? "") == "Y"){
				ColMap.Clear();
				ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
				ColMap["in_no"] = "'" + RSno + "'";
				ColMap["mod_field"] = "'mod_claim1'";
				if (Array.IndexOf(new []{"FC21","FC6","FC8","FCI" },(Request["tfy_arcase"] ?? ""))>-1) {//Array.Contains
					ColMap["ncname1"] = Util.dbchar(Request["ttg21_ncname2"]);
				else{
					ColMap["ncname1"] = Util.dbchar(Request["ttg2_ncname2"]);
				}
				SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
				conn.ExecuteNonQuery(SQL);
			}

 			//*****變更註冊申請案號數
			if (Array.IndexOf(new []{"FC2","FC20","FC0","FCC","FCD","FCG" },(Request["tfy_arcase"] ?? ""))>-1) {//Array.Contains
				if ((Request["tft2_mod_count2"] ?? "") != ""){
					ColMap.Clear();
					ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
					ColMap["in_no"] = "'" + RSno + "'";
					ColMap["mod_field"] = "'mod_tcnref'";
					ColMap["mod_count"] = Util.dbchar(Request["tft2_mod_count2"]);
					ColMap["new_no"] = Util.dbchar(Request["new_no21"]);
					ColMap["ncname1"] = Util.dbchar(Request["ncname121"]);

					SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
					conn.ExecuteNonQuery(SQL);
				}
			}
	 
			//'*****變更註冊申請案號數
			for (int j = 1; j <= 5; j++) {
				if ((Request["tft2_mod_count2"+j] ?? "") != ""){
					for (int i = 1; i <= Convert.ToInt32("0" + Request["tft2_mod_count2"+j]); i++) {
						ColMap.Clear();
						ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
						ColMap["in_no"] = "'" + RSno + "'";
						ColMap["mod_field"] = "'mod_tcnref'";
						ColMap["mod_type"] = Util.dbchar(Request["tft2_mod_type_"+j]);
						ColMap["mod_count"] = Util.dbchar(Request["tft2_mod_count2_"+j]);
						ColMap["new_no"] = Util.dbchar(Request["new_no2_"+j+"_"+i]);
						ColMap["ncname1"] = Util.dbchar(Request["ncname12_"+j+"_"+i]);

						SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
						conn.ExecuteNonQuery(SQL);
					}
				}
			}		

			//*****新增代理人
			if ((Request["tfy_arcase"] ?? "")=="FCC") {
				ColMap.Clear();
				ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
				ColMap["in_no"] = "'" + RSno + "'";
				ColMap["mod_field"] = "'mod_agt'";
				ColMap["new_no"] = Util.dbchar(Request["FC2_add_agt_no"]);

				SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
				conn.ExecuteNonQuery(SQL);
			}

			//寫入交辦申請人檔
			insert_dmt_temp_ap_FC0(conn, RSno,"0");	
								
			break;
		case "FC3":
			ColMap.Clear();
			foreach (var key in Request.Form.Keys) {
				string colkey = key.ToString().ToLower();
				string colValue = Request[colkey];

				//取1~4碼
				if (colkey.Left(4) == "tfg3") {
					ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
				}
			}
			if ((Request["O_item31"] ?? "") != ""||(Request["O_item32"] ?? "") != "") {
				ColMap["other_item"] = Util.dbchar(Request["O_item31"] + ";" + Request["O_item32"]+ ";" + Request["O_item33"]);
			}
			ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
			ColMap["in_no"] = "'" + RSno + "'";
			ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
			ColMap["tr_scode"] = "'" + Session["scode"] + "'";
			ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
			ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
			SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);
 
			//*****擬減縮商品(服務名稱)
			if ((Request["tfg3_mod_class"] ?? "") == "Y"){
				for (int i = 1; i <= Convert.ToInt32("0" + Request["tft3_class_count1"]); i++) {
					if ((Request["class31_"+i]??"")!= ""){
						ColMap.Clear();
						ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
						ColMap["in_no"] = "'" + RSno + "'";
						ColMap["mod_field"] = "'mod_class'";
						ColMap["mod_type"] = Util.dbchar(Request["tft3_mod_type"]);
						ColMap["mod_dclass"] = Util.dbchar(Request["tft3_class1"]);
						ColMap["mod_count"] = Util.dbchar(Request["tft3_class_count1" + i]);
						ColMap["new_no"] = Util.dbchar(Request["class31_" + i]);
						ColMap["list_remark"] = Util.dbchar(Request["good_name31_" + i]);
						
						SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
						conn.ExecuteNonQuery(SQL);
					}
				}
			}

			//*****新增案件申請人檔
            insert_dmt_temp_ap(conn, RSno, "0");

			break;
		case "FC4":
			ColMap.Clear();
			foreach (var key in Request.Form.Keys) {
				string colkey = key.ToString().ToLower();
				string colValue = Request[colkey];

				//取1~4碼
				if (colkey.Left(4) == "tfg4") {
					ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
				}
			}
			ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
			ColMap["in_no"] = "'" + RSno + "'";
			ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
			ColMap["tr_scode"] = "'" + Session["scode"] + "'";
			ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
			ColMap["seq1"] = Util.dbchar(Request["tfzb_seq1"]);
			SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);
	 
 			//*****變更註冊申請案號數
			for (int k = 1; k <= Convert.ToInt32("0" + Request["tft4_mod_count41"]); k++) {
				SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,mod_type,mod_count,new_no,ncname1) values (";
				SQL+= "'" + Request["F_tscode"] + "','" + RSno + "','mod_tcnref'";
				SQL+= "," + Util.dbchar(Request["tft4_mod_type"]) + "," + Util.dbchar(Request["tft4_mod_count41"]) + "";
				SQL+= "," + Util.dbchar(Request("new_no41_"+k])  + "," + Util.dbchar(Request["ncname141_" + k])  + ")";
				conn.ExecuteNonQuery(SQL);
			}

			//*****新增案件申請人檔
            insert_dmt_temp_ap(conn, RSno, "0");

			break;
	}

	//*****新增文件上傳
	insert_dmt_attach(conn, RSno);

	//後續交辦作業，更新營洽官收確認紀錄檔grconf_dmt.job_no
	upd_grconf_job_no(conn, RSno);

	//更新客戶主檔最近立案日
	upd_dmt_date(conn, RSno);
	
	If Trim(Request.Form("chkTest"))<>Empty Then
		conn.RollbackTrans
		Response.Write "conn.RollbackTrans...<br>"
		Response.End
	End If
	Conn.CommitTrans
End sub
%>

<!--#include file="CaseForm/ShowDoneBox.inc"-->