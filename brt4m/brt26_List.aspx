<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "案性收費標準";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "Brt26";//HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";

    protected int curr= 0;
    protected string submitTask = "";
    protected string tblname = "";
    protected string strdept = "T";
    protected string strbranch = "";
    protected string strcode = "";
    protected string strcountry = "";
    protected string ar_flag = "";
    DataTable dt = new DataTable();

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
        strbranch = ReqVal.TryGet("branch");//國內/出口
        strcode = ReqVal.TryGet("code");//案性
        strcountry = ReqVal.TryGet("coun");//國別
        ar_flag = ReqVal.TryGet("ar_flag");//含稅/未稅

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
        if (strcountry == "T") {
            tblname = "tbfee_v";
        } else {
            tblname = "tebfee_v";
        }

        SQL = "select *,''coun_c,''tend_date,0 oth_ser,0 oth_fee,0 total,0 tax ";
        SQL += "from " + tblname;
        SQL += " where dept = '" + strdept + "' ";
        SQL += "and country in('" + strcountry.Replace(",", "','") + "') ";
        SQL += "and class in('" + strcode.Replace(",", "','") + "') ";
        SQL += "and end_date >= '" + DateTime.Today.ToShortDateString() + "' ";
        SQL += "order by country,class";
        //Sys.showLog(SQL);
        conn.DataTable(SQL, dt);

        for (int i = 0; i < dt.Rows.Count; i++) {
            DataRow dr = dt.Rows[i];

            if (dr.GetDateTimeString("end_date", "yyyy/MM/dd") != "2099/12/31") {
                dr["tend_date"] = "~" + dr.GetDateTimeString("end_date", "yyyy/MM/dd");
            }

            SQL = "select coun_c from country  where coun_code = '" + dr["country"] + "' and markb<>'X'";
            objResult = cnn.ExecuteScalar(SQL);
            dr["coun_c"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

            if (dr.SafeRead("country", "") == "T") {
                if (dr.SafeRead("oth_code", "") != "") {
                    SQL = "select service,fees from case_fee ";
                    SQL += "where country = 'T' and dept = '" + dr["dept"] + "' ";
                    SQL += " and rs_code = '" + dr["oth_code"] + "' ";
                    SQL += " and beg_date='" + dr.GetDateTimeString("beg_date", "yyyy/MM/dd") + "' ";
                    SQL += "and end_date='" + dr.GetDateTimeString("end_date", "yyyy/MM/dd") + "'";
                    using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                        if (dr0.Read()) {
                            dr["oth_ser"] = dr0["service"];
                            dr["oth_fee"] = dr0["fees"];
                        }
                    }
                }

                dr["total"] = dr.SafeRead("service", 0) + dr.SafeRead("fees", 0) + dr.SafeRead("others", 0) + dr.SafeRead("oth_ser", 0) + dr.SafeRead("oth_fee", 0);
            } else {
                dr["total"] = dr.SafeRead("ar_service", 0) + dr.SafeRead("ar_fees", 0) + dr.SafeRead("ar_others", 0);//含稅合計
                dr["tax"] = dr.SafeRead("total", 0) - dr.SafeRead("service", 0) - dr.SafeRead("fees", 0) - dr.SafeRead("others", 0);//稅
                if (ar_flag != "N") {//含稅
                    dr["service"] = dr["ar_service"];
                    dr["fees"] = dr["ar_fees"];
                    dr["others"] = dr["ar_others"];
                }
            }
        }

        //dt.ShowTable();
        dataRepeater.DataSource = dt;
        dataRepeater.DataBind();
    }

    //[作業]
    protected string GetLink(RepeaterItem Container) {
        string link = "";

        if (Eval("remark").ToString().Trim() != "") {
            link = "<a href=\"brt26_Edit.aspx?prgid=" + prgid + "&sqlno=" + Eval("sqlno") + "&dept=" + Eval("dept") + "&arcase=" + Eval("arcase") + "&coun_c=" + Eval("coun_c") + "&country=" + Eval("country") + "\" target=\"Eblank\">[說明]</a>";
        }

        return link;
    }

    //附屬案性
    protected void rpt_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if (e.Item.ItemIndex == 0) {//因pagebind&repeater bind會讓repaeter觸發綁定2次.所以第一筆時總計要重算
            curr = dt.Rows.Count;
        }

        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            string country = DataBinder.Eval(e.Item.DataItem, "country").ToString();
            string tclass = DataBinder.Eval(e.Item.DataItem, "class").ToString();
            string arcase = DataBinder.Eval(e.Item.DataItem, "arcase").ToString();

            Repeater childRpt = (Repeater)e.Item.FindControl("childRepeater");
            DataTable dtChild = new DataTable();

            if ((childRpt != null)) {
                if (country == "T" && tclass != "Z1") {
                    SQL = "select *,''coun_c,''tend_date,0 oth_ser,0 oth_fee,0 total,0 tax ";
                    SQL += "from " + tblname;
                    SQL += " where dept = '" + strdept + "' and country = 'T' and class='Z1' ";
                    SQL += " and arcase like '" + arcase + "%' ";
                    SQL += "and end_date >= '" + DateTime.Today.ToShortDateString() + "' ";
                    SQL += "order by arcase";
                    conn.DataTable(SQL, dtChild);

                    for (int i = 0; i < dtChild.Rows.Count; i++) {
                        curr += 1;
                        DataRow dr = dtChild.Rows[i];

                        if (dr.GetDateTimeString("end_date", "yyyy/MM/dd") != "2099/12/31") {
                            dr["tend_date"] = "~" + dr.GetDateTimeString("end_date", "yyyy/MM/dd");
                        }

                        SQL = "select coun_c from country  where coun_code = '" + dr["country"] + "' and markb<>'X'";
                        objResult = cnn.ExecuteScalar(SQL);
                        dr["coun_c"] = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();

                        if (dr.SafeRead("oth_code", "") != "") {
                            SQL = "select service,fees from case_fee ";
                            SQL += "where country = 'T' and dept = '" + dr["dept"] + "' ";
                            SQL += " and rs_code = '" + dr["oth_code"] + "' ";
                            SQL += " and beg_date='" + dr.GetDateTimeString("beg_date", "yyyy/MM/dd") + "' ";
                            SQL += "and end_date='" + dr.GetDateTimeString("end_date", "yyyy/MM/dd") + "'";
                            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                                if (dr0.Read()) {
                                    dr["oth_ser"] = dr0["service"];
                                    dr["oth_fee"] = dr0["fees"];
                                }
                            }
                        }

                        dr["total"] = dr.SafeRead("service", 0) + dr.SafeRead("fees", 0) + dr.SafeRead("others", 0) + dr.SafeRead("oth_ser", 0) + dr.SafeRead("oth_fee", 0);
                    }
                }

                childRpt.DataSource = dtChild;
                childRpt.DataBind();
            }
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
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <input type="hidden" id="dept" name="dept" value="<%=strdept%>">
    <input type="hidden" id="coun" name="coun" value="<%=strcountry%>">
    <input type="hidden" id="code" name="code" value="<%=strcode%>">
    <input type="hidden" id="branch" name="branch" value=<%=strbranch%>>
	<%if (strbranch=="E"){%>※聖智收費&nbsp;&nbsp;
	顯示方式：
	<label><input type="radio" name="ar_flag" value="" <%#(ar_flag!="N"?"checked":"")%>>含稅</label>
	<label><input type="radio" name="ar_flag" value="N" <%#(ar_flag=="N"?"checked":"")%>>未稅</label>
	<%}%>
</form>

<div align="center" id="noData" style="display:<%#dt.Rows.Count==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

<form style="margin:0;" id="reg" name="reg" method="post">
    <asp:Repeater id="dataRepeater" runat="server" OnItemDataBound="rpt_ItemDataBound">
    <HeaderTemplate>
        <table style="display:<%#dt.Rows.Count==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
	        <thead>
                <Tr class="lightbluetable">
		            <td align="center" width="10%"><strong>國家</strong></td>
		            <td align="center" width="8%"> <strong>案性</strong></td>
		            <td align="center" width="16%"><strong>案性名稱</strong></td>
		            <%if (strbranch == "E"){%>
			            <td align="center" width="10%"><strong>服務費<br><%#(ar_flag=="N"?"(未稅)":"(含稅)")%></strong></td>
			            <td align="center" width="10%"><strong>規費<br><%#(ar_flag=="N"?"(未稅)":"(含稅)")%></strong></td>
			            <td align="center" width="8%"><strong>公簽證費<br><%#(ar_flag=="N"?"(未稅)":"(含稅)")%></strong></td>
				            <%if (ar_flag=="N"){%><!--未稅-->
					            <td align="center" width="8%" ><strong>未稅合計</strong></td>
					            <td align="center" width="8%"><strong>營業稅</strong></td>
				            <%}%>
			            <td align="center" width="10%"><strong>合計<br>(含稅)</strong></td>
		            <%}else{%>
			            <td align="center" width="10%"><strong>服務費</strong></td>
			            <td align="center" width="10%"><strong>規費</strong></td>
			            <td align="center" width="10%"><strong>合計</strong></td>
		            <%}%>
		            <td align="center" width="10%"><strong>本所啟用日</strong></td>
		            <%if (strbranch != "E"){%>
			            <td align="center" width="10%"><strong>智財局實施日</strong></td>
		            <%}%>
		            <td align="center" width="8%"><strong>作業</strong></td>
                </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
			<ItemTemplate>
              <tr class=whitetablebg> 
		        <td align="center" width="10%"><%#Eval("coun_c")%></td>  
		        <td align="center" width="8%"><%#Eval("arcase")%></td>
		        <td><%#Eval("case_name")%></td>
		        <td align="center"><%#Eval("service")%><!--服務費-->
			        <%#(Convert.ToInt32(Eval("oth_ser"))>0?"<br>(" +Eval("oth_code")+":"+Eval("oth_ser")+")":"")%>
		        </td>
		        <td align="center"><%#Eval("fees")%><!--規費-->
			        <%#(Convert.ToInt32(Eval("oth_fee"))>0?"<br>(" +Eval("oth_code")+":"+Eval("oth_fee")+")":"")%>
		        </td>
		        <%if (strbranch == "E"){%>
			        <td align="center"><%#Eval("others")%></td><!--公簽證費-->
			        <%if(ar_flag=="N"){%>
				        <td align="center"><%#Convert.ToInt32(Eval("service"))+Convert.ToInt32(Eval("fees"))+Convert.ToInt32(Eval("others"))%></td><!--未稅合計-->
				        <td align="center"><%#Eval("tax")%></td><!--營業稅-->
			        <%}%>
		        <%}%>
		        <td bgcolor="#80FF80" align="center"><%#Eval("total","NT${0:N0}")%></td><!--含稅合計-->
		        <td align="center"><%#Eval("beg_date","{0:yyyy/M/d}")%><%#Eval("tend_date")%></td>
		        <%if (strbranch != "E" ){%>
			        <td align="center"><%#Eval("IPO_date","{0:yyyy/M/d}")%></td>
		        <%}%>
		        <td align="center">
                    <%#GetLink(Container)%>
		        </td>
	          </tr>

                <asp:Repeater id="childRepeater" runat="server">
			    <ItemTemplate>
                  <tr class=whitetablebg> 
		            <td align="center" width="10%"><%#Eval("coun_c")%></td>  
		            <td align="center" width="8%"><%#Eval("arcase")%></td>
		            <td><%#Eval("case_name")%></td>
		            <td align="center"><%#Eval("service")%>
			            <%#(Convert.ToInt32(Eval("oth_ser"))>0?"<br>(" +Eval("oth_code")+":"+Eval("oth_ser")+")":"")%>
		            </td>
		            <td align="center"><%#Eval("fees")%>
			            <%#(Convert.ToInt32(Eval("oth_fee"))>0?"<br>(" +Eval("oth_code")+":"+Eval("oth_fee")+")":"")%>
		            </td>
		            <td bgcolor="#80FF80" align="center"><%#Eval("total","NT${0:N0}")%></td>
		            <td align="center"><%#Eval("beg_date","{0:yyyy/M/d}")%><%#Eval("tend_date")%></td>
		            <%if (strbranch != "E" ){%>
			            <td align="center"><%#Eval("IPO_date","{0:yyyy/M/d}")%></td>
		            <%}%>
		            <td align="center">
                        <%#GetLink(Container)%>
		            </td>
	              </tr>
			    </ItemTemplate>
                </asp:Repeater>
			</ItemTemplate>
    <FooterTemplate>
	        </tbody>
        </table>
	    <BR>

        <table style="display:<%#dt.Rows.Count==0?"none":""%>" border="0" width="100%" cellspacing="0" cellpadding="0">
		    <tr class="FormName"><td>
			    <div style="color:blue">
                    [註]:<br>◎智財局實施日為智慧局公佈生效日期<br>◎本所啟用日為本所收費標準之有效期限
			    </div>
                
                <center>
                    <br><strong>資料共&nbsp;<font color=red><%=curr%></font>&nbsp;筆</strong>
                    <br><input type="button" name="submit1" id="submit1" class="cbutton" value="產生word檔" onclick="formWord()">
                </center>
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
        regPage.target = "_self";
        regPage.action = "<%=HTProgPrefix%>_List.aspx";
        $("#regPage").submit();
    };
    //////////////////////
    $("input[name='ar_flag']").click(function (e) {
        goSearch();//重新整理
    });

    function formWord() {
        regPage.target = "ActFrame";
        regPage.action = "<%=HTProgPrefix%>_word.aspx";
        regPage.submit();
    }
</script>