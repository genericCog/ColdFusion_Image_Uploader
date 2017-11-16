<!--- File: index.cfm
Associated Files: index.cfm, profile_image_scripts.js, image_cropper.js, up_action.cfm, up.cfc, cropper.css, cropper.js
Purpose: Implements image upload functionality front-end.
 --->

<cfsetting showdebugoutput="true">

<cfinvoke component="up" method="session_user_profile" returnvariable="get_session_user_profile"/>
<cfset file_name_on_server = "">

<!doctype html>
<head>
    <cfheader name="X-UA-Compatible" value="IE=EDGE" />
    <meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <cfset html_title = #get_session_user_profile.first_name# >
    <title><cfoutput>#html_title#</cfoutput>, Upload Test</title>
    <meta name="author" content="Adam Cherochak">
    <meta name="description" content="Image Upload Test">
    <meta name="keywords" content="image upload">

    <link rel="stylesheet" type="text/css" href="css/up_styles.css">
    <script src="js/jquery-3.2.1.min.js"></script>
    <script src="js/jquery-ui-1.12.1.min.js"></script>
    <link rel="stylesheet" type="text/css" href="js/jquery-ui-smoothness.css" />
    
     <!---image cropper scripts --->
    <script src="cropper/cropper.js"></script>
    <link rel="stylesheet" type="text/css" href="cropper/cropper.css">
    
    <!--- set coldfusion variables to javascript variables --->
    <cfset cf_first_name = #get_session_user_profile.first_name#>
    <cfset cf_last_name = #get_session_user_profile.last_name#>
    <script>
        <cfoutput>
            var #toScript(cf_first_name, "js_first_name")#;
            var #toScript(cf_last_name,  "js_last_name")#;
        </cfoutput>	
        var currentState = history.state;
        var current_URL = window.location.href;//URL is passed to action page for use on return. also used to reset the page
        //Image File Properties ( ifp ) initialization
        var ifp_name   = '';
        var ifp_size   = '';
        var ifp_type   = '';
        var ifp_width  = '';
        var ifp_height = '';
    </script>
    <!--- END set coldfusion variables --->
</head>

<body>
    <div id="drag_drop_container" class="div_wrapper_main">
        <form action="up_action.cfm" method="post"  id="form_upload_image"  name="form_upload_image">
            <!---hidden fields--->
            <input type="hidden" id="hidden_URL" name="hidden_URL" />
            <input type="hidden" id="hidden_file_name" name="hidden_file_name" />                   
            <input type="hidden" id="hidden_cropped_flag" name="hidden_cropped_flag" />
            <input type="hidden" id="hidden_input_image_file" name="hidden_input_image_file" />
            <input type="hidden" id="hidden_input_image_file_cropped" name="hidden_input_image_file_cropped" />
            
            <!---END hidden fields --->
            <div id="drop_zone_container" class="dz_container_normal flex_center_column"><!--- DRAG and DROP --->
                <div id="image_drop_zone" data-action-drop="Drop Image Here" class="dz_normal flex_center_column">
                <img src="" alt="fall back image container" id="fallback_img" class="display_none"/>
                    <!--- the image element is created dynamically & placed into the image_drop_zone container <img id="profile_image_file" class="profile_img" --->
                    <svg id="svg_cloud_icon_1" class="svg_cloud_icon" width="50" height="75" viewBox="13 0 60 75" 
                          version="1.1" xmlns="http://www.w3.org/2000/svg"
                          xmlns:xlink="http://www.w3.org/1999/xlink"
                          xmlns:ev="http://www.w3.org/2001/xml-events" >
                    
                        <g id="svg_icon_container" xmlns="http://www.w3.org/2000/svg">
                            <ellipse id="cloud_icon_shadow" fill="#DEE3E7" cx="43.3" cy="73.9" rx="37.6" ry="4.1"/>
                            <g id="svg_inner_container">
                                <path id="cloud_icon" fill="#A6B6C2"
                                      d="M69.4,21.5C66.9,9.2,56,0,43,0C32.6,0,23.7,5.8,19.2,14.4C8.4,15.5,0,24.6,0,35.6C0,47.5,9.6,57,21.5,57
                                         h46.6C78,57,86,49,86,39.2C86,29.8,78.6,22.2,69.4,21.5z"/>
                                <polygon id="up_arrow_icon" fill="#F0F2F4" 
                                         points="50.2,32.1 50.2,46.3 35.8,46.3 35.8,32.1 25.1,32.1 43,14.3 60.9,32.1 "/>
                            </g>
                        </g>
                    </svg>
                    <span id="lbl_drop_zone">Drop image here</span>
                    <span id="lbl_loading" style="">loading...</span>                    
                </div>
                
                <div id="image_display_container"></div>
                
                <div id="file_select_container" style="margin-top:4px;border:0px solid red;width:200px;">
                    <div id="upload_icon_div_2" class="modern_button">
                        <input required type="file" accept="image/*" 
                               class="input_select_image"
                               id="input_manual_select" name="input_manual_select" />
                        <label for="input_manual_select" style="width:100%;height:100%;">        
                            <svg id="svg_upload_tray_container" class="svg_upload_tray" width="20" height="17" viewBox="0 0 20 17"
                                 version="1.1" xmlns="http://www.w3.org/2000/svg"
                                 xmlns:xlink="http://www.w3.org/1999/xlink"
                                 xmlns:ev="http://www.w3.org/2001/xml-events" >
                                    <path d="M10 0l-5.2 4.9h3.3v5.1h3.8v-5.1h3.3l-5.2-4.9zm9.3 
                                             11.5l-3.2-2.1h-2l3.4 2.6h-3.5c-.1 0-.2.1-.2.1l-.8 
                                             2.3h-6l-.8-2.2c-.1-.1-.1-.2-.2-.2h-3.6l3.4-2.6h-2l-3.2 2.1c-.4.3-.7 
                                             1-.6 1.5l.6 3.1c.1.5.7.9 1.2.9h16.3c.6 0 
                                             1.1-.4 1.3-.9l.6-3.1c.1-.5-.2-1.2-.7-1.5z"
                                           fill="rgba(215,227,248,1.00)" stroke-width="1" stroke="rgba(215,227,248,1.00)" />
                            </svg> 
                            <span id='lbl_manual_select'>Select an image</span>
                        </label>
                    </div><!---END upload_icon_div_2 --->
                </div><!---END file_select_container--->
                <div id="btn_dz_container" class="flex_center_row">                        
                    <div id="lbl_dz_container">
                        <span id="lbl_after_submit"></span>
                        <hr id="hr_after_submit" class="hr_gradient" style="margin-bottom:-2px;">
                    </div>
                    <div id="btn_change_image" class="display_none modern_button">
                        <span id="lbl_undo_image">Change</span>
                    </div>                        
                    <div id="btn_crop_image" class="display_none modern_button">
                        <span id="lbl_crop_image">Crop</span>
                    </div>                        
                    <div id="btn_submit_image" class="display_none modern_button">
                        <span id="lbl_submit_image">Submit</span>
                    </div>
                </div>                   
            </div><!---END drop zone wrapper--->
                              
        </form><!---END form --->
        
    </div><!---END drag and drop container--->
 
    <div id="server_image_container" class="flex_center_row" style="display:none;margin:25px 0 25px 0;min-width:50px;">
        <img id="server_image_tag" alt="Profile Image" style="border:1px solid red;min-width:150px;min-height:150px;" src="" />
    </div><!---END server_image_container--->


    <script src="js/profile_image_scripts.js"></script>
    <script src="js/image_cropper.js"></script>
    <cfset template_URL_parameters = 'template_URL_parameters.cfm'>
    <cfinclude template="#template_URL_parameters#">
</body>
</html>