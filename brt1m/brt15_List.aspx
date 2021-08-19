<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案官方收文營洽確認作業";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string qryscode = "";
    protected string html_qryscode = "";
    
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
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";

        FormName = "備註:<br>\n";
        FormName += "1.「<img src=\"" + Page.ResolveUrl("~/images/todolist01.jpg") + "\" align=\"absmiddle\">」表示本筆官收有掃描文件，但承辦尚未掃描。<br>\n";

        qryscode = Request["qryscode"] ?? "";
        if ((HTProgRight & 64) == 0) qryscode = Sys.GetSession("scode");

        //洽案營洽
        SQL = "select distinct a.job_scode,(select sc_name from sysctrl.dbo.scode where scode=a.job_scode) as sc_name";
        SQL += ",(select sscode from sysctrl.dbo.scode where scode=a.job_scode) as scode1 ";
        SQL += "from todo_dmt a ";
        SQL += "where syscode='" + Session["syscode"] + "' and dowhat='SALES_GR' and job_status='NN' order by scode1 ";
        html_qryscode = Util.Option(conn, SQL, "{job_scode}", "{job_scode}_{sc_name}", true, Sys.GetSession("scode"));
    }

    private void QueryData() {
        SQL="select a.*,c.cappl_name as appl_name";
	    SQL+= ",c.step_date,c.mp_date,c.rs_detail,c.pr_scan,c.pr_scan_date";
	    SQL+= ",(select sc_name from sysctrl.dbo.scode where scode=b.job_scode) as sc_name";
        SQL += ",''fseq,''from_flagnm";
	    SQL+= " from grconf_dmt a ";
	    SQL+= " inner join todo_dmt b on a.grconf_sqlno=b.temp_rs_sqlno ";
	    SQL+= " inner join vstep_dmt c on a.seq=c.seq and a.seq1=c.seq1 and a.step_grade=c.step_grade and a.rs_sqlno=c.rs_sqlno ";
        SQL += " where b.dowhat='SALES_GR' and b.job_status='NN' ";
        if ((Request["qrySeq"] ?? "") != "") {
            SQL += " and a.seq in('" + (Request["qrySeq"] ?? "").Replace(",", "','") + "') ";
        }        
        if ((Request["qrySeq1"] ?? "") != "") {
            SQL += " and a.seq1='" + Request["qrySeq1"] + "'";
        }
        if (qryscode != "") {
            SQL += " and b.job_scode='" + qryscode + "'";
        }
        if ((Request["qryfrom_flag"] ?? "") != "") {
            SQL += " and a.from_flag='" + Request["qryfrom_flag"] + "'";
        }
        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "c.step_date,a.seq,a.seq1"));
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
            
            //來文方式
            if (dr.SafeRead("from_flag", "") == "A") {
                dr["from_flagnm"] = "紙本收文";
            }else if (dr.SafeRead("from_flag", "") == "C") {
                 dr["from_flagnm"] = "電子收文";
            } else if (dr.SafeRead("from_flag", "") == "E") {
                dr["from_flagnm"] = "官發回條";
            } else if (dr.SafeRead("from_flag", "") == "J") {
                dr["from_flagnm"] = "電子公文";
            } else {
                dr["from_flagnm"] = "";
            }
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }
    
    //[作業]
    protected string GetButton(RepeaterItem Container) {
        string rtn = "";
        string pr_scan = Eval("pr_scan").ToString();

        string pr_scan_flag = "N";
        if (pr_scan == "Y") {
            SQL = "select chk_status from dmt_attach where seq=" + Eval("seq") + " and seq1='" + Eval("seq1") + "' and step_grade=" + Eval("step_grade") + " and source='scan' ";
            SQL += " order by attach_no ";
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                if (dr0.HasRows) {
                    while (dr0.Read()) {
                        if (dr0.SafeRead("chk_status", "") == "NN") pr_scan_flag = "Y";
                    }
                } else {
                    pr_scan_flag = "Y";
                }
            }
        }

        //有掃描文件，但承辦尚未掃描
        if (pr_scan_flag == "Y") {
            rtn = "<img src=" + Page.ResolveUrl("~/images/todolist01.jpg") + " style=\"cursor:pointer\" align=\"absmiddle\" border=\"0\">";
        } else {
            rtn = "<a href=\"Brt15_Edit.aspx?prgid="+prgid+"&closewin=N&submittask=U&grconf_sqlno=" + Eval("grconf_sqlno") + "&seq=" + Eval("seq") + "&seq1=" + Eval("seq1") + "&step_grade=" + Eval("step_grade") + "\" target=\"Eblank\">[確認]</a>";
        }

        return rtn;
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
    <table border="0" cellspacing="1" cellpadding="2" width="100%">
        <tr>
	        <td class="text9">
		        ◎洽案營洽 :<select id="qryscode" name="qryscode"><%#html_qryscode%></SELECT>	
	        </td>
	        <td class="text9">
		        ◎本所編號: <input type="text" name="qrySeq" size="30" value="<%=Request["qrySeq"]%>" onblur="fseq_chk(this)">-<input type="text" name="qrySeq1" size="2" value="<%=Request["qrySeq1"]%>">
	        </td>
	        <td class="text9">
		        <input type="button" value="查詢" class="cbutton" onClick="goSearch()" id=qrybutton name=qrybutton>
		        <input type="hidden" name="prgid" id="prgid" value="<%=prgid%>">
	        </td>
        </tr>
        <tr>
	        <td class="text9" colspan="3">
		        ◎來文方式:
		        <label><input type="radio" name="qryfrom_flag" value="A" <%#ReqVal.TryGet("qryfrom_flag")=="A"?"checked":""%>>一般收文(紙本、電話、Email等)</label>
		        <label><input type="radio" name="qryfrom_flag" value="C" <%#ReqVal.TryGet("qryfrom_flag")=="C"?"checked":""%>>電子收文(批次Email通知)</label>
		        <label><input type="radio" name="qryfrom_flag" value="J" <%#ReqVal.TryGet("qryfrom_flag")=="J"?"checked":""%>>電子公文</label>
		        <label><input type="radio" name="qryfrom_flag" value="E" <%#ReqVal.TryGet("qryfrom_flag")=="E"?"checked":""%>>官發回條</label>
		        <label><input type="radio" name="qryfrom_flag" value=""  <%#ReqVal.TryGet("qryfrom_flag")==""?"checked":""%>>全部</label>
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
                    <td class="lightbluetable" nowrap align="center">作業</td>   
                    <td class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.seq,a.seq1">本所編號</u></td>
                    <td class="lightbluetable" width="20%" nowrap align="center"><u class="setOdr" v1="c.cappl_name">案件名稱</u></td>
                    <td class="lightbluetable" nowrap align="center"><u class="setOdr" v1="b.job_scode">營洽</u></td>
                    <td class="lightbluetable" nowrap align="center"><u class="setOdr" v1="c.step_date,a.seq,a.seq1">區所收文日</u></td>
                    <td class="lightbluetable" nowrap align="center"><u class="setOdr" v1="c.mp_date">總管處收發日</u></td>
                    <td class="lightbluetable" width="20%" align="center"><u class="setOdr" v1="c.rs_detail">收文內容</u></td>
                    <td class="lightbluetable" align="center"><u class="setOdr" v1="a.from_flag">來文方式</u></td>
                </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
	<ItemTemplate>
 	    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		    <td class="whitetablebg" align="center">
		        <%#GetButton(Container)%>
		    </td>
		    <td nowrap style="cursor:pointer;color:darkblue" onmouseover="this.style.color='red'" onmouseout="this.style.color='darkblue'" onclick="CapplClick('<%#Eval("seq")%>','<%#Eval("seq1")%>')"><%#Eval("fseq")%></td>
		    <td><%#Eval("appl_name")%></td>
		    <td align="center"><%#Eval("sc_name")%></td>
		    <td nowrap align=center ><%#Eval("step_date","{0:yyyy/M/d}")%></td>
		    <td nowrap align=center ><%#Eval("mp_date","{0:yyyy/M/d}")%></td>
		    <td><%#Eval("rs_detail")%></td>
		    <td align="center"><%#Eval("from_flagnm")%></td>
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
		    <tr class="FormName"><td><div align="left" style="color:blue"><%#FormName%></div></td>
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
        $("#regPage").submit();
    };

    function this_init() {
        if ((main.right & 64) == 0) {
            $("#qryscode").lock();
        }else{
            $("#qryscode").unlock();
        }

        $(".Lock").lock();
        $("input.dateField").datepick();
    }
    //////////////////////
    //案件主檔查詢
    function CapplClick(pseq,pseq1){
        window.showModalDialog(getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + pseq + "&seq1=" + pseq1 + "&submittask=Q", "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }
</script>