<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案管制期限維護作業";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta23";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
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

    protected string submitTask = "";

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
        submitTask = ReqVal.TryGet("submittask").ToUpper();

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");

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
        StrFormBtnTop += "<a href='" + HTProgPrefix + ".aspx?prgid=" + prgid + "'>[查詢畫面]</a>";
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";
    }

    private void QueryData() {
        SQL = "select a.seq,a.seq1,a.in_date,appl_name,a.cust_area,a.cust_seq,apply_no,b.ap_cname1,a.step_grade ";
        SQL += ",(select code_name from cust_code where code_type='tcase_stat' and cust_code=a.now_stat) as code_name,a.scode ";
        SQL += ",''fseq,''a_last_date,''scode1_name ";
        SQL += " from dmt a ";
        SQL += " inner join apcust b on a.cust_seq = b.cust_seq ";
        SQL += " where 1=1 ";

        if (ReqVal.TryGet("seq") != "") {
            SQL += "AND a.seq='" + ReqVal["seq"] + "' ";
        }
        if (ReqVal.TryGet("seq1") != "") {
            SQL += "AND a.seq1 like '" + ReqVal["seq1"] + "%' ";
        }
        if (ReqVal.TryGet("appl_name") != "") {
            SQL += "and a.appl_name like '%" + ReqVal["appl_name"] + "%' ";
        }
        if (ReqVal.TryGet("cust_seq") != "") {
            SQL += "AND a.cust_seq='" + ReqVal["cust_seq"] + "' ";
        }
        if (ReqVal.TryGet("ap_cname1") != "") {
            SQL += " and a.cust_seq in (select distinct cust_seq from apcust where ap_cname1 like '%" + ReqVal["ap_cname1"] + "%' ) ";
        }
        if (ReqVal.TryGet("kind_no") != "") {
            if (ReqVal.TryGet("ref_no") != "") {
                SQL += " and a." + ReqVal["kind_no"] + " like '%" + ReqVal["ref_no"] + "%' ";
            }
        } else {
            if (ReqVal.TryGet("ref_no") != "") {
                SQL += " and (a.Apply_No like '%" + ReqVal["ref_no"] + "%'";
                SQL += " or a.Issue_No like '%" + ReqVal["ref_no"] + "%'";
                SQL += " or a.Rej_No like '%" + ReqVal["ref_no"] + "%')";
            }
        }

        if (ReqVal.TryGet("kind_date") != "") {
            if (ReqVal.TryGet("sdate") != "") {
                if (ReqVal.TryGet("kind_date").ToUpper() == "STEP_DATE") {
                    SQL += " and rtrim(cast(a.seq as char)) + a.seq1 in ( select distinct rtrim(cast(seq as char)) + seq1 from step_dmt where seq=a.seq and seq1=a.seq1 and step_date >='" + ReqVal["sdate"] + "')";
                } else {
                    SQL += " and a." + ReqVal["kind_date"] + " >= '" + ReqVal["sdate"] + "'";
                }
            }
            if (ReqVal.TryGet("edate") != "") {
                if (ReqVal.TryGet("kind_date").ToUpper() == "STEP_DATE") {
                    SQL += " and rtrim(cast(a.seq as char)) + a.seq1 in ( select distinct rtrim(cast(seq as char)) + seq1 from step_dmt where seq=a.seq and seq1=a.seq1 and step_date <='" + ReqVal["edate"] + "')";
                } else {
                    SQL += " and a." + ReqVal["kind_date"] + " <= '" + ReqVal["edate"] + "'";
                }
            }
        } else {
            if (ReqVal.TryGet("sdate") != "") {
                SQL += " and (a.In_Date >= '" + ReqVal["sdate"] + "'";
                SQL += "  or a.Apply_Date >= '" + ReqVal["sdate"] + "'";
                SQL += "  or a.Issue_Date >= '" + ReqVal["sdate"] + "'";
                SQL += "  or a.End_Date >= '" + ReqVal["sdate"] + "'";
                SQL += "  or rtrim(cast(a.seq as char)) + a.seq1 in ( select distinct rtrim(cast(seq as char)) + seq1 from step_dmt where seq=a.seq and seq1=a.seq1 and step_date >='" + ReqVal["sdate"] + "'))";
            }
            if (ReqVal.TryGet("edate") != "") {
                SQL += " and (a.In_Date <= '" + ReqVal["edate"] + "'";
                SQL += "  or a.Apply_Date <= '" + ReqVal["edate"] + "'";
                SQL += "  or a.Issue_Date <= '" + ReqVal["edate"] + "'";
                SQL += "  or a.End_Date <= '" + ReqVal["edate"] + "'";
                SQL += "  or rtrim(cast(a.seq as char)) + a.seq1 in ( select distinct rtrim(cast(seq as char)) + seq1 from step_dmt where seq=a.seq and seq1=a.seq1 and step_date <='" + ReqVal["edate"] + "'))";
            }
        }

        SQL += " group by a.seq,a.seq1,a.in_date,appl_name,a.cust_area,a.cust_seq,apply_no,b.ap_cname1,a.step_grade,a.now_stat,a.scode ";

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "a.seq,a.seq1"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }

        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //案號
            dr["fseq"] = Sys.formatSeq1(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));
            //尚未銷管法定期限
            dr["a_last_date"] = GetLastDate(dr);
            //洽案營洽
            dr["scode1_name"] = GetScode1Name(dr);
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    //尚未銷管法定期限
    protected string GetLastDate(DataRow dr) {
        string last_date = "";

        //取得最近且尚未銷管制的法定管制期限, 若距今兩日內到期者顯示為紅字
        SQL = "select min(ctrl_date) as last_date, ctrl_type, code_name ";
        SQL += " from ctrl_dmt a inner join cust_code b on a.ctrl_type = b.cust_code ";
        SQL += " where branch = '" + Session["seBranch"] + "'";
        SQL += "   and seq = '" + dr.SafeRead("seq","") + "'";
        SQL += "   and seq1 = '" + dr.SafeRead("seq1", "") + "'";
        SQL += "   and b.code_type = 'CT' ";
        SQL += " group by ctrl_type,code_name ";
        SQL += " order by last_date";
        using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
            if (dr0.Read()) {
                string a_last_date = dr0.GetDateTimeString("last_date", "yyyy/M/d");
                string tcolor = Sys.getSetting(Sys.GetSession("dept"), "1", a_last_date);
                last_date = "<font color=" + tcolor + ">" + dr0.SafeRead("code_name", "").Left(2) + "  " + a_last_date + "</font>";
            }
        }
        return last_date;
    }

    //營洽
    protected string GetScode1Name(DataRow dr) {
        string scode1_name = "";

        SQL = "select sc_name from scode where scode='" + dr.SafeRead("scode", "") + "'";
        objResult = cnn.ExecuteScalar(SQL);
        scode1_name = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
        return scode1_name;
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

<form style="margin:0;" id="regPage" name="regPage" method="post">
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
                  <Tr class="lightbluetable">
		            <TD align=center><u class="setOdr" v1="a.seq">本所編號</u></TD>
		            <TD align=center>目前<br>進度</TD>
		            <TD align=center>案件狀態</TD>
		            <TD align=center>立案日期</TD>
		            <TD align=center><u class="setOdr" v1="a.appl_name">案件名稱</u></TD>
		            <TD align=center><u class="setOdr" v1="a.cust_seq">客戶</u></TD>
		            <TD align=center><u class="setOdr" v1="ctrl_date">管制期限</u></TD>
		            <TD align=center><u class="setOdr" v1="a.scode">營洽</u></TD>
		            <TD align=center>作業</TD>
                 </Tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			<ItemTemplate>
 		        <tr align="center" class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
			        <td nowrap style="cursor: pointer;"onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CapplClick('<%#Eval("seq")%>', '<%#Eval("seq1")%>')">
                        <%#Eval("fseq")%>
		            </td>
			        <td nowrap><%#Eval("step_grade")%></td>
			        <td><%#Eval("code_name")%></td>
			        <td nowrap><%#Eval("in_date","{0:yyyy/M/d}")%></td>
			        <td nowrap style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CapplClick('<%#Eval("seq")%>', '<%#Eval("seq1")%>')">
                        <%#Eval("appl_name")%>
			        </td>
			        <td><%#Eval("ap_cname1")%></td>
	                <td align="left"><%#Eval("a_last_date")%></td>
	                <td><%#Eval("scode1_name")%></td>
			        <td>
				        <a href="brta23_Edit.aspx?submitTask=U&prgid=<%=prgid%>&aseq=<%#Eval("seq")%>&aseq1=<%#Eval("seq1")%>&QType=A&FrameBlank=50" target="Eblank">[維護]</a>
			        </td>
		        </tr>
			</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>

        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div style="color:blue">
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

    function this_init() {
        $(".Lock").lock();
        $("input.dateField").datepick();
    }

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////
    function CapplClick(pseq,pseq1){
        window.showModalDialog(getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + pseq + "&seq1=" + pseq1 + "&submittask=Q", "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }
</script>