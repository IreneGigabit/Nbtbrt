<%@ Page Language="C#" CodePage="65001" AutoEventWireup="true"  %>
<%@ Import Namespace="System.Data" %>
<%@Import Namespace = "System.Text"%>
<%@Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<!DOCTYPE html>

<script runat="server">
    protected string isql = "";
    protected string tsql = "";


    string att_string = "";
    int att_cnt = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        //Response.Write(Server.MapPath("~/Agent7m") + "<br /><br />");

        //Response.Write(Session["sifdbs"].ToString() + "<br /><br />");
        
        using (DBHelper conn = new DBHelper(Session["sifdbs"].ToString()).Debug(false))
        {
            // REPLACE 是為了處理全形空格
            isql = "select a.*, ";
            isql += "(select code_name from cust_code where code_type = 'tf_class' and cust_code = a.tf_class) as tf_classnm, ";
            isql += "(select sc_name from sysctrl.dbo.scode where scode=a.pr_scode) as pr_scodenm, ";

            isql += "(select sc_name from sysctrl.dbo.scode where scode=a.pr_scodej) as pr_scodejnm, ";

            isql += "(select sc_name from sysctrl.dbo.scode where scode=a.chk_scode) as chk_scodenm, ";
            isql += "(select sc_name from sysctrl.dbo.scode where scode=a.chk_scodej) as chk_scodejnm, ";
            isql += "(select sc_name from sysctrl.dbo.scode where scode=a.supply_scode) as supply_scodenm, ";
            isql += "isnull((select code_name from cust_code where code_type='tf_sender1' and cust_code=a.tf_sender1), '') as tf_sender1nm, ";
            isql += "isnull((select code_name from cust_code where code_type='tf_sender2' and cust_code=a.tf_sender2), '') as tf_sender2nm, ";
            isql += "isnull((select code_name from cust_code where code_type='tfhavefile' and cust_code=a.tf_havefile), '') as tf_havefilenm ";
            isql += " from tfcode_imp a ";
            isql += " where a.tf_code=a.tf_code ";
            
            if ((Request["qrytf_code"] ?? "") != "")
                isql += " and a.tf_code = '" + Request["qrytf_code"].ToString().Trim() + "'";

            if ((Request["qrytf_name"] ?? "") != "")
                isql += " and a.tf_name like '%" + Request["qrytf_name"].ToString().Trim() + "%'";

            if ((Request["qrytf_class"] ?? "") != "")
                isql += " and a.tf_class = '" + Request["qrytf_class"].ToString().Trim() + "'";

            if ((Request["qrytf_ag"] ?? "") != "")
                isql += " and a.tf_ag = '" + Request["qrytf_ag"].ToString().Trim() + "'";

            if ((Request["qrytf_rs"] ?? "") != "")
                isql += " and a.tf_rs = '" + Request["qrytf_rs"].ToString().Trim() + "'";

            if ((Request["qrywork_team"] ?? "") != "")
                isql += " and (a.pr_team = '" + Request["qrywork_team"].ToString().Trim() + "' or a.pr_teamj = '" + Request["qrywork_team"].ToString().Trim() + "')";

            if ((Request["qrywork_scode"] ?? "") != "")
                isql += " and (a.pr_scode = '" + Request["qrywork_scode"].ToString().Trim() + "' or a.pr_scodej = '" + Request["qrywork_scode"].ToString().Trim() + "')";
                        
            if ((Request["qrybeg_date"] ?? "") != "")
                isql += " and a.beg_date >= '" + Request["qrybeg_date"].ToString().Trim() + "'";

            if ((Request["qryend_date"] ?? "") != "")
                isql += " and a.end_date <= '" + Request["qryend_date"].ToString().Trim() + "'";

            if ((Request["radStat"] ?? "") == "0") // 使用中
                isql += " and (a.end_date>getdate() or a.end_date is null) ";
            else if ((Request["radStat"] ?? "") == "1") // 已停用
                isql += " and a.end_date<=getdate() ";

            if ((Request["lang_code"] ?? "") != "")
                isql += " and a.lang_code = '" + Request["lang_code"].ToString().Trim() + "'";
            
            isql += " order by a.tf_code";

            //Response.Write(Request["radStat"] + "<br /><br />");
            //Response.Write(isql + "<br /><br />");
            //return;

            DataTable dt = new DataTable();
            conn.DataTable(isql, dt);

            //Response.Write(x + "<br />");
            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
            Paging page = new Paging(nowPage, PerPageSize);
            page.GetPagedTable(dt);

            //分頁完再處理其他資料才不會虛耗資源
            //for (int i = 0; i < page.pagedTable.Rows.Count; i++)
            //{

            //}

            string str_json = JsonConvert.SerializeObject(page, Formatting.Indented);
            Response.Write(str_json);
            Response.End();
        }

    }
</script>
