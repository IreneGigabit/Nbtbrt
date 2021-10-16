<%@ Control Language="C#" ClassName="cust22Form" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace = "System.Text"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/cust/impForm/cust221Form.ascx" TagPrefix="uc1" TagName="cust221Form" %>

<script runat="server">
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    //區所名稱
    protected string html_BranchCode = Sys.getBranchCode().Option("{branch}", "{branch}_{branchname}");
    //公司別
    protected string html_company = Sys.getCustCode("con_comp", "", "sortfld").Option("{cust_code}", "{code_name}");
    //國別
    protected string html_country = Sys.getCountry().Option("{coun_code}", "{coun_code}_{coun_c}");
    //接洽人員
    protected string html_signscode = Sys.getCustScode("A", Sys.GetSession("dept"), 0, "").Option("{scode}", "{scode}_{sc_name}");
    //附件說明
    protected string html_doctype = Sys.getCustCode("apdoc", " and mark='B' ", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    //國內案出名代理人
    protected string html_Agent = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}");
    
    protected string html_dept = "";
    protected string seBranch = "";
    protected string dept = "";
    public string uploadfield = "attach";
    public string uploadsource = "";
    
    
    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        //foreach (var item in ReqVal)
        //{
        //    Response.Write(item.Key + "," + item.Value);
        //}
        seBranch = Sys.GetSession("seBranch");
        dept = Sys.GetSession("dept");
        
        if (Sys.GetSession("dept") == "P")
        {
            html_dept = "<option value='P'>專利國內案</option>";
            html_dept += "<option value='PE'>專利出口案</option>";
        }
        else
        {
            html_dept = "<option value='T'>商標國內案</option>";
            html_dept += "<option value='TE'>商標出口案</option>";
        }
        
        prgid = Request["prgid"].ToString();
    }
    
    
</script>


<TABLE id=tabcontract name=tabcontract style="display:" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<TR id="tr_contract_no">
		<TD class="lightbluetable" align=right>委任書編號：</TD>
		<TD class=whitetablebg colspan=3>
            <%--<INPUT TYPE="hidden" name=apattach_sqlno id="apattach_sqlno">--%>
			<input type="text" name="contract_no" id="contract_no" size=11 maxlength=10 class=SEdit readonly>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>委任書種類：</TD>
		<TD class=whitetablebg>
			<input type="radio" name="sign_flag" value="S" >單一申請人簽署
			<input type="radio" name="sign_flag" value="M" >多個申請人合併簽署
		</TD>
		<TD class=lightbluetable align=right>單位部門：</TD>
		<TD class=whitetablebg>
		    <select name="cust_area" id="cust_area" size=1 disabled>
		    <%=html_BranchCode%>
		    </select>
		    <select name="dept" id="dept" size="1" onchange="cust22form.DeptChange()">
		       <option value="">請選擇</option>
                <%=html_dept%>
		    </select>
		    <span id="span_country"></span>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>特定國別：</TD>
		<TD class=whitetablebg>
			<select name="country" id="country" tabindex="1">
				<%=html_country%>
			</select>
		</TD>
		<TD class=lightbluetable align=right>狀態：</TD>
		<TD class=whitetablebg>
			<input type="radio" name="attach_flag" value="U" >使用中
			<input type="radio" name="attach_flag" value="E" >停用
			<span id="span_stop_remark" style="display:none">
			    <br>
			    原因：<input type="text" name="stop_remark" id="stop_remark" size=30 maxlength=100>
			</span>
		</TD>
	</TR>
	<TR>
		<td class=lightbluetable align=right nowrap>國內案出名代理人：</td>
		<td class=whitetablebg colspan=3>
			<select name="agt_no" id="agt_no">
                <%=html_Agent%>
			</select>
		</TD>
	</TR>
	<TR>
		<td class=lightbluetable align=right nowrap>出口案代理人：</td>
		<td class=whitetablebg colspan=3>
			<INPUT TYPE="text" NAME="agent_no" id="agent_no" SIZE="4" MAXLENGTH="4" class="InputNumOnly" value="" onblur="cust22form.agent_onblur()" >-
			<INPUT TYPE="text" NAME="agent_no1" id="agent_no1" SIZE="1" MAXLENGTH="1" value="_" onblur="cust22form.agent_onblur()" >-
			<INPUT TYPE=text NAME="agent_coun" id="agent_coun" SIZE=2 value="" class=SEdit readonly >
			<INPUT TYPE=text NAME="agent_na" id="agent_na" SIZE=60 value="" class=SEdit readonly >
		</td>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>有效期間：</TD>
		<TD class=whitetablebg>
		    <input type="text" name="use_sdate" id="use_sdate" size="10" readonly="readonly" class="dateField">～
		    <input type="text" name="use_edate" id="use_edate" size="10" readonly="readonly" class="dateField">
		</TD>
		<TD class=lightbluetable align=right>接洽人員：</TD>
		<TD class=whitetablebg>
		    <select name="sign_scode" id="sign_scode" size="1" >
                <%=html_signscode%>
		    </select>
		</TD>
	</TR>
	<TR>
		<td class="whitetablebg" colspan="4">
            <uc1:cust221Form runat="server" ID="cust221Form" />
		</td>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>上傳檔案：</TD>
		<TD class=whitetablebg colspan=3>
		    檔案名稱：<INPUT type="text" name="attach_name" id="attach_name" size="30" class=SEdit readonly>
            <input type=button id='btn<%#uploadfield%>' name='btn<%#uploadfield%>' class='cbutton <%=Lock.TryGet("Qup")%>' value='上傳' onclick="UploadAttach()">
            <input type=button id='btn<%#uploadfield%>_D' name='btn<%#uploadfield%>_D' class='cbutton <%=Lock.TryGet("Qup")%>' value='刪除' onclick="DelAttach()">
            <input type=button id='btn<%#uploadfield%>_S' name='btn<%#uploadfield%>_S' class='cbutton' value='檢視' onclick="PreviewAttach()">
            <input type='hidden' id='<%#uploadfield%>_size' name='<%#uploadfield%>_size'>
            <input type='hidden' id='uploadfield' name='uploadfield' value="<%#uploadfield%>">
            <input type='hidden' id='<%#uploadfield%>' name='<%#uploadfield%>'>
            <input type="hidden" id="<%=uploadfield%>_max_attach_no" name="<%=uploadfield%>_max_attach_no" size="2"><!--attach_no-->
            <input type='hidden' id='tstep_grade' name='tstep_grade'>
            <input type='hidden' id='attach_sqlno' name='attach_sqlno'>
            <input type='hidden' id='attach_flag' name='attach_flag'>
            <input type='hidden' id='attach_flag_name' name='attach_flag_name'>
            <input type='hidden' id='dir_name' name='dir_name'>
            <span id="span_source"><BR>原始檔名：<input type='text' id='source_name' name='source_name' class=SEdit readonly size=50></span>
            <input type='hidden' id='attach_no' name='attach_no' value='##'>
            <input type='hidden' id='old_<%#uploadfield%>_name' name='old_<%#uploadfield%>_name'>
            <input type='hidden' id='doc_type_mark' name='doc_type_mark'>
            <input type='hidden' id='attach_flagtran' name='attach_flagtran'><!--2014/12/13柳月for異動作業增加-->
            <input type='hidden' id='tran_sqlno' name='tran_sqlno' value='0'><!--2014/12/13柳月for異動作業增加-->
            <input type='hidden' id='<%#uploadfield%>_apattach_sqlno' name='<%#uploadfield%>_apattach_sqlno'><!--2015/12/25柳月for總契約書/委任書作業增加-->
            <input type='hidden' id='attach_old_branch' name='attach_old_branch'>
		    <br>檔案說明：
		    <select name="attach_doc_type" id="attach_doc_type" onchange="cust22form.DocTypeChange()"><%=html_doctype%></select>
		    <INPUT type="text" name="attach_desc" id="attach_desc" size="50" maxlength="80" >
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>首案使用：</TD>
		<TD class=whitetablebg colspan=3>
            區所案號：<%=seBranch%>
		    <select name="main_dept" id="main_dept" onchange="" size=1 >
		        <%=html_dept%>
		    </select>
            -
            <input name="main_seq" id="main_seq" onblur="cust22form.main_seq_onblur()" size="6" maxlength="6" style="margin-bottom:4px;" >
            <input name="main_seq1" id="main_seq1" onblur="cust22form.main_seq_onblur()" size="1" maxlength=1 value="_">
            <%--<font onclick="VBScript:Qseq_onclick" style="cursor: hand;color:blue" onmouseover="vbs:me.style.color='red'" onmouseout="vbs:me.style.color='blue'" nowrap>[查詢]</font>
            <font onclick="VBScript:Qseqdetail_onclick reg.main_dept.value,reg.main_seq.value,reg.main_seq1.value" style="cursor: hand;color:blue" onmouseover="vbs:me.style.color='red'" onmouseout="vbs:me.style.color='blue'" nowrap>[詳細]</font>--%>
            <input type="button" name="btnquery_seq" id="btnquery_seq" class="cbutton" value="查詢" onclick="cust22form.Queryseq()" >
			<input type="button" name="btnseqDetail" id="btnseqDetail" class="cbutton" value="詳細" onclick="cust22form.Qseqdetail()">
            &nbsp;&nbsp;申請號：<INPUT type="text" name="apply_no" id="apply_no" size="30" maxlength=30 class=SEdit readonly="readonly" style="margin-bottom:4px;">
            <br>正本存放：<INPUT type="text" name="mremark" id="mremark" size="50" maxlength="100" style="margin-bottom:4px;" >
            <br>委任書號：<INPUT type="text" name="mcontract_no" id="mcontract_no" size="50" maxlength="100">
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>備註說明：</TD>
		<TD class=whitetablebg colspan=3>
		    <textarea name="remark" id="remark" rows=3 cols=70 ></textarea>
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>建檔日期：</TD>
		<TD class=whitetablebg>
		    <INPUT type="text" name="in_date" id="in_date" size="20" class=SEdit readonly>
		    <INPUT type="text" name="in_scode" id="in_scode" size="15" class=SEdit readonly>&nbsp;
		</TD>
		<TD class=lightbluetable align=right>最近異動日：</TD>
		<TD class=whitetablebg>
		    <INPUT type="text" name="tran_date" id="tran_date" size="20" class=SEdit readonly>
		    <INPUT type="text" name="tran_scode" id="tran_scode" size="15" class=SEdit readonly>&nbsp;
		</TD>
	</TR>
</table>
<br />
<div align="left">
<font color="blue" size="2">
※注意！已上傳檔案，如需修改申請人統編，則請先刪除檔案。(若無法刪除檔案，表示已使用到個案無法維護)
</font>
</div>



<script language="javascript" type="text/javascript">
    //****每個form都有自已的別名
    var cust22form = {};
    //畫面初始化
    cust22form.init = function () {
        $("#cust_area").val('<%#Sys.GetSession("seBranch")%>');
        $("#cust_area").lock();
        
        
    }

    cust22form.DeptChange = function () {

        if ($("#dept").val() == "") {
            $("#agt_no").val(''); $("#agt_no").lock();
            $("#country").val(''); $("#country").lock();
            $("#agent_no").val(''); $("#agent_no").lock();
            $("#agent_no1").val(''); $("#agent_no1").lock();
        }
        else {
            if ($("#dept").val() == "P" || $("#dept").val() == "T") {
                $("#country").val("T"); $("#country").lock();
                $("#agt_no").val(''); $("#agt_no").unlock();
                $("#agent_no").val(''); $("#agent_no").lock();
                $("#agent_no1").val(''); $("#agent_no1").lock();
            }
            else {
                $("#agt_no").val(''); $("#agt_no").lock();
                $("#country").val(''); $("#country").unlock();
                $("#agent_no, #agent_no1").unlock();
            }
        }
    }

    cust22form.DocTypeChange = function () {
        if ($("#attach_doc_type").val() != "") {
            var str = $("#attach_doc_type option")[1].text.substring(5, 9);
            if ($("#attach_desc").val() != "") {
                $("#attach_desc").val($("#attach_desc").val() + "、" + str);
            }
            else {
                $("#attach_desc").val(str);
            }
        }
    }


    cust22form.SetReadOnly = function () {
        $("input:radio[name=sign_flag]").lock();
        $("#dept, #country, #company, #agt_no, #agent_no, #agent_no1, #use_sdate, #use_edate, #sign_scode, #attach_doc_type, #attach_desc, #main_dept, #main_seq, #main_seq1, #mremark, #mcontract_no, #remark").lock();
        $("#btnquery_seq").hide();
    }

    cust22form.Setcust221formReadOnly = function () {
        cust221form.SetReadOnly();
    }

    cust22form.Queryseq = function () {
        //主檔查詢
        var url = "cust22_Querymain.aspx?prgid=cust22&submitTask=Q";
        //window.open(url, "_blank");
        window.open(url, "myWindowQ", "width=1024 height=768 top=20 left=20 toolbar=no, menubar=no, location=no, directories=no resizable=yes status=yes scrollbars=yes");
    }

    cust22form.Qseqdetail = function () {
        var url = "";
        switch ($("#dept").val()) {
            case "P":
                url = getRootPath() + "/brp3m/brp33edit.aspx?prgid=<%=prgid%>&winact=1&seq="+$("#main_seq").val()+"&seq1="+$("#main_seq1").val()+"&submittask=Q";
                break;
            case "PE":
                url = getRootPath() + "/brp3m/exp33Edit.aspx?prgid=<%=prgid%>&winshow=Y&winact=1&seq="+$("#main_seq").val()+"&seq1="+$("#main_seq1").val()+"&submittask=Q";
                break;
            case "T":
                url = getRootPath() + "/brt5m/brt15ShowFP.aspx?seq=" + $("#main_seq").val() + "&seq1=" + $("#main_seq1").val() + "&submittask=Q";
                break;
            case "TE":
                url = getRootPath() + "/brt5m/ext54Edit.aspx?seq=" + $("#main_seq").val() + "&seq1=" + $("#main_seq1").val() + "&submittask=DQ&winact=Y&prgid=<%=prgid%>";
                break;
            default:
                break;
        }

        if ($("#dept").val() != "T") {
            alert("目前僅開放商標國內案件資料明細查詢");
            return;
        }

        window.open(url, "myWindowQ", "width=1024 height=768 top=20 left=20 toolbar=no, menubar=no, location=no, directories=no resizable=yes status=yes scrollbars=yes");
    }

    cust22form.CanDelAttach = function () {
        //2017/2/3增加判斷可否執行檔案刪除，若上傳檔案中已有apattach_sqlno，則不能刪除
        var sql = "";
        switch ($("#dept").val()) {

            case "P":
                sql = "Select count(*) as cnt from dmp_attach ";
                sql += " where apattach_sqlno = '" + $("#apattach_sqlno").val() + "' and attach_flag <>'D' ";
                break;
            case "PE":
                sql = "Select count(*) as cnt from exp_attach ";
                sql += " where apattach_sqlno = '" + $("#apattach_sqlno").val() + "' and attach_flag <>'D' ";
                break;
            case "T":
                sql = "Select count(*) as cnt from dmt_attach ";
                sql += " where apattach_sqlno = '" + $("#apattach_sqlno").val() + "' and attach_flag <>'D' ";
                break;
            case "TE":
                sql = "Select count(*) as cnt from caseattach_ext ";
                sql += " where apattach_sqlno = '" + $("#apattach_sqlno").val() + "'";
                break;
            default:
                break;
        }

        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + sql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                if (JSONdata.length > 0) {
                    if (CInt(JSONdata[0].cnt) > 0) {
                        $("#btn<%#uploadfield%>_D").lock();
                    }
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


    cust22form.main_seq_onblur = function () {
        var maintable = "";
        if ($("#main_seq").val() != "" && $("#main_seq1").val() != "") {

            switch ($("#main_dept").val()) {

                case "P":
                    maintable = "dmp";
                    break;
                case "PE":
                    maintable = "exp";
                    break;
                case "T":
                    maintable = "dmt";
                    break;
                case "TE":
                    maintable = "ext";
                    break;
                default:
                    break;
            }

            var psql = "select apply_no from " + maintable + " where seq = '" + $("#main_seq").val() + "' and seq1 = '" + $("#main_seq1").val() + "'";
            $.ajax({
                url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql,
                type: "POST",
                async: false,
                cache: false,
                data: $("#reg").serialize(),
                success: function (json) {
                    var JSONdata = $.parseJSON(json);
                    if (JSONdata.length >0) {
                        $("#apply_no").val(JSONdata[0].apply_no);
                    }
                    else {
                        $("#apply_no").val('');
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
    }

    cust22form.agent_onblur = function () {

        if ($("#agent_no").val().trim() != "") {
            chkNum($("#agent_no").val(), "出口案代理人");
            $("#agent_no").val(padLeft($("#agent_no").val(), 4, "0"));

            var psql = "select *, isnull(agent_na1,'')+isnull(agent_na2,'') as agent_na, ";
            psql += "ar_statnm=case ar_stat when 'Y' then '正常' when 'N' then '異常' end, ";
            psql += "(select coun_c from sysctrl.dbo.country where coun_code = agent.agcountry) as agcountry_nm ";
            psql += "from agent where agent_no = agent_no";

            if ($("#agent_no").val() != "") {
                psql += " and agent_no = '" + $("#agent_no").val() + "'";
            }
            if ($("#agent_no1").val() != "") {
                psql += " and agent_no1 = '" + $("#agent_no1").val() + "'";
            }
            else {
                psql += " and agent_no1 = '_'";
            }

            psql += " order by agent_no, agent_no1";

            $.ajax({
                url: "../AJAX/JsonGetSqlData.aspx",
                type: "POST",
                async: false,
                cache: false,
                //data: $("#reg").serialize(),
                data: { SQL: psql },
                success: function (json) {
                    var JSONdata = $.parseJSON(json);
                    if (JSONdata.length > 0) {
                        if (JSONdata[0].end_date != "") {
                            alert("該代理人已停用，請重新輸入!!");
                            $("#agent_no, #agent_no1, #agent_na, #agent_coun").val('');
                        }
                        else {
                            $("#agent_coun").val(JSONdata[0].agcountry);
                            $("#agent_na").val(JSONdata[0].agent_na1 + " " + JSONdata[0].agent_na2);
                        }
                    }
                    else {
                        alert("查無該代理人資料!!");
                        $("#agent_no, #agent_no1, #agent_na, #agent_coun").val('');
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
        else {
            $("#agent_no, #agent_no1, #agent_na, #agent_coun").val('');
        }
    }


    //資料綁定
    cust22form.bind = function (jData) {
        
        $("input[name=sign_flag]").each(function () {
            var way = $(this).val();
            var ischeck = jData.sign_flag.indexOf(way);
            if (ischeck >= 0) {
                $(this).prop('checked', true);
            }
        })

        $("#cust_area").val(jData.cust_area);
        $("#dept").val(jData.dept);
        //$("#company").val(jData.company);
        $("#country").val(jData.country);
        if ($("#dept").val() == "P" || $("#dept").val() == "T") {
            $("#agt_no").unlock();
            $("#agent_no, #agent_no1, #country").lock();
        }
        else {
            $("#agt_no").lock();
            $("#agent_no, #agent_no1, #country").unlock();
        }

        $("#agt_no").val(jData.agt_no);
        $("#contract_no").val(jData.contract_no);

        $("input[name=attach_flag]").each(function () {
            var way = $(this).val();
            var ischeck = jData.attach_flag.indexOf(way);
            if (ischeck >= 0) {
                $(this).prop('checked', true);
            }
            if (way == "U" && jData.attach_flag == "A") {
                $(this).prop('checked', true);
            }
        })
        if ($("input[name=attach_flag][value='E']").prop('checked') == true) {
            $("#span_stop_remark").show();
            $("#stop_remark").val(jData.stop_remark);
        }



        $("#agent_no").val(jData.agent_no);
        $("#agent_no1").val(jData.agent_no1);
        $("#agent_coun").val(jData.agent_coun);
        $("#agent_na").val(jData.agent_na);

        $("#use_sdate").val(dateReviver(jData.use_dates, "yyyy/M/d"));
        $("#use_edate").val(dateReviver(jData.use_datee, "yyyy/M/d"));
        $("#sign_scode").val(jData.sign_scode);
        $("#<%=uploadfield%>").val(jData.attach_path);
        $("#<%=uploadfield%>_name").val(jData.attach_name);
        $("#<%=uploadfield%>_doc_type").val(jData.doc_type);
        $("#<%=uploadfield%>_desc").val(jData.attach_desc);
        $("#<%=uploadfield%>_size").val(jData.attach_size);
        $("#source_name").val(jData.source_name);
        $("#attach_no").val(jData.attach_no);

        $("#main_dept").val(jData.main_dept);
        $("#main_seq").val(jData.main_seq);
        $("#main_seq1").val(jData.main_seq1);
        $("#apply_no").val(jData.apply_no);
        $("#mremark").val(jData.mremark);
        $("#mcontract_no").val(jData.mcontract_no);
        $("#remark").val(jData.remark);
        $("#in_date").val(dateReviver(jData.in_date, "yyyy/M/d tt HH:mm:ss"));
        $("#in_scode").val(jData.in_scode + jData.in_scodenm);
        //$("#in_scodenm").val(jData.in_scodenm);
        $("#tran_date").val(dateReviver(jData.tran_date, "yyyy/M/d tt HH:mm:ss"));
        $("#tran_scode").val(jData.tran_scode + jData.tran_scodenm);
        //$("#tran_scodenm").val(jData.tran_scodenm);
        cust22form.Loadcust221FormData(jData.apattach_sqlno);
        cust22form.main_seq_onblur();
    }

    function getmax_attach_no() {
        var psql = "select isnull(max(Attach_No),0) as max_attach_no ";
        psql += "from apcust_attach ";
        psql += "where cust_area = '" + reg.cust_area.value + "' and apsqlno = '" + reg.sapsqlno_1.value + "'"
        var maxno = 1;
        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                maxno = parseInt(JSONdata[0].max_attach_no) + 1;
                $("#<%=uploadfield%>_max_attach_no").val(maxno);
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                alert("\n資料擷取剖析錯誤 !\n" + jqXHR.url);
            }
        });
        return maxno;
    }

    //[上傳]
    function UploadAttach() {
        if ($.trim($("#sapcust_no_1").val()) == "") {
            alert("請輸入申請人編號1，才可上傳附件 !!!");
            return false;
        }
        //nfilename = reg.cust_area.value & "AP-" & apsqlno & "-" & max_attach_no
        //Custdb_file\N\016\016203\NAP-016203-1
        //var tfolder = $("#" + $("#uploadfield").val() + "_path").val();
        var apsqlno = padLeft(reg.sapsqlno_1.value, 6, '0');
        var tfolder = reg.cust_area.value + "/" + apsqlno.substring(0, 3) + "/" + apsqlno;
        var max_attach_no = getmax_attach_no();
        var nfilename = reg.cust_area.value + "AP-" + apsqlno + "-" + max_attach_no;
        var url = getRootPath() + "/sub/upload_win_file_new.aspx?type=custdb_file" +
            "&attach_sqlno_name=attach_sqlno"+
            "&folder_name=" + tfolder +
            "&form_name=<%=uploadfield%>"+
            "&file_name=" + $("#uploadfield").val() + "_name" +
            "&nfilename=" + nfilename +
            "&size_name=" + $("#uploadfield").val() + "_size" +
            "&dir_name=dir_name" +
            "&source_name=source_name"  +
            "&attach_flag_name=attach_flag_name" +
            "&attach_no=" + max_attach_no +//傳回max_attach_no用
            "&prgid=<%=prgid%>" +
            "&btnname=btn" + $("#uploadfield").val() +
            "&filename_flag=source_name2";
        window.open(url, "dmtupload", "width=700 height=600 top=50 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    

    }//[上傳]

    //[刪除]
    function DelAttach() {
        var fld = $("#uploadfield").val();

        if (document.getElementById(fld).value == "") {
            alert("無檔案可刪除!!");
            return false;
        }
        var file = document.getElementById(fld).value;
        var tname = document.getElementById(fld + "_name").value;
        if (file.indexOf(".") > -1) {	//路徑包含檔案
            if (file.indexOf("/") > -1) {	//當檔名前的符號為/，將檔名前/改為\
                file = file.substr(0, file.lastIndexOf("/")) + "\\" + tname;
            }
        } else {
            file += "\\" + tname;
        }

        //2015/12/25for總契約書/委任書增加檢查(只取消連結不刪實體檔)
        if (document.getElementById(fld + "_apattach_sqlno").value != "") {
            if (confirm("確定取消" + document.getElementById(fld + "_desc").value + "連結？")) {
                document.getElementById(fld + "_apattach_sqlno").value = "";
                document.getElementById(fld + "_name").value = "";
                document.getElementById("source_name").value = "";
                document.getElementById(fld + "_desc").value = "";
                document.getElementById(fld + "_size").value = "";
                ////document.getElementById(fld + "_" + nRow).value = "";
                document.getElementById(fld).value = "";
                //document.getElementById("doc_type").value = "";

                document.getElementById("attach_flag").value = "D";
                $("#btn<%=uploadfield%>").unlock();
                $("#sapcust_no_1").unlock();
                
            }
            return false;
        }

        if (confirm("確定刪除上傳檔案？")) {
            $.ajax({
                url: getRootPath() + "/sub/del_draw_file_new.aspx",
                data: { type: "doc", draw_file: file },
                type: 'post',//刪除要用post,參數帶中文檔名時才不會有問題
                dataType: "script",
                async: false,
                cache: false,
                success: function (data) {
                    document.getElementById(fld + "_name").value = "";
                    document.getElementById("source_name").value = "";
                    document.getElementById(fld + "_desc").value = "";
                    document.getElementById(fld + "_size").value = "";
                    ////document.getElementById(fld + "_" + nRow).value = "";
                    document.getElementById(fld).value = "";
                    //document.getElementById("doc_type").value = "";

                    document.getElementById("attach_flag").value = "D";
                    $("#btn<%=uploadfield%>").unlock();
                    $("#sapcust_no_1").unlock();
                    $("#btnquery_apcust_no_1").unlock();
                },
                error: function (xhr) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>刪除檔案失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                    $("#dialog").dialog({ title: '刪除檔案失敗！', modal: true, maxHeight: 500, width: "90%" });
                }
            });

        } else {
            document.getElementById(fld + "_desc").focus();
            return false;
        }
    }

    //檢視
    function PreviewAttach () {
        var fld = $("#uploadfield").val();
        if ($("#" + fld + "_name").val() == "") {
            alert("請先上傳附件 !!");
            return false;
        }

        var file = document.getElementById(fld).value;
        var tname = document.getElementById(fld + "_name").value;
        if (file.indexOf(".") > -1) {	//路徑包含檔案
            if (file.indexOf("/") > -1) {	//當檔名前的符號為/，將檔名前/改為\
                file = file.substr(0, file.lastIndexOf("/")) + "\\" + tname;
            }
        } else {
            file += "\\" + tname;
        }

        window.open(Path2Nbrp(file));
    }//檢視

    cust22form.Loadcust221FormData = function (jData) {
    
        var psql = "select r.apattach_ref_sqlno,r.apsqlno,a.cust_area,a.apcust_no,a.ap_cname1,a.ap_cname2,a.apclass,a.ap_crep,a.ap_erep, ";
        psql += "a.ap_addr1,a.ap_addr2,a.ap_eaddr1,a.ap_eaddr2,a.ap_eaddr3,a.ap_eaddr4, ";
        psql += "(select code_name From cust_code where Code_type='apclass' and cust_code=a.apclass) as apclassnm, ";
        psql += "(select mark From cust_code where Code_type='apclass' and cust_code=a.apclass) as mark ";
        psql += "from apcust_attach_ref r, apcust a ";
        psql += "where r.apattach_sqlno='" + jData + "' and r.apsqlno=a.apsqlno";


        $.ajax({
            url: "../AJAX/JsonGetSqlData.aspx?SQL=" + psql,
            type: "POST",
            async: false,
            cache: false,
            data: $("#reg").serialize(),
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                //****form的資料綁定移到form裡,這樣不同的作業使用這個form時只要把json丟進去就好
                if (JSONdata.length > 0) {
                    cust221form.bind(JSONdata);
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
