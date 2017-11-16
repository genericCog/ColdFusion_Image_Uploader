/*  File: profile_image_scripts.js
    Called From: index.cfm  Associated Files: index.cfm, profile_image_scripts.js, image_cropper.js, up_action.cfm, up.cfc
    Purpose: Implements image upload functionality with error handling.
    Custom Functions:
        0. Display_Dialog_Modal(m_title, m_msg, m_class, m_mode)
        1. Remove_URL_Parameters(base_URL)
        2. Create_Toggle_Label(lbl_class, lbl_text, toggle_mode)
        3. Toggle_Button(btn_id_1, btn_id_2, btn_id_3, toggle_mode)
        4. Prevent_Default(e)
        5. Drop_Zone_Hover()
        6. Drop_Zone_Normal()
        7. Trigger_On_Click()
        8. Preview_File(file)
        9. Initialize_Display_Area()
        10. Reset_Upload_Area()
        11. Form_Submit_Message(url_param)
        12. Success_Display_Server_Image(url_msg_parameter, session_cacedipi, img_file_name_parameter, replace_URL)
        13. Image_File_Properties(input_element_id)
var $btn_dz_container = $('#btn_dz_container');
var $btn_change_image = $('#btn_change_image');
var $btn_crop_image = $('#btn_crop_image');
var $btn_submit_image = $('#btn_submit_image');
var $dialog_modal = $('#dialog_modal');
var $drop_zone_container = $('#drop_zone_container');
var $file_select_container = $('#file_select_container');
var $form_upload_image = $('#form_upload_image');
var $hidden_input_image_file = $('#hidden_input_image_file');
var $hidden_URL = $('#hidden_URL');
var $hr_after_submit = $('#hr_after_submit');
var $image_display_container = $('#image_display_container');
var $image_drop_zone = $('#image_drop_zone');
var $input_manual_select = $('#input_manual_select');
var $lbl_dz_container = $('#lbl_dz_container');
var $lbl_after_submit = $('#lbl_after_submit');
var $lbl_drop_zone = $('#lbl_drop_zone');
var $lbl_file_name = $('#lbl_file_name' );
var $lbl_loading = $('#lbl_loading');
var $lbl_manual_select = $('#lbl_manual_select');
var $temp_label = $('#temp_label');
*/
// Set 
    $(function() { $('#hidden_URL').val(current_URL); });
    
    function Remove_URL_Parameters(base_URL){
        window.history.pushState("object", "Select New Image", base_URL);//Remove URL Parameters Used In: template_URL_parameters.cfm
    }
    
    ///*_____Display Dialog Modal______________________________________*/
    function Display_Dialog_Modal(){
        console.log('*_*_*Modal Event' +'\n'+ 'm_mode: '+arguments[3] +'\n'+ 'm_title: '+arguments[0] +'\n'+ 'm_msg:'+arguments[1] +'\n'+ 'm_class: '+arguments[2]+'\n_____');
        
  
        var s_btns = {'Ok':function(){Dialog_Reset();$(this).dialog('close');}};
        var m_btns = {'Edit': function(){Dialog_Reset();$(this).dialog('close');},
                      'Close': function(){Dialog_Reset();$(this).dialog('close');},
                      'Submit': function(){$('#btn_submit_image').trigger('click');Dialog_Reset();$(this).dialog('close');}};
        var parent_params = arguments;
        var m_title= arguments[0] || 'Notice';
        var m_msg  = arguments[1] || 'No message sent';
        var m_class= arguments[2] || 'modal_default';
        var m_mode = arguments[3] || 'false';
        var $temp_span = $('<span />',{id:'temp_span'});
        var $temp_div = $('<div />',{id:'dialog_modal', "class":'modal_default'});//.appendTo( "body" );//Create DOM element for use as modal dialog


        if(! arguments.length){
            $temp_div.addClass('modal_default').html($temp_span.html(m_msg).addClass(m_class)).dialog({title: m_title, buttons: s_btns});
        }
        for(var i = 0, j = arguments.length; i< j; i++){
            if(arguments[i].indexOf('true') == -1 || arguments[i].indexOf('false') == -1){
                toggle_mode = arguments[i];
            }else{toggle_mode='false'}
        }
        switch(toggle_mode){
            case( 'true' ):
                //$('#dialog_modal').html('<p class="modal_default '+ m_class + '">' + m_msg + '</p>').dialog({title: m_title, buttons: m_btns});
                $temp_div.addClass('modal_default').html($temp_span.html(m_msg).addClass(m_class)).dialog({title: m_title, buttons: m_btns,resizable: false, modal:false});
                break;
            case( 'false' ):
                $temp_div.addClass('modal_default').html($temp_span.html(m_msg).addClass(m_class)).dialog({title: m_title, buttons: s_btns});
                break;
            default:
                console.log('ERROR: Display_Dialog_Modal()\n'+'Incorrect toggle mode.');
            break;
        }        
        function Dialog_Reset(){
            for(var i=0, j=parent_params.length; i<j; i++){
                console.log('*_*_*Modal RESET ' + parent_params[i] + '\n_____');
                parent_params[i] = '';
            }
        }
    }///*_____END Display Dialog Modal__________________________________*/
    
    ///*_____Toggle Labels & Buttons______________________________________*/
    function Create_Toggle_Label(){
        console.log('*_*_*Toggle Label(s)'+'\nlbl_class: '+arguments[0]+'\nlbl_text: '+arguments[1]+'\ntoggle_mode: '+arguments[2]+'\n_____');
        if(! arguments.length){
            console.log('Toggle Label missing parameters');
        }
        var lbl_class   = arguments[0] || "temp_lbl_default";
        var lbl_text    = arguments[1] || "Label not defined."; 
        var toggle_mode = arguments[2] || 'hide';

        for(var i = 0, j = arguments.length; i< j; i++){
            if(arguments[i].indexOf('show') == -1 || arguments[i].indexOf('hide') == -1){
                toggle_mode = arguments[i];console.log(toggle_mode);
            }else{toggle_mode='hide';console.log('toggle mode: '+toggle_mode);}
        }      
         switch(toggle_mode){
            case( 'show' ):
                var $temp_label = $('<label />',{id:'temp_label',html:lbl_text});
                $('#btn_dz_container').append($temp_label);
                $('#temp_label').attr('class',lbl_class);
                //$('#temp_label').attr('class',lbl_class).fadeIn("slow");
                $('#temp_label').animate({
                    'opacity':1
                    }, 
                    2500, 
                    function(){
                        $('#temp_label').hide();
                    }).animate({'opacity':'0'}, 2500);

                break;
            case( 'hide' ):
                $('#temp_label').hide();
                break;
            default:
                console.log('ERROR: Display_Dialog_Modal()\n'+'Incorrect toggle_mode.');
            break;
         }
    }
    
   function Toggle_Button(){
        console.log('*_*_*Toggle Button(s)'+'\nbtn_id_1: '+arguments[0]+'\nbtn_id_2: '+arguments[1]+'\nbtn_id_3: '+arguments[2]+'\ntoggle_mode: '+arguments[3]+'\n_____');
        var btn_id_1 = arguments[0] || '#btn_change_image';
        var btn_id_2 = arguments[1] || '#btn_crop_image'; 
        var btn_id_3 = arguments[2] || '#btn_submit_image';
        var toggle_mode = arguments[3] || 'hide';
        var params = [];
        if(! arguments.length){
            console.log('Toggle Button missing parameters');
        } 
        for(var i = 0, j = arguments.length; i< j; i++){
            if(arguments[i].indexOf('#') == -1){
                toggle_mode = arguments[i];
            }else{
                params.push(arguments[i]);
            }
        }
        switch(toggle_mode){
            case( 'show' ):
                $('#btn_dz_container').show();
                for(var i = 0, j = params.length; i< j; i++){
                    $(params[i]).fadeIn('slow');
                    
                    $(params[i]).animate({ opacity:1}, 2500, function(){/*$(params[i]).show();*/}).animate({'opacity':'1'}, 2500);
                    
                }
                break;
            case( 'hide' ):
                for(var i = 0, j = params.length; i< j; i++){
                    $(params[i]).hide();
                }
                break;
            default:
                console.log('ERROR: Display_Dialog_Modal()\n'+'Incorrect toggle_mode.');
            break;
        } 
    }

///*_____END Toggle Labels & Buttons______________________________________*/



///*_____Image Loader__________________________*/
    var max_file_size = 2500000;

    
    
    ///*_____ drag & drop _____*/
    //  Images dragged onto the dz or selected through file system are in base64 then converted and saved to the server
    var img   = '';
    var dataTransfer  = '';
    var file_name     = '';
    var manual_upload = '';
    var error_message = '';
    var b64_img_tag_open  = '';
    var b64_img_tag_close = '';
    
    function Prevent_Default(e){e.preventDefault(); e.stopPropagation(); console.log('*_*_*EVENT: Prevent_Default(e) function called | e.type: ' + e.type+'\n_____'); }
    function Drop_Zone_Hover(){
        $('#drop_zone_container').removeClass('dz_container_normal');
        $('#image_drop_zone').removeClass('dz_normal');
        $('#image_drop_zone').addClass('dz_over');
        $('#drop_zone_container').addClass('dz_container_over');
    }
    function Drop_Zone_Normal(){
        $('#drop_zone_container').addClass('dz_container_normal');
        $('#image_drop_zone').addClass('dz_normal');
        $('#image_drop_zone').removeClass('dz_over');
        $('#drop_zone_container').removeClass('dz_container_over');
    }
   
    
    function Trigger_On_Click(){$('#input_manual_select').trigger('click');}
    
    $('#input_manual_select').on('change', function(e) {console.log('*_*_*EVENT: change on the upload_icon_div_2 | e.type:' + e.type+'\n_____');
        var files = document.querySelector('input[type=file]').files;
        Image_File_Properties(this);
        if (files[0].size > max_file_size) {
            Display_Dialog_Modal('File Size Too Big', 'Please limit file size to 4Mb.','class_warn_red','false');
                    console.log('*_*_*Modal Event'+'\nform_submit: '+arguments[3]+'\nm_title: '+arguments[0]+'\nm_msg:'+arguments[1]+'\nm_class: '+arguments[2]+'\n_____');
            Reset_Upload_Area();
            return;
        }
        Preview_File(files);
    });
    
    $('#btn_change_image').on('click', function(e){ Reset_Upload_Area(); });    
    $('#btn_submit_image').on('click', function(){ 
        Create_Toggle_Label('class_do_blue', 'Processing...', 'show');
        //$('#lbl_after_submit').text('Processing...').attr('class','class_do_blue').show();
        Toggle_Button('#btn_change_image', '#btn_crop_image', '#btn_submit_image', 'hide');
        $('#form_upload_image').submit();
    });
    
    $the_drop_zone = $('#image_drop_zone');

    $the_drop_zone.on({
        //'click':     function(e) {try{$('#input_manual_select').trigger('click');}catch(error_info){console.log('ERROR click\n'+e.type+'\n'+error_info);}},
        'click':     function(e) {console.log('event on the drop zone ' + e.type);Trigger_On_Click();},
        'dragstart': function(e) {try{Prevent_Default(e);Drop_Zone_Hover();}catch(error_info){console.log('ERROR dragstart\n'+e+'\n'+error_info);}}, //END dragstart
        'dragover':  function(e) {try{Prevent_Default(e);Drop_Zone_Hover();}catch(error_info){console.log('ERROR dragover\n'+e+'\n'+error_info);}},   //END dragover
        'dragend':   function(e) {try{Prevent_Default(e);Drop_Zone_Normal();}catch(error_info){console.log('ERROR dragend\n'+e+'\n'+error_info);}},     //END dragend
        'dragleave': function(e) {try{Prevent_Default(e);Drop_Zone_Normal();}catch(error_info){console.log('ERROR dragleave\n'+e+'\n'+error_info);}},   //END dragleave
        
        'drop': function(e) {
            Prevent_Default(e);
            Drop_Zone_Normal();
            //console.log(e.originalEvent instanceof DragEvent);
            try{
                dataTransfer =  e.originalEvent.dataTransfer;
                Image_File_Properties(dataTransfer);//show me the file properties
                
                if( dataTransfer && dataTransfer.files.length) {
                    e.preventDefault();
                    e.stopPropagation();
                    if (dataTransfer.files[0].size > max_file_size) { //TO DO: in action page check file size and restrict
                        Reset_Upload_Area();
                        Display_Dialog_Modal('File Size Too Big','Please limit file size to 4Mb.','class_warn_red','false');
                        return;
                    }//END if file size > 4Mb
                    
                    $.each( dataTransfer.files, function(i, file) {
                        console.log('*_*_*EVENT: drop: function(e) | file info:' +file+'\n_____');
                        Preview_File(dataTransfer.files);
                    });//END each loop            
                    
                }//END if dataTransfer 
                else{ Display_Dialog_Modal('File Type Incorrect', 'Image must be of type jpg, png, or gif.\nPlease select a different image.','class_warn_red','false'); }      
            }catch(e){Display_Dialog_Modal('Unknown Error', 'Please contact webmaster.\nError Message:Unknown error in drop event.','class_warn_red','false');}
        }//END drop function
    });//
    /*_____ END drag & drop _____*/


    ///*_____display image after drag/drop or select event_____*/
    function Preview_File(file){
        console.log('*_*_*EVENT: Preview_File(file) | file info:' +file[0].name+'\n_____');
        function Read_Preview(file) {
            try{
                if ( /\.(jpe?g|png|gif)$/i.test(file.name) ){// file extension pre-check
                    var reader = new FileReader();    
                    
                    $('#lbl_drop_zone').hide();
                    $('#lbl_loading').show();
                    
                    reader.onload = $.proxy(function(file, $image_display_container, event) {
                        img = file.type.match('image.*') ? '<img id="profile_image_file" class="profile_img" src="' + event.target.result + '" /> ' : '';
                        $image_display_container.prepend( $("<span class='profile_img'>").append( img + '</span>') );
                        
                        $('#image_display_container').show();   //display the image in a new field
                        $('#hidden_input_image_file').val(img); //prep send to server
                        $('#hidden_input_image_file_cropped').val(img);
                        Initialize_Display_Area();
                        Crop_Image_Intitializer('#profile_image_file', '#btn_crop_image', '#hidden_input_image_file_cropped', '#hidden_input_image_file', 'true');
                        
                    }, this, file, $("#image_display_container"));//END reader.onload
                    reader.readAsDataURL(file);
                }//END file extension pre-check 
                else{  Display_Dialog_Modal('File Type Incorrect', 'Image must be of type jpg, png, or gif.\nPlease select a different image.', 'class_warn_red','false');}        
            }catch(e){ Display_Dialog_Modal('Unknown Error', 'Please contact webmaster\nError Message: Unknown error occured, in function Preview_File()\n'+e, 'class_warn_red','false'); }//END try/catch
            
        }//END Read_Preview()    
        
        if (file) {[].forEach.call(file, Read_Preview);}
        
    }///*_____END Preview_File(file)_____*/


    ///*_____Initialize Display*/
    function Initialize_Display_Area(){
        //used in: Form_Submit_Message
        try{
            $('#file_select_container').hide();
            $('#image_drop_zone').hide();
            Toggle_Button('#btn_submit_image', '#btn_crop_image' , '#btn_change_image', 'show');            
            $('#lbl_loading').hide();
            $('#lbl_drop_zone').fadeIn( "slow");
        }catch(e){
            console.log('*_*_*ERROR: Initialize_Display_Area() | e:' +e+'\n_____');
        }//END try/catch
    }///*_____END Initialize Display*/
    
    
    ///*_____Reset upload area_____*/
    function Reset_Upload_Area(){
        //used in: Form_Submit_Message
        try{
            $('#file_select_container').show();
            $('#image_display_container').empty();//empty the image container
            $('#image_display_container').wrap('<form>').closest('form').get(0).reset();//wrap then unwrap element to perform a reset
            $('#image_display_container').unwrap();
            $('#image_display_container').hide();
            $('#input_manual_select').empty();//empty the image container
            $('#input_manual_select').wrap('<form>').closest('form').get(0).reset();//wrap then unwrap element to perform a reset
            $('#input_manual_select').unwrap();
            $('#input_manual_select').hide();
            Toggle_Button('#btn_submit_image', '#btn_crop_image' , '#btn_change_image', 'hide');
            $('#image_drop_zone').fadeIn( "slow");
            $('#lbl_file_name').hide();
            $('#lbl_file_name').val('');
            $('#hidden_input_image_file').val('');
            $('#lbl_dz_container').hide();
            $('#lbl_after_submit').val('Select an image');
            //$('#lbl_manual_select').html('Choose a file&hellip;');
        }catch(e){
            console.log('*_*_*ERROR: Reset_Upload_Area() | e:' +e+'\n_____');
        }//END try/catch
    }///*_____END Reset_Upload_Area()_____*/
///*_____END Image Loader__________________________*/

    /*_____Return Action_____*/
    function Form_Submit_Message(url_param){
        // used in template.cfm
        switch(url_param){
            case( 'empty' ):
                Reset_Upload_Area();
                Display_Dialog_Modal('Upload Failed','Please try again with a different image.','class_warn_red','false');
                console.log('*_*_*ERROR: Empty URL Parameter | url_param:' +url_param+'\n_____');
            break;
            case( 'success' ):
                //Create_Toggle_Label('class_good_green', 'Successful Image Upload', 'show');
                Reset_Upload_Area();
                Initialize_Display_Area();
                Toggle_Button('#btn_submit_image', '#btn_crop_image' , '#btn_change_image', 'hide');
                $('#image_display_container').show();
        Create_Toggle_Label('class_good_green', 'Successful Image Upload', 'show');
                $('#hr_after_submit').show();
                Toggle_Button('', '' , '#btn_change_image', 'show');


                
                console.log('*_*_*SUCCESS: Image upload | url_param:' +url_param+'\n_____');
            break;
            case( 'not_post' ):
                Reset_Upload_Area();
                Display_Dialog_Modal('Upload Failed', 'Please contact the webmaster.\nError Message: Form submit is not POST', 'class_warn_red','false');
                console.log('*_*_*ERROR: Not Form POST | url_param:' +url_param+'\n_____');
            break;
            default:
                Reset_Upload_Area();
                Display_Dialog_Modal('Unknown URL Parameter', 'Please contact the webmaster.\nError Message: Unknown URL Parameter '+url_param, 'class_warn_red','false');
                console.log('*_*_*ERROR: Unknown URL Parameter | url_param:' +url_param+'\n_____');
            break;
        }
    }///*_____END Return Action__________________________*/

    function Success_Display_Server_Image(url_msg_parameter, session_cacedipi, img_file_name_parameter, replace_URL){
        //Used In: template_URL_parameters.cfm
        Form_Submit_Message(url_msg_parameter);
        $('#lbl_drop_zone').hide();
        $('#lbl_loading').show();
        
        var img_tag = '<img id="profile_image_file" class="profile_img" src="' + session_cacedipi +'/' + img_file_name_parameter + '" /> ';
        $('#image_display_container').prepend( $("<span class='profile_img'>").append( img_tag + '</span>') );
        
        $('#lbl_loading').hide();
        $('#lbl_drop_zone').fadeIn( "slow");
    }//END Success_Display_Server_Image()

    function Image_File_Properties(input_element_id){
    /*Used In: input_manual_select on change, 
      Purpose: Called on the change event of an HTML input element.
               Writes console log.
               */
        ifp_name   = input_element_id.files[0].name;
        ifp_size   = input_element_id.files[0].size;
        ifp_type   = input_element_id.files[0].type;
        console.log('*_*_*Image File Properties ( ifp ) assignment\n' + 'File Type : ' + ifp_type + '\n' + 'File Name : ' + ifp_name + '\n' + 'File Size : ' + ifp_size + ' bytes'  + '\n' + 'File Width : ' + ifp_width  + ' pixels' + '\n' + 'File Height : ' + ifp_height + ' pixels');
    }//END Image File Properties ( ifp )
