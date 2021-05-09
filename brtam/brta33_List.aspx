<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "國內案官發回條確認作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";

    protected string emg_scode = "";
    protected string emg_agscode = "";
    protected string qrydowhat = "", qryrs_class = "", qryrectitle = "";
    protected string dowhat_name="確認",tcolspan="2",Qclass="";
    protected int conf_count = 0,mconf_count = 0,dconf_count = 0,back_count = 0,mback_count = 0,dback_count = 0;//確認、退件件數
    protected int pcount = 0,ecount = 0,eacount = 0;//各發文方式之件數
    protected int titleEYcount=0,titleENcount=0,titlePYcount=0,titlePNcount=0;//各收據/規費之件數

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");
        
        qrydowhat=Request["qrydowhat"]??"";
        if (qrydowhat=="") qrydowhat="mg_gs";
        qryrs_class=Request["qryrs_class"]??"";
        if (qryrs_class == "") qryrs_class = "*";
        qryrectitle = Request["qryrectitle"] ?? "";
        if (qryrectitle == "") qryrectitle = "P";
            
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title.Replace("官發", "<font color=blue>官方發文</font>");
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";

        if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0 || (HTProgRight & 16) > 0 || (HTProgRight & 64) > 0) {
            StrFormBtn += "<br>\n";
            if (qrydowhat == "mg_gs_back") {
                StrFormBtn += "<input type=button value ='退件確認' class='redbutton bsubmit' onclick='formReSubmit()'>\n";
            } else {
                StrFormBtn += "<input type=button value ='確  認' class='cbutton bsubmit' onclick='formAddSubmit()'>\n";
            }
            StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
        }
        
        if (qrydowhat == "mg_gs") {
            FormName = "備註:<br>\n";
            FormName += "1.<img src=\"" + Page.ResolveUrl("~/images/remark.gif") + "\" align=\"absmiddle\">表總管處有填寫說明，將游標移至該圖處即會顯示。<br>\n";
            FormName += "2.總管處同時會將案件申請號/申請日寫入，如有誤，提供email通知總收發文修改。<br>\n";
            FormName += "3.執行確認時，系統會處理下列事項：<br>\n";
            FormName += "&nbsp;&nbsp;(1)同步修改案件主檔申請號/申請日。<br>\n";
            FormName += "&nbsp;&nbsp;(2)產生一筆官收「官方已收件」進度及客發。<br>\n";
            FormName += "&nbsp;&nbsp;(3)規費資料寫入帳款系統。<br>\n";
            FormName += "&nbsp;&nbsp;(4)爭救案件，若有爭救案系統轉入上傳文件，系統會轉入區所官發進度。<br>\n";
            FormName += "4.「作業」顯示[<font color=red size=3>！</font>]表示本筆官收總管處程序未確認完成且未Email通知區所，請區所收到總管處程序Email通知後再執行確認。<br>\n";
            FormName += "5.「作業」顯示[<font color=red size=3>＊</font>]表示尚未取得電子收據。<br>\n";
        }
        if (qrydowhat == "mg_gs_back") {
            FormName = "備註:<br>\n";
            FormName += "1.包含總收發的送件確認之退件及發文確認之退件。<br>\n";
            FormName += "2.執行退件確認時，發文進度取消、期限管制取消及銷管恢復、對應交辦已扣規費取消，退回「國內案承辦交辦發文作業」。<br>\n";
        }

        emg_scode = Sys.getRoleScode(Sys.GetSession("seBranch"), Sys.GetSession("syscode"), "T", "mg_pror");//總管處程序人員-正本
        emg_agscode = Sys.getRoleScode(Sys.GetSession("seBranch"), Sys.GetSession("syscode"), "T", "mg_prorm");//總管處程序人員-副本
    }

    private void QueryData() {
        //計算確認、退件件數
        SQL = "select mg_rs_no,mg_mrs_no,from_flag from step_mgt_temp where into_date is null";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            while (dr.Read()) {
                string mg_rs_no = dr.SafeRead("mg_rs_no", "").Trim();
                string mg_mrs_no = dr.SafeRead("mg_mrs_no", "").Trim();
                if (dr.SafeRead("from_flag", "") == "E") {
                    conf_count += 1;
                    if (mg_rs_no == mg_mrs_no) {
                        mconf_count += 1;
                    } else {
                        dconf_count += 1;
                    }
                } else if (dr.SafeRead("from_flag", "") == "F" || dr.SafeRead("from_flag", "") == "G") {
                    back_count += 1;
                    if (mg_rs_no == mg_mrs_no) {
                        mback_count += 1;
                    } else {
                        dback_count += 1;
                    }
                }
            }
        }

        //計算各發文方式之件數
        SQL = "select b.send_way ";
        SQL += " from step_mgt_temp a ";
        SQL += " inner join vstep_dmt as b on a.seq=b.seq and a.seq1=b.seq1 and a.mg_rs_no=b.rs_no ";
        SQL += " where a.into_date is null and a.mg_rs_no=a.mg_mrs_no ";
        SQL += " union all ";
        SQL += " select isnull(b.send_way,'M') as send_way ";
        SQL += " from step_mgt_temp a ";
        SQL += " inner join bstep_temp as b on a.seq=b.seq and a.seq1=b.seq1 and a.mg_rs_no=b.rs_no ";
        SQL += " where a.into_date is null and a.mg_rs_no=a.mg_mrs_no ";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            while (dr.Read()) {
                if (dr.SafeRead("send_way", "") == "E")
                    ecount += 1;
                else if (dr.SafeRead("send_way", "") == "EA")
                    eacount += 1;
                else
                    pcount += 1;
            }
        }

        //計算紙本收據/電子收據件數
        SQL = "select isnull(b.receipt_type,'P') receipt_type,isnull(b.fees,0)fees ";
        SQL += " from step_mgt_temp a ";
        SQL += " inner join vstep_dmt as b on a.seq=b.seq and a.seq1=b.seq1 and a.mg_rs_no=b.rs_no ";
        SQL += " where a.into_date is null and a.mg_rs_no=a.mg_mrs_no ";
        SQL += " union all ";
        SQL += " select isnull(b.send_way,'M') as send_way,isnull(b.fees,0)fees ";
        SQL += " from step_mgt_temp a ";
        SQL += " inner join bstep_temp as b on a.seq=b.seq and a.seq1=b.seq1 and a.mg_rs_no=b.rs_no ";
        SQL += " where a.into_date is null and a.mg_rs_no=a.mg_mrs_no ";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            while (dr.Read()) {
                if (dr.SafeRead("receipt_type", "") == "E") {
                    if (Convert.ToInt32(dr.SafeRead("fees", "0")) > 0) {
                        titleEYcount += 1;
                    } else {
                        titleENcount += 1;
                    }
                } else {
                    if (Convert.ToInt32(dr.SafeRead("fees", "0")) > 0) {
                        titlePYcount += 1;
                    } else {
                        titlePNcount += 1;
                    }
                }
            }
        }

        //抓取新申請案類別
        string rs_class_a = "";
        SQL = "select cust_code from cust_code where code_type='T92' and ref_code='A'";
        using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
            rs_class_a = dr.ConcatColumn("cust_code", ",");
        }
        if (rs_class_a == "") rs_class_a = "A1";

        string wSQL = "";
        if ((Request["qryStep_dateS"] ?? "") != "") wSQL += " and b.Step_Date>='" + Request["qryStep_dateS"] + "'";
        if ((Request["qryStep_dateE"] ?? "") != "") wSQL += " and b.Step_Date<='" + Request["qryStep_dateE"] + "'";
        if ((Request["qrySeq"] ?? "") != "") wSQL += " and a.Seq in ('" + Request["qrySeq"].Replace(",", "','") + "')";
        if ((Request["qrySeq1"] ?? "") != "") wSQL += " and a.Seq1='" + Request["qrySeq1"] + "'";
        //案性
        if (qryrs_class != "*") {
            if (qryrs_class == "A") {
                wSQL += " and a.rs_class in ('" + rs_class_a + "')";
            } else {
                wSQL += " and a.rs_class not in ('" + rs_class_a + "')";
            }
        }
        //作業狀態
        if (qrydowhat == "mg_gs_back") {
            wSQL += " and (a.from_flag='F' or a.from_flag='G') ";
            dowhat_name = "<font color=red>退件</font>";
            tcolspan = "1";
            Qclass = " readonly class='sedit'";
        } else {
            wSQL += " and a.from_flag='E' ";
        }
        //發文方式
        if ((Request["qrysend_way"] ?? "") == "E" || (Request["qrysend_way"] ?? "") == "EA") {
            wSQL += " and b.send_way='" + Request["qrysend_way"] + "'";
        } else if ((Request["qrysend_way"] ?? "") == "M") {
            wSQL += " and isnull(b.send_way,'') not in('E','EA') ";
        }
        //規費
        if ((Request["qryfee"] ?? "") == "Y") {
            wSQL += " and isnull(b.fees,0)<>0";
        } else if ((Request["qryfee"] ?? "") == "N") {
            wSQL += " and isnull(b.fees,0)=0";
        }
        //收據種類
        if (qryrectitle == "P") {
            wSQL += " and isnull(b.receipt_type,'P')='P' ";
        } else {
            wSQL += " and isnull(b.receipt_type,'P')='E' ";
        }

        SQL = "select a.temp_rs_sqlno,a.seq_area as branch,a.seq,a.seq1,a.step_grade,a.rs_detail,a.apply_date as mg_apply_date,a.apply_no as mg_apply_no,a.mg_in_date";
        SQL += ",a.mg_send_grade,a.mg_send_rs_sqlno,b.cust_seq,b.att_sql,b.cappl_name as appl_name,b.rs_no,b.main_rs_no,b.step_date,b.mp_date,b.apply_no";
        SQL += ",b.apply_date,b.fees,b.rs_type,b.rs_class,b.rs_code,b.act_code";
        SQL += ",b.dmt_scode,b.tot_num,b.rs_sqlno,b.send_way,isnull(b.receipt_type,'P')receipt_type,isnull(b.fees,0)fees ";
        SQL += ",a.mg_conf_flag,''fseq,''mfseq,''mgdate_style,''mgno_style,''gs_send_way,'N'opt_attach_flag,''reject_reason,''todo_sqlno ";
        SQL += ",''ctrl_date,'N'child_flag,'Y'main_flag,''mg_pr_remark,''egsPath ";
        SQL += " from step_mgt_temp a ";
        SQL += " inner join vstep_dmt as b on a.seq=b.seq and a.seq1=b.seq1 and a.mg_rs_no=b.rs_no ";
        SQL += " where a.into_date is null and a.mg_rs_no=a.mg_mrs_no" + wSQL;
        //SQL += " where a.seq in(64150,65436) and a.mg_rs_no=a.mg_mrs_no and tot_num>1 ";
        SQL += " union ";
        SQL += "select a.temp_rs_sqlno,a.seq_area as branch,a.seq,a.seq1,a.step_grade,a.rs_detail,a.apply_date as mg_apply_date,a.apply_no as mg_apply_no,a.mg_in_date";
        SQL += ",a.mg_send_grade,a.mg_send_rs_sqlno,c.cust_seq,c.att_sql,c.appl_name,b.rs_no,b.rs_no as main_rs_no,b.step_date,b.mp_date,c.apply_no";
        SQL += ",c.apply_date,b.fees,b.rs_type,b.rs_class,b.rs_code,b.act_code";
        SQL += ",c.scode as dmt_scode,1 as tot_num,0 as rs_sqlno,isnull(b.send_way,'M') as send_way,isnull(b.receipt_type,'P')receipt_type,isnull(b.fees,0)fees ";
        SQL += ",a.mg_conf_flag,''fseq,''mfseq,''mgdate_style,''mgno_style,''gs_send_way,'N'opt_attach_flag,''reject_reason,''todo_sqlno ";
        SQL += ",''ctrl_date,'N'child_flag,'Y'main_flag,''mg_pr_remark,''egsPath ";
        SQL += " from step_mgt_temp a ";
        SQL += " inner join bstep_temp as b on a.seq=b.seq and a.seq1=b.seq1 and a.mg_rs_no=b.rs_no ";
        SQL += " inner join dmt c on a.seq=c.seq and a.seq1=c.seq1 ";
        SQL += " where a.into_date is null and a.mg_rs_no=a.mg_mrs_no" + wSQL;
        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "b.step_date,a.seq,a.seq1"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }

        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "30"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //案號
            dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
            //申請日顏色
            if (dr.SafeRead("apply_date", "") == "") {
                //若區所無申請日帶入總收發申請日,並為藍色
                dr["apply_date"] = dr["mg_apply_date"];
                dr["mgdate_style"] = "color:blue";
            }
            if (dr.GetDateTimeString("apply_date", "yyyy/M/d") != dr.GetDateTimeString("mg_apply_date", "yyyy/M/d")) {
                //若區所無申請日<>總收發申請日,則為藍色
                dr["mgdate_style"] = "color:red";
            }
            //申請號顏色
            if (dr.SafeRead("apply_no", "") == "") {
                //若區所無申請號帶入總收發申請號,並為藍色
                dr["apply_no"] = dr["mg_apply_no"];
                dr["mgno_style"] = "color:blue";
            }
            if (dr.SafeRead("apply_no", "") != dr.SafeRead("mg_apply_no", "")) {
                //若區所無申請號日<>總收發申請號,則為藍色
                dr["mgno_style"] = "color:red";
            }
            //官發之發文方式
            dr["gs_send_way"] = dr.SafeRead("send_way", "M");
            if (dr.SafeRead("gs_send_way", "") == "") dr["gs_send_way"] = "M";
            //爭救案上傳文件
            if (dr.SafeRead("rs_no", "").Left(1) == "B") {
                SQL = "select count(*) as cnt from bdmt_attach_temp ";
                SQL += "where seq=" + dr["seq"] + " and seq1='" + dr.SafeRead("seq1", "").Trim() + "' and rs_no='" + dr.SafeRead("main_rs_no", "").Trim() + "' ";
                SQL += "and attach_flag<>'D' and into_status='NN' and source='OPT' ";
                objResult = conn.ExecuteScalar(SQL);
                int opt_attach_cnt = (objResult == DBNull.Value || objResult == null) ? 0 : Convert.ToInt32(objResult);
                if (opt_attach_cnt > 0) dr["opt_attach_flag"] = "Y";
            }
            if (qrydowhat == "mg_gs_back") {
                //退件原因
                SQL = "select reject_reason from step_mgt_temp where temp_rs_sqlno=" + dr["temp_rs_sqlno"];
                objResult = conn.ExecuteScalar(SQL);
                dr["reject_reason"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                //抓取本筆官發之承辦交辦todo_sqlno
                if (Convert.ToInt32(dr.SafeRead("rs_sqlno", "0")) > 0) {
                    dr["todo_sqlno"] = "0";
                    SQL = "select todo_sqlno from attcase_dmt where seq=" + dr["seq"] + " and seq1='" + dr["seq1"] + "' and rs_sqlno=" + dr["rs_sqlno"];
                    objResult = conn.ExecuteScalar(SQL);
                    if (!(objResult == DBNull.Value || objResult == null)) {
                        dr["todo_sqlno"] = objResult.ToString();
                    }
                }
            }
            //抓取本筆官發銷管期限
            //2010/2/24因爭救案尚未產生官發進度，所以進度0，這樣會抓取到所有至期限管制維護銷管期限，增加判斷step_grade>0才抓取銷管期限
            if (Convert.ToInt32(dr.SafeRead("step_grade", "0")) > 0) {
                SQL = "select ctrl_date from resp_dmt where seq='" + dr["seq"] + "' and seq1='" + dr["seq1"] + "' and resp_grade=" + dr["step_grade"];
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    int ctrl_date_num = 0;
                    string ctrl_date = "";
                    while (dr0.Read()) {
                        ctrl_date_num++;
                        ctrl_date += (ctrl_date != "" ? "," : "") + (ctrl_date_num > 2 && ctrl_date_num % 2 == 1 ? "<BR>" : "") + dr0.GetDateTimeString("ctrl_date", "yyyy/M/d");
                    }
                    dr["ctrl_date"] = ctrl_date;
                }
            }
            //檢查是否有子案
            if (dr.SafeRead("tot_num", "") != "1") {
                dr["child_flag"] = "Y";
            }
            if (dr.SafeRead("main_rs_no", "") != dr.SafeRead("rs_no", "")) {
                dr["main_flag"] = "N";
            }
            //抓取總管處備註說明
            SQL = "select mg_pr_remark from step_mgt_temp where temp_rs_sqlno=" + dr["temp_rs_sqlno"];
            objResult = conn.ExecuteScalar(SQL);
            dr["mg_pr_remark"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            //抓取電子收據路徑
            SQL = "select attach_path,attach_name from mgt_attach_temp ";
            SQL += "where seq=" + dr["seq"] + " and seq1='" + dr["seq1"] + "' and temp_rs_sqlno=" + dr["temp_rs_sqlno"] + " and source='EGS' and attach_flag<>'D' ";
            objResult = conn.ExecuteScalar(SQL);
            string attach_path = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            if (attach_path != "") {
                string egsPath = attach_path.Replace("/MG", "/nbtbrt");
                //先檢查本機檔案
                if (Sys.CheckFile(egsPath) == false) {
                    egsPath = "http://" + Sys.MG_IIS + attach_path;
                }
                dr["egsPath"] = egsPath;
            }
        }

        batchRepeater.DataSource = page.pagedTable;
        batchRepeater.DataBind();
    }


    //子案欄位idx
    protected string GetSubIdx(RepeaterItem Container) {
        return (((RepeaterItem)Container.Parent.Parent).ItemIndex + 1) + "_" + (Container.ItemIndex + 1);
    }

    //子案
    protected void batchRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            Repeater childRpt = (Repeater)e.Item.FindControl("childRepeater");

            if ((childRpt != null)) {
                string mfseq = ((DataRowView)e.Item.DataItem).Row["fseq"].ToString();
                string main_flag = ((DataRowView)e.Item.DataItem).Row["main_flag"].ToString();
                string rs_no = ((DataRowView)e.Item.DataItem).Row["rs_no"].ToString();
                string seq = ((DataRowView)e.Item.DataItem).Row["seq"].ToString();
                string seq1 = ((DataRowView)e.Item.DataItem).Row["seq1"].ToString();

                SQL = "select a.temp_rs_sqlno,a.seq_area as branch,a.seq,a.seq1,a.step_grade,a.rs_detail,a.apply_date as mg_apply_date,a.apply_no as mg_apply_no,a.reject_reason,a.mg_in_date";
                SQL += ",a.mg_send_grade,a.mg_send_rs_sqlno,a.mg_pr_remark,b.cust_seq,b.att_sql,b.cappl_name as appl_name,b.rs_no,b.main_rs_no,b.step_date,b.mp_date,b.apply_no";
                SQL += ",b.apply_date,b.fees,b.rs_type,b.rs_class,b.rs_code,b.act_code";
                SQL += ",b.dmt_scode,b.tot_num,'" + mfseq + "'mfseq,'" + main_flag + "'main_flag,''fseq,''mgdate_style,''mgno_style ";
                SQL += " from step_mgt_temp a ";
                SQL += " inner join vstep_dmt as b on a.seq=b.seq and a.seq1=b.seq1 and a.mg_rs_no=b.rs_no ";
                //SQL += " where a.into_date is null and a.mg_mrs_no='" + rs_no + "' and a.mg_mrs_no<>a.mg_rs_no";
                SQL += " where a.mg_mrs_no='" + rs_no + "' and a.mg_mrs_no<>a.mg_rs_no";
                DataTable dtChild = new DataTable();
                conn.DataTable(SQL, dtChild);
                for (int i = 0; i < dtChild.Rows.Count; i++) {
                    DataRow dr = dtChild.Rows[i];

                    //案號
                    dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));

                    //申請日顏色
                    if (dr.SafeRead("apply_date", "") == "") {
                        //若區所無申請日帶入總收發申請日,並為藍色
                        dr["apply_date"] = dr["mg_apply_date"];
                        dr["mgdate_style"] = "color:blue";
                    }
                    if (dr.GetDateTimeString("apply_date", "yyyy/M/d") != dr.GetDateTimeString("mg_apply_date", "yyyy/M/d")) {
                        //若區所無申請日<>總收發申請日,則為藍色
                        dr["mgdate_style"] = "color:red";
                    }
                    //申請號顏色
                    if (dr.SafeRead("apply_no", "") == "") {
                        //若區所無申請號帶入總收發申請號,並為藍色
                        dr["apply_no"] = dr["mg_apply_no"];
                        dr["mgno_style"] = "color:blue";
                    }
                    if (dr.SafeRead("apply_no", "") != dr.SafeRead("mg_apply_no", "")) {
                        //若區所無申請號日<>總收發申請號,則為藍色
                        dr["mgno_style"] = "color:red";
                    }
                }

                childRpt.DataSource = dtChild;
                childRpt.DataBind();
            }
        }
    }
    
    //checkbox
    protected string GetChkDisplay(RepeaterItem Container) {
        string fees = Eval("fees").ToString();
        string receipt_type = Eval("receipt_type").ToString();
        if (fees != "0" && receipt_type == "E" && qrydowhat == "mg_gs") {
            return "display:none;";
        } else {
            return "";
        }
    }
    
    //[作業]
    protected string GetButton(RepeaterItem Container) {
        string rtn = "";
        string fees = Eval("fees").ToString();
        string receipt_type = Eval("receipt_type").ToString();

        if (fees != "0" && receipt_type == "E" && qrydowhat == "mg_gs") {
            if (Eval("mg_conf_flag").ToString() == "Y") {
                if (Eval("egsPath").ToString() != "") {
                    rtn += "<a href=\"javascript:void(0)\" class=\"receipt\" v0=\"" + (Container.ItemIndex + 1) + "\" v1=\"" + Eval("egsPath") + "\" id=\"dimg_" + (Container.ItemIndex + 1) + "\" title=\"" + Eval("egsPath") + "\">[電子收據]</a>";
                } else {
                    rtn += "<a href=\"javascript:void(0)\" v1=\"" + Eval("egsPath") + "\" id=\"dimg_" + (Container.ItemIndex + 1) + "\" title=\"" + Eval("egsPath") + "\">[<font color=red size=3>＊</font>]</a>";
                }
            } else {
                //總管處程序未確認
                rtn += "<a href=\"javascript:void(0)\" v1=\"" + Eval("egsPath") + "\" id=\"dimg_" + (Container.ItemIndex + 1) + "\" title=\"" + Eval("egsPath") + "\">[<font color=red size=3>！</font>]</a>";
            }
        }
        //[重抓]
        if (qrydowhat == "mg_gs") {
            rtn += "<br><font style=\"cursor:pointer;color:darkblue\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='darkblue'\" onclick=\"getmgt('" + Eval("seq") + "','" + Eval("seq1") + "','" + Eval("temp_rs_sqlno") + "','" + Eval("mg_send_rs_sqlno") + "')\">[重抓]</font>";
        }

        return rtn;
    }

    //子案[作業]
    protected string GetButtonC(RepeaterItem Container) {
        string rtn = "";
        //[重抓]
        if (qrydowhat == "mg_gs") {
            rtn += "<font style=\"cursor:pointer;color:darkblue\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='darkblue'\" onclick=\"getmgt('" + Eval("seq") + "','" + Eval("seq1") + "','" + Eval("temp_rs_sqlno") + "','" + Eval("mg_send_rs_sqlno") + "')\">[重抓]</font>";
        }

        return rtn;
    }

    //客函發文方式
    protected string GetSendWay(RepeaterItem Container) {
        return Sys.getCustCode("SEND_WAY", "", "").Option("{cust_code}", "{code_name}", true, "2");//預設掛號
    }

    //預設預定寄發日期
    protected string GetPMailDate(RepeaterItem Container) {
	    //預設預定寄發日期為官收總收發文+7天
        return Util.str2Dateime(Eval("mg_in_date", "{0:yyyy/M/d}")).AddDays(7).ToShortDateString();
    }

    //延期寄發原因
    protected string GetCSRemark(RepeaterItem Container) {
        return Sys.getCustCode("Tcs_remark", "", "").Option("{cust_code}", "{code_name}", true, "");
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
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

<form style="margin:0;" id="regPage" name="regPage" method="post">
    <table border="0" cellspacing="1" cellpadding="2" width="100%">
        <tr>
	        <td class="text9">
		        ◎作業狀態: <label><input type="radio" name="qrydowhat" value="mg_gs" <%#(qrydowhat=="mg_gs")?"checked":""%>>發文確認<%=(conf_count>0?"<font color=blue>(共" + conf_count + "件=" + mconf_count+ "件主案+"+ dconf_count+"件併案)</font>":"")%></label>
			               <label><input type="radio" name="qrydowhat" value="mg_gs_back" <%#qrydowhat=="mg_gs_back"?"checked":""%>><font color=red>總管處退件<%=(back_count>0?"(共" + back_count +"件=" + mback_count + "件主案+" + dback_count+"件併案)":"")%></font></label>
				           <!--<label><input type="radio" name="qrydowhat" value="*" >不指定</label>-->
	        </td>
	        <td class="text9">
		        ◎發文方式:
		        <label><input type="radio" name="qrysend_way" value="" <%#ReqVal.TryGet("qrysend_way")==""?"checked":""%>>不指定</label>
		        <label><input type="radio" name="qrysend_way" value="M" <%#ReqVal.TryGet("qrysend_way")=="M"?"checked":""%>>非電子送件(<font color=blue><%=pcount%></font>件)</label>
		        <label><input type="radio" name="qrysend_way" value="E" <%#ReqVal.TryGet("qrysend_way")=="E"?"checked":""%>>電子送件(<font color=blue><%=ecount%></font>件)</label>
		        <label><input type="radio" name="qrysend_way" value="EA" <%#ReqVal.TryGet("qrysend_way")=="EA"?"checked":""%>>註冊費電子送件(<font color=blue><%=eacount%></font>件)</label>
	        </td>
        </tr>	
        <tr>
	        <td class="text9">
		        ◎規費:
                <label><input type="radio" id="qryfeeY" name="qryfee" value="Y" <%#ReqVal.TryGet("qryfee")=="Y"?"checked":""%>>有規費</label>
		        <label><input type="radio" id="qryfeeN" name="qryfee" value="N" <%#ReqVal.TryGet("qryfee")=="N"?"checked":""%>>無規費</label>
		        <label><input type="radio" id="qryfee0" name="qryfee" value="*" <%#(ReqVal.TryGet("qryfee")==""||ReqVal.TryGet("qryfee")=="*")?"checked":""%>>不指定</label>
	        </td>
	        <td class="text9">
		        ◎收據種類:
                <label><input type="radio" id="qryrectitleP" name="qryrectitle" value="P" <%#qryrectitle=="P"?"checked":""%>>紙本收據</label><span style="display:none">(有規費<font color=blue><%=titlePYcount%></font>件+無規費<font color=blue><%=titlePNcount%></font>件)</span>
                <label><input type="radio" id="qryrectitleE" name="qryrectitle" value="E" <%#qryrectitle=="E"?"checked":""%>>電子收據</label><span style="display:none">(有規費<font color=blue><%=titleEYcount%></font>件+無規費<font color=blue><%=titleENcount%></font>件)</span>
		        <span id="spnScan" <%#(qryrectitle=="P"||qrydowhat=="mg_gs_back")?"style='display:none'":""%>>
		        (掃描預設:
                <label><input type="radio" id="radscanY" name="radscan" value="Y" <%#ReqVal.TryGet("radscan")=="Y"?"checked":""%>>需要</label>
		        <label><input type="radio" id="radscanN" name="radscan" value="N" <%#ReqVal.TryGet("radscan")=="N"?"checked":""%>>不需要</label>)
		        <input type="hidden" id="scanYN" name="scanYN" value="<%=Request["radscan"]%>">
		        </span>
	        </td>
        </tr>	
        <tr>
	        <td class="text9">
		        ◎案性:
                <label><input type="radio" name="qryrs_class" value="A" <%#qryrs_class=="A"?"checked":""%>>新申案</label>
		        <label><input type="radio" name="qryrs_class" value="B" <%#qryrs_class=="B"?"checked":""%>>非新申案</label>
		        <label><input type="radio" name="qryrs_class" value="*" <%#qryrs_class=="*"?"checked":""%>>不指定</label>
	        </td>
        </tr>
        <tr>
	        <td class="text9">
		        ◎官發日期: <input type="text" id="qryStep_DateS" name="qryStep_DateS" size="10" value="<%#ReqVal.TryGet("qryStep_DateS")%>" class="dateField">
	        </td>
	        <td class="text9">
		        ◎本所編號:<input type="text" id="qrySeq" name="qrySeq" size="30">-<input type="text" id="qrySeq1" name="qrySeq1" size="2">
	        </td>
	        <td class="text9">
		        <input type="button" value="查詢" class="cbutton" onClick="goSearch()" id="qrybutton" name="qrybutton">
		        <input type=hidden id=orderBy name=orderBy value=<%=Request["orderBy"]%>>
		        <input type=hidden id=sort name=sort value=<%=Request["sort"]%>>
		        <input type="hidden" name="prgid" id="prgid" value="<%=prgid%>">
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
				    <span id="PageUp" style="display:<%#page.nowPage>1?"":"none"%>">| <a href="javascript:void(0)" class="pgU" v1="<%#page.nowPage-1%>">上一頁</a></span>
				    <span id="PageDown" style="display:<%#page.nowPage<page.totPage?"":"none"%>">| <a href="javascript:void(0)" class="pgD" v1="<%#page.nowPage+1%>">下一頁</a></span>
				    | 每頁筆數:
				    <select id="PerPage" name="PerPage" style="color:#FF0000">
					    <option value="10" <%#page.perPage==10?"selected":""%>>10</option>
					    <option value="20" <%#page.perPage==20?"selected":""%>>20</option>
					    <option value="30" <%#page.perPage==30?"selected":""%>>30</option>
					    <option value="50" <%#page.perPage==50?"selected":""%>>50</option>
				    </select>
                    <input type="hidden" name="SetOrder" id="SetOrder" value="<%#ReqVal.TryGet("qryOrder")%>" />
			    </font>
		    </td>
	    </tr>
    </TABLE>
    </div>
</form>

<div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
    <INPUT type="hidden" name="qrydowhat" id="qrydowhat">
	<input type="hidden" name="prgid" value="<%=prgid%>">
    <input type="hidden" id=row name=row value="<%#page.pagedTable.Rows.Count%>"> 
    <INPUT type="hidden" name="rows_chk" id="rows_chk">
	<INPUT type="hidden" name="rows_seq" id="rows_seq">
	<INPUT type="hidden" name="rows_seq1" id="rows_seq1">
	<INPUT type="hidden" name="rows_gr_mp_date" id="rows_gr_mp_date">
	<INPUT type="hidden" name="rows_rs_type" id="rows_rs_type">
	<INPUT type="hidden" name="rows_rs_class" id="rows_rs_class">
	<INPUT type="hidden" name="rows_rs_code" id="rows_rs_code">
	<INPUT type="hidden" name="rows_act_code" id="rows_act_code">
	<INPUT type="hidden" name="rows_cust_seq" id="rows_cust_seq">
	<INPUT type="hidden" name="rows_att_sql" id="rows_att_sql">
	<INPUT type="hidden" name="rows_temp_rs_sqlno" id="rows_temp_rs_sqlno">
	<INPUT type="hidden" name="rows_rs_no" id="rows_rs_no">
	<INPUT type="hidden" name="rows_rs_sqlno" id="rows_rs_sqlno">
	<INPUT type="hidden" name="rows_dmt_scode" id="rows_dmt_scode">
	<INPUT type="hidden" name="rows_step_grade" id="rows_step_grade">
	<INPUT type="hidden" name="rows_mg_step_grade" id="rows_mg_step_grade">
	<INPUT type="hidden" name="rows_mg_rs_sqlno" id="rows_mg_rs_sqlno">
	<INPUT type="hidden" name="rows_child_flag" id="rows_child_flag">
	<INPUT type="hidden" name="rows_step_date" id="rows_step_date">
	<INPUT type="hidden" name="rows_opt_attach_flag" id="rows_opt_attach_flag">
	<INPUT type="hidden" name="rows_todo_sqlno" id="rows_todo_sqlno">
	<INPUT type="hidden" name="rows_appl_name" id="rows_appl_name">
	<INPUT type="hidden" name="rows_rs_detail" id="rows_rs_detail">
	<INPUT type="hidden" name="rows_gs_send_way" id="rows_gs_send_way">
	<INPUT type="hidden" name="rows_receipt_type" id="rows_receipt_type">
	<INPUT type="hidden" name="rows_fees" id="rows_fees">

	<INPUT type="hidden" name="rows_mg_apply_date" id="rows_mg_apply_date">
	<INPUT type="hidden" name="rows_apply_date" id="rows_apply_date">
	<INPUT type="hidden" name="rows_mg_apply_no" id="rows_mg_apply_no">
	<INPUT type="hidden" name="rows_apply_no" id="rows_apply_no">
	<INPUT type="hidden" name="rows_radcs" id="rows_radcs">
	<INPUT type="hidden" name="rows_chkcsd_flag" id="rows_chkcsd_flag">
	<INPUT type="hidden" name="rows_send_way" id="rows_send_way">
	<INPUT type="hidden" name="rows_opmail_date" id="rows_opmail_date">
	<INPUT type="hidden" name="rows_cs_remark_code" id="rows_cs_remark_code">
	<INPUT type="hidden" name="rows_cs_remark" id="rows_cs_remark">
	<INPUT type="hidden" name="rows_pmail_date" id="rows_pmail_date">
	<INPUT type="hidden" name="rows_radscan" id="rows_radscan">

    <INPUT type="hidden" name="rows_mchknum" id="rows_mchknum">

    <asp:Repeater id="batchRepeater" runat="server" OnItemDataBound="batchRepeater_ItemDataBound">
    <HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                <Tr>
	                <td  class="lightbluetable" nowrap align="center" rowspan=<%=tcolspan%>><%=dowhat_name%></td>
	                <td  class="lightbluetable" nowrap align="center" rowspan=<%=tcolspan%>><u class="setOdr" v1="seq,seq1">本所編號</u></td>
	                <td  class="lightbluetable" nowrap align="center">進度</td>
	                <td  class="lightbluetable" nowrap align="center" rowspan=<%=tcolspan%>><u class="setOdr" v1="appl_name">案件名稱</u></td> 
	                <td  class="lightbluetable" nowrap align="center" rowspan=<%=tcolspan%>><u class="setOdr" v1="step_date">發文日期</u></td> 
	                <td  class="lightbluetable" nowrap align="center" rowspan=<%=tcolspan%>><u class="setOdr" v1="rs_no">發文字號</u></td>
	                <td  class="lightbluetable" nowrap align="center" rowspan=<%=tcolspan%>>發文內容</td>
	                <td  class="lightbluetable" nowrap align="center" rowspan=<%=tcolspan%>>申請日期</td>
	                <td  class="lightbluetable" nowrap align="center" rowspan=<%=tcolspan%>>申請號碼</td>
	                <td  class="lightbluetable" nowrap align="right"  rowspan=<%=tcolspan%>>規費</td>
	                <td  class="lightbluetable" nowrap align="center" rowspan=<%=tcolspan%>>銷管期限</td> 
	                <%if( qrydowhat=="mg_gs"){%>
	                    <td  class="lightbluetable" nowrap align="center" >客函</td>
	                <%}%>
	                <%if( qrydowhat=="mg_gs_back"){%>
	                    <td  class="lightbluetable" nowrap align="center">退件原因</td> 
	                <%}%>
                </tr>
	            <%if( qrydowhat=="mg_gs"){%>
                <tr>
	                <td  class="lightbluetable" nowrap align="center">Email</td>
	                <td  class="lightbluetable" nowrap align="center">掃描文件</td>
                </tr>
	            <%}%>
	        </thead>
	        <tbody>
    </HeaderTemplate>
	<ItemTemplate>
 	    <tr class="main_tr" rec="<%#(Container.ItemIndex+1)%>">
		    <td class="whitetablebg" align="center" rowspan="<%=tcolspan%>">
                <input type=checkbox id=chk_<%#(Container.ItemIndex+1)%> onclick="chkdata('<%=qrydowhat%>','<%#(Container.ItemIndex+1)%>')" value='Y' style="<%#GetChkDisplay(Container)%>">
                <%#GetButton(Container)%>
		        <input type=hidden id="seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq")%>">
		        <input type=hidden id="seq1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq1")%>">
		        <input type=hidden id="gr_mp_date_<%#(Container.ItemIndex+1)%>" value="<%#Eval("mg_in_date","{0:yyyy/M/d}")%>">
		        <input type=hidden id="rs_type_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_type")%>">
		        <input type=hidden id="rs_class_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_class")%>">
		        <input type=hidden id="rs_code_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_code")%>">
		        <input type=hidden id="act_code_<%#(Container.ItemIndex+1)%>" value="<%#Eval("act_code")%>">
		        <input type=hidden id="cust_seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("cust_seq")%>">
		        <input type=hidden id="att_sql_<%#(Container.ItemIndex+1)%>" value="<%#Eval("att_sql")%>">
		        <input type=hidden id="temp_rs_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("temp_rs_sqlno")%>">
		        <input type=hidden id="rs_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_no")%>">
		        <input type=hidden id="rs_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_sqlno")%>">
		        <input type=hidden id="dmt_scode_<%#(Container.ItemIndex+1)%>" value="<%#Eval("dmt_scode")%>">
		        <input type=hidden id="step_grade_<%#(Container.ItemIndex+1)%>" value="<%#Eval("step_grade")%>">
		        <input type=hidden id="mg_step_grade_<%#(Container.ItemIndex+1)%>" value="<%#Eval("mg_send_grade")%>">
		        <input type=hidden id="mg_rs_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("mg_send_rs_sqlno")%>">
		        <input type=hidden id="child_flag_<%#(Container.ItemIndex+1)%>" value="<%#Eval("child_flag")%>">
		        <input type=hidden id="step_date_<%#(Container.ItemIndex+1)%>" value="<%#Eval("step_date","{0:yyyy/M/d}")%>">
		        <input type=hidden id="opt_attach_flag_<%#(Container.ItemIndex+1)%>" value="<%#Eval("opt_attach_flag")%>">
		        <input type=hidden id="todo_sqlno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("todo_sqlno")%>"><!--官發對應承辦交辦發文的todo_dmt.sqlno-->
		        <input type=hidden id="appl_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("appl_name")%>">
		        <input type=hidden id="rs_detail_<%#(Container.ItemIndex+1)%>" value="<%#Eval("rs_detail")%>">
		        <input type=hidden id="gs_send_way_<%#(Container.ItemIndex+1)%>" value="<%#Eval("gs_send_way")%>"><!--官發之發文方式-->
		        <input type=hidden id="receipt_type_<%#(Container.ItemIndex+1)%>" value="<%#Eval("receipt_type")%>">
		        <input type=hidden id="fees_<%#(Container.ItemIndex+1)%>" value="<%#Eval("fees")%>">
		    </td>
            <td class="whitetablebg" align="center" nowrap rowspan=<%=tcolspan%>>
			    <font style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CapplClick('<%#Eval("seq")%>','<%#Eval("seq1")%>')" title="案件主檔查詢"><%#Eval("fseq")%></font>
				<span style="display:<%#(Eval("mg_pr_remark").ToString()!=""?"":"none")%>"><br><img src="../images/remark.gif" title="<%#Eval("mg_pr_remark")%>"></span>
                <%#(Eval("mg_pr_remark").ToString()!=""?"":"<BR>")%>
				<img src="<%=Page.ResolveUrl("~/images/ftv2folderopen.gif")%>" border="0" style="cursor:pointer;display:<%#(Eval("opt_attach_flag").ToString()=="Y"?"":"none")%>" title="爭救案上傳文件" onClick="qryopt_attach('<%#Eval("seq")%>','<%#Eval("main_rs_no")%>','<%#Eval("seq1")%>')">
		    </td>
		    <td class="whitetablebg" align="center" style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'"  onclick="QstepClick('<%#Eval("seq")%>','<%#Eval("seq1")%>')" title="案件進度查詢"><%#Eval("step_grade")%></td>
		    <td class="whitetablebg" rowspan=<%=tcolspan%>><%#Eval("appl_name").ToString().Left(10)%></td>
		    <td class="whitetablebg" align="center" rowspan=<%=tcolspan%>><%#Eval("step_date","{0:yyyy/M/d}")%></td>
		    <td class="whitetablebg" nowrap align="center" rowspan=<%=tcolspan%>>
                <%#(Eval("main_flag").ToString()=="N"?"<font color=red>*</font>":"")%>
                <%#Eval("rs_no")%>
                <%#(Eval("main_flag").ToString()=="N"?"<br><font color=blue>(" +Eval("main_rs_no")+")</font>":"")%>
		    </td>
		    <td class="whitetablebg" align="left" rowspan=<%=tcolspan%>><%#Eval("rs_detail")%></td>
		    <td class="whitetablebg" nowrap align="left" rowspan=<%=tcolspan%>>
			    <input type=hidden id=mg_apply_date_<%#(Container.ItemIndex+1)%> value="<%#Eval("mg_apply_date","{0:yyyy/M/d}")%>">
			    <input type=text size=10 id=apply_date_<%#(Container.ItemIndex+1)%> <%=Qclass%> value="<%#Eval("apply_date","{0:yyyy/M/d}")%>"><br>
			    <span style="<%#Eval("mgdate_style")%>">總：<%#Eval("mg_apply_date","{0:yyyy/M/d}")%></span>
		    </td>
		    <td class="whitetablebg" nowrap align="left" rowspan=<%=tcolspan%>>
			    <input type=hidden id=mg_apply_no_<%#(Container.ItemIndex+1)%> value="<%#Eval("mg_apply_no")%>">
			    <input type=text size=10 id=apply_no_<%#(Container.ItemIndex+1)%> <%=Qclass%> value="<%#Eval("apply_no")%>" onblur="chkapplyno(<%#(Container.ItemIndex+1)%>)"><br>
			    <span style="<%#Eval("mgno_style")%>">總：<%#Eval("mg_apply_no")%></span>
		    </td>
		    <td class="whitetablebg" nowrap align="right" rowspan=<%=tcolspan%>><%#Eval("fees")%></td>
		    <td width="10%" class="whitetablebg" align="left" rowspan=<%=tcolspan%>><%#Eval("ctrl_date")%></td>

            <asp:Panel runat="server" Visible='<%#qrydowhat== "mg_gs"%>'><!--發文確認才顯示-->
			<td class="whitetablebg" nowrap align="left">
				<input type=radio name="radcs_<%#(Container.ItemIndex+1)%>" value="Y" checked onclick="show_send_way('<%#(Container.ItemIndex+1)%>')">是
				<input type=radio name="radcs_<%#(Container.ItemIndex+1)%>" value="N" onclick="show_send_way('<%#(Container.ItemIndex+1)%>')">否
				<input type=checkbox id="chkcsd_flag_<%#(Container.ItemIndex+1)%>" value="Y" onclick="show_cs_remark('<%#(Container.ItemIndex+1)%>')"><font color=blue size=1>要延期客發</font>
				<span id="sp_send_way_<%#(Container.ItemIndex+1)%>">
				    <br>發文方式：<select id="send_way_<%#(Container.ItemIndex+1)%>"><%#GetSendWay(Container)%></select> 
				</span>
				<span id="sp_cs_remark_<%#(Container.ItemIndex+1)%>" style="display:none">
				    <input type=text id="opmail_date_<%#(Container.ItemIndex+1)%>" value="<%#GetPMailDate(Container)%>">
				    <br><font color=red size=1>原因：</font>
					<SELECT id="cs_remark_code_<%#(Container.ItemIndex+1)%>" onchange="cs_remark_code_onchange('<%#(Container.ItemIndex+1)%>')">
					<%#GetCSRemark(Container)%>
					</select><br>
					<input type=text id="cs_remark_<%#(Container.ItemIndex+1)%>" size=26 >
				    <br><font color=red size=1>預定寄發日：</font><input type="text" id="pmail_date_<%#(Container.ItemIndex+1)%>" size="10" value="<%#GetPMailDate(Container)%>" onblur="chkpmaildate(<%#(Container.ItemIndex+1)%>)" class="dateField">
				</span>
			</td>
		    </asp:Panel>
	        <asp:Panel runat="server" Visible='<%#qrydowhat== "mg_gs_back"%>'><!--總管處退件才顯示-->
			<td class="whitetablebg"><%#Eval("reject_reason")%></td>
		    </asp:Panel>
	    </tr>
        <asp:Panel runat="server" Visible='<%#qrydowhat== "mg_gs"%>'><!--發文確認才顯示-->
  	    <tr class="main_tr" rec="<%#(Container.ItemIndex+1)%>">
		    <td class="whitetablebg" nowrap align="center">
                <img src="<%=Page.ResolveUrl("~/images/email01.gif")%>" style="cursor:pointer" title="Email通知總收發" align="absmiddle" border="0" onClick="tomgbutton_email('<%#Eval("fseq")%>','<%#Eval("rs_no")%>','<%#Eval("step_date","{0:yyyy/M/d}")%>','<%#Eval("mp_date","{0:yyyy/M/d}")%>','<%#Eval("rs_detail")%>')">
		    </td>
		    <td class="whitetablebg" nowrap align="left">
			    <input type=radio name="radscan_<%#(Container.ItemIndex+1)%>" value="Y" <%#(ReqVal.TryGet("radscan")!="N"?"checked":"")%>>需要
			    <input type=radio name="radscan_<%#(Container.ItemIndex+1)%>" value="N" <%#(ReqVal.TryGet("radscan")=="N"?"checked":"")%>>不需要
	        </td>
        </tr>
		</asp:Panel>
        <!--子案-->
        <asp:Repeater id="childRepeater" runat="server">
	        <ItemTemplate>
				<tr class="child_tr">
					<td class="lightbluetable3" align=right>
                        <%#GetButtonC(Container)%>
						<input type=hidden name="seq_<%#GetSubIdx(Container)%>" id="seq_<%#GetSubIdx(Container)%>" value="<%#Eval("seq")%>">
						<input type=hidden name="seq1_<%#GetSubIdx(Container)%>" id="seq1_<%#GetSubIdx(Container)%>" value="<%#Eval("seq1")%>">
						<input type=hidden name="gr_mp_date_<%#GetSubIdx(Container)%>" id="gr_mp_date_<%#GetSubIdx(Container)%>" value="<%#Eval("mg_in_date","{0:yyyy/M/d}")%>">
						<input type=hidden name="rs_type_<%#GetSubIdx(Container)%>" id="rs_type_<%#GetSubIdx(Container)%>" value="<%#Eval("rs_type")%>">
						<input type=hidden name="rs_class_<%#GetSubIdx(Container)%>" id="rs_class_<%#GetSubIdx(Container)%>" value="<%#Eval("rs_class")%>">
						<input type=hidden name="rs_code_<%#GetSubIdx(Container)%>" id="rs_code_<%#GetSubIdx(Container)%>" value="<%#Eval("rs_code")%>">
						<input type=hidden name="cust_seq_<%#GetSubIdx(Container)%>" id="cust_seq_<%#GetSubIdx(Container)%>" value="<%#Eval("cust_seq")%>">
						<input type=hidden name="att_sql_<%#GetSubIdx(Container)%>" id="att_sql_<%#GetSubIdx(Container)%>" value="<%#Eval("att_sql")%>">
						<input type=hidden name="temp_rs_sqlno_<%#GetSubIdx(Container)%>" id="temp_rs_sqlno_<%#GetSubIdx(Container)%>" value="<%#Eval("temp_rs_sqlno")%>">
						<input type=hidden name="rs_no_<%#GetSubIdx(Container)%>" id="rs_no_<%#GetSubIdx(Container)%>" value="<%#Eval("rs_no")%>">
						<input type=hidden name="dmt_scode_<%#GetSubIdx(Container)%>" id="dmt_scode_<%#GetSubIdx(Container)%>" value="<%#Eval("dmt_scode")%>">
						<input type=hidden name="step_grade_<%#GetSubIdx(Container)%>" id="step_grade_<%#GetSubIdx(Container)%>" value="<%#Eval("step_grade")%>">
						<input type=hidden name="mg_step_grade_<%#GetSubIdx(Container)%>" id="mg_step_grade_<%#GetSubIdx(Container)%>" value="<%#Eval("mg_send_grade")%>">
						<input type=hidden name="mg_rs_sqlno_<%#GetSubIdx(Container)%>" id="mg_rs_sqlno_<%#GetSubIdx(Container)%>" value="<%#Eval("mg_send_rs_sqlno")%>">	
					</td>
					<td class="lightbluetable3" align="center" nowrap><%#Eval("fseq")%><br><font color=red title="母案本所編號">(<%#Eval("mfseq")%>)</font>
                        <span style="display:<%#(Eval("mg_pr_remark").ToString()!=""?"":"none")%>"><br><img src="../images/remark.gif" title="<%#Eval("mg_pr_remark")%>"></span>
					</td>
					<td class="lightbluetable3" align="center">
                        <%#Eval("step_grade")%><br>
                        <asp:Panel runat="server" Visible='<%#qrydowhat== "mg_gs"%>'>
                            <img src="<%=Page.ResolveUrl("~/images/email01.gif")%>" style="cursor:pointer" title="Email通知總收發" align="absmiddle" border="0" onClick="tomgbutton_email('<%#Eval("fseq")%>','<%#Eval("rs_no")%>','<%#Eval("step_date","{0:yyyy/M/d}")%>','<%#Eval("mp_date","{0:yyyy/M/d}")%>','<%#Eval("rs_detail")%>')">
                        </asp:Panel>
                    </td>
					<td class="lightbluetable3" ><%#Eval("appl_name").ToString().Left(10)%></td>
					<td class="lightbluetable3" align="center"><%#Eval("step_date","{0:yyyy/M/d}")%></td>
					<td class="lightbluetable3" nowrap align="center">
                        <%#(Eval("main_flag").ToString()=="N"?"<font color=red>*</font>":"")%>
                        <%#Eval("rs_no")%>
                        <%#(Eval("main_flag").ToString()=="N"?"<br><font color=blue>(" +Eval("main_rs_no")+")</font>":"")%>
					</td>
					<td class="lightbluetable3" align="left"><%#Eval("rs_detail")%></td>
					<td class="lightbluetable3" nowrap align="left">
						<input type=hidden name="mg_apply_date_<%#GetSubIdx(Container)%>" id="mg_apply_date_<%#GetSubIdx(Container)%>" value="<%#Eval("mg_apply_date","{0:yyyy/M/d}")%>">
						<input type=text size=10 name="apply_date_<%#GetSubIdx(Container)%>" id="apply_date_<%#GetSubIdx(Container)%>" <%=Qclass%> value="<%#Eval("apply_date","{0:yyyy/M/d}")%>"><br>
			            <span style="<%#Eval("mgdate_style")%>">總：<%#Eval("mg_apply_date","{0:yyyy/M/d}")%></span>
					</td>
					<td class="lightbluetable3" nowrap align="left">
						<input type=hidden name="mg_apply_no_<%#GetSubIdx(Container)%>" id="mg_apply_no_<%#GetSubIdx(Container)%>" value="<%#Eval("mg_apply_no")%>">
						<input type=text size=10 name="apply_no_<%#GetSubIdx(Container)%>" id="apply_no_<%#GetSubIdx(Container)%>" <%=Qclass%> value="<%#Eval("apply_no")%>" onblur="chkapplyno(<%#(Container.ItemIndex+1)%>)"><br>
			            <span style="<%#Eval("mgno_style")%>">總：<%#Eval("mg_apply_no")%></span>
					</td>
					<td class="lightbluetable3" nowrap align="right"><%#Eval("fees")%></td>
					<td class="lightbluetable3" align="left"></td>
					<td class="lightbluetable3" nowrap align="left"></td>
				</tr>
 	        </ItemTemplate>
            <FooterTemplate>
                <input type="hidden" id="mchknum_<%#(((RepeaterItem)Container.Parent.Parent).ItemIndex+1)%>" value="<%#((Repeater)Container.Parent).Items.Count%>">
            </FooterTemplate>
      </asp:Repeater>
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
		    <tr class="FormName"><td><div align="left" style="color:blue"><%#FormName%></div></td>
            </tr>
	    </table>
	    <br>
    </FooterTemplate>
    </asp:Repeater>

    <%#DebugStr%>
</form>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        this_init();
    });

    function this_init() {
        $("select[id^='act_code_']").each(function(idx) {
            $(this).trigger("change");
        });

        $(".Lock").lock();
        $("input.dateField").datepick();
    }

    //執行查詢
    function goSearch() {
        //發文確認時才須選擇掃描預設
        if ($("input[name='qrydowhat']:checked").val()=="mg_gs"){
            if ($("input[name='qryrectitle']:checked").val()=="E" && typeof($("input[name=radscan]:checked").val()) === "undefined" ){
                alert("請選擇掃描預設");
                return false;
            }
        }

        $("#regPage").submit();
    };
    //////////////////////
    //[電子收據]
    $(".receipt").on("click",function(){
        var record=$(this).parents("tr:first").attr("rec");
        var url=$(this).attr("v1");
        $(this).parents("tr:first").siblings("tr[rec='"+record+"']").andSelf().find("td").each(function(tdindex,tditem){
            if($(tditem).hasClass("enter")){
                window.parent.Eblank.location.href="about:blank";
                $(tditem).removeClass("enter");
                window.parent.tt.rows = "100%, *";
            }else{
                window.parent.Eblank.location.href= "brta33_List_doc.aspx?url="+url+"&chkobj="+record;
                $(tditem).addClass("enter");
                window.parent.tt.rows = "55%, 45%";
            }
        })
		
        $(this).parents("tr:first").siblings("tr[rec!='"+record+"']").find("td").removeClass("enter");
    })
    //作業狀態
    $("input[name=qrydowhat]").on("click",function(){
        $("input[name='qryrectitle']:checked").triggerHandler("click");
    })
    //發文方式
    $("input[name='qrysend_way']").on("click",function(){
        if ($(this).val()=="M"){
            $("#qryrectitleP").click();
        }
        if ($(this).val()=="E" || $(this).val()=="EA"){
            $("#qryrectitleE").click();
        }
    })
    //收據種類
    $("input[name='qryrectitle']").on("click",function(){
        $("input[name=radscan]").attr("checked",false);//點選收據種類一律清空預設掃描radio
        if ($(this).val()=="P"){//紙本收據預設不指定
            $("#scanYN").val("");
            $("#qryfee0").click();
            $("#spnScan").hide();
        }else{
            $("#qryfeeY").click();//電子收據預設有規費
            //確認退件時不須選擇掃描預設
            if ($("input[name='qrydowhat']:checked").val()=="mg_gs_back"){
                $("#scanYN").val("");
                $("#spnScan").hide();
            }else{
                $("#spnScan").show();
            }
        }
		
        if ($("input[name='qrysend_way']:checked").val()=="M" && $(this).val()=="E"){
            $("input[name='qrysend_way'][value='E']").attr("checked",true);
        }
    })
    //選擇掃描預設
    $("input[name=radscan]").on("click",function(){
        if ($("#scanYN").val()!="" && $("#scanYN").val()!=$(this).val()){
            alert("請重新執行[查詢]變更預設值。");
        }
        $("#scanYN").val($(this).val());
    })
    //爭救案上傳文件
    function qryopt_attach(pseq,prs_no,pseq1){
        window.parent.Eblank.location.href=getRootPath() +"/brt6m/brt62_list.aspx?prgid=<%=prgid%>&qryseq=" + pseq + "&qryseq1=" + pseq1 + "&rs_no=" + prs_no + "&qryOrder=a.seq,a.seq1 asc&frameblank=Y";
    }
    //案件主檔查詢
    function CapplClick(pseq,pseq1){
        window.showModalDialog(getRootPath() + "/brt5m/brt15ShowFP.aspx?seq=" + pseq + "&seq1=" + pseq1 + "&submittask=Q", "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }
    //案件進度查詢
    function QstepClick(pseq,pseq1) {
        //***todo
        window.open(getRootPath() + "/brtam/brta61Edit.aspx?submitTask=Q&qtype=A&prgid=<%=prgid%>&closewin=Y&winact=1&aseq=" + pseq + "&aseq1=" + pseq1, "myWindowOneN", "width=900 height=700 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }
    //客函選項
    function show_send_way(t){
        if($("input[name='radcs_"+t+"']:checked").val()=="N"){
            $("#sp_send_way_"+t).hide();//發文方式
            $("#sp_cs_remark_"+t).show();//延期客發原因
            $("#chkcsd_flag_"+t).prop("checked",false).prop("disabled",true);//⬜要延期客發
        }else if($("input[name='radcs_"+t+"']:checked").val()=="Y"){
            $("#sp_send_way_"+t).show();//發文方式
            $("#chkcsd_flag_"+t).prop("disabled",false);//⬜要延期客發
            show_cs_remark(t);
        } 
    }
    //要延期客發
    function show_cs_remark(t){
        if($("#chkcsd_flag_"+t).prop("checked")==true){
            $("#sp_cs_remark_"+t).show();//延期客發原因
        } else {
            $("#sp_cs_remark_"+t).hide();//延期客發原因
        }
    }
    //客函延期寄發原因代碼
    function cs_remark_code_onchange(pnum){
        $("#cs_remark_" +pnum).val($( "#cs_remark_code_"+pnum+" option:selected").text());
    }
    //預定寄發日
    function chkpmaildate(t){
        if ($("#pmail_date_"+t).val() != "" && !$.isDate($("#pmail_date_"+t).val())) {
            alert("日期格式錯誤，請重新輸入!!");
            $("#pmail_date_"+t).focus();
            return false;
        }
    }
    //檢查申請號並補足9碼
    function chkapplyno(pnum){
        var pvalue=$("#apply_no_"+pnum).value;
    
        if (chkNum(pvalue,"申請號")) return false;
        if (fDataLenX(pvalue, 9, "申請號")=="") return false;
        var tno=chkgno(pvalue,9);
        $("#apply_no_"+pnum).val(tno);
    }
    //重抓總管處案件主檔資料
    function getmgt(tseq,tseq1,temp_rs_sqlno,mg_step_rs_sqlno){
        if (confirm("是否確定重新取得總收發案件資料？")){
            var url = getRootPath() + "/ajax/brta33_Get_mgt.aspx?prgid=<%=prgid%>&cgrs=GS&temp_rs_sqlno="+temp_rs_sqlno+"&mg_step_rs_sqlno=" + mg_step_rs_sqlno+"&qbranch=<%=Session["seBranch"]%>&qseq="+tseq+"&qseq1=" + tseq1;
            ajaxScriptByGet("重新取得總收發案件資料", url);
        }
    }
    //資料有誤通知總收發修正
    function tomgbutton_email(fseq,rs_no,step_date,mp_date,rs_detail){
        <%
        string strto = "";//收件者
        string strcc = "";//副本
        string strbcc = "";//密件副本
        string Sender=Sys.GetSession("scode");//寄件者
        if (Sys.Host=="web08") {
            strto = "";
            strcc = "m1583;";
            strbcc = "";
        } else if (Sys.Host == "web10") {
            strto = emg_scode + ";";
            strcc = emg_agscode + ";";//2016/4/19修改
            strbcc = "";
        } else {
            strto = emg_scode + ";";
            strcc = emg_agscode + ";";//2016/4/19修改
            strbcc = "";
        }
        %>
        var tsubject = "國內所－官發資料修正通知（區所編號：" + fseq + "，發文字號：" + rs_no + " ）";//主旨
        var strto = "<%=strto%>";//收件者
        var strcc = "<%=strcc%>";//副本
        var strbcc = "<%=strbcc%>";//密件副本
        
        var tbody = "致: 總管處 程序%0A%0A"
        tbody += "【通 知 日 期 】: " + (new Date()).format("yyyy/M/d");
        tbody += "%0A【區所編號】:" + fseq + "，發文字號：" + rs_no+ "，發文日期：" +step_date +"，總收發日期：" + mp_date ;
        tbody += "%0A【發文內容】:" + rs_detail;
        tbody += "%0A 檢核資料有誤 ，煩請確認，如有資料修正，請更正後通知。";
        tbody += "%0A【檢核項目】";
        tbody += "%0A申請日期";
        tbody += "%0A申請號碼";

        ActFrame.location.href = "mailto:" + strto + "?subject=" + tsubject + "&body=" + tbody + "&cc=" + strcc;//+"&bcc="+ strbcc;
    }

    function chkdata(pdowhat,pnum){
        if(pdowhat=="mg_gs"){
            var tflag=$("#chk_"+pnum).prop("checked");
            if (tflag==true){
                var br_apply_date=$("#apply_date_"+pnum).val();
                var br_apply_no=$("#apply_no_"+pnum).val();
                var mg_apply_date=$("#mg_apply_date_"+pnum).val();
                var mg_apply_no=$("#mg_apply_no_"+pnum).val();
                var tseq=$("#seq_"+pnum).val();
                var tseq1=$("#seq1_"+pnum).val();
                var tchild=$("#child_flag_"+pnum).val();
                var tchild_num=$("#mchknum_"+pnum).val();
                var fseq=tseq;
                if (tseq1!="_") fseq+=tseq1;

                if(br_apply_no!=mg_apply_no){
                    alert("本所編號：" + fseq + "的區所申請號與總管處申請號不同，請先檢核資料正確後再執行確認！");
                    $("#chk_"+pnum).prop("checked",false);
                    return false;
                }
                if(br_apply_date!=mg_apply_date){
                    alert("本所編號：" + fseq + "的區所申請日與總管處申請日不同，請先檢核資料正確後再執行確認！");
                    $("#chk_"+pnum).prop("checked",false);
                    return false;
                }
                if (fDataLenX(br_apply_no, 9, "申請號")=="") return false;
                $("#apply_date_"+pnum).prop("disabled",true);
                $("#apply_no_"+pnum).prop("disabled",true);

                //檢查子案的申請號資料
                if(tchild=="Y"){
                    for (var k = 1; k <= CInt(tchild_num) ; k++) {
                        var tnum=pnum+"_"+k;
                        var br_apply_date=$("#apply_date_"+tnum).val();
                        var br_apply_no=$("#apply_no_"+tnum).val();
                        var mg_apply_date=$("#mg_apply_date_"+tnum).val();
                        var mg_apply_no=$("#mg_apply_no_"+tnum).val();
                        var tseq=$("#seq_"+tnum).val();
                        var tseq1=$("#seq1_"+tnum).val();
                        var cfseq=tseq;
                        if (cfseq!="_") cfseq+=tseq1;

                        if(br_apply_no!=mg_apply_no){
                            alert("本所編號：" + cfseq + "的區所申請號與總管處申請號不同，請先檢核資料正確後再執行確認！");
                            $("#chk_"+pnum).prop("checked",false);
                            return false;
                        }
                        if(br_apply_date!=mg_apply_date){
                            alert("本所編號：" + cfseq + "的區所申請日與總管處申請日不同，請先檢核資料正確後再執行確認！");
                            $("#chk_"+pnum).prop("checked",false);
                            return false;
                        }
                        if (fDataLenX(br_apply_no, 9, "申請號")=="") return false;
                        $("#apply_date_"+tnum).prop("disabled",true);
                        $("#apply_no_"+tnum).prop("disabled",true);
                    }
                }
                //檢查是否客戶報導及選擇發文方式
                if($("input[name='radcs_"+pnum+"']:checked").val()=="Y"){
                    if ($("#send_way_"+pnum).val()==""){
                        alert("本所編號：" + fseq + "需要客戶報導，請選擇發文方式！");
                        $("#send_way_"+pnum).focus();
                        return false;
                    }
                    //要延期客發
                    if($("#chkcsd_flag_"+pnum).prop("checked")==true){
                        if($("#cs_remark_"+pnum).val()==""){
                            alert("本所編號：" + fseq + "客戶函要延期客發，請填寫原因！");
                            $("#cs_remark_"+pnum).focus();
                            return false;
                        }
                        if($("#pmail_date_"+pnum).val()==""){
                            alert("本所編號：" + fseq + "客戶函要延期客發，請填寫預定寄發日！");
                            $("#pmail_date_"+pnum).focus();
                            return false;
                        }else{
                            var pmail_date = CDate($("#pmail_date_"+pnum).val());
                            if(pmail_date.getTime()< Today().getTime()){
                                alert("本所編號：" + fseq + "客函預定寄發日期小於今天，請檢查並重新輸入！");
                                $("#pmail_date_"+pnum).focus();
                                return false;
                            }
                        }
                    }else{
                        //要客戶報導不延期，預定寄發日=預設值
                        $("#pmail_date_"+pnum).val($("#opmail_date_"+pnum).val());
                    }
                }else{
                    if($("#cs_remark_"+pnum).val()==""){
                        alert("本所編號：" + fseq + "不需要客戶報導，請填寫原因！");
                        $("#cs_remark_"+pnum).focus();
                        return false;
                    }
                }
            }else{
                $("#apply_date_"+pnum).prop("disabled",false);
                $("#apply_no_"+pnum).prop("disabled",false);
            }
        }
    }
    ///////////////////////////////////////
    //串接資料
    function setRowData(){
        $("#rows_chk").val(getJoinValue(".main_tr input[id^='chk_']"));
        $("#rows_seq").val(getJoinValue(".main_tr input[id^='seq_']"));
        $("#rows_seq1").val(getJoinValue(".main_tr input[id^='seq1_']"));
        $("#rows_gr_mp_date").val(getJoinValue(".main_tr input[id^='gr_mp_date_']"));
        $("#rows_rs_type").val(getJoinValue(".main_tr input[id^='rs_type_']"));
        $("#rows_rs_class").val(getJoinValue(".main_tr input[id^='rs_class_']"));
        $("#rows_rs_code").val(getJoinValue(".main_tr input[id^='rs_code_']"));
        $("#rows_act_code").val(getJoinValue(".main_tr input[id^='act_code_']"));
        $("#rows_cust_seq").val(getJoinValue(".main_tr input[id^='cust_seq_']"));
        $("#rows_att_sql").val(getJoinValue(".main_tr input[id^='att_sql_']"));
        $("#rows_temp_rs_sqlno").val(getJoinValue(".main_tr input[id^='temp_rs_sqlno_']"));
        $("#rows_rs_no").val(getJoinValue(".main_tr input[id^='rs_no_']"));
        $("#rows_rs_sqlno").val(getJoinValue(".main_tr input[id^='rs_sqlno_']"));
        $("#rows_dmt_scode").val(getJoinValue(".main_tr input[id^='dmt_scode_']"));
        $("#rows_step_grade").val(getJoinValue(".main_tr input[id^='step_grade_']"));
        $("#rows_mg_step_grade").val(getJoinValue(".main_tr input[id^='mg_step_grade_']"));
        $("#rows_mg_rs_sqlno").val(getJoinValue(".main_tr input[id^='mg_rs_sqlno_']"));
        $("#rows_child_flag").val(getJoinValue(".main_tr input[id^='child_flag_']"));
        $("#rows_step_date").val(getJoinValue(".main_tr input[id^='step_date_']"));
        $("#rows_opt_attach_flag").val(getJoinValue(".main_tr input[id^='opt_attach_flag_']"));
        $("#rows_todo_sqlno").val(getJoinValue(".main_tr input[id^='todo_sqlno_']"));
        $("#rows_appl_name").val(getJoinValue(".main_tr input[id^='appl_name_']"));
        $("#rows_rs_detail").val(getJoinValue(".main_tr input[id^='rs_detail_']"));
        $("#rows_gs_send_way").val(getJoinValue(".main_tr input[id^='gs_send_way_']"));
        $("#rows_receipt_type").val(getJoinValue(".main_tr input[id^='receipt_type_']"));
        $("#rows_fees").val(getJoinValue(".main_tr input[id^='fees_']"));

        $("#rows_mg_apply_date").val(getJoinValue(".main_tr input[id^='mg_apply_date_']"));
        $("#rows_apply_date").val(getJoinValue(".main_tr input[id^='apply_date_']"));
        $("#rows_mg_apply_no").val(getJoinValue(".main_tr input[id^='mg_apply_no_']"));
        $("#rows_apply_no").val(getJoinValue(".main_tr input[id^='apply_no_']"));
        $("#rows_radcs").val(getJoinValue(".main_tr input[name^='radcs_']:checked"));
        $("#rows_chkcsd_flag").val(getJoinValue(".main_tr input[id^='chkcsd_flag_']"));
        $("#rows_send_way").val(getJoinValue(".main_tr select[id^='send_way_']"));
        $("#rows_opmail_date").val(getJoinValue(".main_tr input[id^='opmail_date_']"));
        $("#rows_cs_remark_code").val(getJoinValue(".main_tr select[id^='cs_remark_code_']"));
        $("#rows_cs_remark").val(getJoinValue(".main_tr input[id^='cs_remark_']:not([id^='cs_remark_code_'])"));
        $("#rows_pmail_date").val(getJoinValue(".main_tr input[id^='pmail_date_']"));
        $("#rows_radscan").val(getJoinValue(".main_tr input[name^='radscan_']:checked"));

        $("#rows_mchknum").val(getJoinValue("input[id^='mchknum_']"));
    }

    //回條確認檢核
    function formAddSubmit(){
        for (var pno = 1; pno <= CInt($("#row").val()) ; pno++) {
            if($("#chk_"+pno).prop("checked")==true){
                var tseq=$("#seq_"+pno).val();
                var tseq1=$("#seq1_"+pno).val();
                var fseq=tseq;
                if (fseq!="_") fseq+=tseq1;
			
                //檢查是否客戶報導及選擇發文方式
                if($("input[name='radcs_"+pno+"']:checked").val()=="Y"){
                    if ($("#send_way_"+pno).val()==""){
                        alert("本所編號：" + fseq + "需要客戶報導，請選擇發文方式！");
                        $("#send_way_"+pno).focus();
                        return false;
                    }
                    //要延期客發
                    if($("#chkcsd_flag_"+pno).prop("checked")==true){
                        if($("#cs_remark_"+pno).val()==""){
                            alert("本所編號：" + fseq + "客戶函要延期客發，請填寫原因！");
                            $("#cs_remark_"+pno).focus();
                            return false;
                        }
                        if($("#pmail_date_"+pno).val()==""){
                            alert("本所編號：" + fseq + "客戶函要延期客發，請填寫預定寄發日！");
                            $("#pmail_date_"+pno).focus();
                            return false;
                        }else{
                            var pmail_date = CDate($("#pmail_date_"+pno).val());
                            if(pmail_date.getTime()< Today().getTime()){
                                alert("本所編號：" + fseq + "客函預定寄發日期小於今天，請檢查並重新輸入！");
                                $("#pmail_date_"+pno).focus();
                                return false;
                            }
                        }
                    }else{
                        //要客戶報導不延期，預定寄發日=預設值
                        $("#pmail_date_"+pno).val($("#opmail_date_"+pno).val());
                    }
                }else{
                    if($("#cs_remark_"+pno).val()==""){
                        alert("本所編號：" + fseq + "不需要客戶報導，請填寫原因！");
                        $("#cs_remark_"+pno).focus();
                        return false;
                    }
                }
            }
        }
	
        //檢查是否有勾選
        var totnum=$("input[id^='chk_']:checked").length;
        if (totnum == 0){
            alert("請勾選您要確認的案件!!");
            return false;
        }

        if (!confirm("共有" + totnum + "筆確認 , 是否確定?")) return false;
        
        //串接資料
        setRowData();

        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));
        $("#qrydowhat").val($("input[name='qrydowhat']:checked").val());
        
        var formData = new FormData($('#reg')[0]);
        ajaxByForm("brta33_Update.aspx",formData)
        .complete(function( xhr, status ) {
            $("#dialog").html(xhr.responseText);
            $("#dialog").dialog({
                title: '存檔訊息',modal: true,maxHeight: 500,width: 800,closeOnEscape: false
                ,buttons: {
                    確定: function() {
                        $(this).dialog("close");
                    }
                }
                ,close:function(event, ui){
                    if(status=="success"){
                        if(!$("#chkTest").prop("checked")){
                            window.parent.tt.rows="100%,0%";
                            goSearch();//重新整理
                        }
                    }
                }
            });
        });
    }

    //退件確認檢核
    function formReSubmit(){
        //檢查是否有勾選
        var totnum=$("input[id^='chk_']:checked").length;
        if (totnum == 0){
            alert("請勾選您要退件的案件!!");
            return false;
        }

        if (!confirm("共有" + totnum + "筆退件 , 是否確定?")) return false;
        
        //串接資料
        setRowData();

        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));
        $("#qrydowhat").val($("input[name='qrydowhat']:checked").val());
        
        var formData = new FormData($('#reg')[0]);
        ajaxByForm("brta33_Update.aspx",formData)
        .complete(function( xhr, status ) {
            $("#dialog").html(xhr.responseText);
            $("#dialog").dialog({
                title: '存檔訊息',modal: true,maxHeight: 500,width: 800,closeOnEscape: false
                ,buttons: {
                    確定: function() {
                        $(this).dialog("close");
                    }
                }
                ,close:function(event, ui){
                    if(status=="success"){
                        if(!$("#chkTest").prop("checked")){
                            window.parent.tt.rows="100%,0%";
                            goSearch();//重新整理
                        }
                    }
                }
            });
        });
    }
</script>