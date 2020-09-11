<%@ Control Language="C#" ClassName="prior_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string tfz_country = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        //國家
        tfz_country = Sys.getCountry().Option("{coun_code}", "{coun_code}-{coun_c}");
        this.DataBind();
    }
</script>

<tr>
	<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(ztextp)"><strong>貳、<u>優先權聲明</u></strong></td>
</tr>
<tr>
	<td class="lightbluetable" align="right">申請日：</td>
	<td class="whitetablebg" colspan="3"><input TYPE="text" NAME="pfz1_prior_date" SIZE="10" class="dateField">
	</TD>
	<td class="lightbluetable" align="right">首次申請國家：</td>
	<td class="whitetablebg">
        <select NAME="tfz1_prior_country" SIZE="1"><%#tfz_country%></select>
		申請案號：<input type="text" name=tfz1_prior_no size=20 maxlength="20">
	</td>
</tr>

