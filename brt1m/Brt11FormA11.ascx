<%@ Control Language="C#" ClassName="Brt11FormA11" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/brt1m/brtform/CaseForm/FA1Form.ascx" TagPrefix="uc1" TagName="FA1Form" %>


<script runat="server">
    private void Page_Load(System.Object sender, System.EventArgs e) {
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<uc1:FA1Form runat="server" ID="FA1Form" />

<script language="javascript" type="text/javascript">
    //依案性切換要顯示的欄位
    main.changeTag = function (T1) {
        var code3 = T1.substr(2, 1).toUpperCase();//案性第3碼
        //壹、商標圖樣(依案性第3碼切換顯示)
        $("#td_br_appl").empty();
        var copyStr = $("script.tabbr_appl_" + code3).text() || "";
        $("#td_br_appl").append(copyStr);
        //$(".tabbr_appl_0").hide();
        //$(".tabbr_appl_"+code3).show();

        //參、展覽會優先權聲明(依案性第3碼切換顯示)
        if ($("#td_br_show .tabbrshow_" + code3).length == 0) {
            $("#td_br_show").empty();
            var copyStr = $("script.tabbrshow_" + code3).text() || "";
            $("#td_br_show").append(copyStr);
            if (copyStr == "") {
                $("#td_br_show").closest("tr").hide();
            } else {
                $("#td_br_show").closest("tr").show();
            }
        }
        //$(".tabbrshow_0").hide();
        //$(".tabbrshow_"+code3).show();

        //伍、團體標章表彰之內容
        //陸、標章證明標的及內容(依案性第3碼切換顯示)
        if ($("#td_br_good .tabbrgood_" + code3).length == 0) {
            $("#td_br_good").empty();
            var copyStr = $("script.tabbrgood_" + code3).text() || "";
            $("#td_br_good").append(copyStr);
            if (copyStr == "") {
                $("#td_br_good").closest("tr").hide();
            } else {
                $("#td_br_good").closest("tr").show();
            }
        }
        //$(".tabbrgood_0").hide();
        //$(".tabbrgood_"+code3).show();

        //陸、指定使用商品／服務類別及名稱(依案性第3碼切換顯示)
        if ($("#td_br_class .tabbrclass_" + code3).length == 0) {
            $("#td_br_class").empty();
            var copyStr = $("script.tabbrclass_" + code3).text() || "";
            $("#td_br_class").append(copyStr);
            if (copyStr == "") {
                $("#td_br_class").closest("tr").hide();
            } else {
                $("#td_br_class").closest("tr").show();
                br_form.Add_class(1);//預設顯示第1筆
            }
        }
        //$(".tabbrclass_0").hide();
        //$(".tabbrclass_"+code3).show();

        //附件(以案性第3碼判斷要show哪個附件)
        $("#td_br_remark1").empty();
        $("#tfz1_remark1").val("");
        var copyStr = $("script#tabbr_remark1_" + code3).text() || "";
        $("#td_br_remark1").append(copyStr);


        //***商標種類及畫面顯示
        var txtType0 = "", txtType1 = "";
        switch (code3) {
            case '5': case '6': case '7': case '8':
                txtType0 = "團體商標";
                txtType1 = "商標";
                $("input[name=span_mark1][value='N']").prop("checked", true);//團體商標
                break;
            case '9': case 'A': case 'B': case 'C':
                txtType0 = "團體標章";
                txtType1 = "標章";
                $("input[name=span_mark1][value='M']").prop("checked", true);//團體標章
                break;
            case 'D': case 'E': case 'F': case 'G':
                txtType0 = "證明標章";
                txtType1 = "標章";
                $("input[name=span_mark1][value='L']").prop("checked", true);//證明標章
                break;
            default:
                txtType0 = "商標";
                txtType1 = "商標";
                $("input[name=span_mark1][value='']").prop("checked", true);//商標
                break;
        }
        $(".txtMark0").html(txtType0);
        $(".txtMark1").html(txtType1);
        $("#tfz1_S_Mark").val($("input[name='span_mark1']:checked").val());

        //***商標種類2
        switch (code3) {
            case '4': case '8': case 'C': case 'G'://立體
                $("input[name=tfz1_s_mark2][value='B']").prop("checked", true);
                if (code3 == "8") {
                    $("#span_FA151").html("詳細說明所欲註冊之內容，不屬於立體商標之虛線部份應一併說明");
                } else if (code3 == "C") {
                    $("#span_FA151").html("標章");
                } else if (code3 == "G") {
                    $("#span_FA151").html("標章");
                } else {
                    $("#span_FA151").html("詳細說明所欲註冊之內容，不屬於立體商標之虛線部份應一併說明");
                }
                break;
            case '3': case '7': case 'B': case 'F'://聲音
                $("input[name=tfz1_s_mark2][value='C']").prop("checked", true);
                break;
            case '2': case '6': case 'A': case 'E'://顏色
                $("input[name=tfz1_s_mark2][value='D']").prop("checked", true);
                if (code3 == "6") {
                    $("#span_FA151").html("<INPUT TYPE=radio NAME=tfz1_remark3 value=商品>商品、<INPUT TYPE=radio NAME=tfz1_remark3 value=包裝>包裝、<INPUT TYPE=radio NAME=tfz1_remark3 value=容器>容器之形狀、或<INPUT TYPE=radio NAME=tfz1_remark3 value=營業物>營業相關物品之形狀，不屬於團體商標");
                } else if (code3 == "A") {
                    $("#span_FA151").html("<INPUT TYPE=radio NAME=tfz1_remark3 value=相關物品>相關物品或<INPUT TYPE=radio NAME=tfz1_remark3 value=文書>文書之形狀，不屬於團體標章");
                } else if (code3 == "E") {
                    $("#span_FA151").html("<INPUT TYPE=radio NAME=tfz1_remark3 value=商品>商品、<INPUT TYPE=radio NAME=tfz1_remark3 value=包裝>包裝、<INPUT TYPE=radio NAME=tfz1_remark3 value=容器>容器之形狀、或<INPUT TYPE=radio NAME=tfz1_remark3 value=營業物>營業相關物品之形狀，不屬於顏色標章");
                } else {
                    $("#span_FA151").html("<INPUT TYPE=radio NAME=tfz1_remark3 value=商品>商品、<INPUT TYPE=radio NAME=tfz1_remark3 value=包裝>包裝、<INPUT TYPE=radio NAME=tfz1_remark3 value=容器>容器之形狀、或<INPUT TYPE=radio NAME=tfz1_remark3 value=營業物>營業相關物品之形狀，不屬於顏色商標");
                }
                break;
            case 'I'://全像圖
                $("input[name=tfz1_s_mark2][value='E']").prop("checked", true);
                $("#span_FA150").html("及樣本");
                $("#span_FA151").html("詳細說明全像圖的全像效果，如因視角差異產生圖像變化，應說明各視圖的變化情形，不屬於全像圖商標之虛線部份應一併說明，並得檢送商標樣本");
                break;
            case 'J'://動態
                $("input[name=tfz1_s_mark2][value='F']").prop("checked", true);
                $("#span_FA150").html("及樣本");
                $("#span_FA151").html("詳細說明個別靜止圖像的排列順序及變化過程，如包含聲音及不屬於動態商標之虛線部分者，應一併說明，並應檢送圖像變化之AVI或MPEG檔光碟片");
                break;
            case 'K'://其他商標不可預設
                $("input[name=tfz1_s_mark2]").prop("checked", false);
                $("#span_FA150").html("及樣本");
                $("#span_FA151").html("對商標本身及其使用於商品或服務情形所為之相關說明，並提供商標樣本供審查參考");
                break;
            default://平面
                $("input[name=tfz1_s_mark2][value='A']").prop("checked", true);
                break;
        }

        //***表彰預設申請人
        var tfap_cname = "";
        for (var papnum = 1; papnum <= CInt($("#apnum").val()) ; papnum++) {
            tfap_cname += $("#ap_cname1_" + papnum).val() + $("#ap_cname2_" + papnum).val() + "、";
        }
        $("#tf91_good_name").val(tfap_cname.substring(0, tfap_cname.length - 1));

        //切換後重新綁資料
        br_form.bind();
    }

    <!--#include virtual="~\brt1m\A11_bind.js" -->//資料綁定(main.bind)

    <!--#include virtual="~\brt1m\A11_savechk.js" -->//存檔檢查(main.savechk)
</script>