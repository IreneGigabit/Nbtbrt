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
    string seq, seq1, sclass;
    string mseq, mseq1, scode;
    string cust_area, cust_seq;
    string ap_cname1, apcust_no, ap_cname;
    string s_mark, s_mark2;
    string pul, appl_name;
    string kind_no, ref_no, kind_date;
    string sdate, edate;
    string qryend, end_code;

	private void Page_Load(System.Object sender, System.EventArgs e) {
		//Response.CacheControl = "no-cache";
		Response.CacheControl = "Private";
		Response.AddHeader("Pragma", "no-cache");
		Response.Expires = -1;
        Response.Clear();

        seq = Request["seq"] ?? "";
        seq1 = Request["seq1"] ?? "";
        sclass = Request["class"] ?? "";
        mseq = Request["mseq"] ?? "";
        mseq1 = Request["mseq1"] ?? "";
        scode = Request["scode"] ?? "";
        cust_area = Request["cust_area"] ?? "";
        cust_seq = Request["cust_seq"] ?? "";
        ap_cname1 = Request["ap_cname1"] ?? "";
        apcust_no = Request["apcust_no"] ?? "";
        ap_cname = Request["ap_cname"] ?? "";
        s_mark = Request["s_mark"] ?? "";
        s_mark2 = Request["s_mark2"] ?? "";
        pul = Request["pul"] ?? "";
        appl_name = Request["appl_name"] ?? "";
        kind_no = Request["kind_no"] ?? "";
        ref_no = Request["ref_no"] ?? "";
        kind_date = Request["kind_date"] ?? "";
        sdate = Request["sdate"] ?? "";
        edate = Request["edate"] ?? "";
        qryend = (Request["qryend"] ?? "").Trim();
        end_code = (Request["end_code"] ?? "").Trim();
        
        ExcelOut();
	}

    private void ExcelOut() {
        string tplPath = Server.MapPath("~/ReportTemplate/國內案件資料查詢.xlsx");

        FileStream file = new FileStream(tplPath, FileMode.Open, FileAccess.Read);
        IWorkbook workbook = new XSSFWorkbook(file);
        ISheet oSheet = workbook.GetSheetAt(0);
        ISheet tSheet = workbook.GetSheetAt(1); //樣本格式來源sheet
        
        //處理報表抬頭部分
        string rptTitle = "";
        if (seq != "" || seq1 != "") rptTitle += "、◎本所編號：" + seq + "-" + seq1;
        if (sclass != "") rptTitle += "、◎類別(含)：" + sclass;
        if (mseq != "" || mseq1 != "") rptTitle += "、◎母案編號：" + mseq + "-" + mseq1;
        if (scode != "") rptTitle += "、◎營洽：" + scode;
        if (cust_seq != "") rptTitle += "、◎客戶編號：" + cust_area + cust_seq;
        if (ap_cname1 != "") rptTitle += "、◎客戶名稱(含)：" + ap_cname1;
        if (apcust_no != "") rptTitle += "、◎申請人編號(含)：" + apcust_no;
        if (ap_cname != "") rptTitle += "、◎申請人名稱(含)：" + ap_cname;
        if (s_mark != "" || s_mark2 != "") {
            rptTitle += "、◎商標種類：";
            if (s_mark2 == "A") rptTitle += "平面";
            if (s_mark2 == "B") rptTitle += "立體";
            if (s_mark2 == "C") rptTitle += "聲音";
            if (s_mark2 == "D") rptTitle += "顏色";
            if (s_mark2 == "E") rptTitle += "全像圖";
            if (s_mark2 == "F") rptTitle += "動態";
            if (s_mark2 == "G") rptTitle += "其他";
            if (s_mark == "T") rptTitle += "商標";
            if (s_mark == "S") rptTitle += "92年修正前服務標章";
            if (s_mark == "L") rptTitle += "證明標章";
            if (s_mark == "M") rptTitle += "團體標章";
            if (s_mark == "N") rptTitle += "團體商標";
        }
        if (pul != "") {
            rptTitle += "、◎正聯防：";
            if (pul == "0") rptTitle += "正商標";
            if (pul == "1") rptTitle += "聯合";
            if (pul == "2") rptTitle += "防護";
        }
        if (appl_name != "") rptTitle += "、◎商標名稱(含)：" + appl_name;
        if (kind_no != "") {
            rptTitle += "、◎文號種類：";
            if (kind_no == "Apply_No") rptTitle += "申請號碼";
            if (kind_no == "Issue_No") rptTitle += "註冊號碼";
            if (kind_no == "Rej_No") rptTitle += "核駁號碼";
        }
        if (ref_no != "") rptTitle += "、◎官方文號：" + ref_no;

        if (kind_date == "") rptTitle += "、◎日期種類：不指定";
        if (kind_date == "In_Date") rptTitle += "、◎日期種類：立案日期";
        if (kind_date == "Apply_Date") rptTitle += "、◎日期種類：申請日期";
        if (kind_date == "Issue_Date") rptTitle += "、◎日期種類：註冊日期";
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
            oSheet.Pos(irow, 3).SetValue(dr["class"].ToString());//類別
            oSheet.Pos(irow, 4).SetValue(dr["now_statnm"].ToString());//案件狀態
            oSheet.Pos(irow, 5).SetValue(dr["appl_name"].ToString().ToXmlUnicode());//案件名稱
            oSheet.Pos(irow, 6).SetValue(dr["ap_cname1"].ToString().ToXmlUnicode());//客戶
            oSheet.Pos(irow, 7).SetValue(dr.GetDateTimeString("apply_date", "yyyy/M/d"));//申請日期
            oSheet.Pos(irow, 8).SetValue(dr["apply_no"].ToString());//申請號碼
            oSheet.Pos(irow, 9).SetValue(dr.GetDateTimeString("issue_date", "yyyy/M/d"));//註冊日期
            oSheet.Pos(irow, 10).SetValue(dr["issue_no"].ToString());//註冊號碼
            oSheet.Pos(irow, 11).SetValue(dr.GetDateTimeString("term2", "yyyy/M/d"));//專用迄日
            oSheet.Pos(irow, 12).SetValue(dr["scode"].ToString() + dr["scodenm"].ToString());//營洽

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
        Response.AddHeader("Content-Disposition", "attachment; filename=\"" + HttpUtility.UrlEncode("國內案件資料明細", System.Text.Encoding.UTF8) + DateTime.Now.ToString("yyyyMMdd") + ".xlsx\"");
        Response.BinaryWrite(MS.ToArray());
        //== 釋放資源
        workbook = null;
        MS.Close();
        MS.Dispose();
    }

    private void getData(DataTable dt) {
        //取得報表資料
        conn = new DBHelper(Session["btbrtdb"].ToString(), false).Debug(false);

        string SQL = "";
        SQL += "select a.seq,a.seq1,a.class,a.in_date,a.appl_name,a.cust_area,a.cust_seq,a.apply_no,a.apply_date ";
        SQL += ",a.issue_date,a.issue_no,a.term2,a.scode,a.end_date,b.ap_cname1,c.draw_file ";
        SQL += ",(select code_name from cust_code where code_type = 'TCase_Stat' and cust_code = a.now_stat) as now_statnm ";
        SQL += ",(select sc_name from sysctrl.dbo.scode where scode = a.scode) as scodenm ";
        SQL += "from dmt a ";
        SQL += "join apcust b on a.cust_seq = b.cust_seq ";
        SQL += "join ndmt c on a.seq=c.seq and a.seq1=c.seq1 ";
        SQL += "where 1=1 ";
        if (seq != "") SQL += " and a.seq = '" + seq + "' ";
        if (seq1 != "") SQL += " and a.seq1 = '" + seq1 + "' ";
        if (sclass != "") SQL += " and a.class like '%" + sclass + "%' ";
        if (mseq != "") SQL += " and a.mseq = '" + mseq + "' ";
        if (mseq1 != "") SQL += " and a.mseq1 = '" + mseq1 + "' ";
        if (scode != "") SQL += " and a.scode = '" + scode + "' ";
        if (cust_seq != "") SQL += " and a.cust_seq = '" + cust_seq + "' ";
        if (ap_cname1 != "") SQL += " and b.ap_cname1 like '%" + ap_cname1 + "%' ";
        if (apcust_no != "") SQL += " and a.seq in (select distinct seq from dmt_ap where apcust_no like '%" + apcust_no + "%' ) ";
        if (ap_cname != "") SQL += " and rtrim(cast(a.seq as char))+a.seq1 in (select rtrim(cast(seq as char))+seq1 from dmt_ap where ap_cname like '%" + ap_cname + "%') ";
        if (s_mark != "") {
            if (s_mark == "T")
                SQL += " and a.s_mark in ('T','') ";
            else
                SQL += " and a.s_mark = '" + s_mark + "' ";
        }
        //2012/8/29增設商標種類s_mark2
        if (s_mark2 != "") SQL += " and a.s_mark2='" + s_mark2 + "' ";
        if (pul != "") {
            if (s_mark == "0")
                SQL += " and a.pul = '' ";
            else
                SQL += " and a.pul = '" + pul + "' ";
        }
        if (appl_name != "") SQL += " and a.appl_name like '%" + appl_name + "%' ";
        if (kind_no != "") {
            //2008/12/2修改為like，因前面補0  
            SQL += " and a." + kind_no + " like '%" + ref_no + "%' ";
        } else {
            if (ref_no != "") {
                SQL += " and (a.Apply_No like '%" + ref_no + "%' ";
                SQL += " or a.Issue_No like '%" + ref_no + "%' ";
                SQL += " or a.Rej_No like '%" + ref_no + "%') ";
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
                SQL += "  or a.End_Date >= '" + sdate + "' ";
                SQL += "  or a.term2 >= '" + sdate + "') ";
            }
            if (edate != "") {
                SQL += " and (a.In_Date <= '" + edate + "' ";
                SQL += "  or a.Apply_Date <= '" + edate + "' ";
                SQL += "  or a.Issue_Date <= '" + edate + "' ";
                SQL += "  or a.End_Date <= '" + edate + "' ";
                SQL += "  or a.term2 >= '" + edate + "') ";
            }
        }
        if (qryend == "Y") {
            SQL += " and a.end_date is null ";
        } else if (qryend == "N") {
            SQL += " and a.end_date is not null ";
            if (end_code != "")
                SQL += " and a.end_code = '" + end_code + "' ";
        }
        SQL += "order by a.seq,a.seq1";
        conn.DataTable(SQL, dt);
    }
</script>
