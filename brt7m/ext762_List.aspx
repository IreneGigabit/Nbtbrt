<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<script runat="server">
    protected string HTProgCap = "請款綜合查詢作業-預計請款記錄";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Ext762";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> ColMap = new Dictionary<string, string>();
    protected Paging page = null;
    protected DataTable dtHead = new DataTable();

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";

    protected int chk_progright = 0, uninput_cnt = 0;//存檔權限、未填寫筆數
    protected string chk_progcode = "", sales_scode = "", tfx_cust_seq = "", qryin_scode = "", sc_name = "";
    protected string qs_dept = "", case_Table = "", qrypr_status = "", qrytr_yy = "", qrytr_mm = "", td_scode = "", preardate_style = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connacc = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connacc != null) connacc.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        connacc = new DBHelper(Conn.account).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        qs_dept = (Request["qs_dept"] ?? "").ToLower();
        if (qs_dept == "t") {
            HTProgCode = "Brt76";
            chk_progcode = "Brt71";//檢查請款單開立作業權限
            case_Table = "case_dmt";
        } else if (qs_dept == "e") {
            HTProgCode = "Ext76";
            chk_progcode = "Ext71";//檢查請款單開立作業權限
            case_Table = "case_ext";
        }

        qrypr_status = (Request["qrypr_status"] ?? "").ToUpper();//作業狀態
        //作業年月、是否顯示預計請款日
        if (qrypr_status == "Y") {//已填寫
            qrytr_yy = ReqVal.TryGet("qrytr_yy");
            qrytr_mm = ReqVal.TryGet("qrytr_mm");
            preardate_style = "display:";
        } else {
            qrytr_yy = DateTime.Today.Year.ToString();
            qrytr_mm = DateTime.Today.ToString("MM");
            preardate_style = "display:none";
        }

        //請款客戶
        tfx_cust_seq = ReqVal.TryGet("tfx_cust_seq");
        if (ReqVal.TryGet("acust_seq") != "") {
            tfx_cust_seq = ReqVal.TryGet("acust_seq");
        }

        //營洽
        qryin_scode = ReqVal.TryGet("qryin_scode");
        if (qryin_scode == "") {
            qryin_scode = ReqVal.TryGet("scode");
        }

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title + "-預計請款記錄 ";
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            PreData();//預先準備資料
            SumData();//表頭資料
            QueryData();//清單資料
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a href=Ext76.aspx?prgid=" + prgid + "&qs_dept=" + qs_dept + ">[回請款單查詢]</a>";
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";

        if (ReqVal.TryGet("ar_mark") == "A") {
            HTProgCap += "請款種類：一般+實報實銷 ";
        }
        if (ReqVal.TryGet("ar_mark") == "D") {
            HTProgCap += "請款單種類：扣收入案件(不開收據) ";
        }

        //存檔權限
        SQL = "Select rights from loginAP where syscode='" + Session["Syscode"] + "' and loginGrp='" + Session["LoginGrp"] + "' and beg_date<=GETDATE() and end_date>=GETDATE() AND (APcode='" + chk_progcode + "') ";
        using (DBHelper connsys = new DBHelper(Conn.ODBCDSN).Debug(false)) {
            chk_progright = Convert.ToInt32(connsys.getZero(SQL));
        }
        if ((chk_progright & 4) > 0) {
            StrFormBtn += "<input type=button value ='存　檔' class='cbutton bsubmit' onclick=\"formSubmit('save')\">\n";
        }

        //抓取營洽人員
        DataTable dtscode = new DataTable();
        SQL = "select distinct scode,sc_name,scode1 from vscode_roles ";
        SQL += " where branch='" + Session["SeBranch"] + "' and dept='" + Session["Dept"] + "' and syscode='" + Session["syscode"] + "' and roles='sales'";
        SQL += " order by scode1 ";
        cnn.DataTable(SQL, dtscode);
        var list = dtscode.AsEnumerable().Select(r => r.Field<string>("scode")).ToArray();
        sales_scode = "'" + string.Join("','", list) + "'";

        //營洽清單
        if ((HTProgRight & 64) != 0) {
            td_scode = "<select id='qryin_scode' name='qryin_scode'>";
            td_scode += dtscode.Option("{scode}", "{scode}_{sc_name}", true, qryin_scode);
            td_scode += "<option value=\"*\" style=\"color:blue\" " + (qryin_scode == "*" ? "selected" : "") + ">全部</option>";
            td_scode += "</select>";
        } else {
            td_scode = "<input type='hidden' id='qryin_scode' name='qryin_scode' value='" + Session["scode"] + "'>";
            td_scode += "<input type='text' id='ScodeName' name='ScodeName' readonly class='SEdit' value='" + Session["sc_name"] + "'>";
        }
    }

    //預先準備資料
    private void PreData() {
        //從請款綜合查詢進來時才執行,換頁/修改條件後不執行
        if (ReqVal.TryGet("qryform") == "Y") {
            //抓取入檔資料
            if (qs_dept == "t") {
                SQL = "SELECT b.seq,b.seq1,b.in_no,B.In_scode, B.case_no,'T' as country,B.Service as service, B.Fees,B.add_service,B.add_fees ";
                SQL += ",B.ar_service,B.ar_fees,isnull(b.oth_money,0) as tr_money ";
                SQL += " from case_dmt b ";
                SQL += " inner join view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq ";
                SQL += " WHERE (B.stat_code = 'YZ') and b.ar_code='N' and (B.mark='N' or B.mark is null or B.mark='') ";
            } else {
                SQL = "SELECT b.seq,b.seq1,b.in_no,B.In_scode, B.case_no,c.country,B.tot_Service as service, B.tot_Fees as fees, B.add_service,B.add_fees ";
                SQL += ",B.ar_service,B.ar_fees ,isnull(b.oth_money,0) as tr_money ";
                SQL += "FROM case_ext B ";
                SQL += "INNER JOIN ext_temp C ON B.In_no = C.in_no AND B.In_scode = C.in_scode and c.case_sqlno=0 ";
                SQL += " inner join view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq ";
                SQL += "WHERE (B.invoice_chk='B' or B.invoice_chk='C') ";
                SQL += "and (B.stat_code = 'YZ' or B.stat_code like 'S%') and b.ar_code='N' and (B.mark='N' or B.mark ='' or B.mark is null) ";
            }
            //營洽人員
            if (qryin_scode == "" || qryin_scode == "*") {
                SQL += " and b.in_scode in (" + sales_scode + ")";
            } else {
                SQL += " and b.in_scode ='" + qryin_scode + "'";
            }
            //請款客戶
            if (tfx_cust_seq != "") {
                SQL += " and b.cust_area ='" + Session["seBranch"] + "' and b.cust_seq = '" + tfx_cust_seq + "'";
            }
            //客戶名稱
            if (ReqVal.TryGet("cust_name") != "") {
                SQL += " and f.cust_name like '" + ReqVal.TryGet("cust_name") + "%' ";
            }
            //本所編號
            if (ReqVal.TryGet("bseq") != "") {
                SQL += " and b.seq between " + ReqVal.TryGet("bseq") + " and " + ReqVal.TryGet("eseq");
            }
            //交辦期間-起
            if (ReqVal.TryGet("scdate") != "") {
                SQL += " and b.case_date >= '" + ReqVal.TryGet("scdate") + "'";
            }
            //交辦期間-迄
            if (ReqVal.TryGet("ecdate") != "") {
                SQL += " and b.case_date <= '" + ReqVal.TryGet("ecdate") + "'";
            }
            //請款單種類-一般+實報實銷案件
            if (ReqVal.TryGet("ar_mark") == "A") {
                SQL += " and b.ar_mark <> 'D' ";
            }
            //請款單種類-扣收入案件(不開收據)
            if (ReqVal.TryGet("ar_mark") == "D") {
                SQL += " and b.ar_mark = 'D' ";
            }
            //規費支出-已支出
            if (ReqVal.TryGet("spkind") == "gs_fees") {//已發文支出未請款，2012/3/14增加為畫面查詢條件
                SQL += " and b.gs_fees>0";
            }
            //規費支出-未支出
            if (ReqVal.TryGet("spkind") == "N") {//規費未支出，2012/3/14增加為畫面查詢條件
                SQL += " and b.gs_fees=0";
            }
            Sys.showLog("預先準備=" + SQL);
            DataTable dtpre = new DataTable();
            conn.DataTable(SQL, dtpre);

            for (int i = 0; i < dtpre.Rows.Count; i++) {
                DataRow rs1 = dtpre.Rows[i];
                bool addData = false, haveData = false;
                //檢查該年月及交辦單號有無資料，無資料才入檔
                SQL = "select * from prear_brt ";
                SQL += "where case_no='" + rs1.SafeRead("case_no", "") + "' and country='" + rs1.SafeRead("country", "") + "' ";
                SQL += "order by sqlno desc";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        if (dr0.SafeRead("tr_yy", "") != qrytr_yy && dr0.SafeRead("tr_mm", "") != qrytr_mm) {
                            haveData = true;//有舊資料,預計請款資料依之前資料寫入
                        }
                    } else {
                        addData = true;//無資料,新增一筆
                    }

                    if (haveData == true || addData == true) {
                        SQL = "insert into prear_brt ";
                        ColMap.Clear();
                        ColMap["tr_yy"] = Util.dbchar(qrytr_yy);
                        ColMap["tr_mm"] = Util.dbchar(qrytr_mm);
                        ColMap["input_scode"] = "'" + Session["scode"] + "'";
                        ColMap["input_date"] = "getdate()";
                        ColMap["in_scode"] = Util.dbchar(rs1.SafeRead("in_scode", ""));
                        ColMap["in_no"] = Util.dbchar(rs1.SafeRead("in_no", ""));
                        ColMap["case_no"] = Util.dbchar(rs1.SafeRead("case_no", ""));
                        ColMap["seq"] = Util.dbnull(rs1.SafeRead("seq", ""));
                        ColMap["seq1"] = Util.dbchar(rs1.SafeRead("seq1", ""));
                        ColMap["country"] = Util.dbchar(rs1.SafeRead("country", ""));
                        ColMap["service"] = Util.dbzero(rs1.SafeRead("service", ""));
                        ColMap["fees"] = Util.dbzero(rs1.SafeRead("fees", ""));
                        ColMap["tr_money"] = Util.dbzero(rs1.SafeRead("tr_money", ""));
                        ColMap["add_service"] = Util.dbzero(rs1.SafeRead("add_service", ""));
                        ColMap["add_fees"] = Util.dbzero(rs1.SafeRead("add_fees", ""));
                        ColMap["ar_service"] = Util.dbzero(rs1.SafeRead("ar_service", ""));
                        ColMap["ar_fees"] = Util.dbzero(rs1.SafeRead("ar_fees", ""));
                        ColMap["invoice_mark"] = Util.dbchar("B");
                        if (haveData == true) {
                            ColMap["prear_date"] = Util.dbnull(dr0.GetDateTimeString("prear_date", "yyyy/M/d HH:mm:ss"));
                            ColMap["noar_code"] = Util.dbnull(dr0.SafeRead("noar_code", ""));
                            ColMap["noar_remark"] = Util.dbnull(dr0.SafeRead("noar_remark", ""));
                        }
                        SQL += ColMap.GetInsertSQL();
                        dr0.Close();
                        conn.ExecuteNonQuery(SQL);
                        Sys.showLog("新增prear_brt_2=" + SQL);
                    }
                }
            }
        }
    }

    private void SumData() {
        if (qrypr_status == "Y") {
            //本月
            //string tr_yy1=qrytr_yy;
            //string tr_mm1=qrytr_mm;
            ////下月
            //string tr_yy2 = Convert.ToDateTime(qrytr_yy + "/" + tr_mm1 + "/1").AddMonths(1).Year.ToString();
            //string tr_mm2 = Convert.ToDateTime(qrytr_yy + "/" + tr_mm1 + "/1").AddMonths(1).ToString("MM");
            ////非本/下月
            //string tr_yy3= Convert.ToDateTime(qrytr_yy + "/" + tr_mm1 + "/1").AddMonths(2).Year.ToString();
            //string tr_mm3 = Convert.ToDateTime(qrytr_yy + "/" + tr_mm1 + "/1").AddMonths(2).ToString("MM");
            //Sys.showLog(tr_yy1 + "," + tr_mm1);
            //Sys.showLog(tr_yy2 + "," + tr_mm2);
            //Sys.showLog(tr_yy3 + "," + tr_mm3);

            string wsql = "", swsql = "", statsql = "";
            if (qryin_scode == "" || qryin_scode == "*") {
                wsql = " and a.in_scode in (" + sales_scode + ")";
                swsql = " and c.in_scode in (" + sales_scode + ")";
            } else {
                wsql = " and a.in_scode in ('" + qryin_scode + "')";
                swsql = " and c.in_scode in ('" + qryin_scode + "')";
            }

            if (qs_dept == "t") {
                wsql += " and a.country='T'";
                swsql += " and c.country='T'";
                statsql = " b.stat_code='YZ'";
            } else {
                wsql += " and a.country<>'T'";
                swsql += " and c.country<>'T'";
                statsql = " (b.stat_code='YZ' or B.stat_code like 'S%')";
            }
            SQL = "select a.invoice_mark,a.tr_yy,a.tr_mm";
            SQL += ",isnull((select sum(c.service+c.tr_money+c.add_service-c.ar_service) from prear_brt c inner join " + case_Table + " b on c.in_no=b.in_no and c.in_scode=b.in_scode and " + statsql + " and b.ar_code='N' and (b.mark='' or b.mark is null or b.mark='N')  where c.tr_yy=a.tr_yy and c.tr_mm=a.tr_mm and c.invoice_mark=a.invoice_mark and datediff(month,getdate(), c.prear_date)<=0 " + swsql + "),0) as service1";
            SQL += ",isnull((select sum(c.service+c.tr_money+c.add_service-c.ar_service) from prear_brt c inner join " + case_Table + " b on c.in_no=b.in_no and c.in_scode=b.in_scode and " + statsql + " and b.ar_code='N' and (b.mark='' or b.mark is null or b.mark='N')  where c.tr_yy=a.tr_yy and c.tr_mm=a.tr_mm and c.invoice_mark=a.invoice_mark and datediff(month,getdate(), c.prear_date)=1" + swsql + "),0) as service2";
            SQL += ",isnull((select sum(c.service+c.tr_money+c.add_service-c.ar_service) from prear_brt c inner join " + case_Table + " b on c.in_no=b.in_no and c.in_scode=b.in_scode and " + statsql + " and b.ar_code='N' and (b.mark='' or b.mark is null or b.mark='N')  where c.tr_yy=a.tr_yy and c.tr_mm=a.tr_mm and c.invoice_mark=a.invoice_mark and datediff(month,getdate(), c.prear_date)>1" + swsql + "),0) as service3";
            SQL += ",isnull((select sum(c.service+c.tr_money+c.add_service-c.ar_service) from prear_brt c inner join " + case_Table + " b on c.in_no=b.in_no and c.in_scode=b.in_scode and " + statsql + " and b.ar_code='N' and (b.mark='' or b.mark is null or b.mark='N')  where c.tr_yy=a.tr_yy and c.tr_mm=a.tr_mm and c.invoice_mark=a.invoice_mark and c.prear_date is null " + swsql + "),0) as service4";
            SQL += " from prear_brt a ";
            SQL += " inner join " + case_Table + " b on a.in_scode=b.in_scode and a.in_no=b.in_no ";
            SQL += " where a.case_no=a.case_no and a.tr_yy='" + qrytr_yy + "' and a.tr_mm='" + qrytr_mm + "' and a.invoice_mark='" + Request["qryinvoice_mark"] + "'" + wsql;
            SQL += " and " + statsql + " and b.ar_code='N' and (b.mark='N' or b.mark ='' or b.mark is null) ";
            SQL += " group by a.invoice_mark,a.tr_yy,a.tr_mm";
            conn.DataTable(SQL, dtHead);
            //資料綁定
            headRepeater.DataSource = dtHead;
            headRepeater.DataBind();
        }
    }

    private void QueryData() {
        if (qs_dept == "t") {
            //2008/1/9業務出名代理人，修改收據別依交辦出名代理人對應抓取
            //ref:vcase_dmt
            SQL = "SELECT b.seq,b.seq1,b.in_no,B.In_scode, B.case_no,f.cust_name,t.appl_name,B.Service ";
            SQL += ",B.Fees,B.add_service,B.add_fees,isnull(b.oth_money,0) as tr_money,B.arcase,B.ar_service,B.ar_fees ";
            SQL += ",B.Service + B.Fees+isnull(b.add_service,0)+isnull(b.add_fees,0)+isnull(b.oth_money,0) AS allcost ";
            SQL += ",B.ar_mark,B.case_date,B.Cust_area, B.Cust_seq,b.change,b.case_stat,b.arcase_type ";
            SQL += ",(select Rs_detail from code_br where rs_code=b.arcase and cr='Y' and dept='T' and rs_type=b.arcase_type) as CArcase ";
            SQL += ",(SELECT rs_class FROM code_br WHERE rs_code = b.arcase AND dept = 'T' AND cr = 'Y' and rs_type=b.arcase_type) AS Ar_form ";
            SQL += ",(select treceipt from agt where agt_no=t.agt_no) as receipt ";
            SQL += ",(select code_name from cust_code where code_type='ar_mark' and cust_code=b.ar_mark) as ar_marknm ";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=b.in_scode) as sc_name ";
            SQL += ",a.sqlno,a.prear_date,a.noar_code,a.noar_remark,b.arcase_class,D.remark as progpath,'T'country ";
            SQL += ",''fseq,''strar_mark,''noar_remark_style,''urlasp ";
            SQL += " from case_dmt b ";
            SQL += " inner join dmt_temp t ON b.in_scode = t.in_scode AND b.in_no = t.in_no AND t.case_sqlno = 0 ";
            SQL += " inner join view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq ";
            SQL += " inner join cust_code D on d.code_type=b.arcase_type and d.cust_code='__' ";
            SQL += " inner join prear_brt a on b.case_no=a.case_no and a.country='T' AND a.tr_yy='" + qrytr_yy + "' AND a.tr_mm='" + qrytr_mm + "' ";
            SQL += " WHERE (B.stat_code = 'YZ') and b.ar_code='N' and (B.mark='N' or B.mark is null or B.mark='') ";
        } else {
            SQL = "SELECT b.seq,b.seq1,b.in_no,B.In_scode, B.case_no,f.cust_name,t.appl_name,B.tot_service as Service ";
            SQL += ",B.tot_Fees as fees, B.add_service,B.add_fees,B.arcase,B.ar_service,B.ar_fees ";
            SQL += ",B.tot_Service + B.tot_Fees+isnull(b.oth_money,0) AS allcost ";
            SQL += ",B.ar_mark,B.case_date,B.Cust_area, B.Cust_seq,isnull(b.oth_money,0) as tr_money,b.change,b.case_stat,b.arcase_type ";
            SQL += ",(select Rs_detail from code_ext where rs_code=b.arcase and cr_flag='Y' and rs_type=b.arcase_type) as CArcase ";
            SQL += ",(select rs_class  from code_ext where rs_code=b.arcase and cr_flag='Y' and rs_type=b.arcase_type) as ar_form ";
            SQL += ",(select code_name from cust_code where code_type='ar_mark' and cust_code=b.ar_mark) as ar_marknm ";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=b.in_scode) as sc_name ";
            SQL += ",a.sqlno,a.prear_date,a.noar_code,a.noar_remark,B.arcase_class as prt_code,a.country ";
            SQL += ",''fseq,''strar_mark,''noar_remark_style,''urlasp ";
            SQL += " from case_ext b ";
            SQL += " inner join ext_temp t ON b.In_no = t.in_no AND b.In_scode = t.in_scode and t.case_sqlno=0 ";
            SQL += " inner join view_cust F on F.cust_area = B.cust_area and F.cust_seq=B.cust_seq ";
            SQL += " inner join prear_brt a on b.case_no=a.case_no and a.country<>'T' AND a.tr_yy='" + qrytr_yy + "' AND a.tr_mm='" + qrytr_mm + "' ";
            SQL += " WHERE (B.invoice_chk='B' or B.invoice_chk='C') and (B.stat_code = 'YZ' or B.stat_code like 'S%') and b.ar_code='N' and (B.mark='N' or B.mark is null or B.mark='') ";
        }
        //全部
        if (qryin_scode == "" || qryin_scode == "*") {
            SQL += " and b.in_scode in (" + sales_scode + ")";
        } else {
            SQL += " and b.in_scode ='" + qryin_scode + "'";
        }
        if (ReqVal.TryGet("tfx_cust_seq") != "") {
            SQL += " and b.cust_area ='" + Session["seBranch"] + "' and b.cust_seq = '" + ReqVal.TryGet("tfx_cust_seq") + "'";
        }
        if (ReqVal.TryGet("cust_name") != "") {
            SQL += "AND f.cust_name like '" + ReqVal["cust_name"] + "%' ";
        }
        if (ReqVal.TryGet("bseq") != "") {
            SQL += "AND b.seq between " + ReqVal["bseq"] + " and " + ReqVal["eseq"] + " ";
        }
        //交辦期間
        if (ReqVal.TryGet("scdate") != "") {
            SQL += "AND b.case_date>='" + ReqVal["scdate"] + "' ";
        }
        if (ReqVal.TryGet("ecdate") != "") {
            SQL += "AND b.case_date<='" + ReqVal["ecdate"] + "' ";
        }
        if (ReqVal.TryGet("ar_mark") == "A") {//一般+實報實銷
            SQL += "and b.ar_mark <>'D' ";
        }
        if (ReqVal.TryGet("ar_mark") == "D") {//扣收入(不開收據)
            SQL += "and b.ar_mark ='D' ";
        }
        if (ReqVal.TryGet("spkind") == "gs_fees") {//規費已支出
            SQL += "and b.gs_fees>0 ";
        }
        if (ReqVal.TryGet("spkind") == "N") {//規費未支出
            SQL += "and b.gs_fees=0 ";
        }

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "f.cust_name,b.case_no"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        DataTable dtBase = new DataTable();
        conn.DataTable(SQL, dtBase);//全部(已填寫+未填寫)
        Sys.showLog(SQL);

        //計算未填寫件數用
        string strFilter1 = "(prear_date is null or noar_code is null or noar_code='')";

        //依查詢條件篩選
        string strFilter2 = "";
        if (qrypr_status == "N") {//未填寫
            strFilter2 = "(prear_date is null or noar_code is null or noar_code='') ";
        }
        if (qrypr_status == "Y") {//已填寫
            strFilter2 = "prear_date is not null and noar_code is not null ";
            if (ReqVal.TryGet("qrysprear_date") != "") {
                strFilter2 += " and prear_date>='" + ReqVal.TryGet("qrysprear_date") + "'";
            }
            if (ReqVal.TryGet("qryeprear_date") != "") {
                strFilter2 += " and prear_date<='" + ReqVal.TryGet("qryeprear_date") + "'";
            }
        }

        //未填寫件數
        uninput_cnt = dtBase.Select(strFilter1).Count();

        //畫面清單
        //DataTable dt = dtRpt.Select(strFilter2).CopyToDataTable();
        var rows = dtBase.Select(strFilter2);
        var dt = rows.Any() ? rows.CopyToDataTable() : dtBase.Clone();

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "20"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //案號
            dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), (dr.SafeRead("country", "") == "T" ? "" : dr.SafeRead("country", "")), "", "");
            //請款註記
            if (dr.SafeRead("ar_mark", "") != "N") {
                dr["strar_mark"] = "<font color=red>" + dr.SafeRead("ar_marknm", "");
            }
            if (dr.SafeRead("noar_code", "").Left(1) == "Z") {
                dr["noar_remark_style"] = "display:";
            } else {
                dr["noar_remark_style"] = "display:none;";
            }

            //交辦畫面連結
            if (qs_dept == "t") {
                dr["urlasp"] = Sys.getCaseDmt11Aspx(prgid, dr.SafeRead("in_no", ""), dr.SafeRead("in_scode", ""), "Show");
            } else if (qs_dept == "e") {
                dr["urlasp"] = Sys.getCaseExt11Aspx(prgid, dr.SafeRead("in_no", ""), dr.SafeRead("in_scode", ""), "Show");
            }

            //營洽
            if (qryin_scode == "" || qryin_scode == "*") {
                sc_name = "全部";
            } else {
                sc_name = dr.SafeRead("sc_name", "");
            }
        }

        //資料綁定
        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //未請款原因
    protected string GetNoARCode(RepeaterItem Container) {
        string noar_code = Eval("noar_code").ToString();
        return Sys.getCustCode("noar_codeT", "", "sortfld").Option("{cust_code}", "{code_name}", true, noar_code);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.branch = "<%#Session["SeBranch"]%>";
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
</script>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%> <%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form style="margin:0;" id="reg" name="reg" method="post">
<input type="hidden" name="prgid" id="prgid" value="<%=prgid%>">
<input type=hidden id=qs_dept name=qs_dept value=<%=qs_dept%>>
<input type=hidden id=acust_seq name=acust_seq value=<%=tfx_cust_seq%>>
<input type=hidden id=apsqlno name=apsqlno value=<%=Request["apsqlno"]%>>
<input type=hidden id=tobject name=tobject value=<%=Request["tobject"]%>>
<input type=hidden id=ar_mark name=ar_mark value=<%=Request["ar_mark"]%>>
<input type=hidden name="case_Table" id="case_Table" value=<%=case_Table%>>
<input type=hidden id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 
<input type=hidden id=homelist name=homelist value="<%=Request["homelist"]%>">

<!--<input type=hidden id=todo name=todo value="<%=Request["todo"]%>">-->
<!--<input type=hidden id=scdate name=scdate value="<%=Request["scdate"]%>">-->
<!--<input type=hidden id=ecdate name=ecdate value="<%=Request["ecdate"]%>">-->
<!--<input type=hidden id=sdate name=sdate value="<%=Request["sdate"]%>">-->
<!--<input type=hidden id=edate name=edate value="<%=Request["edate"]%>">-->
<!--<input type=hidden id=todate name=todate value="<%=Request["todate"]%>">-->
<!--<input type=hidden id=spkind name=spkind value="<%=Request["spkind"]%>">-->
<!--<input type=hidden id=cust_name name=cust_name value="<%=Request["cust_name"]%>">-->
<!--<input type=hidden id=bseq name=bseq value="<%=Request["bseq"]%>">-->
<!--<input type=hidden id=eseq name=eseq value="<%=Request["eseq"]%>">-->

<INPUT type="hidden" name="rows_prear_sqlno" id="rows_prear_sqlno">
<INPUT type="hidden" name="rows_in_scode" id="rows_in_scode">
<INPUT type="hidden" name="rows_in_no" id="rows_in_no">
<INPUT type="hidden" name="rows_case_no" id="rows_case_no">
<INPUT type="hidden" name="rows_seq" id="rows_seq">
<INPUT type="hidden" name="rows_seq1" id="rows_seq1">
<INPUT type="hidden" name="rows_country" id="rows_country">
<INPUT type="hidden" name="rows_service" id="rows_service">
<INPUT type="hidden" name="rows_fees" id="rows_fees">
<INPUT type="hidden" name="rows_tr_money" id="rows_tr_money">
<INPUT type="hidden" name="rows_add_service" id="rows_add_service">
<INPUT type="hidden" name="rows_add_fees" id="rows_add_fees">
<INPUT type="hidden" name="rows_ar_service" id="rows_ar_service">
<INPUT type="hidden" name="rows_ar_fees" id="rows_ar_fees">
<INPUT type="hidden" name="rows_hchk_flag" id="rows_hchk_flag">
<INPUT type="hidden" name="rows_prear_date" id="rows_prear_date">
<INPUT type="hidden" name="rows_noar_code" id="rows_noar_code">
<INPUT type="hidden" name="rows_noar_remark" id="rows_noar_remark">

    <table border="0" cellspacing="1" cellpadding="2" width="100%">
		<tr>
			<td class="text9">
				◎作業狀態: <label><input type="radio" name="qrypr_status" value="N" <%#qrypr_status == "N" ? "checked" : ""%>>未填寫<font color=red>(<%=uninput_cnt%>)</font></label>
							<label><input type="radio" name="qrypr_status" value="Y" <%#qrypr_status == "Y" ? "checked" : ""%>>已填寫</label>
							<label><input type="radio" name="qrypr_status" value="" <%#qrypr_status == "" ? "checked" : ""%>>全部</label>
			</td>
			<td class="text9">
				◎作業年月: <input type="text" id="qrytr_yy" name="qrytr_yy" size="4" value="<%=qrytr_yy%>" disabled>年/<input type="text" id="qrytr_mm" name="qrytr_mm" size="2" value="<%=qrytr_mm%>" disabled>月
			</td>
		<tr>
			<td class="text9">
				◎營洽人員:<%#td_scode%>
			</td>
			<td class="text9">
				<span id="span_prear_date" style=<%=preardate_style%>>
				◎預計請款日: <input type="text" id="qrysprear_date" name="qrysprear_date" size="10" value="<%#ReqVal.TryGet("qrysprear_date")%>" class="dateField">~
							  <input type="text" id="qryeprear_date" name="qryeprear_date" size="10" value="<%#ReqVal.TryGet("qryeprear_date")%>" class="dateField">
							  <label><input type="checkbox" name="case_chk" id="case_chk" <%#ReqVal.TryGet("qryeprear_date") == "" ? "checked" : ""%>>不指定</label>
				</span>
                <input type="button" value="查詢" class="cbutton" onClick="goSearch()" id=button1 name=button1>
				<input type="hidden" id="qryinvoice_mark" name="qryinvoice_mark" value="B">
			</td>
		</tr>
    </table>

    <div id="divPaging" style="display:<%#page.totRow==0?"none":""%>">
    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
	    <tr>
		    <td colspan=2 align=center>
			    <font size="2" color="#3f8eba">
				    第<font color="red"><span id="NowPage"><%#page.nowPage%></span>/<span id="TotPage"><%#page.totPage%></span></font>頁
				    | 資料共<font color="red"><span id="TotRec"><%#page.totRow%></span></font>筆
				    | 跳至第
				    <select id="GoPage" name="GoPage" style="color:#FF0000"><%#page.GetPageList()%></select>
				    頁
				    <span id="PageUp" style="display:<%#page.nowPage>1?"":"none"%>">| <a href="javascript:void(0)" class="pgU" v1="<%#page.nowPage - 1%>">上一頁</a></span>
				    <span id="PageDown" style="display:<%#page.nowPage<page.totPage?"":"none"%>">| <a href="javascript:void(0)" class="pgD" v1="<%#page.nowPage + 1%>">下一頁</a></span>
				    | 每頁筆數:
				    <select id="PerPage" name="PerPage" style="color:#FF0000">
					    <option value="10" <%#page.perPage == 10 ? "selected" : ""%>>10</option>
					    <option value="20" <%#page.perPage == 20 ? "selected" : ""%>>20</option>
					    <option value="30" <%#page.perPage == 30 ? "selected" : ""%>>30</option>
					    <option value="50" <%#page.perPage == 50 ? "selected" : ""%>>50</option>
				    </select>
                    <input type="hidden" name="SetOrder" id="SetOrder" value="<%#ReqVal.TryGet("qryOrder")%>" />
			    </font>
		    </td>
	    </tr>
    </TABLE>
    </div>

<div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

    <asp:Repeater id="headRepeater" runat="server">
 		<ItemTemplate>
		<table style="display:<%#dtHead.Rows.Count==0?"none":""%>" align="center" border=0 width="80%" cellspacing="1" cellpadding="1" class="bluetable">
		<tr align="center" class="lightbluetable">
			<td>營洽</td>
			<td>本月預計請款服務費</td>
			<td>下月預計請款服務費</td>
			<td colspan=2>非本/下月預計請款服務費</td>
			<td>未請款服務費合計</td>
		</tr>
		<tr align="center" >
			<td class="sfont9" rowspan=2><%=sc_name%></td>
			<td class="sfont9" rowspan=2><%#Eval("service1")%></td><!--本月預計請款服務費-->
			<td class="sfont9" rowspan=2><%#Eval("service2")%></td><!--下月預計請款服務費-->
			<td class="lightbluetable">已填請款日</td>
			<td class="lightbluetable">未填寫請款日</td>
			<td class="sfont9" rowspan=2><%#(Convert.ToDecimal(Eval("service1")) + Convert.ToDecimal(Eval("service2")) + Convert.ToDecimal(Eval("service3")) + Convert.ToDecimal(Eval("service4")))%></td><!--未請款服務費合計-->
		</tr>
		<tr class="sfont9" align="center"><!--非本/下月預計請款服務費-->
			<td><%#Eval("service3")%></td><!--已填請款日-->
			<td><%#Eval("service4")%></td><!--未填寫請款日-->
		</tr>
		</table>
        <br />
  		</ItemTemplate>
    </asp:Repeater>

    <asp:Repeater id="dataRepeater" runat="server">
    <HeaderTemplate>
 		<ItemTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                <Tr class="lightbluetable" align="center">
	                <td nowrap><u class="setOdr" v1="b.in_scode">營洽</u></td> 
	                <td nowrap><u class="setOdr" v1="f.cust_name">客戶名稱</u></td>    
	                <td nowrap><u class="setOdr" v1="b.case_date">交辦日期</u></td>  
	                <td nowrap><u class="setOdr" v1="b.seq,b.seq1">案件<br>編號</u></td>
	                <td nowrap><u class="setOdr" v1="t.appl_name">案件名稱</u></td>
	                <td nowrap><u class="setOdr" v1="b.ar_mark">請款<br>註記</u></td>
	                <td nowrap><u class="setOdr" v1="b.arcase">案性</u></td>
	                <td nowrap>未稅服務費</td>
	                <td nowrap>未稅規費</td>
	                <td nowrap>合計</td>
	                <td nowrap><u class="setOdr" v1="a.prear_date">預計請款日</u></td>
	                <td nowrap><u class="setOdr" v1="a.noar_code">未請款原因</u></td>
                </Tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			<ItemTemplate>
 		        <tr align="center" class="<%#(Container.ItemIndex + 1) % 2 == 1 ? "sfont9" : "lightbluetable3"%>">
		            <td nowrap>
		                <input type="hidden" id="prear_sqlno_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("sqlno")%>">
		                <input type="hidden" id="in_scode_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("in_scode")%>">
		                <input type="hidden" id="in_no_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("in_no")%>">
		                <input type="hidden" id="case_no_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("case_no")%>">
		                <input type="hidden" id="seq_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("seq")%>">
		                <input type="hidden" id="seq1_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("seq1")%>">
		                <input type="hidden" id="country_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("country")%>">
		                <input type="hidden" id="service_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("service")%>">
		                <input type="hidden" id="fees_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("fees")%>">
		                <input type="hidden" id="tr_money_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("tr_money")%>">
		                <input type="hidden" id="add_service_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("add_service")%>">
		                <input type="hidden" id="add_fees_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("add_fees")%>">
		                <input type="hidden" id="ar_service_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("ar_service")%>">
		                <input type="hidden" id="ar_fees_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("ar_fees")%>">
		                <input type="hidden" id="hchk_flag_<%#(Container.ItemIndex + 1)%>" value="N">
		                <a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("sc_name")%></a>
		            </td>
		            <td ><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("cust_name").ToString().ToUnicode().CutData(12)%></a></td>
		            <td ><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("case_date", "{0:d}")%></a></td>
		            <td ><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("fseq")%></a></td>	
		            <td ><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("appl_name").ToString().ToUnicode().CutData(20)%></a></td>
		            <td ><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("strar_mark")%></a></td>
		            <td ><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("CArcase")%></a></td>
		            <td ><a href="<%#Eval("urlasp")%>" target="Eblank"><%#(Convert.ToDecimal(Eval("service")) + Convert.ToDecimal(Eval("tr_money")) + Convert.ToDecimal(Eval("add_service")) - Convert.ToDecimal(Eval("ar_service")))%></a></td>
		            <td ><a href="<%#Eval("urlasp")%>" target="Eblank"><%#(Convert.ToDecimal(Eval("fees")) + Convert.ToDecimal(Eval("add_fees")) - Convert.ToDecimal(Eval("ar_fees")))%></a></td>
		            <td ><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("allcost")%></a></td>
		            <td><input type="text" id="prear_date_<%#(Container.ItemIndex + 1)%>" size=10 onblur="prear_dateonblur('<%#(Container.ItemIndex + 1)%>')" value="<%#Eval("prear_date", "{0:d}")%>"></td>
		            <td><select id="noar_code_<%#(Container.ItemIndex + 1)%>" onchange="noarcode_change('<%#(Container.ItemIndex + 1)%>')"><%#GetNoARCode(Container)%></select>
			            <span id="span_noar_remark_<%#(Container.ItemIndex + 1)%>" style="<%#Eval("noar_remark_style")%>"><br>
                        說明：<input type="text" id="noar_remark_<%#(Container.ItemIndex + 1)%>" size=30 value="<%#Eval("noar_remark")%>"></span>
		            </td>
		        </tr>
			</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>
	    <div align="center" style="display:<%#page.totRow==0?"none":""%>">
            <%#StrFormBtn%>
        </div>
	    <BR>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div style="color:blue">
                    ※作業說明:<br>
                    1.存檔是以頁為資料儲存單位，若有超過2頁以上，請先於第1頁輸入並存檔完成後，再繼續執行下一頁；每頁筆數最多50筆。<br>
                    2.只要「預計請款日」與「未請款原因」其中有一個未填寫，「作業狀態」就屬於未填寫。<br>
                    3.必須先執行「存檔」，才能產製word檔。<br>
                    ※記錄欄位說明:<br>
                    1.各項金額為尚未請款金額，未稅服務費=交辦服務費(含轉帳費用)+追加請款服務費-已請款服務費，未稅規費=交辦規費+追加請款規費-已請款規費。<br>
                    ※word檔欄位說明:<br>
                    1.本月預計請款服務費：以查詢條件之「作業年月」為基準，計算當月未請款服務費。<br>
                    2.下月預計請款服務費：以查詢條件之「作業年月」為基準，計算下個月未請款服務費。<br>
                    3.非本/下月預計請款服務費：以查詢條件之「作業年月」為基準，計算下二個月以後未請款或是未填寫預計請款日之服務費。<br>
			    </div>
		    </td>
            </tr>
	    </table>
	    <br>
    </FooterTemplate>
    </asp:Repeater>

    <%#DebugStr%>
</form>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="300" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }
        this_init();
    });

    //執行查詢
    function goSearch() {
        if($("input[name='qrypr_status']:checked").val()=="Y"){//已填寫
            if ($("#qrytr_yy").val()==""){
                alert("請輸入作業年度！");
                return false;
            }
            if ($("#qrytr_mm").val()==""){
                alert("請輸入作業月份！");
                return false;
            }
        }

        $("#qrytr_yy").prop("disabled",false);
        $("#qrytr_mm").prop("disabled",false);

        reg.target = "_self";
        reg.action = "ext762_List.aspx";
        $("#reg").submit();
    }

    function this_init() {
        $(".Lock").lock();
        $("input.dateField").datepick();

        $("input[id^='prear_date_']").datepick({ 
            onClose: function(dates) { $(this).triggerHandler("blur"); }
        });
    }
    //////////////////////
    //未請款原因
    function noarcode_change(pno){
        $("#noar_remark_"+pno).val("");
        //選項Z開頭需顯示說明欄
        if ($("#noar_code_"+pno).val().Left(1)=="Z") {
            $("#span_noar_remark_"+pno).show();
        }else{
            if ($("#noar_code_"+pno).val()!=""){
                $("#noar_remark_"+pno).val( $("#noar_code_"+pno).find("option:selected").text() );
            }
            $("#span_noar_remark_"+pno).hide();
        }
    }

    //預計請款日檢查
    function prear_dateonblur(pno){
        var gname=$("#prear_date_"+pno).val();
        if (gname=="") return false;
        if (isNaN(new Date(gname))){
            alert("日期格式錯誤，請重新輸入!!! 日期格式:YYYY/MM/DD");
            $("#prear_date_"+pno).val("");
            $("#prear_date_"+pno).focus();
            return false;
        }
	
        //預計請款日不能小於作業日
        if(CDate(gname).getTime()< Today().getTime()){
            alert("輸入預計請款日不能小於系統日，請重新輸入！");
            $("#prear_date_"+pno).val("");
            $("#prear_date_"+pno).focus();
            return false;
        }
    }

    //作業狀態判斷是否顯示預計請款日
    $("input[name=qrypr_status]").on("click",function(){
        if($("input[name='qrypr_status']:checked").val()=="Y"){
            $("#span_prear_date").show();
        }else{
            $("#span_prear_date").hide();
        }
    });

    //存檔
    function formSubmit(A){
        var today=new Date();
        //檢查需輸入作業年月
        if ($("#qrytr_yy").val()=="" || $("#qrytr_mm").val()==""){
            alert("請輸入作業年度及月份！");
            return false;
        }else{
            //因預計請款日不能小於作業日，若年月不同在統計會有問題
            if ( $("#qrytr_yy").val()!=today.getFullYear() ){
                alert("輸入作業年度非作業日年度，請檢查！");
                return false;
            }
            if ( $("#qrytr_mm").val()!=(today.getMonth()+1) ){
                alert("輸入作業月份非作業日月份，請檢查！");
                return false;
            }
        }
	
        var totnum=0;
        for (var x = 1; x <= CInt($("#row").val()) ; x++) {
            if ( !($("#prear_date_"+x).val()=="" && $("#noar_code_"+x).val()=="" ) ){
                if ( $("#noar_code_"+x).val().substr(0, 1)=="Z" && $("#noar_remark_"+x).val()=="" ) {
                    alert("未請款原因選擇「其他」，請輸入「說明」！");
                    $("#noar_remark_"+x).focus();
                    return false;
                }
                totnum++;
                $("#hchk_flag_"+x).val("Y");
            }
        }
	
        if (totnum==0){
            alert("尚未輸入任何資料，毋須存檔！");
            return false;
        }else{
            var tans = confirm("共有" + totnum + "筆存檔 , 是否確定?");
            if (tans ==false) return false;

            //串接資料
            $("#rows_prear_sqlno").val(getJoinValue("#dataList>tbody input[id^='prear_sqlno_']"));
            $("#rows_in_scode").val(getJoinValue("#dataList>tbody input[id^='in_scode_']"));
            $("#rows_in_no").val(getJoinValue("#dataList>tbody input[id^='in_no_']"));
            $("#rows_case_no").val(getJoinValue("#dataList>tbody input[id^='case_no_']"));
            $("#rows_seq").val(getJoinValue("#dataList>tbody input[id^='seq_']"));
            $("#rows_seq1").val(getJoinValue("#dataList>tbody input[id^='seq1_']"));
            $("#rows_country").val(getJoinValue("#dataList>tbody input[id^='country_']"));
            $("#rows_service").val(getJoinValue("#dataList>tbody input[id^='service_']"));
            $("#rows_fees").val(getJoinValue("#dataList>tbody input[id^='fees_']"));
            $("#rows_tr_money").val(getJoinValue("#dataList>tbody input[id^='tr_money_']"));
            $("#rows_add_service").val(getJoinValue("#dataList>tbody input[id^='add_service_']"));
            $("#rows_add_fees").val(getJoinValue("#dataList>tbody input[id^='add_fees_']"));
            $("#rows_ar_service").val(getJoinValue("#dataList>tbody input[id^='ar_service_']"));
            $("#rows_ar_fees").val(getJoinValue("#dataList>tbody input[id^='ar_fees_']"));
            $("#rows_hchk_flag").val(getJoinValue("#dataList>tbody input[id^='hchk_flag_']"));
            $("#rows_prear_date").val(getJoinValue("#dataList>tbody input[id^='prear_date_']"));
            $("#rows_noar_code").val(getJoinValue("#dataList>tbody select[id^='noar_code_']"));
            $("#rows_noar_remark").val(getJoinValue("#dataList>tbody input[id^='noar_remark_']"));

            $("input:disabled, select:disabled").unlock();
            $(".bsubmit").lock(!$("#chkTest").prop("checked"));

            var formData = new FormData($('#reg')[0]);
            ajaxByForm("Ext762_Update.aspx",formData)
            .complete(function( xhr, status ) {
                $("#dialog").html(xhr.responseText);
                $("#dialog").dialog({
                    title: '存檔訊息',modal: true,maxHeight: 500,width: 800,closeOnEscape: false
                });
            });
        }
    }

    //[返回清單](update呼叫)
    function ext762submit(){
        $("input[name='qrypr_status'][value='N']").prop("checked",true); //只顯示未填寫
        goSearch();//重新查詢
    }

    //[產生word檔](update呼叫)
    function ext762print(){
        $("#dialog").dialog("close");
        reg.target = "ActFrame";
        reg.action = "ext762_word.aspx";
        reg.submit();
    }
</script>