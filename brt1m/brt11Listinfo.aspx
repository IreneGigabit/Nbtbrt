<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "洽案登錄作業";// HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt11";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";

    protected string submitTask = "";
    protected string code_type = Sys.getRsType();
    
    DataSet ds = new DataSet();
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
    }
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");

        ReqVal = Util.GetRequestParam(Context,Request["chkTest"] == "TEST");
        submitTask = Request["submitTask"] ?? "";

        Token myToken = new Token(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        if (HTProgRight >= 0) {
            QueryData();
            //PageLayout();

            this.DataBind();
        }
    }

    private void PageLayout() {
        //StrFormBtnTop += "<a href=\"" + HTProgPrefix + ".aspx?prgid=" + prgid + "\" >[查詢]</a>";
        StrFormBtnTop += "<a href=\"javascript:window.history.back()\" >[查詢]</a>";
    }

    private void QueryData() {
        string tfx_cust_area = "", tfx_cust_seq = "";

        if (ReqVal.TryGet("tfx_seq") != "") {
            SQL = "select cust_area,cust_seq from dmt ";
            SQL += "where seq='" + ReqVal.TryGet("tfx_seq") + "' ";
            SQL += "and seq1='" + ReqVal.TryGet("tfx_seq1") + "' ";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    tfx_cust_area = dr.SafeRead("cust_area", "");
                    tfx_cust_seq = dr.SafeRead("cust_seq", "");
                }
            }
        } else {
            tfx_cust_area = ReqVal.TryGet("tfx_cust_area");
            tfx_cust_seq = ReqVal.TryGet("tfx_cust_seq");
        }

        SQL = "SELECT a.id_no,a.dmt_date,b.* ";
        SQL += "FROM Custz as a ";
        SQL += "inner join apcust as b on a.cust_area=b.cust_area And a.cust_seq=b.cust_seq ";
        SQL += "where 1=1 ";
        if (tfx_cust_seq != "") {
            SQL += " AND a.cust_seq=" + tfx_cust_seq;
        }
        if (ReqVal.TryGet("pfx_Cust_name") != "") {
            SQL += " AND b.ap_cname1 like '" + Request["pfx_Cust_name"] + "%'";
        }

        //案性分類
        SQL += ";SELECT Cust_code,Code_name,form_name";
        SQL += " FROM Cust_code";
        SQL += " WHERE Code_type = '" + code_type + "' AND form_name is not null ";
        if (ReqVal.TryGet("kind", "") == "old") {//舊案不可創設申請
            SQL += "AND form_name<>'E11' ";
        }
        SQL += "order by cust_code";
        conn.DataSet(SQL, ds);

        for (int i = 0; i < ds.Tables[0].Rows.Count; i++) {
        }

        dataRepeater.DataSource = ds.Tables[0];
        dataRepeater.DataBind();
    }

    protected void dataRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if ((e.Item.ItemType == ListItemType.Item) | (e.Item.ItemType == ListItemType.AlternatingItem)) {
            Repeater rsRepeater = (Repeater)e.Item.FindControl("rsRepeater");
            if ((rsRepeater != null)) {
                rsRepeater.DataSource = ds.Tables[1];
                rsRepeater.DataBind();
            }
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
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

<form style="margin:0;" id="reg" name="reg" method="post">
    <input type=hidden id=prgid name=prgid value="<%#prgid%>">
    <input type=hidden id=cust_area name=cust_area>
    <input type=hidden id=cust_seq name=cust_seq>
    <input type=hidden id=Ar_Form name=Ar_Form>
    <input type=hidden id=prt_code name=prt_code>
    <input type=hidden id=submitTask name=submitTask>
    <input type=hidden id=seq name=seq value="<%#Request["tfx_seq"]%>">
    <input type=hidden id=seq1 name=seq1 value="<%#Request["tfx_seq1"]%>">
    <input type=hidden id=country name=country value="<%#Request["country"]%>">
    <input type=hidden id=type name=type value="<%#Request["type"]%>">
    <input type=hidden id=kind name=kind value="<%#Request["kind"]%>">
    <input type=hidden id=uploadtype name=uploadtype value="case"><!--文件上傳畫面用，表接洽記錄-->
	<input type=hidden name=code_type value="<%=code_type%>">
</form>

<div align="center" id="noData" style="display:<%#ds.Tables[0].Rows.Count==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

<asp:Repeater id="dataRepeater" runat="server" OnItemDataBound="dataRepeater_ItemDataBound">
<HeaderTemplate>
    <table style="display:<%#ds.Tables[0].Rows.Count==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	    <thead>
            <Tr>
			    <td align="center" class="lightbluetable">客戶編號</td>
			    <td align="center" class="lightbluetable">客戶名稱</td>
			    <td align="center" class="lightbluetable">代表人</td>	
			    <td align="center" class="lightbluetable">證照號碼</td>
			    <td align="center" class="lightbluetable">建檔日期</td>
			    <td align="center" class="lightbluetable">內商最後異動日</td>
			    <td align="center" class="lightbluetable">洽案登錄</td>
			    <td align="center" class="lightbluetable">作業</td>	
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		            <td align="center">
                        <a href="../cust/cust11_mod.asp?modify=Q&gs_dept=t&cust_area=<%#Eval("cust_area")%>&cust_seq=<%#Eval("cust_seq")%>&apsqlno=<%#Eval("id_no")%>&hRight=2&att_sql=1">
                            <%#Eval("cust_area")%>-<%#Eval("cust_seq")%>
                        </a>
                    </td>
		            <td align="center"><%#Eval("ap_cname1")%></td>
		            <td align="center"><%#Eval("ap_crep")%></td>
		            <td align="center"><%#Eval("id_no")%></td>
		            <td align="center"><%#Util.parseDBDate(Eval("in_date").ToString(),"yyyy/M/d")%></td>
		            <td align="center"><%#Util.parseDBDate(Eval("dmt_date").ToString(),"yyyy/M/d")%></td>
		            <td align="center">
                        <asp:Repeater id="rsRepeater" runat="server">
                            <HeaderTemplate>
			                    <SELECT name=toadd<%#(Container.ItemIndex+1)%> id=toadd<%#(Container.ItemIndex+1)%> onchange="Formadd('<%#DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "cust_area")%>','<%#DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "cust_seq")%>',this )" >
			                    <option value="" style="color:blue">請選擇案性</option>
                            </HeaderTemplate>
			                <ItemTemplate>
                                <option value="<%#Eval("Cust_code").ToString().Trim()%>" v1="<%#Eval("form_name").ToString().Trim()%>"><%#Eval("Code_name")%></option>
			                </ItemTemplate>
                        </asp:Repeater>
		            </td>
		            <td align="center">
                        [<a href="Brt11_1.asp?cust_area=<%#Eval("cust_area")%>&cust_seq=<%#Eval("cust_seq")%>&prgid=brt11&Type=Brt"><font color="blue">舊案檢索</font></a>]
                        [<a href="Brt11ListA.aspx?cust_area=<%#Eval("cust_area")%>&cust_seq=<%#Eval("cust_seq")%>"><font color="blue">維護/交辦</font></a>]
		            </td>
				</tr>
			</ItemTemplate>
<FooterTemplate>
	    </tbody>
    </table>
    <br />
</FooterTemplate>
</asp:Repeater>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }
    });

    //關閉視窗
    $(".imgCls").click(function (e) {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        } else {
            window.close();
        }
    })

    function Formadd(x, y, obj) {
        var oThis = $(obj);
        if (oThis.val() == "") return false;
        reg.cust_area.value = x;
        reg.cust_seq.value = y;
        reg.submitTask.value = "Add";
        
        reg.Ar_Form.value = oThis.val();
        reg.prt_code.value = $('option:selected', oThis).attr('v1');
        reg.action = "Brt11Add" + reg.prt_code.value + ".aspx";
        reg.submit();
    }
</script>
