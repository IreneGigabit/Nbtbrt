<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/brt1m/brtform/brt25_Form.ascx" TagPrefix="uc1" TagName="brt25_Form" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>



<script runat="server">
    protected string HTProgCap = HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt25";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string StrFormRemark = "";

    protected string SQL = "";
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected string submitTask = "";

    protected string seq = "";
    protected string seq1 = "";
    protected string case_no = "";
    protected string todo_sqlno = "";
    protected string from_flag = "";
    protected string scode1 = "";
    protected string in_no = "";
    protected string in_scode = "";

    protected string fseq = "";
    protected string cappl_name = "";
    protected string step_grade = "";
    protected string rs_detail = "";
    protected string cust_area = "";
    protected string cust_seq = "";
    protected string ap_cname = "";
    protected string apcust_name = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = (Request["submittask"] ?? "").Trim();
        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();
        case_no = (Request["case_no"] ?? "").Trim();
        todo_sqlno = (Request["todo_sqlno"] ?? "").Trim();
        from_flag = (Request["from_flag"] ?? "").Trim();
        scode1 = (Request["scode1"] ?? "").Trim();
        in_no = (Request["in_no"] ?? "").Trim();
        in_scode = (Request["in_scode"] ?? "").Trim();
 
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
        StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        if (submitTask=="A")
            HTProgCap+="-新增";
        else if (submitTask=="U")
            HTProgCap +="-修改";
      
        if (Sys.GetSession("dept")=="p")
            HTProgCap+="-專利";
        else if (Sys.GetSession("dept")=="t")
            HTProgCap +="-商標";

        if (submitTask != "Q") {
            if ((HTProgRight & 4) > 0 || (HTProgRight & 8) > 0) {
                StrFormBtn += "<input type=button value ='存　檔' id='button1' class='cbutton bsubmit' onclick='formAddSubmit()'>\n";
                StrFormBtn += "<input type=button value ='重　填' id='buttonr' class='cbutton' onclick='this_init()'>\n";
            }

            if ((HTProgRight & 256) != 0) {
                StrFormRemark+="<br />權限C備註";
		        StrFormRemark+="<br />※此作業可查詢契約書後補之交辦，並提供補入契約書號碼及契約書上傳，若為總契約書則需對應總契約書檔，";
		        StrFormRemark+="<br />　完成後系統將銷管契約書後補期限並將此筆交辦寫入「會計契約書檢核作業」，同時會EMAIL通知會計。";
            }
        }
    }

    private string QueryData() {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            if (prgid.ToLower().Left(3) == "brt") {
                SQL = "select scode as scode1,cust_area,cust_seq,appl_name as cappl_name ,'' as country ";
                SQL += ",(select sc_name from sysctrl.dbo.scode where scode=d.scode) as scode1nm";
                SQL += ",(select ap_cname1+isnull(ap_cname2,'') from apcust where cust_area=d.cust_area and cust_seq=d.cust_seq) as ap_cname";
                SQL += " from dmt d ";
                SQL += " where seq='"+seq+"' and seq1='"+seq1+"' ";
            } else if (prgid.ToLower().Left(3) == "ext") {
                SQL = "select scode as scode1,cust_area,cust_seq,appl_name as cappl_name ,country ";
                SQL += ",(select sc_name from sysctrl.dbo.scode where scode=d.scode) as scode1nm";
                SQL += ",(select ap_cname1+isnull(ap_cname2,'') from apcust where cust_area=d.cust_area and cust_seq=d.cust_seq) as ap_cname";
                SQL += " from ext d ";
                SQL += " where seq='" + seq + "' and seq1='" + seq1 + "' ";
            }
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            if (dt.Rows.Count > 0) {
                scode1 = dt.Rows[0].SafeRead("scode1", "");
                cust_area = dt.Rows[0].SafeRead("cust_area", "");
                cust_seq = dt.Rows[0].SafeRead("cust_seq", "");
                ap_cname = dt.Rows[0].SafeRead("ap_cname", "");
                cappl_name = dt.Rows[0].SafeRead("cappl_name", "");
                fseq = Sys.formatSeq(seq, seq1, dt.Rows[0].SafeRead("country", ""), Sys.GetSession("seBranch"), "T" + ((prgid.ToLower().Left(2) == "ex") ? "E" : ""));

                apcust_name = "";
                if (prgid.ToLower().Left(2) == "ex") {
                    SQL = "select * from ext_apcust where seq='" + seq + "' and seq1='" + seq1 + "' order by sqlno";
                    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                        while (dr.Read()) {
                            apcust_name += (apcust_name != "" ? "、" : "") + dr.SafeRead("apcust_no", "") + dr.SafeRead("ap_cname1", "") + dr.SafeRead("ap_cname2", "");
                        }
                    }
                } else {
                    SQL = "select * from dmt_ap where seq='" + seq + "' and seq1='" + seq1 + "' order by dmt_ap_sqlno";
                    using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                        while (dr.Read()) {
                            apcust_name += (apcust_name != "" ? "、" : "") + dr.SafeRead("apcust_no", "") + dr.SafeRead("ap_cname", "");
                        }
                    }
                }
            }

            if (prgid.ToLower().Left(3) == "brt") {
                SQL = "select step_grade,rs_detail from step_dmt ";
                SQL += " where seq='" + seq + "' and seq1='" + seq1 + "' and cg='C' and rs='R' ";
                SQL += " and case_no='" + case_no + "' ";
            } else if (prgid.ToLower().Left(3) == "ext") {
                SQL = "select step_grade,rs_detail from step_ext ";
                SQL += " where seq='" + seq + "' and seq1='" + seq1 + "' and cg='C' and rs='R' ";
                SQL += " and case_no='" + case_no + "' ";
            }
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    step_grade = dr.SafeRead("step_grade", "");
                    rs_detail = dr.SafeRead("rs_detail", "");
                }
            }

            
            var settings = new JsonSerializerSettings()
            {
                Formatting = Formatting.None,
                ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
                Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
            };

            return JsonConvert.SerializeObject(dt, settings).ToUnicode().Replace("\\", "\\\\").Replace("\"", "\\\"");
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.branch = "<%#Session["SeBranch"]%>";
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
    main.submittask = "<%#submitTask%>";
    jMain = {};
</script>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=HTProgCode%><%=HTProgCap%>】
        </td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<br>
<form id="reg" name="reg" method="post">
    <table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
	    <td width="100%" valign="top">
	        ※本所編號：<font color="blue"><%=fseq%></font>
	        &nbsp;&nbsp;&nbsp;※案件名稱：<font color="blue"><%=cappl_name%></font>
	        <br>※交辦單號：<font color="blue"><%=scode1%>-<%=case_no%></font>
	        &nbsp;&nbsp;&nbsp;※進度：<font color="blue"><%=step_grade%>&nbsp;&nbsp;<%=rs_detail%></font>
	        <br>※客戶：<font color="blue"><%=cust_area%>-<%=cust_seq%>&nbsp;<%=ap_cname%></font>
	        <br>※申請人：<font color="blue"><%=apcust_name%></font>	
        </td>
    </tr>
    <tr>
        <td>
            <uc1:brt25_Form runat="server" ID="brt25_Form" />
        </td>
    </tr>
    </table>
	<input type="text" id="prgid" name="prgid" value="<%=prgid%>">
	<input type="text" id="submittask" name="submittask" value="<%=submitTask%>">
	<input type="text" id="seq" name="seq" value="<%=seq%>">
	<input type="text" id="seq1" name="seq1" value="<%=seq1%>">
	<input type="text" id="case_no" name="case_no" value="<%=case_no%>">
	<input type="text" id="step_grade" name="step_grade" value="<%=step_grade%>">
	<input type="text" id="todo_sqlno" name="todo_sqlno" value="<%=todo_sqlno%>">
	<input type="text" id="from_flag" name="from_flag" value="<%=from_flag%>">
	<input type="text" id="scode1" name="scode1" value="<%=scode1%>">
	<input type="text" id="in_no" name="in_no" value="<%=in_no%>">
	<input type="text" id="in_scode" name="in_scode" value="<%=in_scode%>">
	<input type="text" id="fseq" name="fseq" value="<%=fseq%>">
	<input type="text" id="cappl_name" name="cappl_name" value="<%=cappl_name%>">
	<input type="text" id="cust_seq" name="cust_seq" value="<%=cust_seq%>">

    <%#DebugStr%>
    <table border="0" width="98%" cellspacing="0" cellpadding="0">
    <tr>
        <td width="100%" align="center">
            <%#StrFormBtn%>
        </td>
    </tr>
    </table>
</form>
<div align=left style="font-size:10pt;color:blue" class="haveData">
    <%#StrFormRemark%>
</div>


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

        if(main.submittask=="A"||main.submittask=="C"){
            window.parent.tt.rows = "0%,100%";
            if(main.submittask=="C"){
                $("#button1").val("取消後補送會計檢核");
                $("#buttonr").hide();
            }
        }else if(main.submittask=="U"||main.submittask=="Q"){
            window.parent.tt.rows = "30%,70%";
        }else if(main.submittask=="D"){
            window.parent.tt.rows = "30%,70%";
            $("#button1").val("契約書已上傳，不需後補");
            $("#buttonr").hide();
            $("select,textarea,input,span").lock();
        }

        $("input.dateField").datepick();
        $(".Lock").lock();
    }
    
    //存檔
    function formAddSubmit(){
        $.maskStart();
        var saveflag=main.savechk();
        $.maskStop();

        if(!saveflag) return false;

        $("#tfy_case_stat").val("NN");//新案
        $("#submittask").val("Add");

        $("select,textarea,input,span").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        $.ajax({
            url:'<%=HTProgPrefix%>AddA11_Update.aspx',
            type : "POST",
            data : formData,
            contentType: false,
            cache: false,
            processData: false,
            beforeSend:function(xhr){
                $("#dialog").html("<div align='center'><h1>存檔中...</h1></div>");
                $("#dialog").dialog({ title: '存檔訊息', modal: true,maxHeight: 500,width: 800,buttons:[] });
            },
            //success: function (data, status, xhr) { main.onSuccess(data, status, xhr); },
            //error: function (xhr, status) { main.onError(xhr, status); },
            complete: function (xhr, status) {
                $("#dialog").html(xhr.responseText);
                $("#dialog").dialog({ title: '存檔訊息', modal: true,maxHeight: 500,width: "90%" });
            }
        });

        //reg.action = "<%=HTProgPrefix%>AddA11_Update.aspx";
        //if($("#chkTest").prop("checked"))
        //    reg.target = "ActFrame";
        //else
        //    reg.target = "_self";
        //reg.submit();
    }
</script>
