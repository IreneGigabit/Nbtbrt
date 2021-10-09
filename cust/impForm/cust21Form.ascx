<%@ Control Language="C#" ClassName="cust21Form" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace = "System.Text"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/cust/impForm/cust211Form.ascx" TagPrefix="uc1" TagName="cust211Form" %>

<script runat="server">
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    //區所名稱
    protected string html_BranchCode = Sys.getBranchCode().Option("{branch}", "{branch}_{branchname}");
    //公司別
    protected string html_company = Sys.getCustCode("con_comp", "", "sortfld").Option("{cust_code}", "{code_name}");
    //接洽人員
    protected string html_signscode = Sys.getCustScode("A", Sys.GetSession("dept"), 0, "").Option("{scode}", "{scode}_{sc_name}");
    //附件說明
    protected string html_doctype = Sys.getCustCode("apdoc", " and mark='A' ", "sortfld").Option("{cust_code}", "{cust_code}_{code_name}");
    protected string html_dept = "";
    public string uploadfield = "attach";
    public string uploadsource = "";
    public string tempfilepath = "";
    
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

<style>
    .InputMB input{
         margin-bottom : 4px;
    }

</style>


<TABLE id=tabcontract border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<TR>
		<TD class="lightbluetable" align=right>契約書種類：</TD>
		<TD class=whitetablebg>
			<input type="radio" name="sign_flag" value="S">單一客戶簽署
			<input type="radio" name="sign_flag" value="M">多個客戶合併簽署
		</TD>
		<TD class="lightbluetable" align=right>單位部門：</TD>
		<TD class=whitetablebg>
		    <select name="cust_area" id="cust_area" size=1>
                <%=html_BranchCode%>
		    </select>
		    <select name="dept" id="dept" size=1>
		        <option value="">請選擇</option>
                <%=html_dept%>
		    </select>
		    <span id="span_country"></span>
		</TD>
	</TR>
	<TR>
		<TD class="lightbluetable" align=right>契約書編號：</TD>
		<TD class=whitetablebg>
		    <select name="company" id="company" size=1>
		        <%=html_company%>
		    </select>
			<input type="text" name="contract_no" id="contract_no" size=11 maxlength=10 class=SEdit readonly>
		</TD>
		<TD class="lightbluetable" align=right>狀態：</TD>
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
		<TD class="lightbluetable" align=right>有效期間：</TD>
		<TD class=whitetablebg>
            <input type="text" name="use_sdate" id="use_sdate" size="10" readonly="readonly" class="dateField">～
		    <input type="text" name="use_edate" id="use_edate" size="10" readonly="readonly" class="dateField">
		</TD>
		<TD class="lightbluetable" align=right>接洽人員：</TD>
		<TD class=whitetablebg>
		    <select name="sign_scode" id="sign_scode" size=1>
			<%=html_signscode%>
		    </select>
		</TD>
	</TR>
	<TR>
		<td class="whitetablebg" colspan=4>
			<uc1:cust211Form runat="server" ID="cust211Form" />
		</td>
	</TR>
	<TR>
		<TD class="lightbluetable" align=right>上傳檔案：</TD>
		<TD class=whitetablebg>
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
            <%--<br>檔案說明：<select id='doc_type' name='doc_type' class="<%=Lock.TryGet("Qup")%>" onchange="upload_form.getfiledoc('##')"><%#html_doc%></select>
                <input type=text id='<%#uploadfield%>_desc' name='<%#uploadfield%>_desc' class="<%=Lock.TryGet("Qup")%>" size=50 maxlength=60 onblur="fChkDataLen(this,'檔案說明')" >--%>
		    <br>檔案說明：
		    <select name="attach_doc_type" id="attach_doc_type" onchange="cust21form.DocTypeChange()"><%=html_doctype%></select>
		    <INPUT type="text" name="attach_desc" id="attach_desc" size="50" maxlength="80" >
		    <%--<br>原始檔名：<INPUT type="text" name="attach_source_name" id="attach_source_name" size="30" class=SEdit readonly>--%>
		    
		</TD>
		<TD class="lightbluetable" align=right>正本存放：</TD>
		<TD class=whitetablebg>
		    <INPUT type="text" name="mremark" id="mremark" size="50" maxlength=100 >
		</TD>
	</TR>
	<TR>
		<TD class="lightbluetable" align=right>備註說明：</TD>
		<TD class=whitetablebg colspan=3>
		    <textarea name="remark" id="remark" rows=3 cols=70></textarea>
		</TD>
	</TR>
	<TR>
		<TD class="lightbluetable" align=right>建檔日期：</TD>
		<TD class=whitetablebg>
		    <INPUT type="text" name="in_date" id="in_date" size="22" class=SEdit readonly>
		    <INPUT type="text" name="in_scode" id="in_scode" size="15" class=SEdit readonly>
		    <%--<INPUT type="text" name="in_scodenm" id="in_scodenm" size="10" class=SEdit readonly>--%>
		</TD>
		<TD class="lightbluetable" align=right>最近異動日：</TD>
		<TD class=whitetablebg>
		    <INPUT type="text" name="tran_date" id="tran_date" size="22" class=SEdit readonly>
		    <INPUT type="text" name="tran_scode" id="tran_scode" size="15" class=SEdit readonly style="text-align: right">
		    <%--<INPUT type="text" name="tran_scodenm" id="tran_scodenm" size="10" class=SEdit readonly style="text-align: left">--%>
		</TD>
	</TR>
</table>

<div align="left">
    <font size=2>
※注意！已上傳檔案，如需修改客戶編號，則請先刪除檔案。
</font>
</div>


<script language="javascript" type="text/javascript">
    //****每個form都有自已的別名
    var cust21form = {};
    //畫面初始化
    cust21form.init = function () {
        $("#cust_area").val('<%#Sys.GetSession("seBranch")%>');
        $("#cust_area").lock();
        
        
    }

    cust21form.DocTypeChange = function () {
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

    cust21form.CanDelAttach = function () {
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

    cust21form.SetReadOnly = function () {
        $("input:radio[name=sign_flag]").lock();
        $("#dept, #company, #use_sdate, #use_edate, #sign_scode, #attach_doc_type, #attach_desc, #mremark, #remark").lock();
    }

    cust21form.Setcust211formReadOnly = function () {
        cust211form.SetReadOnly();
    }

    //資料綁定
    cust21form.bind = function (jData) {
        
        $("input[name=sign_flag]").each(function () {
            var way = $(this).val();
            var ischeck = jData.sign_flag.indexOf(way);
            if (ischeck >= 0) {
                $(this).prop('checked', true);
                //oldValue-$("input[name=osign_flag]").val(way);
            }
        })

        $("#cust_area").val(jData.cust_area);
        $("#dept").val(jData.dept);
        $("#company").val(jData.company);
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
        $("#mremark").val(jData.mremark);
        $("#remark").val(jData.remark);
        $("#in_date").val(dateReviver(jData.in_date, "yyyy/M/d tt HH:mm:ss"));
        $("#in_scode").val(jData.in_scode + jData.in_scodenm);
        //$("#in_scodenm").val(jData.in_scodenm);
        $("#tran_date").val(dateReviver(jData.tran_date, "yyyy/M/d tt HH:mm:ss"));
        $("#tran_scode").val(jData.tran_scode + jData.tran_scodenm);
        //$("#tran_scodenm").val(jData.tran_scodenm);
        cust21form.Loadcust211FormData(jData.apattach_sqlno);
    
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
        if ($.trim($("#scust_seq_1").val()) == "") {
            alert("請輸入客戶編號1，才可上傳附件 !!!");
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
        window.open(url, "", "width=700 height=600 top=50 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    

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
                    $("#scust_seq_1").unlock();
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

    cust21form.Loadcust211FormData = function (jData) {
        var dept = '<%=Sys.GetSession("dept")%>';
        dept = dept.toLowerCase();
    
        var psql = "select r.apattach_ref_sqlno,r.apsqlno,a.cust_area,a.cust_seq,a.apcust_no,a.ap_cname1,a.ap_cname2, ";
        psql += "c."+dept+"level as level, c."+dept+"scode as scode, ";
        psql += "(select code_name from cust_code where code_type='level' and cust_code=c."+dept+"level) as levelnm, ";
        psql += "(select sc_name from sysctrl.dbo.scode where scode=c."+dept+"scode) as scodenm ";
        psql += "from apcust_attach_ref r, apcust a, custz c ";
        psql += "where r.apattach_sqlno = '" + jData + "' and r.apsqlno=a.apsqlno ";
        psql += "and a.cust_area=c.cust_area and a.cust_seq=c.cust_seq";

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
                    cust211form.bind(JSONdata);
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

