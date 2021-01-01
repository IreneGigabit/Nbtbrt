<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;

    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string apcode = "";
    protected string qs_dept = "";
    
    protected string grpid = "";//簽核者的Grpid
    protected string grplevel = "";//簽核者的Grplevel

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        qs_dept=(Request["qs_dept"]??"").ToLower();

        Sys.getScodeGrpid(Sys.GetSession("seBranch"), Request["job_scode"], ref grpid, ref grplevel);
        
        if (qs_dept =="t"){
           HTProgCode="brt31";
           apcode = "'Si04W02','brt31'";//改版後有新舊代碼
        }else{
            HTProgCode="ext34";
            apcode = "'Si04W06','ext34'";//改版後有新舊代碼
        }
        
        TokenN myToken = new TokenN(HTProgCode);
        myToken.CheckMe(false);
        if (HTProgRight >= 0) {
           QueryData();
            this.DataBind();
        }
    }
    private void QueryData() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            if (qs_dept == "t") {
                SQL = "SELECT b.in_no,B.In_scode,B.arcase_type,B.arcase_class, A.in_date as step_date, A.ctrl_date, C.appl_name, B.Service, B.Fees,B.oth_money, B.ar_mark, B.arcase";
                SQL += ",ISNULL(B.Discount, 0) AS discount, B.Service + B.Fees + B.oth_money AS allcost,b.seq,b.seq1,b.remark,''country,b.contract_flag,b.contract_remark,b.discount_remark ";
                SQL += ",A.job_scode, A.sqlno, A.in_no, D.Rs_detail as CArcase,D.rs_class as ar_form,D.prt_code,e.sc_name, B.Cust_area, B.Cust_seq,B.case_no,''upload_chk,b.back_flag,b.end_flag,b.case_date";
                SQL += ",(select code_name from cust_code where code_type='ar_mark' and cust_code=b.ar_mark) as ar_marknm ";
                SQL += ",''link_remark,''fseq,''urlasp,0 T_Service,0 T_Fees,0 P_Service,0 P_Fees ";
                SQL += ",'1'ctrl_rowspan,''tar_mark,''dis_flag,''disT_flag,''tran_remark1 ";
                SQL += "FROM Case_dmt B ";
                SQL += "INNER JOIN dmt_temp C ON B.In_no = C.in_no AND B.In_scode = C.in_scode And c.case_sqlno=0 ";
                SQL += "INNER JOIN todo_dmt A ON B.In_no = A.in_no and b.in_scode=A.case_in_scode ";
                SQL += "INNER JOIN code_br D ON B.Arcase = D.Rs_code and d.cr='Y' and dept='T' and rs_type=b.arcase_type ";
                SQL += "INNER JOIN sysctrl.dbo.scode e ON B.In_scode = e.scode ";
                SQL += "WHERE (A.job_status = 'NN') and syscode= '" + Session["syscode"] + "' and apcode in(" + apcode + ") ";
            } else {
                SQL = "SELECT b.in_no,B.In_scode,B.arcase_type,B.arcase_class,B.mark1, A.in_date as step_date, A.ctrl_date, C.appl_name, B.tot_Service as service, B.tot_Fees as fees, isnull(B.oth_money,0) as oth_money,B.ar_mark, B.arcase";
                SQL += ",ISNULL(B.Discount, 0) AS discount, B.tot_Service + B.tot_Fees + B.tot_tax + isnull(B.oth_money,0) AS allcost,b.seq,b.seq1,c.country,b.contract_flag,b.contract_remark,b.discount_remark ";
                SQL += ",A.job_scode, A.sqlno, A.in_no, D.Rs_detail as CArcase,D.rs_class as ar_form,D.prt_code,e.sc_name, B.Cust_area, B.Cust_seq,B.case_no,B.upload_chk,b.back_flag,b.end_flag,b.case_date,c.remark1 ";
                SQL += ",(select code_name from cust_code where code_type='ar_mark' and cust_code=b.ar_mark) as ar_marknm ";
                SQL += ",''link_remark,''fseq,''urlasp,0 T_Service,0 T_Fees,0 P_Service,0 P_Fees ";
                SQL += ",'1'ctrl_rowspan,''tar_mark,''dis_flag,''disT_flag,''tran_remark1 ";
                SQL += "FROM Case_ext B ";
                SQL += "INNER JOIN ext_temp C ON B.In_no = C.in_no AND B.In_scode = C.in_scode and c.case_sqlno=0 ";
                SQL += "INNER JOIN todo_ext A ON B.In_no = A.in_no and b.in_scode=A.case_in_scode ";
                SQL += "INNER JOIN code_ext D ON B.Arcase = D.Rs_code and d.cr_flag='Y' and d.rs_type=b.arcase_type ";
                SQL += "INNER JOIN sysctrl.dbo.scode e ON B.In_scode = e.scode ";
                SQL += "WHERE (A.job_status = 'NN') and syscode='" + Session["syscode"] + "' and apcode in(" + apcode + ") ";
            }

            if (ReqVal.TryGet("job_scode") != "") {
                SQL += " AND (A.job_scode = '" + Request["job_scode"] + "')";
            } else {
                SQL += " AND (A.job_scode = '" + Session["scode"] + "')";
            }

            if (ReqVal.TryGet("scode") != "*" && ReqVal.TryGet("scode") != "") {
                SQL += " and A.in_scode = '" + Request["scode"] + "'";
            }
            if (ReqVal.TryGet("dtype") == "1") {
                SQL += " and A.ctrl_date between '" + Request["Sdate"] + "' and '" + Request["Edate"] + "'";
            }
            if (ReqVal.TryGet("dtype") == "2") {
                SQL += " and A.in_date between '" + Request["Sdate"] + " 00:00:00' and '" + Request["Edate"] + " 23:59:59'";
            }

            ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", ""));
            if (ReqVal.TryGet("qryOrder") != "") {
                SQL += " order by " + ReqVal.TryGet("qryOrder");
            } else {
                SQL += " order by step_date";
            }
            conn.DataTable(SQL, dt);

            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
            page = new Paging(nowPage, PerPageSize, string.Join(";", conn.exeSQL.ToArray()));
            page.GetPagedTable(dt);

            //分頁完再處理其他資料才不會虛耗資源
            for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
                page.pagedTable.Rows[i]["dis_flag"] = "N";//折扣需簽至區所主管
                page.pagedTable.Rows[i]["disT_flag"] = "N";//折扣需簽至商標經理
                if (qs_dept == "t") {
                    SQL = "Select remark from cust_code where cust_code='__' and code_type='" + page.pagedTable.Rows[i]["arcase_type"] + "'";
                    object objResult = conn.ExecuteScalar(SQL);
                    string link_remark = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                    page.pagedTable.Rows[i]["link_remark"] = link_remark;//案性版本連結

                    page.pagedTable.Rows[i]["upload_chk"] = "N";//專案請核單upload_chk=Y需經商標經理簽准
                    page.pagedTable.Rows[i]["tar_mark"] = "N";//扣收入註記

                    if (page.pagedTable.Rows[i].SafeRead("ar_mark","") == "D") {
                        string remark1 = page.pagedTable.Rows[i]["remark"].ToString();
                    }
                    int T_Service = 0;//交辦服務費
                    int T_Fees = 0;//交辦規費
                    int P_Service = 0;//服務費收費標準
                    int P_Fees = 0;//規費收費標準
                    SQL = "select a.item_service as case_service,a.item_fees as case_fees, service*item_count as fee_service,fees*item_count AS fee_Fees ";
                    SQL += "from caseitem_dmt a ";
                    SQL += "inner join case_fee b on a.item_arcase=b.rs_code ";
                    SQL += "where a.in_no='" + page.pagedTable.Rows[i].SafeRead("in_no", "") + "' ";
                    SQL += "and b.dept='T' and b.country='T' and getdate() between b.beg_date and b.end_date";
                    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                        if (dr.Read()) {
                            T_Service += dr.SafeRead("case_service", 0);
                            P_Service += dr.SafeRead("Fee_service", 0);
                            T_Fees += dr.SafeRead("Case_Fees", 0);
                            P_Fees += dr.SafeRead("Fee_Fees", 0);
                        }
                    }
                    SQL = "select a.oth_arcase,a.oth_money,b.service ";
                    SQL += "from case_dmt a ";
                    SQL += "inner join case_fee b on  a.oth_arcase=b.rs_code ";
                    SQL += "where in_no='" + page.pagedTable.Rows[i].SafeRead("in_no", "") + "' ";
                    SQL += "and b.dept='T' and b.country='T' and getdate() between b.beg_date and b.end_date";
                    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                        if (dr.Read()) {
                            T_Service += dr.SafeRead("oth_money", 0);
                            P_Service += dr.SafeRead("service", 0);
                        }
                    }
                    page.pagedTable.Rows[i]["T_Service"] = T_Service;
                    page.pagedTable.Rows[i]["T_Fees"] = T_Fees;
                    page.pagedTable.Rows[i]["P_Service"] = P_Service;
                    page.pagedTable.Rows[i]["P_Fees"] = P_Fees;

                    if (Convert.ToDecimal(page.pagedTable.Rows[i]["discount"]) > 20) {
                        page.pagedTable.Rows[i]["dis_flag"] = "Y";
                        if (Convert.ToDecimal(page.pagedTable.Rows[i]["discount"]) > 30 && Convert.ToDecimal(page.pagedTable.Rows[i]["P_Service"]) > 5000) {
                            page.pagedTable.Rows[i]["disT_flag"] = "Y";
                        }
                    }
                } else {

                }

                if (page.pagedTable.Rows[i].SafeRead("contract_flag", "") == "") {
                    page.pagedTable.Rows[i]["contract_flag"] = "N";//契約書後補註記
                }
            }

            dataRepeater.DataSource = page.pagedTable;
            dataRepeater.DataBind();
        }
    }

    protected string GetLink(DataRow row) {
        string url = Page.ResolveUrl("~/Brt5m/Brt15showFP.aspx") + "?cust_area=" + row.SafeRead("cust_area", "") + "&seq=" + row.SafeRead("seq", "") + "&seq1=" + row.SafeRead("seq1", "");
        if (ReqVal.TryGet("submittask") == "Q") {
            return url + "&submittask=Q";
        } else {
            return url + "&submittask=U";
        }
    }
</script>

<div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

<asp:Repeater id="dataRepeater" runat="server">
<HeaderTemplate>
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
                    <input type="hidden" name="SetOrder" id="SetOrder" value="<%#ReqVal.TryGet("qryOrder", "")%>" />
			    </font>
		    </td>
	    </tr>
    </TABLE>
    <BR>

    <input type=hidden id="GrpID" name="GrpID" value="<%=grpid%>">
    <input type=hidden id="grplevel" name="grplevel" value="<%=grplevel%>">
    <input type=hidden id="upload_flag" name="upload_flag" value="N"><!--專案請核單upload_chk=Y需經商標經理簽准-->
    <input type=hidden id="armark_flag" name="armark_flag" value="N"><!--扣收入ar_mark=D需經會計檢核-->
    <input type=hidden id="armarkT_flag" name="armarkT_flag" value="N"><!--扣收入ar_mark=D且金額>=5000需經商標經理簽准-->
    <input type=hidden id="contract_flag" name="contract_flag" value="N"><!--契約書後補contract_flag=Y需經區所主管簽准-->
    <input type=hidden id="dis_flag" name="dis_flag" value="N"><!--折扣簽核dis_flag=Y低於8折或低於7折且服務費<=5000需經區所主管簽准-->
    <input type=hidden id="disT_flag" name="disT_flag" value="N"><!--折扣簽核disT_flag=Y低於7折或國內案低於7折且服務費>5000需經商標經理簽准-->

    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="90%" align="center" id="dataList">
	    <thead>
            <Tr>
                <td align="center" class="lightbluetable" onclick="checkall()" style="cursor:pointer">全選</td>
	            <td align="center" class="lightbluetable">接洽序號</td>
	            <td align="center" class="lightbluetable">交辦單號</td>
	            <td align="center" class="lightbluetable">交辦日期</td>
	            <td align="center" class="lightbluetable">案件編號</td>
	            <td align="center" class="lightbluetable qs_deptE">國別</td>
	            <td align="center" class="lightbluetable">案件名稱</td>
	            <td align="center" class="lightbluetable">案性</td>
	            <td align="center" class="lightbluetable">服務費</td>
	            <td align="center" class="lightbluetable">規費</td>
	            <td align="center" class="lightbluetable">轉帳<br>費用</td>
	            <td align="center" class="lightbluetable">合計</td>
	            <td align="center" class="lightbluetable">折扣</td>
	            <td align="center" class="lightbluetable">請款<br>註記</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		            <td align="center" rowspan=<%#Eval("ctrl_rowspan")%>>
                        <input type=checkbox id="CT" name="C_<%#(Container.ItemIndex+1)%>" value="Y" onclick="Chkupload('<%#Eval("upload_chk")%>','<%#Eval("tar_mark")%>','<%#(Container.ItemIndex+1)%>','<%#Eval("fees")%>','<%#Eval("contract_flag")%>')">
                		<input type=text id="code_<%#(Container.ItemIndex+1)%>" name="code_<%#(Container.ItemIndex+1)%>" value="<%#Eval("sqlno")%>">
		                <input type=text id="In_no_<%#(Container.ItemIndex+1)%>" name="In_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("In_no")%>">
		                <input type=text id="In_scode_<%#(Container.ItemIndex+1)%>" name="In_scode_<%#(Container.ItemIndex+1)%>" value="<%#Eval("In_scode")%>">
		                <input type=text id="Cust_area_<%#(Container.ItemIndex+1)%>" name="Cust_area_<%#(Container.ItemIndex+1)%>" value="<%#Eval("Cust_area")%>">
		                <input type=text id="Cust_seq_<%#(Container.ItemIndex+1)%>" name="Cust_seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("Cust_seq")%>">
		                <input type=text id="case_no_<%#(Container.ItemIndex+1)%>" name="case_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_no")%>">
		                <input type=text id="appl_name_<%#(Container.ItemIndex+1)%>" name="appl_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("appl_name")%>">
		                <input type=text id="case_arcase_<%#(Container.ItemIndex+1)%>" name="case_arcase_<%#(Container.ItemIndex+1)%>" value="<%#Eval("arcase")%>">
		                <input type=text id="case_name_<%#(Container.ItemIndex+1)%>" name="case_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("carcase")%>">
		                <input type=text id="upload_chk_<%#(Container.ItemIndex+1)%>" name="upload_chk_<%#(Container.ItemIndex+1)%>" value="<%#Eval("upload_chk")%>"><!--請核單上傳-->
		                <input type=text id="ar_mark_<%#(Container.ItemIndex+1)%>" name="ar_mark_<%#(Container.ItemIndex+1)%>" value="<%#Eval("tar_mark")%>"><!--扣收入註記-->
		                <input type=text id="seq_<%#(Container.ItemIndex+1)%>" name="seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq")%>">
		                <input type=text id="seq1_<%#(Container.ItemIndex+1)%>" name="seq1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq1")%>">
		                <input type=text id="country_<%#(Container.ItemIndex+1)%>" name="country_<%#(Container.ItemIndex+1)%>" value="<%#Eval("country")%>">
		                <input type=text id="fees_<%#(Container.ItemIndex+1)%>" name="fees_<%#(Container.ItemIndex+1)%>" value="<%#Eval("fees")%>"><!--規費-->
		                <input type=text id="contract_flag_<%#(Container.ItemIndex+1)%>" name="contract_flag_<%#(Container.ItemIndex+1)%>" value="<%#Eval("contract_flag")%>"><!--契約書後補註記-->
		                <input type=text id="dis_flag_<%#(Container.ItemIndex+1)%>" name="dis_flag_<%#(Container.ItemIndex+1)%>" value="<%#Eval("dis_flag")%>">
		                <input type=text id="disT_flag_<%#(Container.ItemIndex+1)%>" name="disT_flag_<%#(Container.ItemIndex+1)%>" value="<%#Eval("disT_flag")%>">
		            </td>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
	<BR>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		<tr class="FormName"><td>
			<div align="left">
			</div>
		</td>
        </tr>
	</table>
	<br>
</FooterTemplate>
</asp:Repeater>
