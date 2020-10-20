<%@ Control Language="C#" ClassName="Brt11FormA9Z" %>
<%@ Register Src="~/brt1m/CaseForm/A9Z_end.ascx" TagPrefix="uc1" TagName="A9Z_end" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //A5分割案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string ar_form = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        ar_form = (Request["ar_form"] ?? "").Trim();
        PageLayout();
        this.DataBind();
    }
    
    private void PageLayout() {

        //交辦內容欄位畫面
        if (ar_form == "A3") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FFForm.ascx"));//註冊費
        } else if (ar_form == "A4") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FR1Form.ascx"));//延展
        } else if (ar_form == "A5") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FD1Form.ascx"));//分割
        } else if (ar_form == "A6") {
            //tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FC1Form.ascx"));//變更
        } else if (ar_form == "A7") {
            //tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FL1Form.ascx"));//授權
        } else if (ar_form == "A8") {
            //tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FT1Form.ascx"));//移轉
        } else if (ar_form == "A9") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FP1Form.ascx"));//質權
        } else if (ar_form == "AA") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FN1Form.ascx"));//各種證明書
        } else if (ar_form == "AB") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FI1Form.ascx"));//補(換)發證
        } else if (ar_form == "AC") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FV1Form.ascx"));//閲案
        } else if (ar_form == "B") {
            //tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/DO1Form.ascx"));//申請異議
            //tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/DR1Form.ascx"));//申請廢止
            //tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/DI1Form.ascx"));//申請評定
            //tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/BZZ1Form.ascx"));//無申請書之交辦內容案
            //tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/B5C1Form.ascx"));//聽證
        } else {
            //tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/ZZ1Form.ascx"));
            //tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FOBForm.ascx"));
            //tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/B5C1Form.ascx"));
            //tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FOFForm.ascx"));
            //tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FB7Form.ascx"));
        }
    }
</script>
<script language="javascript" type="text/javascript">
    var br_form = {};
    br_form.init = function () {
    }
</script>
<%=Sys.GetAscxPath(this)%>
<asp:PlaceHolder ID="tranHolder" runat="server"></asp:PlaceHolder><!--交辦內容.依ar_form動態載入form-->
<uc1:A9Z_end runat="server" ID="A9Z_end" />
<!--include file="../brt1m/CaseForm/A9Z_end.ascx"--><!--結案復案資料-->

