<%@ Control Language="C#" ClassName="dmt_CR_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>

<script runat="server">
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;


    protected string submitTask = "";
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//功能權限代碼
    protected string SQL = "";

    protected string html_pr_scode="",html_send_sel = "", html_pay_times = "";

    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        submitTask = (Request["submittask"] ?? "").Trim().ToUpper();

        SQL = "select a.scode,b.sc_name,a.sort ";
        SQL += " from sysctrl.dbo.scode_roles a ";
        SQL += " inner join sysctrl.dbo.scode b on a.scode=b.scode ";
        SQL += " where a.dept = '" + Session["dept"] + "' and syscode = '" + Session["syscode"] + "' and prgid = 'brta21' ";
        SQL += " and roles = 'process' and branch = '" + Session["seBranch"] + "' ";
        SQL += " order by sort ";
        DataTable prDT = new DataTable();
        conn.DataTable(SQL, prDT);
        html_pr_scode = prDT.Option("{scode}", "{scode}_{sc_name}", "", false, "", "sort=01");
        html_send_sel = Sys.getCustCode("SEND_SEL", "", "cust_code").Option("{cust_code}", "{code_name}");
        html_pay_times = Sys.getCustCode(Sys.GetSession("dept") + "PAY_TIMES", "", "sortfld").Option("{cust_code}", "{code_name}");

        PageLayout();
        this.DataBind();
    }

    private void PageLayout() {
        if (submitTask == "Q" || submitTask == "D") {
            Lock["Qdisabled"] = "Lock";
            Lock["Qdisabled_opt"] = "Lock";
        }
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<TABLE id=tabbr style="display:" border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
	<TR>
		<TD align=center colspan=6 class=lightbluetable1><font color=white>收&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>進度序號：</TD>
		<TD class=whitetablebg>
			<input type="text" id="closewin" name="closewin" value="N">
			<input type="text" id="code" name="code"><!--todo.sqlno-->
			<input type="text" id="in_no" name="in_no">
			<input type="text" id="in_scode" name="in_scode">
			<input type="text" id="change" name="change">
			<input type="text" id="cust_area1" name="cust_area1">
			<input type="text" id="cust_seq1" name="cust_seq1">
			<input type="text" id="rs_no" name="rs_no">
			<input type="text" id="nstep_grade" name="nstep_grade" size="2" class="SEdit" readonly>
			<input type="text" id="cgrs" name="cgrs">
			<select id=scgrs name=scgrs class="<%=Lock.TryGet("Qdisabled")%>">
				<option value="CR">客收</option>
			</select>
		</TD>
		<TD class=lightbluetable align=right>收文日期：</TD>
		<TD class=whitetablebg ><input type="text" id="step_date" name="step_date" size="10" class="dateField <%=Lock.TryGet("Qdisabled")%>"></TD>
		<TD class=lightbluetable align=right>來文字號：</TD>
		<TD class=whitetablebg ><input type="text" id="receive_no" name="receive_no" size=20 maxlength=20 class="<%=Lock.TryGet("Qdisabled")%>"></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>收文代碼：</TD>
		<TD class=whitetablebg colspan=5>結構分類：
			<input type="text" name="rs_type" id="rs_type">
			<span id=span_rs_class>
			<input type="text" name="hrs_class" id="hrs_class">
			<select name="rs_class" id="rs_class"  class="Lock"></select>
			</span>
			案性代碼：
			<span id=span_rs_code>
				<input type="text" name="hrs_code" id="hrs_code">
				<select name="rs_code" id="rs_code" class="Lock">
				</select>
			</span><br>
			處理事項：
			<input type="text" name="act_sqlno" id="act_sqlno">
			<span id=span_act_code>
				<input type="text" name="hact_code" id="hact_code">
				<select name="act_code" id="act_code" class="Lock">
				</select>
			</span>
			&nbsp;&nbsp;&nbsp;&nbsp;本次狀態：
			<input type="text" name="ocase_stat" id="ocase_stat">
			<input type="text" name="ncase_stat" id="ncase_stat">
			<input type="text" name="ncase_statnm" id="ncase_statnm" size="10" class="Lock">
		</TD>
    </TR>
    <TR>
		<TD class=lightbluetable align=right>收文內容：</TD>
		<TD class=whitetablebg colspan=5><input type="text" name="rs_detail" id="rs_detail" size=60 class="<%=Lock.TryGet("Qdisabled")%>"></TD>
	</TR>
    <TR>
		<TD class=lightbluetable align=right>附件：</TD>
		<TD class=whitetablebg colspan=5><input type="text" name="doc_detail" id="doc_detail" size=60 maxlength=60 class="<%=Lock.TryGet("Qdisabled")%>"></TD>
	</tr>
	<TR>
		<TD class=lightbluetable align=right>承辦：</TD>
		<TD class=whitetablebg colspan=3>
			<SELECT name="pr_scode" id="pr_scode" class="<%=Lock.TryGet("Qdisabled")%>">
			<%=html_pr_scode%><option value="" style="color:blue">不需承辦</option>
			</SELECT>
		</TD>
		<TD class=lightbluetable align=right>官方號碼：</TD>
		<TD class=whitetablebg>
			<SELECT name=send_sel id=send_sel class="<%=Lock.TryGet("Qdisabled")%>"><%=html_send_sel%></SELECT>
		</TD>		
	</TR>
	<TR id="show_optstat" style="display:none">
		<TD class=lightbluetable align=right><font color=darkblue>※爭救案交辦：</font></TD>
		<TD class=whitetablebg colspan=5>
			<input type=radio name="opt_stat" value="N" class="<%=Lock.TryGet("Qdisabled_opt")%>">需交辦
			<input type=radio name="opt_stat" value="X" class="<%=Lock.TryGet("Qdisabled_opt")%>">不需交辦				
			<span id="sp_optstat" style="display:none">
			<input type=radio name="opt_stat" value="Y" class="<%=Lock.TryGet("Qdisabled_opt")%>">已交辦
			</span>
		</TD>
	</tr>
	<%if(prgid == "brt51"){%>	
	    <tr id="show_paytimes" style="display:none">
			    <td class="lightbluetable" align="right">註冊費繳納：</td>
			    <td class="whitetablebg" colspan=3 >
	   			    <Select NAME=pay_times id=pay_times class="<%=Lock.TryGet("Qdisabled")%>"><%=html_pay_times%>
				    </SELECT>						
			    </td>
			    <td class="lightbluetable"  align="right">繳納日期：</td>
			    <td class="whitetablebg"><input type="text" name="pay_date" id="pay_date" size="10" class="dateField <%=Lock.TryGet("Qdisabled")%>"></td>
	    </tr>
	    <TR id="show_endstat" style="display:none">
		    <TD class=lightbluetable align=right><font color=darkblue>結案處理：</font></TD>
		    <TD class=whitetablebg colspan=5>
			    <input type=radio name="end_stat" value="B61" class="<%=Lock.TryGet("Qdisabled")%>" onclick="vbscript: end_stat_onclick">送會計確認
			    <input type=radio name="end_stat" value="B6" class="<%=Lock.TryGet("Qdisabled")%>" onclick="vbscript: end_stat_onclick">待結案處理				
		    </TD>
	    </tr>
	<%}%>
	<TR><!--20160923 增加維護發文方式-->
		<TD class=lightbluetable align=right>發文方式：</TD>
		<TD class=whitetablebg colspan=5><input type="text" id="old_send_way" name="old_send_way">
		<SELECT id="send_way" name="send_way"></select>
		</TD>
	</TR>
	<%if(prgid=="brta22"){%>
	    <TR><!--20160923 增加維護發文方式-->
		    <!--20180712 增加客收維護可修改收據種類-->
		    <TD class=lightbluetable align=right>官發收據種類：</TD>
		    <TD class=whitetablebg><input type="text" id="old_receipt_type" name="old_receipt_type">
			    <select id="receipt_type" name="receipt_type">
				    <option value="" style="color:blue">請選擇</option>
				    <option value="P">紙本收據</option>
				    <option value="E">電子收據</option>
			    </select>
		    </TD>
		    <TD class=lightbluetable align=right>收據抬頭：</TD>
		    <TD class=whitetablebg colspan=3><input type="text" id="old_receipt_title" name="old_receipt_title">
			    <select id="receipt_title" name="receipt_title">
				    <option value="" style="color:blue">請選擇</option>
				    <option value="A">案件申請人</option>
				    <option value="B">空白</option>
				    <option value="C">案件申請人(代繳人)</option>
			    </select>
		    </TD>
	    </TR>
	<%}%>
</table>
<input type="text" name=tot_num id=tot_num value=0><!--一案多件筆數-->
<TABLE id=tabar1 style="display:none" border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
	<TR>
		<TD class=whitetablebg colspan=7><span id="span_seqdesc">此次變更本所編號：</span></TD>
	</TR>
	<TR align=center class=lightbluetable>
		<TD></TD><TD class="rs_code_FD">本所編號</TD><td>商標種類</TD><TD>類別</TD><TD>商標/案件名稱</TD>
		<TD><span id="span_no">申請號</span></TD>
	</TR>
</table>

<script language="javascript" type="text/javascript">
    var cr_form = {};

    cr_form.init = function () {
    }

    cr_form.bind = function () {
        if ($("#rs_code").val().Left(2) == "FD") $(".rs_code_FD").hide();
    }

    //依rs_type帶結構分類
    $("#rs_type").change(function () {
        $("#rs_class").getOption({
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: {
                sql: "select cust_code,code_name from cust_code where code_type='" + $("#rs_type").val() + "' and mark is null " +
				      " and cust_code in (select rs_class from vcode_act where cg ='C' and rs = 'R') order by cust_code"
            },
            valueFormat: "{cust_code}",
            textFormat: "{code_name}"
        });
    });

    //依結構分類帶案性代碼
    $("#rs_class").change(function () {
        $("#rs_code").getOption({//案性代碼
            url: getRootPath() + "/ajax/json_rs_code.aspx",
            data: { cgrs: "CR", rs_type: $("#rs_type").val() },
            valueFormat: "{rs_code}",
            textFormat: "{rs_detail}",
            attrFormat: "vrs_class='{rs_class}'"
        });
    });

    //依案性帶處理事項
    $("#rs_code").change(function () {
        $("#act_code").getOption({//處理事項
            url: getRootPath() + "/ajax/json_act_code.aspx",
            data: { bcgrs: "CR", rs_class: $("#rs_class").val(), rs_code: $("#rs_code").val() },
            valueFormat: "{act_code}",
            textFormat: "{act_code_name}",
            attrFormat: "spe_ctrl='{spe_ctrl}'"
        });
        cr_form.setSendWay();
    });

    //20200701 增加顯示發文方式
    cr_form.setSendWay = function () {
        $("#send_way").getOption({//發文方式
            url: getRootPath() + "/ajax/json_sendway.aspx",
            data: { rs_type: $("#rs_type").val(), rs_code: $("#rs_code").val() },
            valueFormat: "{cust_code}",
            textFormat: "{code_name}"
        });
        $("#send_way option[value!='']").eq(0).prop("selected", true);
    };

    $("#step_date").blur(function () {
        ChkDate($(this)[0]);
    });

    //[增加一筆]
    cr_form.appendFile = function () {
        var fld = $("#uploadfield").val();

        if (main.prgid == "brt62" && main.submittask == "A") {//文件上傳作業
            if ($("#step_grade").val() == "0" && $("#" + fld + "_filenum").val() == "0") {
                var ans = confirm("對應進度0，是否確定將文件上傳至進度0？若不是進度0，請先點選「否」再點選「查詢」以重新選取對應進度後再上傳");
                if (ans == false) {
                    $("#btnquery").focus();
                    return false;
                }
            }
        }

        var nRow = CInt($("#" + fld + "_filenum").val()) + 1;//畫面顯示NO
        $("#maxattach_no").val(CInt($("#maxattach_no").val()) + 1);//table+畫面顯示 NO
        //複製樣板
        //$("#tabfile" + fld + ">tfoot").each(function (i) {
        //    var strLine1 = $(this).html().replace(/##/g, nRow);
        //    $("#tabfile" + fld + ">tbody").append(strLine1);
        //});
        var copyStr = $("#tabfile" + fld + ">#upload_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tabfile" + fld + ">tbody").append(copyStr);
        $("#" + fld + "_filenum").val(nRow);
        $("#attach_no_" + nRow).val($("#maxattach_no").val());//dmt_attach.attach_no

        if ($("#prgid").val() == "brta38") {
            $("#span_source_" + nRow).show();//原始檔名
        }
        if ($("#uploadsource").val() == "CASE") {
            $("#span_branch_" + nRow).show();//交辦專案室
        } else {
            //不是發文畫面會出錯,增加判斷
            if (document.getElementsByName("cgrs").length > 0 && document.getElementById("cgrs").value == "GS") {
                $("#span_edoc_" + nRow).show();//電子送件文件檔
            }
        }
    }

    //[減少一筆]
    cr_form.deleteFile = function () {
        var fld = $("#uploadfield").val();
        var tfilenum = CInt($("#" + fld + "_filenum").val());//畫面顯示NO
        if (tfilenum > 0) {
            if ($("#" + fld + "_name_" + tfilenum).val() == "") {
                $(".tr_brattach_" + tfilenum).remove();
                $("#" + fld + "_filenum").val(Math.max(0, tfilenum - 1));
            } else {
                //檔案已存在要刪除
                if (cr_form.DelAttach(tfilenum) == true) {
                    //先不刪除,而是使用隱藏方式
                    $(".tr_brattach_" + tfilenum).hide();
                }
            }
        }
    }

    //檔案說明
    cr_form.getfiledoc = function (nRow) {
        var fld = $("#uploadfield").val();
        if ($("#doc_type_" + nRow).val() == "") {
            $("#doc_type_mark_" + nRow).val("");
            return false;
        }

        var dname = $("#" + fld + "_desc_" + nRow).val().trim();
        if (dname != "") dname += "、";
        dname += $("#doc_type_" + nRow + " :selected").text();
        $("#" + fld + "_desc_" + nRow).val(dname);

        //抓取文件種類之mark1說明，for電子送件copy時用原始檔名或更名
        $("#doc_type_mark_" + nRow).val($("#doc_type_" + nRow + " :selected").attr("v1"));
    }
</script>
