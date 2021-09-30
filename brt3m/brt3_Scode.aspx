<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>

<script runat="server">
    protected string SQL = "";

    protected string fld1 = "";//簽核者
    protected string fld2 = "";//回傳的select欄位名
    protected string fld3 = "";//dept/prgid
    protected StringBuilder strOut = new StringBuilder();

    protected void Page_Load(object sender, EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        fld1 = (Request["fld1"] ?? "").Trim();
        fld2 = (Request["fld2"] ?? "").Trim();
        fld3 = (Request["fld3"] ?? "").Trim().ToLower();

        string apcode = "", tblname = "";
        switch (fld3) {
            case "t":
                apcode = "'Si04W02','brt31','brt63'";//國內交辦案主管簽核//國內案官發簽核作業//改版後有新舊代碼
                tblname = "si" + Session["seBranch"] + "dbs.dbo.todo_dmt";
                break;
            case "e":
                apcode = "'Si04W06','ext34','ext61'";//改版後有新舊代碼
                tblname = "si" + Session["seBranch"] + "dbs.dbo.todo_ext";
                break;
            case "x":
                apcode = "'ext14'";
                tblname = "si" + Session["seBranch"] + "dbs.dbo.todo_ext";
                break;
            case "endt"://國內結案簽核
                apcode = "'brt7b','brt3f'";
                tblname = "si" + Session["seBranch"] + "dbs.dbo.todo_dmt";
                break;
            case "ende"://出口結案簽核
                apcode = "'extdh'";
                tblname = "si" + Session["seBranch"] + "dbs.dbo.todo_ext";
                break;
            case "trant0"://轉案簽核
                apcode = "'brt1b'";
                tblname = "si" + Session["seBranch"] + "dbs.dbo.todo_dmt";
                break;
            case "trane0"://轉案簽核
                apcode = "'brt1b'";
                tblname = "si" + Session["seBranch"] + "dbs.dbo.todo_ext";
                break;
            case "trant"://確認轉案簽核
                apcode = "'brt3h','brt3h1'";
                tblname = "si" + Session["seBranch"] + "dbs.dbo.todo_dmt";
                break;
            case "trane"://確認轉案簽核
                apcode = "'ext3h','ext3h1'";
                tblname = "si" + Session["seBranch"] + "dbs.dbo.todo_ext";
                break;
            default:
                if (fld3.Right(2) == "81" || fld3.Right(2) == "di") {
                    apcode = fld3;
                    tblname = "sysctrl.dbo.todolist";
                } else {
                    apcode = "'Ext61','ext14','ext161','ext3a'";
                    tblname = "si" + Session["seBranch"] + "dbs.dbo.todo_ext";
                }
                break;
        }

        DBHelper conn = null;
        try {
            if (fld3.Right(2) == "81") {
                SQL = "select A.IN_scode,d.sc_name ";
                SQL += "from sysctrl.dbo.todolist A ";
                SQL += "inner join scode D on a.in_scode = d.scode ";
                SQL += "where a.job_status='NN' and a.job_scode='" + fld1 + "' ";
                SQL += "and a.syscode='" + Session["syscode"] + "' ";
                SQL += "and apcode in(" + apcode + ") ";
                SQL += "group by a.in_scode,d.sc_name";
                conn = new DBHelper(Conn.Sysctrl);
            } else if (fld3 == "brt1a") {//國內爭救案交辦專案室抽件簽核
                SQL = "select A.IN_scode,d.sc_name ";
                SQL += "from todo_opt A inner join sysctrl.dbo.scode D on a.in_scode = d.scode ";
                SQL += "where a.job_status='NN' and a.job_scode='" + fld1 + "' and a.syscode='" + Session["syscode"] + "' and apcode='" + fld3 + "' ";
                SQL += "group by a.in_scode,d.sc_name";
                conn = new DBHelper(Conn.optK);
            } else {
                //2010/5/21因應todo_ext/todo_dmt修改
                SQL = "select A.case_IN_scode as in_scode,d.sc_name ";
                SQL += "from " + tblname + " A ";
                SQL += "inner join scode D on a.case_in_scode = d.scode ";
                SQL += "where a.job_status='NN' and a.job_scode='" + fld1 + "' ";
                SQL += "and a.syscode='" + Session["syscode"] + "' ";
                SQL += "and apcode in(" + apcode + ") ";
                SQL += "group by a.case_in_scode,d.sc_name";
                conn = new DBHelper(Conn.Sysctrl);
            }
            //strOut.AppendLine("console.log('" + SQL.Replace("'","\\'") + "')");
            
            strOut.AppendLine("var obj = $('#" + fld2 + "')");
            strOut.AppendLine("obj.empty();");
            strOut.AppendLine("obj.append(\"<option value='' style='COLOR:blue'>請選擇</option>\");");
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                while (dr.Read()) {
                    strOut.AppendLine("obj.append(\"<option value='" + dr.SafeRead("in_scode", "") + "'>" + dr.SafeRead("sc_name", "") + "</option>\");");
                }
            }
        }
        catch (Exception ex) {
            throw;
        }
        finally {
            conn.Dispose();
        }
    }
</script>

<%=strOut.ToString()%>
