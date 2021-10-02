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
    protected string HTProgCap = "";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "cust12";//程式檔名前綴
    protected string HTProgCode = "Cust12";//功能權限代碼
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
    protected string QueryName = "";
    protected string TableName = "";
    protected string Bindid = "";
    
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
        TableName = Request["tablename"];
        if (TableName == "apcust")
        { HTProgCap = "申請人資料清單"; QueryName = "申請人"; Bindid = "apcust_no"; }
        else
        { HTProgCap = "客戶資料清單"; QueryName = "客戶"; Bindid = "cust_seq"; }

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
        //foreach (var item in ReqVal)
        //{
        //    Response.Write("[Key = " + item.Key + ", Value = " + item.Value + "], ");
        //}
        SQL = "SELECT * FROM apcust WHERE 1=1";
        if (TableName != "apcust") { SQL += " and cust_seq is not null and cust_seq <> 0 "; }
        
        if (ReqVal.TryGet("cust_seq") != "")
        {
            SQL += " and cust_seq = '" + ReqVal.TryGet("cust_seq") + "'";
        }
        else
        {
            if (ReqVal.TryGet("apcust_no") != "")
            {
                SQL += " and apcust_no = '" + ReqVal.TryGet("apcust_no") + "'";
            }
            else
            {
                if (ReqVal.TryGet("ap_cname") != "")
                {
                    SQL += " and (ap_cname1 LIKE '%" + ReqVal.TryGet("ap_cname") + "%' OR ap_cname2 LIKE '%" + ReqVal.TryGet("ap_cname") + "%')";
                }
                if (ReqVal.TryGet("ap_ename") != "")
                {
                    SQL += " and (ap_ename1 LIKE '%" + ReqVal.TryGet("ap_ename") + "%' OR ap_ename2 LIKE '%" + ReqVal.TryGet("ap_ename") + "%')";
                }
            }
        }

        SQL += " order by cust_seq desc";
        //Sys.showLog(SQL);
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
    <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="80%" align="center" id="dataList">
	    <thead>
            <tr>
		        <td class=lightbluetable align=center><%=QueryName%>編號</td>
		        <td class=lightbluetable align=center><%=QueryName%>名稱</td>
		        <td class=lightbluetable align=center>地址</td>
		        <td class=lightbluetable align=center>電話</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center" style="height:30px" onclick="GetData('<%=TableName%>' , '<%#Eval(Bindid)%>')" >
			        <td nowrap>
                        <a href="javascript:void(0)"><%#Eval(Bindid)%></a>
			        </td>
			        <td nowrap>
                        <a href="javascript:void(0)"><%#Eval("ap_cname1")%><%#Eval("ap_cname2")%></a>
			        </td>
			        <td nowrap>
                        <a href="javascript:void(0)"><%#Eval("ap_zip")%><%#Eval("ap_addr1")%><%#Eval("ap_addr2")%></a>
			        </td>
			        <td nowrap>
                        <a href="javascript:void(0)"><%#Eval("apatt_tel0")%><%#Eval("apatt_tel")%><%#Eval("apatt_tel1")%></a>
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

    function GetData(tablename, id) {
        if (tablename == "apcust")
        {
            Get_Apcust(id);
        }
        else
        {
            Get_Csut_seq(id);
        }
    }

    
    function Get_Csut_seq(cust_seq) {
        window.opener.reg.cust_seq.value = cust_seq;
        window.opener.reg.btn_getcust_seqName.onclick();
        window.close();
    }

    function Get_Apcust(apcust_no) {
        var SQLStr = "select * from apcust where apcust_no = '" + apcust_no + "'";
        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx",
            type: "get",
            async: false,
            cache: false,
            data: { sql: SQLStr },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {
                    var Item = JSONdata[0];
                    window.opener.reg.same_ap.checked = true;
                    window.opener.reg.same_ap.onclick();
                    window.opener.reg.apcust_no.value = Item["apcust_no"];
                    window.opener.reg.ant_id.value = Item["apcust_no"];
                    window.opener.reg.ant_country.value = Item["ap_country"];
                    if (Item.ap_country == "T") {
                        window.opener.reg.apclass.value = "B";
                    }

                    window.opener.reg.ant_cname1.value = Item["ap_cname1"];
                    window.opener.reg.ant_cname2.value = Item["ap_cname2"];
                    window.opener.reg.ant_ename1.value = Item["ap_ename1"];
                    window.opener.reg.ant_ename2.value = Item["ap_ename2"];
                    window.opener.reg.ant_zip.value = Item["ap_zip"];
                    window.opener.reg.ant_addr1.value = Item["ap_addr1"];
                    window.opener.reg.ant_addr2.value = Item["ap_addr2"];
                    window.opener.reg.ant_eaddr1.value = Item["ap_eaddr1"];
                    window.opener.reg.ant_eaddr2.value = Item["ap_eaddr2"];
                    window.opener.reg.ant_eaddr3.value = Item["ap_eaddr3"];
                    window.opener.reg.ant_eaddr4.value = Item["ap_eaddr4"];
                    window.opener.reg.ant_tel0.value = Item["apatt_tel0"];
                    window.opener.reg.ant_tel.value = Item["apatt_tel"];
                    window.opener.reg.ant_tel1.value = Item["apatt_tel1"];
                    window.opener.reg.ant_email.value = Item["apatt_email"];
                    window.opener.reg.bapcustno.value = "Y";
                    window.close();
                }

            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
    }


</script>