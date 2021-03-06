﻿<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Text"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Web.Script.Serialization"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string SQL = "";

    protected int right = 0;
    protected string prgid = "";
    protected string submitTask = "";
    protected string formfunction = "";
    protected string in_no = "";
    protected string cust_area = "";
    protected string cust_seq = "";
    protected string code_type = "";

    protected string br_in_scode = "";//交辦單營洽
    protected string br_in_scname = "";//交辦單營洽
    
    Sys sfile = new Sys();

    protected void Page_Load(object sender, EventArgs e) {
        prgid = (Request["prgid"] ?? "").Trim().ToLower();
        right = Convert.ToInt32(Request["right"] ?? "0");
        submitTask = (Request["submitTask"] ?? "").Trim();
        formfunction = (Request["formfunction"] ?? "").Trim();
        in_no = (Request["in_no"] ?? "").Trim();
        cust_area = (Request["cust_area"] ?? "").Trim();
        cust_seq = (Request["cust_seq"] ?? "").Trim();
        code_type = (Request["code_type"] ?? "").Trim();
        
        br_in_scode = Sys.GetSession("scode");
        br_in_scname = Sys.GetSession("sc_name");
        sfile.getFileServer(Sys.GetSession("SeBranch"), "brt");//檔案上傳相關設定

        var settings = new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
            Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
        };
        
        Response.Write("{");
        Response.Write("\"case_main\":" + JsonConvert.SerializeObject(GetCase(), settings).ToUnicode() + "\n");
        Response.Write(",\"case_item\":" + JsonConvert.SerializeObject(GetCaseItem(), settings).ToUnicode() + "\n");
        Response.Write(",\"case_good\":" + JsonConvert.SerializeObject(GetCaseGood(), settings).ToUnicode() + "\n");
        Response.Write(",\"case_show\":" + JsonConvert.SerializeObject(GetCaseShow(), settings).ToUnicode() + "\n");
        Response.Write(",\"case_attach\":" + JsonConvert.SerializeObject(GetCaseAttach(), settings).ToUnicode() + "\n");
        Response.Write(",\"case_tran\":" + JsonConvert.SerializeObject(GetCaseTran(), settings).ToUnicode() + "\n");
        Response.Write(",\"case_tranlist\":" + JsonConvert.SerializeObject(GetCaseTranlist(), settings).ToUnicode() + "\n");
        Response.Write(",\"cust\":" + JsonConvert.SerializeObject(GetCust(), settings).ToUnicode() + "\n");
        //Response.Write(",\"salesList\":" + JsonConvert.SerializeObject(GetSales(), settings).ToUnicode() + "\n");
        Response.Write(",\"br_in_scode\":" + JsonConvert.SerializeObject(br_in_scode, settings).ToUnicode() + "\n");
        Response.Write(",\"br_in_scname\":" + JsonConvert.SerializeObject(br_in_scname, settings).ToUnicode() + "\n");
        Response.Write("}");

        //Response.Write(JsonConvert.SerializeObject(dt, settings).ToUnicode());
    }

    #region GetCase 交辦資料
    //private JObject GetCase() {
    //    JObject obj = new JObject();
    //    obj.Add("cust_area", JToken.FromObject(cust_area));
    //    obj.Add("cust_seq", JToken.FromObject(cust_seq));
    //    obj.Add("cust_seq", JToken.FromObject(cust_seq));
    //    return obj;
    //}

    private DataTable GetCase() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            //Dictionary<string, string> paras = new Dictionary<string, string>();
            //paras.Add("nIn_no", in_no);
            //conn.Procedure("Pro_case2", paras, dt);
            //if (formfunction == "Add" && submitTask != "AddNext") {//新增模式
            //    SQL = "SELECT A.*, B.*,''in_no ";
            //    SQL += ",(select min(att_sql) from custz_att c where B.cust_area = C.cust_area AND B.cust_seq = C.cust_seq and (dept='T' or dept is null) )att_sql ";
            //    SQL += " FROM apcust A ";
            //    SQL += "INNER JOIN custz B ON A.cust_area = B.cust_area AND A.cust_seq = B.cust_seq ";
            //    //SQL += " LEFT OUTER JOIN custz_att C ON B.cust_area = C.cust_area AND B.cust_seq = C.cust_seq ";
            //    SQL += "where b.cust_area='" + cust_area + "' and b.cust_seq='" + cust_seq + "'";
            //    conn.DataTable(SQL, dt);
            //} else {//編輯/複製 模式
            //    SQL = "Pro_case2 '" + in_no + "'";
            //    conn.DataTable(SQL, dt);
            //}
            if (submitTask == "Edit" || submitTask == "AddNext") {//編輯/複製下一筆 模式
                SQL = "Pro_case2 '" + in_no + "'";
                conn.DataTable(SQL, dt);

                if (dt.Rows.Count > 0) {
                    code_type = dt.Rows[0].SafeRead("arcase_type", "");
                    br_in_scode = dt.Rows[0].SafeRead("in_scode", "");

                    if (submitTask == "AddNext") {//圖様改為新檔名
                        if (dt.Rows[0].SafeRead("draw_file", "") != "") {
                            System.IO.FileInfo sFi = new System.IO.FileInfo(HttpContext.Current.Server.MapPath(Sys.Path2Nbtbrt(dt.Rows[0].SafeRead("draw_file", ""))));
                            string strpath1 = sfile.gbrWebDir + "/temp";
                            string newName = br_in_scode + "-" + Path.GetFileName(dt.Rows[0].SafeRead("draw_file", ""));
                            sFi.CopyTo(Server.MapPath(Sys.Path2Nbtbrt(strpath1 + "/" + newName)), true);
                            dt.Rows[0]["draw_file"] = strpath1 + "/" + newName;
                        }
                    }
                    
                    SQL = "select sc_name from sysctrl.dbo.scode where scode='" + br_in_scode + "'";
                    object objResult = conn.ExecuteScalar(SQL);
                    br_in_scname = (objResult == DBNull.Value || objResult == null) ? "" : objResult.ToString();
                }

            }
        }
        return dt;
    }
    #endregion

    #region GetCaseItem 交辦費用
    private DataTable GetCaseItem() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "select a.item_sql,a.item_arcase,a.item_count,a.item_service,a.item_fees,b.prt_code,b.remark,c.service,c.fees,c.others,c.oth_code,c.oth_code1 ";
            SQL += "from caseitem_dmt a ";
            SQL += "inner join code_br b on  a.item_arcase=b.rs_code AND b.no_code='N' and b.rs_type='" + code_type + "' ";
            SQL += "left outer join case_fee c on c.dept='T' and c.country='T' and c.rs_code=a.item_arcase and getdate() between c.beg_date and c.end_date ";
            SQL += "where a.in_no= '" + in_no + "' and a.in_scode='" + br_in_scode + "' ";
            SQL += "order by a.item_sql";
            conn.DataTable(SQL, dt);
        }
        return dt;
    }
    #endregion

    #region GetCaseGood 商品類別
    private DataTable GetCaseGood() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "select * from  casedmt_good where in_no= '"  + in_no + "' and in_scode='" + br_in_scode +"' order by cast(class as int)";
            conn.DataTable(SQL, dt);
        }
        return dt;
    }
    #endregion

    #region GetCaseShow 展覽優先權
    private DataTable GetCaseShow() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "select * from casedmt_show where in_no='" + in_no + "' and case_sqlno=0  order by show_sqlno";
            conn.DataTable(SQL, dt);
        }
        return dt;
    }
    #endregion

    #region GetCaseAttach 交辦附件
    private DataTable GetCaseAttach() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            if (in_no != "") {
                SQL = "select * from dmt_attach where in_no='" + in_no + "' and source='case' and attach_flag<>'D' order by attach_sqlno";
                conn.DataTable(SQL, dt);

                for (int i = 0; i < dt.Rows.Count; i++) {
                    if (submitTask == "AddNext") {//複製模式,改為新檔名
                        if (dt.Rows[i].SafeRead("apattach_sqlno", "") == "") {//總契約書/委任書不需複製檔案
                            System.IO.FileInfo sFi = new System.IO.FileInfo(HttpContext.Current.Server.MapPath(Sys.Path2Nbtbrt(dt.Rows[i].SafeRead("attach_path", ""))));
                            string strpath1 = sfile.gbrWebDir + "/doc/case";
                            string newName = br_in_scode + "-" + dt.Rows[i].SafeRead("attach_name", "");

                            dt.Rows[i]["attach_name"] = newName;
                            dt.Rows[i]["attach_path"] = strpath1 + "/" + newName;

                            sFi.CopyTo(Server.MapPath(strpath1 + "/" + newName), true);
                        }
                    }
                    dt.Rows[i]["attach_path"] = Sys.Path2Nbtbrt(dt.Rows[i].SafeRead("attach_path", ""));
                }
            }
        }
        return dt;
    }
    #endregion

    #region GetCaseTran 異動檔
    private DataTable GetCaseTran() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "select * from dmt_tran where in_no= '"  + in_no + "' and in_scode='" + br_in_scode +"'";
            conn.DataTable(SQL, dt);
        }
        return dt;
    }
    #endregion

    #region GetCaseTranlist 異動明細檔
    private DataTable GetCaseTranlist() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "select * from dmt_tranlist where in_no= '"  + in_no + "' and in_scode='" + br_in_scode +"'";
            conn.DataTable(SQL, dt);
        }
        return dt;
    }
    #endregion

    #region GetCust 客戶主檔資料
    private DataTable GetCust() {
        DataTable dt = new DataTable();
        using (DBHelper conn = new DBHelper(Conn.btbrt).Debug(false)) {
            SQL = "SELECT * ";
            SQL += ",(select min(att_sql) from custz_att c where B.cust_area = C.cust_area AND B.cust_seq = C.cust_seq and (dept='T' or dept is null) )att_sql ";
            SQL += " FROM vcustlist b ";
            SQL += "where cust_area='" + cust_area + "' ";
            SQL += "and cust_seq='" + cust_seq + "'";
            conn.DataTable(SQL, dt);
        }
        return dt;
    }
    #endregion

    #region GetSales 洽案營洽清單
    private DataTable GetSales() {
        DataTable dt = new DataTable();
        using (DBHelper cnn = new DBHelper(Conn.Sysctrl).Debug(false)) {
            if (formfunction == "Edit") {
                if ((right & 64) != 0) {
                    SQL = "select distinct 'select'input_type,scode,sc_name,scode1  ";
                    SQL += "from vscode_roles ";
                    SQL += "where branch='" + Session["SeBranch"] + "' ";
                    SQL += "and dept='" + Session["Dept"] + "' ";
                    SQL += "and syscode='" + Session["Syscode"] + "' ";
                    SQL += "and roles='sales' ";
                    SQL += "order by scode1 ";
                } else {
                    SQL = "select 'text'input_type,scode,sc_name,sscode scode1 from scode where scode='" + br_in_scode + "'";
                }
            } else {
                if ((right & 64) != 0) {
                    SQL = "select distinct 'select'input_type,scode,sc_name,scode1  ";
                    SQL += "from vscode_roles ";
                    SQL += "where branch='" + Session["SeBranch"] + "' ";
                    SQL += "and dept='" + Session["Dept"] + "' ";
                    SQL += "and syscode='" + Session["Syscode"] + "' ";
                    SQL += "and roles='sales' ";
                    SQL += "and (end_date is null or end_date>convert(date,getDate())) ";
                    SQL += "order by scode1 ";
                } else {
                    SQL = "select 'text'input_type,scode,sc_name,sscode scode1 from scode where scode='" + Session["se_scode"] + "'";
                }
            }
            cnn.DataTable(SQL, dt);
        }
        return dt;
    }
    #endregion
</script>
