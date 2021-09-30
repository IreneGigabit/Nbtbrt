<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<script runat="server">
    protected string HTProgCap = "國內案洽案記錄刪除作業";// HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgPrefix = "brt17";//程式檔名前綴
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a href=" + HTProgPrefix + ".aspx?prgid=" + prgid + ">[回查詢]</a>";
    }

    private void QueryData() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "SELECT a.In_scode,a.In_no,a.case_no,a.Seq,a.Seq1,a.Service, a.Fees,a.oth_money, b.appl_name, b.class ";
            SQL += ",a.Arcase, a.Ar_mark, isnull(a.discount,0) as discount, a.case_num,a.stat_code, a.cust_area, a.cust_seq ";
            SQL += ",c.service AS p_service, c.fees AS p_fees, a.Discount_chk, d.cust_name,a.case_num,a.arcase_type,a.arcase_class ";
            SQL += ",(SELECT rs_detail FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' AND no_code='N' and rs_type=a.arcase_type) AS case_name ";
            SQL += ",(SELECT rs_class FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' AND no_code='N' and rs_type=a.arcase_type) AS Ar_form ";
            SQL += ",(SELECT prt_code FROM code_br WHERE rs_code = a.arcase AND dept = 'T' AND cr = 'Y' AND no_code='N' and rs_type=a.arcase_type) AS prt_code ";
            SQL += ",''link_remark,''fseq,''urlasp,''case_num_txt,''todoicon,''sum_txt,''dis_txt,''nx_link ";
            SQL += ",0 T_Service,0 T_Fees,0 P_Service,0 P_Fees ";
            SQL += "FROM case_dmt a ";
            SQL += " INNER JOIN dmt_temp b ON a.in_scode = b.in_scode AND a.in_no = b.in_no and b.case_sqlno=0 ";
            SQL += "INNER JOIN VIEW_Cust d ON a.cust_seq = d.cust_seq AND a.cust_area = d.cust_area ";
            SQL += "LEFT OUTER JOIN case_fee c ON a.arcase = c.rs_code AND (c.dept = 'T') AND (c.country = 'T') AND (GETDATE() BETWEEN c.beg_date AND c.end_date) ";
            SQL += "WHERE a.cust_area = '" + Request["tfx_cust_area"] + "' ";
            SQL += "AND a.stat_code LIKE 'N%' ";

            if (ReqVal.TryGet("stat_code") != "") {
                SQL += "AND a.stat_code ='" + Request["stat_code"] + "' ";
            }
            if (ReqVal.TryGet("tfx_cust_seq") != "") {
                SQL += "AND a.cust_seq ='" + Request["tfx_cust_seq"] + "' ";
            }
            if (ReqVal.TryGet("sfx_in_date") != "") {
                SQL += "AND a.in_date> ='" + Request["sfx_in_date"] + "' ";
            }
            if (ReqVal.TryGet("Efx_in_date") != "") {
                SQL += "AND a.in_date< ='" + Request["Efx_in_date"] + "' ";
            }
            if (ReqVal.TryGet("tscode") != "") {
                SQL += "AND a.in_scode ='" + Request["tscode"] + "' ";
            }
            if (ReqVal.TryGet("pfx_Arcase") != "") {
                SQL += "AND a.Arcase ='" + Request["pfx_Arcase"] + "' ";
            }
            SQL += "AND (a.mark='N' or a.mark is null)";
            ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder"));
            if (ReqVal.TryGet("qryOrder") != "") {
                SQL += " order by " + ReqVal.TryGet("qryOrder");
            } else {
                SQL += " order by a.in_no";
            }
            conn.DataTable(SQL, dt);

            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
            page = new Paging(nowPage, PerPageSize, SQL);
            page.GetPagedTable(dt);

            //分頁完再處理其他資料才不會虛耗資源
            for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
                DataRow dr = page.pagedTable.Rows[i];

                SQL = "Select remark from cust_code where cust_code='__' and code_type='" + dr["arcase_type"] + "'";
                object objResult = conn.ExecuteScalar(SQL);
                string link_remark = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                dr["link_remark"] = link_remark;//案性版本連結

                int T_Service = 0;//交辦服務費
                int T_Fees = 0;//交辦規費
                int P_Service = 0;//服務費收費標準
                int P_Fees = 0;//規費收費標準
                SQL = "select a.item_service as case_service,a.item_fees as case_fees, service*item_count as fee_service,fees*item_count AS fee_Fees ";
                SQL += "from caseitem_dmt a ";
                SQL += "inner join case_fee b on a.item_arcase=b.rs_code ";
                SQL += "where a.in_no='" + dr.SafeRead("in_no", "") + "' ";
                SQL += "and b.dept='T' and b.country='T' and getdate() between b.beg_date and b.end_date";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        T_Service += dr0.SafeRead("case_service", 0);
                        P_Service += dr0.SafeRead("Fee_service", 0);
                        T_Fees += dr0.SafeRead("Case_Fees", 0);
                        P_Fees += dr0.SafeRead("Fee_Fees", 0);
                    }
                }
                SQL = "select a.oth_arcase,a.oth_money,b.service ";
                SQL += "from case_dmt a ";
                SQL += "inner join case_fee b on  a.oth_arcase=b.rs_code ";
                SQL += "where in_no='" + dr.SafeRead("in_no", "") + "' ";
                SQL += "and b.dept='T' and b.country='T' and getdate() between b.beg_date and b.end_date";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        T_Service += dr0.SafeRead("oth_money", 0);
                        P_Service += dr0.SafeRead("service", 0);
                    }
                }
                dr["T_Service"] = T_Service;
                dr["T_Fees"] = T_Fees;
                dr["P_Service"] = P_Service;
                dr["P_Fees"] = P_Fees;

                dr["cust_name"] = dr.SafeRead("cust_name", "").Left(20);
                dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", "", "");
                dr["case_num_txt"] = dr.SafeRead("stat_code", "") == "NX" ? "(" + dr.SafeRead("stat_code", "") + ")" : "";
                dr["todoicon"] = GetTodoIcon(dr);
                dr["sum_txt"] = GetSum(dr);
                dr["dis_txt"] = GetDiscount(dr);

                string new_form = "";//連結的aspx
                SQL = "SELECT c.remark ";
                SQL += "FROM Cust_code c ";
                SQL += "inner join code_br b on b.rs_type=c.Code_type and b.rs_class=c.Cust_code ";
                //SQL += "WHERE c.form_name is not null ";
                SQL += "WHERE 1=1 ";
                SQL += "and b.rs_type='" + dr["arcase_type"] + "' ";
                SQL += "and b.rs_code='" + dr["arcase"] + "' ";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        new_form += dr0.SafeRead("remark", "");
                    }
                }
                string ar_form = dr.SafeRead("ar_form", "");//rs_class
                string prt_name = dr.SafeRead("reportp", "");//列印程式
                bool FlagPrint = (prt_name != "" ? true : false);
                if (dr.SafeRead("prt_code", "") == "D9Z" || dr.SafeRead("prt_code", "") == "ZZ") {
                    //2014/4/29因有部份類別在洽案登錄為大類別，如C救濟案，但編修時值皆抓rs_class=C2，則會造成若要改C1下的案性，就會選不到，增加下列判斷重抓洽案登錄大類別
                    SQL = "select cust_code from cust_code where code_type='" + dr["arcase_type"] + "' and form_name is not null and cust_code='" + ar_form + "'";
                    using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                        if (!dr0.HasRows) {
                            dr0.Close();
                            SQL = "select cust_code from cust_code where code_type='" + dr["arcase_type"] + "' and form_name is not null and cust_code like '" + ar_form.Left(1) + "%' ";
                            using (SqlDataReader dr1 = conn.ExecuteReader(SQL)) {
                                if (dr1.Read()) {
                                    dr["ar_form"] = dr1.SafeRead("cust_code", "");
                                }
                            }
                        }
                    }
                } else {
                    if (dr.SafeRead("prt_code", "") == "D3"
                        || dr.SafeRead("prt_code", "") == ""
                        || dr.SafeRead("arcase", "") == "DE2"
                        || dr.SafeRead("arcase", "") == "AD7"
                        )
                        FlagPrint = false;
                }
                string urlasp = "";//連結的url
                //urlasp = Page.ResolveUrl("~/brt1m" + link_remark + "/Brt11Edit" + new_form + ".aspx?prgid=" + prgid);
                //urlasp += "&in_scode=" + dr["in_scode"];
                //urlasp += "&in_no=" + dr["in_no"];
                //urlasp += "&add_arcase=" + dr["arcase"];
                //urlasp += "&cust_area=" + dr["cust_area"];
                //urlasp += "&cust_seq=" + dr["cust_seq"];
                //urlasp += "&ar_form=" + dr["ar_form"];
                //urlasp += "&new_form=" + new_form;
                //urlasp += "&code_type=" + dr["arcase_type"];
                //urlasp += "&homelist=" + Request["homelist"];
                //urlasp += "&uploadtype=case";

                if (Sys.GetSession("scode") == dr.SafeRead("in_scode", "") || (HTProgRight & 128) != 0) {
                    //urlasp += "&submittask=Edit";
                    urlasp = Sys.getCase11Aspx(prgid, dr.SafeRead("in_no", ""), dr.SafeRead("in_scode", ""), "Edit");
                } else {
                    //urlasp += "&submittask=Show";
                    urlasp = Sys.getCase11Aspx(prgid, dr.SafeRead("in_no", ""), dr.SafeRead("in_scode", ""), "Show");
                }
                
                dr["urlasp"] = urlasp;
                dr["nx_link"] = GetNXLink(dr, new_form);
            }

            dataRepeater.DataSource = page.pagedTable;
            dataRepeater.DataBind();
        }
    }

    protected string GetTodoIcon(DataRow row) {
        string back_flag = row.SafeRead("back_flag","").Trim().ToUpper();
        string end_flag = row.SafeRead("end_flag","").Trim().ToUpper();
        if (back_flag == "Y" || end_flag == "Y")
            return "<img src='" + Page.ResolveUrl("~/images/todolist01.jpg") + "' align='absmiddle' border='0'>";

        return "";
    }

    protected string GetSum(DataRow row) {
        int Service = Convert.ToInt32(row.SafeRead("Service","0"));
        int fees = Convert.ToInt32(row.SafeRead("fees","0"));
        int oth_money = Convert.ToInt32(row.SafeRead("oth_money","0"));
            return (Service+fees+oth_money).ToString();
    }

    protected string GetDiscount(DataRow row) {
        decimal discount = Convert.ToDecimal(row.SafeRead("discount","0"));
        string discount_chk = row.SafeRead("Discount_chk","");
        string discount_remark = row.SafeRead("discount_remark","");
        string rtn = "";
        if (discount > 0) {
            rtn += discount + "%";
        }

        if (discount_chk == "Y" || discount_remark != "") {
            rtn += "(*)";
        }

        return rtn;
    }

    protected string GetNXLink(DataRow row, string new_form) {
        string stat_code = row.SafeRead("stat_code", "");
        if (stat_code == "NX")
            return "<a href='" + Page.ResolveUrl("~/Brt4m/Brt13_ListA.aspx") +
                    "?prgid=" + prgid +
                    "&in_scode=" + row.SafeRead("in_scode", "") +
                    "&in_no=" + row.SafeRead("in_no", "") +
                    "&ar_form=" + row.SafeRead("ar_form", "") +
                    "&homelist=" + Request["homelist"] +
                    "&new_form=" + new_form +
                    "&qs_dept=T' target='Eblank'><font color=red>說明</font></a>";
        return "";
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%#prgid%> <%#HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form id="regPage" name="regPage" method="post">
    <%#page.GetHiddenText("GoPage,PerPage,SetOrder,chktest")%>
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
			    </font><%#DebugStr%>
		    </td>
	    </tr>
    </TABLE>
    </div>
</form>

<div align="center" id="noData" style="display:<%#page.totRow==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
<asp:Repeater id="dataRepeater" runat="server">
<HeaderTemplate>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	<thead>
        <Tr>
	        <td align="center" class="lightbluetable" width="5%">接洽序號</td>
	        <td align="center" class="lightbluetable" width="10%">客戶名稱</td>
	        <td align="center" class="lightbluetable" width="20%">案件名稱</td>	
	        <td align="center" class="lightbluetable">類別</td>
	        <td align="center" class="lightbluetable" width="15%">案性</td>
	        <td align="center" class="lightbluetable">服務費</td>
	        <td align="center" class="lightbluetable">規費</td>
	        <td align="center" class="lightbluetable">轉帳<br>費用</td>
	        <td align="center" class="lightbluetable">合計</td>
	        <td align="center" class="lightbluetable">折扣</td>
	        <td align="center" class="lightbluetable">註記</td>
	        <td align="center" class="lightbluetable">作業</td>
        </tr>
	</thead>
	<tbody>
</HeaderTemplate>
<ItemTemplate>
 		<tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
	        <td class="whitetablebg" align="center">
                <a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("in_scode")%>-<%#Eval("in_no")%><%#Eval("case_num_txt")%></A>
                <input type=hidden id="inscode_<%#(Container.ItemIndex+1)%>" name="inscode_<%#(Container.ItemIndex+1)%>" value="<%#Eval("in_scode")%>">
                <input type=hidden id="inno_<%#(Container.ItemIndex+1)%>" name="inno_<%#(Container.ItemIndex+1)%>" value="<%#Eval("in_no")%>">
                <input type=hidden id="case_no_<%#(Container.ItemIndex+1)%>" name="case_no_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_no")%>">
                <input type=hidden id="seq_<%#(Container.ItemIndex+1)%>" name="seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq")%>">
                <input type=hidden id="seq1_<%#(Container.ItemIndex+1)%>" name="seq1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq1")%>">
                <input type=hidden id="cust_area_<%#(Container.ItemIndex+1)%>" name="cust_area_<%#(Container.ItemIndex+1)%>" value="<%#Eval("cust_area")%>">
                <input type=hidden id="cust_seq_<%#(Container.ItemIndex+1)%>" name="cust_seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("cust_seq")%>">
                <input type=hidden id="arcase_<%#(Container.ItemIndex+1)%>" name="arcase_<%#(Container.ItemIndex+1)%>" value="<%#Eval("arcase")%>">
                <input type=hidden id="stat_code_<%#(Container.ItemIndex+1)%>" name="stat_code_<%#(Container.ItemIndex+1)%>" value="<%#Eval("stat_code")%>">
                <input type=hidden id="appl_name_<%#(Container.ItemIndex+1)%>" name="appl_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("appl_name")%>">
                <input type=hidden id="cust_name_<%#(Container.ItemIndex+1)%>" name="cust_name_<%#(Container.ItemIndex+1)%>" value="<%#Eval("cust_name")%>">
                <input type=hidden id="case_num_<%#(Container.ItemIndex+1)%>" name="case_num_<%#(Container.ItemIndex+1)%>" value="<%#Eval("case_num")%>">
            </td>
	        <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("cust_name")%></A></td> 
	        <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("appl_name")%></A></td>
	        <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("class")%></A></td>
	        <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("case_name")%></A></td>
	        <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("service")%></A></td>
	        <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("fees")%></A></td>
	        <td class="whitetablebg" align="center"><a href="<%#Eval("urlasp")%>" target="Eblank"><%#Eval("oth_money")%></A></td>
	        <td class="whitetablebg" align="center"><%#Eval("sum_txt")%></td>
	        <td class="whitetablebg" align="center"><%#Eval("dis_txt")%></td>
            <td class="whitetablebg" align="center" title="主管簽退說明" ><span style="color:red"><%#Eval("nx_link")%></span></td>
	        <td class="whitetablebg" align="center"><a href="javascript:void(0)" onclick="actDel('<%#(Container.ItemIndex+1)%>')">[刪除]</a></td>
	    </tr>
</ItemTemplate>
<FooterTemplate>
	</tbody>
    </table>
</FooterTemplate>
</asp:Repeater>

    <%#DebugStr%>
</form>

<div id="dialog"></div>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        $(".Lock").lock();
        $("input.dateField").datepick();
    });

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };

    //[刪除]
    function actDel(row) {
        var pin_scode = $("#inscode_" + row).val();
        var pin_no = $("#inno_" + row).val();
        var pcase_no = $("#case_no_" + row).val();
        var pcase_stat = $("#stat_code_" + row).val();
        var pappl_name = $("#appl_name_" + row).val();
        var pcust_name = "";//$("#cust_name_" + row).val();
        var parcase = $("#arcase_" + row).val();
        var pseq = $("#seq_" + row).val();
        var pseq1 = $("#seq1_" + row).val();
        var pcust_areq = $("#cust_area_" + row).val();
        var pcust_seq = $("#cust_seq_" + row).val();
        var chktest = ($("#chkTest:checked").val() || "");

        var msg = "接洽序號:" + pin_scode + "-" + pin_no + "\n\n是否確定刪除?";
        if (confirm(msg)) {
            //var url = getRootPath() + "/brt1m/brt17_save.aspx?submitTask=D" +
            //        "&in_scode=" + pin_scode + "&in_no=" + pin_no + "&case_no=" + pcase_no + "&case_stat=" + pcase_stat +
            //        "&cappl_name=" + pappl_name + "&ap_cname1=" + pcust_name + "&arcase=" + parcase + "&seq=" + pseq +
            //        "&seq1=" + pseq1 + "&cust_area=" + pcust_areq + "&cust_seq=" + pcust_seq;
            var url = getRootPath() + "/brt1m/brt17_save.aspx?submitTask=D";
            var data = {
                "in_scode": pin_scode, "in_no": pin_no, "case_no": pcase_no, "case_stat": pcase_stat
                , "cappl_name": pappl_name, "ap_cname1": pcust_name, "arcase": parcase, "seq": pseq
                , "seq1": pseq1, "cust_area": pcust_areq, "cust_seq": pcust_seq
            }
            ajaxScriptByGet("刪除接洽記錄", url, data);
        }
    }
</script>