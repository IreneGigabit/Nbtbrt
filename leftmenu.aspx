<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data"  %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string SQL = "";

    protected string StrUser = "";
    protected string tdate = "";

    protected string tradeUrl = "";
    protected string sales_scode = "";
    
    protected bool dmtAuth = false;
    protected DataTable dtDmt = new DataTable();
    protected bool dmtGsAuth = false;
    protected DataTable dtGsDmt = new DataTable();

    protected bool extAuth = false;
    protected DataTable dtExt = new DataTable();
    protected bool extGsAuth = false;
    protected DataTable dtGsExt = new DataTable();
    
    protected DataTable dtSales = new DataTable();

    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (cnn != null) cnn.Dispose();
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        cnn = new DBHelper(Conn.ODBCDSN, false).Debug(false);
        conn = new DBHelper(Conn.btbrt, false).Debug(false);
        
        StrUser = Sys.GetSession("sc_name");
        tdate = Request["tdate"] ?? DateTime.Today.ToShortDateString();
        tradeUrl = "http://" + Sys.SIServer + "/Tparea/checklogin.asp?tfx_scode=" + Session["se_scode"] + "&sys_pwd=" + Session["SeSysPwd"] + "&toppage=0&syscode=Tparea&stat=Y";

        //抓取組主管所屬營洽
        sales_scode = Sys.getScode(Sys.GetSession("SeBranch"), Sys.GetSession("scode"));

        if (Sys.Host.Left(3) != "web" && Sys.Host != "localhost") {
            feesctrlMail();//規費提列不足管制過期未銷管Email通知主管,正式環境才執行
        }
        
        QueryDmtData();//內商案件
        QueryDmtGsData();//內商總管處稽催案件
        QueryExtData();//出商案件
        QueryExtGsData();//出商國外所稽催案件
        QuerySalesData();//今日行程

        this.DataBind();
    }

    //內商案件
    private void QueryDmtData() {
        SQL = "select rights ";
        SQL += "from sysctrl.dbo.vrights ";
        SQL += "where branch='" + Session["SeBranch"] + "'";
        SQL += " and dept='" + Session["Dept"] + "'";
        SQL += " and syscode='" + Sys.Sysmenu + "'";
        SQL += " and LoginGrp='" + Session["LoginGrp"] + "'";
        SQL += " and scode='" + Session["scode"] + "'";
        SQL += " and apcode='brta61'";
        SQL += " and beg_date<='" + DateTime.Today.ToShortDateString() + " 00:00:00'";
        SQL += " and (end_date>='" + DateTime.Today.ToShortDateString() + " 23:59:59' or end_date is null)";
        using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                dmtAuth = true;
                int Rights = Convert.ToInt32(dr["Rights"]);
                //區間:前一年到今天加10天
                SQL = "select a.rs_no,a.branch,a.seq,a.seq1,a.ctrl_type,a.ctrl_date,b.scode";
                SQL += ",(select sc_name from sysctrl.dbo.scode where scode=b.scode) as sc_name";
                SQL += ",''scode_style,''ctrl_style,''fseq ";
                SQL += "from ctrl_dmt a ";
                SQL += "inner join dmt b on a.seq=b.seq and a.seq1=b.seq1 ";
                SQL += " where ctrl_date between '" + Util.str2Dateime(tdate).AddMonths(-12).ToShortDateString() + "' and '" + Util.str2Dateime(tdate).AddDays(10).ToShortDateString() + "'";
                SQL += " and left(a.ctrl_type,1) in ('A','B')";
                if (!((Rights & 64) != 0 || (Rights & 256) != 0))  //沒有權限A/C
                    SQL += " and b.scode='" + Session["scode"] + "'";
                SQL += " order by a.ctrl_date,a.seq,a.seq1";
                conn.DataTable(SQL, dtDmt);
                for (int i = 0; i < dtDmt.Rows.Count; i++) {
                    //組案號
                    dtDmt.Rows[i]["fseq"] = dtDmt.Rows[i].SafeRead("Branch", "") + Sys.GetSession("dept") + dtDmt.Rows[i].SafeRead("seq", "");
                    if (dtDmt.Rows[i].SafeRead("seq1", "") != "_" && dtDmt.Rows[i].SafeRead("seq1", "") != "")
                        dtDmt.Rows[i]["fseq"] += "-" + dtDmt.Rows[i].SafeRead("seq1", "");

                    //有權限A或C
                    if (((Rights & 64) != 0 || (Rights & 256) != 0)) {
                        if (dr.SafeRead("scode", "") == Sys.GetSession("scode")) {
                            dtDmt.Rows[i]["scode_style"] = "color:#8b0000;font-style:italic";
                        }
                    }
                    if (dtDmt.Rows[i].SafeRead("ctrl_type", "").Left(1) == "A") {
                        dtDmt.Rows[i]["ctrl_style"] = "color:OrangeRed;font-size:15px";
                    } else {
                        dtDmt.Rows[i]["ctrl_style"] = "color:darkblue;font-size:15px";
                    }
                }
            }
        }
        dmtRepeater.Visible = dmtAuth;
        dmtRepeater.DataSource = dtDmt;
        dmtRepeater.DataBind();
    }

    //內商總管處稽催案件
    private void QueryDmtGsData() {
        SQL = "select rights ";
        SQL += "from sysctrl.dbo.vrights ";
        SQL += "where branch='" + Session["SeBranch"] + "'";
        SQL += " and dept='" + Session["Dept"] + "'";
        SQL += " and syscode='" + Sys.Sysmenu + "'";
        SQL += " and LoginGrp='" + Session["LoginGrp"] + "'";
        SQL += " and scode='" + Session["scode"] + "'";
        SQL += " and apcode='brta37'";
        SQL += " and beg_date<='" + DateTime.Today.ToShortDateString() + " 00:00:00'";
        SQL += " and (end_date>='" + DateTime.Today.ToShortDateString() + " 23:59:59' or end_date is null)";
        using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                dmtGsAuth = true;
                int Rights = Convert.ToInt32(dr["Rights"]);

                string wSQL = "";
                if (((Rights & 64) != 0 && (Rights & 128) != 0))  //權限A+B全部
                    sales_scode = "*";
                else if ((Rights & 128) != 0) //權限B商標
                    sales_scode = "*";
                else if ((Rights & 64) != 0) //權限A組主管
                    wSQL += " and b.scode in (" + sales_scode + ")";
                else {
                    wSQL += " and b.scode='" + Session["scode"] + "'";
                    sales_scode = Sys.GetSession("scode");
                }

                SQL = "select a.*,b.scode ";
                SQL += ",(select sc_name from sysctrl.dbo.scode where scode=b.scode) as scode_name ";
                SQL += ",''fseq,'" + sales_scode.Replace("'", "''") + "' sales_scode,''ctrl_style ";
                SQL += " from ctrlgs_mgt a ";
                SQL += " inner join dmt b on a.seq=b.seq and a.seq1=b.seq1 ";
                SQL += " where a.back_flag = 'N' " + wSQL;
                SQL += " order by a.seq,a.seq1,a.ctrl_date ";
                conn.DataTable(SQL, dtGsDmt);
                for (int i = 0; i < dtGsDmt.Rows.Count; i++) {
                    //組案號
                    dtGsDmt.Rows[i]["fseq"] = Sys.GetSession("seBranch") + Sys.GetSession("dept") + dtGsDmt.Rows[i].SafeRead("seq", "");
                    if (dtGsDmt.Rows[i].SafeRead("seq1", "") != "_" && dtGsDmt.Rows[i].SafeRead("seq1", "") != "")
                        dtGsDmt.Rows[i]["fseq"] += "-" + dtGsDmt.Rows[i].SafeRead("seq1", "");

                    if (dtGsDmt.Rows[i].SafeRead("ctrl_type", "").Left(1) == "A") {
                        dtGsDmt.Rows[i]["ctrl_style"] = "color:OrangeRed;font-size:15px";
                    } else {
                        dtGsDmt.Rows[i]["ctrl_style"] = "color:darkblue;font-size:15px";
                    }
                }
            }
        }
        dmtGsRepeater.Visible = dmtGsAuth;
        dmtGsRepeater.DataSource = dtGsDmt;
        dmtGsRepeater.DataBind();
    }

    //出商案件
    private void QueryExtData() {
        SQL = "select rights ";
        SQL += "from sysctrl.dbo.vrights ";
        SQL += "where branch='" + Session["SeBranch"] + "'";
        SQL += " and dept='" + Session["Dept"] + "'";
        SQL += " and syscode='" + Sys.Sysmenu + "'";
        SQL += " and LoginGrp='" + Session["LoginGrp"] + "'";
        SQL += " and scode='" + Session["scode"] + "'";
        SQL += " and apcode='exta61'";
        SQL += " and beg_date<='" + DateTime.Today.ToShortDateString() + " 00:00:00'";
        SQL += " and (end_date>='" + DateTime.Today.ToShortDateString() + " 23:59:59' or end_date is null)";
        using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                extAuth = true;
                int Rights = Convert.ToInt32(dr["Rights"]);
                //區間:前一年到今天加10天
                SQL = "select a.ctrl_sqlno,a.rs_sqlno,a.branch,a.seq,a.seq1,a.ctrl_type,a.ctrl_date,a.back_num,b.scode";
                SQL += ",(select sc_name from sysctrl.dbo.scode where scode=b.scode) as sc_name";
                SQL += ",''scode_style,''ctrl_style,''fseq,''strmark ";
                SQL += "from ctrl_ext a ";
                SQL += "inner join ext b on a.seq=b.seq and a.seq1=b.seq1 ";
                SQL += " where ctrl_date between '" + Util.str2Dateime(tdate).AddMonths(-12).ToShortDateString() + "' and '" + Util.str2Dateime(tdate).AddDays(10).ToShortDateString() + "'";
                SQL += " and left(a.ctrl_type,1) in ('A','B')";
                if (!((Rights & 64) != 0 || (Rights & 256) != 0))  //沒有權限A/C
                    SQL += " and b.scode='" + Session["scode"] + "'";
                SQL += " order by a.ctrl_date,a.seq,a.seq1";
                conn.DataTable(SQL, dtExt);
                for (int i = 0; i < dtExt.Rows.Count; i++) {
                    //組案號
                    dtExt.Rows[i]["fseq"] = dtExt.Rows[i].SafeRead("Branch", "") + Sys.GetSession("dept") + "E" + dtExt.Rows[i].SafeRead("seq", "");
                    if (dtExt.Rows[i].SafeRead("seq1", "") != "_" && dtExt.Rows[i].SafeRead("seq1", "") != "")
                        dtExt.Rows[i]["fseq"] += "-" + dtExt.Rows[i].SafeRead("seq1", "");

                    //抓取該筆期限最近一次被被程序稽催
                    SQL="select * from ctrlgs_ext where ctrl_sqlno=" +dtExt.Rows[i].SafeRead("ctrl_sqlno", "")+ " and back_flag='N' order by ctrlgs_sqlno desc";
                    using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                        if (dr1.Read()) {
                            dtExt.Rows[i]["strmark"] = "&nbsp;<a href=brt1m/ext15List.asp?prgid=ext15&menuname=出口案期限稽催回覆作業&seq=" + dtExt.Rows[i].SafeRead("seq", "") + "&seq1=" + dtExt.Rows[i].SafeRead("seq1", "") + "&ctrlgs_type=" + dr1.SafeRead("ctrlgs_type", "") + "&qscode=" + dr1.SafeRead("ctrlgs_rscode", "") + "&gtype=B&homelist=homelist target='Etop'><font color=red>*</font></a>";
                       } else {
                            if (Convert.ToInt32("0" + dtExt.Rows[i].SafeRead("count", "")) > 0) {
                                dtExt.Rows[i]["strmark"] = "&nbsp;<a href=brtam/exta71.asp?prgid=exta71&seq=" + dtExt.Rows[i].SafeRead("seq", "") + "&seq1=" + dtExt.Rows[i].SafeRead("seq1", "") + "&gtype=B&homelist=homelist target='Etop'>(" + dtExt.Rows[i].SafeRead("back_num", "") + ")</a>";
                            }
                        }
                    }
                    
                    //有權限A或C
                    if (((Rights & 64) != 0 || (Rights & 256) != 0)) {
                        if (dr.SafeRead("scode", "") == Sys.GetSession("scode")) {
                            dtExt.Rows[i]["scode_style"] = "color:#8b0000;font-style:italic";
                        }
                    }
                    if (dtExt.Rows[i].SafeRead("ctrl_type", "").Left(1) == "A") {
                        dtExt.Rows[i]["ctrl_style"] = "color:OrangeRed;font-size:15px";
                    } else {
                        dtExt.Rows[i]["ctrl_style"] = "color:darkblue;font-size:15px";
                    }
                }
            }
        }
        extRepeater.Visible = extAuth;
        extRepeater.DataSource = dtExt;
        extRepeater.DataBind();
    }

    //出商國外所稽催案件
    private void QueryExtGsData() {
        SQL = "select rights ";
        SQL += "from sysctrl.dbo.vrights ";
        SQL += "where branch='" + Session["SeBranch"] + "'";
        SQL += " and dept='" + Session["Dept"] + "'";
        SQL += " and syscode='" + Sys.Sysmenu + "'";
        SQL += " and LoginGrp='" + Session["LoginGrp"] + "'";
        SQL += " and scode='" + Session["scode"] + "'";
        SQL += " and apcode='exta72'";
        SQL += " and beg_date<='" + DateTime.Today.ToShortDateString() + " 00:00:00'";
        SQL += " and (end_date>='" + DateTime.Today.ToShortDateString() + " 23:59:59' or end_date is null)";
        using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                extGsAuth = true;
                int Rights = Convert.ToInt32(dr["Rights"]);

                string wSQL = "";
                if (((Rights & 64) != 0 && (Rights & 128) != 0))  //權限A+B全部
                    sales_scode = "*";
                else if ((Rights & 128) != 0) //權限B商標
                    sales_scode = "*";
                else if ((Rights & 64) != 0) //權限A組主管
                    wSQL += " and b.scode in (" + sales_scode + ")";
                else {
                    wSQL += " and b.scode='" + Session["scode"] + "'";
                    sales_scode = Sys.GetSession("scode");
                }

                SQL = "select a.*,b.seq as bseq,b.seq1 as bseq1,b.appl_name,b.country,b.scode ";
                SQL += ",(select cust_name from view_cust where view_cust.cust_area = b.cust_area and view_cust.cust_seq = b.cust_seq) as cust_name ";
                SQL += ",(select sc_name from sysctrl.dbo.scode where scode = b.scode) as scode_name ";
                SQL += ",(select code_name from cust_code where code_type = '" + Session["dept"] + "ECT' and cust_code = a.ctrl_type) as ctrl_type_name ";
                SQL += ",''fseq,'" + sales_scode.Replace("'", "''") + "' sales_scode,''ctrl_style ";
                SQL += " from tctrlgs_ext a ";
                SQL += " inner join ext b on a.seq = b.ext_seq and a.seq1 = b.ext_seq1 ";
                SQL += " where back_flag = 'N' " + wSQL;
                SQL += " order by b.seq,b.seq1,a.ctrl_date ";
                conn.DataTable(SQL, dtGsExt);
                for (int i = 0; i < dtGsExt.Rows.Count; i++) {
                    //組案號
                    dtGsExt.Rows[i]["fseq"] = Sys.GetSession("seBranch") + Sys.GetSession("dept") + "E" + dtGsExt.Rows[i].SafeRead("bseq", "");
                    if (dtGsExt.Rows[i].SafeRead("bseq1", "") != "_" && dtGsExt.Rows[i].SafeRead("bseq1", "") != "")
                        dtGsExt.Rows[i]["fseq"] += "-" + dtGsExt.Rows[i].SafeRead("bseq1", "");

                    if (dtGsExt.Rows[i].SafeRead("ctrl_type", "").Left(1) == "A") {
                        dtGsExt.Rows[i]["ctrl_style"] = "color:OrangeRed;font-size:15px";
                    } else {
                        dtGsExt.Rows[i]["ctrl_style"] = "color:darkblue;font-size:15px";
                    }
                }
            }
        }
        extGsRepeater.Visible = extGsAuth;
        extGsRepeater.DataSource = dtGsExt;
        extGsRepeater.DataBind();
    }


    //今日行程
    private void QuerySalesData() {
        SQL = "select sqlno,in_scode,cust_name,beg_hh,beg_mm,arr_type,";
        SQL += "(Select ChRelName from Relation where ChRelType='ARRType' and ChRelNo=arr_type) as typename from saleslist";
        SQL += " where in_scode='" + Session["scode"] + "' and beg_date='" + tdate + "'";
        //SQL += " where in_scode='m912'";
        SQL += " order by beg_hh,beg_mm";
        conn.DataTable(SQL, dtSales);
        for (int i = 0; i < dtSales.Rows.Count; i++) {
        }
        salesRepeater.DataSource = dtSales;
        salesRepeater.DataBind();
    }

    //規費提列不足管制過期未銷管Email通知主管
    private void feesctrlMail() {
        bool mail_flag = false;
        //檢查cust_code.code_type=Z and cust_code.cust_code=TEfc_mail_date的日期
        SQL = "select form_name from cust_code where code_type='Z' and cust_code='TEfc_mail_date' and (end_date is null or end_date>=getdate()) ";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                string mail_date = dr.GetDateTimeString("form_name", "yyyyMMdd");
                if (mail_date == "" || mail_date != DateTime.Today.ToString("yyyyMMdd")) {
                    mail_flag = true;
                }
            }
        }

        if (mail_flag) {
            //期限超過1~2天
            bool task = false;
            SendMail(2, ref task);
            //期限超過3天
            bool task1 = false;
            SendMail(3, ref task);

            //修改cust_code的Email通知日期
            if (task || task1) {
                SQL = "update cust_code set form_name='" + DateTime.Today.ToShortDateString() + "' where code_type='Z' and cust_code='TEfc_mail_date' ";
                conn.ExecuteNonQuery(SQL);
            }
        }
    }
    
    //ptodo=2期限超過1-2天，通知到區所主管,ptodo=3期限超過3天，通知到執委
    private void SendMail(int ptodo, ref bool task) {
        string subject = "", sub_title = "", body = "";
        string strFrom = "";
        List<string> strTo = new List<string>();
        List<string> strCC = new List<string>();
        List<string> strBCC = new List<string>();

        string pdate1 = DateTime.Today.AddDays(-1).ToShortDateString();
        string pdate2 = DateTime.Today.AddDays(-2).ToShortDateString();
        string pdate3 = DateTime.Today.AddDays(-3).ToShortDateString();
        string branchname = "";
        SQL = "select a.branch,b.scode,count(*) as cnt ";
        SQL += " ,(select sc_name from sysctrl.dbo.scode where scode=b.scode) as sc_name ";
        SQL += " ,(select branchname from sysctrl.dbo.branch_code where branch=a.branch) as branchname ";
        SQL += " from feesctrl_ext c inner join attrec_ext a on c.rs_sqlno=a.rs_sqlno inner join ext  as b on a.seq=B.seq and a.seq1=b.seq1 ";
        SQL += " left outer join ctrl_ext d on c.rs_sqlno=d.rs_sqlno and d.ctrl_type='B7' ";
        SQL += " where c.fees_stat='N' ";
        if (ptodo == 2) {
            SQL += " and d.ctrl_date>'" + pdate3 + "' and d.ctrl_date<'" + DateTime.Today.ToShortDateString() + "'";
        } else if (ptodo == 3) {
            SQL += " and d.ctrl_date<='" + pdate3 + "'";
        }
        SQL += " group by a.branch,b.scode ";
        SQL += " order by a.branch,convert(int,substring(b.scode,2,5)) ";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.Read()) {
                task = true;
                branchname = dr.SafeRead("branchname", "").Trim();
                body = "致：各位主管暨同仁<br><br>";
                body += "提供 貴單位各營洽代理人請款尚未對應交辦收費已超過管制期限之案件，明細如下，敬請至「規費提列不足銷管作業」儘速完成銷管，謝謝。<br><br>";
                body += "●尚未對應交辦收費之代收明細：<font color='red'>";
                if (ptodo == 2) {
                    body += "管制期限：" + pdate2 + "~" + pdate1 + "(期限已超過1~2天)<br><br>";
                    sub_title = "(期限已超過1~2天)";
                } else if (ptodo == 3) {
                    body += "管制期限：~" + pdate3 + "(期限已超過3天)<br><br>";
                    sub_title = "(期限已超過3天)";
                }
                body += "</font>";

                do {
                    strCC.Add(dr.SafeRead("scode", "").Trim() + "@saint-island.com.tw");
                    body += "※" + dr.SafeRead("sc_name", "") + "，共" + dr.SafeRead("cnt", "0") + "件<br>";
                } while (dr.Read());
            }
        }

        //明細
        SQL = "select ROW_NUMBER() OVER(PARTITION BY a.branch,b.scode ORDER BY a.conf_date ) AS rank";
        SQL += ",a.branch,a.seq,a.seq1,a.country,a.ext_seq,a.ext_seq1,a.rs_detail,a.conf_date,b.appl_name,b.scode,d.ctrl_date ";
        SQL += " ,(select sc_name from sysctrl.dbo.scode where scode=b.scode) as sc_name ";
        SQL += " ,(select branchname from sysctrl.dbo.branch_code where branch=a.branch) as branchname ";
        SQL += " ,(select (dn_money*dn_rate)+pos_fee+hand_fee from exch_temp where exch_no=c.exch_no and dept='T') as dnnt_money ";
        SQL += " from feesctrl_ext c inner join attrec_ext a on c.rs_sqlno=a.rs_sqlno inner join ext  as b on a.seq=B.seq and a.seq1=b.seq1 ";
        SQL += " left outer join ctrl_ext d on c.rs_sqlno=d.rs_sqlno and d.ctrl_type='B7' ";
        SQL += " where c.fees_stat='N' ";
        if (ptodo == 2) {
            SQL += " and d.ctrl_date>'" + pdate3 + "' and d.ctrl_date<'" + DateTime.Today.ToShortDateString() + "'";
        } else if (ptodo == 3) {
            SQL += " and d.ctrl_date<='" + pdate3 + "'";
        }
        SQL += " order by a.branch,convert(int,substring(b.scode,2,5)),a.conf_date ";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            if (dr.HasRows) {
                body += "<table width='90%' border='1' cellspacing='0' cellpadding='0' style='font-size:10pt'>";
                while (dr.Read()) {
                    if (dr.SafeRead("rank", "") == "1") {
                        body += "<tr align='center' style='BACKGROUND-COLOR:#CCFFFF'>";
                        body += "<td nowrap>營洽</td><td nowrap>本所編號</td><td nowrap>案件名稱</td><td nowrap>國外所案號</td><td nowrap>區所收文日</td>";
                        body += "<td nowrap>收文內容</td><td nowrap>管制期限</td><td nowrap>代理人請款金額(NTD)</td>";
                        body += "</tr>";
                    }
                    string fseq = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), dr.SafeRead("country", ""), dr.SafeRead("branch", ""), Sys.GetSession("dept") + "E");
                    string fextseq = Sys.formatSeq(dr.SafeRead("ext_seq", ""), dr.SafeRead("ext_seq1", ""), "", "", Sys.GetSession("dept") + "E");
                    body += "<tr align='center'>";
                    body += "<td nowrap>" + dr.SafeRead("sc_name", "") + "</td>";
                    body += "<td nowrap>" + fseq + "</td>";
                    body += "<td nowrap>" + dr.SafeRead("appl_name", "").CutData(20) + "</td>";
                    body += "<td nowrap>" + fextseq + "</td>";
                    body += "<td nowrap>" + dr.GetDateTimeString("conf_date", "yyyy/M/d") + "</td>";
                    body += "<td nowrap>" + dr.SafeRead("rs_detail", "") + "</td>";
                    body += "<td nowrap>" + dr.GetDateTimeString("ctrl_date", "yyyy/M/d") + "</td>";
                    body += "<td nowrap>" + dr.SafeRead("dnnt_money", (decimal)0).ToString("N0") + "</td>";
                    body += "</tr>";
                }

                body += "</table>";
            }
        }

        subject = branchname + "商標案件管理系統－規費不足管制期限稽催通知" + sub_title + "通知";

        //抓取部門主管、區所主管
        SQL = "select master_scode from sysctrl.dbo.grpid where grpclass='" + Session["SeBranch"] + "' and (grpid='000' or grpid='T000') order by grplevel desc ";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            while (dr.Read()) {
                strTo.Add(dr.SafeRead("master_scode", "").Trim() + "@saint-island.com.tw");//收件者
            }
        }

        //抓取執委
        if (ptodo == 3) {
            SQL = "select scode from sysctrl.dbo.scode_roles where dept='T' and syscode='" + Session["SeBranch"] + "TBRT' and roles='chair' ";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                while (dr.Read()) {
                    strTo.Add(dr.SafeRead("scode", "").Trim() + "@saint-island.com.tw");//收件者
                }
            }
        }

        switch (Sys.Host) {
            case "web08":
                strFrom = Session["scode"] + "@saint-island.com.tw";
                strTo.Clear();
                strTo.Add(Session["scode"] + "@saint-island.com.tw");
                strCC.Clear();
                subject = "(測試信)" + subject;
                break;
            case "web10":
                strFrom = "administrator@saint-island.com.tw";
                strTo.Clear();
                strTo.Add(Session["scode"] + "@saint-island.com.tw");
                strCC.Clear();
                subject = "(測試信)" + subject;
                break;
            default:
                strFrom = "administrator@saint-island.com.tw";
                break;
        }

        if (task) {
            Sys.DoSendMail(subject, body, strFrom, strTo, strCC, strBCC);
        }
    }
</script>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>今日工作清單</title>
    <link href="inc/setstyle.css" rel="stylesheet" />
    <script type="text/javascript" src="js/lib/jquery-1.12.4.min.js"></script>
    <script type="text/javascript" src="js/util.js"></script>
    <script type="text/javascript" src="js/jquery.Snoopy.date.js"></script>
    <script type="text/javascript" src="js/client_chk.js"></script>
    <style type="text/css">
        .enter{cursor:pointer;background-color: #ffffcc;}
    </style>
</head>
<body style="margin:0px 0px 0px 0px;background:url('images/back02.gif');">
    <form method="post" id="reg" name="reg">
        <table style="font-size:16px" >
        <tr>
	        <td colspan=2 align=center><img src="images/hi.gif"></td></tr>	
        <tr>
        <tr>
            <td width=20%></td>
	        <td valign=buttom><font color=darkblue><%#StrUser%> 您好,</td>
        </tr>
        </table>
        <table border=0 align=center bgcolor=AliceBlue cellspacing=3 cellpadding=0>
        <tr align=center>
	        <td align=center>
	           <img id="prevdate" src="images\arrow_left1.gif" style="cursor:pointer" align="absmiddle">
	           <font size=2 color=darkblue>今天是&nbsp;
               <img id="nextdate" src="images\arrow_right1.gif" style="cursor:pointer" align="absmiddle">
	        </td>
        </tr>
        <tr>
	        <td align=center>
                <font size=2 color=darkblue>&nbsp;
                <input id="tdate" name="tdate" size=10 value="<%#tdate%>">&nbsp;
            </td>
        </tr>
        </table>
    </form>
    <br>
    <div>
    <center>
        <IMG src="images/trade2.jpg" border=0 onclick='window.open("<%#tradeUrl%>")'><br /><br><!--商標園地-->
    </center>
    </div>

<!--內商案件-->
<div align=center size=3 style="color:blue;display:<%#dmtAuth?"none":""%>">無使用權限<br><br></div>
<asp:Repeater id="dmtRepeater" runat="server">
<HeaderTemplate>
	<center><a href="brtam/Brta61.aspx?prgid=Brta61" target="Etop"><img src="images/line9211.gif" border=0></a></center>
    <TABLE id="dmtList" border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
    <thead>
		<TR class=data2 align="center">
			<td nowrap colspan=2>
			<img onclick="opendata(this,'dmtList')" v1="close" src="images/icon_go_down.gif" valign=bottom>&nbsp;內商案件(共<%#dtDmt.Rows.Count%>筆)
			</td>
		</TR> 
    </thead>
    <tbody style="display:none">
        <TR class=lightbluetable align=left>
			<td nowrap>案號</td>
			<td nowrap title="橘紅表法定&客戶期限，深藍表自管&承辦期限"><font color=OrangeRed>法定</font>/<font color=darkblue>自管</font>期限</td>
		</TR> 
</HeaderTemplate>
<ItemTemplate>
    	<TR bgcolor="#FFFFFF" style="color:darkblue;" v0="Eblank" v1="brtam/Brta61edit.aspx?prgid=Brta61&qtype=N&submitTask=Q&gtype=B&homelist=homelist&seq=<%#Eval("seq")%>&seq1=<%#Eval("seq1")%>">
			<td title="<%#Eval("sc_name")%>" style="<%#Eval("scode_style")%>"><%#Eval("fseq")%></td>
			<td style="<%#Eval("ctrl_style")%>"><%#Convert.ToDateTime(Eval("ctrl_date")).ToShortDateString()%></td>
		</TR> 
</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
    <br />
</FooterTemplate>
</asp:Repeater>


<!--內商總管處稽催案件-->
<div align=center size=3 style="color:blue;display:<%#dmtGsAuth?"none":""%>">無使用權限<br><br></div>
<asp:Repeater id="dmtGsRepeater" runat="server">
<HeaderTemplate>
	<center><a href="brtam/Brta61.aspx?prgid=Brta61" target="Etop"><img src="images/line9211.gif" border=0></a></center>
    <TABLE id="dmtGsList" border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
    <thead>
		<TR class=data2 align="center">
			<td nowrap colspan=2>
			<img onclick="opendata(this,'dmtGsList')" v1="close" src="images/icon_go_down.gif" valign=bottom>&nbsp;內商總管處稽催案件(共<%#dtGsDmt.Rows.Count%>筆)
			</td>
		</TR> 
    </thead>
    <tbody style="display:none">
        <TR class=lightbluetable align=left>
			<td nowrap>案號</td>
			<td nowrap title="橘紅表法定&客戶期限，深藍表自管&承辦期限"><font color=OrangeRed>法定</font>/<font color=darkblue>自管</font>期限</td>
		</TR> 
</HeaderTemplate>
<ItemTemplate>
    	<TR bgcolor="#FFFFFF" style="color:darkblue;" v0="Etop" v1="brtam/brta37_list.aspx?prgid=brta37&qback_flag=N&qseq=<%#Eval("seq")%>&qseq1=<%#Eval("seq1")%>&qscode=<%#Eval("scode")%>&sales_scode=<%#Eval("sales_scode")%>">
			<td title="<%#Eval("scode_name")%>"><%#Eval("fseq")%></td>
			<td style="<%#Eval("ctrl_style")%>"><%#Convert.ToDateTime(Eval("ctrl_date")).ToShortDateString()%></td>
		</TR> 
</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
    <br />
</FooterTemplate>
</asp:Repeater>


<!--出商案件-->
<div align=center size=3 style="color:blue;display:<%#extAuth?"none":""%>">無使用權限<br><br></div>
<asp:Repeater id="extRepeater" runat="server">
<HeaderTemplate>
	<center><a href="brtam/Exta61.aspx?prgid=Exta61" target="Etop"><img src="images/line9211.gif" border=0></a></center>
    <TABLE id="extList" border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
    <thead>
		<TR class=data2 align="center">
			<td nowrap colspan=2>
			<img onclick="opendata(this,'extList')" v1="close" src="images/icon_go_down.gif" valign=bottom>&nbsp;出商案件(共<%#dtExt.Rows.Count%>筆)
			</td>
		</TR> 
    </thead>
    <tbody style="display:none">
        <TR class=lightbluetable align=left>
			<td nowrap>案號</td>
			<td nowrap title="橘紅表法定&客戶期限，深藍表自管&承辦期限"><font color=OrangeRed>法定</font>/<font color=darkblue>自管</font>期限</td>
		</TR> 
</HeaderTemplate>
<ItemTemplate>
    	<TR bgcolor="#FFFFFF" style="color:darkblue;" v0="Eblank" v1="brtam/exta61edit.aspx?prgid=exta61&qtype=N&submitTask=Q&gtype=B&homelist=homelist&aseq=<%#Eval("seq")%>&aseq1=<%#Eval("seq1")%>">
			<td title="<%#Eval("sc_name")%>" style="<%#Eval("scode_style")%>"><%#Eval("fseq")%></td>
			<td style="<%#Eval("ctrl_style")%>"><%#Convert.ToDateTime(Eval("ctrl_date")).ToShortDateString()%><%#Eval("strmark")%></td>
		</TR> 
</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
    <br />
</FooterTemplate>
</asp:Repeater>


<!--出商國外所稽催案件-->
<div align=center size=3 style="color:blue;display:<%#extGsAuth?"none":""%>">無使用權限<br><br></div>
<asp:Repeater id="extGsRepeater" runat="server">
<HeaderTemplate>
	<center><a href="brtam/Exta61.aspx?prgid=Exta61" target="Etop"><img src="images/line9211.gif" border=0></a></center>
    <TABLE id="extGsList" border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
    <thead>
		<TR class=data2 align="center">
			<td nowrap colspan=2>
			<img onclick="opendata(this,'extGsList')" v1="close" src="images/icon_go_down.gif" valign=bottom>&nbsp;出商國外所稽催案件(共<%#dtGsExt.Rows.Count%>筆)
			</td>
		</TR> 
    </thead>
    <tbody style="display:none">
        <TR class=lightbluetable align=left>
			<td nowrap>案號</td>
			<td nowrap title="橘紅表法定&客戶期限，深藍表自管&承辦期限"><font color=OrangeRed>法定</font>/<font color=darkblue>自管</font>期限</td>
		</TR> 
</HeaderTemplate>
<ItemTemplate>
    	<TR bgcolor="#FFFFFF" style="color:darkblue;" v0="Etop" v1="brtam/exta72List.aspx?prgid=exta72Q&gtype=B&homelist=homelist&seq=<%#Eval("bseq")%>&seq1=<%#Eval("bseq1")%>&qscode=<%#Eval("scode")%>&sales_scode=<%=sales_scode%>">
			<td title="<%#Eval("scode_name")%>"><%#Eval("fseq")%></td>
			<td style="<%#Eval("ctrl_style")%>"><%#Convert.ToDateTime(Eval("ctrl_date")).ToShortDateString()%></td>
		</TR> 
</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
    <br />
</FooterTemplate>
</asp:Repeater>


<!--今日行程-->
<center><a href="brt2m/calendar.aspx?in_scode=<%=Session["scode"]%>" target="Etop"><img src="images/line9211-1.gif" border=0></a></center>
<asp:Repeater id="salesRepeater" runat="server">
<HeaderTemplate>
    <TABLE id="salesList" border=0 class=bluetable cellspacing=1 cellpadding=2 width="100%">
    <tbody>
		<TR class=data3 align=left style="font-size:10pt;display:<%#dtSales.Rows.Count>0?"":"none"%>">	
			<td width=25%>時間</td>	
		    <td width=25%>方式</td>	
			<td nowrap>客戶</td>
		</TR> 
</HeaderTemplate>
<ItemTemplate>
    	<TR bgcolor="#FFFFFF" style="color:darkblue;" v0="Etop" v1="brt2m/calendar.asp?sqlno=<%#Eval("sqlno")%>&in_scode=<%#Eval("in_scode")%>&Beg_Date=<%=tdate%>">
			<td><%#Eval("beg_hh")%>:<%#Eval("beg_mm")%></td>
			<td><%#Eval("typename")%></td>
			<td><%#Convert.ToString(Eval("cust_name")).Left(4)%></td>
		</TR> 
</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
    <br />
</FooterTemplate>
</asp:Repeater>

</body>
</html>


<script type="text/javascript" language="javascript">
    $(function () {
    });

    function opendata(obj,tbl){
        var toggle = $(obj).attr("v1");//目前狀態
        if (toggle == "close") {
            $(obj).attr("v1", "open");
            $(obj).attr("src", "images/go_up.gif");
            $("#"+tbl+" tbody").show();
        } else {
            $(obj).attr("v1", "close");
            $(obj).attr("src", "images/icon_go_down.gif");
            $("#"+tbl+" tbody").hide();
        }
    };

    $("#dmtList tbody tr:gt(0),#dmtGsList tbody tr:gt(0),#extList tbody tr:gt(0),#extGsList tbody tr:gt(0),#salesList tbody tr:gt(0)").hover(
        function () {
            $(this).addClass("enter");
        },
        function () {
            $(this).removeClass("enter");
        }
    );

    $("#dmtList tbody tr,#dmtGsList tbody tr,#extList tbody tr,#extGsList tbody tr,#salesList tbody tr").click(function (e) {
        var target = $(this).attr("v0");
        var url = $(this).attr("v1");
        if (url !== undefined && url != "") {
            //window.parent.frames.Etop.location.href = url;
            window.parent.frames[target].location.href = url;
        }
    });

    $("#tdate").blur(function (e) {
        if (ChkDate(this)) return false;
        if ($(this).val() == "") {
            alert("日期欄位必須輸入!!!");
            return false;
        }
        goSearch();
    });

    $("#prevdate").click(function (e) {
        var tdate = new Date($("#tdate").val());
        $("#tdate").val(tdate.addDays(-1).format("yyyy/M/d"));
        goSearch(); 
    });

    $("#nextdate").click(function (e) {
        var tdate = new Date($("#tdate").val());
        $("#tdate").val(tdate.addDays(1).format("yyyy/M/d"));
        goSearch();
    });

    function goSearch() {
        reg.submit();
    }
</script>
