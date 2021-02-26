<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Text"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string SQL = "";

    protected int right = 0;
    protected string prgid = "";
    protected string submitTask = "";
    protected string formfunction = "";
    protected string in_no = "";
    protected string cust_area = "";
    protected string cust_seq = "";
    protected string code_type = "";
    protected string arcase = "";//案性

    protected string br_in_scode = "";//交辦單營洽
    protected string br_in_scname = "";//交辦單營洽
    protected string casefee_oth_money = "";//轉帳金額合計抓收費標準
    protected string seq = "";
    protected string seq1 = "";

    DataTable dtCaseMain=new DataTable();
    DataTable dtCaseItem=new DataTable();//交辦費用.案性
    DataTable dtCaseGood=new DataTable();//商品類別
    DataTable dtCaseShow=new DataTable();//展覽優先權
    DataTable dtCaseAttach=new DataTable();//交辦附件
    DataTable dtCaseTran=new DataTable();//異動檔
    DataTable dtCaseTranlist=new DataTable();//異動明細檔
    DataTable dtCust=new DataTable();//客戶主檔資料
    DataTable dtCaseDmt1=new DataTable();//一案多件.case_dmt1子案
    DataTable dtCaseTemp1=new DataTable();//一案多件.dmt_temp子案
    DataTable dtDmt=new DataTable();//案件主檔

    Sys sfile = new Sys();

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    protected void Page_Load(object sender, EventArgs e) {
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        prgid = (Request["prgid"] ?? "").Trim().ToLower();
        right = Convert.ToInt32(Request["right"] ?? "0");
        submitTask = (Request["submitTask"] ?? "").Trim();
        formfunction = (Request["formfunction"] ?? "").Trim();
        in_no = (Request["in_no"] ?? "").Trim();
        cust_area = (Request["cust_area"] ?? "").Trim();
        cust_seq = (Request["cust_seq"] ?? "").Trim();
        code_type = (Request["code_type"] ?? "").Trim();

        br_in_scode = Sys.GetSession("scode");
        br_in_scname = Sys.GetSession("sc_name");
        casefee_oth_money = "0";
        sfile.getFileServer(Sys.GetSession("SeBranch"), "brt");//檔案上傳相關設定

        var settings = new JsonSerializerSettings() {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };

        Response.Write("{");
        Response.Write("\"case_main\":" + JsonConvert.SerializeObject(GetCase(ref dtCaseMain), settings).ToUnicode() + "\n");
        Response.Write(",\"case_item\":" + JsonConvert.SerializeObject(GetCaseItem(ref dtCaseItem), settings).ToUnicode() + "\n");//交辦費用.案性
        Response.Write(",\"case_good\":" + JsonConvert.SerializeObject(GetCaseGood(ref dtCaseGood), settings).ToUnicode() + "\n");//商品類別
        Response.Write(",\"case_show\":" + JsonConvert.SerializeObject(GetCaseShow(ref dtCaseShow), settings).ToUnicode() + "\n");//展覽優先權
        Response.Write(",\"case_attach\":" + JsonConvert.SerializeObject(GetCaseAttach(ref dtCaseAttach), settings).ToUnicode() + "\n");//交辦附件
        Response.Write(",\"case_tran\":" + JsonConvert.SerializeObject(GetCaseTran(ref dtCaseTran), settings).ToUnicode() + "\n");//異動檔
        Response.Write(",\"case_tranlist\":" + JsonConvert.SerializeObject(GetCaseTranlist(ref dtCaseTranlist), settings).ToUnicode() + "\n");//異動明細檔
        Response.Write(",\"cust\":" + JsonConvert.SerializeObject(GetCust(ref dtCust), settings).ToUnicode() + "\n");//客戶主檔資料
        Response.Write(",\"case_dmt1\":" + JsonConvert.SerializeObject(GetCaseDmt1(ref dtCaseDmt1), settings).ToUnicode() + "\n");//一案多件.case_dmt1子案
        Response.Write(",\"dmt_temp1\":" + JsonConvert.SerializeObject(GetCaseSql(ref dtCaseTemp1), settings).ToUnicode() + "\n");//一案多件(分割).dmt_temp子案
        Response.Write(",\"casefee_oth_money\":" + JsonConvert.SerializeObject(casefee_oth_money, settings).ToUnicode() + "\n");
        Response.Write(",\"br_in_scode\":" + JsonConvert.SerializeObject(br_in_scode, settings).ToUnicode() + "\n");
        Response.Write(",\"br_in_scname\":" + JsonConvert.SerializeObject(br_in_scname, settings).ToUnicode() + "\n");
        Response.Write(",\"step_cr\":" + JsonConvert.SerializeObject(AddCR(), settings).ToUnicode() + "\n");//交辦客收預設值
        Response.Write("}");

        //Response.Write(JsonConvert.SerializeObject(dt, settings).ToUnicode());
    }

    #region GetCase 交辦資料
    private DataTable GetCase(ref DataTable dt) {
        //if (submitTask == "Edit" || submitTask == "Show" || submitTask == "AddNext") {//編輯/檢視/複製下一筆 模式
        //SQL = "Pro_case2 '" + in_no + "'";
        SQL = "SELECT a.*,c.*,g.* ";
        SQL += ",(SELECT b.coun_c FROM sysctrl.dbo.country b WHERE b.coun_code = a.zname_type and b.markb<>'X') AS nzname ";
        SQL += ",(SELECT c.coun_code+c.coun_cname FROM sysctrl.dbo.ipo_country c WHERE c.ref_coun_code = a.prior_country ) AS ncountry ";
        SQL += ",a.mark temp_mark,c.mark case_mark, C.service + C.fees+ C.oth_money AS othsum,b.mark as codemark ";
        SQL += ",''s_marknm ";
        SQL += " FROM dmt_temp A ";
        SQL += " inner join case_dmt c on a.in_no = c.in_no and a.in_scode = c.in_scode ";
        SQL += " inner join code_br b on c.arcase_type=b.rs_type and c.arcase=b.rs_code and b.dept='T' and b.cr='Y' ";
        SQL += " left JOIN dmt_tran G ON C.in_scode = G.in_scode AND C.in_no = G.in_no ";
        SQL += " WHERE A.in_no ='" + in_no + "' and a.case_sqlno=0 ";
        conn.DataTable(SQL, dt);

        if (dt.Rows.Count > 0) {
            seq = dt.Rows[0].SafeRead("seq", "");
            seq1 = dt.Rows[0].SafeRead("seq1", "");
            code_type = dt.Rows[0].SafeRead("arcase_type", "");
            arcase = dt.Rows[0].SafeRead("arcase", "");
            br_in_scode = dt.Rows[0].SafeRead("in_scode", "");

            if (submitTask == "AddNext") {//圖様改為新檔名
                if (dt.Rows[0].SafeRead("draw_file", "") != "") {
                    System.IO.FileInfo sFi = new System.IO.FileInfo(HttpContext.Current.Server.MapPath(Sys.Path2Nbtbrt(dt.Rows[0].SafeRead("draw_file", ""))));
                    string strpath1 = sfile.gbrWebDir + "/temp";
                    string newName = br_in_scode + "-" + Path.GetFileName(dt.Rows[0].SafeRead("draw_file", ""));
                    sFi.CopyTo(Server.MapPath(Sys.Path2Nbtbrt(strpath1 + "/" + newName)), true);
                    dt.Rows[0]["draw_file"] = strpath1 + "/" + newName;
                }
            }
            dt.Rows[0]["draw_file"] = Sys.Path2Nbtbrt(dt.Rows[0].SafeRead("draw_file", ""));

            if (dt.Rows[0].SafeRead("s_mark", "") == "S") {
                dt.Rows[0]["s_marknm"] = "服務";
            } else if (dt.Rows[0].SafeRead("s_mark", "") == "L") {
                dt.Rows[0]["s_marknm"] = "證明";
            } else if (dt.Rows[0].SafeRead("s_mark", "") == "M") {
                dt.Rows[0]["s_marknm"] = "團體標章";
            } else if (dt.Rows[0].SafeRead("s_mark", "") == "N") {
                dt.Rows[0]["s_marknm"] = "團體商標";
            } else if (dt.Rows[0].SafeRead("s_mark", "") == "K") {
                dt.Rows[0]["s_marknm"] = "產地證明標章";
            } else {
                dt.Rows[0]["s_marknm"] = "商標";
            }

            SQL = "select sc_name from sysctrl.dbo.scode where scode='" + br_in_scode + "'";
            object objResult = conn.ExecuteScalar(SQL);
            br_in_scname = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            //轉帳金額合計抓收費標準
            SQL = "select b.service ";
            SQL += "from case_dmt a ";
            SQL += "inner join case_fee b on a.oth_arcase=b.rs_code ";
            SQL += "where a.in_no= '" + in_no + "' and a.in_scode='" + br_in_scode + "' ";
            SQL += "and b.dept='T' and b.country='T' and getdate() between b.beg_date and b.end_date";
            objResult = conn.ExecuteScalar(SQL);
            casefee_oth_money = (objResult == DBNull.Value || objResult == null) ? "0" : objResult.ToString();
        }
        //}
        return dt;
    }
    #endregion

    #region GetCaseItem 交辦費用
    private DataTable GetCaseItem(ref DataTable dt) {
        SQL = "select a.item_sql,a.item_arcase,a.item_count,a.item_service,a.item_fees,b.prt_code,b.remark,c.service,c.fees,c.others,c.oth_code,c.oth_code1 ";
        SQL += "from caseitem_dmt a ";
        SQL += "inner join code_br b on  a.item_arcase=b.rs_code AND b.no_code='N' and b.rs_type='" + code_type + "' ";
        SQL += "left outer join case_fee c on c.dept='T' and c.country='T' and c.rs_code=a.item_arcase and getdate() between c.beg_date and c.end_date ";
        SQL += "where a.in_no= '" + in_no + "' and a.in_scode='" + br_in_scode + "' ";
        SQL += "order by a.item_sql";
        conn.DataTable(SQL, dt);
        return dt;
    }
    #endregion

    #region GetCaseGood 商品類別
    private DataTable GetCaseGood(ref DataTable dt) {
        SQL = "select * from casedmt_good where in_no= '" + in_no + "' and in_scode='" + br_in_scode + "' order by cast(class as int)";
        conn.DataTable(SQL, dt);
        return dt;
    }
    #endregion

    #region GetCaseShow 展覽優先權
    private DataTable GetCaseShow(ref DataTable dt) {
        SQL = "select * from casedmt_show where in_no='" + in_no + "' and case_sqlno=0  order by show_sqlno";
        conn.DataTable(SQL, dt);
        return dt;
    }
    #endregion

    #region GetCaseAttach 交辦附件
    private DataTable GetCaseAttach(ref DataTable dt) {
        if (in_no != "") {
            SQL = "select * from dmt_attach where in_no='" + in_no + "' and source='case' and attach_flag<>'D' order by attach_sqlno";
            conn.DataTable(SQL, dt);

            for (int i = 0; i < dt.Rows.Count; i++) {
                if (submitTask == "AddNext") {//複製模式,改為新檔名
                    if (dt.Rows[i].SafeRead("apattach_sqlno", "") == "") {//總契約書/委任書不需複製檔案
                        System.IO.FileInfo sFi = new System.IO.FileInfo(HttpContext.Current.Server.MapPath(Sys.Path2Nbtbrt(dt.Rows[i].SafeRead("attach_path", ""))));
                        string strpath1 = sfile.gbrWebDir + "/doc/case";
                        string newName = br_in_scode + "-" + dt.Rows[i].SafeRead("attach_name", "");

                        dt.Rows[i]["attach_name"] = newName;
                        dt.Rows[i]["attach_path"] = strpath1 + "/" + newName;

                        sFi.CopyTo(Server.MapPath(strpath1 + "/" + newName), true);
                    }
                }
                dt.Rows[i]["attach_path"] = Sys.Path2Nbtbrt(dt.Rows[i].SafeRead("attach_path", ""));
            }
        }
        return dt;
    }
    #endregion

    #region GetCaseTran 異動檔
    private DataTable GetCaseTran(ref DataTable dt) {
        SQL = "select * from dmt_tran where in_no= '"  + in_no + "' and in_scode='" + br_in_scode +"'";
        conn.DataTable(SQL, dt);
        return dt;
    }
    #endregion

    #region GetCaseTranlist 異動明細檔
    private DataTable GetCaseTranlist(ref DataTable dt) {
        SQL = "select * from dmt_tranlist where in_no= '" + in_no + "' and in_scode='" + br_in_scode + "'";
        conn.DataTable(SQL, dt);

        for (int i = 0; i < dt.Rows.Count; i++) {
            string[] fld = { "ncname1", "ncname2", "nename1", "nename2", "ncrep", "nerep", "neaddr1", "neaddr2", "neaddr3", "neaddr4" };//會存據以異議/評定/廢止商標圖樣的欄位
            if (dt.Rows[i].SafeRead("mod_field", "") == "mod_dmt" || dt.Rows[i].SafeRead("mod_field", "") == "mod_class") {
                if (arcase == "DO1" || arcase == "DR1" || arcase == "DI1") {
                    if (submitTask == "AddNext") {//複製模式,改為新檔名
                        foreach (string f in fld) {
                            System.IO.FileInfo sFi = new System.IO.FileInfo(HttpContext.Current.Server.MapPath(Sys.Path2Nbtbrt(dt.Rows[i].SafeRead(f, ""))));
                            string strpath1 = sfile.gbrWebDir + "/temp";
                            string newName = br_in_scode + "-" + Path.GetFileName(dt.Rows[i].SafeRead(f, ""));
                            sFi.CopyTo(Server.MapPath(Sys.Path2Nbtbrt(strpath1 + "/" + newName)), true);
                            dt.Rows[i][f] = strpath1 + "/" + newName;
                        }
                    }
                    foreach (string f in fld) {
                        System.IO.FileInfo sFi = new System.IO.FileInfo(HttpContext.Current.Server.MapPath(Sys.Path2Nbtbrt(dt.Rows[i].SafeRead(f, ""))));
                        dt.Rows[i][f] = Sys.Path2Nbtbrt(dt.Rows[i].SafeRead(f, ""));
                    }
                }
                /*
                if (submitTask == "AddNext") {//複製模式,改為新檔名
                    foreach (string f in fld) {
                        System.IO.FileInfo sFi = new System.IO.FileInfo(HttpContext.Current.Server.MapPath(Sys.Path2Nbtbrt(dt.Rows[i].SafeRead(f, ""))));
                        if (sFi.Exists) {//因會存其他資料,判斷檔案存在則表示為檔案路徑,才可改為新檔名
                            string strpath1 = sfile.gbrWebDir + "/temp";
                            string newName = br_in_scode + "-" + Path.GetFileName(dt.Rows[i].SafeRead(f, ""));
                            sFi.CopyTo(Server.MapPath(Sys.Path2Nbtbrt(strpath1 + "/" + newName)), true);
                            dt.Rows[i][f] = strpath1 + "/" + newName;
                        }
                    }
                }
                foreach (string f in fld) {
                    System.IO.FileInfo sFi = new System.IO.FileInfo(HttpContext.Current.Server.MapPath(Sys.Path2Nbtbrt(dt.Rows[i].SafeRead(f, ""))));
                    if (sFi.Exists) {//因會存其他資料,判斷檔案存在則表示為檔案路徑,才可改為新檔名
                        dt.Rows[i][f] = Sys.Path2Nbtbrt(dt.Rows[i].SafeRead(f, ""));
                    }
                }
                */
            }
        }
        return dt;
    }
    #endregion

    #region GetCust 客戶主檔資料
    private DataTable GetCust(ref DataTable dt) {
        SQL = "SELECT * ";
        SQL += ",(select min(att_sql) from custz_att c where B.cust_area = C.cust_area AND B.cust_seq = C.cust_seq and (dept='T' or dept is null) )att_sql ";
        SQL += " FROM vcustlist b ";
        SQL += "where cust_area='" + cust_area + "' ";
        SQL += "and cust_seq='" + cust_seq + "'";
        conn.DataTable(SQL, dt);
        return dt;
    }
    #endregion

    #region GetCaseDmt1 子案
    private JArray GetCaseDmt1(ref DataTable dt) {
        SQL = "Select *,''s_marknm from case_dmt1 d ";
        SQL += "left join dmt_temp t on d.in_no=t.in_no and d.case_sqlno=t.case_sqlno ";
        SQL += "where d.in_no='" + in_no + "' ";
        conn.DataTable(SQL, dt);
        for (int i = 0; i < dt.Rows.Count; i++) {
            if (dt.Rows[i].SafeRead("s_mark", "") == "S") {
                dt.Rows[i]["s_marknm"] = "服務";
            } else if (dt.Rows[i].SafeRead("s_mark", "") == "L") {
                dt.Rows[i]["s_marknm"] = "證明";
            } else if (dt.Rows[i].SafeRead("s_mark", "") == "M") {
                dt.Rows[i]["s_marknm"] = "團體標章";
            } else if (dt.Rows[i].SafeRead("s_mark", "") == "N") {
                dt.Rows[i]["s_marknm"] = "團體商標";
            } else if (dt.Rows[i].SafeRead("s_mark", "") == "K") {
                dt.Rows[i]["s_marknm"] = "產地證明標章";
            } else {
                dt.Rows[i]["s_marknm"] = "商標";
            }
        }

        //處理一案多件暫存
        string mark = "";
        if (arcase.IN("FC11,FC5,FC7,FCH,FC21,FC6,FC8,FCI")) {
            mark = "C";
        } else if (arcase.Left(3).IN("FL5,FL6")) {
            mark = "L";
        } else if (arcase == "FT2") {
            mark = "T";
        }
        if (mark != "") {
            //刪除暫存檔
            SQL = "delete from dmt_temp_change where in_scode='" + br_in_scode + "' and cust_area='" + cust_area + "' and cust_seq='" + cust_seq + "' and mark='" + mark + "'";
            conn.ExecuteNonQuery(SQL);
            SQL = "delete from casedmt_good_change where in_scode='" + br_in_scode + "' and cust_area='" + cust_area + "' and cust_seq='" + cust_seq + "' and mark='" + mark + "'";
            conn.ExecuteNonQuery(SQL);
            SQL = "delete from casedmt_show_change where in_scode='" + br_in_scode + "' and cust_area='" + cust_area + "' and cust_seq='" + cust_seq + "' and mark='" + mark + "'";
            conn.ExecuteNonQuery(SQL);
        }

        //對應案件主檔/交辦暫存檔
        JArray jarr = JArray.FromObject(dt);
        foreach (var item in jarr.ToArray()) {
            DataTable dt0 = new DataTable();
            SQL = "select '1' as sort,s_mark,appl_name,apply_no,issue_no,class,''s_marknm from dmt_temp where in_no ='" + item["in_no"] + "' and case_sqlno = '" + item["case_sqlno"] + "' ";
            SQL += "union ";
            SQL += "select '2' as sort,s_mark,appl_name,apply_no,issue_no,class,''s_marknm from dmt where seq='" + item["seq"] + "' and seq1='" + item["seq1"] + "' ";
            SQL += "order by sort ";
            conn.DataTable(SQL, dt0);
            for (int i = 0; i < dt0.Rows.Count; i++) {
                if (dt0.Rows[i].SafeRead("s_mark", "") == "S") {
                    dt0.Rows[i]["s_marknm"] = "服務";
                } else if (dt0.Rows[i].SafeRead("s_mark", "") == "L") {
                    dt0.Rows[i]["s_marknm"] = "證明";
                } else if (dt0.Rows[i].SafeRead("s_mark", "") == "M") {
                    dt0.Rows[i]["s_marknm"] = "團體標章";
                } else if (dt0.Rows[i].SafeRead("s_mark", "") == "N") {
                    dt0.Rows[i]["s_marknm"] = "團體商標";
                } else if (dt0.Rows[i].SafeRead("s_mark", "") == "K") {
                    dt0.Rows[i]["s_marknm"] = "產地證明標章";
                } else {
                    dt0.Rows[i]["s_marknm"] = "商標";
                }
            }
            item["get_dmt"] = JArray.FromObject(dt0);
        }

        return jarr;
    }
    //private DataTable GetCaseDmt1(ref DataTable dt) {
    //    SQL = "Select * from case_dmt1 d ";
    //    SQL += "left join dmt_temp t on d.in_no=t.in_no and d.case_sqlno=t.case_sqlno ";
    //    SQL += "where d.in_no='" + in_no + "' ";
    //    conn.DataTable(SQL, dt);
    //
    //    //處理一案多件暫存
    //    string mark = "";
    //    if (arcase.IN("FC11,FC5,FC7,FCH,FC21,FC6,FC8,FCI")) {
    //        mark = "C";
    //    } else if (arcase.Left(3).IN("FL5,FL6")) {
    //        mark = "L";
    //    } else if (arcase == "FT2") {
    //        mark = "T";
    //    }
    //    if (mark != "") {
    //        //刪除暫存檔
    //        SQL = "delete from dmt_temp_change where in_scode='" + br_in_scode + "' and cust_area='" + cust_area + "' and cust_seq='" + cust_seq + "' and mark='" + mark + "'";
    //        conn.ExecuteNonQuery(SQL);
    //        SQL = "delete from casedmt_good_change where in_scode='" + br_in_scode + "' and cust_area='" + cust_area + "' and cust_seq='" + cust_seq + "' and mark='" + mark + "'";
    //        conn.ExecuteNonQuery(SQL);
    //        SQL = "delete from casedmt_show_change where in_scode='" + br_in_scode + "' and cust_area='" + cust_area + "' and cust_seq='" + cust_seq + "' and mark='" + mark + "'";
    //        conn.ExecuteNonQuery(SQL);
    //
    //        /*
    //        if (prgid != "brt52") {//不是交辦維護
    //            DataTable dt1 = new DataTable();
    //            SQL = "select * from case_dmt1 where in_no= '" + Request["in_no"] + "'";
    //            conn.DataTable(SQL, dt1);
    //            for (int i = 0; i < dt1.Rows.Count; i++) {
    //                SQL = "insert into dmt_temp_change(s_mark,s_mark2,pul,appl_name,cappl_name,eappl_name";
    //                SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
    //                SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color,prior_date,prior_no ";
    //                SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
    //                SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
    //                SQL += ",end_code,dmt_term1,dmt_term2,renewal,seq,seq1,draw_file,class_type ";
    //                SQL += ",class_count,class ";
    //                SQL += ",in_scode,cust_area,cust_seq,num,tr_date,tr_scode,mark) ";
    //                SQL += "Select s_mark,s_mark2 as ts_mark,pul,appl_name,cappl_name,eappl_name ";
    //                SQL += ",eappl_name1,eappl_name2,jappl_name,jappl_name1,jappl_name2,zappl_name1 ";
    //                SQL += ",zappl_name2,zname_type,oappl_name,Draw,symbol,color,prior_date,prior_no ";
    //                SQL += ",prior_country,ref_no,ref_no1,tcn_ref,tcn_class,tcn_name,tcn_mark ";
    //                SQL += ",apply_date,apply_no,issue_date,issue_no,open_date,rej_no,end_date ";
    //                SQL += ",end_code,dmt_term1,dmt_term2,renewal,seq,seq1,draw_file,class_type ";
    //                SQL += ",class_count,class ";
    //                SQL += ",'" + br_in_scode + "','" + cust_area + "','" + cust_seq + "','" + (i + 1) + "' ";
    //                SQL += ",getdate(),'" + Session["scode"] + "','" + mark + "' ";
    //                SQL += "from dmt_temp where in_no='" + in_no + "' and case_sqlno=" + dt1.Rows[i]["case_sqlno"] + "";
    //                conn.ExecuteNonQuery(SQL);
    //
    //                SQL = "INSERT INTO casedmt_good_change(in_scode,cust_area,cust_seq,num,class,dmt_grp_code";
    //                SQL += ",dmt_goodname,dmt_goodcount,tr_date,tr_scode,mark) ";
    //                SQL += "select '" + br_in_scode + "','" + cust_area + "','" + cust_seq + "','" + (i + 1) + "'";
    //                SQL += ",class,dmt_grp_code,dmt_goodname,dmt_goodcount,getdate(),'" + Session["scode"] + "','" + mark + "' ";
    //                SQL += "from casedmt_good where in_no='" + in_no + "' and case_sqlno=" + dt1.Rows[i]["case_sqlno"] + "";
    //                conn.ExecuteNonQuery(SQL);
    //
    //                SQL = "INSERT INTO casedmt_show_change(in_scode,cust_area,cust_seq,num,show_no,show_date";
    //                SQL += ",show_name,tr_date,tr_scode,mark) ";
    //                SQL += "select '" + br_in_scode + "','" + cust_area + "','" + cust_seq + "','" + (i + 1) + "'";
    //                SQL += ",ROW_NUMBER() OVER(ORDER BY show_sqlno),show_date,show_name,getdate()";
    //                SQL += ",'" + Session["scode"] + "','" + mark + "' ";
    //                SQL += "from casedmt_show where in_no='" + in_no + "' and case_sqlno=" + dt1.Rows[i]["case_sqlno"] + " order by show_sqlno";
    //                conn.ExecuteNonQuery(SQL);
    //            }
    //        }*/
    //    }
    //    return dt;
    //}
    #endregion

    #region GetCaseSql 一案多件.dmt_temp子案
    private DataTable GetCaseSql(ref DataTable dt) {
        SQL = "Select *,''s_marknm from dmt_temp where in_no='" + in_no + "' and in_scode='" + br_in_scode + "' and case_sqlno<>0 order by case_sqlno";
        conn.DataTable(SQL, dt);
        for (int i = 0; i < dt.Rows.Count; i++) {
            if (dt.Rows[i].SafeRead("s_mark", "") == "S") {
                dt.Rows[i]["s_marknm"] = "服務";
            } else if (dt.Rows[i].SafeRead("s_mark", "") == "L") {
                dt.Rows[i]["s_marknm"] = "證明";
            } else if (dt.Rows[i].SafeRead("s_mark", "") == "M") {
                dt.Rows[i]["s_marknm"] = "團體標章";
            } else if (dt.Rows[i].SafeRead("s_mark", "") == "N") {
                dt.Rows[i]["s_marknm"] = "團體商標";
            } else if (dt.Rows[i].SafeRead("s_mark", "") == "K") {
                dt.Rows[i]["s_marknm"] = "產地證明標章";
            } else {
                dt.Rows[i]["s_marknm"] = "商標";
            }
        }
        return dt;
    }
    #endregion

    #region AddCR 交辦客收預設值
    private Dictionary<string, string> AddCR() {
        Dictionary<string, string> cr_form = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        if (dtCaseMain.Rows.Count > 0) {
            //cr_form["seq"] = seq;
            //cr_form["seq1"] = seq1;
            //cr_form["in_scode"] = dtCaseMain.Rows[0].SafeRead("in_scode", "");
            //cr_form["in_no"] = in_no;
            //cr_form["cust_area"] = dtCaseMain.Rows[0].SafeRead("cust_area", "");
            //cr_form["cust_seq"] = dtCaseMain.Rows[0].SafeRead("cust_seq", "");

            cr_form["step_date"] = DateTime.Today.ToShortDateString();
            cr_form["cg"] = "C";
            cr_form["rs"] = "R";
            cr_form["cgrs"] = "CR";
            cr_form["send_cl"] = "1";
            cr_form["act_code"] = "_";

            //cr_form["send_way"] = dtCaseMain.Rows[0].SafeRead("send_way", "");//收文方式改由營洽登錄帶入值
            //cr_form["receipt_type"] = dtCaseMain.Rows[0].SafeRead("receipt_type", "");
            //cr_form["receipt_title"] = dtCaseMain.Rows[0].SafeRead("receipt_title", "B");//預設空白

            //cr_form["codemark"] = dtCaseMain.Rows[0].SafeRead("codemark", "");//收文代碼備註：B爭救案
            //cr_form["dmt_term1"] = dtCaseMain.Rows[0].GetDateTimeString("dmt_term1", "yyyy/M/d");//專用期限起日check非創申案有期限者提醒需註記註冊費繳費狀態
            //cr_form["dmt_term2"] = dtCaseMain.Rows[0].GetDateTimeString("dmt_term2", "yyyy/M/d");//專用期限迄日
            //cr_form["cust_date"] = dtCaseMain.Rows[0].GetDateTimeString("cust_date", "yyyy/M/d");//客戶期限
            //cr_form["pr_date"] = dtCaseMain.Rows[0].GetDateTimeString("pr_date", "yyyy/M/d");//承辦期限
            //cr_form["case_last_date"] = dtCaseMain.Rows[0].GetDateTimeString("last_date", "yyyy/M/d");//營洽輸入法定期限

            string spe_ctrl3 = "N";//Y:案性需管制法定期限
            //收文代碼
            SQL = " select rs_type,rs_class,rs_code,rs_detail,case_stat,case_stat_name,spe_ctrl ";
            SQL += "from vcode_act ";
            SQL += "where rs_code = '" + dtCaseMain.Rows[0].SafeRead("arcase", "") + "' and act_code = '_' ";
            SQL += "and rs_type = '" + dtCaseMain.Rows[0].SafeRead("arcase_type", "") + "'";
            SQL += "and cg = 'C' and rs = 'R'";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    cr_form["rs_type"] = dr.SafeRead("rs_type", "");
                    cr_form["rs_class"] = dr.SafeRead("rs_class", "");
                    cr_form["rs_code"] = dr.SafeRead("rs_code", "");
                    cr_form["rs_detail"] = dr.SafeRead("rs_detail", "");
                    cr_form["case_stat"] = dr.SafeRead("case_stat", "");
                    cr_form["case_statnm"] = dr.SafeRead("case_stat_name", "");

                    if (dtCaseMain.Rows[0].SafeRead("back_flag", "") == "Y") {
                        cr_form["rs_detail"] += "(請復案)";
                    }
                    if (dtCaseMain.Rows[0].SafeRead("end_flag", "") == "Y") {
                        cr_form["rs_detail"] += "(請結案)";
                    }

                    string[] spe_ctrl = dr.SafeRead("spe_ctrl", "").Split(',');//抓取案性控制
                    if (spe_ctrl.Length >= 3) spe_ctrl3 = (spe_ctrl[2] == "" ? "N" : spe_ctrl[2]);//是否為爭救案
                }
            }
            cr_form["spe_ctrl3"] = spe_ctrl3;

            //進度序號
            SQL = "select isnull(step_grade,0)+1 from dmt where seq = '" + seq + "' and seq1 = '" + seq1 + "'";
            object objResult = conn.ExecuteScalar(SQL);
            int nstep_grade = (objResult == DBNull.Value || objResult == null) ? 1 : Convert.ToInt32(objResult);
            cr_form["step_grade"] = nstep_grade.ToString();
        }
        return cr_form;
    }
    #endregion

</script>
