<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "雙邊代理查詢客戶清單";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust46";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
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

    protected string[] branch = { "N", "C", "S", "K" };
    protected string tmpTableName = "cust46";
    
    protected string ap_cname = "";
    protected string ap_ename = "";
    protected string ap_crep = "";
    protected string ap_erep = "";
    protected string id_no = "";
    protected string ap_addr = "";
    protected string FromQuery = "";

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

        ap_cname = ReqVal.TryGet("ap_cname");
        ap_crep = ReqVal.TryGet("ap_crep");
        ap_erep = ReqVal.TryGet("ap_erep");
        id_no  = ReqVal.TryGet("id_no");
        ap_addr = ReqVal.TryGet("ap_addr");
        FromQuery = ReqVal.TryGet("FromQuery");
        
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
        if (FromQuery == "1") {//若從條件頁面進入(cust46.aspx),才需要重新InsertTable
            //先刪除舊資料
            SQL = "delete from " + tmpTableName + " where scode ='" + Session["scode"] + "'";
            conn.ExecuteNonQuery(SQL);

            //抓四所資料
            foreach (string b in branch) {
                using (DBHelper connbr = new DBHelper(Conn.brp(b)).Debug(Request["chkTest"] == "TEST")) {
                    DataTable dtBr = new DataTable();
                    try {
                        SQL = "select * from vcust_apcust where 1<>1 ";
                        if (ap_cname != "") {
                            SQL += " or (isnull(ap_cname1,'')+ isnull(ap_cname2,'')) like '%" + ap_cname + "%'";
                        }
                        if (ap_ename != "") {
                            SQL += " or (isnull(ap_ename1,'')+ isnull(ap_ename2,'')) like '%" + ap_ename + "%'";
                        }
                        if (ap_crep != "") {
                            SQL += " or ap_crep like '%" + ap_crep + "%'";
                        }
                        if (ap_erep != "") {
                            SQL += " or ap_erep like '%" + ap_erep + "%'";
                        }
                        if (id_no != "") {
                            SQL += " or id_no = '" + id_no + "'";
                        }
                        connbr.DataTable(SQL, dtBr);
                    }
                    catch {
                        Response.Write("<font color=blue>無法連線(branch=" + b + ")</font><BR>");
                    }
               
                    InsertTempTable(b, dtBr);
                }
            }
        }

        SQL = "select *,''custtypename,''thref ";
        SQL += " from " + tmpTableName + " ";
        SQL += " where scode ='" + Session["scode"] + "'";
        Sys.showLog(SQL);

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "custtype,cust_area,cust_seq,apcust_no"));
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

            if (dr.SafeRead("custtype", "") == "1") {
                dr["custtypename"] = "客戶";
                //**todo
                if ((HTProgRight & 128) != 0) {
                    dr["thref"] = Page.ResolveUrl("~/cust/cust11_mod.aspx") + "?modify=Q&attmodify=Q&gs_dept=" + Session["dept"] + "&cust_area=" + dr["cust_area"] + "&cust_seq=" + dr["cust_seq"] + "&apsqlno=" + dr["apsqlno"] + "&hRight=3&prgid=cust46";
                }
            } else {
                dr["custtypename"] = "申請人";
                //**todo
                if ((HTProgRight & 128) != 0) {
                    dr["thref"] = Page.ResolveUrl("~/cust/cust13_mod.aspx") + "?apsqlno=" + dr["apsqlno"] + "&modify=Q&hRight=3&prgid=cust46&cust_area=" + dr["cust_area"];
                }
            }
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }

    private void InsertTempTable(string branch, DataTable rs) {
        for (int i = 0; i < rs.Rows.Count; i++) {
            DataRow dr = rs.Rows[i];

            string pscode_name = "";
            if (dr.SafeRead("pscode", "").ToLower() == "np") {
                pscode_name = "專利客戶";
            } else {
                SQL = "select sc_name from scode where scode='" + dr.SafeRead("pscode", "") + "'";
                object objResult = cnn.ExecuteScalar(SQL);
                pscode_name = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            }

            string tscode_name = "";
            if (dr.SafeRead("pscode", "").ToLower() == "nt") {
                tscode_name = "商標客戶";
            } else {
                SQL = "select sc_name from scode where scode='" + dr.SafeRead("tscode", "") + "'";
                object objResult = cnn.ExecuteScalar(SQL);
                tscode_name = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
            }

            string cust_area = "";
            if (dr.SafeRead("custtype", "") == "1") {//客戶
                cust_area = dr.SafeRead("cust_area", "");
            } else {
                cust_area = branch;
            }

            SQL = "insert into " + tmpTableName + " values(";
            SQL += "'" + Session["scode"] + "'," + Util.dbchar(dr.SafeRead("custtype", "")) + "," + Util.dbchar(cust_area) + "," + Util.dbzero(dr.SafeRead("cust_seq", ""));
            SQL += "," + Util.dbchar(dr.SafeRead("id_no", "")) + "," + Util.dbzero(dr.SafeRead("apsqlno", "")) + "," + Util.dbchar(dr.SafeRead("apcust_no", ""));
            SQL += "," + Util.dbchar(dr.SafeRead("ap_cname1", "")) + "," + Util.dbchar(dr.SafeRead("ap_cname2", ""));
            SQL += "," + Util.dbchar(dr.SafeRead("ap_ename1", "")) + "," + Util.dbchar(dr.SafeRead("ap_ename2", ""));
            SQL += "," + Util.dbchar(dr.SafeRead("ap_crep", "")) + "," + Util.dbchar(dr.SafeRead("ap_erep", ""));
            SQL += "," + Util.dbchar(dr.SafeRead("pscode", "")) + "," + Util.dbchar(dr.SafeRead("tscode", ""));
            SQL += "," + Util.dbchar(pscode_name) + "," + Util.dbchar(tscode_name);
            SQL += ")";
            conn.ExecuteNonQuery(SQL);
        }
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
    <%#page.GetHiddenText("GoPage,PerPage,SetOrder,FromQuery")%>
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
                  <Tr class="lightbluetable">
                    <td align="center" width=6% nowrap>類別</td>
		            <td align="center" width=12%><u class="setOdr" v1="custtype,cust_area,cust_seq,apcust_no">客戶/<br>申請人編號</u></td>
		            <td align="center" width=30% nowrap>客戶<br>中文名稱</td>
		            <td align="center" width=30% nowrap>客戶<br>英文名稱</td>
		            <td align="center" width=10% nowrap><u class="setOdr" v1="id_no">統一編號</td>
		            <td align="center" width=10% nowrap>代表人</td>
		            <td align="center" width="8%" nowrap>專利營洽</td>
		            <td align="center" width="8%" nowrap>商標營洽</td>
                 </Tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			<ItemTemplate>
 		        <tr align="center" class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
                    <td><%#Eval("custtypename")%></td>
		            <td>
                        <%#(Eval("thref").ToString()!=""?"<a href=\""+Eval("thref")+"\" target=\"Eblank\">":"")%>
                        <%#Eval("cust_area")%>-<%#(Eval("custtype").ToString()=="1"?Eval("cust_seq"):Eval("apcust_no"))%>
                        <%#(Eval("thref").ToString()!=""?"</a>":"")%>
		            </td>
		            <td>
                        <%#(Eval("thref").ToString()!=""?"<a href=\""+Eval("thref")+"\" target=\"Eblank\">":"")%>
			            <%#Eval("ap_cname1")%><%#Eval("ap_cname2")%>
                        <%#(Eval("thref").ToString()!=""?"</a>":"")%>
		            </td>
		            <td><%#Eval("ap_ename1")%><%#Eval("ap_ename2")%></td>
		            <td><%#Eval("id_no")%></td>
		            <td><%#Eval("ap_crep")%></td>
		            <td><%#Eval("pscode_name")%></td>
		            <td><%#Eval("tscode_name")%></td>
		        </tr>
			</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>

        <table style="display:<%#page.totRow==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div style="color:blue">
	                說明: <br>
	                1.「客戶/申請人編號」欄位為<font color="red">區所別-客戶編號(或申請人編號)</font><br>
	                2. 區所別包括: N→台北、C→台中、S→台南、K→高雄
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
        $(".Lock").lock();
        $("input.dateField").datepick();
    }

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////
</script>