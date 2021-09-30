<%@Page Language="C#" CodePage="65001"%>
<%@Import Namespace = "System"%>
<%@Import Namespace = "System.IO"%>
<%@Import Namespace = "System.Data"%>
<%@Import Namespace = "System.Data.SqlClient"%>
<%@Import Namespace = "System.Collections.Generic"%>
<%@Import Namespace = "NPOI.XSSF.UserModel"%>
<%@Import Namespace = "NPOI.SS.UserModel"%>

<script runat="server">
    protected DBHelper conn = null;
    string seq, seq1, mseq, mseq1;
    string scode, qcountry, qappl_name;
    string s_mark, pul, sclass;
    string cust_area, cust_seq;
    string ap_cname1, apcust_no, ap_cname;
    string qagent_no, qagent_no1, qagent_nm;
    string kind_no, ref_no, kind_date;
    string sdate, edate, qryend, end_code;

    private void Page_Load(System.Object sender, System.EventArgs e) {
        //Response.CacheControl = "no-cache";
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        Response.Clear();

        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();
        mseq = (Request["mseq"] ?? "").Trim();
        mseq1 = (Request["mseq1"] ?? "").Trim();
        scode = (Request["scode"] ?? "").Trim();
        qcountry = (Request["qcountry"] ?? "").Trim();
        qappl_name = (Request["qappl_name"] ?? "").Trim();
        s_mark = (Request["s_mark"] ?? "").Trim();
        pul = (Request["pul"] ?? "").Trim();
        sclass = (Request["class"] ?? "").Trim();
        cust_area = (Request["cust_area"] ?? "").Trim();
        cust_seq = (Request["cust_seq"] ?? "").Trim();
        ap_cname1 = (Request["ap_cname1"] ?? "").Trim();
        apcust_no = (Request["apcust_no"] ?? "").Trim();
        ap_cname = (Request["ap_cname"] ?? "").Trim();
        qagent_no = (Request["qagent_no"] ?? "").Trim();
        qagent_no1 = (Request["qagent_no1"] ?? "").Trim();
        qagent_nm = (Request["qagent_nm"] ?? "").Trim();
        kind_no = (Request["kind_no"] ?? "").Trim();
        ref_no = (Request["ref_no"] ?? "").Trim();
        kind_date = (Request["kind_date"] ?? "").Trim();
        sdate = (Request["sdate"] ?? "").Trim();
        edate = (Request["edate"] ?? "").Trim();
        qryend = (Request["qryend"] ?? "").Trim();
        end_code = (Request["end_code"] ?? "").Trim();

        ExcelOut();
    }

    private void ExcelOut() {
        string tplPath = Server.MapPath("~/ReportTemplate/出口案件資料查詢.xlsx");

        FileStream file = new FileStream(tplPath, FileMode.Open, FileAccess.Read);
        IWorkbook workbook = new XSSFWorkbook(file);
        ISheet oSheet = workbook.GetSheetAt(0);
        ISheet tSheet = workbook.GetSheetAt(1); //樣本格式來源sheet
        
        //處理報表抬頭部分
        string rptTitle = "";
        if (seq != "" || seq1 != "") rptTitle += "、◎本所編號：" + seq + "-" + seq1;
        if (mseq != "" || mseq1 != "") rptTitle += "、◎母案編號：" + mseq + "-" + mseq1;
        if (scode != "") rptTitle += "、◎營洽：" + scode;
        if (qcountry != "") rptTitle += "、◎國別：" + qcountry;
        if (qappl_name != "") rptTitle += "、◎案件名稱(含)：" + qappl_name;
        if (s_mark != "") {
            rptTitle += "、◎商標種類：";
            if (s_mark == "T") rptTitle += "商標";
            if (s_mark == "S") rptTitle += "服務";
            if (s_mark == "L") rptTitle += "證明";
            if (s_mark == "M") rptTitle += "團體";
        }
        if (pul != "") {
            rptTitle += "、◎正聯防：";
            if (pul == "0") rptTitle += "正商標";
            if (pul == "1") rptTitle += "聯合";
            if (pul == "2") rptTitle += "防護";
        }
        if (sclass != "") rptTitle += "、◎類別(含)：" + sclass;
        if (cust_seq != "") rptTitle += "、◎客戶編號：" + cust_area + cust_seq;
        if (ap_cname1 != "") rptTitle += "、◎客戶名稱(含)：" + ap_cname1;
        if (apcust_no != "") rptTitle += "、◎申請人編號(含)：" + apcust_no;
        if (ap_cname != "") rptTitle += "、◎申請人名稱(含)：" + ap_cname;
        if (qagent_no != "" || qagent_no1 != "") rptTitle += "、◎代理人號：" + qagent_no + "-" + qagent_no1;
        if (qagent_nm != "") rptTitle += "、◎代理人名稱(含)：" + qagent_nm;
        if (kind_no != "") {
            rptTitle += "、◎文號種類：";
            if (kind_no == "Apply_No") rptTitle += "申請號碼";
            if (kind_no == "Issue_No") rptTitle += "註冊號碼";
            if (kind_no == "renewal_No") rptTitle += "延展號碼";
        }
        if (ref_no != "") rptTitle += "、◎官方文號：" + ref_no;

        if (kind_date == "") rptTitle += "、◎日期種類：不指定";
        if (kind_date == "In_Date") rptTitle += "、◎日期種類：立案日期";
        if (kind_date == "Apply_Date") rptTitle += "、◎日期種類：申請日期";
        if (kind_date == "Issue_Date") rptTitle += "、◎日期種類：註冊日期";
        if (kind_date == "renewal_Date") rptTitle += "、◎日期種類：延展日期";
        if (kind_date == "End_Date") rptTitle += "、◎日期種類：結案日期";
        if (kind_date == "term2") rptTitle += "、◎日期種類：專用期限迄日";
        if (sdate != "" || edate != "") rptTitle += "、◎日期期間：" + sdate + "~" + edate;

        if (qryend != "") {
            rptTitle += "、◎結案代碼：";
            if (kind_no == "Y") rptTitle += "尚未結案";
            if (kind_no == "N") rptTitle += "已結案" + (end_code != "" ? "(" + end_code + ")" : "");
        }

        oSheet.Pos(0, 11).SetValue("◎列印日期：" + DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss"));
        oSheet.Pos(1, 0).SetValue(rptTitle.Substring(1));

        int irow = 3; //開始處理行數(從0開始)
        int dbCnt = 0; //資料筆數
        DataTable dt = new DataTable();
        getData(dt);

        foreach (DataRow dr in dt.Rows) {
            dbCnt++;

            //顯示明細
            if (irow % 2 == 0)//從樣版複製明細行(連樣式一起複製),單雙行不同色
                oSheet.Row(irow).CopyRow(tSheet, 3);
            else
                oSheet.Row(irow).CopyRow(tSheet, 4);

            oSheet.Pos(irow, 0).SetValue(dr["cust_area"].ToString());//區所別
            oSheet.Pos(irow, 1).SetValue(dr["seq"].ToString());//本所編號
            oSheet.Pos(irow, 2).SetValue(dr["seq1"].ToString());//副號
            oSheet.Pos(irow, 3).SetValue(dr["country"].ToString());//國別
            oSheet.Pos(irow, 4).SetValue(dr["class"].ToString());//類別
            oSheet.Pos(irow, 5).SetValue(dr["now_statnm"].ToString());//案件狀態
            oSheet.Pos(irow, 6).SetValue(dr["appl_name"].ToString().ToXmlUnicode());//案件名稱
            oSheet.Pos(irow, 7).SetValue(dr["ap_cname1"].ToString().ToXmlUnicode());//客戶
            oSheet.Pos(irow, 8).SetValue(dr.GetDateTimeString("apply_date", "yyyy/M/d"));//申請日期
            oSheet.Pos(irow, 9).SetValue(dr["apply_no"].ToString());//申請號碼
            oSheet.Pos(irow, 10).SetValue(dr.GetDateTimeString("issue_date", "yyyy/M/d"));//註冊日期
            oSheet.Pos(irow, 11).SetValue(dr["issue_no"].ToString());//註冊號碼
            oSheet.Pos(irow, 12).SetValue(dr.GetDateTimeString("term2", "yyyy/M/d"));//專用迄日
            oSheet.Pos(irow, 13).SetValue(dr["scode"].ToString() + dr["scodenm"].ToString());//營洽

            irow++;
        }

        //合計處理
        if (dt.Rows.Count > 0) {
            oSheet.Row(irow).CopyRow(tSheet, 6);//複製合計行

            oSheet.Pos(irow, 0).SetValue("◎合計筆數 : " + dt.Rows.Count + " 筆");
        }
        workbook.RemoveSheetAt(1); //移除樣本頁籤

        //== 輸出Excel 2007檔案。==============================
        MemoryStream MS = new MemoryStream();
        workbook.Write(MS);
        //== Excel檔名，請寫在最後面 filename的地方
        Response.AddHeader("Content-Disposition", "attachment; filename=\"" + HttpUtility.UrlEncode("出口案件資料明細", System.Text.Encoding.UTF8) + DateTime.Now.ToString("yyyyMMdd") + ".xlsx\"");
        Response.BinaryWrite(MS.ToArray());
        //== 釋放資源
        workbook = null;
        MS.Close();
        MS.Dispose();
    }

    private void getData(DataTable dt) {
        //取得報表資料
        conn = new DBHelper(Conn.btbrt, false).Debug(false);

        string SQL = "";
        SQL = "select a.end_date,a.country,a.seq,a.seq1,a.class,a.apply_date,a.in_date,appl_name,a.cust_area,a.cust_seq,apply_no,a.apply_date,a.issue_no ";
        SQL += ",a.issue_date,a.term2,a.scode,b.ap_cname1,d.draw_file ";
        SQL += ",(select code_name from cust_code where code_type = 'TECaseStat' and cust_code = a.now_stat) as now_statnm ";
        SQL += ",(select sc_name from sysctrl.dbo.scode where scode = a.scode) as scodenm ";
        SQL += " from ext a ";
        SQL += " left outer join apcust b on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq ";
        SQL += " left outer join [next] d on a.seq=d.seq and a.seq1=d.seq1 ";
        if (qagent_nm != "") {
            SQL += " left outer join agent23 c on a.agt_no=c.agent_no and a.agt_no1=c.agent_no1 ";
        }
        SQL += " where 1=1 ";
        if (seq != "") SQL += " and a.seq = '" + seq + "' ";
        if (seq1 != "") SQL += " and a.seq1 = '" + seq1 + "' ";
        if (sclass != "") SQL += " and a.class like '%" + sclass + "%' ";
        if (mseq != "") SQL += " and a.mseq = '" + mseq + "' ";
        if (mseq1 != "") SQL += " and a.mseq1 = '" + mseq1 + "' ";
        if (scode != "") SQL += " and a.scode = '" + scode + "' ";
        if (qcountry != "") SQL += " and a.country = '" + qcountry + "' ";
        if (cust_seq != "") SQL += " and a.cust_seq = '" + cust_seq + "' ";
        if (ap_cname1 != "") SQL += " and b.ap_cname1 like '%" + ap_cname1 + "%' ";
        if (apcust_no != "") SQL += " and a.seq in (select distinct seq from ext_apcust where apcust_no like '%" + apcust_no + "%') ";
        if (ap_cname != "")
            SQL += " and rtrim(cast(a.seq as char))+a.seq1 in (select rtrim(cast(seq as char))+seq1 from ext_apcust where ap_cname1 like '%" + ap_cname + "%' or ap_cname2 like '%" + ap_cname + "%') ";

        //代理人
        if (qagent_no != "") SQL += " and a.agt_no = '" + qagent_no + "' ";

        if (qagent_no1 != "") SQL += " and a.agt_no1 = '" + qagent_no1 + "' ";

        if (qagent_nm != "") SQL += " and isnull(c.agent_na1,'')+isnull(c.agent_na2,'') like '%" + qagent_nm + "%' ";

        if (s_mark != "") {
            if (s_mark == "T")
                SQL += " and a.s_mark in ('T','') ";
            else
                SQL += " and a.s_mark = '" + s_mark + "' ";
        }

        if (pul != "") {
            if (s_mark == "0")
                SQL += " and a.pul = '' ";
            else
                SQL += " and a.pul = '" + pul + "' ";
        }

        if (qappl_name != "") SQL += " and a.appl_name like '%" + qappl_name + "%' ";

        if (kind_no != "") {
            SQL += " and a." + kind_no + " = '" + ref_no + "' ";
        } else {
            if (ref_no != "") {
                SQL += " and (a.Apply_No like '%" + ref_no + "%' ";
                SQL += " or a.Issue_No like '%" + ref_no + "%' ";
                SQL += " or a.renewal_No like '%" + ref_no + "%') ";
            }
        }

        if (kind_date != "") {
            if (sdate != "") SQL += " and a." + kind_date + " >= '" + sdate + "' ";
            if (edate != "") SQL += " and a." + kind_date + " <= '" + edate + "' ";
        } else {
            if (sdate != "") {
                SQL += " and (a.In_Date >= '" + sdate + "' ";
                SQL += "  or a.Apply_Date >= '" + sdate + "' ";
                SQL += "  or a.Issue_Date >= '" + sdate + "' ";
                SQL += "  or a.renewal_Date >= '" + sdate + "' ";
                SQL += "  or a.End_Date >= '" + sdate + "' ";
                SQL += "  or a.term2 >= '" + sdate + "') ";
            }
            if (edate != "") {
                SQL += " and (a.In_Date <= '" + edate + "' ";
                SQL += "  or a.Apply_Date <= '" + edate + "' ";
                SQL += "  or a.Issue_Date <= '" + edate + "' ";
                SQL += "  or a.renewal_Date <= '" + edate + "' ";
                SQL += "  or a.End_Date <= '" + edate + "' ";
                SQL += "  or a.term2 <= '" + edate + "') ";
            }
        }
        if (qryend == "Y") SQL += " and a.end_date is null ";
        else if (qryend == "N") {
            SQL += " and a.end_date is not null ";
            if (end_code != "") SQL += " and a.end_code = '" + end_code + "' ";
        }
        SQL += " order by a.seq,a.seq1";
        conn.DataTable(SQL, dt);
    }
</script>
