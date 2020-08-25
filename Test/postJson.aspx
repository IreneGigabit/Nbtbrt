<%@ Page Language="C#" %>

<script runat="server">
	private void Page_Load(System.Object sender, System.EventArgs e) {
        string json = new System.IO.StreamReader(Request.InputStream).ReadToEnd();
        Response.Write("json=<BR>"+json);
	}
</script>

