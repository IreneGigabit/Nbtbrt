<%
sub doUpdateDB()

set RS=Server.CreateObject("ADODB.recordset")
set RSinfo=Server.CreateObject("ADODB.recordset")
set cmd=Server.CreateObject("ADODB.command")
set cnn=Server.CreateObject("ADODB.connection")
cnn.Open Session["btbrtdb")
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

	//將檔案更改檔名
	//*****新增案件變更檔
	switch ((Request["tfy_arcase"] ?? "").Left(3)) {
		case "DR1":
			string mod_class_ncname1=move_file(RSno,Request["ttg1_mod_class_ncname1"),"ttg1_mod_class_ncname1");
			string mod_class_ncname2=move_file(RSno,Request["ttg1_mod_class_ncname2"),"ttg1_mod_class_ncname2");
			string mod_class_nename1=move_file(RSno,Request["ttg1_mod_class_nename1"),"ttg1_mod_class_nename1");
			string mod_class_nename2=move_file(RSno,Request["ttg1_mod_class_nename2"),"ttg1_mod_class_nename2");
			string mod_class_ncrep=move_file(RSno,Request["ttg1_mod_class_ncrep"),"ttg1_mod_class_ncrep");
			string mod_class_nerep=move_file(RSno,Request["ttg1_mod_class_nerep"),"ttg1_mod_class_nerep");
			string mod_class_neaddr1=move_file(RSno,Request["ttg1_mod_class_neaddr1"),"ttg1_mod_class_neaddr1");
			string mod_class_neaddr2=move_file(RSno,Request["ttg1_mod_class_neaddr2"),"ttg1_mod_class_neaddr2");
			string mod_class_neaddr3=move_file(RSno,Request["ttg1_mod_class_neaddr3"),"ttg1_mod_class_neaddr3");
			string mod_class_neaddr4=move_file(RSno,Request["ttg1_mod_class_neaddr4"),"ttg1_mod_class_neaddr4");
			//--據以異議
			string mod_dmt_ncname1=move_file(RSno,Request["ttg1_mod_dmt_ncname1"),"ttg1_mod_dmt_ncname1");
			string mod_dmt_ncname2=move_file(RSno,Request["ttg1_mod_dmt_ncname2"),"ttg1_mod_dmt_ncname2");
			string mod_dmt_nename1=move_file(RSno,Request["ttg1_mod_dmt_nename1"),"ttg1_mod_dmt_nename1");
			string mod_dmt_nename2=move_file(RSno,Request["ttg1_mod_dmt_nename2"),"ttg1_mod_dmt_nename2");
			string mod_dmt_ncrep=move_file(RSno,Request["ttg1_mod_dmt_ncrep"),"ttg1_mod_dmt_ncrep");
			string mod_dmt_nerep=move_file(RSno,Request["ttg1_mod_dmt_nerep"),"ttg1_mod_dmt_nerep");
			string mod_dmt_neaddr1=move_file(RSno,Request["ttg1_mod_dmt_neaddr1"),"ttg1_mod_dmt_neaddr1");
			string mod_dmt_neaddr2=move_file(RSno,Request["ttg1_mod_dmt_neaddr2"),"ttg1_mod_dmt_neaddr2");
			string mod_dmt_neaddr3=move_file(RSno,Request["ttg1_mod_dmt_neaddr3"),"ttg1_mod_dmt_neaddr3");
			string mod_dmt_neaddr4=move_file(RSno,Request["ttg1_mod_dmt_neaddr4"),"ttg1_mod_dmt_neaddr4");
	
			ColMap.Clear();
			foreach (var key in Request.Form.Keys) {
				string colkey = key.ToString().ToLower();
				string colValue = Request[colkey];

				//取1~4碼
				if (colkey.Left(4).Substring(1) == "tfz1") {
					ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
				}
			}
			ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
			ColMap["in_no"] = "'" + RSno + "'";
			ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
			ColMap["tr_scode"] = "'" + Session["scode"] + "'";
			ColMap["case_sqlno"] = "0";
			ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
			ColMap["seq1"] = Util.dbchar(Request["tfzb_seq"]);
			SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);

 			//*****變更被申請撤銷人資料
			if(Convert.ToInt32("0" + Request["DR1_apnum"])>0){
				for (int k = 1; k <= Convert.ToInt32("0" + Request["DR1_apnum"]); k++) {
					SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,ncrep,nzip,naddr1,naddr2) values (";
					SQL+= "'" + Request["F_tscode"] + "','" + RSno + "','mod_ap'";
					SQL+= "," + Util.dbchar(Request["ttg1_mod_ap_ncname1_" + k]) + "," + Util.dbchar(Request("ttg1_mod_ap_ncname2_"+k])  + "";
					SQL+= "," + Util.dbchar(Request["ttg1_mod_ap_ncrep_" + k])  + "," + Util.dbchar(Request("ttg1_mod_ap_nzip_" + k]) + "";
					SQL+= "," + Util.dbchar(Request["ttg1_mod_ap_naddr1_" + k]) + "," + Util.dbchar(Request("ttg1_mod_ap_naddr2_" + k]) + ")";
					conn.ExecuteNonQuery(SQL);
				}
				SQL="update dmt_tran set mod_ap='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}
	 
			//*****廢止聲明
			if((Request["ttg11_mod_pul_new_no"]??"")!=""||(Request["ttg11_mod_pul_ncname1"]??"")!=""
			||(Request["ttg11_mod_pul_mod_type"]??"")!=""){
				ColMap.Clear();
				ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
				ColMap["in_no"] = "'" + RSno + "'";
				ColMap["mod_field"] = "'mod_pul'";

				string[] field=["new_no","ncname1","mod_type"];
				foreach (string f in field) {
					ColMap[field[f]] = Util.dbnull(Request["ttg11_mod_pul_"+field[f]]);
				}

				SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			if((Request["ttg12_mod_pul_mod_type"]??"")!=""){
				ColMap.Clear();
				ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
				ColMap["in_no"] = "'" + RSno + "'";
				ColMap["mod_field"] = "'mod_pul'";

				string[] field=["mod_type"];
				foreach (string f in field) {
					ColMap[field[f]] = Util.dbnull(Request["ttg12_mod_pul_"+field[f]]);
				}
				SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			if((Request["ttg13_mod_pul_new_no"]??"")!=""||(Request["ttg13_mod_pul_mod_dclass"]??"")!=""
			||(Request["ttg13_mod_pul_mod_type"]??"")!=""){
				ColMap.Clear();
				ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
				ColMap["in_no"] = "'" + RSno + "'";
				ColMap["mod_field"] = "'mod_pul'";

				string[] field=["new_no","mod_dclass","mod_type"];
				foreach (string f in field) {
					ColMap[field[f]] = Util.dbnull(Request["ttg13_mod_pul_"+field[f]]);
				}

				SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			if((Request["ttg14_mod_pul_new_no"]??"")!=""||(Request["ttg14_mod_pul_mod_dclass"]??"")!=""
			||(Request["ttg14_mod_pul_ncname1"]??"")!=""||(Request["ttg14_mod_pul_mod_type"]??"")!=""){
				ColMap.Clear();
				ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
				ColMap["in_no"] = "'" + RSno + "'";
				ColMap["mod_field"] = "'mod_pul'";

				string[] field=["new_no","mod_dclass","ncname1","mod_type"];
				foreach (string f in field) {
					ColMap[field[f]] = Util.dbnull(Request["ttg14_mod_pul_"+field[f]]);
				}

				SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			//據以異議商標/標章
			if((Request["ttg1_mod_claim1_ncname1"]??"")!=""){
				ColMap.Clear();
				ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
				ColMap["in_no"] = "'" + RSno + "'";
				ColMap["mod_field"] = "'mod_claim1'";

				string[] field=["ncname1"];
				foreach (string f in field) {
					ColMap[field[f]] = Util.dbnull(Request["ttg1_mod_claim1_"+field[f]]);
				}
				SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_claim1='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			//變換使用商標圖樣
			if((Request["ttg1_mod_class_ncname1"]??"")!=""||(Request["ttg1_mod_class_ncname2"]??"")!=""
			||(Request["ttg1_mod_class_nename1"]??"")!=""||(Request["ttg1_mod_class_nename2"]??"")!=""
			||(Request["ttg1_mod_class_ncrep"]??"")!=""||(Request["ttg1_mod_class_nerep"]??"")!=""
			||(Request["ttg1_mod_class_neaddr1"]??"")!=""||(Request["ttg1_mod_class_neaddr2"]??"")!=""
			||(Request["ttg1_mod_class_neaddr3"]??"")!=""||(Request["ttg1_mod_class_neaddr4"]??"")!=""
			){
				SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4)" ;
				SQL+= "VALUES('" + Request["F_tscode"] + "','" + RSno + "','mod_class'";
				SQL+= "," +Util.dbnull(mod_class_ncname1) + "," + Util.dbnull(mod_class_ncname2) ;
				SQL+="," + Util.dbnull(mod_class_nename1) + "," + Util.dbnull(mod_class_nename2) ;
				SQL+= "," +Util.dbnull(mod_class_ncrep) + "," +  Util.dbnull(mod_class_nerep) ;
				SQL+= "," +Util.dbnull(mod_class_neaddr1) + "," + Util.dbnull(mod_class_neaddr2) ;
				SQL+="," + Util.dbnull(mod_class_neaddr3) + "," + Util.dbnull(mod_class_neaddr4)+")";
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_class='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			//變換撤銷商標圖樣
			if((Request["ttg1_mod_dmt_ncname1"]??"")!=""||(Request["ttg1_mod_dmt_ncname2"]??"")!=""
			||(Request["ttg1_mod_dmt_nename1"]??"")!=""||(Request["ttg1_mod_dmt_nename2"]??"")!=""
			||(Request["ttg1_mod_dmt_ncrep"]??"")!=""||(Request["ttg1_mod_dmt_nerep"]??"")!=""
			||(Request["ttg1_mod_dmt_neaddr1"]??"")!=""||(Request["ttg1_mod_dmt_neaddr2"]??"")!=""
			||(Request["ttg1_mod_dmt_neaddr3"]??"")!=""||(Request["ttg1_mod_dmt_neaddr4"]??"")!=""
			){
				SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4)" ;
				SQL+= "VALUES('" + Request["F_tscode"] + "','" + RSno + "','mod_dmt'";
				SQL+= "," + Util.dbnull(mod_dmt_ncname1) + "," + Util.dbnull(mod_dmt_ncname2) ;
				SQL+= "," + Util.dbnull(mod_dmt_nename1) + "," + Util.dbnull(mod_dmt_nename2) ;
				SQL+= "," + Util.dbnull(mod_dmt_ncrep) + "," +  Util.dbnull(mod_dmt_nerep) ;
				SQL+= "," + Util.dbnull(mod_dmt_neaddr1) + "," + Util.dbnull(mod_dmt_neaddr2) ;
				SQL+= "," + Util.dbnull(mod_dmt_neaddr3) + "," + Util.dbnull(mod_dmt_neaddr4)+")";
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_dmt='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}
			break;
		case "DO1":
			string mod_dmt_ncname1=move_file(RSno,Request["ttg2_mod_dmt_ncname1"),"ttg2_mod_dmt_ncname1");
			string mod_dmt_ncname2=move_file(RSno,Request["ttg2_mod_dmt_ncname2"),"ttg2_mod_dmt_ncname2");
			string mod_dmt_nename1=move_file(RSno,Request["ttg2_mod_dmt_nename1"),"ttg2_mod_dmt_nename1");
			string mod_dmt_nename2=move_file(RSno,Request["ttg2_mod_dmt_nename2"),"ttg2_mod_dmt_nename2");
			string mod_dmt_ncrep=move_file(RSno,Request["ttg2_mod_dmt_ncrep"),"ttg2_mod_dmt_ncrep");
			string mod_dmt_nerep=move_file(RSno,Request["ttg2_mod_dmt_nerep"),"ttg2_mod_dmt_nerep");
			string mod_dmt_neaddr1=move_file(RSno,Request["ttg2_mod_dmt_neaddr1"),"ttg2_mod_dmt_neaddr1");
			string mod_dmt_neaddr2=move_file(RSno,Request["ttg2_mod_dmt_neaddr2"),"ttg2_mod_dmt_neaddr2");
			string mod_dmt_neaddr3=move_file(RSno,Request["ttg2_mod_dmt_neaddr3"),"ttg2_mod_dmt_neaddr3");
			string mod_dmt_neaddr4=move_file(RSno,Request["ttg2_mod_dmt_neaddr4"),"ttg2_mod_dmt_neaddr4");

			ColMap.Clear();
			foreach (var key in Request.Form.Keys) {
				string colkey = key.ToString().ToLower();
				string colValue = Request[colkey];

				//取1~4碼
				if (colkey.Left(4).Substring(1) == "tfz2") {
					ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
				}
			}
			ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
			ColMap["in_no"] = "'" + RSno + "'";
			ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
			ColMap["tr_scode"] = "'" + Session["scode"] + "'";
			ColMap["case_sqlno"] = "0";
			ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
			ColMap["seq1"] = Util.dbchar(Request["tfzb_seq"]);
			SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);

 			//*****變更被申請撤銷人資料
			if(Convert.ToInt32("0" + Request["DO1_apnum"])>0){
				for (int k = 1; k <= Convert.ToInt32("0" + Request["DO1_apnum"]); k++) {
					SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,ncrep,nzip,naddr1,naddr2) values (";
					SQL+= "'" + Request["F_tscode"] + "','" + RSno + "','mod_ap'";
					SQL+= "," + Util.dbchar(Request["ttg2_mod_ap_ncname1_" + k]) + "," + Util.dbchar(Request("ttg2_mod_ap_ncname2_"+k])  + "";
					SQL+= "," + Util.dbchar(Request["ttg2_mod_ap_ncrep_" + k])  + "," + Util.dbchar(Request("ttg2_mod_ap_nzip_" + k]) + "";
					SQL+= "," + Util.dbchar(Request["ttg2_mod_ap_naddr1_" + k]) + "," + Util.dbchar(Request("ttg2_mod_ap_naddr2_" + k]) + ")";
					conn.ExecuteNonQuery(SQL);
				}
				SQL="update dmt_tran set mod_ap='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			//*****廢止聲明
			if((Request["ttg21_mod_pul_new_no"]??"")!=""||(Request["ttg21_mod_pul_ncname1"]??"")!=""
			||(Request["ttg21_mod_pul_mod_type"]??"")!=""){
				ColMap.Clear();
				ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
				ColMap["in_no"] = "'" + RSno + "'";
				ColMap["mod_field"] = "'mod_pul'";

				string[] field=["new_no","ncname1","mod_type"];
				foreach (string f in field) {
					ColMap[field[f]] = Util.dbnull(Request["ttg21_mod_pul_"+field[f]]);
				}

				SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			if((Request["ttg22_mod_pul_mod_type"]??"")!=""){
				ColMap.Clear();
				ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
				ColMap["in_no"] = "'" + RSno + "'";
				ColMap["mod_field"] = "'mod_pul'";

				string[] field=["mod_type"];
				foreach (string f in field) {
					ColMap[field[f]] = Util.dbnull(Request["ttg22_mod_pul_"+field[f]]);
				}
				SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			if((Request["ttg23_mod_pul_new_no"]??"")!=""||(Request["ttg23_mod_pul_mod_dclass"]??"")!=""
			||(Request["ttg23_mod_pul_mod_type"]??"")!=""){
				ColMap.Clear();
				ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
				ColMap["in_no"] = "'" + RSno + "'";
				ColMap["mod_field"] = "'mod_pul'";

				string[] field=["new_no","mod_dclass","mod_type"];
				foreach (string f in field) {
					ColMap[field[f]] = Util.dbnull(Request["ttg23_mod_pul_"+field[f]]);
				}

				SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			if((Request["ttg24_mod_pul_new_no"]??"")!=""||(Request["ttg24_mod_pul_mod_dclass"]??"")!=""
			||(Request["ttg24_mod_pul_ncname1"]??"")!=""||(Request["ttg24_mod_pul_mod_type"]??"")!=""){
				ColMap.Clear();
				ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
				ColMap["in_no"] = "'" + RSno + "'";
				ColMap["mod_field"] = "'mod_pul'";

				string[] field=["new_no","mod_dclass","ncname1","mod_type"];
				foreach (string f in field) {
					ColMap[field[f]] = Util.dbnull(Request["ttg34_mod_pul_"+field[f]]);
				}

				SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			//據以異議商標/標章
			if(Convert.ToInt32("0" + Request["ttg2_mod_aprep_mod_count"])>0){
				for (int i = 1; i <= Convert.ToInt32("0" + Request["ttg2_mod_aprep_mod_count"]); i++) {
					SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,mod_count,ncname1,new_no) values (";
					SQL+= "'" + Request["F_tscode"] + "','" + RSno + "','mod_aprep'";
					SQL+= "," + Util.dbnull(Request["ttg2_mod_aprep_mod_count_"]) + "," + Util.dbchar(Request("ttg2_mod_aprep_ncname1_"+i])  + "";
					SQL+= "," + Util.dbchar(Request["ttg2_mod_aprep_new_no_" + i]) + ")";
					conn.ExecuteNonQuery(SQL);
				}
				SQL="update dmt_tran set mod_aprep='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			//變換撤銷商標圖樣
			if((Request["ttg2_mod_dmt_ncname1"]??"")!=""||(Request["ttg2_mod_dmt_ncname2"]??"")!=""
			||(Request["ttg2_mod_dmt_nename1"]??"")!=""||(Request["ttg2_mod_dmt_nename2"]??"")!=""
			||(Request["ttg2_mod_dmt_ncrep"]??"")!=""||(Request["ttg2_mod_dmt_nerep"]??"")!=""
			||(Request["ttg2_mod_dmt_neaddr1"]??"")!=""||(Request["ttg2_mod_dmt_neaddr2"]??"")!=""
			||(Request["ttg2_mod_dmt_neaddr3"]??"")!=""||(Request["ttg2_mod_dmt_neaddr4"]??"")!=""
			){
				SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4)" ;
				SQL+= "VALUES('" + Request["F_tscode"] + "','" + RSno + "','mod_dmt'";
				SQL+="," +  Util.dbnull(mod_dmt_ncname1) + "," + Util.dbnull(mod_dmt_ncname2) ;
				SQL+= "," + Util.dbnull(mod_dmt_nename1) + "," + Util.dbnull(mod_dmt_nename2) ;
				SQL+="," +  Util.dbnull(mod_dmt_ncrep) + "," +  Util.dbnull(mod_dmt_nerep) ;
				SQL+= "," + Util.dbnull(mod_dmt_neaddr1) + "," + Util.dbnull(mod_dmt_neaddr2) ;
				SQL+= "," + Util.dbnull(mod_dmt_neaddr3) + "," + Util.dbnull(mod_dmt_neaddr4)+")";
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_dmt='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}
			break;
		case "DI1":
			string mod_dmt_ncname1=move_file(RSno,Request["ttg3_mod_dmt_ncname1"),"ttg3_mod_dmt_ncname1");
			string mod_dmt_ncname2=move_file(RSno,Request["ttg3_mod_dmt_ncname2"),"ttg3_mod_dmt_ncname2");
			string mod_dmt_nename1=move_file(RSno,Request["ttg3_mod_dmt_nename1"),"ttg3_mod_dmt_nename1");
			string mod_dmt_nename2=move_file(RSno,Request["ttg3_mod_dmt_nename2"),"ttg3_mod_dmt_nename2");
			string mod_dmt_ncrep=move_file(RSno,Request["ttg3_mod_dmt_ncrep"),"ttg3_mod_dmt_ncrep");
			string mod_dmt_nerep=move_file(RSno,Request["ttg3_mod_dmt_nerep"),"ttg3_mod_dmt_nerep");
			string mod_dmt_neaddr1=move_file(RSno,Request["ttg3_mod_dmt_neaddr1"),"ttg3_mod_dmt_neaddr1");
			string mod_dmt_neaddr2=move_file(RSno,Request["ttg3_mod_dmt_neaddr2"),"ttg3_mod_dmt_neaddr2");
			string mod_dmt_neaddr3=move_file(RSno,Request["ttg3_mod_dmt_neaddr3"),"ttg3_mod_dmt_neaddr3");
			string mod_dmt_neaddr4=move_file(RSno,Request["ttg32_mod_dmt_neaddr4"),"ttg3_mod_dmt_neaddr4");

			ColMap.Clear();
			foreach (var key in Request.Form.Keys) {
				string colkey = key.ToString().ToLower();
				string colValue = Request[colkey];

				//取1~4碼
				if (colkey.Left(4).Substring(1) == "tfz3") {
					ColMap[colkey.Substring(5)] = Util.dbnull(colValue);
				}
			}
			ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
			ColMap["in_no"] = "'" + RSno + "'";
			ColMap["tr_date"] = "'" + DateTime.Today.ToShortDateString() + "'";
			ColMap["tr_scode"] = "'" + Session["scode"] + "'";
			ColMap["case_sqlno"] = "0";
			ColMap["seq"] = Util.dbnull(Request["tfzb_seq"]);
			ColMap["seq1"] = Util.dbchar(Request["tfzb_seq"]);
			SQL = "insert into dmt_tran " + ColMap.GetInsertSQL();
			conn.ExecuteNonQuery(SQL);

			//*****變更被申請撤銷人資料
			if(Convert.ToInt32("0" + Request["DI1_apnum"])>0){
				for (int k = 1; k <= Convert.ToInt32("0" + Request["DI1_apnum"]); k++) {
					SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,ncrep,nzip,naddr1,naddr2) values (";
					SQL+= "'" + Request["F_tscode"] + "','" + RSno + "','mod_ap'";
					SQL+= "," + Util.dbchar(Request["ttg3_mod_ap_ncname1_" + k]) + "," + Util.dbchar(Request("ttg3_mod_ap_ncname2_"+k])  + "";
					SQL+= "," + Util.dbchar(Request["ttg3_mod_ap_ncrep_" + k])  + "," + Util.dbchar(Request("ttg3_mod_ap_nzip_" + k]) + "";
					SQL+= "," + Util.dbchar(Request["ttg3_mod_ap_naddr1_" + k]) + "," + Util.dbchar(Request("ttg3_mod_ap_naddr2_" + k]) + ")";
					conn.ExecuteNonQuery(SQL);
				}
				SQL="update dmt_tran set mod_ap='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			//*****廢止聲明
			if((Request["ttg31_mod_pul_new_no"]??"")!=""||(Request["ttg31_mod_pul_ncname1"]??"")!=""
			||(Request["ttg31_mod_pul_mod_type"]??"")!=""){
				ColMap.Clear();
				ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
				ColMap["in_no"] = "'" + RSno + "'";
				ColMap["mod_field"] = "'mod_pul'";

				string[] field=["new_no","ncname1","mod_type"];
				foreach (string f in field) {
					ColMap[field[f]] = Util.dbnull(Request["ttg31_mod_pul_"+field[f]]);
				}

				SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			if((Request["ttg32_mod_pul_mod_type"]??"")!=""){
				ColMap.Clear();
				ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
				ColMap["in_no"] = "'" + RSno + "'";
				ColMap["mod_field"] = "'mod_pul'";

				string[] field=["mod_type"];
				foreach (string f in field) {
					ColMap[field[f]] = Util.dbnull(Request["ttg32_mod_pul_"+field[f]]);
				}
				SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			if((Request["ttg33_mod_pul_new_no"]??"")!=""||(Request["ttg33_mod_pul_mod_dclass"]??"")!=""
			||(Request["ttg33_mod_pul_mod_type"]??"")!=""){
				ColMap.Clear();
				ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
				ColMap["in_no"] = "'" + RSno + "'";
				ColMap["mod_field"] = "'mod_pul'";

				string[] field=["new_no","mod_dclass","mod_type"];
				foreach (string f in field) {
					ColMap[field[f]] = Util.dbnull(Request["ttg33_mod_pul_"+field[f]]);
				}

				SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			if((Request["ttg34_mod_pul_new_no"]??"")!=""||(Request["ttg34_mod_pul_mod_dclass"]??"")!=""
			||(Request["ttg34_mod_pul_ncname1"]??"")!=""||(Request["ttg34_mod_pul_mod_type"]??"")!=""){
				ColMap.Clear();
				ColMap["in_scode"] = Util.dbchar(Request["F_tscode"]);
				ColMap["in_no"] = "'" + RSno + "'";
				ColMap["mod_field"] = "'mod_pul'";

				string[] field=["new_no","mod_dclass","ncname1","mod_type"];
				foreach (string f in field) {
					ColMap[field[f]] = Util.dbnull(Request["ttg34_mod_pul_"+field[f]]);
				}

				SQL = "insert into dmt_tranlist " + ColMap.GetInsertSQL();
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_pul='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			//據以異議商標/標章
			if(Convert.ToInt32("0" + Request["ttg3_mod_aprep_mod_count"])>0){
				for (int i = 1; i <= Convert.ToInt32("0" + Request["ttg3_mod_aprep_mod_count"]); i++) {
					SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,mod_count,ncname1,new_no) values (";
					SQL+= "'" + Request["F_tscode"] + "','" + RSno + "','mod_aprep'";
					SQL+= "," + Util.dbnull(Request["ttg3_mod_aprep_mod_count"]) + "," + Util.dbchar(Request("ttg3_mod_aprep_ncname1_"+i])  + "";
					SQL+= "," + Util.dbchar(Request["ttg3_mod_aprep_new_no_" + i]) + ")";
					conn.ExecuteNonQuery(SQL);
				}
				SQL="update dmt_tran set mod_aprep='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}

			//變換撤銷商標圖樣
			if((Request["ttg3_mod_dmt_ncname1"]??"")!=""||(Request["ttg3_mod_dmt_ncname2"]??"")!=""
			||(Request["ttg3_mod_dmt_nename1"]??"")!=""||(Request["ttg3_mod_dmt_nename2"]??"")!=""
			||(Request["ttg3_mod_dmt_ncrep"]??"")!=""||(Request["ttg3_mod_dmt_nerep"]??"")!=""
			||(Request["ttg3_mod_dmt_neaddr1"]??"")!=""||(Request["ttg3_mod_dmt_neaddr2"]??"")!=""
			||(Request["ttg3_mod_dmt_neaddr3"]??"")!=""||(Request["ttg3_mod_dmt_neaddr4"]??"")!=""
			){
				SQL = "INSERT INTO dmt_tranlist(in_scode,in_no,mod_field,ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4)" ;
				SQL+= "VALUES('" + Request["F_tscode"] + "','" + RSno + "','mod_dmt'";
				SQL+= "," + Util.dbnull(mod_dmt_ncname1) + "," + Util.dbnull(mod_dmt_ncname2) ;
				SQL+= "," + Util.dbnull(mod_dmt_nename1) + "," + Util.dbnull(mod_dmt_nename2) ;
				SQL+= "," + Util.dbnull(mod_dmt_ncrep) + "," +  Util.dbnull(mod_dmt_nerep) ;
				SQL+= "," + Util.dbnull(mod_dmt_neaddr1) + "," + Util.dbnull(mod_dmt_neaddr2) ;
				SQL+= "," + Util.dbnull(mod_dmt_neaddr3) + "," + Util.dbnull(mod_dmt_neaddr4)+")";
				conn.ExecuteNonQuery(SQL);

				SQL="update dmt_tran set mod_dmt='Y' where in_scode='" + Request["F_tscode"] + "' and in_no = '" + RSno + "'";
				conn.ExecuteNonQuery(SQL);
			}
			break;
		default:
			//寫入商品類別檔
			insert_casedmt_good(conn, RSno);

			if((Request["tfy_arcase"] ?? "").Left(3)=="DE1"){
				SQL= "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tran_mark,tr_date,tr_scode,seq,seq1)";
				SQL+=" values ('" + Request["F_tscode"] + "','" + RSno + "'," + Util.dbchar(Request["fr4_other_item"]) + "";
				SQL+="," + Util.dbchar(Request["fr4_other_item1"]) + "," + Util.dbchar(Request["fr4_other_item2"]) + "";
				SQL+="," + Util.dbchar(Request["fr4_tran_remark1"]) + "," + Util.dbchar(Request["fr4_tran_mark"]) + "";
				SQL+=",'" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "'";
				SQL+= Util.dbnull(Request["tfzb_seq")) +","+ Util.dbchar(Request["tfzb_seq1"])+")";
				conn.ExecuteNonQuery(SQL);
				//新增對照當事人資料
				for (int k = 1; k <= Convert.ToInt32("0" + Request["de1_apnum"]); k++) {
				    SQL = "insert into dmt_tranlist(in_scode,in_no,mod_field,ncname1,naddr1) values (";
				    SQL+= "'" + Request["F_tscode"] + "','" + RSno + "','mod_client'";
					SQL+="," +Util.dbchar(Request["tfr4_ncname1_" + k]) + "," + Util.dbchar(Request["tfr4_naddr1_" + k]) + ")";
				    conn.ExecuteNonQuery(SQL);
				}
			}else if((Request["tfy_arcase"] ?? "").Left(3)=="DE2"){
				SQL3= "INSERT INTO dmt_tran(in_scode,in_no,other_item,other_item1,other_item2,tran_remark1,tr_date,tr_scode,seq,seq1)";
				SQL+=" values ('" + Request["F_tscode"] + "','" + RSno + "'," + Util.dbchar(Request["fr4_other_item"]) + ",";
				SQL+="" + Util.dbchar(Request["fr4_other_item1"]) + "," + Util.dbchar(Request["fr4_other_item2"]) + ",";
				SQL+="" + Util.dbchar(Request["fr4_tran_remark1"]) + ",'" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "',";
				SQL+=Util.dbnull(Request["tfzb_seq")) +","+ Util.dbchar(Request["tfzb_seq1"])+")";
				conn.ExecuteNonQuery(SQL);
			}else{
				SQL= "INSERT INTO dmt_tran(in_scode,in_no,tran_remark1,tr_date,tr_scode,seq,seq1,agt_no1)";
				SQL+=" values ('" + Request["F_tscode"] + "','" + RSno + "'," + Util.dbchar(Request["tfg1_tran_remark1"] + "";
				SQL+=",'" + DateTime.Today.ToShortDateString() + "','" + Session["scode"] + "',";
				SQL+=Util.dbnull(Request["tfzb_seq")) +","+ Util.dbchar(Request["tfzb_seq1"])+","+ Util.dbnull(Request["tfg1_agt_no1"]) +")";
				conn.ExecuteNonQuery(SQL);
			}
			break;
	}

	//寫入交辦申請人檔
	insert_dmt_temp_ap(conn, RSno,"0");	

	//*****新增文件上傳
	insert_dmt_attach(conn, RSno);

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