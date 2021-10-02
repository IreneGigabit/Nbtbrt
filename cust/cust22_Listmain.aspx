<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<!DOCTYPE html>
<script runat="server">
    protected string HTProgCap = "案件主檔查詢清單";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust22";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";

    protected string submitTask = "";
    protected string dept = "";
    protected string qrydept = "";
    protected string seBranch = "";
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        submitTask = Request["submitTask"];
        dept = Sys.GetSession("dept");
        qrydept = ReqVal.TryGet("qrydept");
        seBranch = Sys.GetSession("seBranch");
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        DebugStr = myToken.DebugStr;
        
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout()
    {
        if ((HTProgRight & 2) > 0)
        {
            StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        }
    }

    private void QueryData() {
        
        DataTable dt = new DataTable();
        
        string maintable = "";
        switch (qrydept)
        {
            case"P":
                maintable = "dmp";
                break;
            case "PE":
                maintable = "exp";
                break;
            case "T":
                maintable = "dmt";
                break;
            case "TE":
                maintable = "ext";
                break;
            default:
                break;
        }
        SQL = "SELECT a.*, ";
        if (qrydept == "P" || qrydept == "PE")
        {
            SQL += "(select sc_name from sysctrl.dbo.scode where scode=a.scode1) as scode1nm, ";
        }
        else
        {
            SQL += "appl_name as cappl_name, (select sc_name from sysctrl.dbo.scode where scode=a.scode) as scode1nm, ";
        }

        SQL += "(select ap_cname1+isnull(ap_cname2,'') from apcust where cust_area=a.cust_area and cust_seq=a.cust_seq) as ap_cname ";
        SQL += "FROM " + maintable + " a  WHERE seq <> 0 and seq is not null ";

        if (ReqVal.TryGet("qry_seq") != "")
        {
            SQL += " AND a.seq = " + ReqVal.TryGet("cust_seq");
            if (ReqVal.TryGet("qry_seq1") != "")
            {
                SQL += " AND a.seq1 = '" + ReqVal.TryGet("cust_seq") + "'";
            }
        }
        else
        {
            if (ReqVal.TryGet("qrycappl_name") != "")
            {
                if (qrydept == "P" || qrydept == "PE")
                {
                    SQL += " AND cappl_name LIKE '%" + ReqVal.TryGet("qrycappl_name") + "%'";
                }
                else
                {
                    SQL += " AND appl_name LIKE '%" + ReqVal.TryGet("qrycappl_name") + "%'";
                }
            }

            if (ReqVal.TryGet("qryscode") != "")
            {
                if (qrydept == "P" || qrydept == "PE")
                {
                    SQL += " AND a.scode1 = '" + ReqVal.TryGet("qryscode") + "'";
                }
                else
                {
                    SQL += " AND a.scode = '" + ReqVal.TryGet("qryscode") + "'";
                }
            }
            if (ReqVal.TryGet("qrycust_area") != "")
            {
                SQL += " AND cust_area = '" + ReqVal.TryGet("qrycust_area") + "'";
            }
            if (ReqVal.TryGet("qrycust_seq") != "")
            {
                SQL += " AND cust_seq = '" + ReqVal.TryGet("qrycust_seq") + "'";
            }
            
            //日期範圍
            if (ReqVal.TryGet("qryin_sdate") != "")
            {
                SQL += " AND a.in_date >= '" + ReqVal.TryGet("qryin_sdate") + "'";
            }
            if (ReqVal.TryGet("qryin_edate") != "")
            {
                SQL += " AND a.in_date <= '" + ReqVal.TryGet("qryin_edate") + " 23:59:59'";
            }
        }


        SQL += " order by a.seq,a.seq1";
        Sys.showLog(SQL);
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    protected string Setseq(RepeaterItem Container)
    {
        string s = "";
        if (Util.NullConvert(Eval("end_date")) != "")
        {
            s += "<font color=\"red\">*</font>";
        }
        string country = "";
        string tpe = "";
        if (qrydept == "PE" || qrydept == "TE")
        {
            tpe = "E";
            country = Eval("country").ToString();
        }
        
        if (qrydept == "P" || qrydept == "PE")
        {
            s = Sys.formatSeq(Eval("seq").ToString(), Eval("seq1").ToString(), country, seBranch, qrydept);
        }
        else
        {
            s = Sys.formatSeq(Eval("seq").ToString(), Eval("seq1").ToString(), country, seBranch, qrydept);
        }
        return s;
    }

    protected string SetCountryHeader()
    {
        if (qrydept == "PE" || qrydept == "TE")
        {
            return "<td class=lightbluetable align=center>國別</td>";
        }
        else return "";
    }
    protected string SetCountryItem(RepeaterItem Container)
    {
        if (qrydept == "PE" || qrydept == "TE")
        {
            return "<td nowrap><a href=\"javascript:void(0)\">" + Eval("country").ToString() + "</a></td>";
        }
        else return "";
    }
    
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
    <meta http-equiv="x-ua-compatible" content="IE=10">
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

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
    <%#page.GetHiddenText("GoPage,PerPage,SetOrder")%>
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
<asp:Repeater id="dataRepeater" runat="server">
<HeaderTemplate>
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	    <thead>
            <tr>
		        <td class=lightbluetable align=center>案件編號</td>
                <td class=lightbluetable align=center>營洽</td>
                <td class=lightbluetable align=center>案件名稱</td>
                <%#SetCountryHeader()%>
                <td class=lightbluetable align=center>申請號</td>
                <td class=lightbluetable align=center>專用權期限</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center" style="height:30px" 
                     onclick="" >
			        <td nowrap>
                        <a href="javascript:void(0)" onclick="Getseq('<%#Eval("seq")%>','<%#Eval("seq1")%>','<%#Eval("apply_no")%>')"><%#Setseq(Container)%></a>
			        </td>
			        <td nowrap>
                        <%#Eval("scode1nm")%>
			        </td>
			        <td nowrap>
                        <%#Eval("cappl_name")%>
			        </td>
                     <%#SetCountryItem(Container)%>
			        <td nowrap>
                        <%#Eval("apply_no")%>
			        </td>
                     <td nowrap>
                        <%#Util.parseDBDate(Eval("term1").ToString(), "yyyy/M/d")%>～<%#Util.parseDBDate(Eval("term2").ToString(),"yyyy/M/d")%>
			        </td>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
    <BR>
    
</FooterTemplate>
</asp:Repeater>

    <%--<%#DebugStr%>--%>
</form>

</body>
</html>

<script type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

    });


    //換頁查詢
    function goSearch() {
        $("#regPage").submit();
    };

    function Getseq(seq, seq1, apply_no) {
        window.opener.reg.main_seq.value = seq;
        window.opener.reg.main_seq1.value = seq1;
        window.opener.reg.apply_no.value = apply_no;
        window.close();
    }

</script>