<%@ Control Language="C#" ClassName="cust23TextForm" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace = "System.Text"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected string submitTask = "";
    protected string seBranch = "";
    protected string dept = "";
    //說明備註種類
    protected string html_TextType = Sys.getCustCode("cmark_text", "", "sortfld").Option("{cust_code}", "{code_name}", false);
    protected string html_Att = "";

    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;
        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = Request["submitTask"];
        seBranch = Sys.GetSession("seBranch");
        dept = Sys.GetSession("dept");
        prgid = Request["prgid"].ToString();
        
    }
    
    
</script>


<input type="hidden" id="htext_sql" name="htext_sql" value=""><!--位於第幾位-->
<input type=hidden name=refnum value=0><!--進度筆數-->
<TABLE id="tabText" name="tabText" border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
	<thead>
	<TR align=center class=lightbluetable>
		<TD>刪除</TD><TD>部門</TD>
        <TD>種類
            <select id="filter_txt_mark_type2" size="1">
				<option value="">全部</option>
                <%=html_TextType%>
			</select>
        </TD>
        <TD>聯絡人</TD><TD>說明</TD><TD>停用日期</TD><TD>最後異動</TD>
	</TR>
	</thead>
	<tbody></tbody>
        <script type="text/html" id="text_template"><!--設定樣板-->
        <tr class="whitetablebg" id="tr_txt_##">
		    <td class="whitetablebg" align="center" nowrap>
                <span id="txtno_##"></span>
                <input type="checkbox" id="txt_del_##" name="txt_del_##" value="Y">
				<INPUT type="hidden" size=1 id="txt_upd_flag_##" name="txt_upd_flag_##">
		    </td>
		    <td class="whitetablebg">
                <input type="checkbox" NAME="txt_dept_##" id="txt_dept_##_TI" value="TI"><label for="txt_dept_##_TI">內商</label>
			    <input type="checkbox" NAME="txt_dept_##" id="txt_dept_##_TE" value="TE"><label for="txt_dept_##_TE">出商</label>
			    <input type="checkbox" NAME="txt_dept_##" id="txt_dept_##_PI" value="PI"><label for="txt_dept_##_PI">內專</label>
			    <input type="checkbox" NAME="txt_dept_##" id="txt_dept_##_PE" value="PE"><label for="txt_dept_##_PE">出專</label><br />
                <input type="checkbox" NAME="txt_dept_##" id="txt_dept_##_AC" value="AC"><label for="txt_dept_##_AC">會計</label>
			    <input type="hidden" id="txt_dept_value_##" name="txt_dept_value_##">
			    <INPUT type="hidden" id="o_txt_dept_##" name="o_txt_dept_##">
		    </td>
		    <td class="whitetablebg" align="center">
                <select id="txt_mark_type2_##" name="txt_mark_type2_##" size="1">
                    <%=html_TextType %>
				</select>
				<INPUT type="hidden" id="o_txt_mark_type2_##" name="o_txt_mark_type2_##">
		    </td>
		    <td class="whitetablebg" align="center">
			    <SELECT id="txt_att_sql_##" name="txt_att_sql_##" size=1>
				</SELECT>
				<INPUT type="hidden" id="o_txt_att_sql_##" name="o_txt_att_sql_##">
		    </td>
            <td>
                <textarea rows="5" cols="80" id="txt_type_content1_##" name="txt_type_content1_##" style="width:100%"></textarea>
				<textarea id="o_txt_type_content1_##" name="o_txt_type_content1_##" style="display:none"></textarea>
            </td>
            <td>
                <input type="text" name="txt_end_date_##" id="txt_end_date_##" size="10" readonly="readonly" class="dateField"><BR>
				<INPUT type="hidden" id="o_txt_end_date_##">
            </td>
            <td align=center>
                <span id="txt_tran_date_##"></span><BR>
				<span id="txt_tran_scodenm_##"></span>
				<INPUT type="hidden" id="txt_mark_sqlno_##" name="txt_mark_sqlno_##">
            </td>
	    </tr>
        </script>
	<tfoot>
	    <tr>
		    <TD colspan=7 align=left class="whitetablebg">
			    <input type=button value="增加備註項目" class="cbutton" id="ref_AddText_button" name="ref_AddText_button" />
		    </TD>
	    </tr>
	</tfoot>
</TABLE>




<script language="javascript" type="text/javascript">
   

    //****每個form都有自已的別名
    var cust23textform = {};
    //畫面初始化
    cust23textform.init = function () {
        if ('<%=submitTask%>' == "Q") {
            //篩選功能
            $("#filter_txt_mark_type2").show().prop('disabled', false);
        }
        else {
            $("#filter_txt_mark_type2").hide();
        }
    }
    //資料綁定
    cust23textform.bind = function (jData) {
        $("#htext_sql").val("0");
        $.each(jData, function (i, item) {
            cust23textform.addAtt();//新增一筆
            var nRow = $("#htext_sql").val();

            //$("#no_" + nRow).text(nRow + ". ");
            var rDept = item.dept;
            $("#tabText>tbody input[name='txt_dept_" + nRow + "']").each(function (z) {
                $(this).prop('checked', false);
                if (rDept.indexOf("|" + $(this).val() + "|") > -1) $(this).prop('checked', true);
            })
            $("#o_txt_dept_" + nRow).val(rDept);
            $("#txt_mark_type2_" + nRow).val(item.mark_type2);
            $("#o_txt_mark_type2_" + nRow).val(item.mark_type2);
            //getAtt("#txt_att_sql_" + nRow, "");
            $("#txt_att_sql_" + nRow).val(item.att_sql);
            $("#o_txt_att_sql_" + nRow).val(item.att_sql);
            $("#txt_type_content1_" + nRow).val(item.type_content1);
            $("#o_txt_type_content1_" + nRow).val(item.type_content1);
            $("#txt_end_date_" + nRow).val(dateReviver(item.end_date, "yyyy/M/d"));
            $("#o_txt_end_date_" + nRow).val(dateReviver(item.end_date, "yyyy/M/d"));
            $("#txt_tran_date_" + nRow).html(dateReviver(item.tran_date, "yyyy/M/d hh:mm:ss"));
            $("#txt_tran_scodenm_" + nRow).html(item.tran_scodenm);
            $("#txt_mark_sqlno_" + nRow).val(item.mark_sqlno);


            ////新增模式要鎖定
            //if ("<%=submitTask%>" == "A") cust23textform.lockTr("txt_", nRow);
            if ("<%=submitTask%>" == "A") lockTr("txt_", nRow);


        })

        if ('<%=submitTask%>' != "U") {
            $("select[id^='txt_mark_type2_']").lock();
            $("select[id^='txt_att_sql_']").lock();
        }


    }

    cust23textform.lockTr = function lockTr(prefix, rNo) {
        $("#tr_" + prefix + rNo + " select,#tr_" + prefix + rNo + " img,#tr_" + prefix + rNo + " textarea").prop('disabled', true);
        $("#tr_" + prefix + rNo + " input").prop('disabled', true);
    }

    //[增加一筆]
    cust23textform.addAtt = function () {
        if ($.trim($("#cust_seq").val()) == "") {
            alert("請輸入客戶編號，才可新增 !!!");
            return false;
        }

        var nRow = CInt($("#htext_sql").val()) + 1;//畫面顯示NO
        //複製樣板
        var copyStr = $("#text_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        //$("#tbl_att>tbody").append(copyStr);
        $("#tabText>tbody").append(copyStr);
        $("#txtno_" + nRow).text(nRow + ". ");
        $("#htext_sql").val(nRow);
        $("input[type=checkbox][name^='txt_dept_']").lock();

        if ('<%=submitTask%>' == 'A') {
            if ('<%=dept%>' == 'P') {
                $("input[type=checkbox][name='txt_dept_" + nRow + "'][value='PI']").unlock();
                $("input[type=checkbox][name='txt_dept_" + nRow + "'][value='PI']").prop('checked', true);
                $("input[type=checkbox][name='txt_dept_" + nRow + "'][value='PE']").unlock();
                $("input[type=checkbox][name='txt_dept_" + nRow + "'][value='PE']").prop('checked', true);
            }
            else if ('<%=dept%>' == 'T') {
                $("input[type=checkbox][name='txt_dept_" + nRow + "'][value='TI']").unlock();
                $("input[type=checkbox][name='txt_dept_" + nRow + "'][value='TI']").prop('checked', true);
                $("input[type=checkbox][name='txt_dept_" + nRow + "'][value='TE']").unlock();
                $("input[type=checkbox][name='txt_dept_" + nRow + "'][value='TE']").prop('checked', true);
            }
            else {
                $("input[type=checkbox][name='txt_dept_" + nRow + "'][value='AC']").unlock();
                $("input[type=checkbox][name='txt_dept_" + nRow + "'][value='AC']").prop('checked', true);
            }

            $("#txt_mark_type2_" + nRow).val('T_');
        }
        
        cust23textform.searchCustAtt(nRow, "txt_att_sql_");
        $("input.dateField").datepick();
    }


    $("#ref_AddText_button").click(function (e) {
        cust23textform.addAtt();
    });

    cust23textform.searchCustAtt = function (nRow, objID) {
        var psql = "select att_sql, attention from custz_att where cust_area = '" + $("#cust_area").val() + "' and cust_seq = '" + $("#cust_seq").val() + "'";
        if ('<%=submitTask%>' == 'A') {
            psql += " and dept = '" + '<%=dept%>' + "'";
            psql += " and (att_code like 'N%' or att_code='' or att_code is null)";
        }

        //#txt_att_sql_, 
        $("#"+objID+ nRow).getOption({//種類
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: { sql: psql},
            showEmpty: false,//顯示"請選擇"
            valueFormat: "{att_sql}",//option的value格式,用{}包住欄位,ex:{scode}
            textFormat: "{att_sql}---{attention}",//option的文字格式,用{}包住欄位,ex:{scode}_{sc_name}
            firstOpt: "<option value='0'>不指定</option>",//要在最上面額外增加option,ex:<option value='*'>全部<option>
            setValue: "0"//預設值
        });
    }

    cust23textform.SetReadOnly = function () {
        $("input[type=checkbox][name^='txt_del_']").hide();
        $("select[id^='txt_mark_type2_']").lock();
        $("select[id^='txt_att_sql_']").lock();
        $("textarea[id^='txt_type_content1']").lock();
        $("input[type=text][name^='txt_end_date']").lock();
        $("#ref_AddText_button").hide();
    }

    //篩選功能
    $("#filter_txt_mark_type2").on("change", function () {
        var thisValue = $('option:selected', $(this)).val();
        for (var r = 1; r <= CInt($("#htext_sql").val()); r++) {
            if (thisValue != "" && thisValue != $("#txt_mark_type2_" + r + " option:selected").val()) {
                $("#tr_txt_" + r).hide();
            } else {
                $("#tr_txt_" + r).show();
            }
        }
    })


</script>

