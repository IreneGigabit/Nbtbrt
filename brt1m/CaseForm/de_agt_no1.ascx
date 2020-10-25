<%@ Control Language="C#" ClassName="de_agt_no1" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected string tfg1_agt_no1 = "";
    protected string id = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        id = this.ID;
        //代理人
        tfg1_agt_no1 = Sys.getAgent().Option("{agt_no}", "{agt_no}_{agt_namefull}", " v1='{agt_name1}' {selected}", true);
        this.DataBind();
    }
</script>

<select id="<%#id%>" NAME="<%#id%>"><%#tfg1_agt_no1%></select>
