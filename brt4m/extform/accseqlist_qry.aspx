<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Linq" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內/出口個案明細表";// HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";

    protected string SQL = "";
    protected object objResult = null;
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    
    protected string titleLabel = "";
    protected string submitTask = "";

    protected string wsql = "";
    protected string country = "";
    protected string seq = "";
    protected string seq1 = "";

    DataTable dt = new DataTable();
    DataTable dtArt = new DataTable();//應收帳款
    DataTable dtIn = new DataTable();//收入
    DataTable dtFees = new DataTable();//規費

    //應收帳款合計
    protected int sum_ar_service=0;
	protected int sum_ar_fees=0;
	protected int sum_ar_tax_out=0;
	protected int sum_cservice=0;
	protected int sum_cfees=0;
	protected int sum_ctax_out=0;
	protected int sum_tot_service=0;
	protected int sum_tot_fees=0;
	protected int sum_tot_tax_out=0 ;
	protected int sum_dfees=0;	//扣收入的規費
    protected decimal sum_rservice = 0;	//總計沖轉服務費
    protected decimal sum_rfees = 0;
    protected decimal sum_rtax_out = 0;
    //收入合計
    protected int sum_pin_service = 0;//服務費
    protected int sum_pin_fees = 0;//規費
    protected int sum_pin_tax_out = 0;//營業稅
    protected decimal sum_plus_add = 0;//收入加項
    protected decimal sum_plus_del = 0;//收入減項
    //規費合計
    protected decimal sum_fees = 0;//應付規費(D)
    protected decimal sum_fees_add = 0;//應付規費(+)
    protected decimal sum_fees_del = 0;//應付規費(-)
    //各項應收金額及規費結餘
	protected decimal ar_service= 0;//服務費應收
	protected decimal ar_fees= 0;//規費應收
	protected decimal ar_tax_out= 0;//營業稅應收
	protected decimal ar_tot_money= 0;//總計應收(含稅)
	protected decimal fee_money= 0;//規費結餘

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper connacc = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (connacc != null) connacc.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = Request["submitTask"] ?? "";

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        connacc = new DBHelper(Conn.account).Debug(Request["chkTest"] == "TEST");

        country = ReqVal.TryGet("country").ToUpper();
        seq = ReqVal.TryGet("seq");
        seq1 = ReqVal.TryGet("seq1");
        
        if (country=="T"){
	        HTProgCap="<font color=blue>國內</font>案<font color=red>商標</font>個案明細表";
        }else{
            HTProgCap = "<font color=blue>出口</font>案<font color=red>商標</font>個案明細表";
        }

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            QueryData();

            this.DataBind();
        }
    }

    private void PageLayout() {
        if (country != "T") StrFormBtnTop += "<a href=\"javascript:voie(0);\" onclick=\"dnlist_from()\">[代理人請款記錄]</a>";
        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";

        string fseq = "";
        if (country == "T") {
            fseq = Sys.formatSeq(seq, seq1, "", Sys.GetSession("SeBranch"), Sys.GetSession("dept"));
            wsql = " and country='T' ";

            SQL = "select ''ext_seq,''ext_seq1,a.cust_area,a.cust_seq,a.appl_name,b.ap_cname1 as cust_name ";
            SQL += " from dmt a ";
            SQL += " inner join apcust b ";
        } else {
            fseq = Sys.formatSeq(seq, seq1, country, Sys.GetSession("SeBranch"), Sys.GetSession("dept") + "E");
            wsql = " and country<>'T' ";

            SQL = "select a.ext_seq,ext_seq1,a.cust_area,a.cust_seq,a.appl_name,b.ap_cname1 as cust_name ";
            SQL += " from ext a ";
            SQL += " inner join apcust b ";
        }
        SQL += " on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq ";
        SQL += " where 1=1 ";
        if (seq != "") SQL += " and a.Seq ='" + seq + "'";
        if (seq1 != "") SQL += " and a.Seq1 ='" + seq1 + "'";
        //Sys.showLog(SQL);
        conn.DataTable(SQL, dt);

        if (dt.Rows.Count > 0) {
            DataRow dr = dt.Rows[0];
            titleLabel = "&nbsp;&nbsp;◎國內所編號：" + fseq;
            titleLabel += "&nbsp;◎案件名稱：" + dr.SafeRead("appl_name", "") + "<br>";
            if (country != "T") {
                titleLabel += "&nbsp;&nbsp;◎國外所編號：" + Sys.formatSeq(dr.SafeRead("seq", ""), dr.SafeRead("seq1", ""), "", "", Sys.GetSession("dept") + "E") + "&nbsp;" + country;
            }
            titleLabel += "&nbsp;&nbsp;◎客戶編號：" + dr.SafeRead("cust_area", "") + dr.SafeRead("cust_seq", "") + "&nbsp;" + dr.SafeRead("cust_name", "");
        }
    }

    private void QueryData() {
        //抓取應收帳款資料
        SQL = "select arcase,ar_no,ardate,scode,service,fees,tax_out,cservice,cfees,ctax_out,casegrp,ar_mark,db_no,in_curr,inv_mark";
        SQL += ",(select case_name from varcase where dept='T' and casegrp=a.casegrp and arcase=a.arcase) as case_name ";
        SQL += ",isnull((select sum(rservice) from artran where dept='" + Session["dept"] + "' and ar_sqlno=a.art_sqlno),0) as rservice";
        SQL += ",isnull((select sum(rfees) from artran where dept='" + Session["dept"] + "' and ar_sqlno=a.art_sqlno),0) as rfees";
        SQL += ",isnull((select sum(rtax_out) from artran where dept='" + Session["dept"] + "' and ar_sqlno=a.art_sqlno),0) as rtax_out";
        SQL += ",service+cservice tot_service,fees+cfees tot_fees,tax_out+ctax_out tot_tax_out";
        SQL += " from art a where seq=" + seq + " and seq1='" + seq1 + "' " + wsql + " order by ardate ";
        connacc.DataTable(SQL, dtArt);
        artRepeater.DataSource = dtArt;
        artRepeater.DataBind();
        //合計
        sum_ar_service = Convert.ToInt32(dtArt.Compute("Sum(service)", ""));//服務費
        sum_ar_fees = Convert.ToInt32(dtArt.Compute("Sum(fees)", ""));//規費
        sum_ar_tax_out = Convert.ToInt32(dtArt.Compute("Sum(tax_out)", ""));//營業稅
        sum_cservice = Convert.ToInt32(dtArt.Compute("Sum(cservice)", ""));//更正服務費
        sum_cfees = Convert.ToInt32(dtArt.Compute("Sum(cfees)", ""));//更正規費
        sum_ctax_out = Convert.ToInt32(dtArt.Compute("Sum(ctax_out)", ""));//更正營業稅
        sum_tot_service = Convert.ToInt32(dtArt.Compute("Sum(tot_service)", ""));//總計服務費
        sum_tot_fees = Convert.ToInt32(dtArt.Compute("Sum(tot_fees)", ""));//總計規費
        sum_tot_tax_out = Convert.ToInt32(dtArt.Compute("Sum(tot_tax_out)", ""));//總計營業稅
        sum_dfees = dtArt.AsEnumerable().Sum(x => x["fees"] == DBNull.Value ? 0 : (int)x["fees"]);//扣收入的規費
        sum_rservice = Convert.ToDecimal(dtArt.Compute("Sum(rservice)", ""));//沖轉已收服務費
        sum_rfees = Convert.ToDecimal(dtArt.Compute("Sum(rfees)", ""));//沖轉已收規費
        sum_rtax_out = Convert.ToDecimal(dtArt.Compute("Sum(rtax_out)", ""));//沖轉已收營業稅

        //抓取收入資料1-acct_pin
        int plusRow = 0;
        SQL = "select '**1**'dt_type,arcase,ar_no,in_date as ardate,service,fees,tax_out,acc_date,casegrp,isnull(in_curr,0)in_curr,db_no,''tclass";
        SQL += ",(select case_name from varcase where dept='" + Session["dept"] + "' and casegrp=a.casegrp and arcase=a.arcase) as case_name ";
        SQL += ",(select tran_no from acct where branch=a.branch and in_no=a.in_no) as tran_no ";
        SQL += ",(select acc_sqlno from acct where branch=a.branch and in_no=a.in_no) as acc_sqlno ";
        SQL += " from acct_pin a where seq=" + seq + " and seq1='" + seq1 + "' and dept='T' " + wsql + " order by in_date ";
        connacc.DataTable(SQL, dtIn);

        //抓取收入調整資料2-oacct_plus
        SQL = "select '**2**'dt_type,arcase,ar_no,plus_date as ardate,nt_money,acc_code,remark,casegrp,tran_no,acc_sqlno,db_no,dc_code,0.00 plus_add,0.00 plus_del,''tclass,0 in_curr ";
        SQL += ",(select case_name from varcase where dept='" + Session["dept"] + "' and casegrp=a.casegrp and arcase=a.arcase) as case_name ";
        SQL += " from oacct_plus a where seq=" + seq + " and seq1='" + seq1 + "' and dept='T' " + wsql + " and acc_code like '4%' order by plus_date ";
        connacc.DataTable(SQL, dtIn);

        //抓取收入調整資料3-acct_plus
        SQL = "select '**3**'dt_type,arcase,ar_no,plus_date as ardate,nt_money,acc_code,remark,casegrp,tran_no,acc_sqlno,db_no,dc_code,0.00 plus_add,0.00 plus_del,''tclass,0 in_curr ";
        SQL += ",(select case_name from varcase where dept='" + Session["dept"] + "' and casegrp=a.casegrp and arcase=a.arcase) as case_name ";
        SQL += " from acct_plus a where seq=" + seq + " and seq1='" + seq1 + "' and dept='T' " + wsql + " and acc_code like '4%' order by plus_date ";
        connacc.DataTable(SQL, dtIn);
        if (dtIn.Rows.Count > 0) {
            for (int i = 0; i < dtIn.Rows.Count; i++) {
                DataRow dr = dtIn.Rows[i];

                //行樣式
                dr["tclass"] = (++plusRow) % 2 == 1 ? "sfont9" : "lightbluetable3";

                //2015/1/21因有大陸進口案4MP2,4MP3，所以修改只抓最後一碼
                //2017/6/28增加借貸方dc_code判斷
                if (dr.SafeRead("acc_code", "").Right(1) == "2") {
                    if (dr.SafeRead("dc_code", "") == "2")//貸方
                        dr["plus_add"] = dr["nt_money"];
                    else
                        dr["plus_del"] = dr["nt_money"];
                }
                if (dr.SafeRead("acc_code", "").Right(1) == "3") {
                    if (dr.SafeRead("dc_code", "") == "1") //借方
                        dr["plus_del"] = dr["nt_money"];
                    else
                        dr["plus_add"] = dr["nt_money"];
                }
            }
            inRepeater.DataSource = dtIn;
            inRepeater.DataBind();
            //合計
            sum_pin_service = Convert.ToInt32(dtIn.Compute("Sum(service)", ""));//服務費
            sum_pin_fees = Convert.ToInt32(dtIn.Compute("Sum(fees)", ""));//規費
            sum_pin_tax_out = Convert.ToInt32(dtIn.Compute("Sum(tax_out)", ""));//營業稅
            
            sum_plus_add = Convert.ToInt32(dtIn.Compute("Sum(plus_add)", ""));//收入加項
            sum_plus_del = Convert.ToInt32(dtIn.Compute("Sum(plus_del)", ""));//收入減項
        }

        //抓取規費資料1-oacct_plus
        int acctRow = 0;
        SQL = "select '**1**'dt_type,arcase,ar_no,plus_date as ardate,nt_money,acc_code1,dc_code,plus_no,excase,ex_rate,currency,tr_money,remark,casegrp,tran_no,acc_sqlno ";
        SQL += ",(select case_name from varcase where dept='" + Session["dept"] + "' and casegrp=a.casegrp and arcase=a.arcase) as case_name";
        SQL += ",(select rs_detail from " + Sys.tdbname(Sys.GetSession("seBranch")) + ".code_ext where ar_flag='Y' and rs_code=a.excase) as excase_name";
        SQL += ",0.00 fees,0.00 fees_add,0.00 fees_del,''tclass";
        SQL += " from oacct_plus a where seq=" + seq + " and seq1='" + seq1 + "' and dept='T' " + wsql + " and acc_code like '21T%' order by plus_date ";
        connacc.DataTable(SQL, dtFees);

        //抓取規費資料2-acct_plus
        SQL = "select '**2**'dt_type,arcase,ar_no,plus_date as ardate,nt_money,acc_code1,dc_code,plus_no,excase,ex_rate,currency,tr_money,remark,casegrp,tran_no,acc_sqlno ";
        SQL += ",(select case_name from varcase where dept='" + Session["dept"] + "' and casegrp=a.casegrp and arcase=a.arcase) as case_name";
        SQL += ",(select rs_detail from " + Sys.tdbname(Sys.GetSession("seBranch")) + ".code_ext where ar_flag='Y' and rs_code=a.excase) as excase_name";
        SQL += ",0.00 fees,0.00 fees_add,0.00 fees_del,''tclass";
        SQL += " from acct_plus a where seq=" + seq + " and seq1='" + seq1 + "' and dept='T' " + wsql + " and acc_code like '21T%' order by plus_date ";
        connacc.DataTable(SQL, dtFees);
        if (dtFees.Rows.Count > 0) {
            for (int i = 0; i < dtFees.Rows.Count; i++) {
                DataRow dr = dtFees.Rows[i];

                //行樣式
                dr["tclass"] = (++acctRow) % 2 == 1 ? "sfont9" : "lightbluetable3";

                if (dr.SafeRead("acc_code1", "") == "99") {
                    if (dr.SafeRead("dc_code", "") == "1")
                        dr["fees"] = dr["nt_money"];
                    else
                        dr["fees_add"] = dr["nt_money"];
                }
                if (dr.SafeRead("acc_code1", "") == "01") dr["fees_add"] = dr["nt_money"];
                if (dr.SafeRead("acc_code1", "") == "02") dr["fees_del"] = dr["nt_money"];
            }
            feesRepeater.DataSource = dtFees;
            feesRepeater.DataBind();
            //合計
            sum_fees = Convert.ToInt32(dtFees.Compute("Sum(fees)", ""));//應付規費(D)
            sum_fees_add = Convert.ToInt32(dtFees.Compute("Sum(fees_add)", ""));//應付規費(+)
            sum_fees_del = Convert.ToInt32(dtFees.Compute("Sum(fees_del)", ""));//應付規費(-)
        }

        //計算各項應收金額及規費結餘
        //2014/9/16修改，依UNIX帳款系統，加異動沖轉已收服務費		
        ar_service = sum_ar_service + sum_cservice - sum_pin_service + sum_rservice;
        if (ar_service < 0) ar_service = 0;

        //2009/9/18修改，要扣除扣收入之應收規費
        //2014/9/16修改，依UNIX帳款系統，加異動沖轉已收規費
        ar_fees = sum_ar_fees + sum_cfees - sum_pin_fees - sum_dfees + sum_rfees;
        if (ar_fees < 0) ar_fees = 0;
        //2014/9/16修改，依UNIX帳款系統，加異動沖轉已收營業稅
        ar_tax_out = sum_ar_tax_out + sum_ctax_out - sum_pin_tax_out + sum_rtax_out;
        if (ar_tax_out < 0) ar_tax_out = 0;
        ar_tot_money = ar_service + ar_fees + ar_tax_out;
        fee_money = sum_pin_fees + sum_fees_add - sum_fees_del - sum_fees;
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
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
        <td colspan="2"><%#titleLabel%></td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<br />

<div align="center" id="noData" style="display:<%#dt.Rows.Count==0?"":"none"%>">
	<font color="red">=== 目前無資料 ===</font>
</div>

    <asp:Repeater id="artRepeater" runat="server">
    <HeaderTemplate>
        <table style="display:<%#dtArt.Rows.Count==0?"none":""%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center">
	    <tr align="center">  
		    <td class="lightbluetable1" colspan=15 >
                <font color=white>*&nbsp;&nbsp;應&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;收&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;帳&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;款&nbsp;&nbsp;*</font>
		    </td>  
	    </tr>
	    <tr align="center">  
		    <td class="lightbluetable">案性</td>
		    <td class="lightbluetable">案性名稱</td>
		    <td class="lightbluetable">帳款編號</td>
		    <td class="lightbluetable">請款單號</td>		
		    <td class="lightbluetable">帳款日期</td>
		    <td class="lightbluetable">營洽</td>
		    <td class="lightbluetable">服務費</td>
		    <td class="lightbluetable">規費</td>
		    <td class="lightbluetable">營業稅</td>
		    <td class="lightbluetable">更正服務費</td>
		    <td class="lightbluetable">更正規費</td>
		    <td class="lightbluetable">更正營業稅</td>
		    <td class="lightbluetable">總計服務費</td>
		    <td class="lightbluetable">總計規費</td>
		    <td class="lightbluetable">總計營業稅</td>
	    </tr>
    </HeaderTemplate>
	<ItemTemplate>
 	    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		    <td align="center"><%#Eval("arcase")%></td>
		    <td align="center"><%#Eval("case_name")%></td>
		    <td align="center"><%#Eval("ar_no")%><%#(Convert.ToInt32(Eval("in_curr"))>1 ?"-"+Eval("in_curr"):"")%></td>
		    <td align="center"><%#Eval("db_no")%></td>
		    <td align="center"><%#Eval("ardate","{0:d}")%></td>
		    <td align="center"><%#Eval("scode")%></td>
		    <td align="right"><%#Eval("service")%></td>
		    <td align="right"><%#Eval("fees")%></td>
		    <td align="right"><%#Eval("tax_out")%><%#(Eval("inv_mark").ToString()=="I"?"("+Eval("inv_mark")+ ")":"")%></td>
		    <td align="right"><%#Eval("cservice")%></td>
		    <td align="right"><%#Eval("cfees")%></td>
		    <td align="right"><%#Eval("ctax_out","{0:0}")%></td>
		    <td align="right"><%#Eval("tot_service","{0:0}")%></td>
		    <td align="right"><%#Eval("tot_fees","{0:0}")%></td>
		    <td align="right"><%#Eval("tot_tax_out","{0:0}")%><%#(Eval("ar_mark").ToString()!="N"?"("+Eval("ar_mark")+")":"")%></td>
	    </tr>
	</ItemTemplate>
    <FooterTemplate>
           <tr>
		        <td align="right" colspan=6 style="BACKGROUND-COLOR: #ffff99">*小計</td>
		        <td align="right" style="BACKGROUND-COLOR: #ffff99"><%=sum_ar_service%></td>
		        <td align="right" style="BACKGROUND-COLOR: #ffff99"><%=sum_ar_fees%></td>
		        <td align="right" style="BACKGROUND-COLOR: #ffff99"><%=sum_ar_tax_out%></td> 
		        <td align="right" style="BACKGROUND-COLOR: #ffff99"><%=sum_cservice%></td>
		        <td align="right" style="BACKGROUND-COLOR: #ffff99"><%=sum_cfees%></td>
		        <td align="right" style="BACKGROUND-COLOR: #ffff99"><%=sum_ctax_out%></td>  
		        <td align="right" style="BACKGROUND-COLOR: #ffff99"><%=sum_tot_service%></td>
		        <td align="right" style="BACKGROUND-COLOR: #ffff99"><%=sum_tot_fees%></td>
		        <td align="right" style="BACKGROUND-COLOR: #ffff99"><%=sum_tot_tax_out%></td> 
	        </tr>
        </table>
    </FooterTemplate>
    </asp:Repeater>
    <br />
    <table style="display:<%#((dtIn.Rows.Count==0)?"none":"")%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center">
	    <tr align="center">  
		    <td class="lightbluetable1" colspan=12 ><font color=white>*&nbsp;&nbsp;收&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;入&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料&nbsp;&nbsp;*</font></td>  
	    </tr>
	    <tr align="center">  
		    <td class="lightbluetable">案性</td>
		    <td class="lightbluetable">案性名稱</td>
		    <td class="lightbluetable">帳款編號</td>	
		    <td class="lightbluetable">請款單號</td>	
		    <td class="lightbluetable">傳票號碼</td>	
		    <td class="lightbluetable">傳票日期</td>
		    <td class="lightbluetable">服務費</td>
		    <td class="lightbluetable">規費</td>
		    <td class="lightbluetable">營業稅</td>
		    <td class="lightbluetable">回收日期</td>
		    <td class="lightbluetable">收入加項</td>
		    <td class="lightbluetable">收入減項</td>
	    </tr>
    <asp:Repeater id="inRepeater" runat="server">
	<ItemTemplate>
 	    <tr class="<%#Eval("tclass")%>">
		    <td align="center"><%#Eval("arcase")%></td><!--<%#Eval("dt_type")%>-->
		    <td align="center"><%#Eval("case_name")%></td>
		    <td align="center"><%#Eval("ar_no")%><%#(Convert.ToInt32(Eval("in_curr"))>1 ?"-"+Eval("in_curr"):"")%></td>
		    <td align="center"><%#Eval("db_no")%></td>
		    <td align="center"><%#Eval("tran_no")%></td>
		    <td align="center"><%#Eval("ardate","{0:d}")%></td>
		    <td align="right"><%#Eval("service","{0:0}")%></td>
		    <td align="right"><%#Eval("fees","{0:0}")%></td>
		    <td align="right"><%#Eval("tax_out","{0:0}")%></td> 
		    <td align="center"><%#Eval("acc_date","{0:d}")%></td>
		    <td align="right"><%#Eval("plus_add","{0:0}")%></td> 
		    <td align="right"><%#Eval("plus_del","{0:0}")%></td>
	    </tr>
	</ItemTemplate>
    </asp:Repeater>
	<tr>
		<td align="right" colspan=6 style="BACKGROUND-COLOR: #ffff99">*小計</td>
		<td align="right" style="BACKGROUND-COLOR: #ffff99"><%=sum_pin_service%></td>
		<td align="right" style="BACKGROUND-COLOR: #ffff99"><%=sum_pin_fees%></td>
		<td align="right" style="BACKGROUND-COLOR: #ffff99"><%=sum_pin_tax_out%></td> 
		<td align="right" style="BACKGROUND-COLOR: #ffff99"></td>
		<td align="right" style="BACKGROUND-COLOR: gold"><%=sum_plus_add%></td>
		<td align="right" style="BACKGROUND-COLOR: lightgreen"><%=sum_plus_del%></td>  
	</tr>  
    </table>
    <br />
    <table style="display:<%#((dtFees.Rows.Count==0)?"none":"")%>" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center">
	    <tr align="center">  
		    <td align="center" class="lightbluetable1" colspan=10 >
                <font color=white>*&nbsp;&nbsp;規&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;費&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料&nbsp;&nbsp;*</font>
		    </td>  
	    </tr>
	    <tr align="center">  
		    <td class="lightbluetable">案性</td>
		    <td class="lightbluetable">案性名稱</td>
		    <td class="lightbluetable">帳款編號</td>	
		    <td class="lightbluetable">傳票號碼</td>
		    <td class="lightbluetable">傳票日期</td>
		    <td class="lightbluetable">應付規費(D)</td>
		    <td class="lightbluetable">應付規費(+)</td>
		    <td class="lightbluetable">應付規費(-)</td>
		    <td class="lightbluetable">出口編號</td>
		    <td class="lightbluetable">收費性質</td>
	    </tr>
    <asp:Repeater id="feesRepeater" runat="server">
	<ItemTemplate>
 	    <tr class="<%#Eval("tclass")%>">
		    <td align="center" rowspan=2><%#Eval("arcase")%></td><!--<%#Eval("dt_type")%>-->
		    <td align="center" rowspan=2><%#Eval("case_name")%></td> 
		    <td align="center" rowspan=2><%#Eval("ar_no")%></td>
		    <td align="center" rowspan=2><%#Eval("tran_no")%></td> 
		    <td align="center" rowspan=2><%#Eval("ardate","{0:d}")%></td>
		    <td align="right"><%#Eval("fees","{0:0.00}")%></td>
		    <td align="right"><%#Eval("fees_add","{0:N2}")%></td>
		    <td align="right"><%#Eval("fees_del","{0:N2}")%></td>
		    <td align="center"><%#Eval("plus_no")%></td>
		    <td align="center"><%#Eval("excase")%>&nbsp;<%#Eval("excase_name")%></td> 
	    </tr>
 	    <tr class="<%#(Container.ItemIndex+1)%2== 1 ?"sfont9":"lightbluetable3"%>">
		    <td align="center" colspan=3><%#Eval("remark")%></td>
		    <td align="center"><%#((Convert.ToDecimal(Eval("fees"))!=0&&Convert.ToDecimal(Eval("ex_rate"))!=0)?"匯率："+Eval("ex_rate","{0:f4}"):"")%></td>
		    <td align="center"><%#((Convert.ToDecimal(Eval("fees"))!=0&&Eval("currency").ToString()!="")?"外幣："+Eval("currency")+"&nbsp;"+Eval("tr_money","{0:f2}"):"")%></td>
	    </tr>
	</ItemTemplate>
    </asp:Repeater>
    <tr>	
		<td align="right" colspan=5 style="BACKGROUND-COLOR: #ffff99">*小計</td>
		<td align="right" style="BACKGROUND-COLOR: #ffff99"><%=sum_fees.ToString("N2")%></td>
		<td align="right" style="BACKGROUND-COLOR: #ffff99"><%=sum_fees_add.ToString("N2")%></td>
		<td align="right" style="BACKGROUND-COLOR: #ffff99"><%=sum_fees_del.ToString("N2")%></td> 
		<td align="right" style="BACKGROUND-COLOR: #ffff99"></td>
		<td align="right" style="BACKGROUND-COLOR: #ffff99"></td>
    </tr>
    </table>
    <br>
    <table  border="0" class="greentable" cellspacing="1" cellpadding="2" width="100%" align="center">
        <tr class="greenths">  
		    <td align="center">服務費應收</td>
		    <td align="center">規費應收</td>	
		    <td align="center">營業稅應收</td>
		    <td align="center">總計應收(含稅)</td>
		    <td align="center">規費結餘</td>
        </tr>
        <tr>
		    <td align="center" class="whitetablebg"><%=ar_service%></td>
		    <td align="center" class="whitetablebg"><%=ar_fees%></td>
		    <td align="center" class="whitetablebg"><%=ar_tax_out%></td>
		    <td align="center" class="whitetablebg"><%=ar_tot_money%></td>
		    <td align="center" class="whitetablebg" style="BACKGROUND-COLOR: lightgreen"><%=fee_money%></td>
        </tr>
    </table>

<div id="dialog"></div>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "30%,70%";
        }
    });

    //查代理人請款記錄
    function dnlist_from() {
        //***todo
        var url = getRootPath() + "/btbrt/brtam/extform/dnlist_qry.aspx?prgid=<%=prgid%>&seq=<%=seq%>&seq1=<%=seq1%>&fromprg=accseq";
        window.open(url, "mydnlistwinN", "width=750px, height=550px, top=10, left=10, toolbar=no, menubar=no, location=no, directories=no, status=no,resizable=yes, scrollbars=yes");
    }
</script>
