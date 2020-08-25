<%@ WebHandler Language="C#" Class="UpLoaded" %>

using System;
using System.Web;
using System.Web.SessionState;
using System.IO;
using System.Collections.Generic;
using System.Data.SqlClient;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public class UpLoaded : IHttpHandler, IRequiresSessionState
{

    public void ProcessRequest(HttpContext context) {
        string QueryString = context.Request.ServerVariables["QUERY_STRING"];
        Dictionary<string, string> ReqVal = Util.GetRequestParam(context, context.Request["chkTest"] == "TEST");

        string msg = "";//回傳訊息
        string type = context.Request["type"] ?? "";
        string mappath_name = Sys.FileDir(type);//依type決定要存的位置
        string upfolder = context.Request["upfolder"] ?? "";//子目錄
        string nfilename = context.Request["nfilename"] ?? "";//新檔名格式
        string pattach_path = mappath_name + "/" + upfolder + "/";//虛擬完整路徑+實體檔名

        string file_path = context.Server.MapPath(pattach_path);//儲存路徑
        context.Response.ContentType = "application/json";
        //context.Response.StatusCode = (int)System.Net.HttpStatusCode.InternalServerError;
        //context.Response.Write("<BR>" + file_path);
        //context.Response.Write("<BR>" + uploadedFile.FileName);
        //context.Response.End();
        if (!System.IO.Directory.Exists(file_path)) {
            System.IO.Directory.CreateDirectory(file_path);//如果不存在就建立file資料夾
        }

        HttpPostedFile uploadedFile = context.Request.Files[0];
        string FName = uploadedFile.FileName;//使用者端目錄(d:\xxxxx)+檔案名稱
        string psource_name = System.IO.Path.GetFileName(FName);//原始檔名(含Ext)
        string dd = System.IO.Path.GetFileNameWithoutExtension(FName);//原檔名(不含Ext)
        string sExt = System.IO.Path.GetExtension(FName);//副檔名
        int pattach_size = uploadedFile.ContentLength;//檔案大小(bytes)

        string attach_no = GetAttachNo(context);
        
        string ee = "";//新檔名
        if (nfilename != "") {//有指定新檔名格式
            ee = nfilename.Replace("{{attach_no}}", attach_no);
        } else {
            ee = dd;//使用原始檔名
        }

        string saveFName = ee + sExt;

        //如果存在的話原來的要備份起來,備份規則：檔名_年月日時分秒千分秒
        System.IO.FileInfo fi = new System.IO.FileInfo(file_path + saveFName);
        if (fi.Exists) {
            string File_name_new = String.Format("{0}_{1}{2}", ee, DateTime.Now.ToString("yyyyMMddHHmmssfff"), sExt);
            fi.MoveTo(file_path + File_name_new);
            msg = "此檔案已存在！已覆蓋檔案！";
        }

        uploadedFile.SaveAs(file_path + saveFName);

        JObject obj = new JObject(
                 new JProperty("msg", msg),//回傳訊息
                 new JProperty("name", saveFName),//實體檔名,KT-2011000060-14m.png
                 new JProperty("path", pattach_path + saveFName),//虛擬完整路徑+實體檔名,/nopt/opt_file/attach/2011/000060/KT-2011000060-14m.png
                 new JProperty("source", psource_name),//原始檔名,[立體商標註冊申請書]-TI-54531-IT_[立體商標註冊申請書]_0000.png
                 new JProperty("desc", dd),//原始檔名(不含Ext),[立體商標註冊申請書]-TI-54531-IT_[立體商標註冊申請書]_0000
                 new JProperty("size", pattach_size),//檔案大小
                 new JProperty("attach_no", attach_no)//attach_no
                );
        context.Response.Write(JsonConvert.SerializeObject(obj, Formatting.None));//回傳值
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

    public string GetAttachNo(HttpContext context) {
        string temptable = context.Request["temptable"] ?? "";//attachtemp_opt
        string attach_tablename = context.Request["attach_tablename"] ?? "";//attach_opt
        string syscode = context.Request["syscode"] ?? "";
        string apcode = context.Request["apcode"] ?? "";
        string branch = context.Request["branch"] ?? "";
        string dept = context.Request["dept"] ?? "";
        string opt_sqlno = context.Request["opt_sqlno"] ?? "";
        string remark = context.Request["remark"] ?? "";
        string prgid = context.Request["prgid"] ?? "";
        
        int attach_no = 0;

        string SQL = "";
        using (DBHelper conn = new DBHelper(Conn.OptK)) {
            //--1.先刪除attachtemp_opt三小時前的資料，再入，以免承辦上傳但未作存檔attach_no虛增
            SQL = "delete from " + temptable;
            SQL += " where syscode='" + syscode + "' and branch='" + branch + "' and dept='" + dept + "'";
            SQL += " and opt_sqlno='" + opt_sqlno + "' and in_date<DATEADD(hour,-3,getdate()) ";
            conn.ExecuteNonQuery(SQL);

            //--2.抓取最大值
            SQL = "select isnull(max(attach_no),1)+1 as maxattach_no ";
            SQL += "from " + attach_tablename;
            SQL += " where opt_sqlno='" + opt_sqlno + "'";
            object objResult1 = conn.ExecuteScalar(SQL);
            int maxattach_no1 = (objResult1 == DBNull.Value || objResult1 == null ? 1 : (int)objResult1);

            SQL = "select isnull(max(attach_no),1)+1 as maxattach_no ";
            SQL += "from " + temptable;
            SQL += " where syscode='" + syscode + "' and branch='" + branch + "' and dept='" + dept + "'";
            SQL += " and opt_sqlno='" + opt_sqlno + "'";
            object objResult2 = conn.ExecuteScalar(SQL);
            int maxattach_no2 = (objResult2 == DBNull.Value || objResult2 == null ? 1 : (int)objResult2);

            attach_no = Math.Max(maxattach_no1, maxattach_no2);

            //--3.回寫db記錄attach_no
            SQL = "select attach_no from " + temptable;
            SQL += " where syscode='" + syscode + "' and branch='" + branch + "' and dept='" + dept + "'";
            SQL += " and opt_sqlno='" + opt_sqlno + "' ";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    SQL = "update " + temptable;
                    SQL += " set attach_no='" + attach_no + "'";
                    SQL += ",tran_scode='" + context.Session["scode"] + "'";
                    SQL += " where syscode='" + syscode + "' and branch='" + branch + "' and dept='" + dept + "'";
                    SQL += " and opt_sqlno='" + opt_sqlno + "' ";
                } else {
                    SQL = "insert into " + temptable;
                    SQL += "(syscode,apcode,branch,dept,opt_sqlno,attach_no,in_date,in_scode,tran_date,tran_scode,remark)";
                    SQL += " values('" + syscode + "','" + apcode + "','" + branch + "','" + dept + "','" + opt_sqlno + "'";
                    SQL += ",'" + attach_no + "',getdate(),'" + context.Session["scode"] + "',getdate(),'" + context.Session["scode"] + "'";
                    SQL += ",'多檔上傳(" + prgid + ")')";
                }
                dr.Close();
                conn.ExecuteNonQuery(SQL);
            }

            conn.Commit();
        }

        return attach_no.ToString();
    }
}
