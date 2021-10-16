<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"] ?? "商標國內案件明細表";//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
  
    DataTable dtRpt = new DataTable();//明細

    protected string branchname = "";
    protected string kind_no = "";
    protected string ref_no = "";
    protected string kind_date = "";
    protected string sdate = "";
    protected string edate = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "Private";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

        kind_no = ReqVal.TryGet("kind_no");
        ref_no = ReqVal.TryGet("ref_no");
        kind_date = ReqVal.TryGet("kind_date");
        sdate = ReqVal.TryGet("sdate");
        edate = ReqVal.TryGet("edate");

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            this.Page.DataBind();
        }
    }

    protected void PageLayout() {
        branchname = Sys.getCodeName(conn, "sysctrl.dbo.branch_code", "branchname", "where branch='" + Session["seBranch"] + "'");

        SQL = "select a.seq,a.seq1,a.class_count,a.class,a.in_date,a.appl_name,a.cust_area,a.cust_seq,a.apply_no,a.apply_date,a.issue_date,a.issue_no,a.term1,a.term2";
        SQL += ",a.scode,a.rej_no,a.end_date,b.ap_cname1,c.draw_file ";
        SQL += ",(select code_name from cust_code where code_type = 'TCase_Stat' and cust_code = a.now_stat) as now_statnm";
        SQL += ",(select agt_name from agt where agt_no=a.agt_no) as agt_name";
        SQL += ",(select sc_name from sysctrl.dbo.scode where scode = a.scode) as scodenm";
        SQL += ",(SELECT code_name FROM cust_code where code_type='EndCode' and cust_code=a.end_code) as end_codenm";
        SQL += ",''fseq,''fdraw_file,a.scode lscode,''dmt_good";
        SQL += " from dmt a ";
        SQL += " inner join apcust b on a.cust_seq = b.cust_seq ";
        SQL += " inner join ndmt c on a.seq=c.seq and a.seq1=c.seq1 ";
        SQL += " where 1=1 ";
        if (ReqVal.TryGet("seq") != "") {
            SQL += " and a.seq = '" + ReqVal.TryGet("seq") + "'";
        }
        if (ReqVal.TryGet("seq1") != "") {
            SQL += " and a.seq1 = '" + ReqVal.TryGet("seq1") + "'";
        }
        if (ReqVal.TryGet("class") != "") {
            SQL += " and a.class like '%" + ReqVal.TryGet("class") + "%'";
        }
        if (ReqVal.TryGet("mseq") != "") {
            SQL += " and a.mseq = '" + ReqVal.TryGet("mseq") + "'";
        }
        if (ReqVal.TryGet("mseq1") != "") {
            SQL += " and a.mseq1 = '" + ReqVal.TryGet("mseq1") + "'";
        }
        if (ReqVal.TryGet("scode") != "") {
            SQL += " and a.scode = '" + ReqVal.TryGet("scode") + "'";
        }
        if (ReqVal.TryGet("cust_seq") != "") {
            SQL += " and a.cust_seq = '" + ReqVal.TryGet("cust_seq") + "'";
        }
        if (ReqVal.TryGet("ap_cname1") != "") {
            SQL += " and b.ap_cname1 like '%" + ReqVal.TryGet("ap_cname1") + "%'";
        }
        if (ReqVal.TryGet("apcust_no") != "") {
            SQL += " and a.seq in (select distinct seq from dmt_ap where apcust_no like '%" + ReqVal.TryGet("apcust_no") + "%' )";
        }
        if (ReqVal.TryGet("ap_cname") != "") {
            SQL += " and rtrim(cast(a.seq as char))+a.seq1 in (select rtrim(cast(seq as char))+seq1 from dmt_ap where ap_cname like '%" + ReqVal.TryGet("ap_cname") + "%')";
        }
        if (ReqVal.TryGet("s_mark") != "") {
            if (ReqVal.TryGet("s_mark") != "") {
                SQL += " and a.s_mark in ('T','')";
            } else {
                SQL += " and a.s_mark = '" + ReqVal.TryGet("s_mark") + "'";
            }
        }
        if (ReqVal.TryGet("s_mark2") != "") {
            SQL += " and a.s_mark2 = '" + ReqVal.TryGet("s_mark2") + "'";
        }
        if (ReqVal.TryGet("pul") != "") {
            if (ReqVal.TryGet("s_mark") == "0") {
                SQL += " and a.pul=''";
            } else {
                SQL += " and a.pul = '" + ReqVal.TryGet("pul") + "'";
            }
        }
        if (ReqVal.TryGet("appl_name") != "") {
            SQL += " and a.appl_name like '%" + ReqVal.TryGet("appl_name") + "%'";
        }
        if (kind_no != "") {
            SQL += " and a." + kind_no + " = '" + ref_no + "' ";
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
                SQL += "  or a.term2 <= '" + edate + "') ";
            }
        }
        if (ReqVal.TryGet("qryend") == "Y") {
            SQL += "  and a.end_date is null";
        } else if (ReqVal.TryGet("qryend") == "N") {
            SQL += " and a.end_date is not null";
            if (ReqVal.TryGet("end_code") != "") {
                SQL += " and a.end_code = '" + ReqVal.TryGet("end_code") + "'";
            }
        }

        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        } else {
            SQL += " order by a.seq,a.seq1";
        }
        conn.DataTable(SQL, dtRpt);

        for (int i = 0; i < dtRpt.Rows.Count; i++) {
            DataRow dr = dtRpt.Rows[i];

            //案號
            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", dr.SafeRead("cust_area", ""), Sys.GetSession("dept"));
            //圖檔
            if (dr.SafeRead("draw_file", "") != "") {
                dr["fdraw_file"] = "<img src=\"" + Sys.Path2Nbtbrt(dr["draw_file"].ToString()) + "\" width=\"30\" height=\"30\">";
            }
            //營洽
            if (dr.SafeRead("scodenm", "") != "") {
                dr["lscode"] = dr.SafeRead("scodenm", "");
            } else {
                dr["lscode"] = dr.SafeRead("scode", "");
            }
            //商品內容
            string dmt_good = "";
            SQL = "SELECT class,dmt_goodname FROM dmt_good";
            SQL += " WHERE seq=" + dr.SafeRead("seq", "");
            SQL += " AND seq1='" + dr.SafeRead("seq1", "") + "'";
            SQL += " ORDER BY sqlno";
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                while (dr0.Read()) {
                    dmt_good += "<br>&nbsp;" + dr0.SafeRead("class", "") + "_" + dr0.SafeRead("dmt_goodname", "");
                }
            }
            if (dmt_good != "") {
                dr["dmt_good"] = dmt_good.Substring(10);
            }
        }

        dtlRepeater.DataSource = dtRpt;
        dtlRepeater.DataBind();
    }

    protected void dtlRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        int i = e.Item.ItemIndex + 1;

        Panel pagePanel = (Panel)e.Item.FindControl("pagePanel");
        if (i % 4 == 1) {
            pagePanel.Visible = true;
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
<uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body onload="window.focus();">
	<asp:Repeater id="dtlRepeater" runat="server" OnItemDataBound="dtlRepeater_ItemDataBound">
	<ItemTemplate>
        <asp:Panel runat="server" ID="pagePanel" Visible="false">
                <p style='overflow:hidden;<%#((Container.ItemIndex>0 && Container.ItemIndex%4==0)?"page-break-before:always;":"")%>'></p>
            <table border="0" width="100%" cellspacing="1" cellpadding="0" align="center" style="">
	            <tr>
                     <td width="30%"></td>
                    <td style="font-size:20px" colspan="3" align=center><%#branchname%><%#HTProgCap%></td>
		            <td width="30%" align=right><a href="javascript:window.print();void(0);">列印</a>日期：<%#DateTime.Today.ToShortDateString()%></td>
	            </tr>
            </table>
        </asp:Panel>

        <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">	
	        <tr class="sfont9" >
		        <td align="center" nowrap rowspan="6"><font size="2">本所編號<br><%#Eval("fseq")%></font></td>
		        <td width="12%" nowrap align="right"><font size="2">立案日期：</font></td>
		        <td width="12%" align="center"><font size="2">&nbsp;<%#Eval("in_date","{0:d}")%></font></td>
		        <td width="12%" nowrap align="right"><font size="2">申請日期：</font></td>
		        <td width="12%" align="center"><font size="2">&nbsp;<%#Eval("apply_date","{0:d}")%></font></td>
		        <td width="12%" nowrap align="right"><font size="2">申請號：</font></td>
		        <td width="12%" align="center"><font size="2">&nbsp;<%#Eval("apply_no")%></font></td>
		        <td width="12%" nowrap align="right"><font size="2">註冊日期：</font></td>
		        <td width="12%" align="center"><font size="2">&nbsp;<%#Eval("issue_date","{0:d}")%></font></td>
	        </tr>
	        <tr class="sfont9" >
		        <td nowrap align="right"><font size="2">註冊號：</font></td>
		        <td align="center"><font size="2">&nbsp;<%#Eval("issue_no")%></font></td>
		        <td nowrap align="right"><font size="2">核駁號：</font></td>
		        <td align="center"><font size="2">&nbsp;<%#Eval("rej_no")%></font></td>
		        <td nowrap align="right"><font size="2">專用期限：</font></td>
		        <td align="center" colspan="3">
                    <font size="2">&nbsp;<%#Eval("term1","{0:d}")%><%#(Eval("term1").ToString()!=""||Eval("term2").ToString()!="")?"~":""%><%#Eval("term2","{0:d}")%></font>
		        </td>
	        </tr>
	        <tr class="sfont9" >
		        <td nowrap align="right"><font size="2">客戶名稱：</font></td>
		        <td align="left" colspan="3"><font size="2">&nbsp;<%#Eval("cust_area")%><%#Eval("cust_seq")%>-<%#Eval("ap_cname1")%></font></td>
		        <td nowrap align="right"><font size="2">代理人：</font></td>
		        <td align="center"><font size="2">&nbsp;<%#Eval("agt_name")%></font></td>
		        <td nowrap align="right"><font size="2">營　　洽：</font></td>
		        <td align="center"><font size="2">&nbsp;<%#Eval("lscode")%></font></td>
	        </tr>
	        <tr class="sfont9" >
		        <td nowrap align="right"><font size="2">商標名稱：</font></td>
		        <td align="left" colspan="3"><font size="2">&nbsp;<%#Eval("appl_name")%></font></td>		
		        <td nowrap align="right"><font size="2">商標圖樣：</font></td>
		        <td align="center"><font size="2">&nbsp;<%#Eval("fdraw_file")%></td>
		        <td nowrap align="right"><font size="2">案件狀態：</font></td>
		        <td align="center"><font size="2">&nbsp;<%#Eval("now_statnm")%></font></td>
	        </tr>
	        <tr class="sfont9" >
		        <td nowrap align="right"><font size="2">類　　別：</font></td>
		        <td align="left" colspan="3"><font size="2">&nbsp;共<%#Eval("class_count")%>類 <%#Eval("class")%></font></td>
		        <td nowrap align="right"><font size="2">結案日期：</font></td>
		        <td align="center"><font size="2">&nbsp;<%#Eval("end_date")%></font></td>
		        <td nowrap align="right"><font size="2">結案代碼：</font></td>
		        <td align="center"><font size="2">&nbsp;<%#Eval("end_codenm")%></font></td>
	        </tr>
	        <tr class="sfont9" >
		        <td nowrap align="right"><font size="2">商品內容：</font></td>
		        <td align="left" colspan="7"><font size="2">&nbsp;<%#Eval("dmt_good")%></font></td>
	        </tr>
        </table>
        <br>
    </ItemTemplate>
    </asp:Repeater>

    <asp:Label ID="lblEmpty" runat="server" Visible='<%#bool.Parse((dtRpt.Rows.Count==0).ToString())%>'>
        <div align="center"><font color="red" size=2>=== 查無資料===</font></div>
    </asp:Label> 
    <BR>
</body>
</html>
