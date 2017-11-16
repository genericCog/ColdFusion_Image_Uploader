<!--- File: up_action.cfm
    Called From: index.cfm  Associated Files: index.cfm, profile_image_scripts.js, image_cropper.js, up_action.cfm, up.cfc
    Purpose: Image processing on Form submit. Writes image to server, deletes old image, returns to calling page with URL parameters
--->
<cfsetting showdebugoutput="false">
<div style="background-image:linear-gradient(to top,rgba(255, 255, 255, 0.3), rgb(240, 240, 240));">
<cfinvoke component="up" method="session_user_profile" returnvariable="get_session_user_profile"/>
<!--- Establish Server Environment --->  
<cfif CGI.HTTP_HOST IS "adamc.co" OR CGI.HTTP_HOST IS "0.0.0.0.1">	
    <cfset session.environment   = "dev">
    <cfset session.serverpath    = "\\server_name\folder_name\cherochak\up\">
    <cfset path_server_directory = #session.serverpath#>
    <cfset path_url_directory    = #session.serverpath#>
    <cfelse>
    <cfset session.environment   = "prod">
    <cfset session.serverpath    = "\\server_name\folder_name\cherochak\up\">
    <cfset path_server_directory = #session.serverpath#>
    <cfset path_url_directory    = #session.serverpath#>
</cfif>

    <cfset referer_cfm_page = "index.cfm">
<!--- begin image processing --->
<cfif cgi.request_method IS "post" AND 
      ( structKeyExists(form,"hidden_input_image_file") OR structKeyExists(form,"hidden_input_image_file_cropped") )>

    <cfif structKeyExists(form,"hidden_cropped_flag")>
        <cfset search_text_area = #form.hidden_input_image_file_cropped#>
    <cfelse>
        <cfset search_text_area = #form.hidden_input_image_file#>
    </cfif>

  <cfif (trim(form.hidden_input_image_file) NEQ '') OR (trim(form.hidden_input_image_file_cropped) NEQ '')>
    <!--- initialize arrays to sort and compare image files on the server and in the browser --->
    <cfset array_images_on_server_that_match_the_ckeditor = ArrayNew(1)>
    <cfset array_of_images_on_the_server                  = ArrayNew(1)>
    <cfset array_images_in_ckeditor                       = ArrayNew(1)>
    <cfset array_of_images_on_server_to_delete            = ArrayNew(1)>
    <cfset folder_user_cacedipi  = #get_session_user_profile.cac_edipi#>
    <cfset path_server_directory = #path_server_directory# & #folder_user_cacedipi# & "\">
    
    <cfif directoryExists(#path_server_directory#)> 
        <cfset path_url_directory = #path_url_directory# & #folder_user_cacedipi# & "\">
    <cfelse>
        <cfset directoryCreate(#path_server_directory#)>
        <cfset path_url_directory = #path_url_directory# & #folder_user_cacedipi# & "\">
    </cfif>
    
    <cfdirectory action="list" sort="ASC" directory="#path_server_directory#"  listinfo="all" filter="*.png|*.jpg|*.jpeg|*.gif" name="cfDir_list_images_on_server">
    
    <cfloop query="#cfDir_list_images_on_server#">
        <cfset ArrayAppend(array_images_on_server_that_match_the_ckeditor, cfDir_list_images_on_server.name)>
        <cfset ArrayAppend(array_of_images_on_the_server, cfDir_list_images_on_server.name)>
        <cfset ArrayAppend(array_of_images_on_server_to_delete, cfDir_list_images_on_server.name)>
    </cfloop>
        
    <cftry> <!---_________________________________________________________________________________________________________________ START Base64 Image Detection & Conversion --->    
    
        <!--- Initialize variables for image processing --->
        <cfset counter    = 0>      
        <cfset base64_png = "data:image/png;base64,">       
        <cfset base64_jpg = "data:image/jpeg;base64,">       
        <cfset base64_gif = "data:image/gif;base64,">
        <cfset base64_closure = '"'>
        <cfset header_length  = 0>
        <cfset file_type_png  = ".png">
        <cfset file_type_jpg  = ".jpg">
        <cfset file_type_gif  = ".gif">
        <cfset continue_searching_url = true>
        <cfset continue_searching     = true>
        <cfset go_thru_again          = false>
        <cfset file_name_on_server    = "">
        <cfset return_image_file_name = "">


        <!--- Find base64 images and convert to file system --->
        <cfloop condition = "continue_searching eq true"> 
            <cfoutput>
                <cfset starting_index_png = find( base64_png, search_text_area)>
                <cfset starting_index_jpg = find( base64_jpg, search_text_area)>
                <cfset starting_index_gif = find( base64_gif, search_text_area)>
                
                <cfif starting_index_png GT 0>
                    <cfset starting_index = starting_index_png>
                    <cfset header_length = 22<!---#Len(base64_jpg)#--->>
                </cfif>
                <cfif starting_index_jpg GT 0>
                    <cfset starting_index = starting_index_jpg>
                    <cfset header_length = #Len(base64_jpg)#>
                </cfif>
                <cfif starting_index_gif GT 0>
                    <cfset starting_index = starting_index_gif>
                    <cfset header_length = #Len(base64_gif)#>
                </cfif>
                
                <cfif starting_index eq 0>
                    <cfset continue_searching = false>
                    <cfcontinue>
                </cfif>
                <cfset ending_index     = find( base64_closure , search_text_area, starting_index )>
                <cfset full_occurrence  =  mid(#search_text_area#, (#starting_index#), ((#ending_index#)-#starting_index#))>
                <cfset local_occurrence = mid(#search_text_area#, (#starting_index# + #header_length#), ((#ending_index# - #header_length#)-#starting_index#))>
                <cfset image = imageReadBase64(#local_occurrence#)><cfoutput>#ending_index#</cfoutput>
                <cfset name_of_image    = #CreateUUID()#>
                <cfimage action="resize" height="300" width="200" 
                         source="#image#" 
                         destination="#path_server_directory##name_of_image##file_type_png#" 
                         nameconflict="MAKEUNIQUE" 
                         overwrite="yes" />
                <!--- <cfimage action="write" source="#image#" destination="#path_server_directory##name_of_image##file_type_png#" nameconflict="MAKEUNIQUE"> --->
                               
                <cfset search_text_area = replace(search_text_area, full_occurrence, path_url_directory & name_of_image & file_type_png, "All")>
                <cfset file_name_on_server = #path_url_directory# & #name_of_image# & #file_type_png#>
                <cfset return_image_file_name = #name_of_image# & #file_type_png#>
                <cfset starting_index   = 0>
                 
            </cfoutput>
        </cfloop>
        
        <cfcatch type="any">
            <cfoutput>
                <script>console.log('ERROR:' +'\n' + 'Base64 Image Detection & Conversion' + '\n' + '#cfcatch.message#' + '\n' + '#cfcatch.detail#');</script>
                <div class="base64_warning_container" style="border:1px solid red;padding:5px 5px;min-height:50px;width:100%;background-color:rgba(253,2,6,0.62);">
                    <h3 class="base64_warning"><span>ERROR:</span></h3>
                    <p>Performing action in: Base64 Image Detection & Conversion</p>
                    <p class="base64_warning">#cfcatch.message#</p>
                    <p class="base64_warning">#cfcatch.detail#</p>
                </div>
            </cfoutput>
        </cfcatch> 
    </cftry>
    
    <cftry><!---_________________________________________________________________________________________________________________ START Identify Image(s) To Delete --->
        
        <!--- find all image URLs and prepare to delete from File System --->
        <cfset length_of_text_field = #Len(search_text_area)#>
        <cfset image_url_closure = '"'>     
        <cfset array_images_in_ckeditor =[]>    
        <cfset counter_array =[]>
        <cfset continue_searching_url = true>
        <cfset first_pass = true>
        <cfset go_thru_again = false>
        <cfset counter = 0>
        <cfset next_position = -1>
        
        <cfloop condition = "continue_searching_url eq true">
            <cfoutput>
                <cfset counter = counter+1>
                <cfif counter GTE 15>
                    <cfbreak>
                </cfif>
                <cfif first_pass eq true>
                    <cfset starting_index_url = find(path_url_directory, search_text_area)>
                </cfif>
                <cfif go_thru_again eq true>
                    <cfset next_position = #ending_index_url#>
                </cfif>
                <cfif starting_index_url eq 0>
                    <cfset continue_searching_url = false>
                    <cfcontinue>
                </cfif>
                <cfif first_pass eq true>                             
                    <cfset ending_index_url     = find( image_url_closure , search_text_area, starting_index_url )>            
                    <cfset full_occurrence_url  = mid(#search_text_area#, (#starting_index_url#), ((#ending_index_url#)-#starting_index_url#))>
                    <cfset local_occurrence_url = mid(#search_text_area#, (#starting_index_url#), ((#ending_index_url#)-#starting_index_url#))>
                    <cfset first_pass           = false>
                    <cfset go_thru_again        = true>
                    <cfset next_position        = #ending_index_url#>
                    <cfset ArrayAppend(array_images_in_ckeditor, (local_occurrence_url))>
                </cfif>
                <cfset ArrayAppend(counter_array, starting_index_url)>
                <cfif go_thru_again eq true>
                    <cfif starting_index_url NEQ length_of_text_field>
                        <cfset starting_index_url   = find(path_url_directory, search_text_area, next_position)>
                        <cfset ending_index_url     = find( image_url_closure , search_text_area, starting_index_url )>            
                        <cfif starting_index_url eq 0>
                            <cfset continue_searching_url = false>
                            <cfcontinue>
                        </cfif>
                        <cfset full_occurrence_url  = mid(#search_text_area#, (#starting_index_url#), ((#ending_index_url#)-#starting_index_url#))>
                        <cfset local_occurrence_url = mid(#search_text_area#, (#starting_index_url#), ((#ending_index_url#)-#starting_index_url#))>
                        <cfset first_pass           = false>
                        <cfset go_thru_again        = true>
                        <cfset next_position        = #ending_index_url#>
                        <cfset ArrayAppend(array_images_in_ckeditor, (local_occurrence_url))>
                    <cfelse>
                        <cfset go_thru_again = false>
                        <cfset starting_index_url = 0> 
                        <cfcontinue>
                    </cfif>
                </cfif>
            </cfoutput>
        </cfloop>
        
        <cfcatch type="any">
            <cfoutput>
                <script>console.log('ERROR:' + '\n' + 'Identify Image(s) To Delete' + '\n' + '#cfcatch.message#' + '\n' + '#cfcatch.detail#');</script>
                <div class="base64_warning_container" style="border:1px solid red;padding:5px 5px;min-height:50px;width:100%;background-color:rgba(253,2,6,0.62);">
                    <h3 class="base64_warning"><span>ERROR:</span></h3>
                    <p>Performing action in: Identify Image(s) To Delete</p>
                    <p class="base64_warning">#cfcatch.message#</p>
                    <p class="base64_warning">#cfcatch.detail#</p>
                </div>
            </cfoutput>
        </cfcatch> 
    </cftry>
    
    <cftry><!---_________________________________________________________________________________________________________________ START Delete Image(s) --->

        <!--- DELETE images on server folder that no longer exist in CKEditor text area. --->
        <cfset ArraySort(array_images_in_ckeditor, "textnocase", "desc")>
        <cfset ArraySort(array_images_on_server_that_match_the_ckeditor, "textnocase", "desc")>
        <cfset ArraySort(array_of_images_on_server_to_delete, "textnocase", "desc")>
        <cfset array_image_file_names_from_ckeditor =[]>
        <cfset image_list_array_on_server =[]>
    
        
        <cfloop array="#array_images_in_ckeditor#" index="image_url_in_ckeditor">                               <!--- look in ckeditor area, find image URLs, extract file name to array --->
            <cfoutput>
                <cfset ArrayAppend(array_image_file_names_from_ckeditor, (ListLast(#image_url_in_ckeditor#, "\")))>
            </cfoutput>
        </cfloop>
        
        <cfset ArraySort(array_image_file_names_from_ckeditor, "textnocase", "desc")>                           <!--- sort to compare in RetainAll() --->
        <cfset array_images_on_server_that_match_the_ckeditor.retainAll(array_image_file_names_from_ckeditor)>  <!--- compare two arrays, retain all images that are the same --->        
        <cfset array_of_images_on_server_to_delete.removeAll(array_image_file_names_from_ckeditor)>             <!--- remove all file names that match between two arrays --->
        
        <cfloop array="#array_of_images_on_server_to_delete#" index="file_to_delete_in_server_folder">
            <cfoutput>
                <cfset position = array_of_images_on_server_to_delete.indexOf(file_to_delete_in_server_folder) + 1>
                <script>console.log('DO delete this file ' + '#file_to_delete_in_server_folder#');</script>
                <cffile action="delete" file="#path_server_directory##file_to_delete_in_server_folder#">
            </cfoutput>
        </cfloop><!--- END delete files --->
        
        <cfcatch type="any">
            <cfoutput>
                <script>console.log('ERROR:' + '\n' + 'Delete Image(s)' + '\n' + '#cfcatch.message#' + '\n' + '#cfcatch.detail#');</script>
                <div class="base64_warning_container" style="border:1px solid red;padding:5px 5px;min-height:50px;width:100%;background-color:rgba(253,2,6,0.62);">
                    <h3 class="base64_warning"><span>ERROR:</span></h3>
                    <p>Performing action in: Delete Image(s)</p>
                    <p class="base64_warning">#cfcatch.message#</p>
                    <p class="base64_warning">#cfcatch.detail#</p>
                </div>
            </cfoutput>
        </cfcatch> 
    </cftry> 
    
    <cfelse>
        <cflocation url="#referer_cfm_page#?msg=empty"/> <!---fail, no image - form_upload_image is empty--->
    
  </cfif><!---END form not empty--->
  

    <cflocation url="#referer_cfm_page#?msg=success&img=#return_image_file_name#"/> <!--- SUCCESS, send user back to calling page w/ file name---> 

<cfelse> 
 
      <cflocation url="#referer_cfm_page#?msg=not_post"/> <!--- fail, form not submitted --->
      
</cfif><!------><!---END form post request--->


<!---  <cfexit>  _________________________________________________________________________________________________________________ END Image Processing --->

</div>
<!---END of file--->

<!--- 
    <cffunction name="dumpAll">
        <cfdump var='#cgi#'>
        <cfdump var="#form#"> 
        <cfdump var="#variables#"> 
        <cfdump var="#request#">
    </cffunction>
    <cfset dumpAll()>
--->
<!---
    <cfabort> 
    Create Image Thumbnail    
    <cfif directoryExists(#path_server_directory# & "\thumb\" )> 
        <cfset folder_thumb = "thumb">
    <cfelse>
        <cfset directoryCreate(#path_server_directory# & "\thumb\")>
        <cfset folder_thumb = "thumb">
    </cfif>
    <cfimage action="resize" height="50" width="" 
             source="#folder_user_cacedipi#\#return_image_file_name#" 
             destination="#folder_user_cacedipi#\#folder_thumb#\#return_image_file_name#" 
             overwrite="yes" />
--->