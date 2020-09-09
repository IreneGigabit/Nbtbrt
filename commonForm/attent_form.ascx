<%@ Control Language="C#" Classname="attent_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    public Dictionary<string, string> Lock = new Dictionary<string, string>();
    protected string cust_area = "";
    protected string cust_seq = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        cust_area = Request["cust_area"] ?? "";
        cust_seq = Request["cust_seq"] ?? "";
        
        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<TR>
		<td class="lightbluetable" align="right">客戶編號：</td>
		<td class="whitetablebg" colspan=3>
		<input TYPE="text" id="tfy_cust_area" name="tfy_cust_area" size="1" readonly class="SEdit">-
		<input TYPE="text" id="tfy_cust_seq" name="tfy_cust_seq" size="8" readonly class="SEdit"></td>
	</TR>
	<TR>
		<td class="lightbluetable" align="right">聯絡人：</td>
		<td class="whitetablebg">
            <select id=tfy_att_sql name=tfy_att_sql></select>
            <input type="button" value="重新整理" id="toclick">
        </td>
		<TD class=lightbluetable align=right>所屬部門：</TD>
		<TD class=whitetablebg><INPUT TYPE=text id=dept name=dept readonly class="SEdit"></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>職稱：</TD>
		<TD class=whitetablebg><INPUT TYPE=text id=att_title SIZE=11 MAXLENGTH=10 readonly class="SEdit"></TD>		
		<TD class=lightbluetable align=right>聯絡部門：</TD>
		<TD class=whitetablebg><INPUT TYPE=text id=att_dept SIZE=22 MAXLENGTH=20 readonly class="SEdit"></TD>
	</TR>
	<TR>
		<td class="lightbluetable" align="right">聯絡公司：</td>
		<td class="whitetablebg">
			<input TYPE="text" id="att_company" name="att_company" SIZE="40" MAXLENGTH="60" class="SEdit" readonly >
		</td>
		<TD class=lightbluetable align=right>聯絡電話：</TD>
		<TD class=whitetablebg>
            (<INPUT TYPE=text id=att_tel0 name=att_tel0 SIZE=4 MAXLENGTH=4 readonly class="SEdit" />)
		    <INPUT TYPE=text id=att_tel SIZE=16 MAXLENGTH=15 readonly class="SEdit">-<INPUT TYPE=text id=att_tel1 SIZE=5 MAXLENGTH=5 readonly class="SEdit">
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>行動電話：</TD>
		<TD class=whitetablebg><INPUT TYPE=text id=att_mobile SIZE=11 MAXLENGTH=10 readonly class="SEdit"></TD>		
		<TD class=lightbluetable align=right>傳真號碼：</TD>
		<TD class=whitetablebg><INPUT TYPE=text id=att_fax SIZE=16 MAXLENGTH=15 readonly class="SEdit"></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>聯絡地址：</TD>
		<TD class=whitetablebg colspan=3>
		    <INPUT TYPE=text id=att_zip SIZE=8 MAXLENGTH=8 readonly class="SEdit">
		    <INPUT TYPE=text id=att_addr1 SIZE=33 MAXLENGTH=30 readonly class="SEdit">
		    <INPUT TYPE=text id=att_addr2 SIZE=33 MAXLENGTH=30 readonly class="SEdit">
		</TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>電子郵件：</TD>
		<TD class=whitetablebg colspan=3><INPUT TYPE=text id=Att_email SIZE=44 MAXLENGTH=40 readonly class="SEdit"></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>郵寄雜誌：</TD>
		<TD class=whitetablebg colspan=3><INPUT TYPE=text id=att_mag size=22 readonly class="SEdit"></TD>				  
	</TR>
</table>
<script language="javascript" type="text/javascript">
    var attent_form = {};
    attent_form.att_list = {};
    attent_form.init = function () {
    }

    //取得聯絡人資料
    attent_form.getatt = function (cust_area,cust_seq) {
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_custz_att.aspx?cust_area=" + cust_area + "&cust_seq=" + cust_seq,
            async: false,
            cache: false,
            success: function (json) {
                if ($("#chkTest").prop("checked")) toastr.info("<a href='" + this.url + "' target='_new'>Debug(_custz_att)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                attent_form.att_list = $.parseJSON(json);
                if (attent_form.att_list == 0) {
                    toastr.warning("無該客戶聯絡人資料!!!");
                    return false;
                }
                $("#tfy_att_sql").getOption({//聯絡人清單
                    dataList: attent_form.att_list,
                    valueFormat: "{att_sql}",
                    textFormat: "{att_sql}---{attention}"
                });
                $("#tfy_att_sql option[value!='']").eq(0).prop('selected', true);
                $("#tfy_att_sql").triggerHandler("change");
            },
            error: function () { toastr.error("<a href='" + this.url + "' target='_new'>客戶資料載入失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>"); }
        });
    }

    //重新整理
    $("#toclick").click(function () {
        attent_form.getatt($("#tfy_cust_area").val() ,$("#tfy_cust_seq").val());
    });


    //選聯絡人帶資料
    $("#tfy_att_sql").change(function () {
        var val = $(this).val();
        $.each(attent_form.att_list, function (idx, obj) {
            if (obj.att_sql == val) {
                $("#dept").val(obj.deptnm);
                $("#att_title").val(obj.att_title);
                $("#att_dept").val(obj.att_dept);
                $("#att_company").val(obj.att_company);
                $("#att_tel0").val(obj.att_tel0);
                $("#att_tel").val(obj.att_tel);
                $("#att_tel1").val(obj.att_tel1);
                $("#att_mobile").val(obj.att_mobile);
                $("#att_fax").val(obj.att_fax);
                $("#att_zip").val(obj.att_zip);
                $("#att_addr1").val(obj.att_addr1);
                $("#att_addr2").val(obj.att_addr2);
                $("#Att_email").val(obj.att_email);
                $("#att_mag").val(obj.magnm);
                return;
            }
        });
    });

</script>
