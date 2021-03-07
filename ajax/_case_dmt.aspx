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
    protected object objResult = null;

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
    protected string case_no = "";

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
    DataTable dtDmt = new DataTable();//案件主檔
    DataTable dtStepDmtCR = new DataTable();//對應客收進度
    DataTable dtAttCaseDmt = new DataTable();//對應交辦發文檔

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
        Response.Write(",\"dmt\":" + JsonConvert.SerializeObject(GetDmt(ref dtDmt), settings).ToUnicode() + "\n");//案件主檔
        Response.Write(",\"step_cr\":" + JsonConvert.SerializeObject(AddCR(), settings).ToUnicode() + "\n");//交辦客收預設值
        Response.Write(",\"step_dmt_cr\":" + JsonConvert.SerializeObject(GetStepCR(ref dtStepDmtCR), settings).ToUnicode() + "\n");//對應客收進度
        Response.Write(",\"attcase_dmt\":" + JsonConvert.SerializeObject(GetAttCaseDmt(ref dtAttCaseDmt), settings).ToUnicode() + "\n");//對應交辦發文檔
        //Response.Write(",\"step_gs\":" + JsonConvert.SerializeObject(AddGS(), settings).ToUnicode() + "\n");//交辦官發預設值
        Response.Write("}");

        //Response.Write(JsonConvert.SerializeObject(dt, settings).ToUnicode());
    }

    #region GetCase 交辦資料
    private DataTable GetCase(ref DataTable dt) {
        dt = Sys.GetCaseDmtMain(conn, in_no);

        if (dt.Rows.Count > 0) {
            seq = dt.Rows[0].SafeRead("seq", "");
            seq1 = dt.Rows[0].SafeRead("seq1", "");
            case_no = dt.Rows[0].SafeRead("case_no", "");
            code_type = dt.Rows[0].SafeRead("arcase_type", "");
            arcase = dt.Rows[0].SafeRead("arcase", "");
            br_in_scode = dt.Rows[0].SafeRead("in_scode", "");
            br_in_scname = dt.Rows[0].SafeRead("in_scodenm", "");

            if (submitTask == "AddNext") {//圖様改為新檔名
                if (dt.Rows[0].SafeRead("draw_file", "") != "") {
                    System.IO.FileInfo sFi = new System.IO.FileInfo(HttpContext.Current.Server.MapPath(Sys.Path2Nbtbrt(dt.Rows[0].SafeRead("draw_file", ""))));
                    string strpath1 = sfile.gbrWebDir + "/temp";
                    string newName = br_in_scode + "-" + Path.GetFileName(dt.Rows[0].SafeRead("draw_file", ""));
                    sFi.CopyTo(Server.MapPath(Sys.Path2Nbtbrt(strpath1 + "/" + newName)), true);
                    dt.Rows[0]["draw_file"] = Sys.Path2Nbtbrt(strpath1 + "/" + newName);
                }
            }

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
        dt = Sys.GetVCustlist(conn, "", cust_area, cust_seq);
        return dt;
        /*
        SQL = "SELECT * ";
        SQL += ",(select min(att_sql) from custz_att c where B.cust_area = C.cust_area AND B.cust_seq = C.cust_seq and (dept='T' or dept is null) )att_sql ";
        SQL += " FROM vcustlist b ";
        SQL += "where cust_area='" + cust_area + "' ";
        SQL += "and cust_seq='" + cust_seq + "'";
        conn.DataTable(SQL, dt);
        return dt;
        */
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

    #region GetDmt 案件主檔
    private DataTable GetDmt(ref DataTable dt) {
        dt = Sys.GetDmt(conn, seq, seq1);
        return dt;

        //SQL = "Select *,''s_marknm,''custname,''ap_apcust_no,''dmtap_cname,''arcasenm,''now_arcasenm,''now_rsclass ";
        //SQL += "from dmt where seq='" + seq + "' and seq1='" + seq1 + "'";
        //conn.DataTable(SQL, dt);
        //object objResult = null;
        //for (int i = 0; i < dt.Rows.Count; i++) {
        //    if (dt.Rows[i].SafeRead("s_mark", "") == "S") {
        //        dt.Rows[i]["s_marknm"] = "服務";
        //    } else if (dt.Rows[i].SafeRead("s_mark", "") == "L") {
        //        dt.Rows[i]["s_marknm"] = "證明";
        //    } else if (dt.Rows[i].SafeRead("s_mark", "") == "M") {
        //        dt.Rows[i]["s_marknm"] = "團體標章";
        //    } else if (dt.Rows[i].SafeRead("s_mark", "") == "N") {
        //        dt.Rows[i]["s_marknm"] = "團體商標";
        //    } else if (dt.Rows[i].SafeRead("s_mark", "") == "K") {
        //        dt.Rows[i]["s_marknm"] = "產地證明標章";
        //    } else {
        //        dt.Rows[i]["s_marknm"] = "商標";
        //    }
        //
        //    SQL = "select isnull(ap_cname1,'')+isnull(ap_cname2,'')custname from apcust ";
        //    SQL += "where cust_area = '" + dt.Rows[i]["cust_area"] + "' and cust_seq='" + dt.Rows[i]["cust_seq"] + "'";
        //    objResult = conn.ExecuteScalar(SQL);
        //    string custname = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        //    dt.Rows[i]["custname"] = custname;
        //
        //    SQL = "select apcust_no from apcust where apsqlno='" + dt.Rows[i]["apsqlno"] + "'";
        //    objResult = conn.ExecuteScalar(SQL);
        //    string apcust_no = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        //    dt.Rows[i]["ap_apcust_no"] = apcust_no;
        //
        //    SQL = "select apcust_no,ap_cname from dmt_ap where seq='" + seq + "' and seq1='" + seq1 + "'";
        //    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
        //        int ap = 0;
        //        string dmtap_cname = "";
        //        while (dr.Read()) {
        //            ap++;
        //            dmtap_cname += (dmtap_cname != "" ? " " : "") + ap + "." + dr["apcust_no"] + dr["ap_cname"];
        //        }
        //        dt.Rows[i]["dmtap_cname"] = dmtap_cname;
        //    }
        //
        //    //立案案性
        //    SQL = "select rs_detail from code_br where cr='Y' and dept='" + Session["dept"] + "'";
        //    SQL += "and rs_type = '" + dt.Rows[i]["arcase_type"] + "' and rs_code='" + dt.Rows[i]["arcase"] + "'";
        //    objResult = conn.ExecuteScalar(SQL);
        //    string arcasenm = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        //    dt.Rows[i]["arcasenm"] = arcasenm;
        //
        //    //案件狀態
        //    string lf = "cr";
        //    SQL = "select cg,rs from step_dmt where seq=" + seq + " and seq1='" + seq1 + "' ";
        //    SQL += " and step_grade = " + dt.Rows[i]["now_grade"];
        //    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
        //        if (dr.Read()) {
        //            lf = "" + dr["cg"] + dr["rs"];
        //            if (lf.ToUpper() == "ZS") lf = "cr";
        //        }
        //    }
        //
        //    SQL = "select rs_class,rs_detail from code_br where " + lf + "='Y' and dept='" + Session["dept"] + "' ";
        //    SQL += " and rs_type = '" + dt.Rows[i]["now_arcase_type"] + "' and rs_code='" + dt.Rows[i]["now_arcase"] + "'";
        //    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
        //        if (dr.Read()) {
        //            dt.Rows[i]["now_arcasenm"] = dr.SafeRead("rs_detail", "");
        //            dt.Rows[i]["now_rsclass"] = dr.SafeRead("rs_class", "");
        //        }
        //    }
        //}
        //return dt;
    }
    #endregion

    #region AddCR 交辦客收預設值
    private Dictionary<string, string> AddCR() {
        Dictionary<string, string> cr_form = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        if (dtCaseMain.Rows.Count > 0) {
            cr_form["step_date"] = DateTime.Today.ToShortDateString();
            cr_form["cg"] = "C";
            cr_form["rs"] = "R";
            cr_form["cgrs"] = "CR";
            cr_form["send_cl"] = "1";
            cr_form["act_code"] = "_";

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

    #region GetStepCR 對應客收進度
    private DataTable GetStepCR(ref DataTable dt) {
        SQL = "select * from step_dmt where seq='" + seq + "' and seq1='" + seq1 + "' and case_no='"+ case_no +"' and cg='C' and rs='R'";
        conn.DataTable(SQL, dt);
        for (int i = 0; i < dt.Rows.Count; i++) {
        }
        return dt;
    }
    #endregion

    #region GetAttCaseDmt 對應交辦發文檔
    private DataTable GetAttCaseDmt(ref DataTable dt) {
        dt = Sys.GetAttCaseDmt(conn, "", in_no);
        return dt;
        /*
        SQL = "select *,''rs_class_name,''rs_code_name,''act_code_name,''ncase_stat,''ncase_statnm,''rs_agt_nonm,''markb ";
        SQL += "from attcase_dmt where in_no='" + in_no + "'";
        conn.DataTable(SQL, dt);
        for (int i = 0; i < dt.Rows.Count; i++) {
            //取得結構分類、代碼、處理事項名稱
            SQL = "select code_name from cust_code where code_type='" + dt.Rows[i]["rs_type"] + "' and cust_code='" + dt.Rows[i]["rs_class"] + "'";
            objResult = conn.ExecuteScalar(SQL);
            dt.Rows[i]["rs_class_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            SQL = "select rs_detail from code_br where rs_type='" + dt.Rows[i]["rs_type"] + "' and rs_code='" + dt.Rows[i]["rs_code"] + "' and gs='Y' ";
            dt.Rows[i]["rs_class_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            SQL = "select code_name from cust_code where code_type='tact_code' and cust_code='" + dt.Rows[i]["act_code"] + "'";
            dt.Rows[i]["act_code_name"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            //取得案件狀態
            SQL = "select a.cust_code,a.code_name from cust_code a inner join vcode_act b on a.cust_code = b.case_stat ";
            SQL += " where a.code_type='tcase_stat'";
            SQL += "   and b.dept='" + Session["dept"] + "' and b.cg='G' and b.rs='S'";
            SQL += "   and b.rs_class='" + dt.Rows[i]["rs_class"] + "'";
            SQL += "   and b.rs_code='" + dt.Rows[i]["rs_code"] + "'";
            SQL += "   and b.act_code='" + dt.Rows[i]["act_code"] + "'";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    dt.Rows[i]["ncase_stat"] = dr.SafeRead("cust_code", "");
                    dt.Rows[i]["ncase_statnm"] = dr.SafeRead("code_name", "");
                }
            }

            //取得發文出名代理人
            SQL = "select treceipt,agt_name from agt where agt_no='" + dt.Rows[i]["rs_agt_no"] + "'";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    dt.Rows[i]["rs_agt_nonm"] = dr.SafeRead("treceipt", "") + "_" + dr.SafeRead("agt_name", "");
                }
            }

            //取得案性mark
            SQL = "select mark from code_br where dept='T' and rs_type='" + dt.Rows[i]["rs_type"] + "' and rs_class='" + dt.Rows[i]["rs_class"] + "' and rs_code='" + dt.Rows[i]["rs_code"] + "' and gs='Y'";
            dt.Rows[i]["markb"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        }
        return dt;
        */
    }
    #endregion

    #region AddGS 交辦官發預設值
    private Dictionary<string, string> AddGS() {
        Dictionary<string, string> gs_form = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        if (dtCaseMain.Rows.Count > 0) {
            gs_form["fees"] = "0";
            gs_form["fees_stat"] = "N";
            gs_form["step_date"] = DateTime.Today.ToShortDateString();
            //總收發文日期
            //台北所總收發當天就會發文
            gs_form["mp_date"] = DateTime.Today.ToShortDateString();
            if (Sys.GetSession("seBranch") != "N") {
                switch (DateTime.Today.DayOfWeek) {
                    case DayOfWeek.Friday: gs_form["mp_date"] = DateTime.Today.AddDays(3).ToShortDateString(); break;//星期五加三天
                    case DayOfWeek.Saturday: gs_form["mp_date"] = DateTime.Today.AddDays(2).ToShortDateString(); break;//星期六加兩天
                    default: gs_form["mp_date"] = DateTime.Today.AddDays(1).ToShortDateString(); break;//加一天
                }
            }
            //2011/2/18依2010/12/15李協理Email需求，結構分類：C4_行政訴訟預設發文對象為Q_智慧財產法院
            if (dtDmt.Rows[0].SafeRead("now_rsclass", "") == "C4") {
                gs_form["send_cl"] = "Q";
            } else {
                gs_form["send_cl"] = "1";
            }

            gs_form["send_cl1"] = "";
            gs_form["send_sel"] = "";
            gs_form["rs_type"] = dtCaseMain.Rows[0].SafeRead("arcase_type", "");
            gs_form["rs_class"] = dtCaseMain.Rows[0].SafeRead("arcase_class", "");
            gs_form["rs_code"] = dtCaseMain.Rows[0].SafeRead("arcase", "");


            //gs_form["cg"] = "Gc";
            //gs_form["rs"] = "S";
            //gs_form["cgrs"] = "GS";
            //gs_form["send_cl"] = "1";
            //gs_form["act_code"] = "_";


            //string spe_ctrl3 = "N";//Y:案性需管制法定期限
            ////收文代碼
            //SQL = " select rs_type,rs_class,rs_code,rs_detail,case_stat,case_stat_name,spe_ctrl ";
            //SQL += "from vcode_act ";
            //SQL += "where rs_code = '" + dtCaseMain.Rows[0].SafeRead("arcase", "") + "' and act_code = '_' ";
            //SQL += "and rs_type = '" + dtCaseMain.Rows[0].SafeRead("arcase_type", "") + "'";
            //SQL += "and cg = 'C' and rs = 'R'";
            //using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            //    if (dr.Read()) {
            //        gs_form["rs_type"] = dr.SafeRead("rs_type", "");
            //        gs_form["rs_class"] = dr.SafeRead("rs_class", "");
            //        gs_form["rs_code"] = dr.SafeRead("rs_code", "");
            //        gs_form["rs_detail"] = dr.SafeRead("rs_detail", "");
            //        gs_form["case_stat"] = dr.SafeRead("case_stat", "");
            //        gs_form["case_statnm"] = dr.SafeRead("case_stat_name", "");
            //
            //        if (dtCaseMain.Rows[0].SafeRead("back_flag", "") == "Y") {
            //            gs_form["rs_detail"] += "(請復案)";
            //        }
            //        if (dtCaseMain.Rows[0].SafeRead("end_flag", "") == "Y") {
            //            gs_form["rs_detail"] += "(請結案)";
            //        }
            //
            //        string[] spe_ctrl = dr.SafeRead("spe_ctrl", "").Split(',');//抓取案性控制
            //        if (spe_ctrl.Length >= 3) spe_ctrl3 = (spe_ctrl[2] == "" ? "N" : spe_ctrl[2]);//是否為爭救案
            //    }
            //}
            //gs_form["spe_ctrl3"] = spe_ctrl3;
            //
            ////進度序號
            //SQL = "select isnull(step_grade,0)+1 from dmt where seq = '" + seq + "' and seq1 = '" + seq1 + "'";
            //object objResult = conn.ExecuteScalar(SQL);
            //int nstep_grade = (objResult == DBNull.Value || objResult == null) ? 1 : Convert.ToInt32(objResult);
            //gs_form["step_grade"] = nstep_grade.ToString();
        }
        return gs_form;
    }
    #endregion
</script>
