<%@ Control Language="C#" ClassName="de_agt_no1" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string html_agt_no = "";
    protected string id = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        id = this.ID;
        //代理人
        html_agt_no = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
        this.DataBind();
    }
</script>

<select id="<%#id%>" NAME="<%#id%>"><%#html_agt_no%></select>
