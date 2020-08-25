<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data"%>

<script runat="server">
    public partial class apcust
    {
        public string ap_cname1 { get; set; }

        public string ap_cname2 { get; set; }

        public string ap_ename1 { get; set; }

        public string ap_ename2 { get; set; }

        public string ap_crep { get; set; }
    }
    
	private void Page_Load(System.Object sender, System.EventArgs e) {
        using (DBHelper conn = new DBHelper(ConfigurationManager.ConnectionStrings["dev_btbrtdb"].ToString())) {
            DataTable dt = new DataTable();
            conn.DataTable("select * from apcust where ap_cname1 like '%英業%'", dt);
            apcust rst1 = new apcust() { ap_cname1 = dt.Rows[0]["ap_cname1"].ToString(), ap_crep = dt.Rows[0]["ap_crep"].ToString() };
            Response.Write(rst1.ap_crep);
        }
	}
</script>

