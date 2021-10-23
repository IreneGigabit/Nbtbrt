<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = " 聯絡人職代/副本信箱設定";//功能名稱
    protected string HTProgPrefix = "cust24";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string FormName = "";
    protected string StrSaveBtn = "";
    protected string StrResetBtn = "";
    
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected string SQL = "";
    protected string submitTask = "";
    protected string json = "";
    protected string cust_area = "";
    protected string cust_seq = "";
    protected string dept = "";
    protected string syscode = "";

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
        
        //conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        conn = new DBHelper(Conn.brp(Sys.GetSession("seBranch"))).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.Sysctrl).Debug(Request["chkTest"] == "TEST");
        
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");

        dept = Sys.GetSession("dept");
        if (dept == "P")
        {
            syscode = "BRP"; 
        }
        else if (dept == "T")
        {
            syscode = "BTBRT"; 
        }
        else
        {
            syscode = "ACC";
        }
        
        cust_area = Sys.GetSession("seBranch");
        submitTask = ReqVal.TryGet("submitTask").ToUpper();
        
        if (submitTask == "A") cust_seq = "";
        else cust_seq = Request["cust_seq"]; 
        
        dept = Sys.GetSession("dept");
        
        if (submitTask == "A") HTProgCap = HTProgCap + "-<font color=blue>新增</font>";
        if (submitTask == "U") HTProgCap = HTProgCap + "-<font color=blue>維護</font>";
        if (submitTask == "Q") HTProgCap = HTProgCap + "-<font color=blue>查詢</font>";

        
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

        if ((HTProgRight & 2) > 0)
        {
            if (submitTask == "U")
            {
                //StrFormBtnTop += "<a href=\"javascript:window.history.back();\" >[回清單]</a>\n";
            }
            StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        }

        if (((HTProgRight & 4) > 0 && (submitTask == "A")) || ((HTProgRight & 8) > 0 && (submitTask == "U")) ||
            ((HTProgRight & 8) > 0 && (submitTask == "A" || submitTask == "U" || submitTask == "C")) || (HTProgRight & 256) > 0)
        {
            if (submitTask == "Q") { }
            else
            {
                StrSaveBtn = "<input type=\"button\" id=\"btnSave\" value =\"存　檔\" class=\"cbutton bsubmit\"  />";//****class增加bsubmit.存檔時會控制鎖定.防止連點
                StrResetBtn = "<input type=\"button\" id=\"btnReset\" value =\"重　填\" class=\"cbutton\" />";
            }
        }
    }


</script>
<style>
    input[type=checkbox] {
    vertical-align:middle;
    }
</style>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
    <meta http-equiv="x-ua-compatible" content="IE=10">
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【cust24_Edit <%=HTProgCap%>】
            &nbsp;&nbsp;<span id="span_rs_no"></span>
            <span id="span_scodenm"></span>
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
<INPUT TYPE="hidden" id="prgid" name="prgid" value="<%=prgid%>">
<INPUT TYPE="hidden" id="submitTask" name=submitTask value="<%=submitTask%>">
<input type="hidden" id="dept" name="dept" value="<%=dept%>" />

    <table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td>
            <table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
			<TR>
				<TD class=lightbluetable align=right>客戶編號：</TD>
				<TD class=whitetablebg>
					<INPUT type="text" class="SEdit" readOnly="readonly" size="3" value="<%=cust_area%>" id="cust_area" name="cust_area">-
					<INPUT type="text" size="6" value="<%=cust_seq%>" id="cust_seq" name="cust_seq">
					<INPUT type="button" class="cbutton" style="display:none" value=確定 id="btncust">
					<INPUT type="hidden" id=apsqlno name=apsqlno>
					<INPUT type="hidden" id=apcust_no name=apcust_no>
					<INPUT type="hidden" id=now_cust_seq name=now_cust_seq>
				</TD>
				<TD class=lightbluetable align=right>專利營洽：</TD>
				<TD class=whitetablebg>
					<INPUT type="text" class=SEdit readOnly size=5 id=pscode name=pscode>-
					<INPUT type="text" class=SEdit readOnly size=10 id=pscodenm name=pscodenm>
				</TD>
			</TR>
			<TR>
				<TD class=lightbluetable align=right>客戶名稱：</TD>
				<TD class=whitetablebg>
					<INPUT class=SEdit readOnly size=47 id="ap_cname" name="ap_cname">
				</TD>
				<TD class=lightbluetable align=right>商標營洽：</TD>
				<TD class=whitetablebg>
					<INPUT type="text" class=SEdit readOnly size=5 id=tscode name=tscode>-
					<INPUT type="text" class=SEdit readOnly size=10 id=tscodenm name=tscodenm>
				</TD>
			</TR>
		    </table>
            </td>
    </tr>
    <tr>
        <td>
        <input type="hidden" id="hmail_sql" name="hmail_sql" value=""><!--筆數-->
		<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
			<TR class=whitetablebg>
				<TD class=lightbluetable1 style="color:#ffffff" align=center colspan=5>
					副　本　信　箱　設　定
				</TD>
			</TR>
			<TR>
				<TD class=whitetablebg align=center>
					<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" id="maillist">
					<TFOOT>
						<TR class=whitetablebg>
							<TD colspan=9>
								<INPUT type="button" id="AddMail_button" class=cbutton  value=增加信箱設定 onclick="AddMailSetting()">
							</TD>
						</TR>
					</TFOOT>
					<THEAD>
						<TR>
							<TD class=lightbluetable align=center width=5%>刪除</TD>
							<TD class=lightbluetable align=center width=15%>系統單位<HR style="border:1px;">聯絡人</TD>
							<TD class=lightbluetable align=center>設定內容</TD>
							<TD class=lightbluetable align=center width=10%>最後異動</TD>
						</TR>
                        <script type="text/html" id="mail_template"><!--設定樣板-->
						<TR class=sfont9  id="tr_rpt_##">
							<TD class=whitetablebg align=center>##.
								<input type="checkbox" id="mail_del_##" name="mail_del_##" value="Y">
								<INPUT type="hidden" id="mail_upd_flag_##" name="mail_upd_flag_##">
							</TD>
							<TD class=whitetablebg align=center>
								<input TYPE="radio" NAME="mail_syscode_##" id="mail_syscode_##_BRP" value="BRP"><label for="mail_syscode_##_BRP">專利</label>
								<input TYPE="radio" NAME="mail_syscode_##" id="mail_syscode_##_BTBRT" value="BTBRT"><label for="mail_syscode_##_BTBRT">商標</label>
								<input TYPE="radio" NAME="mail_syscode_##" id="mail_syscode_##_ACC" value="ACC"><label for="mail_syscode_##_ACC">會計</label>
								<HR style="border:1px;">

                                <SELECT id="mail_mark_type2_##" name="mail_mark_type2_##" size=1>
								<option value="TO">正本</option>
								<option value="CC">副本</option>
								</SELECT>
								<SELECT id="mail_att_sql_##" name="mail_att_sql_##" size=1>
								</SELECT>
								<BR><br />
								<input type="checkbox" NAME="mail_spe_mark_##" id="mail_spe_mark_##_Y" value="Y"><label for="mail_spe_mark_##_Y">不寄</label>
								<INPUT type="hidden" id=o_mail_syscode_##>
								<INPUT type="hidden" id=o_mail_mark_type2_##>
								<INPUT type="hidden" id=o_mail_att_sql_##>
								<INPUT type="hidden" id=o_mail_spe_mark_##>
								<INPUT type="hidden" id=mail_spe_mark_value_##>
							</TD>
							<td>
								<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
									<TR>
										<TD class=lightbluetable align=right width="130">代理Email(正本)：</TD>
										<TD class="whitetablebg">
											<INPUT type="text" size=10 id="mail_type_content1_##" name="mail_type_content1_##" style="width:100%" onblur="ChkEmail(this)">
											<INPUT type="hidden" id="o_mail_type_content1_##" name="o_mail_type_content1_##">
										</TD>
									</TR>
									<TR>
										<TD class=lightbluetable align=right width="130">代理Email(副本)：</TD>
										<TD class="whitetablebg">
											<INPUT type="text" size=10 id="mail_type_content2_##" name="mail_type_content2_##" style="width:100%" onblur="ChkEmail(this)">
											<INPUT type="hidden" id="o_mail_type_content2_##" name="o_mail_type_content2_##">
										</TD>
									</TR>
									<TR>
										<TD class=lightbluetable align=right>備註說明：</TD>
										<TD class="whitetablebg">
											<textarea rows="3" id="mail_type_content3_##" name="mail_type_content3_##" style="width:100%"></textarea>
											<textarea id="o_mail_type_content3_##" name="o_mail_type_content3_##" style="display:none"></textarea>
										</TD>
									</TR>
									<TR>
										<TD class=lightbluetable align=right>代理日期：</TD>
										<TD class="whitetablebg">
                                            <input type="text" name="mail_open_date_##" id="mail_open_date_##" size="10" readonly="readonly" class="dateField">
											~
                                            <input type="text" name="mail_end_date_##" id="mail_end_date_##" size="10" readonly="readonly" class="dateField">
											<INPUT type="hidden" id="o_mail_open_date_##">
											<INPUT type="hidden" id="o_mail_end_date_##">
										</TD>
									</TR>
								</table>
							</td>
							<td align=center>
								<span id="mail_tran_date_##"></span><BR>
							    <span id="mail_tran_scodenm_##"></span>
							    <INPUT type="hidden" id="mail_mark_sqlno_##" name="mail_mark_sqlno_##">
							</td>
						</TR>
                        </script>
					</THEAD>
					<TBODY>
					</TBODY>
					</table>
				</td>
			</TR>
		</table>
        </td>
    </tr>
    </table>

    <%#DebugStr%>
</form>

<table border="0" width="98%" cellspacing="0" cellpadding="0">
<tr class="FormName"><td><div align="left" style="color:blue"><%#FormName%></div></td></tr>
</table>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="500" style="display:none"></iframe>
<table border="0" width="100%" cellspacing="0" cellpadding="0">
    <tr>
        <td width="100%" align="center">
            <%#StrSaveBtn%>
            <%#StrResetBtn%>                    
        </td>
    </tr>
</table>
<div>
　※副本信箱設定 :<BR>
　－「系統單位」依系統對應開放勾選,其餘鎖定
</div>
<div id="dialog"></div>

</body>
</html>

<script type="text/javascript">

    var bMailData = true;
    var nMail=0;//設定計數
    $(function () {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "0%,100%";
        }

        if($("#submitTask").val() == "A") {
            $("#cust_seq").val('');
        }
        else {
            loadData();
        }

    });

    function this_init() {
	
        //還原原始狀態
        $("#submitTask").val("<%=submitTask%>");
        $("#cust_seq").val("<%=cust_seq%>");
        $("#now_cust_seq").val("<%=cust_seq%>");
        $("#apsqlno").val("");
        $("#apcust_no").val("");
        $("#ap_cname").val("");
        $("#pscode").val("");
        $("#pscodenm").val("");
        $("#tscode").val("");
        $("#tscodenm").val("");

        nMail = 0;
        $("#hmail_sql").val("0");
        $("#maillist>tbody tr").remove();
    }

    function loadData() {

        loadCustData();
        loadMailSettingData();
        if ($("#submitTask").val() != "A") {
            $("#cust_seq").lock();

            if ($("#submitTask").val() == "Q") {
                SetMailReadOnly();
            }

        }
        else { }//如果是新增
    }


    //檢查有改過客編則要重新載入
    $("#cust_seq").on("blur",function(){
        if($("#now_cust_seq").val()!=$(this).val()){
            //$("#btncust").click();
            loadData();
            if (bMailData == true) {
                alert("此客戶已有設定備註,系統將載入目前設定!");
            }
        }
    })


    //新增一筆
    function AddMailSetting() {
        if ($.trim($("#cust_seq").val())==""){
            alert("請輸入客戶編號，才可新增 !!!");
            return false;
        }

        nMail++;
        $("#hmail_sql").val(nMail);
        //var strLine1 = "<tr class=sfont9 id='tr_rpt_"+nMail+"'>" + $("#maillist>thead tr").eq(1).html().replace(/##/g, nMail) + "</tr>";
        var strLine1 = $("#mail_template").text() || "";
        strLine1 = strLine1.replace(/##/g, nMail);
        $("#maillist>tbody").append(strLine1);
	
        //預設單位部門可選項目
        $("input[name='mail_syscode_"+nMail+"'][value='<%=syscode%>']").prop('checked', true).trigger("click");
        $("input[name='mail_syscode_"+nMail+"'][value!='<%=syscode%>']").prop('disabled', true);

        //帶對應的聯絡人清單
        //getAtt("#rpt_att_sql_"+nMail,"<%=syscode%>");
        GetCustatt(nMail, "mail_att_sql_", '<%=syscode%>', '<%=dept%>');
        $("input.dateField").datepick();
    }

    function GetCustatt(nRow, objID, syscode, dept) {
        var psql = "select att_sql, attention from custz_att where cust_area = '" + $("#cust_area").val() + "' and cust_seq = '" + $("#cust_seq").val() + "'";
        if (syscode != "ACC") {
            psql += " and dept = '" + dept + "'";
        }
        if ('<%=submitTask%>' == 'A') {
            psql += " and (att_code like 'N%' or att_code='' or att_code is null)";
        }

        //#mail_att_sql_, 
        $("#" + objID + nRow).getOption({//種類
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: { sql: psql },
            showEmpty: false,//顯示"請選擇"
            valueFormat: "{att_sql}",//option的value格式,用{}包住欄位,ex:{scode}
            textFormat: "{att_sql}---{attention}",//option的文字格式,用{}包住欄位,ex:{scode}_{sc_name}
            //firstOpt: "<option value='0'>不指定</option>",//要在最上面額外增加option,ex:<option value='*'>全部<option>
            //setValue: "0"//預設值
        });
        if ($("#" + objID + nRow)[0] != undefined) {
            $("#" + objID + nRow).get(0).selectedIndex = 0;
        }
        
    }

    
    function loadMailSettingData() {
        var psql = "select *, convert(varchar,m.tran_date,120)trandate, ";
        psql += "convert(varchar,m.end_date,111)enddate, convert(varchar,m.open_date,111)opendate, ";
        psql += "(select sc_name from sysctrl.dbo.scode s where m.tran_scode=s.scode) tran_scodenm ";
        psql += "from apcust_mark m where mark_type='cmark_mail' ";
        psql += "and cust_area='" + $("#cust_area").val() + "' and cust_seq='" + $("#cust_seq").val() + "' ";
        psql += "order by mark_sqlno";

        <%--if ($("#submitTask").val() == "U") {//編輯模式只顯示單筆
            psql += " and mark_sqlno='<%=Request["mark_sqlno"]%>'";
        }--%>

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {
                    $.each(JSONdata, function (i, item) {
                        AddMailSetting();//新增一行
                        //$row=$(this);
                        var rSyscode=item.syscode;
                        var rSpe_mark=item.spe_mark;
                        $("input[name='mail_syscode_" + nMail + "'][value='" + rSyscode + "']").prop('checked', true).trigger("click");
                        if ("<%=syscode%>" == rSyscode) {
                            $("input[name='mail_syscode_" + nMail + "'][value='" + rSyscode + "']").prop('disabled', false);
                        } else {
                            $("input[name='mail_syscode_" + nMail + "']").prop('disabled', true);
                        }
                        $("#o_mail_syscode_" + nMail).val(rSyscode);
                        if (rSpe_mark == "Y") {
                            $("input[name='mail_spe_mark_" + nMail + "'][value='Y']").prop('checked', true);
                        } else {
                            $("input[name='mail_spe_mark_" + nMail + "'][value='Y']").prop('checked', false);
                        }
                        $("#o_mail_spe_mark_" + nMail).val(rSpe_mark);

                        //帶對應的聯絡人清單-清空重放
                        $("#mail_att_sql_" + nMail).empty();
                        var d = "";
                        if (item.syscode == "BRP") {
                            d = "P"
                        } else if (item.syscode == "BTBRT") {
                            d = "T"
                        }
                        GetCustatt(nMail, "mail_att_sql_", item.syscode, d);
                        //getAtt("#mail_att_sql_" + nMail, rSyscode);
                        $("#mail_att_sql_" + nMail).val(item.att_sql);

                        
                        $("#mail_mark_type2_" + nMail).val(item.mark_type2);
                        $("#o_mail_mark_type2_" + nMail).val(item.mark_type2);
                        $("#o_mail_att_sql_" + nMail).val(item.att_sql);
                        $("#mail_type_content1_" + nMail).val(item.type_content1);
                        $("#o_mail_type_content1_" + nMail).val(item.type_content1);
                        $("#mail_type_content2_" + nMail).val(item.type_content2);
                        $("#o_mail_type_content2_" + nMail).val(item.type_content2);
                        $("#mail_type_content3_" + nMail).val(item.type_content3);
                        $("#o_mail_type_content3_" + nMail).val(item.type_content3);
                        $("#mail_open_date_" + nMail).val(dateReviver(item.open_date, "yyyy/M/d"));
                        $("#o_mail_open_date_" + nMail).val(dateReviver(item.open_date, "yyyy/M/d"));
                        $("#mail_end_date_" + nMail).val(dateReviver(item.end_date, "yyyy/M/d"));
                        $("#o_mail_end_date_" + nMail).val(dateReviver(item.end_date, "yyyy/M/d"));
                        $("#mail_tran_date_" + nMail).html(item.trandate);
                        $("#mail_tran_scodenm_" + nMail).html(item.tran_scodenm);
                        $("#mail_mark_sqlno_" + nMail).val(item.mark_sqlno);
                        //不同單位鎖定
                        if(rSyscode!="<%=syscode%>")lockTr("mail_",nMail);
                    })

                    bMailData = true;
                }
                else {
                    bMailData = false;
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

    function lockTr(prefix,rNo){
        $("#tr_"+prefix+rNo+" select,#tr_"+prefix+rNo+" img,#tr_"+prefix+rNo+" textarea").prop('disabled', true);
        $("#tr_"+prefix+rNo+" input").prop('disabled', true);
    }

    function loadCustData() {

        var psql = "SELECT apsqlno,ap.apcust_no,c.cust_area,c.cust_seq,ap_cname1,ap_cname2,pscode,tscode, ";
        psql += "(select sc_name from sysctrl.dbo.scode where scode=c.pscode) as pscodenm, ";
        psql += "(select sc_name from sysctrl.dbo.scode where scode=c.tscode) as tscodenm, ";
        psql += "(select count(*) from apcust_mark m where m.cust_area = c.cust_area AND m.cust_seq = c.cust_seq and m.mark_type in('cmark_report','cmark_text')) as remarkcount, ";
        psql += "(select count(*) from apcust_mark m where m.cust_area = c.cust_area AND m.cust_seq = c.cust_seq and m.mark_type in('cmark_mail')) as mailcount, ";
        psql += "(select count(*) from apcust_attach t where t.cust_area = c.cust_area AND t.cust_seq = c.cust_seq and t.source='custz') as attachcount ";
        psql += "FROM custz c ";
        psql += "INNER JOIN apcust ap ON c.cust_area = ap.cust_area AND c.cust_seq = ap.cust_seq ";
        psql += "where 1=1 and c.cust_area = '" + $("#cust_area").val() + "' and c.cust_seq = '" + $("#cust_seq").val() + "'";
        psql += " order by c.cust_area,c.cust_seq desc";

        this_init();

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                
                var JSONdata = $.parseJSON(json);
                var item = JSONdata[0];
                if (JSONdata.length > 0) {

                    $("#cust_seq").val(item.cust_seq);
                    $("#now_cust_seq").val(item.cust_seq);
                    $("#apsqlno").val(item.apsqlno);
                    $("#apcust_no").val(item.apcust_no);

                    $("#ap_cname").val(item.ap_cname1+item.ap_cname2);
                    $("#pscode").val(item.pscode);
                    $("#pscodenm").val(item.pscodenm);
                    $("#tscode").val(item.tscode);
                    $("#tscodenm").val(item.tscodenm);
                    $("#apsqlno").val(item.apsqlno);
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


    function Save() {

        //標記update flag//////////////////////////////////////////////////////////////////////
        for (var r = 1; r <= nMail; r++) {
            $("#mail_upd_flag_" + r).val("");
            if ($("#mail_mark_sqlno_" + r).val() != "") {//有流水號表示DB有資料
                if ($("input[name=mail_syscode_" + r + "]:checked").val() != $("#o_mail_syscode_" + r).val()
                    || $("#mail_mark_type2_" + r).val() != $("#o_mail_mark_type2_" + r).val()
                    || $("#mail_att_sql_" + r).val() != $("#o_mail_att_sql_" + r).val()
                    //|| $("#mail_spe_mark_value_" + r).val() != $("#o_mail_spe_mark_" + r).val()//不寄
                    || NulltoEmpty($("input[name=mail_spe_mark_" + r + "]:checked").val()) != $("#o_mail_spe_mark_" + r).val()//不寄
                    || $("#mail_type_content1_" + r).val() != $("#o_mail_type_content1_" + r).val()
                    || $("#mail_type_content2_" + r).val() != $("#o_mail_type_content2_" + r).val()
                    || $("#mail_type_content3_" + r).val() != $("#o_mail_type_content3_" + r).val()
                    || $("#mail_open_date_" + r).val() != $("#o_mail_open_date_" + r).val()
                    || $("#mail_end_date_" + r).val() != $("#o_mail_end_date_" + r).val()
                    ) {
                    $("#mail_upd_flag_" + r).val("Y");
                }
            }
        }

        //資料檢查//////////////////////////////////////////////////////////////////////
        var errMsg="";
        var objMail = {},objTxt = {},objAttach = {};
	
        for (var r=1;r<=nMail;r++){

            if (!$("#mail_del_" + r).prop('checked')) {
                if ($("#mail_type_content1_" + r).val() == "" && $("#mail_type_content2_" + r).val() == "") {
                    errMsg += "行" + r + ". 須輸入代理Email\n";
                }

                var lineOpt = getJoinValue("#maillist>tbody input[name='mail_syscode_" + r + "']:checked,#mail_mark_type2_" + r + ",#mail_att_sql_" + r);
                if (objMail[lineOpt]) {
                    errMsg += "行" + r + ". 與 行" + objMail[lineOpt].idx + ". 選項重覆\n";
                } else {
                    objMail[lineOpt] = { flag: true, idx: r };
                }
            }

        }
        
        //計算異動筆數//////////////////////////////////////////////////////////////////////
        if(nMail == 0){
            errMsg+="無資料可存檔\n";
        }
	
        if (errMsg!=""){
            alert(errMsg);
            return false;
        }


        //****改用ajax,才不用處理update後導頁面
        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        ajaxByForm("cust24_Update.aspx",formData)
        .complete(function( xhr, status ) {
            $("#dialog").html(xhr.responseText);
            $("#dialog").dialog({
                title: '存檔訊息',modal: true,maxHeight: 500,width: 800,closeOnEscape: false
                ,buttons: {
                    確定: function() {
                        $(this).dialog("close");
                    }
                }
                ,close:function(event, ui){
                    if(status=="success"){
                        if(!$("#chkTest").prop("checked")){
                            window.parent.tt.rows="100%,0%";
                            window.parent.Etop.goSearch();//重新整理
                        }
                    }
                }
            });
        });
    }//Save



    $("#btnSave").click(function (e) {
        Save();
    });


    //[重填]
    $("#btnReset").click(function (e) {
        reg.reset();
        this_init();
        loadData();
    });

    function SetMailReadOnly() {
        $("input[type=checkbox][id^='mail_del_']").hide();
        $("#AddMail_button").hide();
        $("input[type=radio]").lock();
        $("select[id^='mail_mark_type2_']").lock();
        $("select[id^='mail_att_sql_']").lock();
        $("input[type=checkbox][id^='mail_spe_mark_']").lock();
        $(":text").lock();
        $("textarea").lock();
    }


    function ChkEmail(email) {
        if (email.value == undefined || email.value == "") { }
        else {
            if (IsEmail(email.value) == false) {
                alert("請填寫正確的E-MAIL格式");
                email.focus();
                return false;
            }
        }
    }


    



</script>
