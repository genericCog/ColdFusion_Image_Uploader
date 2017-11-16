/*  File: image_cropper.js
    Called From:profile_image_scripts.js  Associated Files: index.cfm, profile_image_scripts.js, image_cropper.js, up_action.cfm, up.cfc
    Purpose: Implements image crop functionality with error handling.
    Detail: Calls "cropper" on the object of the ID passed in as a string. 
            Initializes the crop area with width, height values. 
            On click event returns a data URI, setting the value of a 
            hidden form input field with it while reseting of input fields.
    Functions:
        1. Crop_Image_Intitializer(id_img_to_crop, id_crop_btn, id_hidden_form_field_1, id_hidden_form_field_2, bool_flag)
        2. Crop_Image_Do(e)
*/
    function Crop_Image_Intitializer(id_img_to_crop, id_crop_btn, id_hidden_form_field_1, id_hidden_form_field_2, submit_flag){

        var $c_image  = $(id_img_to_crop) || $('#fallback_img');
        var $c_btn    = $(id_crop_btn)    || $('#btn_crop_image');
        var $c_hide_1 = $(id_hidden_form_field_1) || $('#hidden_input_image_file_cropped');
        var $c_hide_2 = $(id_hidden_form_field_2) || $('#hidden_input_image_file');
        var c_flag    = submit_flag || 'false';
        var c_img_tag_open  = '<img id="profile_image_file" class="profile_img" src="';
        var c_img_tag_close = '" /> ';
            
        //Cropper_Instance();call the instance the first time cropper is called from outside the Crop_Image_Intitializer function
        
        
        
            //var $dataX = $("#dataX"),$dataY = $("#dataY"),$dataHeight = $("#dataHeight"),$dataWidth = $("#dataWidth");
            var originalData = {};
            var c_canvas  = '';
            var c_reset   = '';
            var c_data_URL= '';
            var $cropper = $c_image.cropper({
                aspectRatio: 2/3,
                autoCrop: true,
                autoCropArea: 0.5,
                data: originalData,
                minContainerHeight:300,
                minContainerWidth:200,
                
                maxContainerHeight:300,
                maxContainerWidth:200,
                
                minCanvasWidth:200,
                minCanvasHeight:300,
                
                minCropBoxWidth:50,
                minCropBoxHeight:100,

                done: function(data){console.log('cropper data: '+data);},
                crop: function(e) {
                    console.log('Center X: ' + e.x + '   Center Y: ' + e.y);
                    console.log('natural width: ' + e.width + '   natural height: ' + e.height);
                    console.log('rotate: ' + e.rotate + '\nscale X: ' + e.scaleX + '\nscale Y: ' + e.scaleY);
                }
            });

        function Crop_Image_Do(e){           
            if(c_flag == 'true'){
                console.log('*****\nEVENT: Crop_Image_Do function called\n'+e+'\n_____');
                document.getElementById('profile_image_file').src='';
                c_img_tag_open  = '<img id="profile_image_file" class="profile_img" src="';            
                $('#hidden_cropped_flag').val('cropped');
                c_canvas = $c_image.cropper('getCroppedCanvas');
                c_data_URL = c_canvas.toDataURL();            
                c_img_tag_open += c_data_URL + c_img_tag_close;
                $('#profile_image_file').attr( 'src',c_data_URL).show();            
                $c_hide_1.val(c_img_tag_open);
                //$c_hide_2.val(''); 
                $('#server_image_tag').css({'width':'200','height':'300'});
                Display_Dialog_Modal('Image Preview', c_img_tag_open,'modal_default','true');
                
            }else if(c_flag == 'false'){
                Display_Dialog_Modal('Image Preview', c_img_tag_open,'modal_default','false');
            }
        }
        
        $('#btn_crop_image').on('click', function(e){console.trace();e.preventDefault(); e.stopPropagation();
            Crop_Image_Do(e);//console.log('*****\nEVENT: crop button clicked\n_____');
        });
    }//END Crop_Image_Intitializer()
    
///*_____END Image Cropper______________________*/