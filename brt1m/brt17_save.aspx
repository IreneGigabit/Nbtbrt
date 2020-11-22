<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>

<script runat="server">
    protected string SQL = "";
    protected string msg = "";

    protected StringBuilder strOut = new StringBuilder();

    protected void Page_Load(object sender, EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        string submitTask = (Request["submitTask"] ?? "").Trim();
        string in_scode = (Request["in_scode"] ?? "").Trim();
        string in_no = (Request["in_no"] ?? "").Trim();
        string case_no = (Request["case_no"] ?? "").Trim();
        string seq = (Request["seq"] ?? "").Trim();
        string seq1 = (Request["seq1"] ?? "").Trim();
        string cust_area = (Request["cust_area"] ?? "").Trim();
        string cust_seq = (Request["cust_seq"] ?? "").Trim();
        string case_stat = (Request["case_stat"] ?? "").Trim();
        string arcase = (Request["arcase"] ?? "").Trim();
        string cappl_name = (Request["cappl_name"] ?? "").Trim();
        string ap_cname1 = (Request["ap_cname1"] ?? "").Trim();

        if (submitTask == "D") {
            msg = "營洽接洽記錄刪除";
            DBHelper conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
            try {
                SQL = "update case_dmt set stat_code='XX',mark='D' where in_scode='" + in_scode + "' and in_no='" + in_no + "'";
                conn.ExecuteNonQuery(SQL);

                //上傳文件註記刪除
                SQL = "update dmt_attach set attach_flag='D',tran_date=getdate(),tran_scode='" + Session["scode"] + "' where in_no='" + in_no + "' and source='case' ";
                conn.ExecuteNonQuery(SQL);

                //log
                string strnote = "刪除洽案資料(" + in_scode + "-" + in_no + "-" + case_stat + "-" + arcase + ")(本所編號:" + seq + "-" + seq1 + "-" + cappl_name + "-" + ap_cname1 + ")";
                SQL = " insert into rec_log(tableid,prgid,in_no,case_no,oseq,oseq1,ocust_area,ocust_seq,oscode,scode,tran_date,note)";
                SQL += " values('case_brt|todolist','brt17','" + in_no + "','" + case_no + "','" + seq + "'";
                SQL += ",'" + seq1 + "','" + cust_area + "','" + cust_seq + "','" + in_scode + "','" + Session["scode"] + "',getdate()," + Util.dbnull(strnote) + ")";
                conn.ExecuteNonQuery(SQL);

                msg += "成功(" + in_scode + "-" + in_no + ")";
                conn.Commit();
                //conn.RollBack();
            }
            catch (Exception ex) {
                conn.RollBack();
                msg += "失敗(" + in_scode + "-" + in_no + ")";
                throw new Exception(msg, ex);
            }
            finally {
                conn.Dispose();
            }
        }

        strOut.AppendLine("alert('" + msg + "');");
        strOut.AppendLine("$('.imgRefresh').click();");//重新整理
    }
</script>

<%=strOut.ToString()%>
