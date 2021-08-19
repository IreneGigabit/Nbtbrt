<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "洽案登錄作業";// HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt11_1";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Paging page = null;
    
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";

    protected string submitTask = "";
    
    protected string code_type = "";
    protected string type="",tcust_area = "", tcust_seq = "", cust_name = "";
  
    DataTable dtRS = new DataTable();
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

        type = ReqVal.TryGet("type").ToLower();
        tcust_area = ReqVal.TryGet("pfx_cust_area");
        tcust_seq = ReqVal.TryGet("Ifx_cust_seq");
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            QueryData();
            PageLayout();

            this.DataBind();
        }
    }

    private void PageLayout() {
        //StrFormBtnTop += "<a href=\"javascript:window.history.back()\" >[回上一頁]</a>";
        StrFormBtnTop += "<a href=\""+Page.ResolveUrl("~/brt1m/brt11_1.aspx")+"?prgid="+prgid+"&cust_area="+tcust_area+"&cust_seq="+tcust_seq+"&type="+type+"\">[查詢]</a>\n";
    }

    private void QueryData() {
        SQL = "select ap_cname1,ap_cname2 from apcust where cust_area = '" + tcust_area + "' and cust_seq = " + tcust_seq;
        using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
            if (dr0.Read()) {
                cust_name = dr0.SafeRead("ap_cname1", "") + dr0.SafeRead("ap_cname2", "");
            }
        }

        if (type == "ext") {
            code_type = Sys.getRsTypeExt();

            SQL = "SELECT seq,seq1,in_date,appl_name,''apcust_no,''ap_cname,issue_no,apply_no,country,''fseq,''ref_seq_name ";
            SQL += " from ext where 1=1 ";
        } else {
            code_type = Sys.getRsType();

            SQL = "SELECT seq,seq1,in_date,appl_name,apcust_no,ap_cname,issue_no,apply_no,''country,''fseq,''ref_seq_name ";
            SQL += " from dmt where 1=1 ";
        }

        foreach (var key in Request.Form.Keys) {
            string colkey = key.ToString().ToLower();
            string colValue = Request[colkey];

            if (colValue != "") {
                if (colkey.Left(3) == "tfx") {
                    SQL += " and " + colkey.Substring(4) + " like '%" + colValue + "%' ";
                } else if (colkey.Left(3) == "pfx") {
                    SQL += " and " + colkey.Substring(4) + " like '" + colValue + "%' ";
                } else if (colkey.Left(3) == "ifx") {
                    SQL += " and " + colkey.Substring(4) + " ='" + colValue + "' ";
                } else if (colkey.Left(3) == "sfx") {
                    SQL += " and " + colkey.Substring(4) + " >=" + colValue + " ";
                } else if (colkey.Left(3) == "efx") {
                    SQL += " and " + colkey.Substring(4) + " <=" + colValue + " ";
                }
            }
        }
        SQL += " order by seq,seq1 ";

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
            dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), dr.SafeRead("country", ""), Sys.GetSession("seBranch"), Sys.GetSession("dept"));

            if (type == "ext") {//出口案
                SQL = "select apcust_no,ap_cname1,ap_cname2 from ext_apcust where seq=" + dr["seq"] + " and seq1='" + dr["seq1"] + "'";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        dr["apcust_no"] = dr0.SafeRead("apcust_no", "");
                    }
                }

                SQL = "select ref_seq,ref_seq1 from ext where seq=" + dr["seq"] + " and seq1='" + dr["seq1"] + "'";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        dr["ref_seq_name"] = Sys.formatSeq(dr0.SafeRead("ref_seq", ""), dr0.SafeRead("ref_seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept") + "E");
                    }
                }
            } else {
                SQL = "select apcust_no,ap_cname from dmt_ap where seq=" + dr["seq"] + " and seq1='" + dr["seq1"] + "'";
                using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                    if (dr0.Read()) {
                        dr["apcust_no"] = dr0.SafeRead("apcust_no", "");
                        dr["ap_cname"] = dr0.SafeRead("ap_cname", "");
                    }
                }
            }
        }

        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();

        //案性分類
        SQL = "SELECT Cust_code,Code_name,form_name,remark";
        SQL += " FROM Cust_code";
        SQL += " WHERE Code_type = '" + code_type + "' AND form_name is not null ";
        SQL += "AND convert(varchar,cust_code)<>'A1' ";
        SQL += "order by cust_code";
        conn.DataTable(SQL, dtRS);
    }

    protected void dataRepeater_ItemDataBound(object sender, RepeaterItemEventArgs e) {
        if ((e.Item.ItemType == ListItemType.Item) || (e.Item.ItemType == ListItemType.AlternatingItem)) {
            Repeater rsRepeater = (Repeater)e.Item.FindControl("rsRepeater");
            if ((rsRepeater != null)) {
                rsRepeater.DataSource = dtRS;
                rsRepeater.DataBind();
            }
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
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

<form style="margin:0;" id="reg" name="reg" method="post">
    <input type=hidden id=prgid name=prgid value="<%#prgid%>">
    <input type=hidden id=cust_area name=cust_area>
    <input type=hidden id=cust_seq name=cust_seq>
    <input type=hidden id=ar_form name=ar_form>
    <input type=hidden id=prt_code name=prt_code>
    <input type=hidden id=new_form name=new_form>
    <input type=hidden id=seq name=seq>
    <input type=hidden id=seq1 name=seq1>
    <input type=hidden id=type name=type value="<%=type%>">
	<input type=hidden name=code_type value="<%=code_type%>">
    <input type=hidden id=uploadtype name=uploadtype value="case"><!--文件上傳畫面用，表接洽記錄-->
</form>

<form id="regPage" name="regPage" method="post">
    <%#page.GetHiddenText("GoPage,PerPage,SetOrder,chktest")%>
    <div id="divPaging" style="display:<%#page.totRow==0?"none":""%>">

      <table width="60%" cellspacing="1" cellpadding="0" align="center">
          <tr align="left">
	        <td align="center" ><h3>客戶編號：</h3></td>
	        <td align="left"><h3><%=tcust_area%>-<%=tcust_seq%></h3></td>
	        <td align="center" ><h3>客戶名稱：</h3></td>
	        <td align="left"><h3><%=cust_name%></h3></td>
          </tr>
      </table>

    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
        <tr>
            <td colspan=2 align=center>
                <font size="2" color="#3f8eba">
                第<font color="red"><span id="NowPage"><%#page.nowPage%></span>/<span id="TotPage"><%#page.totPage%></span></font>頁
                | 資料共 <font color="red"><span id="TotRec"><%#page.totRow%></span></font> 筆
                | 跳至第<select id="GoPage" name="GoPage" style="color:#FF0000"><%#page.GetPageList()%></select>頁
                <span id="PageUp" style="display:<%#page.nowPage>1?"":"none"%>">| <a href="javascript:void(0)" class="pgU" v1="<%#page.nowPage-1%>">上一頁</a></span>
                <span id="PageDown" style="display:<%#page.nowPage<page.totPage?"":"none"%>">| <a href="javascript:void(0)" class="pgD" v1="<%#page.nowPage+1%>">下一頁</a></span>
                | 每頁筆數:
                <select id="PerPage" name="PerPage" style="color:#FF0000">
                 <option value="10" <%#page.perPage==10?"selected":""%>>10</option>
                 <option value="20" <%#page.perPage==20?"selected":""%>>20</option>
                 <option value="30" <%#page.perPage==30?"selected":""%>>30</option>
                 <option value="30" <%#page.perPage==40?"selected":""%>>40</option>
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

<asp:Repeater id="dataRepeater" runat="server" OnItemDataBound="dataRepeater_ItemDataBound">
<HeaderTemplate>
        <table style="display:<%#page.totRow==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	    <thead>
            <Tr>
	            <td align="center" class="lightbluetable">案件編號</td>
	            <td align="center" class="lightbluetable" width="20%">案件名稱</td>
	            <td align="center" class="lightbluetable">申請人號</td>	
	            <td align="center" class="lightbluetable">申請人名稱</td>
	            <td align="center" class="lightbluetable">立案日期</td>
	            <td align="center" class="lightbluetable">申請號</td>
	            <td align="center" class="lightbluetable">註冊號</td>
	            <td align="center" class="lightbluetable tdext" style="display:none">相關案號</td>
	            <td align="center" class="lightbluetable tdbrt11" style="display:none">洽案登錄</td>
            </tr>
	    </thead>
	    <tbody>
</HeaderTemplate>
			<ItemTemplate>
 		        <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>" align="center">
	                <td style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" nowrap onclick="CapplClick('<%#Eval("Seq")%>','<%#Eval("Seq1")%>')">
                        <%#Eval("fseq")%>
                    </td>
	                <td><%#Eval("appl_name").ToString().Left(20)%></td>
	                <td><%#Eval("apcust_no")%></td>
	                <td><%#Eval("ap_cname").ToString().Left(20)%></td>	
	                <td><%#Eval("in_date","{0:yyyy/M/d}")%></td>
	                <td><%#Eval("apply_no")%></td>
	                <td><%#Eval("issue_no")%></td>
	                <td class="tdext">
		                <a href="<%=Page.ResolveUrl("~/Brt5m/Brt15showFP.aspx")%>?prgid=<%=prgid%>&seq=<%#Eval("seq")%>&seq1=<%#Eval("seq1")%>&submittask=Q" target="_blank"><%#Eval("ref_seq_name")%></a>
	                </td>
		            <td class="tdbrt11" align="center">
                        <asp:Panel runat="server" ID="emptyCtrl" Visible='<%#Eval("apcust_no").ToString()==""%>'>
                            <FONT COLOR=RED>※無申請人號</FONT>
                        </asp:Panel>
                        <asp:Repeater id="rsRepeater" runat="server" Visible='<%#DataBinder.Eval(((RepeaterItem)Container).DataItem, "apcust_no").ToString()!=""%>'>
                            <HeaderTemplate>
			                    <SELECT name=toadd<%#(Container.ItemIndex+1)%> id=toadd<%#(Container.ItemIndex+1)%> onchange="Formadd('<%#tcust_area%>','<%#tcust_seq%>',this,'<%#DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "seq")%>','<%#DataBinder.Eval(((RepeaterItem)Container.Parent.Parent).DataItem, "seq1")%>' )" >
			                    <option value="" style="color:blue">請選擇案性</option>
                            </HeaderTemplate>
			                <ItemTemplate>
                                <option value="<%#Eval("Cust_code").ToString().Trim()%>" v1="<%#Eval("form_name").ToString().Trim()%>" v2="<%#Eval("remark").ToString().Trim()%>"><%#Eval("Code_name")%></option>
			                </ItemTemplate>
                        </asp:Repeater>
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

        $(".tdext,.tdbrt11").hide();

        if ($("#type").val() == "ext") {
            $(".tdext").show();
        }

        if ($("#prgid").val() == "brt11") {
            $(".tdbrt11").show();
        }
    });

    //執行查詢
    function goSearch() {
        $("#regPage").submit();
    };
    //////////////////////
    function CapplClick(pseq, pseq1) {
        window.showModalDialog(getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + pseq + "&seq1=" + pseq1 + "&submittask=Q", "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }

    function Formadd(x, y, obj, m, n) {
        var oThis = $(obj);
        if (oThis.val() == "") return false;

        reg.cust_area.value = x;
        reg.cust_seq.value = y;

        reg.ar_form.value = oThis.val();
        reg.seq.value = m;
        reg.seq1.value = n;
        reg.ar_form.value = oThis.val();
        reg.prt_code.value = $('option:selected', oThis).attr('v1');
        reg.new_form.value = $('option:selected', oThis).attr('v2');//20201006原由form_name判斷案性入口aspx,改為remark

        if ($("#type").val() == "ext") {
            reg.action = "Ext11Add" + reg.prt_code.value + ".aspx"
        } else {
            reg.action = "Brt11Add" + reg.new_form.value + ".aspx";
        }
        reg.submit();
    }
</script>
