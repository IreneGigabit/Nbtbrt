<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "國內案官方收文確認作業";//HttpContext.Current.Request["prgname"];//功能名稱
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

    protected string emg_scode = "";
    protected string emg_agscode = "";
    protected string pcount = "", ecount = "", gcount = "";
        
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

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");
        
        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title.Replace("官收", "<font color=blue>官方收文</font>");
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();
            this.DataBind();
        }
    }

    private void PageLayout() {
        StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>";

        FormName += "備註:<br>";
        FormName += "◎法定期限為總管處於本筆官收進度管制的期限(含已銷管期限)，期限後方顯示<font color=red>(銷)</font>表示本筆期限總管處已銷管。<br>\n";
        FormName += "◎「作業」顯示[確認<font color=red>*</font>]表示本筆官收可立子案。<br>\n";
        FormName += "◎「作業」顯示[<font color=red size=3>！</font>]表示本筆官收總管處程序未確認完成且未Email通知區所，請區所收到總管處程序Email通知後再執行確認。<br>\n";

        if (ReqVal.TryGet("qryfrom_flag") == "") ReqVal["qryfrom_flag"] = "P";

        emg_scode = Sys.getRoleScode(Sys.GetSession("seBranch"), Sys.GetSession("syscode"), Sys.GetSession("dept"), "mg_pror");//總管處程序人員-正本
        emg_agscode = Sys.getRoleScode(Sys.GetSession("seBranch"), Sys.GetSession("syscode"), Sys.GetSession("dept"), "mg_prorm");//總管處程序人員-副本
    }

    private void QueryData() {
        //抓取紙本收文件數
        SQL = "select count(*) as num from step_mgt_temp where cg='G' and rs='R' and from_flag <>'C' and from_flag<>'J' and into_date is null";
        objResult = conn.ExecuteScalar(SQL);
        pcount = (objResult == DBNull.Value || objResult == null) ? "" : "<font color=blue>" + objResult + "</font>件";

        //抓取電子收文件數
        SQL = "select count(*) as num from step_mgt_temp where cg='G' and rs='R' and from_flag='C' and into_date is null";
        objResult = conn.ExecuteScalar(SQL);
        ecount = (objResult == DBNull.Value || objResult == null) ? "" : "<font color=blue>" + objResult + "</font>件";

        //抓取電子公文件數
        SQL = "select count(*) as num from step_mgt_temp where cg='G' and rs='R' and from_flag='J' and into_date is null";
        objResult = conn.ExecuteScalar(SQL);
        gcount = (objResult == DBNull.Value || objResult == null) ? "" : "<font color=blue>" + objResult + "</font>件";

        SQL = "select a.temp_rs_sqlno,a.seq_area as branch,a.seq,a.seq1,a.mg_step_grade,a.rs_detail,a.apply_date as mg_apply_date,a.apply_no as mg_apply_no,a.reject_reason,a.mg_in_date,a.from_flag ";
        SQL += ",a.mg_step_rs_sqlno,a.mg_send_grade,a.mg_send_rs_sqlno,c.step_grade,c.appl_name,a.receive_no,a.mg_step_date,a.rs_class,a.rs_code,a.new_seq,d.end_date as mg_end_date,a.mg_conf_flag ";
        SQL += ",c.end_date,c.end_code ";
        SQL += ",(select code_name from cust_code where code_type='endcode' and cust_code=c.end_code) as end_reason ";
        SQL += ",c.scode as dmt_scode,(select sc_name from sysctrl.dbo.scode where scode=c.scode) as sc_name ";
        SQL += ",''fseq,''ctrl_datetxt,''lend_date,''lmg_end_date ";
        SQL += " from step_mgt_temp a ";
        SQL += " inner join todo_dmt as b on a.temp_rs_sqlno=b.temp_rs_sqlno ";
        SQL += " inner join dmt as c on a.seq=c.seq and a.seq1=c.seq1 ";
        SQL += " inner join mgt_temp d on a.temp_rs_sqlno=d.temp_rs_sqlno ";
        SQL += " where a.into_date is null and b.dowhat='GR' and b.job_status='NN' ";

        if (ReqVal.TryGet("qrystep_dateS") != "") {
            SQL += "AND a.mg_Step_Date>='" + ReqVal["qrystep_dateS"] + "' ";
        }
        if (ReqVal.TryGet("qrystep_dateE") != "") {
            SQL += "AND a.mg_Step_Date<='" + ReqVal["qrystep_dateE"] + "' ";
        }
        if (ReqVal.TryGet("qryfrom_flag") != "*" && ReqVal.TryGet("qryfrom_flag") != "") {
            if (ReqVal.TryGet("qryfrom_flag") == "C") {
                SQL += "and a.from_flag = 'C' ";
            } else if (ReqVal.TryGet("qryfrom_flag") == "J") {
                SQL += "and a.from_flag = 'J' ";
            } else {
                SQL += "and a.from_flag not in('C','J') ";
            }
        }
        if (ReqVal.TryGet("qrySeq") != "") {
            SQL += "AND a.Seq in ('" + ReqVal.TryGet("qrySeq").Replace(",", "','") + "') ";
        }
        if (ReqVal.TryGet("qrySeq1") != "") {
            SQL += "AND a.Seq1='" + ReqVal["qrySeq1"] + "' ";
        }

        ReqVal["qryOrder"] = ReqVal.TryGet("SetOrder", ReqVal.TryGet("qryOrder", "a.mg_step_date,a.mg_step_rs_sqlno"));
        if (ReqVal.TryGet("qryOrder") != "") {
            SQL += " order by " + ReqVal.TryGet("qryOrder");
        }
        Sys.showLog(SQL);
        DataTable dt = new DataTable();
        conn.DataTable(SQL, dt);

        //處理分頁
        int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
        int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "20"); //每頁筆數
        page = new Paging(nowPage, PerPageSize, SQL);
        page.GetPagedTable(dt);

        //分頁完再處理其他資料才不會虛耗資源
        for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
            DataRow dr = page.pagedTable.Rows[i];

            //案號
            dr["fseq"] = Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", Sys.GetSession("seBranch"), Sys.GetSession("dept"));

            if (dr.SafeRead("end_date", "") == "") dr["lend_date"] = "無";
            if (dr.SafeRead("mg_end_date", "") == "")dr["lmg_end_date"]="無";
                
            //抓取本筆官收法定期限,2009/2/18因有延展期限A4，所以原抓A1改抓A%
            SQL = " select ctrl_date,'' as from_flag from ctrl_mgt_temp ";
            SQL += " where temp_rs_sqlno=" + dr["temp_rs_sqlno"] + " and ctrl_type like 'A%'";
            SQL += " union select ctrl_date,'r' as from_flag from resp_mgt_temp ";
            SQL += " where temp_rs_sqlno=" + dr["temp_rs_sqlno"] + " and ctrl_type like 'A%'";
            string ctrl_date = "";
            using (SqlDataReader dr0 = conn.ExecuteReader(SQL)) {
                while (dr0.Read()) {
                    string from_name = "";
                    //2010/7/13便於區分已銷管期限，增加註記
                    if (dr0.SafeRead("from_flag", "") == "r") from_name = "<font color=red>(銷)</font>";
                    ctrl_date += (ctrl_date != "" ? "," : "") + dr0.GetDateTimeString("ctrl_date", "yyyy/M/d") + from_name;
                }
                dr["ctrl_datetxt"] = ctrl_date;
            }
        }
        dataRepeater.DataSource = page.pagedTable;
        dataRepeater.DataBind();
    }
    
    //[作業]
    protected string GetButton(RepeaterItem Container) {
        string rtn = "";

        //2014/9/10增加判斷，電子公文需總管處確認完成並Email通知區所後，區所才能確認
        string mg_conf_flag = "Y";
        if (Eval("from_flag").ToString() == "J") {
            mg_conf_flag = Eval("mg_conf_flag").ToString();
        }

        string ldoname = "確認";
        if (Eval("new_seq").ToString() != "") {
            //ldoname="立子案";
            ldoname = "確認<font color=red>*</font>";
        }
        if (mg_conf_flag == "Y") {
            rtn = "<font style=\"cursor:pointer;color:darkblue\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='darkblue'\" onclick=\"linkedit(" + (Container.ItemIndex + 1) + ",'" + Eval("seq") + "','" + Eval("seq1") + "','" + Eval("temp_rs_sqlno") + "','" + Eval("fseq") + "')\">";
            rtn += "[" + ldoname + "]</font>";
            rtn += "<font style=\"cursor:pointer;color:darkblue\" onmouseover=\"this.style.color='red'\" onmouseout=\"this.style.color='darkblue'\" onclick=\"getmgt('" + Eval("seq") + "','" + Eval("seq1") + "','" + Eval("temp_rs_sqlno") + "','" + Eval("mg_step_rs_sqlno") + "')\">[重抓]</font>";
        } else {
            rtn = "<font color=red size=3>！</font>";
        }

        return rtn;
    }

    //期限管制查詢
    protected string disButton(RepeaterItem Container) {
        if (ReqVal.TryGet("qryfrom_flag") == "C")
            return "<input type=button class=\"c1button\" name=\"btndis\" title=\"期限管制查詢\" value=\"查\" onclick=\"btndis_onclick1('" + (Container.ItemIndex + 1) + "')\">";
        else
            return "";
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
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
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
		        ◎總管處收文日期: <input type="text" id="qryStep_DateS" name="qryStep_DateS" size="10" value="<%#ReqVal.TryGet("qryStep_DateS")%>" class="dateField">
                 ~
                <input type="text" id="qryStep_DateE" name="qryStep_DateE" size="10" value="<%#ReqVal.TryGet("qryStep_DateE")%>" class="dateField">
	        </td>
	        <td class="text9">
		        ◎本所編號:<input type="text" id="qrySeq" name="qrySeq" size="30" value="<%#ReqVal.TryGet("qrySeq")%>">-<input type="text" id="qrySeq1" name="qrySeq1" size="2" value="<%#ReqVal.TryGet("qrySeq1")%>">
	        </td>
        </tr>
        <tr>
	        <td class="text9" colspan="2">
		        ◎來文方式:
                <label><input type="radio" name="qryfrom_flag" value="P" <%#ReqVal.TryGet("qryfrom_flag")=="P"?"checked":""%>>一般收文(紙本、電話、Email等<%=pcount%>)</label>
                <label><input type="radio" name="qryfrom_flag" value="C" <%#ReqVal.TryGet("qryfrom_flag")=="C"?"checked":""%>>電子收文(批次Email通知<%=ecount%>)</label>
                <label><input type="radio" name="qryfrom_flag" value="J" <%#ReqVal.TryGet("qryfrom_flag")=="J"?"checked":""%>><font color=red>電子收文(公文<%=gcount%>)</font></label>
                &nbsp;
		        <input type="button" value="查詢" class="cbutton" onClick="goSearch()" id=qrybutton>
		        <input type="hidden" name="prgid" value="<%=prgid%>">
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
                <Tr>
	                <td class="lightbluetable" nowrap align="center">作業</td>
	                <td class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.seq,a.seq1">本所編號</u></td>
	                <td class="lightbluetable" nowrap align="center">案件名稱</td>
	                <td class="lightbluetable" nowrap align="center"><u class="setOdr" v1="c.scode">營洽</u></td>
	                <td class="lightbluetable" nowrap align="center"><u class="setOdr" v1="a.mg_step_date,a.mg_step_rs_sqlno">總管處收文日</u></td>
	                <td class="lightbluetable" nowrap align="center">來文字號</td>
	                <td class="lightbluetable" nowrap align="center">收文內容</td>
	                <td class="lightbluetable" nowrap align="center">法定期限</td> 
	                <td class="lightbluetable" nowrap align="center">結案日期</td> 
	                <td class="lightbluetable" nowrap align="center">總管處結案日</td>
                </tr>
	        </thead>
	        <tbody>
    </HeaderTemplate>
	<ItemTemplate>
 	    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		    <td nowrap align="center">
                <%#GetButton(Container)%><!--作業-->
                <input type="hidden" id="seq_<%#(Container.ItemIndex+1)%>" name="seq_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq")%>">
                <input type="hidden" id="seq1_<%#(Container.ItemIndex+1)%>" name="seq1_<%#(Container.ItemIndex+1)%>" value="<%#Eval("seq1")%>">
                <input type="hidden" id="end_date_<%#(Container.ItemIndex+1)%>" name="end_date_<%#(Container.ItemIndex+1)%>" value="<%#Eval("end_date", "{0:yyyy/M/d}")%>">
                <input type="hidden" id="mg_end_date_<%#(Container.ItemIndex+1)%>" name="mg_end_date_<%#(Container.ItemIndex+1)%>" value="<%#Eval("mg_end_date", "{0:yyyy/M/d}")%>">
                <input type="hidden" id="step_grade_<%#(Container.ItemIndex + 1)%>" name="step_grade_<%#(Container.ItemIndex + 1)%>" value="<%#Eval("step_grade")%>">
		    </td>
		    <td align="center"><%#Eval("fseq")%>
                <img src="<%=Page.ResolveUrl("~/images/email01.gif")%>" style="cursor:pointer" title="Email通知總收發" align="absmiddle" border="0" onClick="tomgbutton_email('<%#Eval("fseq")%>','<%#Eval("mg_step_grade")%>','<%#Eval("mg_step_date", "{0:yyyy/M/d}")%>','<%#Eval("rs_detail")%>','<%#Eval("ctrl_datetxt")%>','<%#Eval("lend_date")%>','<%#Eval("lmg_end_date")%>')">
		    </td>
		    <td ><%#Eval("appl_name").ToString().Left(20)%></td>
		    <td nowrap align="center"><%#Eval("sc_name")%></td>
		    <td align="center"><%#Eval("mg_step_date", "{0:yyyy/M/d}")%></td>
		    <td align="left"><%#Eval("receive_no")%></td>
		    <td align="left"><%#Eval("rs_detail")%></td>
		    <td align="center"><%#Eval("ctrl_datetxt")%><%#disButton(Container)%><!--期限管制查詢--></td>
		    <td align="center"><%#Eval("end_date", "{0:yyyy/M/d}")%></td>
		    <td align="center"><%#Eval("mg_end_date", "{0:yyyy/M/d}")%></td>
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
    //資料有誤通知總收發修正
    function tomgbutton_email(fseq,mg_step_grade,mp_date,rs_detail,ctrl_date,end_date,mg_end_date){
        <%
        string strto = "";//收件者
        string strcc = "";//副本
        string strbcc = "";//密件副本
        string Sender = Sys.GetSession("scode");//寄件者
        if (Sys.Host == "web08") {
            strto = "";
            strcc = "m1583;";
            strbcc = "";
        } else if (Sys.Host == "web10") {
            strto = emg_scode + ";";
            strcc = emg_agscode + ";";
            strbcc = "";
        } else {
            strto = emg_scode + ";";
            strcc = emg_agscode + ";";
            strbcc = "";
        }
        %>
        var tsubject = "國內所商標網路系統－官收資料修正通知（區所編號：" + fseq + "，總收發進度：" + mg_step_grade + " ）";//主旨
        var strto = "<%=strto%>";//收件者
        var strcc = "<%=strcc%>";//副本
        var strbcc = "<%=strbcc%>";//密件副本
        
        var tbody = "致: 總管處 程序%0A%0A"
        tbody += "【通 知 日 期 】: " + (new Date()).format("yyyy/M/d");
        tbody += "%0A【區所編號】:" + fseq + "，總收發進度：" + mg_step_grade + "，總收發日期：" + mp_date ;
        tbody += "%0A【收文內容】:" + rs_detail;
        tbody += "%0A【法定期限】:" + ctrl_date;
        tbody += "%0A 檢核區所與總管處資料有不一致 ，煩請確認，如有資料修正，請更正後通知。";
        tbody += "%0A【檢核項目】";
        tbody += "%0A結案日期：區所："+end_date+"，總收發："+mg_end_date;
        tbody += "%0A申請日期";
        tbody += "%0A申請號碼";
        tbody += "%0A註冊日期";
        tbody += "%0A註冊號碼";
        tbody += "%0A核駁號碼";
        tbody += "%0A官收代碼";
        tbody += "%0A法定期限";

        ActFrame.location.href = "mailto:" + strto + "?subject=" + tsubject + "&body=" + tbody + "&cc=" + strcc;//+"&bcc="+ strbcc;
    }

    //檢查結案日期並link到brta24edit.asp
    function linkedit(pno,tseq,tseq1,temp_rs_sqlno,fseq){
        var br_end_date=$("#end_date_"+pno).val();
        var mg_end_date=$("#mg_end_date_"+pno).val();

        if (br_end_date!=mg_end_date) {
            if (br_end_date=="" && mg_end_date!=""){
                alert("本所編號："+fseq+"尚未結案但總收發已結案，無法確認！如確定未結案，請先Email通知總管處程序人員修改後，再執行官收確認！");
                return false;
            }
        }
        window.parent.Eblank.location.href="Brta24_edit.aspx?prgid=<%=prgid%>&cgrs=GR&seq=" + tseq + "&seq1=" + tseq1 + "&branch=<%=Session["seBranch"]%>&SubmitTask=U&temp_rs_sqlno=" + temp_rs_sqlno + "&fseq=" + fseq + "&mg_end_date=" +mg_end_date;
    }

    //重抓總管處案件主檔資料
    function getmgt(tseq,tseq1,temp_rs_sqlno,mg_step_rs_sqlno){
        if (confirm("是否確定重新取得總收發案件及官收資料？")){
            var url = getRootPath() + "/ajax/brta21_Get_mgt.aspx?prgid=<%=prgid%>&cgrs=GR&temp_rs_sqlno="+temp_rs_sqlno+"&mg_step_rs_sqlno=" + mg_step_rs_sqlno+"&qbranch=<%=Session["seBranch"]%>&qseq="+tseq+"&qseq1="+tseq1+"&qryfrom_flag=<%=ReqVal.TryGet("qryfrom_flag")%>";
            ajaxScriptByGet("重新取得總收發案件及官收資料", url);
        }
    }

    //查詢期限管制
    function btndis_onclick1(pnum){
        var tseq=$("#seq_"+pnum).val();
        var tseq1=$("#seq1_"+pnum).val();
        var tstep_grade=$("#step_grade_"+pnum).val();

        window.open(getRootPath() + "/brtam/brta21disEdit.aspx?prgid=<%=prgid%>&branch=<%=Session["seBranch"]%>&seq="+tseq+"&seq1="+tseq1+"&qtype=R&rsqlno=&step_grade="+tstep_grade+"&submitTask=Q","","width=780 height=490 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }
</script>