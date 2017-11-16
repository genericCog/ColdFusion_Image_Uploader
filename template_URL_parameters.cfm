
    
<cfset cf_cacedipi_folder = #get_session_user_profile.cac_edipi#>
<cfset cf_replace_URL = #ListLast(CGI.SCRIPT_NAME,'?')#>

<cfif structkeyexists(url, 'msg') and url.msg EQ 'success'>
<!---Success Status Parameter--->

    <!---get image name from url --->
<cfset cf_img_file_name = #url.img#>
    
    <!---<cfimage action="info" source="#cf_cacedipi_folder#/#cf_img_file_name#" name="myImage" structname = "myImage">--->
    <script>
        <cfset cf_url_msg = #url.msg#>
        <cfoutput>var #toScript(cf_url_msg, "js_url_msg")#;</cfoutput>
        <cfoutput>var #toScript(cf_img_file_name, "js_img_file_name")#;</cfoutput>
        <cfoutput>var #toScript(cf_cacedipi_folder, "js_cacedipi_folder")#;</cfoutput>
        <cfoutput>var #toScript(cf_replace_URL, "js_replace_URL")#;</cfoutput>
        Success_Display_Server_Image(js_url_msg, js_cacedipi_folder, js_img_file_name, js_replace_URL);
        Remove_URL_Parameters(js_replace_URL);
    </script>
    
<cfelseif structkeyexists(url, 'msg') and url.msg EQ 'empty'>

    <script>
        <cfset cf_url_msg = #url.msg#>
        <cfoutput>var #toScript(cf_url_msg, "js_url_msg")#;</cfoutput>
        <cfoutput>var #toScript(cf_replace_URL, "js_replace_URL")#;</cfoutput>
        var url_param = js_url_msg;
        Form_Submit_Message(url_param);
        Remove_URL_Parameters(js_replace_URL);
    </script>
    
<cfelseif structkeyexists(url, 'msg') and url.msg EQ 'not_post'>

    <script>
        <cfset cf_url_msg = #url.msg#>
        <cfoutput>var #toScript(cf_url_msg, "js_url_msg")#;</cfoutput>
        <cfoutput>var #toScript(cf_replace_URL, "js_replace_URL")#;</cfoutput>
        var url_param = js_url_msg;
        Form_Submit_Message(url_param);
        Remove_URL_Parameters(js_replace_URL);
    </script>
</cfif>     