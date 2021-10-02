<%@Page Language="C#" CodePage="65001" validateRequest="false" %>
<%@Import Namespace = "System.Collections.Generic"%>
<%@Import Namespace = "System.Data.SqlClient"%>
<%@Import Namespace = "System.Data" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script runat="server">
    protected string HTProgCap = "電文內容維護作業-入檔";
    private string HTProgCode = HttpContext.Current.Request["prgid"];
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"];
    private int HTProgAcs = 1;
    private int HTProgRight = 0;

    protected string submitTask = "";
    protected string tf_code = "";
    protected string msg = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e)
    {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = Request["submitTask"].ToString();

        if ((Request["tf_code"] ?? "") != "") tf_code = Request["tf_code"].ToString();

        msg = "電文內容維護";
        
        Token myToken = new Token(HTProgCode, HTProgAcs);
        HTProgRight = myToken.CheckMe();
        
        if (HTProgRight >= 0)
        {
            if (submitTask == "A")
            {
                msg = msg + "-新增";
                ProcessAdd();
            }
            else if (submitTask == "U")
            {
                msg = msg + "-修改";
                ProcessUpdate();
            }
                            
            this.DataBind();
        }
    }

    private void ProcessUpdate()
    {
        //Response.Write("Session[\"sifdbs\"] = " + Session["sifdbs"].ToString() + "<BR>");

        msg = msg + "(電文代碼： " + Request["tf_code"] + Request["tf_name"] + ")";
        
        string isql = "";
        
        DBHelper conn = new DBHelper(Session["sifdbs"].ToString(), true).Debug(false);
        //Boolean result = true;
        try
        {
            int tf_cnt = 0;
            int tf_group_cnt = 0;
            // 先處理動態變數並且確認數量，之後再做insert update tfcode_imp
            String usql = "";
            
            //'---update tf_codep
            usql = "delete from tf_codep where tf_code='" + Request["tf_code"] + "'";
            conn.ExecuteNonQuery(usql);
            
            //(2- Request["sortfld_"+ i].Length).ToString()
            for (int i = 1; i <= int.Parse(Request["tf_cnt"]); i++)
            {
                if (Request["check_delete_" + i] != "on")
                {
                    usql = "insert into tf_codep(tf_code,tf_mod,sortfld,tf_name_use,tf_datatype," +
                    "tf_default,source_table,source_field,ctrl_input)" +
                    " values('" + Request["tf_code"] + "','" + Request["tf_mod_" + i] + "'," +
                    "'" + "0" + Request["sortfld_" + i] + "'," +
                    "'" + Request["tf_name_use_" + i] + "'," +
                    chkempty(Request["tf_datatype_" + i]) + "," + chkempty(Request["tf_default_" + i]) + "," +
                    chkempty(Request["source_table_" + i]) + "," + chkempty(Request["source_field_" + i]) + "," +
                    chkempty(Request["ctrl_input_" + i]) + ")";

                    //Response.Write("tf_codep table: <br>" + usql + "<br>");
                    conn.ExecuteNonQuery(usql);
                    tf_cnt++;
                }
                
            }

            usql = "delete from tf_codep_subject where tf_code='" + Request["tf_code"] + "'";
            conn.ExecuteNonQuery(usql);

            //Response.Write("tf_group_cnt: " + Request["tf_group_cnt"] + "<br>");
            
            for (int i = 1; i <= int.Parse(Request["tf_group_cnt"]); i++)
            {
                
                if (Request["check_delete2_" + i] != "on")
                {
                    String tf_column = "";
                    String tf_mark = "";
                    
                    if (Request["group_select_" + i] == "0")
                        tf_column = Funcs.ToBig5(Request["tf_text_value_" + i]);
                    else
                        tf_column = Funcs.ToBig5(Request["tf_mod2_" + i]);

                    tf_mark = Funcs.ToBig5(Request["tf_mark2_" + i]);
                    
                    String ctrl_show = "Y";
                    //if (Request["group_select_" + i] == "0")
                    //    ctrl_show = "N";

                    //Response.Write("source_field2_: " + Request["source_field2_" + i] + "<br>");
                    //Response.Write("check_show_: " + Request["check_show_" + i] + "<br>");

                    if (Request["source_field2_" + i] == "prior_date" || Request["source_field2_" + i] == "prior_no" || Request["source_field2_" + i] == "ctrl_date")
                    {
                        if (Request["check_show_" + i] != "on") ctrl_show = "N";
                    }
                    
                    usql = "insert into tf_codep_subject(tf_code,tf_column,sortfld,tf_datatype," +
                    "source_table,source_field,ctrl_show, tf_subject_type)" +
                    " values('" + Request["tf_code"] + "','" + tf_column + "'," +
                    "'" + Request["group_select_" + i].ToString() + Request["sortfld2_" + i] + "'," +
                    chkempty(Request["tf_datatype2_" + i]) + "," +
                    chkempty(Request["source_table2_" + i]) + "," + chkempty(Request["source_field2_" + i]) + "," +
                    chkempty(ctrl_show) + "," + chkempty(Request["tf_subject_type_" + i]) + ")";

                    //Response.Write("tf_codep_subject table: <br>" + usql + "<br>");
                    conn.ExecuteNonQuery(usql);
                    tf_group_cnt++;
                }                
            }

            isql = "update tfcode_imp set tf_type='" + Request["tf_type"] + "'," +
                    "tf_name='" + Request["tf_name"] + "',lang_code=" + chkempty(Request["ddl_lang_code"]) + "," +
                    "tf_class='" + Request["tf_class"] + "'," +
                    "tf_cnt='" + tf_cnt + "',tf_content='" + Funcs.ToBig5(Request["tf_content"].ToString()) + "'," +
                    "tf_sender1=" + chkempty(Request["tf_sender1"]) + ",tf_sender2=" + chkempty(Request["tf_sender2"]) + "," +
                    "tf_havefile='" + Request["tf_havefile"] + "',tf_content2='" + Funcs.ToBig5(Request["tf_content2"].ToString()) + "'," +
                    "tf_ag='" + Request["tf_ag"] + "',tf_rs='" + Request["tf_rs"] + "'," +
                    "rs_type=" + chkempty(Request["rs_type"]) + ",rs_class=" + chkempty(Request["form_rs_class"]) + "," +
                    "rs_code=" + chkempty(Request["form_rs_code"]) + ",act_code=" + chkempty(Request["form_act_code"]) + "," +
                    "rs_detail=" + chkempty(Request["rs_detail"]) + "," +
                    "send_way=" + chkempty(Request["htf_send_way"]) + ",send_way1=" + chkempty(Request["htf_send_way1"]) + "," +
                    "send_way_A5=" + chkempty(Request["htf_send_wayA5"]) + "," +
                    "pr_team=" + chkempty(Request["pr_team"]) + ",pr_scode=" + chkempty(Request["pr_scode"]) + "," +
                    "pr_teamj=" + chkempty(Request["pr_teamj"]) + ",pr_scodej=" + chkempty(Request["pr_scodej"]) + "," +
                    "beg_date=" + chknull(Request["beg_date"]) + ",end_date=" + chknull(Request["end_date"]) + "," +
                    "supply_scode=" + chkempty(Request["supply_scode"]) + ",tran_date=getdate(),tran_scode='" + Session["scode"] + "'," +
                    "use_grpid=" + chkempty(Request["use_grpid"]) + ",tf_remark=" + chkempty(Request["tf_remark"]) + "," +
                    "upd_code=" + chkempty(Request["upd_code"]) + ",mark=" + chkempty(Request["mark"]) + "," +
                    "chk_flag=" + chkempty(Request["hchk_flag"]) + "," +
                    "chk_scode=" + chkempty(Request["chk_scode"]) + ",chk_scodej=" + chkempty(Request["chk_scodej"]) + "," +
                    "canadd=" + chkempty(Request["canadd"]) + "," +
                    "pr_point=" + chkzero(Request["pr_point"]) + "," +
                    "chk_point=" + chkzero(Request["chk_point"]) + "," +
                    "qry_type1=" + chkempty(Request["qry_type1"]) +
                    ",tfext_flag=" + chkempty(Request["tfext_flag"]) + ",tf_content_head ='" + Funcs.ToBig5(Request["tf_content_head"].ToString()) + "', " +
                    "tf_group_cnt='" + tf_group_cnt + "', " + "us_prgids =" + chkempty(Request["us_prgids"]) + " " +
                    " where tf_code='" + Request["tf_code"] + "'";

            conn.ExecuteNonQuery(isql);
            
            //都沒問題 
            conn.Commit();
        }
        catch (Exception ex)
        {
            //result = false;
            conn.RollBack();
            msg += "失敗！";
            throw new Exception(msg, ex);
        }
        finally
        {
            conn.Dispose();
        }

        
        //Response.Write("<BR>isql = " + isql + "<BR>");
        msg += "成功！";
    }

    private void ProcessAdd()
    {
        //Response.Write("Session[\"sifdbs\"] = " + Session["sifdbs"].ToString() + "<BR>");

        msg = msg + "(電文代碼： " + Request["tf_code"] + Request["tf_name"] + ")";
        
        string isql = "";
        
        DBHelper conn = new DBHelper(Session["sifdbs"].ToString(), true).Debug(false);
        //Boolean result = true;
        try
        {
            isql = "insert into tfcode_imp(tf_code,tf_type,tf_name,lang_code,tf_class,tf_cnt," +
		            "tf_content,tf_sender1,tf_sender2,tf_havefile,tf_content2,tf_ag,tf_rs,rs_type,rs_class,rs_code,act_code," +
		            "rs_detail,send_way,send_way1,send_way_A5,pr_team,pr_scode,pr_teamj,pr_scodej," +
		            "beg_date,end_date,supply_scode,tran_date,tran_scode,use_grpid,tf_remark,upd_code,mark," +
                    "chk_flag,chk_scode,chk_scodej,canadd,pr_point,chk_point,qry_type1,tfext_flag, tf_content_head, tf_group_cnt, us_prgids)" +
		            " values('"+ Request["tf_code"] +"','"+ Request["tf_type"] +"','"+ Request["tf_name"] +"',"+
                    chkempty(Request["ddl_lang_code"]) + ",'" + Request["tf_class"] + "'," +
		            "'"+ Request["tf_cnt"] +"','"+ Funcs.ToBig5(Request["tf_content"]) +"'," +
		            chkempty(Request["tf_sender1"]) +","+ chkempty(Request["tf_sender2"]) +"," +
		            "'"+ Request["tf_havefile"] +"','"+ Funcs.ToBig5(Request["tf_content2"]) +"','"+ Request["tf_ag"] +"'," +
                    "'" + Request["tf_rs"] + "'," + chkempty(Request["rs_type"]) + "," + chkempty(Request["form_rs_class"]) + "," +
		            chkempty(Request["form_rs_code"]) +","+ chkempty(Request["form_act_code"]) +"," +
		            chkempty(Request["rs_detail"]) +","+
                    chkempty(Request["htf_send_way"]) + "," + chkempty(Request["htf_send_way1"]) + "," + chkempty(Request["htf_send_wayA5"]) + "," +
		            chkempty(Request["pr_team"]) +","+ chkempty(Request["pr_scode"]) +"," +
		            chkempty(Request["pr_teamj"]) +","+ chkempty(Request["pr_scodej"]) +","+
		            chknull(Request["beg_date"]) +","+ chknull(Request["end_date"]) +","+
                    chkempty(Request["supply_scode"]) + ",getdate(),'" + Session["scode"] + "'," +
		            chkempty(Request["use_grpid"]) +","+ chkempty(Request["tf_remark"]) +"," +
		            chkempty(Request["upd_code"]) +","+ chkempty(Request["mark"]) +","+
		            chkempty(Request["hchk_flag"]) +","+ chkempty(Request["chk_scode"]) +","+
		            chkempty(Request["chk_scodej"]) +","+ chkempty(Request["canadd"]) +"," +
		            chkzero(Request["pr_point"]) +","+ chkzero(Request["chk_point"]) +","+
                    chkempty(Request["qry_type1"]) + "," + chkempty(Request["tfext_flag"]) + ",'" + 
                    Funcs.ToBig5(Request["tf_content_head"].ToString()) + "'" + ", '" + Request["tf_group_cnt"] + "', " + chkempty(Request["us_prgids"]) + ")";


            conn.ExecuteNonQuery(isql);

            String usql = "";
            //'---update tf_codep
            usql = "delete from tf_codep where tf_code='" + Request["tf_code"] + "'";
            conn.ExecuteNonQuery(usql);
            
            //(2- Request["sortfld_"+ i].Length).ToString()
            if ((Request["tf_cnt"] ?? "") != "")
            {
                for (int i = 1; i <= int.Parse(Request["tf_cnt"]); i++)
                {
                    usql = "insert into tf_codep(tf_code,tf_mod,sortfld,tf_name_use,tf_datatype," +
                    "tf_default,source_table,source_field,ctrl_input)" +
                    " values('" + Request["tf_code"] + "','" + Request["tf_mod_" + i] + "'," +
                    "'" + "0" + Request["sortfld_" + i] + "'," +
                    "'" + Request["tf_name_use_" + i] + "'," +
                    chkempty(Request["tf_datatype_" + i]) + "," + chkempty(Request["tf_default_" + i]) + "," +
                    chkempty(Request["source_table_" + i]) + "," + chkempty(Request["source_field_" + i]) + "," +
                    chkempty(Request["ctrl_input_" + i]) + ")";

                    //Response.Write("tf_codep table: <br>" + usql + "<br>");

                    conn.ExecuteNonQuery(usql);
                }
            }

            usql = "delete from tf_codep_subject where tf_code='" + Request["tf_code"] + "'";
            conn.ExecuteNonQuery(usql);

            //Response.Write("tf_group_cnt: " + Request["tf_group_cnt"] + "<br>");
            
            for (int i = 1; i <= int.Parse(Request["tf_group_cnt"]); i++)
            {

                //Response.Write("check_delete2_: " + Request["check_delete2_" + i] + "<br>");

                if (Request["check_delete2_" + i] != "on")
                {
                    String tf_column = "";
                    if (Request["group_select_" + i] == "0")
                        tf_column = Funcs.ToBig5(Request["tf_text_value_" + i]);
                    else
                        tf_column = Funcs.ToBig5(Request["tf_mod2_" + i]);

                    String ctrl_show = "Y";
                    //if (Request["group_select_" + i] == "0")
                    //    ctrl_show = "N";

                    if (Request["source_field2_" + i] == "prior_date" || Request["source_field2_" + i] == "prior_no" || Request["source_field2_" + i] == "ctrl_date")
                    {
                        if (Request["check_show_" + i] != "on") ctrl_show = "N";
                    }
                    
                    usql = "insert into tf_codep_subject(tf_code,tf_column,sortfld,tf_datatype," +
                    "source_table,source_field,ctrl_show, tf_subject_type)" +
                    " values('" + Request["tf_code"] + "','" + tf_column + "'," +
                    "'" + Request["group_select_" + i].ToString() + Request["sortfld2_" + i] + "'," +
                    chkempty(Request["tf_datatype2_" + i]) + "," +
                    chkempty(Request["source_table2_" + i]) + "," + chkempty(Request["source_field2_" + i]) + "," +
                    chkempty(ctrl_show) + "," + chkempty(Request["tf_subject_type_" + i]) + ")";

                    //Response.Write("tf_codep_subject table: <br>" + usql + "<br>");
                    conn.ExecuteNonQuery(usql);
                }                
            }
            //都沒問題 
            conn.Commit();
        }
        catch (Exception ex)
        {
            //result = false;
            conn.RollBack();
            msg += "失敗！";
            throw new Exception(msg, ex);
        }
        finally
        {
            conn.Dispose();
        }

        //Response.Write("<BR>isql = " + isql + "<BR>");
        msg += "成功！";
    }
    
    private String chkempty(String arg)
    {
        if ((arg ?? "") == "") return "''";
        if (arg.Trim() != ""){		
            arg = "'" + arg + "'";
        }
        else {
            arg = "''";
        }
        return arg;
    }

    private String chknull(String arg)
    {
        if ((arg ?? "") == "") return "null";
        if (arg.Trim() != "")
        {
            arg = "'" + arg + "'";
        }
        else
        {
            arg = "null";
        }
        return arg;
    }

    private String chkzero(String arg)
    {
        if ((arg ?? "") == "") return "'0'";
        if (arg.Trim() != "")
        {
            arg = "'" + arg + "'";
        }
        else
        {
            arg = "'0'";
        }
        return arg;
    }
</script>


<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<body>
    <input type="hidden" id="prgid" name="prgid"   value="<%=Request["prgid"].ToString()%>"/>
</body>
</html>

<script type="text/javascript" language="javascript">

    if (!(window.parent.parent.tt == undefined)) {
        window.parent.tt.rows = "100%,0%";
    } else {        
        if ("<%#submitTask%>" == "A")
            window.parent.tt.rows = "20%,80%";
        else
            window.parent.tt.rows = "100%,0%";

        //alert("<%#submitTask%>");
        window.parent.Etop.goSearch();

        if ("<%#submitTask%>" == "A") {
            
            window.location.href = "nimp851Edit.aspx?submitTask=U&prgid=" + $("#prgid").val() + "&tf_code=<%=tf_code%>&radStat=0&nowPage=1&lang_code=<%=Request["ddl_lang_code"].ToString()%>";
        }
        else if ("<%#submitTask%>" == "U") {
            
            //window.location.href = "Agent91_Query.aspx?submitTask=UT&prgid=" + $("#prgid").val() + "&code_type=Agent_cust_code&parent_name=代理人系統代碼";
        }
        
        //window.close();
    }

    alert("<%#msg%>");

</script>
