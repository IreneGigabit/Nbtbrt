<%@Page Language="C#" CodePage="65001"%>

<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "電文內容維護作業";
    private string HTProgCode = "nimp851";
    protected string HTProgPrefix = "nimp851";
    private int HTProgAcs = 1;
    private int HTProgRight = 2;

    private string StrParentCodeName = "";

    protected string StrQueryLink = "";
    protected string StrAddLink = "";
    protected string StrQueryBtn = "";

    protected string prgid = "";
    protected string submitTask = "";

    protected string se_grpclass = "FIMP";
    protected string scode = "";
    protected string qlang_code = "";
    protected string ctrl_open = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        
        if (Request["submitTask"] != null) submitTask = Request["submitTask"].ToString();

        if ((Request["ctrl_open"] ?? "") != "")
            ctrl_open = Request["ctrl_open"];
        
        //Session["pwd"] = true;
        
        //Response.Write("Session['pwd']=" + Session["pwd"]);

        Token myToken = new Token(HTProgCode, HTProgAcs);        
        HTProgRight = myToken.CheckMe2();
        
        //HTProgRight = 2;

        //Response.Write("test");
        
        //Response.Write(HTProgRight);

        if ((Request["lang_code"] ?? "") != "")
            qlang_code = Request["lang_code"];
        else
            qlang_code = "E";
        
        if (HTProgRight >= 0)
        {            
            QueryPageLayout();
            this.DataBind();
        }
    }

    private void QueryPageLayout()
    {
        prgid = Request.QueryString["prgid"] ?? "";

        //se_grpclass = Session["se_grpclass"].ToString();
        
        scode = Session["scode"].ToString();
        
        if ((HTProgRight & 2) > 0)
        {
            //Response.Write(HTProgRight);
        
            StrQueryLink = "<input type=\"image\" id=\"imgSrch\" src=\"../icon/inquire_in.png\" title=\"送出查詢\" />&nbsp;";
            StrQueryBtn = "<input type=\"button\" id=\"btnSrch\" value =\"送出查詢\" class=\"cbutton\" />";
        }

        //if ((HTProgRight & 4) > 0)
        //    StrAddLink = "<input type=\"image\" id=\"imgAdd\" src=\"../icon/new.png\" title=\"新增\" />&nbsp;";                        
    }
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="x-ua-compatible" content="IE=10">
    <title><%=HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<body>    
    <input type="hidden" name="hi_lang_code" id="hi_lang_code" value="<%#qlang_code%>" />
    <table cellspacing="1" cellpadding="0" width="85%" border="0" align="center">
        <tr>
            <td width="100%" class="text9" nowrap="nowrap">&nbsp;【<%#HTProgCode%><%#HTProgCap%>‧<b style="color: Red">查詢</b>】
                <label>定稿版本:</label><label id ="lb_word"></label>
            </td>
            <td class="FormLink" valign="top" align="right" nowrap="nowrap">
                <a id="imgAdd" href="nimp851Edit.aspx?submitTask=A&prgid=<%=prgid%>&lang_code=E" target="Eblank">
                    <font>[新增]</font>
                </a>
                <a id="imgQuery" >
                    <font>[查詢]</font>
                </a>
                <a id="imgRefresh">
                    <font>[重新整理]</font>
                </a>                
            </td>
        </tr>
        <tr>
            <td width="100%" colspan="2">
                <hr />
            </td>
        </tr>
    </table>
    <span>
        
    </span>
    <form id="reg">
        <div>
            <table id="table_query" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="80%" align="center">
                <tr>
                    <td class="lightbluetable" align="right">電文語言種類：</td>
                    <td class="whitetablebg" align="left" colspan ="3" >
                        <input type="radio" id ="actionEN" name="LandType" value="E" checked="checked" /><label>英文</label>
                        <input type="radio" id ="actionJA" name="LandType" value="J" /><label>日文</label>       
                    </td>                    
                </tr>
                <tr>
                    <td class="lightbluetable" align="right">電文代碼：</td>
                    <td class="whitetablebg" align="left" >
                        <select id="qrytf_code" name="qrytf_code">
                            <option value='' style='color: blue' selected="selected">請選擇</option>
                        </select>
                    </td>
                    <TD class=lightbluetable align=right>電文代碼種類：</TD>
                    <TD class=whitetablebg>
			            <select id="qrytf_class" name="qrytf_class" size=1>
			                <option value='' style='color: blue' selected="selected">請選擇</option>
			            </select>
		            </TD>
                </tr>
                <tr>
		            <td class=lightbluetable align=right>電文名稱：</td>
		            <td class=whitetablebg colspan=3 >
			            <input type="text" name="qrytf_name" size=40 maxlength=40>
		            </td>
	            </tr>
                <tr>
		            <td class=lightbluetable align=right>承辦人員：</td>
		            <td class=whitetablebg colspan=3>
			            <select id="qrywork_team" name="qrywork_team" size=1>
				            <option value='' style='color: blue' selected="selected">請選擇</option>
			            </select>
			            <span id="span_work_scode">
			            <select id="qrywork_scode" name="qrywork_scode" size=1>
			                <option value='' style='color: blue' selected="selected">請選擇</option>
			            </select>
			            </span>
		            </td>
	            </tr>
                <tr>
		            <td class=lightbluetable align=right>使用期間：</td>
		            <td class=whitetablebg colspan=3>			        
                        <input type="text" name="qrybeg_date" id="qrybeg_date" class="dateField" value="" size="10" />
                            ~
                        <input type="text" name="qryend_date" id="qryend_date" class="dateField" value="" size="10" />
		            </td>
	            </tr>
                <tr>
		            <td class=lightbluetable align=right>代碼狀態：</td>
		            <td class=whitetablebg align=left colspan=3>
			            <input type=radio name="radStat" checked="checked" value="0">使用中
			            <input type=radio name="radStat" value="1">已停用
			            <input type=radio name="radStat" value="2">不指定
		            </td>
	            </tr>
            </table>
            <br />
            <table id ="table_btn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
                <tr>
                    <td width="100%" align="center">
                        <%#StrQueryBtn%>
                        <input type="button" id="btnRst" value="重　填" class="cbutton" />
                    </td>
                </tr>
            </table>
        </div>
        <div id="divPaging" style="display: none">
            <table border="0" cellspacing="1" cellpadding="0" width="85%" align="center">                
                <tr>
                    <td colspan="2" align="center" class="whitetablebg">
                        <font size="2" color="#3f8eba">第<font color="red"><span id="NowPage"></span>/<span id="TotPage"></span></font>頁
				| 資料共<font color="red"><span id="TotRec"></span></font>筆
				| 跳至第
				<select id="GoPage" name="GoPage" style="color: #FF0000"></select>
                            頁
				<span id="PageUp">| <a href="javascript:void(0)" class="pgU" v1="">上一頁</a></span>
                            <span id="PageDown">| <a href="javascript:void(0)" class="pgD" v1="">下一頁</a></span>
                            | 每頁筆數:
				<select id="PerPage" name="PerPage" style="color: #FF0000">
                    <option value="10" selected>10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option value="40">40</option>
                </select>
                            <input type="hidden" name="SetOrder" id="SetOrder" />
                        </font>
                    </td>
                </tr>
            </table>
        </div>
        <br />
        <table style="display: none" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%" align="center" id="dataList">
                <thead>
                    <tr align="center" class="lightbluetable">                        
                        <td align="center" class="lightbluetable" nowrap="nowrap">電文代碼/名稱</td>
                        <td align="center" class="lightbluetable" nowrap="nowrap">代碼種類</td>
                        <td align="center" class="lightbluetable" nowrap="nowrap">使用期間</td>
                        <td align="center" class="lightbluetable" nowrap="nowrap">承辦人員</td>
                        <td align="center" class="lightbluetable" nowrap="nowrap">判行人員</td>
                        <td align="center" class="lightbluetable" nowrap="nowrap">發文內容</td>
                        <td align="center" class="lightbluetable" nowrap="nowrap">信函署名</td>
                        <td align="center" class="lightbluetable" nowrap="nowrap">E-mail署名</td>
                        <td align="center" class="lightbluetable" nowrap="nowrap">附件</td>
                        <td align="center" class="lightbluetable" nowrap="nowrap">作業</td>                        
                    </tr>
                </thead>
                <tfoot style="display: none">
                    <tr align='center' class='{{tclass}}' id='tr_data_{{nRow}}'>                        
                        <td>{{tf_code}}-{{tf_name}}</td>
                        <td>{{tf_classnm}}</td>
                        <td>{{beg_date}}~{{end_date}}</td>
                        <td>{{pr_scode}}</td>
                        <td>{{chk_scode}}</td>
                        <td>{{rs_type}}</td>
                        <td>{{tf_sender1}}</td>
                        <td>{{tf_sender2}}</td>
                        <td>{{tf_havefilenm}}</td>
                        <td nowrap="nowrap">
                            <a id="btnQuery_{{nRow}}" href="nimp851Edit.aspx?submitTask=Q&prgid=<%=prgid%>&tf_code={{tf_code}}&radStat=0&nowPage=1&lang_code={{lang_code}}&ctrl_open=<%=ctrl_open%>" target="Eblank"  {{check_query}}>
                                <font>[查詢]</font>
                            </a>
                            <a href="nimp851_print.aspx?prgid=<%=prgid%>&tf_code={{tf_code}}&lang_code={{lang_code}}" target="Eblank" {{check_print}}>
                                <font>[列印]</font>
                            </a>
                            <br />
                            <a id="btnModify_{{nRow}}" href="nimp851Edit.aspx?submitTask=U&prgid=<%=prgid%>&tf_code={{tf_code}}&radStat=0&nowPage=1&lang_code={{lang_code}}&ctrl_open=<%=ctrl_open%>" target="Eblank" {{check_edit}}>
                                <font>[維護]</font>
                            </a>
                            <a href="nimp851Edit.aspx?submitTask=C&prgid=<%=prgid%>&tf_code={{tf_code}}&radStat=0&nowPage=1&lang_code={{lang_code}}&ctrl_open=<%=ctrl_open%>" target="Eblank" {{check_copy}}>
                                <font>[複製]</font>
                            </a>
                        </td>
                    </tr>
                </tfoot>
                <tbody>
                </tbody>
            </table>       
    </form>
    <div align="center" id="noData" style="display: none">
        <font color="red">=== 目前無資料 ===</font><br />        
    </div>
</body>
</html>

<script type="text/javascript" language="javascript">

    
    window.parent.tt.rows = '100%,0%';

    function goSearch() {
        //window.parent.tt.rows = '100%,0%';
        //alert("123");
        $("#divPaging,#noData,#dataList").hide();
        

        $("#dataList>tbody tr").remove();
        nRow = 0;

        var lang_code = "E";
             
        if ($("#actionJA").prop("checked")) {
            lang_code = "J";
        }

        //$("#reg").attr('action', 'nimp851List.aspx');
        //$("#reg").attr('method', 'post');

        //$("#reg").submit();

        //return;

        $.ajax({
            url: "nimp851List.aspx?lang_code=" + lang_code,
            type: "POST",
            async: false,
            cache: false,
            datatype:"text",
            data: $("#reg").serialize(),
            success: function (data) {
                $("#table_query,#table_btn").hide();
                $("#imgQuery,#imgRefresh").show();
                var JSONdata = $.parseJSON(data);
                //////更新分頁變數
                var totRow = parseInt(JSONdata.totRow, 10);
                if (totRow > 0) {
                    $("#divPaging").show();
                    $("#dataList").show();
                } else {
                    $("#noData").show();
                    $("#showinfo").hide();
                }
                    
                var nowPage = parseInt(JSONdata.nowPage);
                var totPage = parseInt(JSONdata.totPage);
                $("#NowPage").html(nowPage);
                $("#TotPage").html(totPage);
                $("#TotRec").html(totRow);
                var i = totPage + 1, option = new Array(i);
                while (--i) {
                    option[i] = ['<option value="' + i + '">' + i + '</option>'].join("");
                }
                $("#GoPage").replaceWith('<select id="GoPage" name="GoPage" style="color:#FF0000">' + option.join("") + '</select>');
                $("#GoPage").val(nowPage);
                nowPage > 1 ? $("#PageUp").show() : $("#PageUp").hide();
                nowPage < totPage ? $("#PageDown").show() : $("#PageDown").hide();
                $("a.pgU").attr("v1", nowPage - 1);
                $("a.pgD").attr("v1", nowPage + 1);
                $("#id-div-slide").slideUp("fast");

                $.each(JSONdata.pagedTable, function (i, item) {
                    nRow++;
                    //複製一筆
                    $("#dataList>tfoot").each(function (i) {

                        var strLine1 = $(this).html().replace(/##/g, nRow);
                        var tclass = "";
                        if (nRow % 2 == 1) tclass = "sfont9"; else tclass = "lightbluetable3";
                        strLine1 = strLine1.replace(/{{tclass}}/g, tclass);
                        strLine1 = strLine1.replace(/{{nRow}}/g, nRow);
                            
                        strLine1 = strLine1.replace(/{{tf_code}}/g, item.tf_code);
                        strLine1 = strLine1.replace(/{{tf_name}}/g, item.tf_name);
                        strLine1 = strLine1.replace(/{{tf_classnm}}/g, item.tf_classnm);                        
                        strLine1 = strLine1.replace(/{{beg_date}}/g, dateReviver(item.beg_date, "yyyy-MM-dd ") );
                        strLine1 = strLine1.replace(/{{end_date}}/g, dateReviver(item.end_date, "yyyy-MM-dd "));

                        /**/
                        var pr_scode = "";
                        if (item.pr_scode != "" ) {
                            pr_scode = "非日:" + item.pr_scode + item.pr_scodenm;                            
                        }
                        if (item.pr_scode != "" && item.pr_scodej != "" ) {
                            pr_scode += "<br>"                            
                        }
                        if (item.pr_scodej != "" ) {
                            pr_scode += "日:" + item.pr_scodej + item.pr_scodejnm;                                
                        }
                        strLine1 = strLine1.replace(/{{pr_scode}}/g, pr_scode);

                        var chk_scode = "";
                        if (item.chk_scode != "" ) {
                            chk_scode = "非日:" + item.chk_scode + item.chk_scodenm;                            
                        }
                        if (item.chk_scode != "" && item.chk_scodej != "" ) {
                            chk_scode += "<br>"                            
                        }
                        if (item.chk_scodej != "" ) {
                            chk_scode += "日:" + item.chk_scodej + item.chk_scodejnm;
                        }
                        strLine1 = strLine1.replace(/{{chk_scode}}/g, chk_scode);
                        
                        if ($("#actionEN").prop("checked")) {
                            strLine1 = strLine1.replace(/{{lang_code}}/g, "E");
                        }
                         
                        if ($("#actionJA").prop("checked")) {
                            strLine1 = strLine1.replace(/{{lang_code}}/g, "J");
                        }

                        strLine1 = strLine1.replace(/{{rs_type}}/g, item.rs_type + "-" + item.rs_class + "-" + item.rs_code + "-" + item.act_code + item.rs_detail);
                            
                        strLine1 = strLine1.replace(/{{tf_sender1}}/g, item.tf_sender1nm);
                        strLine1 = strLine1.replace(/{{tf_sender2}}/g, item.tf_sender2nm);
                        strLine1 = strLine1.replace(/{{tf_havefilenm}}/g, item.tf_havefilenm);

                        // 權限                            
                        if ((<%=HTProgRight%> & 2) > 0) { // 查詢
                            strLine1 = strLine1.replace(/{{check_query}}/g, "");
                        }
                        else
                            strLine1 = strLine1.replace(/{{check_query}}/g, "style='display:none'");

                        if ((<%=HTProgRight%> & 32) > 0) { //列印
                            strLine1 = strLine1.replace(/{{check_print}}/g, "");
                        }
                        else
                            strLine1 = strLine1.replace(/{{check_print}}/g, "style='display:none'");

                        if ((<%=HTProgRight%> & 8) > 0) { // 修改
                            strLine1 = strLine1.replace(/{{check_edit}}/g, "");

                            if ((<%=HTProgRight%> & 4) > 0) { // 複製:有新增修改權限, 應該能複製
                                strLine1 = strLine1.replace(/{{check_copy}}/g, "");
                            }
                            else
                                strLine1 = strLine1.replace(/{{check_copy}}/g, "style='display:none'");

                        }
                        else {
                            strLine1 = strLine1.replace(/{{check_edit}}/g, "style='display:none'");
                            strLine1 = strLine1.replace(/{{check_copy}}/g, "style='display:none'");
                        }

                        //alert(strLine1); // DEBUG AJAX 

                        $("#dataList>tbody").append(strLine1);
                    });
                });
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (jqXHR, textStatus, errorThrown) {
                console.log(jqXHR.url);
                console.log(textStatus);
                console.log(errorThrown);
                alert("\n資料擷取剖析錯誤 !\n" + errorThrown);
            }
        });
    };

    function init_load(){        
        $("#imgQuery,#imgRefresh").hide();

        //抓取 電文代碼
        var ajax_sql = gettf_code(true, 'Y', 'N', '', '', $("#hi_lang_code").val());
        get_ajax_selection(ajax_sql, "qrytf_code", false);

        ajax_sql = gettf_class();
        get_ajax_selection(ajax_sql, "qrytf_class", false);

        ajax_sql = gettf_work_Team("","", "<%=se_grpclass%>");
        get_ajax_selection(ajax_sql, "qrywork_team", false);
        $("#lb_word")[0].innerText = "英文電文定稿標準版";

        if ($("#hi_lang_code").val() == "E"){
            $("#imgAdd")[0].href = "nimp851Edit.aspx?submitTask=A&prgid=<%=prgid%>&lang_code=E";
            $("#actionEN").prop('checked', true);
        }
        else if ($("#hi_lang_code").val() == "J"){
            $("#imgAdd")[0].href = "nimp851Edit.aspx?submitTask=A&prgid=<%=prgid%>&lang_code=J";
            $("#actionJA").prop('checked', true);
        }

        if ((<%=HTProgRight%> & 8) > 0) $("#imgAdd").show();
        else $("#imgAdd").hide();

    }

    $(function () {
        init_load();

        $("input.dateField").datepick();
        
        $("#btnRst").click(function (e) {
            $("#reg")[0].reset();
        });

        $("#btnSrch").click(function (e) {
            goSearch();
        });
        
        //每頁幾筆
        $("#PerPage").change(function (e) {
            goSearch();
        });
        //指定第幾頁
        $("#divPaging").on("change", "#GoPage", function (e) {
            goSearch();
        });
        //上下頁
        $(".pgU,.pgD").click(function (e) {
            $("#GoPage").val($(this).attr("v1"));
            goSearch();
        });
        //排序
        $(".setOdr").click(function (e) {
            $("#dataList>thead tr .setOdr span").remove();
            $(this).append( "<span>▲</span>" );
            $("#SetOrder").val($(this).attr("v1"));
            goSearch();
        });
        //重新整理
        $("#imgRefresh").click(function (e) {
            goSearch();
        });
        //查詢
        $("#imgQuery").click(function (e) {
            $("#imgQuery,#imgRefresh").hide();
            $("#table_query,#table_btn").show();
            $("#divPaging,#noData,#dataList").hide();
            //$("#reg")[0].reset();
            
            window.parent.tt.rows = '100%,0%';
        });
        
        $("#qrywork_team").on("change", function (e) {
            var qrywork_team = $( "#qrywork_team option:selected" ).val();
            var ajax_sql = gettf_work_Scode("<%=prgid%>", qrywork_team, "<%=scode%>", "<%=se_grpclass%>");
            get_ajax_selection(ajax_sql, "qrywork_scode", false);
        });

        $("#actionEN").click(function (e) {
            if ($("#actionEN").prop("checked")) {                
                var ajax_sql = gettf_code(true, 'Y', 'N', '', '', $("#actionEN").val());
                get_ajax_selection(ajax_sql, "qrytf_code", false);

                $("#imgAdd")[0].href = "nimp851Edit.aspx?submitTask=A&prgid=<%=prgid%>&lang_code=E";
                $("#lb_word")[0].innerText = "英文電文定稿標準版";
                $("#hi_lang_code").val("E");
            }
        });

        $("#actionJA").click(function (e) {
            if ($("#actionJA").prop("checked")) {                
                var ajax_sql = gettf_code(true, 'Y', 'N', '', '', $("#actionJA").val());
                get_ajax_selection(ajax_sql, "qrytf_code", false);

                $("#imgAdd")[0].href = "nimp851Edit.aspx?submitTask=A&prgid=<%=prgid%>&lang_code=J";
                $("#lb_word")[0].innerText = "日文電文定稿標準版";
                $("#hi_lang_code").val("J");
            }
        });
    });

</script>