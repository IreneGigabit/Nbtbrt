<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "國內案收文作業-查詢本所編號畫面";//;//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta21";//程式檔名前綴
    protected string HTProgCode = "brta21";//HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = "brta21";//HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";

    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string cust_seq = "";
    protected string cgrs = "";
    protected string seqnum = "";//客發用，第幾筆seq
    protected string tot_num = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        cust_seq = (Request["cust_seq"] ?? "").Trim();
        cgrs = (Request["cgrs"] ?? "").Trim();
        seqnum = (Request["seqnum"] ?? "").Trim();//客發用，第幾筆seq
        tot_num = (Request["tot_num"] ?? "").Trim();

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            this.DataBind();
        }
    }

    private void PageLayout() {
        if (cust_seq != "") {
            Lock["QClass"] = "Lock";
        }
    }

    private void QueryData() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
           
    SQL = "select a.seq,a.seq1,a.in_date,appl_name,a.cust_area,a.cust_seq,apply_no,b.ap_cname1 ";
    SQL+=" from dmt a ";
    SQL+=" inner join apcust b on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq ";
    SQL+=" where 1=1 ";
    if (seq != "") then
	    SQL+= " and a.seq like '" & seq & "%'"
    end if
    if seq1 != "" then
	    SQL+= " and a.seq1 like '" & seq1 & "%'"
    end if
    if cust_seq != "" then
	    SQL+= " and a.cust_seq = '" & cust_seq & "'"
    end if
    if ap_cname1 != "" then
	    SQL+= " and b.ap_cname1 like '%" & ap_cname1 & "%'"
    end if
    if s_mark != "" then
	    if s_mark = "T" then
		    SQL+= " and a.s_mark in ('T','') "
	    else
		    SQL+= " and a.s_mark = '" & s_mark & "'"
	    end if
    end if
    if pul != "" then
	    if s_mark = "0" then
		    SQL+= " and a.pul = ''"
	    else
		    SQL+= " and a.pul = '" & pul & "'"
	    end if
    end if
    if appl_name != "" then
	    SQL+= " and a.appl_name like '%" & appl_name & "%'"
    end if
    if kind_no != "" then
	    SQL+= " and a." & kind_no & " = '" & ref_no & "'"
    else
	    if ref_no != "" then
		    SQL+= " and (a.Apply_No like '%" & ref_no & "%'" 
		    SQL+= " or a.Issue_No like '%" & ref_no & "%'" 
		    SQL+= " or a.Rej_No like '%" & ref_no & "%')" 
	    end if		
    end if
    if kind_date != "" then
	    if sdate != "" then
		    SQL+= " and a." & kind_date & " >= '" & sdate & "'"
	    end if
	    if edate != "" then
		    SQL+= " and a." & kind_date & " <= '" & edate & "'"
	    end if
    else
	    if sdate != "" then
		    SQL+= " and (a.In_Date >= '" & sdate & "'"
		    SQL+= "  or a.Apply_Date >= '" & sdate & "'"
		    SQL+= "  or a.Issue_Date >= '" & sdate & "'"
		    SQL+= "  or a.End_Date >= '" & sdate & "')"
	    end if
	    if edate != "" then
		    SQL+= " and (a.In_Date <= '" & edate & "'"
		    SQL+= "  or a.Apply_Date <= '" & edate & "'"
		    SQL+= "  or a.Issue_Date <= '" & edate & "'"
		    SQL+= "  or a.End_Date <= '" & edate & "')"		
	    end if
    end if
    SQL+= " order by a.seq,a.seq1"


            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
            Paging page = new Paging(nowPage, PerPageSize, string.Join(";", connB.exeSQL.ToArray()));
            page.GetPagedTable(dt);

            //分頁完再處理其他資料才不會虛耗資源
            for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
                //組本所編號
                page.pagedTable.Rows[i]["fseq"] = Funcs.formatSeq(
                    page.pagedTable.Rows[i].SafeRead("seq", "")
                    , page.pagedTable.Rows[i].SafeRead("seq1", "")
                    , page.pagedTable.Rows[i].SafeRead("country", "")
                    , page.pagedTable.Rows[i].SafeRead("Branch", "")
                    , Sys.GetSession("dept") + "E");
                //國外所編號
                page.pagedTable.Rows[i]["fext_seq"] = Funcs.formatSeq(
                    page.pagedTable.Rows[i].SafeRead("ext_seq", "")
                    , page.pagedTable.Rows[i].SafeRead("ext_seq1", "")
                    , ""
                    , ""
                    , Sys.GetSession("dept") + "E");
            }

            var settings = new JsonSerializerSettings() {
                Formatting = Formatting.None,
                ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
                Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
            };

            Response.Write(JsonConvert.SerializeObject(page, settings).ToUnicode());
            Response.End();
            //return JsonConvert.SerializeObject(dt, settings).ToUnicode().Replace("\\", "\\\\").Replace("\"", "\\\"");
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
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

<form id="reg" name="reg" method="post">
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <input type="hidden" id="cgrs" name="cgrs" value="<%=cgrs%>">
    <input type="hidden" id="seqnum" name="seqnum" value="<%=seqnum%>"><!--客發用，第幾筆seq-->
    <input type="hidden" id="tot_num" name="tot_num" value="<%=tot_num%>">

    <div id="id-div-slide">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center">	
	        <TR>
		        <TD class=lightbluetable align=right>本所編號：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="text" id="seq" name="seq" size=6 maxlength=6>-
			        <input type="text" id="seq1" name="seq1" size=1 maxlength=1>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>客戶編號：</TD>
		        <TD class=whitetablebg>
			        <INPUT type="text" id="cust_area" name="cust_area" size="1" class=SEdit readonly maxlength="1" value="<%=Session["seBranch"]%>">-
			        <INPUT type="text" id="cust_seq" name="cust_seq" size="6" maxlength="6"  value="<%#cust_seq%>" class="<%#Lock.TryGet("QClass")%>">
		        </TD>
		        <TD class=lightbluetable align=right>客戶名稱：</TD>
		        <TD class=whitetablebg>
			        <input type="text" id="ap_cname1" name="ap_cname1" size=45 maxlength=40>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>商標種類：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="hidden" id="hs_mark" name="hs_mark" value="">
			        <input type="radio" name="s_mark" value="T" onclick="reg.hs_mark.value=this.value">商標
			        <input type="radio" name="s_mark" value="S" onclick="reg.hs_mark.value=this.value">服務
			        <input type="radio" name="s_mark" value="L" onclick="reg.hs_mark.value=this.value">證明
			        <input type="radio" name="s_mark" value="M" onclick="reg.hs_mark.value=this.value">團體
			        <input type="radio" name="s_mark" value="" checked onclick="reg.hs_mark.value = this.value">不指定
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>正聯防：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="radio" name="pul" value="0">正商標
			        <input type="radio" name="pul" value="1">聯合
			        <input type="radio" name="pul" value="2">防護
			        <input type="radio" name="pul" value="" checked>不指定
		        </TD>
	        </TR>
	        <TR>	
		        <TD class=lightbluetable align=right>商標名稱：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="text" id="appl_name" name="appl_name" size=40 maxlength=30>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>文號種類：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="radio" name="kind_no" value="Apply_No">申請號碼
			        <input type="radio" name="kind_no" value="Issue_No">註冊號碼
			        <input type="radio" name="kind_no" value="Rej_No">核駁號碼
			        <input type="radio" name="kind_no" value="" checked>不指定</TD>
	        </TR>	
	        <TR>	
		        <TD class=lightbluetable align=right>官方文號：</TD>
		        <TD class=whitetablebg colspan=3><input type="text" id="ref_no" name="ref_no" size=20></TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>日期種類：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="radio" name="kind_date" value="In_Date" >立案日期
			        <input type="radio" name="kind_date" value="Apply_Date">申請日期
			        <input type="radio" name="kind_date" value="Issue_Date">註冊日期
			        <input type="radio" name="kind_date" value="End_Date">結案日期
			        <input type="radio" name="kind_date" value="" checked>不指定</TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>日期期間：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="text" id="sdate" name="sdate" size="10" class="dateField">～
			        <input type="text" id="edate" name="edate" size="10" class="dateField">&nbsp;&nbsp;(YYYY/MM/DD)
		        </TD>
	        </TR>		
        </table>
        <br>
        <%#DebugStr%>
        <table id="tabBtn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
	        <tr><td width="100%" align="center">
	            <input type=button class="cbutton" id="btnQuery" name="btnQuery" value ="查詢">
	            <input type=button class="cbutton" id="btnReset" name="btnReset" value ="重填">
	            <input type=button class="cbutton" id="btnClose" name="btnClose" value ="關閉">
	        </td></tr>
        </table>
    </div>
</form>

<div id="dialog">
    <!--iframe id="myIframe" src="about:blank" width="100%" height="97%" style="border:none""></iframe-->
</div>

</body>
</html>


<script language="javascript" type="text/javascript">
    $(function () {
        this_init();
    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        $("input.dateField").datepick();
        $(".Lock").lock();
    }

    //[查詢]
    $("#btnQuery").click(function (e) {
        if ($("#seq").val() == "" && $("#cust_seq").val() == ""
             && $("#ap_cname1").val() == "" && $("#hs_mark").val() == "" && $("#appl_name").val() == ""
             && $("#ref_no").val() == "" && $("#sdate").val() == "" && $("#edate").val() == "") {
            alert("請輸入任一查詢條件!!");
            return false;
        }

        if ($("#seq").val() != "" && IsNumeric($("#seq").val()) == false) {
            alert("本所序號輸入的資料必須為數值!!");
            return false;
        }
        if ($("#seq1").val() != "" && IsNumeric($("#seq1").val()) == false) {
            alert("本所序號輸入的資料必須為數值!!");
            return false;
        }
        if ($("#cust_seq").val() != "" && IsNumeric($("#cust_seq").val()) == false) {
            alert("客戶編號輸入的資料必須為數值!!");
            return false;
        }
        if ($("#ref_no").val() != "" && IsNumeric($("#ref_no").val()) == false) {
            alert("官方文號輸入的資料必須為數值!!");
            return false;
        }
        if ($("#sdate").val() != "" && $.isDate($("#sdate").val()) == false) {
            alert("日期期間起始資料必須為日期型態!!");
            return false;
        }
        if ($("#edate").val() != "" && $.isDate($("#edate").val()) == false) {
            alert("日期期間終止資料必須為日期型態!!");
            return false;
        }
        reg.action = "brta21QList.aspx";
        reg.submit();
    });

    //[重填]
    $("#btnReset").click(function (e) {
        reg.reset();
        this_init();
    });

    //[關閉]
    $("#btnClose").click(function (e) {
        window.close();
    });
</script>
